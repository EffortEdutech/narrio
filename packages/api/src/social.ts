import type { NarrioSupabaseClient } from "@narrio/db";

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
    .maybeSingle();

  if (error) throw error;
  return Boolean(data);
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
  const { data, error } = await client
    .from("bookmarks")
    .select("id")
    .eq("user_id", input.userId)
    .eq("chapter_id", input.chapterId)
    .eq("tag", input.tag ?? "favorite")
    .maybeSingle();

  if (error) throw error;
  return Boolean(data);
}

export async function toggleBookmarkChapter(
  client: NarrioSupabaseClient,
  input: { userId: string; chapterId: string; tag?: string }
) {
  const tag = input.tag ?? "favorite";
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
    return { bookmarked: false };
  }

  const { error } = await client.from("bookmarks").insert({
    user_id: input.userId,
    chapter_id: input.chapterId,
    tag,
    is_public: false
  });

  if (error) throw error;
  return { bookmarked: true };
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
        stories!inner(
          id,
          title
        )
      )
    `)
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}
