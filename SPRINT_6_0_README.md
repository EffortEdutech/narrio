# Narrio Sprint 6.0 — Stabilization Checkpoint

Bismillah.

Sprint 6.0 is a freeze-and-verify checkpoint before we continue into Sprint 6.1 Publishing & Public Discovery.

## Purpose

Sprint 5 made the ForkCraft loop visible:

```text
Onboarding → Library → Story → Timeline Explorer → Chapter → Fork from Chapter → Waypoint → Activity
```

Sprint 6.0 confirms that this loop is stable enough to become the baseline for publishing features.

## What this pack changes

This pack is documentation and QA support only.

It does not change:

- app routes
- database schema
- Supabase RLS
- UI components
- package dependencies
- build configuration

## Recommended local flow

1. Apply all tested Sprint 5 patches/hotfixes in your local repo.
2. Run the command checklist in `docs/sprint-6.0-local-command-checklist.md`.
3. Complete the manual route matrix in `docs/sprint-6.0-manual-qa-matrix.md`.
4. Record results in `docs/sprint-6.0-status-register.md`.
5. Fix only blocking bugs.
6. Commit the Sprint 5 baseline.
7. Tag the baseline locally as Sprint 5 complete.

## Definition of Done

Sprint 6.0 is done when:

```text
pnpm typecheck passes
pnpm build passes
web app starts on port 3900
marketing app starts on port 3901
full ForkCraft loop can be tested manually
all blocking bugs are resolved or documented
Sprint 5 baseline commit exists
local tag exists
```

## Next sprint

After this checkpoint:

```text
Sprint 6.1 — Publish Control Center
```

That sprint will add writer controls for story, timeline, and chapter publication state.
