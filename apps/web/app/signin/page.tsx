import { redirect } from "next/navigation";
import { PageHeader, PrimaryButton, SectionCard, Field, Stack } from "@narrio/ui";
import { createClient } from "../../lib/supabase/server";
import { signInAction } from "../auth/actions";

export default async function SignInPage(props: {
  searchParams?: Promise<{ error?: string }>;
}) {
  const searchParams = (await props.searchParams) ?? {};
  const supabase = await createClient();
  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (user) {
    redirect("/write");
  }

  return (
    <Stack>
      <PageHeader
        eyebrow="Auth"
        title="Sign in to Narrio"
        description="Use an existing Supabase Auth user for Sprint 2."
      />

      <SectionCard title="Email sign-in" description="Simple password sign-in for the writer dashboard.">
        <form action={signInAction} className="narrio-form">
          <Field label="Email" name="email" type="email" placeholder="writer@example.com" />
          <Field label="Password" name="password" type="password" placeholder="••••••••" />
          <PrimaryButton>Sign in</PrimaryButton>
          {searchParams.error ? <div className="narrio-muted">Error: {searchParams.error}</div> : null}
        </form>
      </SectionCard>
    </Stack>
  );
}
