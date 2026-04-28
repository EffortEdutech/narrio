# Sprint 5.1 GitHub Issues — Timeline Explorer

Create these issues manually if you want to track the work in GitHub Projects.

## Issue 5.1.1 — Add Timeline Explorer API helper

**Labels:** `sprint-5`, `api`, `forkcraft`

### Tasks
- [ ] Add `getTimelineExplorerByStoryId()`
- [ ] Aggregate branches by story
- [ ] Aggregate chapter counts per branch
- [ ] Compute branch depth and child counts
- [ ] Export helper from `@narrio/api`

## Issue 5.1.2 — Add reader-facing Timeline Explorer page

**Labels:** `sprint-5`, `frontend`, `timeline-explorer`

### Tasks
- [ ] Add `/story/[storyId]/timelines`
- [ ] Display timeline overview metrics
- [ ] Display root and forked timelines
- [ ] Link each timeline to branch reader page
- [ ] Link author to Story Studio editor

## Issue 5.1.3 — Connect Story, Timeline, and Chapter navigation

**Labels:** `sprint-5`, `frontend`, `navigation`

### Tasks
- [ ] Add `Explore timelines` CTA on story page
- [ ] Add timeline navigation on branch reader page
- [ ] Add `Back to timeline` and `Explore timelines` on chapter reader page

## Issue 5.1.4 — Add ForkCraft map styling

**Labels:** `sprint-5`, `ui`, `design-system`

### Tasks
- [ ] Add timeline map container styles
- [ ] Add timeline node/card styles
- [ ] Add badge styling
- [ ] Add mobile fallback indentation reset

## Definition of Done

- [ ] No database migration required
- [ ] Existing writer flow still works
- [ ] Existing reader flow still works
- [ ] Timeline Explorer route renders
- [ ] Typecheck passes
- [ ] Build passes
