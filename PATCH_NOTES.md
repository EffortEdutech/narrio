# Narrio visible language patch v1

Baseline commit: `020ad151dfc8f12275b2b5c850ccf90a9d3d489b`

## Scope

Visible UI/marketing copy only.

No route segments, database fields, action names, API fields, technical identifiers, or Supabase schema terms were renamed.

## Language cleanup applied

- `ForkCraft` → `Forkcraft`
- `Story page` → `Universe page`
- `public stories` → `public universes`
- `published chapters` → `released chapters`
- `Forking enabled` / similar visible fork states → `Forkcraft open`
- `Publish Control Center` / `Publish Center` → `Release Center`

## Files included

- `packages/config/src/index.ts`
- `apps/web/app/layout.tsx`
- `apps/web/app/page.tsx`
- `apps/web/app/activity/page.tsx`
- `apps/web/app/launch/page.tsx`
- `apps/web/app/onboarding/page.tsx`
- `apps/web/app/write/page.tsx`
- `apps/web/app/write/new/page.tsx`
- `apps/web/app/write/editor/[storyId]/branch/[branchId]/page.tsx`
- `apps/web/app/write/publish/[storyId]/page.tsx`
- `apps/web/app/story/[storyId]/page.tsx`
- `apps/web/app/u/[userId]/page.tsx`
- `apps/web/app/library/page.tsx`
- `apps/marketing/app/layout.tsx`
- `apps/marketing/app/page.tsx`

## Suggested manual test

1. Start the web app.
2. Open `/`, `/onboarding`, `/library`, `/activity`, `/write`, `/write/new`, `/launch`.
3. Open one universe page and one writer profile page.
4. Open Story Studio and Release Center for one seeded universe.
5. Start the marketing app and open its homepage.
6. Confirm visible labels use Forkcraft, Universe page, public universes, released chapters, Forkcraft open, and Release Center.
