import Link from "next/link";
import { listStoriesByAuthor } from "@narrio/api";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { requireUser } from "../../lib/auth";

export default async function WriteDashboardPage() {
  const { supabase, user } = await requireUser();
  const stories = await listStoriesByAuthor(supabase, user.id);

  return (
    <Stack>
      <PageHeader
        eyebrow="Sprint 3"
        title="My stories"
        description="Write, publish, and manage story visibility from one dashboard."
        actions={
          <Link className="narrio-button" href="/write/new">
            Create story
          </Link>
        }
      />

      <SectionCard title="Your draft space" description="Each story automatically gets a main branch.">
        <div className="narrio-list">
          {stories.length ? (
            stories.map((story) => (
              <div key={story.id} className="narrio-list-item">
                <strong>{story.title}</strong>
                <div className="narrio-muted">{story.synopsis ?? "No synopsis yet."}</div>
                <div style={{ height: 10 }} />
                <div className="narrio-nav">
                  <Link href={`/write/editor/${story.id}/branch/${story.main_branch_id}`}>Open editor</Link>
                  <Link href={`/write/settings/${story.id}`}>Settings</Link>
                  <Link href={`/story/${story.id}`}>Public view</Link>
                </div>
              </div>
            ))
          ) : (
            <div className="narrio-list-item">
              No stories yet. Create your first story to start the writer workflow.
            </div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
