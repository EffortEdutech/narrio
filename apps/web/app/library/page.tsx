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
        description="Published stories that readers can discover, follow, and read."
      />

      <div className="narrio-grid library">
        {stories.length ? (
          stories.map((story) => (
            <SectionCard key={story.id} title={story.title} description={story.synopsis ?? "No synopsis yet."}>
              <div className="narrio-inline-meta">
                <span>Status: {story.status}</span>
                <span>Visibility: {story.visibility}</span>
              </div>
              <div style={{ height: 14 }} />
              <div className="narrio-nav">
                <Link className="narrio-button" href={`/story/${story.id}`}>
                  Open story
                </Link>
                <Link className="narrio-button-secondary" href={`/u/${story.author_id}`}>
                  Writer profile
                </Link>
              </div>
            </SectionCard>
          ))
        ) : (
          <SectionCard title="No public stories yet" description="Publish a story from writer settings to populate the library." />
        )}
      </div>
    </Stack>
  );
}
