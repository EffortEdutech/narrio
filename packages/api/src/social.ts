import type { NarrioSupabaseClient } from "@narrio/db";

export const BOOKMARK_TAG_PRESETS = [
  { tag: "favorite", label: "Favorite", description: "A chapter you want to return to." },
  { tag: "reread", label: "Reread", description: "A moment worth reading again." },
  { tag: "theory", label: "Theory", description: "A clue, mystery, or prediction." },
  { tag: "quote", label: "Quote", description: "A line or scene you want to remember." },
  { tag: "fork-idea", label: "Fork idea", description: "A possible path for your own timeline." }
] as const;

export type BookmarkTagPreset = (typeof BOOKMARK_TAG_PRESETS)[number];

export function normalizeBookmarkTag(value: unknown) {
  const raw = String(value ?? "favorite").trim().toLowerCase();
  const normalized = raw
    .replace(/&/g, "and")
    .replace(/[^a-z0-9\s_-]/g, "")
    .replace(/[\s_]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 40);

  return normalized || "favorite";
}

export function getBookmarkTagLabel(tag: string) {
  return BOOKMARK_TAG_PRESETS.find((preset) => preset.tag === tag)?.label ?? tag;
}

export async function isFollowingStory(
  client: NarrioSupabaseClient,
  input: { userId: string; storyId: string }
) {
  const { data, error } = await client
    .from("follows")
    .select("id")
    .eq("user_id", input.userId)
    .eq("story_id", input.storyId)
    .maybeSingle();

  if (error) throw error;
  return Boolean(data);
}

export async function toggleFollowStory(
  client: NarrioSupabaseClient,
  input: { userId: string; storyId: string }
) {
  const following = await isFollowingStory(client, input);

  if (following) {
    const { error } = await client
      .from("follows")
      .delete()
      .eq("user_id", input.userId)
      .eq("story_id", input.storyId);
    if (error) throw error;
    return { following: false };
  }

  const { error } = await client.from("follows").insert({
    user_id: input.userId,
    story_id: input.storyId
  });

  if (error) throw error;
  return { following: true };
}

export async function hasLikedVersion(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterVersionId: string }
) {
  const { data, error } = await client
    .from("likes")
    .select("id")
    .eq("user_id", input.userId)
    .eq("chapter_version_id", input.chapterVersionId)
    .limit(1);

  if (error) throw error;
  return Boolean((data ?? [])[0]);
}

export async function toggleLikeVersion(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterVersionId: string }
) {
  const liked = await hasLikedVersion(client, input);

  if (liked) {
    const { error } = await client
      .from("likes")
      .delete()
      .eq("user_id", input.userId)
      .eq("chapter_version_id", input.chapterVersionId);
    if (error) throw error;
    return { liked: false };
  }

  const { error } = await client.from("likes").insert({
    user_id: input.userId,
    chapter_version_id: input.chapterVersionId
  });

  if (error) throw error;
  return { liked: true };
}

export async function hasBookmarkedChapter(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterId: string; tag?: string }
) {
  const tag = normalizeBookmarkTag(input.tag);
  const { data, error } = await client
    .from("bookmarks")
    .select("id")
    .eq("user_id", input.userId)
    .eq("chapter_id", input.chapterId)
    .eq("tag", tag)
    .limit(1);

  if (error) throw error;
  return Boolean((data ?? [])[0]);
}

export async function listBookmarkTagsForChapter(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterId: string }
) {
  const { data, error } = await client
    .from("bookmarks")
    .select("id, tag, is_public, created_at")
    .eq("user_id", input.userId)
    .eq("chapter_id", input.chapterId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function saveBookmarkChapter(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterId: string; tag?: string; isPublic?: boolean }
) {
  const tag = normalizeBookmarkTag(input.tag);

  // Keep the UX deterministic even before the optional unique index is applied.
  const { error: deleteError } = await client
    .from("bookmarks")
    .delete()
    .eq("user_id", input.userId)
    .eq("chapter_id", input.chapterId)
    .eq("tag", tag);

  if (deleteError) throw deleteError;

  const { data, error } = await client
    .from("bookmarks")
    .insert({
      user_id: input.userId,
      chapter_id: input.chapterId,
      tag,
      is_public: input.isPublic ?? false
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function toggleBookmarkChapter(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterId: string; tag?: string; isPublic?: boolean }
) {
  const tag = normalizeBookmarkTag(input.tag);
  const bookmarked = await hasBookmarkedChapter(client, {
    userId: input.userId,
    chapterId: input.chapterId,
    tag
  });

  if (bookmarked) {
    const { error } = await client
      .from("bookmarks")
      .delete()
      .eq("user_id", input.userId)
      .eq("chapter_id", input.chapterId)
      .eq("tag", tag);
    if (error) throw error;
    return { bookmarked: false, tag };
  }

  await saveBookmarkChapter(client, {
    userId: input.userId,
    chapterId: input.chapterId,
    tag,
    isPublic: input.isPublic ?? false
  });

  return { bookmarked: true, tag };
}

export async function deleteBookmarkById(
  client: NarrioSupabaseClient,
  input: { userId: string; bookmarkId: string }
) {
  const { error } = await client
    .from("bookmarks")
    .delete()
    .eq("id", input.bookmarkId)
    .eq("user_id", input.userId);

  if (error) throw error;
  return { deleted: true };
}

export async function listBookmarksWithContext(client: NarrioSupabaseClient, userId: string) {
  const { data, error } = await client
    .from("bookmarks")
    .select(`
      id,
      tag,
      is_public,
      created_at,
      chapter_id,
      chapters!inner(
        id,
        title,
        chapter_number,
        story_id,
        branch_id,
        stories!inner(
          id,
          title
        ),
        story_branches!inner(
          id,
          name,
          slug
        )
      )
    `)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}
