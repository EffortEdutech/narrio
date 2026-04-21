import Link from "next/link";
import { getBranchesByStoryId, getStoryById } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../../../lib/supabase/server";

export default async function StoryEditorPage(props: { params: Promise<{ storyId: string }> }) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const branches = await getBranchesByStoryId(supabase, params.storyId);

  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Editor"
        title={`Write: ${story.title}`}
        description="Choose a branch to enter the editor shell."
      />

      <SectionCard
        title="Available branches"
        description="Sprint 1 stops at the editor shell. Create/fork/commit actions come next."
      >
        <div className="narrio-list">
          {branches.map((branch) => (
            <Link
              key={branch.id}
              href={`/write/editor/${story.id}/branch/${branch.id}`}
              className="narrio-list-item"
            >
              <strong>{branch.name}</strong>
              <div className="narrio-muted">{branch.branch_type}</div>
            </Link>
          ))}
        </div>
      </SectionCard>
    </div>
  );
}
