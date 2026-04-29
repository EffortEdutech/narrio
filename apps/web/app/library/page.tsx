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

function countLabel(count: number, singular: string, plural?: string) {
  return `${count} ${count === 1 ? singular : plural ?? `${singular}s`}`;
}

function discoveryLabel(path: string, fork: string) {
  if (path === "forkcraft") return "Forkcraft universes";
  if (path === "root") return "Root paths";
  if (fork === "forkable") return "Forkcraft-open universes";
  if (fork === "closed") return "Closed-canon universes";
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
  const displayQuery = q.trim();

  return (
    <Stack>
      <section className={styles.discoveryHero}>
        <div>
          <PageHeader
            eyebrow="Library"
            title="Discover story universes"
            description="Search public universes, find Forkcraft-open worlds, and choose the next timeline to enter."
          />
          <InlineMeta>
            <span>{countLabel(discovery.totalStories, "public universe", "public universes")}</span>
            <span>{countLabel(discovery.totalTimelines, "public timeline")}</span>
            <span>{countLabel(discovery.totalPublishedChapters, "released chapter")}</span>
            <span>{countLabel(discovery.forkableStories, "Forkcraft-open universe", "Forkcraft-open universes")}</span>
          </InlineMeta>
        </div>

        <div className={styles.heroCard}>
          <span>{discoveryLabel(discovery.path, discovery.fork)}</span>
          <strong>{displayQuery ? `Searching “${displayQuery}”` : "Fresh public signals"}</strong>
          <p>Library discovery reads universe, timeline, and chapter signals instead of showing a flat list.</p>
        </div>
      </section>

      <div className={styles.discoveryPanel}>
        <SectionCard title="Find your next path" description="Search by universe title, synopsis, or writer name. Then filter by timeline shape and Forkcraft permission.">
        <form className={styles.discoveryForm}>
          <label>
            <span>Search</span>
            <input name="q" defaultValue={displayQuery} placeholder="dragon archive, moon city, lost heir..." />
          </label>

          <label>
            <span>Sort</span>
            <select name="sort" defaultValue={discovery.sort}>
              <option value="newest">Newest universes</option>
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
              <option value="forkcraft">Forkcraft paths</option>
            </select>
          </label>

          <label>
            <span>Forkcraft</span>
            <select name="fork" defaultValue={discovery.fork}>
              <option value="all">Any permission</option>
              <option value="forkable">Forkcraft open</option>
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
      </div>

      <div className={styles.resultHeader}>
        <div>
          <span className={styles.resultEyebrow}>Discovery results</span>
          <h2>{discovery.totalStories ? countLabel(discovery.totalStories, "public universe", "public universes") : "No matching universe yet"}</h2>
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
                <span>{item.story.allow_forks ? "Forkcraft open" : "Closed canon"}</span>
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
                <p>{item.story.synopsis ?? "A public Narrio universe waiting for its first synopsis."}</p>

                <InlineMeta>
                  <span>{countLabel(item.publishedChapterCount, "chapter")}</span>
                  <span>{countLabel(item.timelineCount, "timeline")}</span>
                  <span>{countLabel(item.forkTimelineCount, "Forkcraft path")}</span>
                </InlineMeta>

                {item.latestChapter ? (
                  <Link className={styles.latestSignal} href={`/story/${item.story.id}/chapter/${item.latestChapter.id}`}>
                    <span>Latest signal</span>
                    <strong>
                      Chapter {item.latestChapter.chapter_number}: {item.latestChapter.title}
                    </strong>
                  </Link>
                ) : (
                  <div className={styles.latestSignalMuted}>No released chapter is readable yet.</div>
                )}

                <div className={styles.storyActions}>
                  {item.startChapter ? (
                    <Link className="narrio-button" href={`/story/${item.story.id}/chapter/${item.startChapter.id}`}>
                      Start reading
                    </Link>
                  ) : null}
                  <Link className="narrio-button-secondary" href={`/story/${item.story.id}`}>
                    Universe page
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
            title="No universe matched this discovery path"
            description="Try removing one filter, or release another public universe from the Release Center."
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
