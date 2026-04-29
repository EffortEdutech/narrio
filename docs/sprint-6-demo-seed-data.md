# Sprint 6 Demo Seed Data Pack

## Purpose

This pack provides enough data to simulate Narrio as a living platform after Sprint 6:

- 8 demo users registered in Supabase Auth.
- Shared password: `test123`.
- 12 stories at different maturity levels.
- 112 universe/timeline varieties represented as `story_branches`.
- One seeded chapter and current chapter version per universe/timeline.
- Demo follows, likes, and public bookmarks.

## Important safety note

Run this on local development or a disposable staging database only. It creates known demo passwords and public demo data.

## Apply manually

Copy the contents of the `files/` folder into your Narrio repo root.

Expected new files:

```text
supabase/seed_forkcraft_demo.sql
scripts/seed-forkcraft-demo.ps1
docs/narrio-demo-accounts.md
docs/narrio-demo-story-universe-catalog.md
docs/sprint-6-demo-seed-data.md
manifest.json
```

## Run option A — Supabase Studio SQL Editor

1. Start Supabase local.
2. Open Supabase Studio.
3. Open SQL Editor.
4. Paste `supabase/seed_forkcraft_demo.sql`.
5. Run it.

## Run option B — PowerShell with psql

```powershell
cd "C:\Users\user\Documents\00 StoryBook\narrio"
.\scripts\seed-forkcraft-demo.ps1 -RepoRoot "C:\Users\user\Documents\00 StoryBook\narrio"
```

The script defaults to the common local Supabase database URL:

```text
postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

## Recommended product test

1. Start web app: `pnpm -C apps/web dev`.
2. Login using `lina.writer@narrio.test` / `test123`.
3. Open `/write` and verify seeded stories appear.
4. Open `/library` and verify public discovery has many stories.
5. Open `/story/garden-112th-star` or any story card.
6. Open timelines and verify the universe branches are visible.
7. Login as `maya.reader@narrio.test` / `test123`.
8. Open `/activity` and verify follows, likes, and bookmarks exist.

## Expected counts

```text
8 demo users
12 demo stories
112 universe/timeline branches
112 seeded opening chapters
112 current chapter versions
```
