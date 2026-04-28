# Sprint 5.3 — GitHub Issue Breakdown

## Issue 1 — Upgrade bookmark API into tagged waypoints

### Scope
- Add bookmark tag presets.
- Normalize custom bookmark tags.
- Add save, toggle, list-by-chapter, delete-by-id helpers.

### Acceptance
- A chapter can have multiple user-owned tags.
- Duplicate tags are collapsed deterministically.
- Existing favorite toggle still works.

---

## Issue 2 — Add Save this waypoint panel to chapter reader

### Scope
- Show active waypoint tags for the current chapter.
- Add preset tag forms.
- Add custom tag form.
- Keep Sprint 5.2 Fork from this chapter button intact.

### Acceptance
- Reader can tag a chapter without leaving the page.
- Tag state is visible after refresh.
- ForkCraft actions remain available.

---

## Issue 3 — Upgrade My bookmarks into My waypoints

### Scope
- Add tag filter chips.
- Show story, chapter, timeline, tag, privacy, and saved date.
- Add remove action.

### Acceptance
- `/write/bookmarks` shows saved waypoints.
- Tag filters work.
- Remove action deletes only the current user’s bookmark.

---

## Issue 4 — Optional bookmark uniqueness migration

### Scope
- Deduplicate existing bookmark rows.
- Add unique index on `(user_id, chapter_id, tag)`.

### Acceptance
- Re-saving an existing tag does not create duplicate rows.
