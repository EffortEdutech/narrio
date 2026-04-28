"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import {
  createBranch,
  createChapter,
  createChapterVersion,
  createStory,
  restoreChapterVersion,
  setChapterPublicationState,
  setStoryPublicationStatus,
  updateBranchPublicationSettings,
  updateStoryPublicationSettings
} from "@narrio/api";
import { requireUser } from "../../lib/auth";

type Visibility = "public" | "unlisted" | "private";

function readVisibility(value: FormDataEntryValue | null): Visibility {
  if (value === "public" || value === "unlisted" || value === "private") return value;
  return "private";
}

function revalidatePublishingPaths(storyId: string) {
  revalidatePath("/write");
  revalidatePath(`/write/publish/${storyId}`);
  revalidatePath(`/story/${storyId}`);
  revalidatePath(`/story/${storyId}/timelines`);
}

export async function createStoryAction(formData: FormData) {
  const title = String(formData.get("title") ?? "").trim();
  const slug = String(formData.get("slug") ?? "").trim();
  const synopsis = String(formData.get("synopsis") ?? "").trim();

  const { supabase, user } = await requireUser();

  const story = await createStory(supabase, {
    authorId: user.id,
    title,
    slug,
    synopsis: synopsis || undefined,
    visibility: "public"
  });

  revalidatePath("/write");
  redirect(`/write/editor/${story.id}/branch/${story.main_branch_id}`);
}

export async function createChapterAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const title = String(formData.get("title") ?? "").trim();
  const summary = String(formData.get("summary") ?? "").trim();

  const { supabase, user } = await requireUser();

  const chapter = await createChapter(supabase, {
    storyId,
    branchId,
    createdBy: user.id,
    title,
    summary: summary || undefined
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  revalidatePath(`/write/publish/${storyId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapter.id}`);
}

export async function saveChapterVersionAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));
  const title = String(formData.get("title") ?? "").trim();
  const summary = String(formData.get("summary") ?? "").trim();
  const contentMd = String(formData.get("contentMd") ?? "");
  const commitMessage = String(formData.get("commitMessage") ?? "").trim();

  const { supabase, user } = await requireUser();

  await createChapterVersion(supabase, {
    chapterId,
    createdBy: user.id,
    title,
    summary: summary || undefined,
    contentMd,
    commitMessage: commitMessage || undefined,
    source: "human"
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  revalidatePath(`/write/publish/${storyId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}

export async function restoreVersionAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));
  const versionId = String(formData.get("versionId"));

  const { supabase, user } = await requireUser();

  await restoreChapterVersion(supabase, {
    chapterId,
    versionId,
    restoredBy: user.id
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  revalidatePath(`/write/publish/${storyId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}

export async function createBranchAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const sourceBranchId = String(formData.get("sourceBranchId"));
  const name = String(formData.get("name") ?? "").trim();
  const slug = String(formData.get("slug") ?? "").trim();
  const description = String(formData.get("description") ?? "").trim();

  const { supabase, user } = await requireUser();

  const branch = await createBranch(supabase, {
    storyId,
    sourceBranchId,
    createdBy: user.id,
    name,
    slug,
    description: description || undefined
  });

  revalidatePath(`/write/editor/${storyId}/branch/${sourceBranchId}`);
  revalidatePath(`/write/publish/${storyId}`);
  redirect(`/write/editor/${storyId}/branch/${branch.id}`);
}

export async function setStoryPublishStatusAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const status = formData.get("status") === "published" ? "published" : "draft";

  const { supabase } = await requireUser();
  await setStoryPublicationStatus(supabase, { storyId, status });

  revalidatePublishingPaths(storyId);
  redirect(`/write/publish/${storyId}`);
}

export async function updateStoryPublishingSettingsAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const visibility = readVisibility(formData.get("visibility"));
  const allowForks = formData.get("allowForks") === "on";

  const { supabase } = await requireUser();
  await updateStoryPublicationSettings(supabase, {
    storyId,
    visibility,
    allowForks
  });

  revalidatePublishingPaths(storyId);
  redirect(`/write/publish/${storyId}`);
}

export async function updateTimelineVisibilityAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const visibility = readVisibility(formData.get("visibility"));
  const description = String(formData.get("description") ?? "").trim();

  const { supabase } = await requireUser();
  await updateBranchPublicationSettings(supabase, {
    branchId,
    visibility,
    description: description || undefined
  });

  revalidatePublishingPaths(storyId);
  revalidatePath(`/story/${storyId}/branch/${branchId}`);
  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/publish/${storyId}`);
}

export async function toggleChapterPublicationAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));
  const isPublished = formData.get("isPublished") === "true";

  const { supabase } = await requireUser();
  await setChapterPublicationState(supabase, {
    chapterId,
    isPublished
  });

  revalidatePublishingPaths(storyId);
  revalidatePath(`/story/${storyId}/branch/${branchId}`);
  revalidatePath(`/story/${storyId}/chapter/${chapterId}`);
  redirect(`/write/publish/${storyId}`);
}
