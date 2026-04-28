# Narrio — Build Start Plan

## 1. Product Lock
Narrio v1 starts as a **branch-first social storytelling platform**.

Core shipped loop:
1. Create story
2. Auto-create `main` branch
3. Write chapter
4. Commit chapter version
5. Read branch
6. Fork from story or chapter
7. Bookmark/tag

Not in v1 foundation:
- graph DB
- Kafka / Redis Streams
- subscriptions / payments
- dispute engine
- advanced governance roles
- canon voting
- creator monetization marketplace

These remain future layers after the core loop is live.

## 2. Recommended Repo Strategy
Because the direction has changed significantly, build this as **Narrio v2** in a fresh repo/folder while keeping the current StoryBook repo as reference/archive.

Recommended root:

```text
narrio/
├─ apps/
│  ├─ web/
│  └─ admin/
├─ packages/
│  ├─ ui/
│  ├─ db/
│  ├─ api/
│  ├─ ai/
│  └─ config/
├─ supabase/
│  ├─ migrations/
│  └─ seed.sql
└─ docs/
```

## 3. Build Order

### Sprint 1 — Foundation
- Monorepo scaffold
- Supabase local project
- Core schema SQL
- RLS SQL
- Seed SQL
- Generated TypeScript DB types
- Server/client Supabase helpers
- Basic domain services

### Sprint 2 — Reader Core
- Story page
- Branch explorer
- Chapter reader
- Latest version loader
- Bookmark/tag action

### Sprint 3 — Writer Core
- Writing editor shell
- Commit version flow
- Version history drawer
- Create chapter flow
- Create branch / fork from chapter flow

### Sprint 4 — AI Layer
- AI rewrite
- Continue writing
- Title generator
- AI labeling on generated versions

## 4. Core Database Tables (v1)
- `profiles`
- `stories`
- `story_branches`
- `chapters`
- `chapter_versions`
- `bookmarks`
- `follows`
- `likes`

## 5. Minimum Routes
- `/`
- `/library`
- `/story/[storyId]`
- `/story/[storyId]/chapter/[chapterId]`
- `/write/editor/[storyId]`
- `/write/editor/[storyId]/branch/[branchId]`

## 6. First Real Deliverables To Generate
1. `0001_core_schema.sql`
2. `0002_rls.sql`
3. `seed.sql`
4. root `package.json`
5. `pnpm-workspace.yaml`
6. `turbo.json`
7. `packages/db/*`
8. `packages/api/*`
9. `apps/web` starter routes
10. Branch Explorer + Writing Editor starter components

## 7. Rules For Discipline
- Keep one web app first; avoid splitting too early.
- Use Supabase as the source of truth.
- Store chapter content only in `chapter_versions`.
- Every story gets a `main` branch automatically.
- AI output must create labeled immutable versions.
- Do not build advanced governance before real users exist.

## 8. Immediate Next Build Pack
The next concrete pack should contain:
- SQL migrations
- TypeScript DB layer
- API services
- web app scaffold

This is the cleanest way to start materializing Narrio without drifting back into over-engineering.

