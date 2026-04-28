import Link from "next/link";
import { getForkSourceByChapterId } from "@narrio/api";
import {
  Field,
  InlineMeta,
  PageHeader,
  PrimaryButton,
  SectionCard,
  Stack,
  TextAreaField
} from "@narrio/ui";
import { createClient } from "../../../../../../lib/supabase/server";
import { forkFromChapterAction } from "../../../../../reader/fork_actions";

function makeDefaultSlug(value: string) {
  return value
    .toLowerCase()
    .trim()
    .replace(/['"]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80);
}

export default async function ForkFromChapterPage(props: {
  params: Promise<{ storyId: string; chapterId: string }>;
}) {
  const params = await props.params;
  const supabase = await createClient();
  const source = await getForkSourceByChapterId(supabase, params.storyId, params.chapterId);

  const {
    data: { user }
  } = await supabase.auth.getUser();

  const canFork =
    Boolean(source.story.allow_forks) ||
    user?.id === source.story.author_id ||
    user?.id === source.branch.created_by;

  const defaultName = `${source.branch.name} — fork from Chapter ${source.chapter.chapter_number}`;
  const defaultSlug = makeDefaultSlug(defaultName);

  return (
    <Stack>
      <PageHeader
        eyebrow="ForkCraft"
        title={`Fork from Chapter ${source.chapter.chapter_number}`}
        description="Create a new timeline from this exact story point."
        actions={
          <div className="narrio-nav">
            <Link className="narrio-button-secondary" href={`/story/${source.story.id}/chapter/${source.chapter.id}`}>
              Back to chapter
            </Link>
            <Link className="narrio-button-secondary" href={`/story/${source.story.id}/timelines`}>
              Explore timelines
            </Link>
          </div>
        }
      />

      <SectionCard
        title="Fork source"
        description="Narrio will copy the readable path up to this chapter into your new timeline."
      >
        <div className="narrio-fork-preview">
          <div>
            <div className="narrio-eyebrow">Story</div>
            <strong>{source.story.title}</strong>
          </div>
          <div>
            <div className="narrio-eyebrow">Source timeline</div>
            <strong>{source.branch.name}</strong>
          </div>
          <div>
            <div className="narrio-eyebrow">Fork point</div>
            <strong>
              Chapter {source.chapter.chapter_number}: {source.chapter.title}
            </strong>
          </div>
        </div>

        <div style={{ height: 14 }} />

        <InlineMeta>
          <span>{source.branch.branch_type === "main" ? "Root timeline" : `Timeline type: ${source.branch.branch_type}`}</span>
          <span>{source.chapter.is_published ? "Published chapter" : "Draft chapter"}</span>
          <span>Current version {source.currentVersion.version_number}</span>
        </InlineMeta>
      </SectionCard>

      {!user ? (
        <SectionCard
          title="Sign in to create your timeline"
          description="You can read this chapter now. Sign in when you are ready to create your own path."
        >
          <Link className="narrio-button" href="/signin">
            Sign in to fork
          </Link>
        </SectionCard>
      ) : !canFork ? (
        <SectionCard
          title="ForkCraft is disabled"
          description="This story is not currently open for reader-created timelines."
        />
      ) : (
        <SectionCard
          title="New timeline"
          description="This creates a new branch with chapters up to the fork point copied as your starting context."
        >
          <form action={forkFromChapterAction} className="narrio-form">
            <input type="hidden" name="storyId" value={source.story.id} />
            <input type="hidden" name="sourceBranchId" value={source.branch.id} />
            <input type="hidden" name="sourceChapterId" value={source.chapter.id} />

            <Field
              label="Timeline name"
              name="name"
              defaultValue={defaultName}
              placeholder="What if the captain chose the storm?"
            />

            <Field
              label="Timeline slug"
              name="slug"
              defaultValue={defaultSlug}
              placeholder="captain-chose-the-storm"
            />

            <TextAreaField
              label="Why does this timeline split?"
              name="description"
              rows={4}
              placeholder="Describe the alternate choice, tone, or ending you want to explore..."
            />

            <label className="narrio-field">
              <span>Visibility</span>
              <select className="narrio-select" name="visibility" defaultValue="private">
                <option value="private">Private draft</option>
                <option value="public">Public timeline</option>
              </select>
            </label>

            <div className="narrio-callout">
              Your new timeline will begin with Chapters 1–{source.chapter.chapter_number}. Continue writing from this
              point in Story Studio.
            </div>

            <PrimaryButton>Create fork from chapter</PrimaryButton>
          </form>
        </SectionCard>
      )}
    </Stack>
  );
}
