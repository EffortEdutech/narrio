import type { NarrioSupabaseClient } from "@narrio/db";

export async function getVersionHistory(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .order("version_number", { ascending: false });

  if (error) throw error;
  return data ?? [];
}
