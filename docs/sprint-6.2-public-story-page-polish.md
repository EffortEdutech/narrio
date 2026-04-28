# Sprint 6.2 — Public Story Page Polish

## Status

Patch prepared as a local downloadable pack.

## Objective

Improve the reader-facing public story page after Sprint 6.1 publishing controls are in place.

Sprint 6.1 lets the writer decide what becomes public. Sprint 6.2 improves what a reader sees once a story is available by direct link or public discovery.

## Scope

### Included

- Replace the plain metadata-heavy `/story/[storyId]` page with a polished story landing page.
- Add a story hero section with title, synopsis, publication state, and reader actions.
- Add a Start Reading path that prefers the first published chapter on the main timeline.
- Add a Latest Signal card for the newest published chapter.
- Add timeline cards with chapter previews.
- Add writer profile and owner-only workflow links.
- Add `getPublicStoryOverview()` in `@narrio/api`.
- Use a route-level CSS module to avoid overwriting global styling.

### Excluded

- No database migration.
- No publishing logic changes.
- No discovery ranking.
- No comments/reviews.
- No cover image upload flow.

## Reader experience

The story page should answer five reader questions quickly:

1. What is this story?
2. Who wrote it?
3. Where do I start?
4. What timelines can I explore?
5. Can this universe be forked?

## Writer experience

When the signed-in viewer is the story author, the page shows:

- Publish Center link.
- Story Studio link.
- Draft chapter counts where relevant.

This keeps the public page useful as a writer preview surface.

## Technical notes

The new API helper intentionally performs simple table queries instead of nested PostgREST relationship joins. This keeps the implementation easier to debug with the current Supabase RLS model.

The page filters visible chapters by visible timeline IDs as a defensive check, so private timeline content is not shown in the story overview even if older local RLS policies are still present.

## QA checklist

- [ ] Story page loads for a published public story.
- [ ] Story page loads for a published unlisted story by direct link after Sprint 6.1 RLS migration.
- [ ] Private draft story loads for author only.
- [ ] Start Reading opens the first published chapter on the main timeline.
- [ ] Timeline cards show correct chapter counts.
- [ ] Owner actions appear only to the author.
- [ ] Guest users see sign-in CTA instead of follow form.
- [ ] Typecheck passes.
- [ ] Build passes.
