"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createBranch, createChapter, createChapterVersion, createStory, restoreChapterVersion } from "@narrio/api";
import { requireUser } from "../../lib/auth";

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
  redirect(`/write/editor/${storyId}/branch/${branch.id}`);
}
