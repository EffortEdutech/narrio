"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import {
  deleteBookmarkById,
  saveBookmarkChapter,
  toggleBookmarkChapter,
  toggleFollowStory,
  toggleLikeVersion
} from "@narrio/api";
import { requireUser } from "../../lib/auth";

function formString(formData: FormData, name: string, fallback = "") {
  const value = formData.get(name);
  return typeof value === "string" && value.trim() ? value.trim() : fallback;
}

function formBoolean(formData: FormData, name: string) {
  const value = formData.get(name);
  return value === "on" || value === "true" || value === "1";
}

export async function toggleFollowAction(formData: FormData) {
  const storyId = formString(formData, "storyId");
  const redirectPath = formString(formData, "redirectPath", `/story/${storyId}`);

  const { supabase, user } = await requireUser();
  await toggleFollowStory(supabase, { userId: user.id, storyId });

  revalidatePath("/library");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function toggleBookmarkAction(formData: FormData) {
  const chapterId = formString(formData, "chapterId");
  const tag = formString(formData, "tag", "favorite");
  const redirectPath = formString(formData, "redirectPath", "/write/bookmarks");

  const { supabase, user } = await requireUser();
  await toggleBookmarkChapter(supabase, {
    userId: user.id,
    chapterId,
    tag,
    isPublic: formBoolean(formData, "isPublic")
  });

  revalidatePath("/write/bookmarks");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function saveBookmarkAction(formData: FormData) {
  const chapterId = formString(formData, "chapterId");
  const tag = formString(formData, "tag", "favorite");
  const redirectPath = formString(formData, "redirectPath", "/write/bookmarks");

  const { supabase, user } = await requireUser();
  await saveBookmarkChapter(supabase, {
    userId: user.id,
    chapterId,
    tag,
    isPublic: formBoolean(formData, "isPublic")
  });

  revalidatePath("/write/bookmarks");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function deleteBookmarkAction(formData: FormData) {
  const bookmarkId = formString(formData, "bookmarkId");
  const redirectPath = formString(formData, "redirectPath", "/write/bookmarks");

  const { supabase, user } = await requireUser();
  await deleteBookmarkById(supabase, { userId: user.id, bookmarkId });

  revalidatePath("/write/bookmarks");
  revalidatePath(redirectPath);
  redirect(redirectPath);
}

export async function toggleLikeAction(formData: FormData) {
  const chapterVersionId = formString(formData, "chapterVersionId");
  const redirectPath = formString(formData, "redirectPath", "/library");

  const { supabase, user } = await requireUser();
  await toggleLikeVersion(supabase, { userId: user.id, chapterVersionId });

  revalidatePath(redirectPath);
  redirect(redirectPath);
}
