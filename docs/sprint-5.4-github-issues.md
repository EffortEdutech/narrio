# Sprint 5.4 GitHub Issues — Activity Feed Stub

## Issue 1 — Add activity aggregation API

**Scope**
- Add `packages/api/src/activity.ts`
- Normalize bookmarks, follows, likes, timelines, and chapters into `NarrioActivityItem`
- Export from `packages/api/src/index.ts`

**Acceptance**
- Returns recent user activity sorted newest first
- Does not require a new database table
- Handles missing nested records safely

## Issue 2 — Add `/activity` page

**Scope**
- Add protected activity page
- Show summary cards
- Show recent pulse feed
- Show empty state

**Acceptance**
- Unauthenticated users are redirected to sign in
- Authenticated users can see their own activity
- Feed items link back to story, timeline, or chapter

## Issue 3 — Add Activity navigation

**Scope**
- Add `Activity` link to top navigation
- Rename navigation bookmark label to `Waypoints`

**Acceptance**
- `/activity` is reachable from top navigation
- Product language remains consistent with Sprint 5.3

## Issue 4 — Style activity feed

**Scope**
- Add activity feed CSS classes
- Add responsive behavior for mobile

**Acceptance**
- Feed is readable on desktop and mobile
- Summary cards and activity cards match Narrio UI style
