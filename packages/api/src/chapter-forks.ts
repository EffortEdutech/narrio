import type { Database, NarrioSupabaseClient } from "@narrio/db";
import { getBranchById } from "./branches";
import { getCurrentVersionByChapterId } from "./chapters";
import { getStoryById } from "./stories";

type Story = Database["public"]["Tables"]["stories"]["Row"];
type StoryBranch = Database["public"]["Tables"]["story_branches"]["Row"];
type Chapter = Database["public"]["Tables"]["chapters"]["Row"];
type ChapterVersion = Database["public"]["Tables"]["chapter_versions"]["Row"];

export type ForkSource = {
  story: Story;
  branch: StoryBranch;
  chapter: Chapter;
  currentVersion: ChapterVersion;
};

export type ForkBranchFromChapterInput = {
  storyId: string;
  sourceBranchId: string;
  sourceChapterId: string;
  createdBy: string;
  name: string;
  slug: string;
  description?: string | null;
  visibility?: "public" | "private";
};

export type ForkBranchFromChapterResult = {
  branch: StoryBranch;
  copiedChapters: Chapter[];
  forkPointChapter: Chapter | null;
};

function assertRecord<T>(value: T | null, label: string): T {
  if (!value) {
    throw new Error(`${label} was not found.`);
  }

  return value;
}

async function getLatestVersionForCopy(
  client: NarrioSupabaseClient,
  chapterId: string
): Promise<ChapterVersion | null> {
  const { data, error } = await client
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .order("is_current", { ascending: false })
    .order("version_number", { ascending: false })
    .limit(1);

  if (error) throw error;

  return ((data ?? [])[0] ?? null) as ChapterVersion | null;
}

function safeVersionSource(value: unknown): "human" | "ai" | "import" {
  return value === "ai" || value === "import" || value === "human" ? value : "human";
}

function makeConflictSafeSlug(baseSlug: string, attempt: number) {
  const base = baseSlug.replace(/-+$/g, "") || "fork";
  const suffix = `${Date.now().toString(36)}-${attempt + 1}`;
  return `${base}-${suffix}`.slice(0, 96);
}

export async function getForkSourceByChapterId(
  client: NarrioSupabaseClient,
  storyId: string,
  chapterId: string
): Promise<ForkSource> {
  const story = await getStoryById(client, storyId);

  const { data: chapter, error: chapterError } = await client
    .from("chapters")
    .select("*")
    .eq("id", chapterId)
    .single();

  if (chapterError) throw chapterError;

  const safeChapter = assertRecord(chapter as Chapter | null, "Chapter");

  if ((safeChapter as any).story_id && (safeChapter as any).story_id !== story.id) {
    throw new Error("This chapter does not belong to the requested story.");
  }

  const branch = await getBranchById(client, safeChapter.branch_id);
  const currentVersion = await getCurrentVersionByChapterId(client, safeChapter.id);

  return {
    story,
    branch,
    chapter: safeChapter,
    currentVersion
  };
}

export async function forkBranchFromChapter(
  client: NarrioSupabaseClient,
  input: ForkBranchFromChapterInput
): Promise<ForkBranchFromChapterResult> {
  const story = await getStoryById(client, input.storyId);
  const sourceBranch = await getBranchById(client, input.sourceBranchId);

  if (sourceBranch.story_id !== story.id) {
    throw new Error("The source timeline does not belong to this story.");
  }

  const { data: sourceChapterData, error: sourceChapterError } = await client
    .from("chapters")
    .select("*")
    .eq("id", input.sourceChapterId)
    .single();

  if (sourceChapterError) throw sourceChapterError;

  const sourceChapter = assertRecord(sourceChapterData as Chapter | null, "Source chapter");

  if (sourceChapter.branch_id !== sourceBranch.id) {
    throw new Error("The selected chapter does not belong to the source timeline.");
  }

  if ((sourceChapter as any).story_id && (sourceChapter as any).story_id !== story.id) {
    throw new Error("The selected chapter does not belong to this story.");
  }

  const canFork = Boolean((story as any).allow_forks) || story.author_id === input.createdBy || sourceBranch.created_by === input.createdBy;

  if (!canFork) {
    throw new Error("ForkCraft is not enabled for this story.");
  }

  let branchData: StoryBranch | null = null;
  let lastBranchError: unknown = null;
  let candidateSlug = input.slug;

  for (let attempt = 0; attempt < 5; attempt += 1) {
    const { data, error } = await client
      .from("story_branches")
      .insert({
        story_id: story.id,
        parent_branch_id: sourceBranch.id,
        name: input.name,
        slug: candidateSlug,
        description: input.description ?? null,
        branch_type: "fork",
        // Branch status is the technical lifecycle status.
        // Draft/private is represented by visibility="private" in the current schema.
        status: "active",
        visibility: input.visibility === "public" ? "public" : "private",
        created_by: input.createdBy
      } as any)
      .select("*")
      .single();

    if (!error) {
      branchData = data as StoryBranch;
      break;
    }

    lastBranchError = error;

    if ((error as { code?: string }).code !== "23505") {
      throw error;
    }

    candidateSlug = makeConflictSafeSlug(input.slug, attempt);
  }

  if (!branchData) {
    throw lastBranchError instanceof Error ? lastBranchError : new Error("Could not create fork timeline.");
  }

  const newBranch = assertRecord(branchData as StoryBranch | null, "New timeline");

  const { data: sourceChaptersData, error: sourceChaptersError } = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", sourceBranch.id)
    .lte("chapter_number", sourceChapter.chapter_number)
    .order("chapter_number", { ascending: true });

  if (sourceChaptersError) throw sourceChaptersError;

  const sourceChapters = (sourceChaptersData ?? []) as Chapter[];
  const copiedChapters: Chapter[] = [];
  let forkPointChapter: Chapter | null = null;

  for (const chapter of sourceChapters) {
    const { data: copiedChapterData, error: copiedChapterError } = await client
      .from("chapters")
      .insert({
        story_id: story.id,
        branch_id: newBranch.id,
        chapter_number: chapter.chapter_number,
        title: chapter.title,
        slug: (chapter as any).slug ?? null,
        summary: (chapter as any).summary ?? null,
        is_published: (chapter as any).is_published ?? true,
        published_at: (chapter as any).published_at ?? null,
        created_by: input.createdBy
      } as any)
      .select("*")
      .single();

    if (copiedChapterError) throw copiedChapterError;

    const copiedChapter = assertRecord(copiedChapterData as Chapter | null, "Copied chapter");
    copiedChapters.push(copiedChapter);

    if (chapter.id === sourceChapter.id) {
      forkPointChapter = copiedChapter;
    }

    const sourceVersion = await getLatestVersionForCopy(client, chapter.id);

    if (!sourceVersion) {
      continue;
    }

    const { error: copiedVersionError } = await client.from("chapter_versions").insert({
      chapter_id: copiedChapter.id,
      version_number: 1,
      title: (sourceVersion as any).title ?? chapter.title,
      content_md: (sourceVersion as any).content_md,
      excerpt: (sourceVersion as any).excerpt ?? null,
      commit_message: `Fork snapshot from ${sourceBranch.name}, Chapter ${chapter.chapter_number}`,
      source: safeVersionSource((sourceVersion as any).source),
      is_current: true,
      created_by: input.createdBy
    } as any);

    if (copiedVersionError) throw copiedVersionError;
  }

  return {
    branch: newBranch,
    copiedChapters,
    forkPointChapter
  };
}
