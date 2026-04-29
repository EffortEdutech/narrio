import Link from "next/link";
import { notFound } from "next/navigation";
import { getBranchesByStoryId, getChaptersByBranchId, getStoryById } from "@narrio/api";
import { BRAND } from "@narrio/config";
import { InlineMeta, PageHeader, SectionCard, Stack, TwoColumn } from "@narrio/ui";
import { requireUser } from "../../../../lib/auth";
import {
  setStoryPublishStatusAction,
  toggleChapterPublicationAction,
  updateStoryPublishingSettingsAction,
  updateTimelineVisibilityAction
} from "../../actions";

type Visibility = "public" | "unlisted" | "private";

const visibilityCopy: Record<Visibility, string> = {
  public: "Public — available to readers and discovery surfaces.",
  unlisted: "Unlisted — available by direct link, hidden from discovery.",
  private: "Private — only visible to you in Story Studio."
};

function formatDate(value: string | null) {
  if (!value) return "Not released";
  return new Date(value).toLocaleString();
}

function VisibilitySelect(props: { name?: string; defaultValue: Visibility }) {
  return (
    <select className="narrio-select" name={props.name ?? "visibility"} defaultValue={props.defaultValue}>
      <option value="public">Public</option>
      <option value="unlisted">Unlisted</option>
      <option value="private">Private</option>
    </select>
  );
}

