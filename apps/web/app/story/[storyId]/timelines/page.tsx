import Link from "next/link";
import { getTimelineExplorerByStoryId } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../../lib/supabase/server";

export default async function TimelineExplorerPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const supabase = await createClient();
  const explorer = await getTimelineExplorerByStoryId(supabase, storyId);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const visibleTimelines = explorer.branches.filter(
    (branch) => branch.visibility === "public" || user?.id === explorer.story.author_id
  );

  const totalChapters = visibleTimelines.reduce((sum, branch) => sum + branch.chapter_count, 0);
  const totalForks = visibleTimelines.filter((branch) => !branch.is_main).length;

  return (
    <Stack>
      <PageHeader
        eyebrow="ForkCraft Explorer"
        title={`${explorer.story.title} timelines`}
        description="Follow the root path, discover alternate timelines, and choose where to continue reading."
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href={`/story/${explorer.story.id}`}>
              Story home
            </Link>
            {user?.id === explorer.story.author_id ? (
              <Link className="narrio-button" href={`/write/editor/${explorer.story.id}/branch/${explorer.story.main_branch_id}`}>
                Open Story Studio
              </Link>
            ) : null}
          </div>
        }
      />

      <SectionCard
        title="Timeline overview"
        description="A reader-friendly map of the story branches already created in this universe."
      >
        <InlineMeta>
          <span>{visibleTimelines.length} timelines</span>
          <span>{totalForks} forks</span>
          <span>{totalChapters} chapters</span>
          <span>{explorer.story.allow_forks ? "ForkCraft enabled" : "ForkCraft disabled"}</span>
        </InlineMeta>
      </SectionCard>

      <SectionCard
        title="ForkCraft map"
        description="Indented timelines show where a path forked from another timeline."
      >
        <div className="narrio-timeline-map">
          {visibleTimelines.length ? (
            visibleTimelines.map((timeline) => (
              <article
                key={timeline.id}
                className={`narrio-timeline-node${timeline.is_main ? " main" : ""}`}
                style={{ marginLeft: timeline.depth * 24 }}
              >
                <div className="narrio-timeline-rail" aria-hidden="true" />
                <div className="narrio-timeline-content">
                  <div className="narrio-timeline-header">
                    <div>
                      <div className="narrio-inline-meta">
                        <span className="narrio-badge">{timeline.is_main ? "Root" : timeline.branch_type}</span>
                        <span>{timeline.path_label}</span>
                      </div>
                      <h3>{timeline.name}</h3>
                    </div>
                    <div className="narrio-nav">
                      <Link className="narrio-button" href={`/story/${explorer.story.id}/branch/${timeline.id}`}>
                        Read timeline
                      </Link>
                      {user?.id === explorer.story.author_id ? (
                        <Link className="narrio-button-secondary" href={`/write/editor/${explorer.story.id}/branch/${timeline.id}`}>
                          Edit
                        </Link>
                      ) : null}
                    </div>
                  </div>

                  <p className="narrio-muted">{timeline.description ?? "No timeline description yet."}</p>

                  <InlineMeta>
                    <span>{timeline.chapter_count} chapters</span>
                    <span>{timeline.children_count} child timelines</span>
                    <span>Visibility: {timeline.visibility}</span>
                    {timeline.latest_chapter ? (
                      <span>
                        Latest: Chapter {timeline.latest_chapter.chapter_number} · {timeline.latest_chapter.title}
                      </span>
                    ) : (
                      <span>No chapters yet</span>
                    )}
                  </InlineMeta>
                </div>
              </article>
            ))
          ) : (
            <div className="narrio-list-item">No visible timelines yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
