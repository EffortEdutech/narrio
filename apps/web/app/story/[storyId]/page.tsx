import Link from "next/link";
import { getBranchesByStoryId, getStoryById } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";

export default async function StoryPage(props: { params: Promise<{ storyId: string }> }) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const branches = await getBranchesByStoryId(supabase, params.storyId);

  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Story"
        title={story.title}
        description={story.synopsis ?? "No synopsis yet."}
        actions={
          <Link className="narrio-button" href={`/write/editor/${story.id}`}>
            Open Editor
          </Link>
        }
      />

      <div className="narrio-grid narrio-grid-2">
        <SectionCard
          title="Story metadata"
          description="This is the story record that anchors all branches and chapters."
        >
          <div className="narrio-kv">
            <div>Status: {story.status}</div>
            <div>Visibility: {story.visibility}</div>
            <div>Forks enabled: {story.allow_forks ? "Yes" : "No"}</div>
            <div>Forked from: {story.forked_from_story_id ?? "Original story"}</div>
            <div>Main branch id: {story.main_branch_id ?? "Not set"}</div>
          </div>
        </SectionCard>

        <SectionCard
          title="Branch explorer"
          description="Readable branch explorer for public navigation."
        >
          <div className="narrio-list">
            {branches.map((branch) => (
              <Link
                key={branch.id}
                href={`/story/${story.id}/branch/${branch.id}`}
                className="narrio-list-item"
              >
                <strong>{branch.name}</strong>
                <div className="narrio-muted">
                  {branch.branch_type} · {branch.visibility}
                </div>
              </Link>
            ))}
          </div>
        </SectionCard>
      </div>
    </div>
  );
}
