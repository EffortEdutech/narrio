import Link from "next/link";
import { listStoriesByAuthor } from "@narrio/api";
import { BRAND } from "@narrio/config";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { requireUser } from "../../lib/auth";

export default async function WriteDashboardPage() {
  const { supabase, user } = await requireUser();
  const stories = await listStoriesByAuthor(supabase, user.id);

  return (
    <Stack>
      <PageHeader
        eyebrow={BRAND.engine}
        title={BRAND.writerStudioTitle}
        description={BRAND.writerStudioDescription}
        actions={
          <Link className="narrio-button" href="/write/new">
            Start a story
          </Link>
        }
      />

      <SectionCard title="Draft timelines" description="Each story starts with a main timeline and can grow through ForkCraft.">
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
              No stories yet. Start your first story and create a world that can branch.
            </div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
