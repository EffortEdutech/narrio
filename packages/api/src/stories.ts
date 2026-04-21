import type { NarrioSupabaseClient } from "@narrio/db";

export async function listPublishedStories(client: NarrioSupabaseClient) {
  const { data, error } = await client
    .from("stories")
    .select("id, title, slug, synopsis, status, visibility, author_id, forked_from_story_id, main_branch_id, created_at")
    .eq("status", "published")
    .eq("visibility", "public")
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function getStoryById(client: NarrioSupabaseClient, storyId: string) {
  const { data, error } = await client
    .from("stories")
    .select("*")
    .eq("id", storyId)
    .single();

  if (error) throw error;
  return data;
}

export async function getStoryBySlug(client: NarrioSupabaseClient, slug: string) {
  const { data, error } = await client
    .from("stories")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error) throw error;
  return data;
}

export async function createStory(
  client: NarrioSupabaseClient,
  input: {
    authorId: string;
    title: string;
    slug: string;
    synopsis?: string | null;
    visibility?: "public" | "unlisted" | "private";
  }
) {
  const { data, error } = await client
    .from("stories")
    .insert({
      author_id: input.authorId,
      title: input.title,
      slug: input.slug,
      synopsis: input.synopsis ?? null,
      visibility: input.visibility ?? "public",
      status: "draft"
    })
    .select("*")
    .single();

  if (error) throw error;
  return data;
}


export async function forkStory(
  client: NarrioSupabaseClient,
  input: {
    sourceStoryId: string;
    newAuthorId: string;
    title?: string;
    slug: string;
  }
) {
  const sourceStory = await getStoryById(client, input.sourceStoryId);
  const branches = await client
    .from("story_branches")
    .select("*")
    .eq("story_id", input.sourceStoryId)
    .order("created_at", { ascending: true });

  if (branches.error) throw branches.error;

  const { data: newStory, error: newStoryError } = await client
    .from("stories")
    .insert({
      author_id: input.newAuthorId,
      forked_from_story_id: input.sourceStoryId,
      title: input.title ?? `${sourceStory.title} — Fork`,
      slug: input.slug,
      synopsis: sourceStory.synopsis,
      cover_url: sourceStory.cover_url,
      visibility: "public",
      status: "draft",
      allow_forks: true
    })
    .select("*")
    .single();

  if (newStoryError) throw newStoryError;

  const insertedStory = newStory.main_branch_id ? newStory : await getStoryById(client, newStory.id);

  const sourceMainBranch = branches.data?.find((branch) => branch.id === sourceStory.main_branch_id);
  const targetMainBranchId = insertedStory.main_branch_id;
  const sourceBranchId = sourceMainBranch?.id;

  if (!sourceBranchId || !targetMainBranchId) return insertedStory;

  const { data: sourceChapters, error: sourceChaptersError } = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", sourceBranchId)
    .order("chapter_number", { ascending: true });

  if (sourceChaptersError) throw sourceChaptersError;

  for (const sourceChapter of sourceChapters ?? []) {
    const { data: newChapter, error: newChapterError } = await client
      .from("chapters")
      .insert({
        story_id: insertedStory.id,
        branch_id: targetMainBranchId,
        chapter_number: sourceChapter.chapter_number,
        title: sourceChapter.title,
        slug: sourceChapter.slug,
        summary: sourceChapter.summary,
        is_published: false,
        created_by: input.newAuthorId
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
      commit_message: "Forked from source story",
      created_by: input.newAuthorId,
      is_current: true
    });

    if (insertVersionError) throw insertVersionError;
  }

  return insertedStory;
}
