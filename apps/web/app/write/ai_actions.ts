"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import {
  createChapterVersion,
  getChapterById,
  getCurrentVersionByChapterId
} from "@narrio/api";
import {
  aiContinueChapter,
  aiRewriteChapter,
  aiSuggestChapterTitle,
  aiSummarizeChapter
} from "@narrio/ai";
import { requireUser } from "../../lib/auth";

function cleanSingleLine(text: string) {
  return text.replace(/^["'`]+|["'`]+$/g, "").replace(/\s+/g, " ").trim();
}

export async function aiContinueChapterAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));

  const { supabase, user } = await requireUser();
  const chapter = await getChapterById(supabase, chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, chapterId);

  const continuation = await aiContinueChapter(currentVersion.content_md);
  const nextContent = `${currentVersion.content_md}\n\n${continuation}`.trim();

  await createChapterVersion(supabase, {
    chapterId,
    createdBy: user.id,
    title: chapter.title,
    summary: chapter.summary ?? undefined,
    contentMd: nextContent,
    commitMessage: "AI continue chapter",
    source: "ai"
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}

export async function aiRewriteChapterAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));

  const { supabase, user } = await requireUser();
  const chapter = await getChapterById(supabase, chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, chapterId);

  const rewritten = await aiRewriteChapter(currentVersion.content_md);

  await createChapterVersion(supabase, {
    chapterId,
    createdBy: user.id,
    title: chapter.title,
    summary: chapter.summary ?? undefined,
    contentMd: rewritten,
    commitMessage: "AI rewrite chapter",
    source: "ai"
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}

export async function aiSummarizeChapterAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));

  const { supabase, user } = await requireUser();
  const chapter = await getChapterById(supabase, chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, chapterId);

  const summary = cleanSingleLine(await aiSummarizeChapter(currentVersion.content_md));

  await createChapterVersion(supabase, {
    chapterId,
    createdBy: user.id,
    title: chapter.title,
    summary,
    contentMd: currentVersion.content_md,
    commitMessage: "AI summarize chapter",
    source: "ai"
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}

export async function aiSuggestChapterTitleAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const branchId = String(formData.get("branchId"));
  const chapterId = String(formData.get("chapterId"));

  const { supabase, user } = await requireUser();
  const chapter = await getChapterById(supabase, chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, chapterId);

  const title = cleanSingleLine(await aiSuggestChapterTitle(currentVersion.content_md));

  await createChapterVersion(supabase, {
    chapterId,
    createdBy: user.id,
    title,
    summary: chapter.summary ?? undefined,
    contentMd: currentVersion.content_md,
    commitMessage: "AI suggest chapter title",
    source: "ai"
  });

  revalidatePath(`/write/editor/${storyId}/branch/${branchId}`);
  redirect(`/write/editor/${storyId}/branch/${branchId}?chapter=${chapterId}`);
}
