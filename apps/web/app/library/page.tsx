import Link from "next/link";
import { getLibraryDiscovery } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../lib/supabase/server";
import styles from "./library.module.css";

function readParam(value: string | string[] | undefined) {
  if (Array.isArray(value)) return value[0] ?? "";
  return value ?? "";
}

function formatDate(value?: string | null) {
  if (!value) return "No update yet";

  return new Intl.DateTimeFormat("en", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(value));
}

function authorName(author: { display_name: string | null; username: string | null } | null) {
  return author?.display_name ?? author?.username ?? "Narrio writer";
}

function discoveryLabel(path: string, fork: string) {
  if (path === "forkcraft") return "ForkCraft universes";
  if (path === "root") return "Root paths";
  if (fork === "forkable") return "Fork-friendly stories";
  if (fork === "closed") return "Closed-canon stories";
  return "Public discovery";
}

export default async function LibraryPage(props: {
  searchParams?: Promise<Record<string, string | string[] | undefined>>;
}) {
  const searchParams = props.searchParams ? await props.searchParams : {};
  const q = readParam(searchParams.q);
  const sort = readParam(searchParams.sort);
  const path = readParam(searchParams.path);
  const fork = readParam(searchParams.fork);

  const supabase = await createClient();
  const discovery = await getLibraryDiscovery(supabase, {
    query: q,
    sort,
    path,
    fork
  });

  return (
    <Stack>
      <section className={styles.discoveryHero}>
        <div>
          <PageHeader
            eyebrow="Library"
            title="Discover story universes"
            description="Search published stories, find ForkCraft-ready worlds, and choose the next timeline to enter."
          />
          <InlineMeta>
            <span>{discovery.totalStories} stories</span>
            <span>{discovery.totalTimelines} public timelines</span>
            <span>{discovery.totalPublishedChapters} published chapters</span>
            <span>{discovery.forkableStories} forkable</span>
          </InlineMeta>
        </div>

        <div className={styles.heroCard}>
          <span>{discoveryLabel(discovery.path, discovery.fork)}</span>
          <strong>{discovery.query ? `Searching “${discovery.query}”` : "Fresh public signals"}</strong>
          <p>Library discovery now reads public story, timeline, and chapter data instead of showing a flat list.</p>
        </div>
      </section>

      <SectionCard title="Find your next path" description="Search by title, synopsis, or writer name. Then filter by story shape and ForkCraft permission.">
        <form className={styles.discoveryForm}>
          <label>
            <span>Search</span>
            <input name="q" defaultValue={discovery.query} placeholder="dragon archive, moon city, lost heir..." />
          </label>

          <label>
            <span>Sort</span>
            <select name="sort" defaultValue={discovery.sort}>
              <option value="newest">Newest stories</option>
              <option value="updated">Recently updated</option>
              <option value="title">Title A-Z</option>
              <option value="chapters">Most chapters</option>
              <option value="timelines">Most timelines</option>
            </select>
          </label>

          <label>
            <span>Path type</span>
            <select name="path" defaultValue={discovery.path}>
              <option value="all">All public paths</option>
              <option value="root">Root timelines</option>
              <option value="forkcraft">ForkCraft branches</option>
            </select>
          </label>

          <label>
            <span>ForkCraft</span>
            <select name="fork" defaultValue={discovery.fork}>
              <option value="all">Any permission</option>
              <option value="forkable">Forking enabled</option>
              <option value="closed">Closed canon</option>
            </select>
          </label>

          <div className={styles.formActions}>
            <button className="narrio-button" type="submit">
              Search library
            </button>
            <Link className="narrio-button-secondary" href="/library">
              Reset
            </Link>
          </div>
        </form>
      </SectionCard>

      <div className={styles.resultHeader}>
        <div>
          <span className={styles.resultEyebrow}>Discovery results</span>
          <h2>{discovery.totalStories ? `${discovery.totalStories} public story${discovery.totalStories === 1 ? "" : "ies"}` : "No matching stories yet"}</h2>
        </div>
        <Link className="narrio-button-secondary" href="/onboarding">
          New here? Start in 60 seconds
        </Link>
      </div>

      <div className={styles.libraryGrid}>
        {discovery.items.length ? (
          discovery.items.map((item) => (
            <article key={item.story.id} className={styles.storyCard}>
              <div
                className={styles.storyCover}
                style={
                  item.story.cover_url
                    ? {
                        backgroundImage: `linear-gradient(135deg, rgba(20, 16, 45, 0.82), rgba(124, 58, 237, 0.48)), url(${item.story.cover_url})`
                      }
                    : undefined
                }
              >
                <span>{item.story.allow_forks ? "ForkCraft open" : "Closed canon"}</span>
              </div>

              <div className={styles.storyBody}>
                <div className={styles.storyTopline}>
                  {item.author ? (
                    <Link className={styles.authorLink} href={`/u/${item.author.id}`}>
                      By {authorName(item.author)}
                    </Link>
                  ) : (
                    <span>By {authorName(item.author)}</span>
                  )}
                  <small>{formatDate(item.latestPublishedAt)}</small>
                </div>

                <h3>{item.story.title}</h3>
                <p>{item.story.synopsis ?? "A published Narrio universe waiting for its first synopsis."}</p>

                <InlineMeta>
                  <span>{item.publishedChapterCount} chapters</span>
                  <span>{item.timelineCount} timelines</span>
                  <span>{item.forkTimelineCount} ForkCraft paths</span>
                </InlineMeta>

                {item.latestChapter ? (
                  <Link className={styles.latestSignal} href={`/story/${item.story.id}/chapter/${item.latestChapter.id}`}>
                    <span>Latest signal</span>
                    <strong>
                      Chapter {item.latestChapter.chapter_number}: {item.latestChapter.title}
                    </strong>
                  </Link>
                ) : (
                  <div className={styles.latestSignalMuted}>No published chapter is readable yet.</div>
                )}

                <div className={styles.storyActions}>
                  {item.startChapter ? (
                    <Link className="narrio-button" href={`/story/${item.story.id}/chapter/${item.startChapter.id}`}>
                      Start reading
                    </Link>
                  ) : null}
                  <Link className="narrio-button-secondary" href={`/story/${item.story.id}`}>
                    Story page
                  </Link>
                  <Link className="narrio-button-secondary" href={`/story/${item.story.id}/timelines`}>
                    Timelines
                  </Link>
                </div>
              </div>
            </article>
          ))
        ) : (
          <SectionCard
            title="No story matched this discovery path"
            description="Try removing one filter, or publish another public story from the Publish Control Center."
          >
            <Link className="narrio-button" href="/library">
              Clear discovery filters
            </Link>
          </SectionCard>
        )}
      </div>
    </Stack>
  );
}
