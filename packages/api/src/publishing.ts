import type { NarrioSupabaseClient } from "@narrio/db";

type StoryVisibility = "public" | "unlisted" | "private";
type StoryStatus = "draft" | "published" | "archived";

export async function updateStorySettings(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    title: string;
    slug: string;
    synopsis?: string;
    coverUrl?: string;
    allowForks: boolean;
    status: StoryStatus;
    visibility: StoryVisibility;
  }
) {
  const { data, error } = await client
    .from("stories")
    .update({
      title: input.title,
      slug: input.slug,
      synopsis: input.synopsis ?? null,
      cover_url: input.coverUrl ?? null,
      allow_forks: input.allowForks,
      status: input.status,
      visibility: input.visibility
    })
    .eq("id", input.storyId)
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function setStoryPublicationStatus(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    status: Extract<StoryStatus, "draft" | "published">;
  }
) {
  const { data, error } = await client
    .from("stories")
    .update({ status: input.status })
    .eq("id", input.storyId)
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function updateStoryPublicationSettings(
  client: NarrioSupabaseClient,
  input: {
    storyId: string;
    visibility: StoryVisibility;
    allowForks: boolean;
  }
) {
  const { data, error } = await client
    .from("stories")
    .update({
      visibility: input.visibility,
      allow_forks: input.allowForks
    })
    .eq("id", input.storyId)
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function updateBranchVisibility(
  client: NarrioSupabaseClient,
  input: {
    branchId: string;
    visibility: StoryVisibility;
    description?: string;
  }
) {
  const { data, error } = await client
    .from("story_branches")
    .update({
      visibility: input.visibility,
      description: input.description ?? null
    })
    .eq("id", input.branchId)
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function updateBranchPublicationSettings(
  client: NarrioSupabaseClient,
  input: {
    branchId: string;
    visibility: StoryVisibility;
    description?: string;
  }
) {
  return updateBranchVisibility(client, input);
}

export async function setChapterPublicationState(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    isPublished: boolean;
  }
) {
  const { data, error } = await client
    .from("chapters")
    .update({
      is_published: input.isPublished,
      published_at: input.isPublished ? new Date().toISOString() : null
    })
    .eq("id", input.chapterId)
    .select("*")
    .single();

  if (error) throw error;
  return data;
}

export async function setChapterPublished(
  client: NarrioSupabaseClient,
  input: {
    chapterId: string;
    isPublished: boolean;
  }
) {
  return setChapterPublicationState(client, input);
}

export async function listPublishedStoriesByAuthor(client: NarrioSupabaseClient, authorId: string) {
  const { data, error } = await client
    .from("stories")
    .select("*")
    .eq("author_id", authorId)
    .eq("status", "published")
    .eq("visibility", "public")
    .order("updated_at", { ascending: false });

  if (error) throw error;
  return data ?? [];
}
