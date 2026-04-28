import Link from "next/link";
import { notFound } from "next/navigation";
import { getPublicWriterProfile } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../lib/supabase/server";
import styles from "./profile.module.css";

function formatDate(value?: string | null) {
  if (!value) return "No public signal yet";

  return new Intl.DateTimeFormat("en", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(value));
}

function writerName(profile: { display_name: string | null; username: string | null }) {
  return profile.display_name ?? profile.username ?? "Narrio writer";
}

function writerHandle(profile: { username: string | null; id: string }) {
  return profile.username ? `@${profile.username}` : `writer-${profile.id.slice(0, 8)}`;
}

function initials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  const first = parts[0]?.[0] ?? "N";
  const second = parts[1]?.[0] ?? "";
  return `${first}${second}`.toUpperCase();
}

function storyShape(item: { forkTimelineCount: number; rootTimelineCount: number }) {
  if (item.forkTimelineCount > 0) return "ForkCraft universe";
  if (item.rootTimelineCount > 0) return "Root canon";
  return "Published story";
}

export default async function PublicProfilePage(props: {
  params: Promise<{ userId: string }>;
}) {
  const { userId } = await props.params;
  const supabase = await createClient();

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const overview = await getPublicWriterProfile(supabase, userId);
  if (!overview) notFound();

  const {
    profile,
    stories,
    featuredStory,
    publicStoryCount,
    publicTimelineCount,
    forkTimelineCount,
    publishedChapterCount,
    forkableStoryCount,
    forkedStoryCount,
    latestPublishedAt
  } = overview;

  const name = writerName(profile);
  const canEdit = user?.id === profile.id;

  return (
    <Stack>
      <section className={styles.profileHero}>
        <div className={styles.identityBlock}>
          <div className={styles.avatarShell}>
            {profile.avatar_url ? <img src={profile.avatar_url} alt="" /> : <span>{initials(name)}</span>}
          </div>
          <div>
            <PageHeader
              eyebrow="Creator profile"
              title={name}
              description={profile.bio ?? "A Narrio writer shaping story universes, timelines, and ForkCraft paths."}
            />
            <InlineMeta>
              <span>{writerHandle(profile)}</span>
              <span>Joined {formatDate(profile.created_at)}</span>
              <span>Latest signal {formatDate(latestPublishedAt)}</span>
            </InlineMeta>
          </div>
        </div>

        <div className={styles.heroActions}>
          <Link className="narrio-button" href="/library">
            Explore library
          </Link>
          {canEdit ? (
            <Link className="narrio-button-secondary" href="/write">
              Writer dashboard
            </Link>
          ) : null}
        </div>
      </section>

      <div className={styles.statGrid}>
        <div>
          <strong>{publicStoryCount}</strong>
          <span>Public stories</span>
        </div>
        <div>
          <strong>{publicTimelineCount}</strong>
          <span>Timelines</span>
        </div>
        <div>
          <strong>{publishedChapterCount}</strong>
          <span>Chapters</span>
        </div>
        <div>
          <strong>{forkTimelineCount}</strong>
          <span>ForkCraft paths</span>
        </div>
      </div>

      {featuredStory ? (
        <section
          className={styles.featuredStory}
          style={
            featuredStory.story.cover_url
              ? {
                  backgroundImage: `linear-gradient(135deg, rgba(26, 18, 56, 0.92), rgba(124, 58, 237, 0.64)), url(${featuredStory.story.cover_url})`
                }
              : undefined
          }
        >
          <div>
            <span className={styles.kicker}>Featured universe</span>
            <h2>{featuredStory.story.title}</h2>
            <p>{featuredStory.story.synopsis ?? "A published Narrio universe ready for readers."}</p>
            <InlineMeta>
              <span>{featuredStory.publishedChapterCount} chapters</span>
              <span>{featuredStory.publicTimelineCount} timelines</span>
              <span>{featuredStory.story.allow_forks ? "ForkCraft open" : "Closed canon"}</span>
            </InlineMeta>
          </div>

          <div className={styles.featuredActions}>
            {featuredStory.startChapter ? (
              <Link className="narrio-button" href={`/story/${featuredStory.story.id}/chapter/${featuredStory.startChapter.id}`}>
                Start reading
              </Link>
            ) : null}
            <Link className="narrio-button-secondary" href={`/story/${featuredStory.story.id}`}>
              Story page
            </Link>
          </div>
        </section>
      ) : (
        <SectionCard title="No public stories yet" description="This writer has a profile, but no discoverable published universe yet.">
          <Link className="narrio-button-secondary" href="/library">
            Return to Library
          </Link>
        </SectionCard>
      )}

      <div className={styles.profileColumns}>
        <SectionCard title="Published universes" description="Public stories by this writer. Unlisted and private drafts stay outside this profile.">
          <div className={styles.storyGrid}>
            {stories.length ? (
              stories.map((item) => (
                <article key={item.story.id} className={styles.storyCard}>
                  <div className={styles.storyTopline}>
                    <span>{storyShape(item)}</span>
                    <small>{formatDate(item.latestPublishedAt)}</small>
                  </div>

                  <h3>{item.story.title}</h3>
                  <p>{item.story.synopsis ?? "No synopsis yet."}</p>

                  <InlineMeta>
                    <span>{item.publishedChapterCount} chapters</span>
                    <span>{item.publicTimelineCount} timelines</span>
                    <span>{item.story.allow_forks ? "ForkCraft open" : "Closed canon"}</span>
                  </InlineMeta>

                  {item.latestChapter ? (
                    <Link className={styles.latestSignal} href={`/story/${item.story.id}/chapter/${item.latestChapter.id}`}>
                      <span>Latest signal</span>
                      <strong>
                        Chapter {item.latestChapter.chapter_number}: {item.latestChapter.title}
                      </strong>
                    </Link>
                  ) : null}

                  <div className={styles.cardActions}>
                    {item.startChapter ? (
                      <Link className="narrio-button" href={`/story/${item.story.id}/chapter/${item.startChapter.id}`}>
                        Start reading
                      </Link>
                    ) : null}
                    <Link className="narrio-button-secondary" href={`/story/${item.story.id}`}>
                      Story page
                    </Link>
                  </div>
                </article>
              ))
            ) : (
              <div className="narrio-list-item">No public story cards yet.</div>
            )}
          </div>
        </SectionCard>

        <aside className={styles.sidePanel}>
          <SectionCard title="Writer signal" description="Public profile health based on discoverable story data.">
            <div className={styles.signalList}>
              <div>
                <span>ForkCraft-ready stories</span>
                <strong>{forkableStoryCount}</strong>
              </div>
              <div>
                <span>Forked story origins</span>
                <strong>{forkedStoryCount}</strong>
              </div>
              <div>
                <span>Latest publication</span>
                <strong>{formatDate(latestPublishedAt)}</strong>
              </div>
            </div>
          </SectionCard>

          <SectionCard title="Reader doorway" description="A profile should help readers decide where to begin.">
            <div className={styles.readerDoorway}>
              <p>Start with the featured universe, then move into timelines to see how this creator shapes branches and alternate paths.</p>
              <Link className="narrio-button-secondary" href={`/library?q=${encodeURIComponent(name)}`}>
                Find this writer in Library
              </Link>
            </div>
          </SectionCard>
        </aside>
      </div>
    </Stack>
  );
}
