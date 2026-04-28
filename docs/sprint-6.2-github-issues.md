# Sprint 6.2 — GitHub Issues Breakdown

## Issue 1 — Add public story overview API

Create `packages/api/src/public-story.ts` with a helper that returns story, author, visible timelines, visible chapters, start chapter, latest chapter, and summary counts.

Acceptance criteria:

- Uses existing tables only.
- Respects current RLS.
- Does defensive filtering by visible timeline IDs.
- Exports from `packages/api/src/index.ts`.

## Issue 2 — Redesign `/story/[storyId]`

Replace the current metadata-heavy reader page with a polished public landing page.

Acceptance criteria:

- Hero section shows story title, synopsis, visibility state, and fork state.
- Start Reading CTA appears when a readable chapter exists.
- Explore Timelines remains available.
- Follow action remains available for signed-in users.
- Guest users see sign-in CTA.

## Issue 3 — Add timeline card reading previews

Display timeline cards on the public story page.

Acceptance criteria:

- Each timeline card shows type, visibility, readable count, published count, and first chapter preview.
- Cards link to timeline page.
- Cards link to first readable chapter when available.

## Issue 4 — Add writer preview actions

Show writer-only actions when the story author opens the page.

Acceptance criteria:

- Publish Center link appears only for author.
- Story Studio link appears only for author when main branch exists.
- Draft counts appear only when relevant to author preview.

## Issue 5 — QA public/private visibility

Run manual QA across published public, published unlisted, draft/private, author, signed-in reader, and guest states.
