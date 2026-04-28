import Link from "next/link";
import { getBranchesByStoryId, getStoryById, isFollowingStory } from "@narrio/api";
import { InlineMeta, PageHeader, PrimaryButton, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";
import { toggleFollowAction } from "../../reader/actions";

export default async function StoryPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, storyId);
  const branches = await getBranchesByStoryId(supabase, storyId);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const following = user ? await isFollowingStory(supabase, { userId: user.id, storyId }) : false;

  return (
    <Stack>
      <PageHeader
        eyebrow="Story"
        title={story.title}
        description={story.synopsis ?? "No synopsis yet."}
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href={`/u/${story.author_id}`}>
              View writer profile
            </Link>
            {user ? (
              <form action={toggleFollowAction}>
                <input type="hidden" name="storyId" value={story.id} />
                <input type="hidden" name="redirectPath" value={`/story/${story.id}`} />
                <PrimaryButton>{following ? "Unfollow story" : "Follow story"}</PrimaryButton>
              </form>
            ) : (
              <Link className="narrio-button" href="/signin">
                Sign in to follow
              </Link>
            )}
          </div>
        }
      />

      <SectionCard title="Story metadata" description="Public-facing story information.">
        <InlineMeta>
          <span>Status: {story.status}</span>
          <span>Visibility: {story.visibility}</span>
          <span>Forks: {story.allow_forks ? "allowed" : "disabled"}</span>
          <span>Forked from: {story.forked_from_story_id ?? "Original story"}</span>
        </InlineMeta>
      </SectionCard>

      <SectionCard title="Branch explorer" description="Readable branch explorer for public navigation.">
        <div className="narrio-list">
          {branches
            .filter((branch) => branch.visibility === "public" || user?.id === story.author_id)
            .map((branch) => (
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
