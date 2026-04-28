# Sprint 5.3 — Bookmark / Tag Reader Loop

## Goal

Make reader bookmarks feel like productized Narrio waypoints instead of a single generic favorite button.

## Added

- Tagged bookmark presets:
  - favorite
  - reread
  - theory
  - quote
  - fork-idea
- Custom waypoint tags from chapter reader pages.
- Private/public bookmark flag storage.
- `/write/bookmarks` upgraded into **My waypoints** with tag filtering.
- Remove bookmark action from the waypoint dashboard.
- Optional uniqueness migration for `(user_id, chapter_id, tag)`.

## No schema-breaking change

The feature uses the existing `bookmarks` table. The migration only adds an optional unique index after deduplicating existing rows.

## Product language

Database term: bookmark  
Product term: waypoint  
Reader-facing action: Save this waypoint

## Manual test flow

1. Open a public story.
2. Open any chapter.
3. Confirm the Save this waypoint panel appears.
4. Save a preset tag such as Theory.
5. Save a custom tag such as prophecy.
6. Open `/write/bookmarks`.
7. Confirm both tags appear.
8. Filter by tag.
9. Remove one waypoint.
10. Return to the chapter and confirm the removed tag no longer appears.
