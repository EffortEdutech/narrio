# Sprint 5.2 — GitHub Issues / Task Breakdown

## Issue 1 — Add Fork from Chapter API

Create `packages/api/src/chapter-forks.ts`.

Acceptance criteria:

- Can load fork source by story and chapter.
- Can create a new branch from source branch.
- Can copy source chapters up to selected fork point.
- Can copy current/latest chapter version into each copied chapter.

## Issue 2 — Add Fork from Chapter page

Create:

```text
apps/web/app/story/[storyId]/chapter/[chapterId]/fork/page.tsx
```

Acceptance criteria:

- Page shows story, source timeline, and fork point.
- Signed-out users see sign-in CTA.
- Signed-in users can create a new timeline.
- Disabled ForkCraft state is handled.

## Issue 3 — Add server action

Create:

```text
apps/web/app/reader/fork_actions.ts
```

Acceptance criteria:

- Requires signed-in user.
- Reads form values.
- Normalizes slug.
- Calls API function.
- Redirects to Story Studio after creation.

## Issue 4 — Add reader UI entry points

Update:

```text
apps/web/app/story/[storyId]/chapter/[chapterId]/page.tsx
apps/web/app/story/[storyId]/branch/[branchId]/page.tsx
apps/web/app/story/[storyId]/timelines/page.tsx
```

Acceptance criteria:

- Chapter page includes `Fork from this chapter`.
- Timeline chapter list includes `Fork here`.
- Timeline explorer includes `Fork latest`.

## Issue 5 — Support fork creator visibility

Update visibility filters so branch creators can see their own private fork timelines.

Acceptance criteria:

- Story page includes public timelines, story-author timelines, and current-user-created timelines.
- Timeline explorer uses the same rule.
- Edit button appears for story author or branch creator.
