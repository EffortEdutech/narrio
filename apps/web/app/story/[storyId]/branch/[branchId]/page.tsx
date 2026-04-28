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
            {user?.id === story.author_id ? (
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

      <SectionCard title="Timeline chapters" description="Choose a chapter and continue reading this path.">
        <div className="narrio-list">
          {chapters.length ? (
            chapters.map((chapter) => (
              <Link
                key={chapter.id}
                href={`/story/${story.id}/chapter/${chapter.id}`}
                className="narrio-list-item"
              >
                <strong>
                  Chapter {chapter.chapter_number}: {chapter.title}
                </strong>
                <div className="narrio-muted">{chapter.summary ?? "No summary yet."}</div>
                <InlineMeta>
                  <span>{chapter.is_published ? "Published" : "Draft"}</span>
                  <span>Updated {new Date(chapter.updated_at).toLocaleDateString()}</span>
                </InlineMeta>
              </Link>
            ))
          ) : (
            <div className="narrio-list-item">No chapters in this timeline yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
