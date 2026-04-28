# Sprint 6.3 — Library Discovery

## Objective

Upgrade `/library` from a plain published-story list into a reader-facing discovery surface.

Sprint 6.1 gave writers publish controls. Sprint 6.2 polished the public story page. Sprint 6.3 makes published stories easier to find.

## Scope

Implemented:

- Search by story title, synopsis, and writer display name.
- Sort by newest, recently updated, title, chapter count, and timeline count.
- Filter by path type:
  - all public paths
  - root timelines
  - ForkCraft branches
- Filter by ForkCraft permission:
  - any permission
  - forking enabled
  - closed canon
- Discovery stats:
  - matching stories
  - public timelines
  - published chapters
  - forkable stories
- Rich story cards:
  - cover area
  - author label
  - latest signal
  - timeline/chapter counts
  - Start reading
  - Story page
  - Timelines

## Database impact

No database migration is required.

The implementation intentionally avoids public follower/like counts because the current RLS only allows users to manage their own follows and likes. Public discovery therefore uses only public stories, public timelines, and published chapters.

## Files

```txt
packages/api/src/discovery.ts
packages/api/src/index.ts
apps/web/app/library/page.tsx
apps/web/app/library/library.module.css
docs/sprint-6.3-library-discovery.md
docs/sprint-6.3-github-issues.md
```

## Manual QA

1. Publish at least one story.
2. Publish at least one chapter.
3. Open `/library`.
4. Confirm the discovery hero appears.
5. Search by story title.
6. Search by writer display name.
7. Sort by chapters.
8. Sort by timelines.
9. Filter by ForkCraft branches.
10. Filter by forking enabled.
11. Open Start reading.
12. Open Story page.
13. Open Timelines.
14. Reset filters.

## Known limitation

Follower counts are intentionally not shown in this sprint. Add them later through a safe public aggregate view or RPC.
