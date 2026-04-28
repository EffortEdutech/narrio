import Link from "next/link";
import { getBranchById, getChaptersByBranchId, getStoryById } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";

export default async function StoryBranchPage(props: {
  params: Promise<{ storyId: string; branchId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const branch = await getBranchById(supabase, params.branchId);
  const chapters = await getChaptersByBranchId(supabase, params.branchId);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const canEditTimeline = user?.id === story.author_id || user?.id === branch.created_by;
  const canForkTimeline = Boolean(story.allow_forks) || canEditTimeline;

  return (
    <Stack>
      <PageHeader
        eyebrow="Timeline"
        title={`${story.title} — ${branch.name}`}
        description={branch.description ?? "A readable path through this story."}
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href={`/story/${story.id}/timelines`}>
              Explore timelines
            </Link>
            {canEditTimeline ? (
              <Link className="narrio-button" href={`/write/editor/${story.id}/branch/${branch.id}`}>
                Open in Story Studio
              </Link>
            ) : null}
          </div>
        }
      />

      <SectionCard title="Timeline details" description="ForkCraft information for this story path.">
        <InlineMeta>
          <span>{branch.branch_type === "main" ? "Root timeline" : `Fork type: ${branch.branch_type}`}</span>
          <span>Status: {branch.status}</span>
          <span>Visibility: {branch.visibility}</span>
          <span>Parent: {branch.parent_branch_id ?? "None"}</span>
        </InlineMeta>
      </SectionCard>

      <SectionCard
        title="Timeline chapters"
        description="Choose a chapter to read, or fork from the exact chapter where your alternate path begins."
      >
        <div className="narrio-list">
          {chapters.length ? (
            chapters.map((chapter) => (
              <div key={chapter.id} className="narrio-list-item narrio-split-list-item">
                <Link href={`/story/${story.id}/chapter/${chapter.id}`} className="narrio-list-main">
                  <strong>
                    Chapter {chapter.chapter_number}: {chapter.title}
                  </strong>
                  <div className="narrio-muted">{chapter.summary ?? "No summary yet."}</div>
                  <InlineMeta>
                    <span>{chapter.is_published ? "Published" : "Draft"}</span>
                    <span>Updated {new Date(chapter.updated_at).toLocaleDateString()}</span>
                  </InlineMeta>
                </Link>

                <div className="narrio-mini-actions">
                  <Link className="narrio-button-secondary" href={`/story/${story.id}/chapter/${chapter.id}`}>
                    Read
                  </Link>
                  {canForkTimeline ? (
                    <Link className="narrio-button" href={`/story/${story.id}/chapter/${chapter.id}/fork`}>
                      Fork here
                    </Link>
                  ) : null}
                </div>
              </div>
            ))
          ) : (
            <div className="narrio-list-item">No chapters in this timeline yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
