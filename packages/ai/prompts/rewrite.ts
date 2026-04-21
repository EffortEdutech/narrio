export function rewritePrompt(input: string) {
  return `Rewrite the following chapter while preserving intent and continuity:\n\n${input}`;
}
