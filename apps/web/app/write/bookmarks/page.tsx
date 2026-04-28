import Link from "next/link";
import { BOOKMARK_TAG_PRESETS, listBookmarksWithContext } from "@narrio/api";
import { InlineMeta, PageHeader, PrimaryButton, SectionCard, Stack } from "@narrio/ui";
import { requireUser } from "../../../lib/auth";
import { deleteBookmarkAction } from "../../reader/actions";

export default async function WriterBookmarksPage(props: {
  searchParams?: Promise<{ tag?: string }>;
}) {
  const searchParams = props.searchParams ? await props.searchParams : {};
  const selectedTag = searchParams.tag ?? "all";

  const { supabase, user } = await requireUser();
  const bookmarks = await listBookmarksWithContext(supabase, user.id);

  const dynamicTags = Array.from(new Set(bookmarks.map((bookmark: any) => bookmark.tag))).filter(Boolean);
  const tagOptions = Array.from(
    new Set(["all", ...BOOKMARK_TAG_PRESETS.map((preset) => preset.tag), ...dynamicTags])
  );
  const filteredBookmarks = selectedTag === "all"
    ? bookmarks
    : bookmarks.filter((bookmark: any) => bookmark.tag === selectedTag);

  return (
    <Stack>
      <PageHeader
        eyebrow="Reader tools"
        title="My waypoints"
        description="Tagged chapter bookmarks across all stories and timelines."
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href="/library">
              Back to library
            </Link>
          </div>
        }
      />

      <SectionCard title="Filter by tag" description="Use tags to return to clues, quotes, rereads, and fork ideas.">
        <div className="narrio-bookmark-tags">
          {tagOptions.map((tag) => {
            const active = tag === selectedTag;
            const label = tag === "all" ? "All" : tag;
            return (
              <Link
                key={tag}
                href={tag === "all" ? "/write/bookmarks" : `/write/bookmarks?tag=${encodeURIComponent(tag)}`}
                className={active ? "narrio-badge narrio-badge-active" : "narrio-badge"}
              >
                {label}
              </Link>
            );
          })}
        </div>
      </SectionCard>

      <SectionCard
        title="Saved waypoints"
        description={`${filteredBookmarks.length} saved ${filteredBookmarks.length === 1 ? "waypoint" : "waypoints"} shown.`}
      >
        <div className="narrio-list">
          {filteredBookmarks.length ? (
            filteredBookmarks.map((bookmark: any) => {
              const chapter = Array.isArray(bookmark.chapters) ? bookmark.chapters[0] : bookmark.chapters;
              const story = Array.isArray(chapter?.stories) ? chapter?.stories[0] : chapter?.stories;
              const timeline = Array.isArray(chapter?.story_branches)
                ? chapter?.story_branches[0]
                : chapter?.story_branches;

              return (
                <div key={bookmark.id} className="narrio-list-item narrio-bookmark-row">
                  <div>
                    <Link href={`/story/${chapter?.story_id}/chapter/${bookmark.chapter_id}`}>
                      <strong>{story?.title ?? "Story"} — Chapter {chapter?.chapter_number}</strong>
                    </Link>
                    <div className="narrio-muted">{chapter?.title ?? "Chapter"}</div>
                    <InlineMeta>
                      <span>Tag: {bookmark.tag}</span>
                      <span>{bookmark.is_public ? "Public" : "Private"}</span>
                      {timeline?.name ? <span>Timeline: {timeline.name}</span> : null}
                      <span>{new Date(bookmark.created_at).toLocaleString()}</span>
                    </InlineMeta>
                  </div>

                  <form action={deleteBookmarkAction} className="narrio-mini-form narrio-bookmark-delete">
                    <input type="hidden" name="bookmarkId" value={bookmark.id} />
                    <input
                      type="hidden"
                      name="redirectPath"
                      value={selectedTag === "all" ? "/write/bookmarks" : `/write/bookmarks?tag=${selectedTag}`}
                    />
                    <PrimaryButton>Remove</PrimaryButton>
                  </form>
                </div>
              );
            })
          ) : (
            <div className="narrio-list-item">
              No saved waypoints for this filter yet. Open a chapter and use Save this waypoint.
            </div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
