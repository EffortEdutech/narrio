import Link from "next/link";
import { notFound } from "next/navigation";
import { getPublicStoryOverview, isFollowingStory } from "@narrio/api";
import { InlineMeta, PrimaryButton, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";
import { toggleFollowAction } from "../../reader/actions";
import styles from "./story-page.module.css";

function formatDate(value?: string | null) {
  if (!value) return "Not released yet";

  return new Intl.DateTimeFormat("en", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(value));
}

function authorName(author: { display_name: string | null; username: string | null } | null) {
  return author?.display_name ?? author?.username ?? "Narrio writer";
}

function timelineLabel(branchType: string) {
  if (branchType === "main") return "Root timeline";
  if (branchType === "alternate") return "Alternate path";
  if (branchType === "experimental") return "Experimental path";
  return "Forkcraft path";
}

export default async function StoryPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const supabase = await createClient();

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const overview = await getPublicStoryOverview(supabase, storyId, user?.id ?? null);
  if (!overview) notFound();

  const {
    story,
    author,
    canEdit,
    branches,
    startChapter,
    latestChapter,
    mainBranch,
    totalVisibleBranches,
    totalVisibleChapters,
    publishedChapterCount,
    draftChapterCount,
    forkTimelineCount
  } = overview;

  const following = user ? await isFollowingStory(supabase, { userId: user.id, storyId }) : false;
  const readableState = story.status === "published" ? "Released universe" : "Private writer preview";
  const isDiscoverable = story.status === "published" && story.visibility === "public";
  const isDirectLinkOnly = story.status === "published" && story.visibility === "unlisted";

  return (
    <Stack>
      <section
        className={styles.storyHero}
        style={
          story.cover_url
            ? {
                backgroundImage: `linear-gradient(135deg, rgba(26, 18, 56, 0.92), rgba(124, 58, 237, 0.72)), url(${story.cover_url})`
              }
            : undefined
        }
      >
        <div className={styles.heroCopy}>
          <div className={styles.eyebrow}>{readableState}</div>
          <h1>{story.title}</h1>
          <p>{story.synopsis ?? "A branching story universe waiting to be explored."}</p>

          <div className={styles.heroActions}>
            {startChapter ? (
              <Link className="narrio-button" href={`/story/${story.id}/chapter/${startChapter.id}`}>
                Start reading
              </Link>
            ) : (
              <span className={styles.disabledCta}>No readable chapter yet</span>
            )}
            <Link className="narrio-button-secondary" href={`/story/${story.id}/timelines`}>
              Explore timelines
            </Link>
            {user ? (
              <form action={toggleFollowAction}>
                <input type="hidden" name="storyId" value={story.id} />
                <input type="hidden" name="redirectPath" value={`/story/${story.id}`} />
                <PrimaryButton>{following ? "Following" : "Follow universe"}</PrimaryButton>
              </form>
            ) : (
              <Link className="narrio-button-secondary" href="/signin">
                Sign in to follow
              </Link>
            )}
          </div>

          <InlineMeta>
            <span>{isDiscoverable ? "Discoverable in Library" : isDirectLinkOnly ? "Unlisted direct link" : story.visibility}</span>
            <span>{story.allow_forks ? "Forkcraft open" : "Forkcraft closed"}</span>
            <span>{mainBranch ? `Root: ${mainBranch.name}` : "No root timeline"}</span>
          </InlineMeta>
        </div>

        <aside className={styles.heroPanel}>
          <div className={styles.coverOrb}>{story.cover_url ? "Cover" : "Narrio"}</div>
          <div className={styles.statGrid}>
            <div>
              <strong>{totalVisibleBranches}</strong>
              <span>Timelines</span>
            </div>
            <div>
              <strong>{publishedChapterCount}</strong>
              <span>Released chapters</span>
            </div>
            <div>
              <strong>{forkTimelineCount}</strong>
              <span>Fork paths</span>
            </div>
          </div>
        </aside>
      </section>

      <div className={styles.storyToolbar}>
        <div>
          <strong>By {authorName(author)}</strong>
          <span>{author?.bio ?? "Creator profile is ready for a short author note."}</span>
        </div>
        <div className="narrio-nav">
          <Link className="narrio-button-secondary" href={`/u/${story.author_id}`}>
            Writer profile
          </Link>
          {canEdit ? (
            <>
              <Link className="narrio-button-secondary" href={`/write/publish/${story.id}`}>
                Release Center
              </Link>
              {story.main_branch_id ? (
                <Link className="narrio-button" href={`/write/editor/${story.id}/branch/${story.main_branch_id}`}>
                  Story Studio
                </Link>
              ) : null}
            </>
          ) : null}
        </div>
      </div>

      <div className={styles.kpiGrid}>
        <SectionCard title="Reading path" description={startChapter ? "Best first step for new readers." : "Release a chapter to unlock reading."}>
          {startChapter ? (
            <Link className={styles.kpiLink} href={`/story/${story.id}/chapter/${startChapter.id}`}>
              <strong>
                Chapter {startChapter.chapter_number}: {startChapter.title}
              </strong>
              <span>{startChapter.summary ?? "Open the first chapter and enter the universe."}</span>
            </Link>
          ) : (
            <p className="narrio-muted">No released chapter is available yet.</p>
          )}
        </SectionCard>

        <SectionCard title="Latest signal" description="The newest released point in the universe.">
          {latestChapter ? (
            <Link className={styles.kpiLink} href={`/story/${story.id}/chapter/${latestChapter.id}`}>
              <strong>
                Chapter {latestChapter.chapter_number}: {latestChapter.title}
              </strong>
              <span>Released {formatDate(latestChapter.published_at ?? latestChapter.updated_at)}</span>
            </Link>
          ) : (
            <p className="narrio-muted">No latest chapter yet.</p>
          )}
        </SectionCard>

        <SectionCard title="Universe health" description="What readers can currently see.">
          <InlineMeta>
            <span>{totalVisibleChapters} visible chapters</span>
            <span>{draftChapterCount} drafts visible to writer</span>
            <span>{branches.length} readable timelines</span>
          </InlineMeta>
        </SectionCard>
      </div>

      <SectionCard
        title="Choose a timeline"
        description="Every timeline is a readable path. Start with the root path, or follow a Forkcraft branch into another version."
      >
        <div className={styles.timelineGrid}>
          {branches.length ? (
            branches.map((card) => (
              <article key={card.branch.id} className={styles.timelineCard}>
                <div className={styles.timelineCardTop}>
                  <span>{timelineLabel(card.branch.branch_type)}</span>
                  <small>{card.branch.visibility}</small>
                </div>

                <h3>{card.branch.name}</h3>
                <p>{card.branch.description ?? "A story path waiting for its own reader rhythm."}</p>

                <InlineMeta>
                  <span>{card.chapterCount} readable chapters</span>
                  <span>{card.publishedChapterCount} released</span>
                  {canEdit && card.draftChapterCount ? <span>{card.draftChapterCount} drafts</span> : null}
                </InlineMeta>

                {card.firstChapter ? (
                  <div className={styles.chapterPreview}>
                    <strong>
                      Chapter {card.firstChapter.chapter_number}: {card.firstChapter.title}
                    </strong>
                    <span>{card.firstChapter.summary ?? "Start this timeline from its first readable chapter."}</span>
                  </div>
                ) : (
                  <div className={styles.chapterPreviewMuted}>No readable chapters in this timeline yet.</div>
                )}

                <div className={styles.timelineActions}>
                  <Link className="narrio-button-secondary" href={`/story/${story.id}/branch/${card.branch.id}`}>
                    Open timeline
                  </Link>
                  {card.firstChapter ? (
                    <Link className="narrio-button" href={`/story/${story.id}/chapter/${card.firstChapter.id}`}>
                      Start this path
                    </Link>
                  ) : null}
                </div>
              </article>
            ))
          ) : (
            <div className="narrio-list-item">No public timelines yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
