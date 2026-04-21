import Link from "next/link";
import { getBranchesByStoryId, getStoryById } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";

export default async function StoryPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, storyId);
  const branches = await getBranchesByStoryId(supabase, storyId);

  return (
    <Stack>
      <PageHeader
        eyebrow="Story"
        title={story.title}
        description={story.synopsis ?? "No synopsis yet."}
        actions={
          <Link className="narrio-button" href={`/write/editor/${story.id}`}>
            Open Writer View
          </Link>
        }
      />

      <SectionCard title="Story metadata" description="Public-facing story information.">
        <InlineMeta>
          <span>Status: {story.status}</span>
          <span>Visibility: {story.visibility}</span>
          <span>Forked from: {story.forked_from_story_id ?? "Original story"}</span>
        </InlineMeta>
      </SectionCard>

      <SectionCard title="Branch explorer" description="Readable branch explorer for public navigation.">
        <div className="narrio-list">
          {branches.map((branch) => (
            <Link
              key={branch.id}
              href={`/story/${story.id}/branch/${branch.id}`}
              className="narrio-list-item"
            >
              <strong>{branch.name}</strong>
              <div className="narrio-muted">{branch.description ?? "No description yet."}</div>
            </Link>
          ))}
        </div>
      </SectionCard>
    </Stack>
  );
}
