# Narrio — Sprint 2 Pack

This pack extends the Sprint 1 foundation into the **Writer Core MVP**.

## Included
- web app on `http://localhost:3900`
- marketing placeholder on `http://localhost:3901`
- Supabase schema + RLS + seed
- sign-in page
- protected writer area
- My Stories dashboard
- Create Story flow
- Chapter editor
- Version history
- Restore version action
- Branch creation flow

## Startup
1. Copy `.env.example` to `.env.local`
2. Fill your Supabase values
3. Apply:
   - `supabase/migrations/0001_core_schema.sql`
   - `supabase/migrations/0002_rls.sql`
   - create a test auth user
   - `supabase/seed.sql`
4. Install and run:
   - `pnpm install`
   - `pnpm dev`

## URLs
- Web: `http://localhost:3900`
- Marketing: `http://localhost:3901` via `pnpm dev:marketing`

## Sprint 2 outcome
By the end of this pack, a signed-in user can:
- create a story
- open its editor
- create chapters
- save chapter versions
- restore an older version
- create a new branch cloned from the current branch state
