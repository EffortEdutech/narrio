import { Field, PageHeader, PrimaryButton, SectionCard, Stack, TextAreaField } from "@narrio/ui";
import { createStoryAction } from "../actions";

export default function NewStoryPage() {
  return (
    <Stack>
      <PageHeader
        eyebrow="Create"
        title="Create a new universe"
        description="This creates the universe shell and auto-generates its main timeline."
      />

      <SectionCard title="Universe details" description="Keep it simple for Sprint 2.">
        <form action={createStoryAction} className="narrio-form">
          <Field label="Title" name="title" placeholder="The City Beneath the Tide" />
          <Field label="Slug" name="slug" placeholder="the-city-beneath-the-tide" />
          <TextAreaField label="Synopsis" name="synopsis" rows={5} placeholder="Optional public synopsis..." />
          <PrimaryButton>Create universe</PrimaryButton>
        </form>
      </SectionCard>
    </Stack>
  );
}
