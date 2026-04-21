import Link from "next/link";
import { listPublishedStories } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../lib/supabase/server";

export default async function LibraryPage() {
  const supabase = await createClient();
  const stories = await listPublishedStories(supabase);

  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Library"
        title="Published stories"
        description="This reads from the Sprint 1 stories table through the shared API package."
      />

      <SectionCard
        title="Story feed"
        description={stories.length ? "Public published stories from Supabase." : "Run the seed after creating a local auth user to see demo content."}
      >
        <div className="narrio-list">
          {stories.length ? (
            stories.map((story) => (
              <Link key={story.id} href={`/story/${story.id}`} className="narrio-list-item">
                <strong>{story.title}</strong>
                <div className="narrio-muted">{story.synopsis ?? "No synopsis yet."}</div>
              </Link>
            ))
          ) : (
            <div className="narrio-list-item">No stories found.</div>
          )}
        </div>
      </SectionCard>
    </div>
  );
}
