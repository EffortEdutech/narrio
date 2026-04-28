import type { Database, NarrioSupabaseClient } from "@narrio/db";

type Tables = Database["public"]["Tables"];
type StoryRow = Tables["stories"]["Row"];
type BranchRow = Tables["story_branches"]["Row"];
type ChapterRow = Tables["chapters"]["Row"];
type VersionRow = Tables["chapter_versions"]["Row"];
type BookmarkRow = Tables["bookmarks"]["Row"];
type FollowRow = Tables["follows"]["Row"];
type LikeRow = Tables["likes"]["Row"];

export type NarrioActivityKind =
  | "waypoint_saved"
  | "story_followed"
  | "chapter_liked"
  | "timeline_created"
  | "chapter_created";

export type NarrioActivityItem = {
  id: string;
  kind: NarrioActivityKind;
  title: string;
  description: string;
  createdAt: string;
  href: string;
  storyId?: string;
  branchId?: string;
  chapterId?: string;
  tag?: string;
  meta: string[];
};

type ActivityInput = {
  userId: string;
  limit?: number;
};

/**
 * Build the current user's activity feed from existing Narrio tables.
 *
 * Important: this intentionally avoids Supabase/PostgREST nested embeds.
 * The Narrio schema has more than one relationship path between `stories`
 * and `story_branches` (`story_branches.story_id` and `stories.main_branch_id`).
 * Nested embeds can therefore fail with relationship ambiguity errors on some
 * local schemas. Flat queries + in-memory joins are safer for this sprint stub.
 */
export async function listMyActivityFeed(
  client: NarrioSupabaseClient,
  input: ActivityInput
): Promise<NarrioActivityItem[]> {
  const limit = input.limit ?? 60;

  const [bookmarksResponse, followsResponse, likesResponse, timelinesResponse, chaptersResponse] =
    await Promise.all([
      client
        .from("bookmarks")
        .select("id,user_id,chapter_id,tag,is_public,created_at")
        .eq("user_id", input.userId)
        .order("created_at", { ascending: false })
        .limit(limit),
      client
        .from("follows")
        .select("id,user_id,story_id,created_at")
        .eq("user_id", input.userId)
        .order("created_at", { ascending: false })
        .limit(limit),
      client
        .from("likes")
        .select("id,user_id,chapter_version_id,created_at")
        .eq("user_id", input.userId)
        .order("created_at", { ascending: false })
        .limit(limit),
      client
        .from("story_branches")
        .select(
          "id,story_id,parent_branch_id,created_by,name,slug,description,branch_type,status,visibility,forked_from_version_id,created_at,updated_at"
        )
        .eq("created_by", input.userId)
        .order("created_at", { ascending: false })
        .limit(limit),
      client
        .from("chapters")
        .select(
          "id,story_id,branch_id,chapter_number,title,slug,summary,is_published,published_at,created_by,created_at,updated_at"
        )
        .eq("created_by", input.userId)
        .order("created_at", { ascending: false })
        .limit(limit)
    ]);

  assertNoError("load bookmark activity", bookmarksResponse.error);
  assertNoError("load follow activity", followsResponse.error);
  assertNoError("load like activity", likesResponse.error);
  assertNoError("load timeline activity", timelinesResponse.error);
  assertNoError("load chapter activity", chaptersResponse.error);

  const bookmarks = (bookmarksResponse.data ?? []) as BookmarkRow[];
  const follows = (followsResponse.data ?? []) as FollowRow[];
  const likes = (likesResponse.data ?? []) as LikeRow[];
  const timelines = (timelinesResponse.data ?? []) as BranchRow[];
  const authoredChapters = (chaptersResponse.data ?? []) as ChapterRow[];

  const likedVersions = await fetchVersionsByIds(
    client,
    unique(likes.map((row) => row.chapter_version_id))
  );

  const chapterIds = unique([
    ...bookmarks.map((row) => row.chapter_id),
    ...Array.from(likedVersions.values()).map((row) => row.chapter_id),
    ...authoredChapters.map((row) => row.id)
  ]);

  const chapters = await fetchChaptersByIds(client, chapterIds);

  const branchIds = unique([
    ...timelines.map((row) => row.id),
    ...authoredChapters.map((row) => row.branch_id),
    ...Array.from(chapters.values()).map((row) => row.branch_id)
  ]);

  const branches = await fetchBranchesByIds(client, branchIds);

  const storyIds = unique([
    ...follows.map((row) => row.story_id),
    ...timelines.map((row) => row.story_id),
    ...authoredChapters.map((row) => row.story_id),
    ...Array.from(chapters.values()).map((row) => row.story_id),
    ...Array.from(branches.values()).map((row) => row.story_id)
  ]);

  const stories = await fetchStoriesByIds(client, storyIds);

  const items: NarrioActivityItem[] = [
    ...mapBookmarkRows(bookmarks, chapters, stories),
    ...mapFollowRows(follows, stories),
    ...mapLikeRows(likes, likedVersions, chapters, stories),
    ...mapTimelineRows(timelines, stories),
    ...mapChapterRows(authoredChapters, branches, stories)
  ];

  return items
    .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    .slice(0, limit);
}

