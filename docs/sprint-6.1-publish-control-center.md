# Sprint 6.1 — Publish Control Center

## Objective

Create a writer-side launch room for each story so publishing is no longer hidden behind database flags.

The writer can now control:

1. Story shell status: draft or published.
2. Story visibility: public, unlisted, or private.
3. ForkCraft permission: allow or disallow reader-created timelines.
4. Timeline visibility: public, unlisted, or private.
5. Chapter release: publish or unpublish one chapter at a time.
6. Reader preview links from the writing flow.

## Route added

```txt
/write/publish/[storyId]
```

This route is protected by `requireUser()` and also checks that the signed-in user is the story author.

## Files changed

```txt
apps/web/app/write/publish/[storyId]/page.tsx
apps/web/app/write/actions.ts
apps/web/app/write/page.tsx
apps/web/app/write/editor/[storyId]/branch/[branchId]/page.tsx
apps/web/app/globals.css
packages/api/src/publishing.ts
supabase/migrations/0007_publish_control_visibility_policies.sql
```

## RLS note

This sprint includes a migration because the UI exposes `unlisted` as a real publishing option.

The migration keeps library discovery strict: the existing `listPublishedStories()` query still lists only `visibility = public` stories. The migration only allows direct-link read access for published stories/timelines marked `unlisted`.

It also tightens chapter reads so an anonymous/public reader can only read a chapter when:

```txt
story.status = published
story.visibility = public or unlisted
timeline.visibility = public or unlisted
chapter.is_published = true
current chapter version only
```

## Manual test flow

1. Sign in as a writer.
2. Open `/write`.
3. Confirm each story card now has a `Publish Center` button.
4. Open `Publish Center`.
5. Change story visibility and save.
6. Toggle `Allow readers to create ForkCraft timelines` and save.
7. Change one timeline visibility and save.
8. Publish one chapter.
9. Publish the story shell.
10. Open `Reader preview`.
11. Confirm the public story loads only when story + timeline + chapter gates allow it.
12. Return the story to draft and confirm reader preview no longer behaves as public content for logged-out users.

## Acceptance checklist

- [ ] `/write/publish/[storyId]` loads for the story author.
- [ ] Non-author cannot access the Publish Control Center for a public story.
- [ ] Story status can switch between draft and published.
- [ ] Story visibility can switch between public, unlisted, and private.
- [ ] Timeline visibility can switch between public, unlisted, and private.
- [ ] Chapter publish/unpublish updates `is_published` and `published_at`.
- [ ] Writer dashboard links to Publish Center.
- [ ] Story Studio links to Publish Center.
- [ ] Migration applies cleanly on local Supabase.
