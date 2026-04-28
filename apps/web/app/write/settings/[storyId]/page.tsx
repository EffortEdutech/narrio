import { getBranchesByStoryId, getStoryById } from "@narrio/api";
import {
  Field,
  PageHeader,
  PrimaryButton,
  SectionCard,
  Stack,
  TextAreaField
} from "@narrio/ui";
import { redirect } from "next/navigation";
import { requireUser } from "../../../../lib/auth";
import { saveStorySettingsAction, updateBranchVisibilityAction } from "../../settings_actions";

export default async function StorySettingsPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const { supabase, user } = await requireUser();
  const story = await getStoryById(supabase, storyId);
  if (story.author_id !== user.id) redirect("/write");
  const branches = await getBranchesByStoryId(supabase, storyId);

  return (
    <Stack>
      <PageHeader
        eyebrow="Publishing"
        title={`Settings — ${story.title}`}
        description="Manage story publishing and visibility."
      />

      <SectionCard title="Story settings" description="Controls for story metadata and publication status.">
        <form action={saveStorySettingsAction} className="narrio-form">
          <input type="hidden" name="storyId" value={story.id} />
          <Field label="Title" name="title" defaultValue={story.title} />
          <Field label="Slug" name="slug" defaultValue={story.slug} />
          <TextAreaField label="Synopsis" name="synopsis" rows={4} defaultValue={story.synopsis ?? ""} />
          <Field label="Cover URL" name="coverUrl" defaultValue={story.cover_url ?? ""} placeholder="https://..." />

          <label className="narrio-field">
            <span>Status</span>
            <select className="narrio-select" name="status" defaultValue={story.status}>
              <option value="draft">draft</option>
              <option value="published">published</option>
              <option value="archived">archived</option>
            </select>
          </label>

          <label className="narrio-field">
            <span>Visibility</span>
            <select className="narrio-select" name="visibility" defaultValue={story.visibility}>
              <option value="public">public</option>
              <option value="unlisted">unlisted</option>
              <option value="private">private</option>
            </select>
          </label>

          <label className="narrio-field">
            <span>Allow forks</span>
            <select className="narrio-select" name="allowForks" defaultValue={story.allow_forks ? "true" : "false"}>
              <option value="true">true</option>
              <option value="false">false</option>
            </select>
          </label>

          <PrimaryButton>Save story settings</PrimaryButton>
        </form>
      </SectionCard>

      <SectionCard title="Branch visibility" description="Control which branches are public.">
        <div className="narrio-list">
          {branches.map((branch) => (
            <form key={branch.id} action={updateBranchVisibilityAction} className="narrio-list-item">
              <input type="hidden" name="storyId" value={story.id} />
              <input type="hidden" name="branchId" value={branch.id} />
              <strong>{branch.name}</strong>
              <div className="narrio-muted">{branch.description ?? "No description yet."}</div>
              <div style={{ height: 10 }} />
              <label className="narrio-field">
                <span>Visibility</span>
                <select className="narrio-select" name="visibility" defaultValue={branch.visibility}>
                  <option value="public">public</option>
                  <option value="unlisted">unlisted</option>
                  <option value="private">private</option>
                </select>
              </label>
              <TextAreaField label="Description" name="description" rows={3} defaultValue={branch.description ?? ""} />
              <PrimaryButton>Save branch settings</PrimaryButton>
            </form>
          ))}
        </div>
      </SectionCard>
    </Stack>
  );
}
