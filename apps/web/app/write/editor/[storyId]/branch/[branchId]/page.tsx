import Link from "next/link";
import { getBranchById, getChaptersByBranchId, getStoryById } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../../../../../lib/supabase/server";

export default async function BranchEditorPage(props: {
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
        eyebrow="Branch Editor"
        title={`${story.title} — ${branch.name}`}
        description="Shell for commit-based writing. Mutation forms are intentionally the next sprint."
      />

      <div className="narrio-grid narrio-grid-2">
        <SectionCard
          title="Draft area"
          description="This textarea is the placeholder for commit-based chapter editing."
        >
          <textarea
            className="narrio-editor"
            defaultValue={`# Draft for ${branch.name}

Start writing here. In Sprint 2 this becomes a real create/commit flow backed by chapter_versions.`}
          />
        </SectionCard>

        <SectionCard
          title="Chapter register"
          description="Existing chapters in this branch."
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
                    {chapter.is_published ? "Published" : "Draft"}
                  </div>
                </Link>
              ))
            ) : (
              <div className="narrio-list-item">No chapters in this branch yet.</div>
            )}
          </div>
        </SectionCard>
      </div>
    </div>
  );
}
