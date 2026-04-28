# Narrio — Sprint 5 Productization Pack

Narrio is a social storytelling platform where every story can branch, fork, and evolve into new timelines.

**Tagline:** Where stories branch forever.  
**Core engine:** ForkCraft

This pack productizes the existing Sprint 2 Writer Core MVP. It does not change the database model or Supabase RLS.

## Included
- web app on `http://localhost:3900`
- marketing app on `http://localhost:3901`
- Supabase schema + RLS + seed
- sign-in page
- protected writer area
- Story Studio dashboard
- Create Story flow
- Chapter editor
- Version history
- Restore version action
- ForkCraft timeline creation flow

## Product language

| Technical layer | Product language |
| --- | --- |
| Story | Story |
| Branch | Timeline |
| Create branch | Fork this timeline |
| Commit message | What changed? |
| Version | Version |
| Branch explorer | Timeline explorer |

Technical tables and API names remain unchanged:

```text
stories -> story_branches -> chapters -> chapter_versions
```

User-facing language becomes:

```text
Story -> Timeline -> Chapter -> Version
```

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

## Sprint 5 outcome
By the end of this patch, a signed-in user can still:
- create a story
- open its editor
- create chapters
- save chapter versions
- restore an older version
- fork the current timeline into a new path

And the visible product experience now says:

```text
Narrio
Where stories branch forever.
Powered by ForkCraft.
```

## Validation
Run these locally before committing:

```bash
pnpm install
pnpm typecheck
pnpm build
```
