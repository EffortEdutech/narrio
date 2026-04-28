"use server";

import { redirect } from "next/navigation";
import { forkBranchFromChapter } from "@narrio/api";
import { createClient } from "../../lib/supabase/server";

function readRequiredString(formData: FormData, key: string) {
  const value = String(formData.get(key) ?? "").trim();

  if (!value) {
    throw new Error(`${key} is required.`);
  }

  return value;
}

function readOptionalString(formData: FormData, key: string) {
  const value = String(formData.get(key) ?? "").trim();
  return value || null;
}

function normalizeSlug(value: string) {
  return value
    .toLowerCase()
    .trim()
    .replace(/['"]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

export async function forkFromChapterAction(formData: FormData) {
  const supabase = await createClient();

  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/signin");
  }

  const storyId = readRequiredString(formData, "storyId");
  const sourceBranchId = readRequiredString(formData, "sourceBranchId");
  const sourceChapterId = readRequiredString(formData, "sourceChapterId");
  const name = readRequiredString(formData, "name");
  const rawSlug = readOptionalString(formData, "slug");
  const description = readOptionalString(formData, "description");
  const visibility = String(formData.get("visibility") ?? "private") === "public" ? "public" : "private";
  const slug = normalizeSlug(rawSlug ?? name);

  if (!slug) {
    throw new Error("A valid timeline slug is required.");
  }

  const result = await forkBranchFromChapter(supabase, {
    storyId,
    sourceBranchId,
    sourceChapterId,
    createdBy: user.id,
    name,
    slug,
    description,
    visibility
  });

  const forkPointQuery = result.forkPointChapter ? `?chapter=${result.forkPointChapter.id}` : "";

  redirect(`/write/editor/${storyId}/branch/${result.branch.id}${forkPointQuery}`);
}
