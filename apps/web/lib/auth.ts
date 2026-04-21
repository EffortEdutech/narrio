import { redirect } from "next/navigation";
import { createClient } from "./supabase/server";

export async function requireUser() {
  const supabase = await createClient();
  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/signin");
  }

  await ensureProfileRow(user);
  return { supabase, user };
}

export async function ensureProfileRow(user: {
  id: string;
  email?: string | null;
  user_metadata?: Record<string, unknown>;
}) {
  const supabase = await createClient();
  const displayName =
    typeof user.user_metadata?.display_name === "string"
      ? user.user_metadata.display_name
      : user.email ?? "Narrio Writer";

  const username =
    typeof user.user_metadata?.username === "string" ? user.user_metadata.username : null;

  await supabase.from("profiles").upsert({
    id: user.id,
    display_name: displayName,
    username
  });
}
