import Link from "next/link";
import {
  BOOKMARK_TAG_PRESETS,
  getBranchById,
  getChapterById,
  getCurrentVersionByChapterId,
  getStoryById,
  hasLikedVersion,
  listBookmarkTagsForChapter,
  listCommentsByChapterId
} from "@narrio/api";
import {
  Field,
  InlineMeta,
  PageHeader,
  PrimaryButton,
  SectionCard,
  Stack,
  TextAreaField
} from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";
import { saveBookmarkAction, toggleBookmarkAction, toggleLikeAction } from "../../../../reader/actions";
import { createCommentAction } from "../../../../reader/comment_actions";

export default async function ChapterReaderPage(props: {
  params: Promise<{ storyId: string; chapterId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const chapter = await getChapterById(supabase, params.chapterId);
  const branch = await getBranchById(supabase, chapter.branch_id);
  const currentVersion = await getCurrentVersionByChapterId(supabase, params.chapterId);
  const comments = await listCommentsByChapterId(supabase, chapter.id);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const bookmarkTags = user
    ? await listBookmarkTagsForChapter(supabase, { userId: user.id, chapterId: chapter.id })
    : [];
  const liked = user
    ? await hasLikedVersion(supabase, { userId: user.id, chapterVersionId: currentVersion.id })
    : false;
  const canEditTimeline = user?.id === story.author_id || user?.id === branch.created_by;
  const canForkChapter = Boolean(story.allow_forks) || canEditTimeline;
  const redirectPath = `/story/${story.id}/chapter/${chapter.id}`;

  return (
    <Stack>
      <PageHeader
        eyebrow="Reader"
        title={`${story.title} — Chapter ${chapter.chapter_number}`}
        description={chapter.title}
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href={`/story/${story.id}/branch/${chapter.branch_id}`}>
              Back to timeline
            </Link>
            <Link className="narrio-button-secondary" href={`/story/${story.id}/timelines`}>
              Explore timelines
            </Link>
            {canForkChapter ? (
              <Link className="narrio-button" href={`/story/${story.id}/chapter/${chapter.id}/fork`}>
                Fork from this chapter
              </Link>
            ) : null}
            {canEditTimeline ? (
              <Link className="narrio-button-secondary" href={`/write/editor/${story.id}/branch/${branch.id}?chapter=${chapter.id}`}>
                Open in Story Studio
              </Link>
            ) : null}
            {user ? (
              <>
                <Link className="narrio-button-secondary" href="/write/bookmarks">
                  My waypoints
                </Link>
                <form action={toggleLikeAction}>
                  <input type="hidden" name="chapterVersionId" value={currentVersion.id} />
                  <input type="hidden" name="redirectPath" value={redirectPath} />
                  <PrimaryButton>{liked ? "Unlike version" : "Like current version"}</PrimaryButton>
                </form>
              </>
            ) : (
              <Link className="narrio-button-secondary" href="/signin">
                Sign in for reader actions
              </Link>
            )}
          </div>
        }
      />

      <SectionCard title="Current version" description="You are reading the latest saved version of this chapter.">
        <InlineMeta>
          <span>Timeline: {branch.name}</span>
          <span>Version {currentVersion.version_number}</span>
          <span>Source: {currentVersion.source}</span>
          <span>Save note: {currentVersion.commit_message ?? "No save note"}</span>
        </InlineMeta>
        <div className="narrio-code" style={{ marginTop: 16 }}>
          {currentVersion.content_md}
        </div>
      </SectionCard>

      <SectionCard
        title="Save this waypoint"
        description="Tag this chapter as a memory, clue, quote, or fork idea."
      >
        {user ? (
          <Stack>
            <div className="narrio-bookmark-tags">
              {bookmarkTags.length ? (
                bookmarkTags.map((bookmark: any) => (
                  <span key={bookmark.id} className="narrio-badge">
                    {bookmark.tag} · {bookmark.is_public ? "public" : "private"}
                  </span>
                ))
              ) : (
                <span className="narrio-muted">No waypoint tags saved for this chapter yet.</span>
              )}
            </div>

            <div className="narrio-tag-grid">
              {BOOKMARK_TAG_PRESETS.map((preset) => {
                const active = bookmarkTags.some((bookmark: any) => bookmark.tag === preset.tag);
                return (
                  <form key={preset.tag} action={toggleBookmarkAction} className="narrio-mini-form">
                    <input type="hidden" name="chapterId" value={chapter.id} />
                    <input type="hidden" name="tag" value={preset.tag} />
                    <input type="hidden" name="redirectPath" value={redirectPath} />
                    <PrimaryButton>{active ? `Remove ${preset.label}` : preset.label}</PrimaryButton>
                    <span className="narrio-muted">{preset.description}</span>
                  </form>
                );
              })}
            </div>

            <form action={saveBookmarkAction} className="narrio-form narrio-bookmark-form">
              <input type="hidden" name="chapterId" value={chapter.id} />
              <input type="hidden" name="redirectPath" value={redirectPath} />
              <Field
                label="Custom waypoint tag"
                name="tag"
                placeholder="Example: prophecy, battle-scene, emotional-turn"
              />
              <label className="narrio-checkbox">
                <input type="checkbox" name="isPublic" />
                <span>Mark this waypoint public later when public reader profiles are enabled.</span>
              </label>
              <PrimaryButton>Save waypoint</PrimaryButton>
            </form>
          </Stack>
        ) : (
          <Link className="narrio-button" href="/signin">
            Sign in to save waypoints
          </Link>
        )}
      </SectionCard>

      <SectionCard title="Discussion" description="Reader comments for this chapter.">
        {user ? (
          <form action={createCommentAction} className="narrio-form">
            <input type="hidden" name="storyId" value={story.id} />
            <input type="hidden" name="chapterId" value={chapter.id} />
            <TextAreaField
              label="Your comment"
              name="body"
              rows={4}
              placeholder="Share your reaction, theory, or feedback..."
            />
            <label className="narrio-field">
              <span>Spoiler flag</span>
              <select className="narrio-select" name="isSpoiler" defaultValue="false">
                <option value="false">false</option>
                <option value="true">true</option>
              </select>
            </label>
            <PrimaryButton>Post comment</PrimaryButton>
          </form>
        ) : (
          <Link className="narrio-button" href="/signin">
            Sign in to comment
          </Link>
        )}

        <div style={{ height: 18 }} />

        <div className="narrio-list">
          {comments.length ? (
            comments.map((comment: any) => (
              <div key={comment.id} className="narrio-list-item">
                <strong>Reader</strong>
                <div className="narrio-muted">
                  {comment.is_spoiler ? "Spoiler" : "General"} · {new Date(comment.created_at).toLocaleString()}
                </div>
                <div style={{ height: 10 }} />
                <div>{comment.body}</div>
              </div>
            ))
          ) : (
            <div className="narrio-list-item">No comments yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
