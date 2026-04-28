# Sprint 5.2 — Fork from Chapter Flow

## What changed

Sprint 5.2 turns ForkCraft from an idea into an action.

Users can now fork from a specific chapter using:

```text
/story/[storyId]/chapter/[chapterId]/fork
```

## Technical behaviour

When a user creates a fork from Chapter N:

1. Narrio creates a new `story_branches` row.
2. The new branch points to the source branch through `parent_branch_id`.
3. Narrio copies source chapters `1..N` into the new branch.
4. Narrio copies the latest/current chapter version for each copied chapter.
5. The user is redirected to Story Studio at the copied fork-point chapter.

## Why copy chapters instead of adding a migration now

The current schema already supports:

```text
stories -> story_branches -> chapters -> chapter_versions
```

A true `forked_from_chapter_id` field can be added later, but Sprint 5.2 avoids migration risk by using the existing branch and chapter model.

## Product language

Use this copy consistently:

- Fork from this chapter
- Fork here
- Create fork from chapter
- New timeline
- Source timeline
- Fork point

## Known limitation

This copy flow is not wrapped in a database transaction yet.

For production hardening, move the multi-step copy into a Supabase RPC function so branch, chapter, and version copy either all succeed or all roll back.
