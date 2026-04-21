import Link from "next/link";
import { getBranchById, getChaptersByBranchId, getStoryById } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";

export default async function StoryBranchPage(props: {
  params: Promise<{ storyId: string; branchId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const branch = await getBranchById(supabase, params.branchId);
  const chapters = await getChaptersByBranchId(supabase, params.branchId);

  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Branch"
        title={`${story.title} — ${branch.name}`}
        description={branch.description ?? "Branch reader view."}
        actions={
          <Link className="narrio-button" href={`/write/editor/${story.id}/branch/${branch.id}`}>
            Open Branch Editor
          </Link>
        }
      />

      <SectionCard
        title="Chapter list"
        description="Published and draft visibility is controlled by RLS."
      >
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
                <div className="narrio-muted">
                  {chapter.summary ?? "No summary yet."}
                </div>
              </Link>
            ))
          ) : (
            <div className="narrio-list-item">No chapters in this branch yet.</div>
          )}
        </div>
      </SectionCard>
    </div>
  );
}
