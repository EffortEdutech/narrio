import Link from "next/link";
import { listStoriesByAuthor } from "@narrio/api";
import { BRAND } from "@narrio/config";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
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
          <div className="narrio-nav">
            <Link className="narrio-button" href="/write/new">
              Start a universe
            </Link>
            <Link className="narrio-button-secondary" href="/onboarding">
              First 60 seconds
            </Link>
          </div>
        }
      />

      <SectionCard
        title="First-run checklist"
        description="A quick way to confirm the full Narrio loop is working in your account."
      >
        <div className="narrio-onboarding-mini">
          <span>Read a chapter</span>
          <span>Save a waypoint</span>
          <span>Fork a timeline</span>
          <span>Write your path</span>
          <span>Control release</span>
        </div>
        <div style={{ height: 12 }} />
        <Link className="narrio-button-secondary" href="/onboarding">
          Open guide
        </Link>
      </SectionCard>

      <SectionCard title="Draft timelines" description="Each universe starts with a main timeline and can grow through Forkcraft.">
        <div className="narrio-list">
          {stories.length ? (
            stories.map((story) => {
              const editorHref = story.main_branch_id
                ? `/write/editor/${story.id}/branch/${story.main_branch_id}`
                : `/write/publish/${story.id}`;

              return (
                <div key={story.id} className="narrio-list-item narrio-split-list-item">
                  <div className="narrio-list-main">
                    <strong>{story.title}</strong>
                    <div className="narrio-muted">{story.synopsis ?? "No synopsis yet."}</div>
                    <InlineMeta>
                      <span>{story.status}</span>
                      <span>{story.visibility}</span>
                      <span>{story.allow_forks ? "Forkcraft open" : "Forkcraft closed"}</span>
                    </InlineMeta>
                  </div>
                  <div className="narrio-mini-actions">
                    <Link className="narrio-button-secondary" href={editorHref}>
                      Studio
                    </Link>
                    <Link className="narrio-button" href={`/write/publish/${story.id}`}>
                      Release Center
                    </Link>
                  </div>
                </div>
              );
            })
          ) : (
            <div className="narrio-list-item">
              No universes yet. Start your first universe and create a world that can branch.
            </div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
