import type { Database, NarrioSupabaseClient } from "@narrio/db";

type Profile = Pick<
  Database["public"]["Tables"]["profiles"]["Row"],
  "id" | "username" | "display_name" | "avatar_url" | "bio" | "created_at" | "updated_at"
>;

type Story = Pick<
  Database["public"]["Tables"]["stories"]["Row"],
  | "id"
  | "author_id"
  | "forked_from_story_id"
  | "title"
  | "slug"
  | "synopsis"
  | "cover_url"
  | "status"
  | "visibility"
  | "allow_forks"
  | "main_branch_id"
  | "created_at"
  | "updated_at"
>;

type Branch = Pick<
  Database["public"]["Tables"]["story_branches"]["Row"],
  "id" | "story_id" | "name" | "description" | "branch_type" | "status" | "visibility" | "created_at" | "updated_at"
>;

type Chapter = Pick<
  Database["public"]["Tables"]["chapters"]["Row"],
  | "id"
  | "story_id"
  | "branch_id"
  | "chapter_number"
  | "title"
  | "summary"
  | "is_published"
  | "published_at"
  | "created_at"
  | "updated_at"
>;

export type PublicWriterStoryCard = {
  story: Story;
  startChapter: Chapter | null;
  latestChapter: Chapter | null;
  publicTimelineCount: number;
  rootTimelineCount: number;
  forkTimelineCount: number;
  publishedChapterCount: number;
  latestPublishedAt: string | null;
};

export type PublicWriterProfile = {
  profile: Profile;
  stories: PublicWriterStoryCard[];
  featuredStory: PublicWriterStoryCard | null;
  publicStoryCount: number;
  publicTimelineCount: number;
  rootTimelineCount: number;
  forkTimelineCount: number;
  publishedChapterCount: number;
  forkableStoryCount: number;
  forkedStoryCount: number;
  latestPublishedAt: string | null;
};

function dateValue(value?: string | null) {
  if (!value) return 0;
  const parsed = new Date(value).getTime();
  return Number.isFinite(parsed) ? parsed : 0;
}

function byChapterNumber(a: Chapter, b: Chapter) {
  return a.chapter_number - b.chapter_number;
}

function byLatestChapterDate(a: Chapter, b: Chapter) {
  return dateValue(b.published_at ?? b.updated_at ?? b.created_at) - dateValue(a.published_at ?? a.updated_at ?? a.created_at);
}

function latestDateForCard(card: PublicWriterStoryCard) {
  return dateValue(card.latestPublishedAt ?? card.story.updated_at ?? card.story.created_at);
}

export async function getPublicWriterProfile(
  client: NarrioSupabaseClient,
  userId: string
): Promise<PublicWriterProfile | null> {
  const { data: profile, error: profileError } = await client
    .from("profiles")
    .select("id, username, display_name, avatar_url, bio, created_at, updated_at")
    .eq("id", userId)
    .maybeSingle();

  if (profileError) throw profileError;
  if (!profile) return null;

  const { data: stories, error: storiesError } = await client
    .from("stories")
    .select(
      "id, author_id, forked_from_story_id, title, slug, synopsis, cover_url, status, visibility, allow_forks, main_branch_id, created_at, updated_at"
    )
    .eq("author_id", userId)
    .eq("status", "published")
    .eq("visibility", "public")
    .order("updated_at", { ascending: false });

  if (storiesError) throw storiesError;

  const publicStories = (stories ?? []) as Story[];
  const storyIds = publicStories.map((story) => story.id);

  const { data: branches, error: branchesError } = storyIds.length
    ? await client
        .from("story_branches")
        .select("id, story_id, name, description, branch_type, status, visibility, created_at, updated_at")
        .in("story_id", storyIds)
        .eq("status", "active")
    : { data: [], error: null };

  if (branchesError) throw branchesError;

  const publicBranches = ((branches ?? []) as Branch[]).filter((branch) => branch.visibility === "public");
  const publicBranchIds = new Set(publicBranches.map((branch) => branch.id));

  const { data: chapters, error: chaptersError } = storyIds.length
    ? await client
        .from("chapters")
        .select("id, story_id, branch_id, chapter_number, title, summary, is_published, published_at, created_at, updated_at")
        .in("story_id", storyIds)
        .eq("is_published", true)
    : { data: [], error: null };

  if (chaptersError) throw chaptersError;

  const publishedChapters = ((chapters ?? []) as Chapter[]).filter((chapter) => publicBranchIds.has(chapter.branch_id));

  const branchesByStoryId = new Map<string, Branch[]>();
  const chaptersByStoryId = new Map<string, Chapter[]>();

  for (const branch of publicBranches) {
    const list = branchesByStoryId.get(branch.story_id) ?? [];
    list.push(branch);
    branchesByStoryId.set(branch.story_id, list);
  }

  for (const chapter of publishedChapters) {
    const list = chaptersByStoryId.get(chapter.story_id) ?? [];
    list.push(chapter);
    chaptersByStoryId.set(chapter.story_id, list);
  }

  const storyCards = publicStories.map((story): PublicWriterStoryCard => {
    const storyBranches = branchesByStoryId.get(story.id) ?? [];
    const storyChapters = (chaptersByStoryId.get(story.id) ?? []).sort(byChapterNumber);
    const latestChapter = [...storyChapters].sort(byLatestChapterDate)[0] ?? null;
    const rootTimelineCount = storyBranches.filter((branch) => branch.branch_type === "main").length;
    const forkTimelineCount = storyBranches.filter((branch) => branch.branch_type !== "main").length;

    return {
      story,
      startChapter: storyChapters[0] ?? null,
      latestChapter,
      publicTimelineCount: storyBranches.length,
      rootTimelineCount,
      forkTimelineCount,
      publishedChapterCount: storyChapters.length,
      latestPublishedAt: latestChapter?.published_at ?? latestChapter?.updated_at ?? story.updated_at ?? story.created_at
    };
  });

  storyCards.sort((a, b) => latestDateForCard(b) - latestDateForCard(a));

  return {
    profile: profile as Profile,
    stories: storyCards,
    featuredStory: storyCards[0] ?? null,
    publicStoryCount: storyCards.length,
    publicTimelineCount: storyCards.reduce((total, item) => total + item.publicTimelineCount, 0),
    rootTimelineCount: storyCards.reduce((total, item) => total + item.rootTimelineCount, 0),
    forkTimelineCount: storyCards.reduce((total, item) => total + item.forkTimelineCount, 0),
    publishedChapterCount: storyCards.reduce((total, item) => total + item.publishedChapterCount, 0),
    forkableStoryCount: storyCards.filter((item) => item.story.allow_forks).length,
    forkedStoryCount: storyCards.filter((item) => item.story.forked_from_story_id).length,
    latestPublishedAt: storyCards[0]?.latestPublishedAt ?? null
  };
}
