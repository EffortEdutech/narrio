# Sprint 5 hotfix v2

This removes the embedded profile relation from the chapter comments query.

## Replace
- `packages/api/src/comments.ts`
- `apps/web/app/story/[storyId]/chapter/[chapterId]/page.tsx`

## Then
Restart `pnpm dev`.

No SQL change is required for this hotfix.
