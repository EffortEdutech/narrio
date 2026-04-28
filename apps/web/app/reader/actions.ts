"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { toggleBookmarkChapter, toggleFollowStory, toggleLikeVersion } from "@narrio/api";
import { requireUser } from "../../lib/auth";

export async function toggleFollowAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const redirectPath = String(formData.get("redirectPath") ?? `/story/${storyId}`);

  const { supabase, user } = await requireUser();
  await toggleFollowStory(supabase, { userId: user.id, storyId });

  revalidatePath("/library");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function toggleBookmarkAction(formData: FormData) {
  const chapterId = String(formData.get("chapterId"));
  const tag = String(formData.get("tag") ?? "favorite");
  const redirectPath = String(formData.get("redirectPath") ?? "/write/bookmarks");

  const { supabase, user } = await requireUser();
  await toggleBookmarkChapter(supabase, { userId: user.id, chapterId, tag });

  revalidatePath("/write/bookmarks");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function toggleLikeAction(formData: FormData) {
  const chapterVersionId = String(formData.get("chapterVersionId"));
  const redirectPath = String(formData.get("redirectPath") ?? "/library");

  const { supabase, user } = await requireUser();
  await toggleLikeVersion(supabase, { userId: user.id, chapterVersionId });

  revalidatePath(redirectPath);
  redirect(redirectPath);
}
