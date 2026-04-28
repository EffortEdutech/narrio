# Narrio Sprint 6.4 + 6.5 — Public Profile & Launch Readiness

## Scope

This combined patch continues Sprint 6 after Library Discovery.

- Sprint 6.4: upgrades `/u/[userId]` into a real public writer profile.
- Sprint 6.5: adds branded launch states and a small launch readiness route.

## Sprint 6.4 — Public Writer Profile

### Added

- `packages/api/src/public-profile.ts`
  - Public-safe writer profile query.
  - Published public stories only.
  - Public timeline counts.
  - Published chapter counts.
  - Featured story selection based on latest public signal.

- `apps/web/app/u/[userId]/page.tsx`
  - Creator hero.
  - Avatar / initials block.
  - Public stats.
  - Featured universe panel.
  - Published universe cards.
  - Writer signal side panel.

- `apps/web/app/u/[userId]/profile.module.css`
  - Visual styling for the new public writer profile.

### Updated

- `packages/api/src/index.ts`
  - Exports the new public profile API.

- `apps/web/app/library/page.tsx`
  - Library author names now link to `/u/[authorId]`.

- `apps/web/app/library/library.module.css`
  - Adds author link styling.

## Sprint 6.5 — Launch Readiness

### Added

- `apps/web/app/not-found.tsx`
  - Branded 404 / lost timeline screen.

- `apps/web/app/error.tsx`
  - Branded recoverable error screen.

- `apps/web/app/loading.tsx`
  - Branded loading state.

- `apps/web/app/status.module.css`
  - Shared status-screen CSS.

- `apps/web/app/launch/page.tsx`
  - Internal launch readiness checkpoint route.

- `apps/web/app/launch/launch.module.css`
  - Launch checkpoint styling.

## No database migration

This patch does not require a Supabase migration. It only reads existing public-safe data:

- `profiles`
- `stories`
- `story_branches`
- `chapters`

Follower counts are intentionally not exposed yet because current RLS only allows users to manage their own follows.

## Manual QA flow

1. Run the web app.
2. Open `/library`.
3. Confirm author name links appear on story cards.
4. Click an author link and confirm `/u/[userId]` loads.
5. Confirm profile stats match visible public story data.
6. Open featured story.
7. Open latest signal chapter.
8. Open `/launch`.
9. Open `/missing-narrio-route-check` and confirm the branded not-found page appears.
10. Confirm mobile layout for `/library`, `/u/[userId]`, and `/launch`.

## Acceptance criteria

- Public writer profile loads without login.
- Profile never shows private or unlisted stories.
- Library links to writer profiles.
- Story page existing writer profile link still works.
- Branded 404, error, and loading screens are present.
- `/launch` gives a clear checkpoint for the demo path.
