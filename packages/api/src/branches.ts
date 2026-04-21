import type { NarrioSupabaseClient } from "@narrio/db";

export async function getBranchById(client: NarrioSupabaseClient, branchId: string) {
  const { data, error } = await client.from("story_branches").select("*").eq("id", branchId).single();
  if (error) throw error;
  return data;
}

export async function getBranchesByStoryId(client: NarrioSupabaseClient, storyId: string) {
  const { data, error } = await client
    .from("story_branches")
    .select("*")
    .eq("story_id", storyId)
    .order("created_at", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function createBranch(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    sourceBranchId: string;
    createdBy: string;
    name: string;
    slug: string;
    description?: string;
  }
) {
  const { data: sourceBranch, error: sourceBranchError } = await client
    .from("story_branches")
    .select("*")
    .eq("id", input.sourceBranchId)
    .single();

  if (sourceBranchError) throw sourceBranchError;

  const { data: newBranch, error: newBranchError } = await client
    .from("story_branches")
    .insert({
      story_id: input.storyId,
      parent_branch_id: input.sourceBranchId,
      created_by: input.createdBy,
      name: input.name,
      slug: input.slug,
      description: input.description ?? null,
      branch_type: sourceBranch.branch_type === "main" ? "alternate" : "fork",
      status: "active",
      visibility: sourceBranch.visibility
    })
    .select("*")
    .single();

  if (newBranchError) throw newBranchError;

  const { data: sourceChapters, error: sourceChaptersError } = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", input.sourceBranchId)
    .order("chapter_number", { ascending: true });

  if (sourceChaptersError) throw sourceChaptersError;

  for (const sourceChapter of sourceChapters ?? []) {
    const { data: newChapter, error: newChapterError } = await client
      .from("chapters")
      .insert({
        story_id: input.storyId,
        branch_id: newBranch.id,
        chapter_number: sourceChapter.chapter_number,
        title: sourceChapter.title,
        slug: sourceChapter.slug,
        summary: sourceChapter.summary,
        is_published: false,
        created_by: input.createdBy
      })
      .select("*")
      .single();

    if (newChapterError) throw newChapterError;

    const { data: latestVersion, error: latestVersionError } = await client
      .from("chapter_versions")
      .select("*")
      .eq("chapter_id", sourceChapter.id)
      .eq("is_current", true)
      .single();

    if (latestVersionError) throw latestVersionError;

    const { error: insertVersionError } = await client.from("chapter_versions").insert({
      chapter_id: newChapter.id,
      version_number: 1,
      title: latestVersion.title,
      excerpt: latestVersion.excerpt,
      content_md: latestVersion.content_md,
      source: latestVersion.source,
      commit_message: `Branched from ${sourceBranch.name}`,
      created_by: input.createdBy,
      is_current: true
    });

    if (insertVersionError) throw insertVersionError;
  }

  return newBranch;
}
