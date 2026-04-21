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
        eyebrow="Sprint 2"
        title="My stories"
        description="Create and manage your branching story projects."
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
              <Link
                key={story.id}
                className="narrio-list-item"
                href={`/write/editor/${story.id}/branch/${story.main_branch_id}`}
              >
                <strong>{story.title}</strong>
                <div className="narrio-muted">{story.synopsis ?? "No synopsis yet."}</div>
              </Link>
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
