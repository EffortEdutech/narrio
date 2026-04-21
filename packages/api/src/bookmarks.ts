import type { NarrioSupabaseClient } from "@narrio/db";

export async function addBookmark(
  client: NarrioSupabaseClient,
  input: {
    userId: string;
    chapterId: string;
    tag: string;
    isPublic?: boolean;
  }
) {
  const { data, error } = await client
    .from("bookmarks")
    .insert({
      user_id: input.userId,
      chapter_id: input.chapterId,
      tag: input.tag,
      is_public: input.isPublic ?? false
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function listUserBookmarks(client: NarrioSupabaseClient, userId: string) {
  const { data, error } = await client
    .from("bookmarks")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}
