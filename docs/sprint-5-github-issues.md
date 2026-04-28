# Sprint 5 — GitHub Issues Backlog

Use this file to manually create GitHub issues after local testing.

## Issue 5.1 — Productize Narrio brand language

**Labels:** `sprint-5`, `branding`, `product-language`

### Goal
Lock the visible product language for Narrio before the next feature sprint.

### Checklist
- [ ] Remove user-facing Sprint 2 wording
- [ ] Standardize tagline: `Where stories branch forever.`
- [ ] Introduce ForkCraft as the branching engine
- [ ] Keep database/API terms unchanged

---

## Issue 5.2 — Add shared brand config package

**Labels:** `sprint-5`, `config`, `frontend`

### Goal
Centralize product copy in `@narrio/config` so pages do not hardcode brand language.

### Checklist
- [ ] Add `packages/config`
- [ ] Export `BRAND`
- [ ] Export `PRODUCT_TERMS`
- [ ] Add `@narrio/config` alias to `tsconfig.base.json`
- [ ] Add workspace dependency to web and marketing apps

---

## Issue 5.3 — Replace marketing placeholder with Narrio landing copy

**Labels:** `sprint-5`, `marketing`, `ui-copy`

### Goal
Make the marketing page explain Narrio clearly.

### Checklist
- [ ] Replace placeholder text
- [ ] Add hero line: `Every story has another path.`
- [ ] Add tagline: `Where stories branch forever.`
- [ ] Add ForkCraft mention
- [ ] Add Start Writing and Explore Stories actions

---

## Issue 5.4 — Polish web homepage and Writer Studio language

**Labels:** `sprint-5`, `web`, `ui-copy`

### Goal
Make the web app feel like a product, not a sprint prototype.

### Checklist
- [ ] Replace `Open Writer Area` with `Enter Writer Studio`
- [ ] Replace homepage Sprint 2 labels
- [ ] Rename `My stories` to `Your Story Studio`
- [ ] Rename `Create story` to `Start a story`
- [ ] Update empty state copy

---

## Issue 5.5 — Update editor language for ForkCraft timelines

**Labels:** `sprint-5`, `editor`, `forkcraft`

### Goal
Keep technical branch logic, but present it as timelines/forks in the UI.

### Checklist
- [ ] Rename `Branch chapters` to `Timeline chapters`
- [ ] Rename `Create branch` to `Fork this timeline`
- [ ] Rename `Story branches` to `Story timelines`
- [ ] Rename `Commit message` to `What changed?`
- [ ] Rename `Save new version` to `Save version`
- [ ] Rename `Restore from this version` to `Restore this version`
