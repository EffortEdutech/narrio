import Link from "next/link";
import {
  getBranchById,
  getBranchesByStoryId,
  getChapterById,
  getChaptersByBranchId,
  getCurrentVersionByChapterId,
  getStoryById,
  getVersionHistory
} from "@narrio/api";
import { BRAND } from "@narrio/config";
import {
  Field,
  InlineMeta,
  PageHeader,
  PrimaryButton,
  SectionCard,
  Stack,
  TextAreaField,
  TwoColumn
} from "@narrio/ui";
import { requireUser } from "../../../../../../lib/auth";
import {
  createBranchAction,
  createChapterAction,
  restoreVersionAction,
  saveChapterVersionAction
} from "../../../../actions";

export default async function BranchEditorPage(props: {
  params: Promise<{ storyId: string; branchId: string }>;
  searchParams?: Promise<{ chapter?: string }>;
}) {
  const params = await props.params;
  const searchParams = (await props.searchParams) ?? {};
  const { supabase } = await requireUser();

  const story = await getStoryById(supabase, params.storyId);
  const branch = await getBranchById(supabase, params.branchId);
  const branches = await getBranchesByStoryId(supabase, params.storyId);
  const chapters = await getChaptersByBranchId(supabase, params.branchId);

  const selectedChapterId = searchParams.chapter ?? chapters[0]?.id ?? null;
  const selectedChapter = selectedChapterId ? await getChapterById(supabase, selectedChapterId) : null;
  const currentVersion = selectedChapterId
    ? await getCurrentVersionByChapterId(supabase, selectedChapterId)
    : null;
  const versionHistory = selectedChapterId ? await getVersionHistory(supabase, selectedChapterId) : [];

  return (
    <Stack>
      <PageHeader
        eyebrow="Story Studio"
        title={`${story.title} — ${branch.name}`}
        description={branch.description ?? "Write, version, and fork this timeline into new paths."}
        actions={
          <div className="narrio-nav">
            <Link href={`/write/publish/${story.id}`}>Release Center</Link>
            <Link href={`/story/${story.id}/branch/${branch.id}`}>Reader preview</Link>
          </div>
        }
      />

      <SectionCard title="Release snapshot" description="Release is controlled separately from writing, so unfinished paths can stay private.">
        <div className="narrio-publish-snapshot">
          <InlineMeta>
            <span>Universe: {story.status}</span>
            <span>Universe visibility: {story.visibility}</span>
            <span>Timeline visibility: {branch.visibility}</span>
            <span>{chapters.filter((chapter) => chapter.is_published).length}/{chapters.length} chapters released</span>
          </InlineMeta>
          <Link className="narrio-button-secondary" href={`/write/publish/${story.id}`}>
            Open Release Center
          </Link>
        </div>
      </SectionCard>

      <TwoColumn>
        <div className="narrio-stack">
          <SectionCard title="Timeline chapters" description="Choose a chapter to edit in this timeline.">
            <div className="narrio-list">
              {chapters.length ? (
                chapters.map((chapter) => (
                  <Link
                    key={chapter.id}
                    className="narrio-list-item"
                    href={`/write/editor/${story.id}/branch/${branch.id}?chapter=${chapter.id}`}
                  >
                    <strong>
                      Chapter {chapter.chapter_number}: {chapter.title}
                    </strong>
                    <div className="narrio-muted">{chapter.summary ?? "No summary yet."}</div>
                    <InlineMeta>
                      <span>{chapter.is_published ? "Released" : "Draft"}</span>
                    </InlineMeta>
                  </Link>
                ))
              ) : (
                <div className="narrio-list-item">No chapters in this timeline yet.</div>
              )}
            </div>
          </SectionCard>

          <SectionCard title="Add chapter" description="Adds a new chapter with an initial version.">
            <form action={createChapterAction} className="narrio-form">
              <input type="hidden" name="storyId" value={story.id} />
              <input type="hidden" name="branchId" value={branch.id} />
              <Field label="Chapter title" name="title" placeholder="Arrival at the hidden harbor" />
              <TextAreaField label="Summary" name="summary" rows={3} placeholder="Optional chapter summary..." />
              <PrimaryButton>Add chapter</PrimaryButton>
            </form>
          </SectionCard>

          <SectionCard title="Fork this timeline" description={`Create a new path with ${BRAND.engine}.`}>
            <form action={createBranchAction} className="narrio-form">
              <input type="hidden" name="storyId" value={story.id} />
              <input type="hidden" name="sourceBranchId" value={branch.id} />
              <Field label="New timeline name" name="name" placeholder="What if the captain never returned?" />
              <Field label="Timeline slug" name="slug" placeholder="captain-never-returned" />
              <TextAreaField label="Why is this timeline different?" name="description" rows={3} placeholder="Explain this alternate path..." />
              <PrimaryButton>Create fork</PrimaryButton>
            </form>
          </SectionCard>

          <SectionCard title="Universe timelines" description="Navigate between alternate paths in this universe.">
            <div className="narrio-list">
              {branches.map((branchItem) => (
                <Link
                  key={branchItem.id}
                  href={`/write/editor/${story.id}/branch/${branchItem.id}`}
                  className="narrio-list-item"
                >
                  <strong>{branchItem.name}</strong>
                  <div className="narrio-muted">{branchItem.description ?? "No description yet."}</div>
                  <InlineMeta>
                    <span>{branchItem.branch_type}</span>
                    <span>{branchItem.visibility}</span>
                  </InlineMeta>
                </Link>
              ))}
            </div>
          </SectionCard>
        </div>

        <div className="narrio-stack">
          {selectedChapter && currentVersion ? (
            <>
              <SectionCard
                title={`Editing Chapter ${selectedChapter.chapter_number}`}
                description="Each save creates a new version and marks it current. Release is controlled from the Release Center."
              >
                <form action={saveChapterVersionAction} className="narrio-form">
                  <input type="hidden" name="storyId" value={story.id} />
                  <input type="hidden" name="branchId" value={branch.id} />
                  <input type="hidden" name="chapterId" value={selectedChapter.id} />
                  <Field label="Chapter title" name="title" defaultValue={selectedChapter.title} />
                  <TextAreaField label="Summary" name="summary" rows={3} defaultValue={selectedChapter.summary ?? ""} />
                  <TextAreaField
                    label="Markdown content"
                    name="contentMd"
                    rows={18}
                    defaultValue={currentVersion.content_md}
                  />
                  <Field
                    label="What changed?"
                    name="commitMessage"
                    defaultValue={currentVersion.commit_message ?? ""}
                    placeholder="Expanded tension in the harbor scene"
                  />
                  <PrimaryButton>Save version</PrimaryButton>
                </form>
              </SectionCard>

              <SectionCard
                title="Version history"
                description="Restore creates a new current version based on the selected historical version."
              >
                <div className="narrio-list">
                  {versionHistory.map((version) => (
                    <div key={version.id} className="narrio-list-item">
                      <strong>
                        Version {version.version_number} {version.is_current ? "· current" : ""}
                      </strong>
                      <div className="narrio-muted">
                        {version.commit_message ?? "No save note"} · {version.source}
                      </div>
                      <div className="narrio-divider" />
                      <div className="narrio-muted">{version.excerpt ?? "No excerpt."}</div>
                      <div style={{ marginTop: 12 }}>
                        <form action={restoreVersionAction}>
                          <input type="hidden" name="storyId" value={story.id} />
                          <input type="hidden" name="branchId" value={branch.id} />
                          <input type="hidden" name="chapterId" value={selectedChapter.id} />
                          <input type="hidden" name="versionId" value={version.id} />
                          <PrimaryButton>Restore this version</PrimaryButton>
                        </form>
                      </div>
                    </div>
                  ))}
                </div>
              </SectionCard>
            </>
          ) : (
            <SectionCard
              title="No chapter selected"
              description="Add the first chapter in this timeline to start writing."
            />
          )}
        </div>
      </TwoColumn>
    </Stack>
  );
}
