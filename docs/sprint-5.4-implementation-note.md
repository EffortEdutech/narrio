# Sprint 5.4 — Activity Feed Stub

## Purpose

Sprint 5.4 introduces a lightweight activity layer for Narrio without creating a new activity-events table yet.

The feed is generated from existing tables:

- `bookmarks` → saved waypoints
- `follows` → followed stories
- `likes` → liked chapter versions
- `story_branches` → created timelines/forks
- `chapters` → added chapters

## New route

```txt
/activity
```

The page is protected by `requireUser()` and shows only the signed-in user's own activity.

## Product language

Technical rows are translated into Narrio language:

```txt
bookmark → waypoint
story_branch → timeline
created fork branch → created a fork timeline
```

## Why no migration yet

A generated feed is safer for this stage because it avoids schema churn. Later, Narrio can introduce a real immutable `activity_events` table for public social feed, notifications, and analytics.

## Test flow

1. Sign in.
2. Open `/activity`.
3. Save a waypoint from a chapter.
4. Follow a story.
5. Like a chapter version.
6. Fork from a chapter.
7. Return to `/activity` and confirm the feed updates.
