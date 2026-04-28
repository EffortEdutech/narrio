# Sprint 5.4 Hotfix 1 — Activity Feed

## Problem

`/activity` could crash at runtime because the first feed implementation used nested Supabase embeds. In this schema, `stories` and `story_branches` have more than one relationship path:

- `story_branches.story_id -> stories.id`
- `stories.main_branch_id -> story_branches.id`

PostgREST can treat this as ambiguous when resolving embedded relationships.

## Fix

The feed now uses flat queries:

- bookmarks
- follows
- likes
- story_branches
- chapters
- chapter_versions
- stories

Then it joins records in TypeScript using maps.

## Migration

None.

## Test Flow

1. Sign in.
2. Open `/activity`.
3. Save a waypoint.
4. Like a chapter version.
5. Fork/create a timeline.
6. Reopen `/activity` and confirm feed items render.
