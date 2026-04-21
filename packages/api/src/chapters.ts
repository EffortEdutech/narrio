import type { NarrioSupabaseClient } from "@narrio/db";

export async function getChaptersByBranchId(client: NarrioSupabaseClient, branchId: string) {
  const { data, error } = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", branchId)
    .order("chapter_number", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function getChapterById(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client
    .from("chapters")
    .select("*")
    .eq("id", chapterId)
    .single();

  if (error) throw error;
  return data;
}

export async function getCurrentVersionByChapterId(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .eq("is_current", true)
    .single();

  if (error) throw error;
  return data;
}

export async function createChapter(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    branchId: string;
    chapterNumber: number;
    title: string;
    createdBy: string;
    summary?: string | null;
  }
) {
  const { data, error } = await client
    .from("chapters")
    .insert({
      story_id: input.storyId,
      branch_id: input.branchId,
      chapter_number: input.chapterNumber,
      title: input.title,
      summary: input.summary ?? null,
      created_by: input.createdBy
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function commitChapterVersion(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    title: string;
    excerpt?: string | null;
    contentMd: string;
    createdBy: string;
    source?: "human" | "ai" | "import";
    commitMessage?: string | null;
  }
) {
  const { data: versions, error: versionLookupError } = await client
    .from("chapter_versions")
    .select("version_number")
    .eq("chapter_id", input.chapterId)
    .order("version_number", { ascending: false })
    .limit(1);

  if (versionLookupError) throw versionLookupError;

  const nextVersion = (versions?.[0]?.version_number ?? 0) + 1;

  const { data, error } = await client
    .from("chapter_versions")
    .insert({
      chapter_id: input.chapterId,
      version_number: nextVersion,
      title: input.title,
      excerpt: input.excerpt ?? null,
      content_md: input.contentMd,
      created_by: input.createdBy,
      source: input.source ?? "human",
      commit_message: input.commitMessage ?? null,
      is_current: true
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}
