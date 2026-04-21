# Narrio — Sprint 1 Foundation Pack

Narrio is a branch-first social storytelling platform.

This Sprint 1 pack initializes the public repo with:

- pnpm + Turborepo monorepo
- `apps/web` public reader + creator starter
- `apps/marketing` landing placeholder
- shared `packages/db`, `packages/api`, `packages/ui`, `packages/ai`, `packages/config`
- Supabase schema migration
- Supabase RLS migration
- seed file for local demo content

## Repo shape

```text
narrio/
├─ apps/
│  ├─ web/
│  └─ marketing/
├─ packages/
│  ├─ api/
│  ├─ ai/
│  ├─ config/
│  ├─ db/
│  └─ ui/
├─ supabase/
│  ├─ migrations/
│  │  ├─ 0001_core_schema.sql
│  │  └─ 0002_rls.sql
│  └─ seed.sql
├─ .env.example
├─ package.json
├─ pnpm-workspace.yaml
├─ turbo.json
└─ tsconfig.base.json
```

## Local setup

1. Open the local folder:
   `C:\Users\user\Documents\00 StoryBook\narrio`

2. Copy environment values:
   - copy `.env.example` to `.env.local`
   - fill in your Supabase URL, publishable key, and service role key if needed for server-side admin utilities

3. Install dependencies:
   ```bash
   pnpm install
   ```

4. Start both apps:
   ```bash
   pnpm dev
   ```

5. Open:
   - Web: `http://localhost:3100`
   - Marketing: `http://localhost:3102`

## Supabase setup

1. Initialize or link your Supabase project.
2. Run the migrations in order:
   - `supabase/migrations/0001_core_schema.sql`
   - `supabase/migrations/0002_rls.sql`
3. Run `supabase/seed.sql` after you have at least one auth user in local/dev.

## Current product scope

Sprint 1 intentionally focuses on the branch-first foundation:

- stories
- story forks
- main branch auto-creation
- chapters
- chapter versions
- bookmarks by tag
- follows
- likes
- library listing
- story page
- branch explorer
- reader page
- writer/editor shell

## Important model decisions

- Content lives in `chapter_versions`, not directly in `chapters`.
- Every new story auto-creates a `main` branch.
- New chapter versions automatically become the current version.
- Public readers only see published/public content.
- Owners can manage their own draft content through RLS.

## Next sprint

- auth screens
- create story flow
- create chapter flow
- commit version flow
- fork branch flow
- bookmark/follow/like actions
- AI rewrite + continue writing
