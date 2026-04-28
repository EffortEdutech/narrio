# Sprint 6.1 Preview — Publish Control Center

After Sprint 6.0 is approved, Sprint 6.1 should add publishing controls.

## Objective

Give writers clear control over what becomes public.

## Planned controls

| Area | Control |
| --- | --- |
| Story | Publish story |
| Story | Unpublish story |
| Story | Set visibility |
| Timeline | Set visibility |
| Chapter | Publish chapter |
| Chapter | Unpublish chapter |

## Product language

Use these labels in UI:

```text
Publish story
Make private
Publish chapter
Hide chapter
Public timeline
Private draft timeline
```

Avoid exposing raw database terms to readers.

## Important design rule

Publishing should not change ForkCraft data structure. It should only control visibility and reader access.
