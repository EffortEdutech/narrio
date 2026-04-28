import type { Database, NarrioSupabaseClient } from "@narrio/db";
import { getStoryById } from "./stories";

type StoryBranch = Database["public"]["Tables"]["story_branches"]["Row"];
type Story = Database["public"]["Tables"]["stories"]["Row"];
type Chapter = Database["public"]["Tables"]["chapters"]["Row"];

export type TimelineExplorerChapter = Pick<
  Chapter,
  "id" | "branch_id" | "chapter_number" | "title" | "summary" | "is_published" | "updated_at"
>;

export type TimelineExplorerBranch = StoryBranch & {
  depth: number;
  chapter_count: number;
  children_count: number;
  is_main: boolean;
  latest_chapter: TimelineExplorerChapter | null;
  parent_branch_name: string | null;
  path_label: string;
};

export type TimelineExplorer = {
  story: Story;
  branches: TimelineExplorerBranch[];
};

function orderChapters(chapters: TimelineExplorerChapter[]) {
  return [...chapters].sort((a, b) => a.chapter_number - b.chapter_number);
}

export async function getTimelineExplorerByStoryId(
  client: NarrioSupabaseClient,
  storyId: string
): Promise<TimelineExplorer> {
  const story = await getStoryById(client, storyId);

  const { data: branches, error: branchesError } = await client
    .from("story_branches")
    .select("*")
    .eq("story_id", storyId)
    .order("created_at", { ascending: true });

  if (branchesError) throw branchesError;

  const { data: chapters, error: chaptersError } = await client
    .from("chapters")
    .select("id, branch_id, chapter_number, title, summary, is_published, updated_at")
    .eq("story_id", storyId)
    .order("chapter_number", { ascending: true });

  if (chaptersError) throw chaptersError;

  const safeBranches = branches ?? [];
  const safeChapters = (chapters ?? []) as TimelineExplorerChapter[];

  const branchById = new Map<string, StoryBranch>();
  for (const branch of safeBranches) {
    branchById.set(branch.id, branch);
  }
  const chaptersByBranch = new Map<string, TimelineExplorerChapter[]>();
  const childrenCountByBranch = new Map<string, number>();
  const depthByBranch = new Map<string, number>();

  for (const chapter of safeChapters) {
    const current = chaptersByBranch.get(chapter.branch_id) ?? [];
    current.push(chapter);
    chaptersByBranch.set(chapter.branch_id, current);
  }

  for (const branch of safeBranches) {
    if (!branch.parent_branch_id) continue;
    childrenCountByBranch.set(
      branch.parent_branch_id,
      (childrenCountByBranch.get(branch.parent_branch_id) ?? 0) + 1
    );
  }

  function getDepth(branch: StoryBranch, seen = new Set<string>()): number {
    const cached = depthByBranch.get(branch.id);
    if (typeof cached === "number") return cached;

    if (!branch.parent_branch_id || seen.has(branch.id)) {
      depthByBranch.set(branch.id, 0);
      return 0;
    }

    const parent = branchById.get(branch.parent_branch_id);
    if (!parent) {
      depthByBranch.set(branch.id, 0);
      return 0;
    }

    seen.add(branch.id);
    const depth = getDepth(parent, seen) + 1;
    depthByBranch.set(branch.id, depth);
    return depth;
  }

  const explorerBranches = safeBranches.map((branch) => {
    const branchChapters = orderChapters(chaptersByBranch.get(branch.id) ?? []);
    const latestChapter = branchChapters.at(-1) ?? null;
    const parentBranch = branch.parent_branch_id ? branchById.get(branch.parent_branch_id) : null;
    const isMain = branch.id === story.main_branch_id || branch.branch_type === "main";

    return {
      ...branch,
      depth: getDepth(branch),
      chapter_count: branchChapters.length,
      children_count: childrenCountByBranch.get(branch.id) ?? 0,
      is_main: isMain,
      latest_chapter: latestChapter,
      parent_branch_name: parentBranch?.name ?? null,
      path_label: isMain
        ? "Root timeline"
        : parentBranch
          ? `Forked from ${parentBranch.name}`
          : "Standalone timeline"
    } satisfies TimelineExplorerBranch;
  });

  explorerBranches.sort((a, b) => {
    if (a.is_main && !b.is_main) return -1;
    if (!a.is_main && b.is_main) return 1;
    if (a.depth !== b.depth) return a.depth - b.depth;
    return a.created_at.localeCompare(b.created_at);
  });

  return {
    story,
    branches: explorerBranches
  };
}