async function fetchStoriesByIds(client: NarrioSupabaseClient, ids: string[]) {
  if (!ids.length) return new Map<string, StoryRow>();

  const { data, error } = await client
    .from("stories")
    .select(
      "id,author_id,forked_from_story_id,title,slug,synopsis,cover_url,status,visibility,allow_forks,main_branch_id,created_at,updated_at"
    )
    .in("id", ids);

  assertNoError("load activity stories", error);
  return mapById((data ?? []) as StoryRow[]);
}

async function fetchBranchesByIds(client: NarrioSupabaseClient, ids: string[]) {
  if (!ids.length) return new Map<string, BranchRow>();

  const { data, error } = await client
    .from("story_branches")
    .select(
      "id,story_id,parent_branch_id,created_by,name,slug,description,branch_type,status,visibility,forked_from_version_id,created_at,updated_at"
    )
    .in("id", ids);

  assertNoError("load activity branches", error);
  return mapById((data ?? []) as BranchRow[]);
}

async function fetchChaptersByIds(client: NarrioSupabaseClient, ids: string[]) {
  if (!ids.length) return new Map<string, ChapterRow>();

  const { data, error } = await client
    .from("chapters")
    .select(
      "id,story_id,branch_id,chapter_number,title,slug,summary,is_published,published_at,created_by,created_at,updated_at"
    )
    .in("id", ids);

  assertNoError("load activity chapters", error);
  return mapById((data ?? []) as ChapterRow[]);
}

async function fetchVersionsByIds(client: NarrioSupabaseClient, ids: string[]) {
  if (!ids.length) return new Map<string, VersionRow>();

  const { data, error } = await client
    .from("chapter_versions")
    .select(
      "id,chapter_id,version_number,title,excerpt,content_md,source,commit_message,is_current,created_by,created_at"
    )
    .in("id", ids);

  assertNoError("load activity chapter versions", error);
  return mapById((data ?? []) as VersionRow[]);
}

function mapBookmarkRows(
  rows: BookmarkRow[],
  chapters: Map<string, ChapterRow>,
  stories: Map<string, StoryRow>
): NarrioActivityItem[] {
  return rows
    .map((row) => {
      const chapter = chapters.get(row.chapter_id);
      const story = chapter ? stories.get(chapter.story_id) : undefined;
      if (!chapter || !story) return null;

      return {
        id: `bookmark:${row.id}`,
        kind: "waypoint_saved" as const,
        title: `Saved ${labelForTag(row.tag)} waypoint`,
        description: `${story.title} · Chapter ${chapter.chapter_number}: ${chapter.title}`,
        createdAt: row.created_at,
        href: `/story/${story.id}/chapter/${chapter.id}`,
        storyId: story.id,
        branchId: chapter.branch_id,
        chapterId: chapter.id,
        tag: row.tag,
        meta: ["Waypoint", row.tag]
      };
    })
    .filter(isActivityItem);
}

