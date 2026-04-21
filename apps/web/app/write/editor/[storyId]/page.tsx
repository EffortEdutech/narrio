import { redirect } from "next/navigation";
import { getStoryById } from "@narrio/api";
import { requireUser } from "../../../../lib/auth";

export default async function StoryEditorIndexPage(props: {
  params: Promise<{ storyId: string }>;
}) {
  const { storyId } = await props.params;
  const { supabase } = await requireUser();
  const story = await getStoryById(supabase, storyId);

  if (!story.main_branch_id) {
    redirect("/write");
  }

  redirect(`/write/editor/${story.id}/branch/${story.main_branch_id}`);
}
