import type { Database, NarrioSupabaseClient } from "@narrio/db";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];
type Story = Database["public"]["Tables"]["stories"]["Row"];
type Branch = Database["public"]["Tables"]["story_branches"]["Row"];
type Chapter = Database["public"]["Tables"]["chapters"]["Row"];

export type PublicStoryTimelineCard = {
  branch: Branch;
  chapters: Chapter[];
  publishedChapters: Chapter[];
  firstChapter: Chapter | null;
  latestChapter: Chapter | null;
  chapterCount: number;
  publishedChapterCount: number;
  draftChapterCount: number;
};

export type PublicStoryOverview = {
  story: Story;
  author: Profile | null;
  canEdit: boolean;
  branches: PublicStoryTimelineCard[];
  startChapter: Chapter | null;
  latestChapter: Chapter | null;
  mainBranch: Branch | null;
  totalVisibleBranches: number;
  totalVisibleChapters: number;
  publishedChapterCount: number;
  draftChapterCount: number;
  forkTimelineCount: number;
};

function chapterDateValue(chapter: Chapter) {
  return new Date(chapter.published_at ?? chapter.updated_at ?? chapter.created_at).getTime();
}

function byChapterNumber(a: Chapter, b: Chapter) {
  return a.chapter_number - b.chapter_number;
}

function byLatestChapterDate(a: Chapter, b: Chapter) {
  return chapterDateValue(b) - chapterDateValue(a);
}

export async function getPublicStoryOverview(
  client: NarrioSupabaseClient,
  storyId: string,
  viewerId?: string | null
): Promise<PublicStoryOverview | null> {
  const { data: story, error: storyError } = await client
    .from("stories")
    .select("*")
    .eq("id", storyId)
    .maybeSingle();

  if (storyError) throw storyError;
  if (!story) return null;

  const canEdit = viewerId === story.author_id;

  const { data: author, error: authorError } = await client
    .from("profiles")
    .select("id, username, display_name, avatar_url, bio, created_at, updated_at")
    .eq("id", story.author_id)
    .maybeSingle();

  if (authorError) throw authorError;

  const { data: branches, error: branchesError } = await client
    .from("story_branches")
    .select("*")
    .eq("story_id", storyId)
    .order("created_at", { ascending: true });

  if (branchesError) throw branchesError;

  const visibleBranches = (branches ?? []).filter((branch) => {
    if (canEdit) return true;
    return branch.visibility === "public" || branch.visibility === "unlisted";
  });

  const visibleBranchIds = new Set(visibleBranches.map((branch) => branch.id));

  const { data: chapters, error: chaptersError } = await client
    .from("chapters")
    .select("*")
    .eq("story_id", storyId)
    .order("chapter_number", { ascending: true });

  if (chaptersError) throw chaptersError;

  const visibleChapters = (chapters ?? [])
    .filter((chapter) => visibleBranchIds.has(chapter.branch_id))
    .filter((chapter) => canEdit || chapter.is_published)
    .sort(byChapterNumber);

  const publishedChapters = visibleChapters.filter((chapter) => chapter.is_published);
  const draftChapters = visibleChapters.filter((chapter) => !chapter.is_published);

  const branchesWithChapters = visibleBranches.map((branch) => {
    const branchChapters = visibleChapters
      .filter((chapter) => chapter.branch_id === branch.id)
      .sort(byChapterNumber);
    const branchPublishedChapters = branchChapters.filter((chapter) => chapter.is_published);
    const readableChapters = canEdit ? branchChapters : branchPublishedChapters;
    const latestReadable = [...readableChapters].sort(byLatestChapterDate)[0] ?? null;

    return {
      branch,
      chapters: readableChapters,
      publishedChapters: branchPublishedChapters,
      firstChapter: readableChapters[0] ?? null,
      latestChapter: latestReadable,
      chapterCount: readableChapters.length,
      publishedChapterCount: branchPublishedChapters.length,
      draftChapterCount: branchChapters.length - branchPublishedChapters.length
    };
  });

  const mainBranch = visibleBranches.find((branch) => branch.id === story.main_branch_id) ?? null;
  const mainBranchCard = branchesWithChapters.find((card) => card.branch.id === story.main_branch_id) ?? null;
  const firstPublishedOnMain = mainBranchCard?.publishedChapters[0] ?? null;
  const firstAnyPublished = publishedChapters[0] ?? null;
  const firstDraftForAuthor = canEdit ? visibleChapters[0] ?? null : null;

  const startChapter = firstPublishedOnMain ?? firstAnyPublished ?? firstDraftForAuthor;
  const latestChapter = [...publishedChapters].sort(byLatestChapterDate)[0] ?? startChapter;

  return {
    story,
    author: author ?? null,
    canEdit,
    branches: branchesWithChapters,
    startChapter,
    latestChapter,
    mainBranch,
    totalVisibleBranches: visibleBranches.length,
    totalVisibleChapters: visibleChapters.length,
    publishedChapterCount: publishedChapters.length,
    draftChapterCount: draftChapters.length,
    forkTimelineCount: visibleBranches.filter((branch) => branch.branch_type !== "main").length
  };
}
