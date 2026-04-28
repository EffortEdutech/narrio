# Sprint 5.7 — Marketing App Direction Patch

## Purpose

`apps/marketing` is the public front door for Narrio.

This sprint turns the existing placeholder into a real landing page that explains:

- Narrio as the platform
- ForkCraft as the signature creative loop
- Readers becoming creators
- Story trees and alternate timelines
- The link between marketing promise and app onboarding

## Scope

Included:

- `apps/marketing/app/page.tsx`
- `apps/marketing/app/layout.tsx`
- `apps/marketing/app/globals.css`

Not included:

- No database migration
- No Supabase changes
- No new dependency
- No GitHub direct change
- No analytics provider yet
- No payment / signup backend change

## Local app role

Use:

```powershell
pnpm -C apps/marketing dev
```

Marketing app:

```text
http://localhost:3901
```

Product app:

```text
http://localhost:3900
```

By default, marketing CTA links point to:

```text
http://localhost:3900
```

For deployed environments, set:

```env
NEXT_PUBLIC_NARRIO_APP_URL=https://your-narrio-app-domain.com
```

## Manual test flow

1. Run the marketing app.
2. Open `http://localhost:3901`.
3. Confirm the hero uses Narrio/ForkCraft language.
4. Confirm the visual story tree appears.
5. Click `Start ForkCraft`.
6. Confirm it opens the product app writer route.
7. Click `Explore stories`.
8. Confirm it opens the product app library route.
9. Resize to mobile width.
10. Confirm cards and CTA buttons stack cleanly.

## Why this sprint matters

Narrio needs two surfaces:

1. `apps/marketing` — public persuasion and positioning.
2. `apps/web` — actual product loop.

The marketing app should not duplicate the product app. It should explain the promise clearly enough that a visitor understands why they should enter the Narrio universe.
