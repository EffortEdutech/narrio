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

export async function listStoriesByAuthor(client: NarrioSupabaseClient, authorId: string) {
  const { data, error } = await client
    .from("stories")
    .select("*")
    .eq("author_id", authorId)
    .order("updated_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}

export async function getStoryById(client: NarrioSupabaseClient, storyId: string) {
  const { data, error } = await client.from("stories").select("*").eq("id", storyId).single();
  if (error) throw error;
  return data;
}

export async function createStory(
  client: NarrioSupabaseClient,
  input: {
    authorId: string;
    title: string;
    slug: string;
    synopsis?: string;
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
      status: "draft",
      allow_forks: true
    })
    .select("*")
    .single();

  if (error) throw error;

  const refreshed = data.main_branch_id ? data : await getStoryById(client, data.id);
  return refreshed;
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

  const forkedStory = await createStory(client, {
    authorId: input.newAuthorId,
    title: input.title ?? `${sourceStory.title} — Fork`,
    slug: input.slug,
    synopsis: sourceStory.synopsis ?? undefined,
    visibility: "public"
  });

  await client
    .from("stories")
    .update({ forked_from_story_id: input.sourceStoryId })
    .eq("id", forkedStory.id);

  const sourceMainBranch = branches.data?.find((branch) => branch.id === sourceStory.main_branch_id);
  if (!sourceMainBranch || !forkedStory.main_branch_id) return forkedStory;

  const chapters = await client
    .from("chapters")
    .select("*")
    .eq("branch_id", sourceMainBranch.id)
    .order("chapter_number", { ascending: true });

  if (chapters.error) throw chapters.error;

  for (const chapter of chapters.data ?? []) {
    const { data: newChapter, error: newChapterError } = await client
      .from("chapters")
      .insert({
        story_id: forkedStory.id,
        branch_id: forkedStory.main_branch_id,
        chapter_number: chapter.chapter_number,
        title: chapter.title,
        slug: chapter.slug,
        summary: chapter.summary,
        created_by: input.newAuthorId
      })
      .select("*")
      .single();

    if (newChapterError) throw newChapterError;

    const latest = await client
      .from("chapter_versions")
      .select("*")
      .eq("chapter_id", chapter.id)
      .eq("is_current", true)
      .single();

    if (latest.error) throw latest.error;

    const insertVersion = await client.from("chapter_versions").insert({
      chapter_id: newChapter.id,
      version_number: 1,
      title: latest.data.title,
      excerpt: latest.data.excerpt,
      content_md: latest.data.content_md,
      source: latest.data.source,
      commit_message: "Forked from source story",
      created_by: input.newAuthorId,
      is_current: true
    });

    if (insertVersion.error) throw insertVersion.error;
  }

  return getStoryById(client, forkedStory.id);
}
