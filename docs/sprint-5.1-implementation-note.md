# Sprint 5.1 Implementation Note

## Decision

Use the existing branch model as the technical source of truth, but expose it to readers as **timelines**.

## Why

The database already supports:

- stories
- story_branches
- chapters
- chapter_versions

So Sprint 5.1 should make ForkCraft visible instead of introducing a new graph schema.

## Route added

```text
/story/[storyId]/timelines
```

## No schema change

This patch intentionally avoids migrations. It only adds an API aggregation helper and UI pages.

## Product language

- Technical: branch
- Public reader language: timeline
- Feature brand: ForkCraft