export default async function PublishControlCenterPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const params = await props.params;
  const { supabase, user } = await requireUser();

  const story = await getStoryById(supabase, params.storyId);
  if (story.author_id !== user.id) notFound();

  const branches = await getBranchesByStoryId(supabase, story.id);
  const timelines = await Promise.all(
    branches.map(async (branch) => ({
      branch,
      chapters: await getChaptersByBranchId(supabase, branch.id)
    }))
  );
  const chapters = timelines.flatMap((timeline) => timeline.chapters);

  const publishedChapters = chapters.filter((chapter) => chapter.is_published).length;
  const visibleTimelines = branches.filter((branch) => branch.visibility === "public" || branch.visibility === "unlisted").length;
  const privateTimelines = branches.filter((branch) => branch.visibility === "private").length;
  const isStoryLive = story.status === "published" && story.visibility !== "private" && publishedChapters > 0 && visibleTimelines > 0;
  const nextStoryStatus = story.status === "published" ? "draft" : "published";

  return (
    <Stack>
      <PageHeader
        eyebrow="Release Center"
        title={`Launch room for ${story.title}`}
        description="Choose what readers can see before this universe leaves Story Studio. Release the universe shell, open selected timelines, and release chapters one by one."
        actions={
          <div className="narrio-nav">
            <Link href="/write">Writer dashboard</Link>
            {story.main_branch_id ? (
              <Link href={`/write/editor/${story.id}/branch/${story.main_branch_id}`}>Story Studio</Link>
            ) : null}
            <Link href={`/story/${story.id}`}>Reader preview</Link>
          </div>
        }
      />

      <SectionCard
        title={isStoryLive ? "Reader-ready" : "Not fully reader-ready yet"}
        description={
          isStoryLive
            ? "This universe has a visible shell, at least one visible timeline, and at least one released chapter."
            : "Use the checklist below to make the universe visible without accidentally exposing unfinished paths."
        }
      >
        <div className={isStoryLive ? "narrio-publish-banner ready" : "narrio-publish-banner draft"}>
          <div>
            <span className="narrio-badge">{isStoryLive ? "Live path open" : "Controlled draft"}</span>
            <h2>{isStoryLive ? "Readers can enter this universe." : "Readers need at least one complete public path."}</h2>
            <p>
              Universe status is <strong>{story.status}</strong>, universe visibility is <strong>{story.visibility}</strong>, {publishedChapters} of {chapters.length} chapters are released, and {visibleTimelines} timelines are visible.
            </p>
          </div>
          <form action={setStoryPublishStatusAction}>
            <input type="hidden" name="storyId" value={story.id} />
            <input type="hidden" name="status" value={nextStoryStatus} />
            <button className={story.status === "published" ? "narrio-button-secondary" : "narrio-button"} type="submit">
              {story.status === "published" ? "Return universe to draft" : "Release universe shell"}
            </button>
          </form>
        </div>
      </SectionCard>

      <div className="narrio-stat-grid">
        <div className="narrio-stat-card">
          <strong>{story.status}</strong>
          <span>Universe status</span>
        </div>
        <div className="narrio-stat-card">
          <strong>{story.visibility}</strong>
          <span>Universe visibility</span>
        </div>
        <div className="narrio-stat-card">
          <strong>{publishedChapters}/{chapters.length}</strong>
          <span>Released chapters</span>
        </div>
        <div className="narrio-stat-card">
          <strong>{visibleTimelines}/{branches.length}</strong>
          <span>Visible timelines</span>
        </div>
      </div>

      <TwoColumn>
        <div className="narrio-stack">
          <SectionCard title="Universe access" description="This controls the universe shell. Chapters and timelines still have their own gates.">
            <form action={updateStoryPublishingSettingsAction} className="narrio-form">
              <input type="hidden" name="storyId" value={story.id} />
              <label className="narrio-field">
                Visibility
                <VisibilitySelect defaultValue={story.visibility as Visibility} />
                <span className="narrio-muted">{visibilityCopy[story.visibility as Visibility]}</span>
              </label>
              <label className="narrio-checkbox">
                <input name="allowForks" type="checkbox" defaultChecked={Boolean(story.allow_forks)} />
                <span>Allow readers to create Forkcraft timelines from this universe.</span>
              </label>
              <button className="narrio-button" type="submit">Save universe access</button>
            </form>
          </SectionCard>

          <SectionCard title="Timeline visibility" description="Open only the paths that are ready. Private timelines stay inside Story Studio.">
            <div className="narrio-list">
              {timelines.map(({ branch, chapters: branchChapters }) => (
                <div key={branch.id} className="narrio-list-item">
                  <div className="narrio-publish-row-header">
                    <div>
                      <span className="narrio-badge">{branch.branch_type}</span>
                      <h3>{branch.name}</h3>
                      <InlineMeta>
                        <span>{branch.visibility}</span>
                        <span>{branchChapters.filter((chapter) => chapter.is_published).length}/{branchChapters.length} chapters released</span>
                      </InlineMeta>
                    </div>
                    <Link className="narrio-button-secondary" href={`/write/editor/${story.id}/branch/${branch.id}`}>Edit</Link>
                  </div>
                  <div className="narrio-divider" />
                  <form action={updateTimelineVisibilityAction} className="narrio-form">
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <label className="narrio-field">
                      Timeline visibility
                      <VisibilitySelect defaultValue={branch.visibility as Visibility} />
                    </label>
                    <label className="narrio-field">
                      Timeline note
                      <textarea className="narrio-textarea" name="description" rows={3} defaultValue={branch.description ?? ""} />
                    </label>
                    <button className="narrio-button-secondary" type="submit">Save timeline visibility</button>
                  </form>
                </div>
              ))}
            </div>
          </SectionCard>
        </div>

        <div className="narrio-stack">
          <SectionCard title="Chapter release" description="Release only chapters that already have reader-safe current versions.">
            <div className="narrio-list">
              {timelines.map(({ branch, chapters: branchChapters }) => (
                <div key={branch.id} className="narrio-list-item">
                  <div className="narrio-publish-row-header">
                    <div>
                      <span className="narrio-badge">Timeline</span>
                      <h3>{branch.name}</h3>
                      <p className="narrio-muted">{branch.visibility} timeline · {branchChapters.length} chapters</p>
                    </div>
                    <Link className="narrio-button-secondary" href={`/story/${story.id}/branch/${branch.id}`}>Preview</Link>
                  </div>
                  <div className="narrio-divider" />
                  <div className="narrio-list">
                    {branchChapters.length ? (
                      branchChapters.map((chapter) => (
                        <div key={chapter.id} className="narrio-list-item narrio-split-list-item">
                          <div className="narrio-list-main">
                            <strong>Chapter {chapter.chapter_number}: {chapter.title}</strong>
                            <span className="narrio-muted">{chapter.summary ?? "No summary yet."}</span>
                            <InlineMeta>
                              <span>{chapter.is_published ? "Released" : "Draft"}</span>
                              <span>{formatDate(chapter.published_at)}</span>
                            </InlineMeta>
                          </div>
                          <form action={toggleChapterPublicationAction}>
                            <input type="hidden" name="storyId" value={story.id} />
                            <input type="hidden" name="branchId" value={branch.id} />
                            <input type="hidden" name="chapterId" value={chapter.id} />
                            <input type="hidden" name="isPublished" value={chapter.is_published ? "false" : "true"} />
                            <button className={chapter.is_published ? "narrio-button-secondary" : "narrio-button"} type="submit">
                              {chapter.is_published ? "Unrelease" : "Release"}
                            </button>
                          </form>
                        </div>
                      ))
                    ) : (
                      <div className="narrio-callout">No chapters yet. Add chapters in Story Studio before releasing this timeline.</div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </SectionCard>

          <SectionCard title={`${BRAND.engine} release logic`} description="Narrio separates writing from release.">
            <div className="narrio-callout">
              A universe shell can be released while selected timelines and chapters remain private. This keeps Forkcraft safe: a reader only sees paths you deliberately open.
              {privateTimelines > 0 ? ` ${privateTimelines} timeline${privateTimelines === 1 ? " is" : "s are"} currently private.` : " All timelines are currently visible."}
            </div>
          </SectionCard>
        </div>
      </TwoColumn>
    </Stack>
  );
}
