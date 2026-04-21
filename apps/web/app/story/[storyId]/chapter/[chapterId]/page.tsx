import { getChapterById, getCurrentVersionByChapterId, getStoryById } from "@narrio/api";
import { PageHeader, SectionCard } from "@narrio/ui";
import { createClient } from "../../../../../lib/supabase/server";

export default async function ChapterPage(props: {
  params: Promise<{ storyId: string; chapterId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();

  const story = await getStoryById(supabase, params.storyId);
  const chapter = await getChapterById(supabase, params.chapterId);
  const version = await getCurrentVersionByChapterId(supabase, params.chapterId);

  return (
    <div className="narrio-stack">
      <PageHeader
        eyebrow="Reader"
        title={`${story.title} — ${chapter.title}`}
        description={`Current version: v${version.version_number}`}
      />

      <SectionCard
        title="Excerpt"
        description={version.excerpt ?? "No excerpt available for this version."}
      >
        <div className="narrio-code">{version.content_md}</div>
      </SectionCard>
    </div>
  );
}
