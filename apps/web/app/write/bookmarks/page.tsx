import Link from "next/link";
import { listBookmarksWithContext } from "@narrio/api";
import { PageHeader, SectionCard, Stack } from "@narrio/ui";
import { requireUser } from "../../../lib/auth";

export default async function WriterBookmarksPage() {
  const { supabase, user } = await requireUser();
  const bookmarks = await listBookmarksWithContext(supabase, user.id);

  return (
    <Stack>
      <PageHeader
        eyebrow="Reader tools"
        title="My bookmarks"
        description="Saved chapter waypoints for later reading."
      />

      <SectionCard title="Bookmarked chapters" description="Sprint 3 reader loop.">
        <div className="narrio-list">
          {bookmarks.length ? (
            bookmarks.map((bookmark: any) => {
              const chapter = bookmark.chapters;
              const story = Array.isArray(chapter?.stories) ? chapter?.stories[0] : chapter?.stories;
              return (
                <Link
                  key={bookmark.id}
                  className="narrio-list-item"
                  href={`/story/${chapter?.story_id}/chapter/${bookmark.chapter_id}`}
                >
                  <strong>{story?.title ?? "Story"} — Chapter {chapter?.chapter_number}</strong>
                  <div className="narrio-muted">{chapter?.title ?? "Chapter"}</div>
                  <div className="narrio-muted">Tag: {bookmark.tag}</div>
                </Link>
              );
            })
          ) : (
            <div className="narrio-list-item">No bookmarks yet.</div>
          )}
        </div>
      </SectionCard>
    </Stack>
  );
}
