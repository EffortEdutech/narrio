import type { NarrioSupabaseClient } from "@narrio/db";

export async function getChaptersByBranchId(client: NarrioSupabaseClient, branchId: string) {
  const { data, error } = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", branchId)
    .order("chapter_number", { ascending: true });

  if (error) throw error;
  return data ?? [];
}

export async function getChapterById(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client.from("chapters").select("*").eq("id", chapterId).single();
  if (error) throw error;
  return data;
}

export async function getCurrentVersionByChapterId(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .eq("is_current", true)
    .single();

  if (error) throw error;
  return data;
}

export async function getVersionHistory(client: NarrioSupabaseClient, chapterId: string) {
  const { data, error } = await client
    .from("chapter_versions")
    .select("*")
    .eq("chapter_id", chapterId)
    .order("version_number", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function createChapter(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    branchId: string;
    createdBy: string;
    title: string;
    summary?: string;
  }
) {
  const { data: lastChapter, error: lastChapterError } = await client
    .from("chapters")
    .select("chapter_number")
    .eq("branch_id", input.branchId)
    .order("chapter_number", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (lastChapterError) throw lastChapterError;

  const nextNumber = (lastChapter?.chapter_number ?? 0) + 1;
  const slug = `chapter-${nextNumber}`;

  const { data, error } = await client
    .from("chapters")
    .insert({
      story_id: input.storyId,
      branch_id: input.branchId,
      chapter_number: nextNumber,
      title: input.title,
      slug,
      summary: input.summary ?? null,
      created_by: input.createdBy
    })
    .select("*")
    .single();

  if (error) throw error;

  const insertVersion = await client.from("chapter_versions").insert({
    chapter_id: data.id,
    version_number: 1,
    title: input.title,
    excerpt: input.summary ?? null,
    content_md: "# New chapter\n\nStart writing here.",
    source: "human",
    commit_message: "Initial chapter draft",
    created_by: input.createdBy,
    is_current: true
  });

  if (insertVersion.error) throw insertVersion.error;

  return data;
}

export async function createChapterVersion(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    createdBy: string;
    title: string;
    summary?: string;
    contentMd: string;
    commitMessage?: string;
    source?: "human" | "ai" | "import";
  }
) {
  const { data: lastVersion, error: lastVersionError } = await client
    .from("chapter_versions")
    .select("version_number")
    .eq("chapter_id", input.chapterId)
    .order("version_number", { ascending: false })
    .limit(1)
    .maybeSingle();

  if (lastVersionError) throw lastVersionError;

  const nextVersion = (lastVersion?.version_number ?? 0) + 1;

  const { error: chapterUpdateError } = await client
    .from("chapters")
    .update({
      title: input.title,
      summary: input.summary ?? null
    })
    .eq("id", input.chapterId);

  if (chapterUpdateError) throw chapterUpdateError;

  const { data, error } = await client
    .from("chapter_versions")
    .insert({
      chapter_id: input.chapterId,
      version_number: nextVersion,
      title: input.title,
      excerpt: input.summary ?? null,
      content_md: input.contentMd,
      source: input.source ?? "human",
      commit_message: input.commitMessage ?? null,
      created_by: input.createdBy,
      is_current: true
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function restoreChapterVersion(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    versionId: string;
    restoredBy: string;
  }
) {
  const { data: versionToRestore, error: versionError } = await client
    .from("chapter_versions")
    .select("*")
    .eq("id", input.versionId)
    .eq("chapter_id", input.chapterId)
    .single();

  if (versionError) throw versionError;

  return createChapterVersion(client, {
    chapterId: input.chapterId,
    createdBy: input.restoredBy,
    title: versionToRestore.title,
    summary: versionToRestore.excerpt ?? undefined,
    contentMd: versionToRestore.content_md,
    commitMessage: `Restored from version ${versionToRestore.version_number}`,
    source: "human"
  });
}
