import Link from "next/link";
import { listPublishedStories } from "@narrio/api";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../lib/supabase/server";

export default async function LibraryPage() {
  const supabase = await createClient();
  const stories = await listPublishedStories(supabase);

  return (
    <Stack>
      <PageHeader
        eyebrow="Library"
        title="Public stories"
        description="Published stories are visible here through RLS."
      />

      <div className="narrio-grid library">
        {stories.length ? (
          stories.map((story) => (
            <SectionCard key={story.id} title={story.title} description={story.synopsis ?? "No synopsis yet."}>
              <div className="narrio-inline-meta">
                <span>Status: {story.status}</span>
                <span>Visibility: {story.visibility}</span>
              </div>
              <div style={{ marginTop: 14 }}>
                <Link className="narrio-button" href={`/story/${story.id}`}>
                  Open story
                </Link>
              </div>
            </SectionCard>
          ))
        ) : (
          <SectionCard title="No public stories yet" description="Seed data or publish a story to populate the library." />
        )}
      </div>
    </Stack>
  );
}