function mapFollowRows(rows: FollowRow[], stories: Map<string, StoryRow>): NarrioActivityItem[] {
  return rows
    .map((row) => {
      const story = stories.get(row.story_id);
      if (!story) return null;

      return {
        id: `follow:${row.id}`,
        kind: "story_followed" as const,
        title: "Followed a story",
        description: story.title,
        createdAt: row.created_at,
        href: `/story/${story.id}`,
        storyId: story.id,
        meta: ["Follow"]
      };
    })
    .filter(isActivityItem);
}

function mapLikeRows(
  rows: LikeRow[],
  versions: Map<string, VersionRow>,
  chapters: Map<string, ChapterRow>,
  stories: Map<string, StoryRow>
): NarrioActivityItem[] {
  return rows
    .map((row) => {
      const version = versions.get(row.chapter_version_id);
      const chapter = version ? chapters.get(version.chapter_id) : undefined;
      const story = chapter ? stories.get(chapter.story_id) : undefined;
      if (!version || !chapter || !story) return null;

      return {
        id: `like:${row.id}`,
        kind: "chapter_liked" as const,
        title: "Liked a chapter version",
        description: `${story.title} · Chapter ${chapter.chapter_number}: ${chapter.title}`,
        createdAt: row.created_at,
        href: `/story/${story.id}/chapter/${chapter.id}`,
        storyId: story.id,
        branchId: chapter.branch_id,
        chapterId: chapter.id,
        meta: ["Like", `Version ${version.version_number}`]
      };
    })
    .filter(isActivityItem);
}

function mapTimelineRows(rows: BranchRow[], stories: Map<string, StoryRow>): NarrioActivityItem[] {
  return rows
    .map((row) => {
      const story = stories.get(row.story_id);
      if (!story) return null;

      const action = row.branch_type === "main" ? "Started main timeline" : "Created a fork timeline";

      return {
        id: `timeline:${row.id}`,
        kind: "timeline_created" as const,
        title: action,
        description: `${story.title} · ${row.name}`,
        createdAt: row.created_at,
        href: `/story/${story.id}/branch/${row.id}`,
        storyId: story.id,
        branchId: row.id,
        meta: ["Timeline", row.branch_type, row.visibility]
      };
    })
    .filter(isActivityItem);
}

function mapChapterRows(
  rows: ChapterRow[],
  branches: Map<string, BranchRow>,
  stories: Map<string, StoryRow>
): NarrioActivityItem[] {
  return rows
    .map((row) => {
      const story = stories.get(row.story_id);
      const branch = branches.get(row.branch_id);
      if (!story) return null;

      return {
        id: `chapter:${row.id}`,
        kind: "chapter_created" as const,
        title: "Added a chapter",
        description: `${story.title} · Chapter ${row.chapter_number}: ${row.title}`,
        createdAt: row.created_at,
        href: `/story/${story.id}/chapter/${row.id}`,
        storyId: story.id,
        branchId: row.branch_id,
        chapterId: row.id,
        meta: ["Chapter", row.is_published ? "Published" : "Draft", branch?.name ?? "Timeline"]
      };
    })
    .filter(isActivityItem);
}

function mapById<T extends { id: string }>(rows: T[]): Map<string, T> {
  return new Map(rows.map((row) => [row.id, row]));
}

function unique(values: string[]): string[] {
  return Array.from(new Set(values.filter(Boolean)));
}

function labelForTag(tag: string) {
  return tag
    .replace(/[-_]+/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .replace(/^./, (value) => value.toUpperCase());
}

function isActivityItem(value: NarrioActivityItem | null): value is NarrioActivityItem {
  return value !== null;
}

function assertNoError(context: string, error: unknown): asserts error is null {
  if (!error) return;

  if (typeof error === "object" && error !== null) {
    const maybeError = error as {
      code?: string;
      message?: string;
      details?: string | null;
      hint?: string | null;
    };

    const parts = [
      maybeError.message,
      maybeError.code ? `code: ${maybeError.code}` : null,
      maybeError.details ? `details: ${maybeError.details}` : null,
      maybeError.hint ? `hint: ${maybeError.hint}` : null
    ].filter(Boolean);

    throw new Error(`Could not ${context}. ${parts.join(" | ")}`);
  }

  throw new Error(`Could not ${context}. ${String(error)}`);
}
