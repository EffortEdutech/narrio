import Link from "next/link";
import { listPublishedStoriesByAuthor } from "@narrio/api";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";

export default async function PublicProfilePage(props: {
  params: Promise<{ userId: string }>;
}) {
  const { userId } = await props.params;
  const supabase = await createClient();

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", userId)
    .maybeSingle();

  const stories = await listPublishedStoriesByAuthor(supabase, userId);

  return (
    <Stack>
      <PageHeader
        eyebrow="Writer"
        title={profile?.display_name ?? "Narrio Writer"}
        description={profile?.bio ?? "Public writer profile"}
      />

      <SectionCard title="Published stories" description="Visible public stories by this writer.">
        <div className="narrio-list">
          {stories.length ? (
            stories.map((story) => (
              <Link key={story.id} className="narrio-list-item" href={`/story/${story.id}`}>
                <strong>{story.title}</strong>
                <div className="narrio-muted">{story.synopsis ?? "No synopsis yet."}</div>
              </Link>
            ))
          ) : (
            <div className="narrio-list-item">No published stories yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
