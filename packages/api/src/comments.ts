import type { NarrioSupabaseClient } from "@narrio/db";

export async function listCommentsByChapterId(
  client: NarrioSupabaseClient,
  chapterId: string
) {
  const { data, error } = await client
    .from("comments")
    .select(`
      id,
      chapter_id,
      story_id,
      user_id,
      parent_comment_id,
      body,
      is_spoiler,
      created_at
    `)
    .eq("chapter_id", chapterId)
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function createComment(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    storyId: string;
    userId: string;
    body: string;
    isSpoiler?: boolean;
    parentCommentId?: string;
  }
) {
  const { data, error } = await client
    .from("comments")
    .insert({
      chapter_id: input.chapterId,
      story_id: input.storyId,
      user_id: input.userId,
      body: input.body,
      is_spoiler: input.isSpoiler ?? false,
      parent_comment_id: input.parentCommentId ?? null
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}
