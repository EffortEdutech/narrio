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
  const visibleBranches = branches.filter((branch) => branch.visibility === "public" || user?.id === story.author_id);

  return (
    <Stack>
      <PageHeader
        eyebrow="Story"
        title={story.title}
        description={story.synopsis ?? "No synopsis yet."}
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button" href={`/story/${story.id}/timelines`}>
              Explore timelines
            </Link>
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
          <span>ForkCraft: {story.allow_forks ? "enabled" : "disabled"}</span>
          <span>Origin: {story.forked_from_story_id ?? "Original story"}</span>
        </InlineMeta>
      </SectionCard>

      <SectionCard
        title="Timeline preview"
        description="Every timeline is a readable path through this story. Open the explorer for the full ForkCraft map."
      >
        <div className="narrio-list">
          {visibleBranches.length ? (
            visibleBranches.map((branch) => (
              <Link
                key={branch.id}
                href={`/story/${story.id}/branch/${branch.id}`}
                className="narrio-list-item"
              >
                <strong>{branch.name}</strong>
                <div className="narrio-muted">{branch.description ?? "No description yet."}</div>
                <InlineMeta>
                  <span>{branch.branch_type === "main" ? "Root timeline" : `Fork type: ${branch.branch_type}`}</span>
                  <span>Status: {branch.status}</span>
                  <span>Visibility: {branch.visibility}</span>
                </InlineMeta>
              </Link>
            ))
          ) : (
            <div className="narrio-list-item">No visible timelines yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
