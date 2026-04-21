import { Field, PageHeader, PrimaryButton, SectionCard, Stack, TextAreaField } from "@narrio/ui";
import { createStoryAction } from "../actions";

export default function NewStoryPage() {
  return (
    <Stack>
      <PageHeader
        eyebrow="Create"
        title="Create a new story"
        description="This creates the story and auto-generates its main branch."
      />

      <SectionCard title="Story details" description="Keep it simple for Sprint 2.">
        <form action={createStoryAction} className="narrio-form">
          <Field label="Title" name="title" placeholder="The City Beneath the Tide" />
          <Field label="Slug" name="slug" placeholder="the-city-beneath-the-tide" />
          <TextAreaField label="Synopsis" name="synopsis" rows={5} placeholder="Optional public synopsis..." />
          <PrimaryButton>Create story</PrimaryButton>
        </form>
      </SectionCard>
    </Stack>
  );
}
