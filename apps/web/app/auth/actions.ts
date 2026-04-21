"use server";

import { redirect } from "next/navigation";
import { createClient } from "../../lib/supabase/server";
import { ensureProfileRow } from "../../lib/auth";

export async function signInAction(formData: FormData) {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  const supabase = await createClient();
  const { error, data } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    redirect(`/signin?error=${encodeURIComponent(error.message)}`);
  }

  if (data.user) {
    await ensureProfileRow(data.user);
  }

  redirect("/write");
}

export async function signOutAction() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  redirect("/");
}
