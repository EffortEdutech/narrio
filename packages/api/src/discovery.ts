import type { Database, NarrioSupabaseClient } from "@narrio/db";

type Profile = Pick<
  Database["public"]["Tables"]["profiles"]["Row"],
  "id" | "username" | "display_name" | "avatar_url" | "bio"
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

export type LibrarySortMode = "newest" | "updated" | "title" | "chapters" | "timelines";
export type LibraryPathMode = "all" | "root" | "forkcraft";
export type LibraryForkMode = "all" | "forkable" | "closed";

export type LibraryDiscoveryInput = {
  query?: string | null;
  sort?: string | null;
  path?: string | null;
  fork?: string | null;
};

export type LibraryDiscoveryItem = {
  story: Story;
  author: Profile | null;
  startChapter: Chapter | null;
  latestChapter: Chapter | null;
  timelineCount: number;
  rootTimelineCount: number;
  forkTimelineCount: number;
  publishedChapterCount: number;
  latestPublishedAt: string | null;
  searchScore: number;
};

export type LibraryDiscoveryResult = {
  query: string;
  sort: LibrarySortMode;
  path: LibraryPathMode;
  fork: LibraryForkMode;
  totalStories: number;
  totalTimelines: number;
  totalPublishedChapters: number;
  forkableStories: number;
  items: LibraryDiscoveryItem[];
};

function normalizeText(value?: string | null) {
  return (value ?? "").trim().toLowerCase();
}

function normalizeSort(value?: string | null): LibrarySortMode {
  if (value === "updated" || value === "title" || value === "chapters" || value === "timelines") return value;
  return "newest";
}

function normalizePath(value?: string | null): LibraryPathMode {
  if (value === "root" || value === "forkcraft") return value;
  return "all";
}

function normalizeFork(value?: string | null): LibraryForkMode {
  if (value === "forkable" || value === "closed") return value;
  return "all";
}

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

function scoreStoryMatch(story: Story, author: Profile | null, query: string) {
  if (!query) return 1;

  const title = normalizeText(story.title);
  const synopsis = normalizeText(story.synopsis);
  const writer = normalizeText(author?.display_name ?? author?.username);
  const terms = query.split(/\s+/).filter(Boolean);

  let score = 0;

  for (const term of terms) {
    if (title === term) score += 10;
    if (title.includes(term)) score += 6;
    if (synopsis.includes(term)) score += 3;
    if (writer.includes(term)) score += 2;
  }

  return score;
}

export async function getLibraryDiscovery(
  client: NarrioSupabaseClient,
  input: LibraryDiscoveryInput = {}
): Promise<LibraryDiscoveryResult> {
  const query = normalizeText(input.query);
  const sort = normalizeSort(input.sort);
  const path = normalizePath(input.path);
  const fork = normalizeFork(input.fork);

  const { data: stories, error: storiesError } = await client
    .from("stories")
    .select(
      "id, author_id, forked_from_story_id, title, slug, synopsis, cover_url, status, visibility, allow_forks, main_branch_id, created_at, updated_at"
    )
    .eq("status", "published")
    .eq("visibility", "public")
    .order("created_at", { ascending: false });

  if (storiesError) throw storiesError;

  const publicStories = (stories ?? []) as Story[];
  const storyIds = publicStories.map((story) => story.id);
  const authorIds = Array.from(new Set(publicStories.map((story) => story.author_id)));

  const { data: profiles, error: profilesError } = authorIds.length
    ? await client
        .from("profiles")
        .select("id, username, display_name, avatar_url, bio")
        .in("id", authorIds)
    : { data: [], error: null };

  if (profilesError) throw profilesError;

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

  const authorById = new Map((profiles ?? []).map((profile) => [profile.id, profile as Profile]));
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

  const items = publicStories
    .map((story): LibraryDiscoveryItem => {
      const author = authorById.get(story.author_id) ?? null;
      const storyBranches = branchesByStoryId.get(story.id) ?? [];
      const storyChapters = (chaptersByStoryId.get(story.id) ?? []).sort(byChapterNumber);
      const latestChapter = [...storyChapters].sort(byLatestChapterDate)[0] ?? null;
      const rootTimelineCount = storyBranches.filter((branch) => branch.branch_type === "main").length;
      const forkTimelineCount = storyBranches.filter((branch) => branch.branch_type !== "main").length;

      return {
        story,
        author,
        startChapter: storyChapters[0] ?? null,
        latestChapter,
        timelineCount: storyBranches.length,
        rootTimelineCount,
        forkTimelineCount,
        publishedChapterCount: storyChapters.length,
        latestPublishedAt: latestChapter?.published_at ?? latestChapter?.updated_at ?? story.updated_at ?? story.created_at,
        searchScore: scoreStoryMatch(story, author, query)
      };
    })
    .filter((item) => (query ? item.searchScore > 0 : true))
    .filter((item) => {
      if (path === "root") return item.rootTimelineCount > 0;
      if (path === "forkcraft") return item.forkTimelineCount > 0;
      return true;
    })
    .filter((item) => {
      if (fork === "forkable") return item.story.allow_forks;
      if (fork === "closed") return !item.story.allow_forks;
      return true;
    });

  items.sort((a, b) => {
    if (query && b.searchScore !== a.searchScore) return b.searchScore - a.searchScore;

    if (sort === "title") return a.story.title.localeCompare(b.story.title);
    if (sort === "updated") return dateValue(b.story.updated_at) - dateValue(a.story.updated_at);
    if (sort === "chapters") return b.publishedChapterCount - a.publishedChapterCount;
    if (sort === "timelines") return b.timelineCount - a.timelineCount;

    return dateValue(b.story.created_at) - dateValue(a.story.created_at);
  });

  return {
    query,
    sort,
    path,
    fork,
    totalStories: items.length,
    totalTimelines: items.reduce((total, item) => total + item.timelineCount, 0),
    totalPublishedChapters: items.reduce((total, item) => total + item.publishedChapterCount, 0),
    forkableStories: items.filter((item) => item.story.allow_forks).length,
    items
  };
}
