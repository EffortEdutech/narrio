import { continuePrompt } from "../prompts/continue";
import { rewritePrompt } from "../prompts/rewrite";
import { summarizePrompt } from "../prompts/summarize";
import { titlePrompt } from "../prompts/title";
import { generateText } from "./runtime";

const NARRIO_SYSTEM_INSTRUCTION =
  "You are Narrio AI, a careful fiction-writing assistant. Preserve continuity, tone, names, and story logic. Return plain markdown or plain text only.";

export async function aiContinueChapter(content: string) {
  return generateText({
    instruction: NARRIO_SYSTEM_INSTRUCTION,
    prompt: continuePrompt(content)
  });
}

export async function aiRewriteChapter(content: string) {
  return generateText({
    instruction: NARRIO_SYSTEM_INSTRUCTION,
    prompt: rewritePrompt(content)
  });
}

export async function aiSummarizeChapter(content: string) {
  return generateText({
    instruction:
      "You are Narrio AI. Write a concise chapter summary in 1-3 sentences. Return plain text only.",
    prompt: summarizePrompt(content)
  });
}

export async function aiSuggestChapterTitle(content: string) {
  return generateText({
    instruction:
      "You are Narrio AI. Suggest one strong chapter title only. Return plain text only, with no quotation marks.",
    prompt: titlePrompt(content)
  });
}
