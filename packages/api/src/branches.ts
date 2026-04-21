import type { NarrioSupabaseClient } from "@narrio/db";

export async function getBranchesByStoryId(client: NarrioSupabaseClient, storyId: string) {
  const { data, error } = await client
    .from("story_branches")
    .select("*")
    .eq("story_id", storyId)
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function getBranchById(client: NarrioSupabaseClient, branchId: string) {
  const { data, error } = await client
    .from("story_branches")
    .select("*")
    .eq("id", branchId)
    .single();

  if (error) throw error;
  return data;
}
