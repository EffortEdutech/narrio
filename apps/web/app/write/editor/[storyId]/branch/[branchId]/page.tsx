import Link from "next/link";
import { redirect } from "next/navigation";
import {
  getBranchById,
  getBranchesByStoryId,
  getChapterById,
  getChaptersByBranchId,
  getCurrentVersionByChapterId,
  getStoryById,
  getVersionHistory
} from "@narrio/api";
import {
  Field,
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
import { toggleChapterPublishAction } from "../../../../settings_actions";
import {
  aiContinueChapterAction,
  aiRewriteChapterAction,
  aiSuggestChapterTitleAction,
  aiSummarizeChapterAction
} from "../../../../ai_actions";

export default async function BranchEditorPage(props: {
  params: Promise<{ storyId: string; branchId: string }>;
  searchParams?: Promise<{ chapter?: string }>;
}) {
  const params = await props.params;
  const searchParams = (await props.searchParams) ?? {};
  const { supabase, user } = await requireUser();

  const story = await getStoryById(supabase, params.storyId);
  if (story.author_id !== user.id) redirect("/write");

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
        eyebrow="Editor"
        title={`${story.title} — ${branch.name}`}
        description={branch.description ?? "Write, version, branch, publish, and use AI from here."}
        actions={
          <div className="narrio-nav">
            <Link href={`/write/settings/${story.id}`}>Story settings</Link>
            <Link href={`/story/${story.id}/branch/${branch.id}`}>Public branch view</Link>
          </div>
        }
      />

      <TwoColumn>
        <div className="narrio-stack">
          <SectionCard title="Branch chapters" description="Choose a chapter to edit in this branch.">
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
                    <div className="narrio-muted">
                      {chapter.is_published ? "Published" : "Draft"} · Branch {branch.visibility}
                    </div>
                  </Link>
                ))
              ) : (
                <div className="narrio-list-item">No chapters in this branch yet.</div>
              )}
            </div>
          </SectionCard>

          <SectionCard title="Create chapter" description="Adds a new chapter with an initial version.">
            <form action={createChapterAction} className="narrio-form">
              <input type="hidden" name="storyId" value={story.id} />
              <input type="hidden" name="branchId" value={branch.id} />
              <Field label="Chapter title" name="title" placeholder="Arrival at the hidden harbor" />
              <TextAreaField label="Summary" name="summary" rows={3} placeholder="Optional chapter summary..." />
              <PrimaryButton>Create chapter</PrimaryButton>
            </form>
          </SectionCard>

          <SectionCard title="Create branch" description="Clone the current branch state into a new path.">
            <form action={createBranchAction} className="narrio-form">
              <input type="hidden" name="storyId" value={story.id} />
              <input type="hidden" name="sourceBranchId" value={branch.id} />
              <Field label="Branch name" name="name" placeholder="What if the captain never returned?" />
              <Field label="Branch slug" name="slug" placeholder="captain-never-returned" />
              <TextAreaField label="Description" name="description" rows={3} placeholder="Explain this alternate path..." />
              <PrimaryButton>Create branch from this branch</PrimaryButton>
            </form>
          </SectionCard>

          <SectionCard title="Story branches" description="Navigate between sibling branches.">
            <div className="narrio-list">
              {branches.map((branchItem) => (
                <Link
                  key={branchItem.id}
                  href={`/write/editor/${story.id}/branch/${branchItem.id}`}
                  className="narrio-list-item"
                >
                  <strong>{branchItem.name}</strong>
                  <div className="narrio-muted">
                    {branchItem.description ?? "No description yet."}
                  </div>
                  <div className="narrio-muted">Visibility: {branchItem.visibility}</div>
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
                description="Each save creates a new chapter version and marks it current."
              >
                <div className="narrio-nav" style={{ marginBottom: 14 }}>
                  <form action={toggleChapterPublishAction}>
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <input type="hidden" name="chapterId" value={selectedChapter.id} />
                    <input
                      type="hidden"
                      name="nextPublishedState"
                      value={selectedChapter.is_published ? "false" : "true"}
                    />
                    <PrimaryButton>
                      {selectedChapter.is_published ? "Unpublish chapter" : "Publish chapter"}
                    </PrimaryButton>
                  </form>
                </div>

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
                    label="Commit message"
                    name="commitMessage"
                    defaultValue={currentVersion.commit_message ?? ""}
                    placeholder="Expanded tension in the harbor scene"
                  />
                  <PrimaryButton>Save new version</PrimaryButton>
                </form>
              </SectionCard>

              <SectionCard
                title="AI writer assist"
                description="These actions create new chapter versions. Without OPENAI_API_KEY, mock mode is used."
              >
                <div className="narrio-list">
                  <form action={aiContinueChapterAction} className="narrio-list-item">
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <input type="hidden" name="chapterId" value={selectedChapter.id} />
                    <strong>AI continue chapter</strong>
                    <div className="narrio-muted">Appends a continuation to the current chapter content.</div>
                    <div style={{ height: 12 }} />
                    <PrimaryButton>Run continue</PrimaryButton>
                  </form>

                  <form action={aiRewriteChapterAction} className="narrio-list-item">
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <input type="hidden" name="chapterId" value={selectedChapter.id} />
                    <strong>AI rewrite chapter</strong>
                    <div className="narrio-muted">Creates a rewritten version of the full chapter.</div>
                    <div style={{ height: 12 }} />
                    <PrimaryButton>Run rewrite</PrimaryButton>
                  </form>

                  <form action={aiSummarizeChapterAction} className="narrio-list-item">
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <input type="hidden" name="chapterId" value={selectedChapter.id} />
                    <strong>AI summarize chapter</strong>
                    <div className="narrio-muted">Generates a better summary and saves it as a new version.</div>
                    <div style={{ height: 12 }} />
                    <PrimaryButton>Run summarize</PrimaryButton>
                  </form>

                  <form action={aiSuggestChapterTitleAction} className="narrio-list-item">
                    <input type="hidden" name="storyId" value={story.id} />
                    <input type="hidden" name="branchId" value={branch.id} />
                    <input type="hidden" name="chapterId" value={selectedChapter.id} />
                    <strong>AI suggest title</strong>
                    <div className="narrio-muted">Suggests a stronger chapter title and saves it as a new version.</div>
                    <div style={{ height: 12 }} />
                    <PrimaryButton>Run title suggestion</PrimaryButton>
                  </form>
                </div>
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
                        {version.commit_message ?? "No commit message"} · {version.source}
                      </div>
                      <div className="narrio-divider" />
                      <div className="narrio-muted">{version.excerpt ?? "No excerpt."}</div>
                      <div style={{ marginTop: 12 }}>
                        <form action={restoreVersionAction}>
                          <input type="hidden" name="storyId" value={story.id} />
                          <input type="hidden" name="branchId" value={branch.id} />
                          <input type="hidden" name="chapterId" value={selectedChapter.id} />
                          <input type="hidden" name="versionId" value={version.id} />
                          <PrimaryButton>Restore from this version</PrimaryButton>
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
              description="Create the first chapter in this branch to start writing."
            />
          )}
        </div>
      </TwoColumn>
    </Stack>
  );
}
