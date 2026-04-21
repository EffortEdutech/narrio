import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "@narrio/db";

export function createClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const publishableKey =
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ??
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !publishableKey) {
    throw new Error(
      "Missing NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY (or fallback NEXT_PUBLIC_SUPABASE_ANON_KEY)."
    );
  }

  return createBrowserClient<Database>(url, publishableKey);
}
