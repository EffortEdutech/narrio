# Sprint 6.3 GitHub Issues / Task Breakdown

## Issue 1 — Add library discovery API

**Files**

- `packages/api/src/discovery.ts`
- `packages/api/src/index.ts`

**Acceptance criteria**

- Returns public published stories only.
- Joins profiles, branches, and chapters using flat queries.
- Avoids nested PostgREST embeds.
- Computes timeline and chapter counts.
- Supports search, sort, and filters.

## Issue 2 — Upgrade `/library` UI

**Files**

- `apps/web/app/library/page.tsx`
- `apps/web/app/library/library.module.css`

**Acceptance criteria**

- Search form works through URL query params.
- Sorting changes results.
- Path and ForkCraft filters change results.
- Cards link to chapter, story page, and timeline explorer.
- Empty state is useful.

## Issue 3 — QA discovery against publishing flow

**Acceptance criteria**

- Draft stories do not appear.
- Private stories do not appear.
- Public published stories appear.
- Unpublished chapters do not appear as readable starts.
- ForkCraft-enabled stories can be filtered.
