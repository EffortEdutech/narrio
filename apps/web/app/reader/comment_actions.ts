"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createComment } from "@narrio/api";
import { requireUser } from "../../lib/auth";

export async function createCommentAction(formData: FormData) {
  const storyId = String(formData.get("storyId"));
  const chapterId = String(formData.get("chapterId"));
  const body = String(formData.get("body") ?? "").trim();
  const isSpoiler = String(formData.get("isSpoiler") ?? "false") === "true";

  if (!body) {
    redirect(`/story/${storyId}/chapter/${chapterId}`);
  }

  const { supabase, user } = await requireUser();

  await createComment(supabase, {
    storyId,
    chapterId,
    userId: user.id,
    body,
    isSpoiler
  });

  revalidatePath(`/story/${storyId}/chapter/${chapterId}`);
  redirect(`/story/${storyId}/chapter/${chapterId}`);
}
