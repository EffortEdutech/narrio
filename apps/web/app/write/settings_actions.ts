"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { setChapterPublished, updateBranchVisibility, updateStorySettings } from "@narrio/api";
import { requireUser } from "../../lib/auth";

export async function saveStorySettingsAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const title = String(formData.get("title") ?? "").trim();
  const slug = String(formData.get("slug") ?? "").trim();
  const synopsis = String(formData.get("synopsis") ?? "").trim();
  const coverUrl = String(formData.get("coverUrl") ?? "").trim();
  const status = String(formData.get("status") ?? "draft") as "draft" | "published" | "archived";
  const visibility = String(formData.get("visibility") ?? "public") as "public" | "unlisted" | "private";
  const allowForks = String(formData.get("allowForks") ?? "true") === "true";

  const { supabase } = await requireUser();

  await updateStorySettings(supabase, {
    storyId,
    title,
    slug,
    synopsis: synopsis || undefined,
    coverUrl: coverUrl || undefined,
    allowForks,
    status,
    visibility
  });

  revalidatePath("/library");
  revalidatePath(`/story/${storyId}`);
  revalidatePath(`/write/settings/${storyId}`);
  revalidatePath("/write");
  redirect(`/write/settings/${storyId}`);
}

export async function updateBranchVisibilityAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const visibility = String(formData.get("visibility") ?? "public") as "public" | "unlisted" | "private";
  const description = String(formData.get("description") ?? "").trim();

  const { supabase } = await requireUser();

  await updateBranchVisibility(supabase, {
    branchId,
    visibility,
    description: description || undefined
  });

  revalidatePath(`/story/${storyId}`);
  revalidatePath(`/write/settings/${storyId}`);
  redirect(`/write/settings/${storyId}`);
}

export async function toggleChapterPublishAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));
  const nextPublishedState = String(formData.get("nextPublishedState") ?? "true") === "true";

  const { supabase } = await requireUser();

  await setChapterPublished(supabase, {
    chapterId,
    isPublished: nextPublishedState
  });

  revalidatePath(`/story/${storyId}/branch/${branchId}`);
  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}
