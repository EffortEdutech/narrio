import { getChapterById, getCurrentVersionByChapterId, getStoryById } from "@narrio/api";
import { InlineMeta, PageHeader, SectionCard, Stack } from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";

export default async function ChapterReaderPage(props: {
  params: Promise<{ storyId: string; chapterId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const chapter = await getChapterById(supabase, params.chapterId);
  const currentVersion = await getCurrentVersionByChapterId(supabase, params.chapterId);

  return (
    <Stack>
      <PageHeader
        eyebrow="Reader"
        title={`${story.title} — Chapter ${chapter.chapter_number}`}
        description={chapter.title}
      />

      <SectionCard title="Current version" description="Reader sees the current version content.">
        <InlineMeta>
          <span>Version {currentVersion.version_number}</span>
          <span>Source: {currentVersion.source}</span>
          <span>Commit: {currentVersion.commit_message ?? "No commit message"}</span>
        </InlineMeta>
        <div className="narrio-code" style={{ marginTop: 16 }}>
          {currentVersion.content_md}
        </div>
      </SectionCard>
    </Stack>
  );
}
