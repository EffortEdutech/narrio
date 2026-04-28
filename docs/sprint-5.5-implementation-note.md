# Sprint 5.5 — First 60 Seconds Onboarding

## Purpose

This sprint connects the existing Sprint 5 features into one guided first-run journey. It does not add new database tables.

## Added

- `/onboarding` public first-run route
- Start Here navigation link
- Homepage entry point: Start in 60 seconds
- Writer dashboard checklist
- Activity page shortcut back to onboarding

## Core journey

1. Read one chapter
2. Explore timelines
3. Save a waypoint
4. Fork a path
5. Write your version

## Notes

The route uses existing APIs: `listPublishedStories()` and `listStoriesByAuthor()`. If no public story exists, it gracefully falls back to `/library`. If the user has no draft story, it points to `/write/new`.
