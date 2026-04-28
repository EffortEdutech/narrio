import Link from "next/link";
import {
  getChapterById,
  getCurrentVersionByChapterId,
  getStoryById,
  hasBookmarkedChapter,
  hasLikedVersion,
  listCommentsByChapterId
} from "@narrio/api";
import {
  InlineMeta,
  PageHeader,
  PrimaryButton,
  SectionCard,
  Stack,
  TextAreaField
} from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";
import { toggleBookmarkAction, toggleLikeAction } from "../../../../reader/actions";
import { createCommentAction } from "../../../../reader/comment_actions";

export default async function ChapterReaderPage(props: {
  params: Promise<{ storyId: string; chapterId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const chapter = await getChapterById(supabase, params.chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, params.chapterId);
  const comments = await listCommentsByChapterId(supabase, chapter.id);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const bookmarked = user
    ? await hasBookmarkedChapter(supabase, { userId: user.id, chapterId: chapter.id, tag: "favorite" })
    : false;
  const liked = user
    ? await hasLikedVersion(supabase, { userId: user.id, chapterVersionId: currentVersion.id })
    : false;

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
            {user ? (
              <>
                <form action={toggleBookmarkAction}>
                  <input type="hidden" name="chapterId" value={chapter.id} />
                  <input type="hidden" name="tag" value="favorite" />
                  <input type="hidden" name="redirectPath" value={`/story/${story.id}/chapter/${chapter.id}`} />
                  <PrimaryButton>{bookmarked ? "Remove bookmark" : "Bookmark chapter"}</PrimaryButton>
                </form>
                <form action={toggleLikeAction}>
                  <input type="hidden" name="chapterVersionId" value={currentVersion.id} />
                  <input type="hidden" name="redirectPath" value={`/story/${story.id}/chapter/${chapter.id}`} />
                  <PrimaryButton>{liked ? "Unlike version" : "Like current version"}</PrimaryButton>
                </form>
              </>
            ) : (
              <Link className="narrio-button" href="/signin">
                Sign in for reader actions
              </Link>
            )}
          </div>
        }
      />

      <SectionCard title="Current version" description="You are reading the latest saved version of this chapter.">
        <InlineMeta>
          <span>Version {currentVersion.version_number}</span>
          <span>Source: {currentVersion.source}</span>
          <span>Save note: {currentVersion.commit_message ?? "No save note"}</span>
        </InlineMeta>
        <div className="narrio-code" style={{ marginTop: 16 }}>
          {currentVersion.content_md}
        </div>
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
