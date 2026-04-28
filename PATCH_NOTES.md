# Narrio Sprint 5.1 — Timeline Explorer / Branch Explorer Patch

This patch continues the **Materializing the Dream Plan** Sprint 5 direction.

## What this adds

- A reader-facing Timeline Explorer route:
  - `/story/[storyId]/timelines`
- A small API aggregation helper:
  - `getTimelineExplorerByStoryId()`
- Story page CTA:
  - `Explore timelines`
- Timeline language polish on story, branch, and chapter reader pages
- CSS for the ForkCraft map / timeline nodes
- No database migration
- No GitHub changes

## Product meaning

This turns the existing technical model:

```text
Story → Branch → Chapter → Version
```

into a reader-facing product model:

```text
Story → Timeline → Chapter → Version
```

The database remains unchanged.

## Apply order

Recommended order:

1. Apply Sprint 5 branding patch.
2. Test it locally.
3. Apply this Sprint 5.1 patch.
4. Test again.

This patch does not require the branding patch to compile, but the product copy will feel more consistent if Sprint 5 branding is applied first.
