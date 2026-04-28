# Sprint 6.1 — GitHub Issues / Task Breakdown

## Issue 1 — Build Publish Control Center route

**Route:** `/write/publish/[storyId]`

Tasks:

- Add story launch status panel.
- Add story visibility form.
- Add ForkCraft permission toggle.
- Add timeline visibility forms.
- Add chapter publish/unpublish controls.
- Add reader preview and Story Studio links.

Acceptance:

- Story author can control publish state from one page.
- Page is not accessible to non-author users.

## Issue 2 — Add server actions for publishing

Tasks:

- Add `setStoryPublishStatusAction`.
- Add `updateStoryPublishingSettingsAction`.
- Add `updateTimelineVisibilityAction`.
- Add `toggleChapterPublicationAction`.
- Revalidate `/write`, `/write/publish/[storyId]`, `/story/[storyId]`, and timeline/chapter preview paths.

Acceptance:

- Forms work without client JavaScript.
- Server actions redirect back to Publish Center after save.

## Issue 3 — Extend API publishing helpers

Tasks:

- Add partial story status update helper.
- Add partial story visibility/ForkCraft settings helper.
- Add timeline publication helper.
- Add chapter publication-state helper.
- Keep existing helper exports backward-compatible.

Acceptance:

- Existing imports from `@narrio/api` still work.
- New server actions use package-level API helpers.

## Issue 4 — Connect Publish Center from writer flow

Tasks:

- Add Publish Center button on `/write` story cards.
- Add Publish Center link in Story Studio page header.
- Add release snapshot inside Story Studio.

Acceptance:

- Writer can discover publishing controls without knowing the URL.

## Issue 5 — Add visibility RLS migration

Tasks:

- Allow direct-link reads for published `unlisted` stories and timelines.
- Keep discovery query public-only.
- Gate public chapter reads by story + timeline + chapter release.
- Preserve reader-created ForkCraft access.

Acceptance:

- Public readers cannot read private timelines or unpublished chapters.
- Unlisted published content can load by direct link.
