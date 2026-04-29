# Narrio Library Language + Search Hotfix v1

This pack is prepared for manual copy/paste into your local repo.

## What this fixes

1. `/library` visible copy now follows the current Narrio product language:
   - `Forkcraft` locked casing
   - `Universe page` instead of `Story page`
   - `public universes` instead of awkward story pluralization
   - `released chapters` where reader-facing language is better

2. `/library` phrase search is now stricter:
   - removes common stop-words such as `the`, `who`, `of`
   - exact phrase matches receive high priority
   - multi-word queries use AND-like matching instead of loose OR matching
   - prevents long phrases like `the child who borrowed` from returning every universe

## Files to copy

Copy these files from `files/` into your local repo:

- `files/apps/web/app/library/page.tsx`
- `files/packages/api/src/discovery.ts`

## Manual test flow

1. Restart the web app if needed.
2. Open `/library`.
3. Search: `the child who borrowed`
4. Confirm it does **not** return every universe.
5. Search: `The Atlas of Rain Cities`
6. Confirm the matching universe appears near the top / alone.
7. Search a broad real keyword such as `rain`.
8. Confirm broad keyword search still works.
9. Run the language audit script again.
10. Confirm `/library` warnings are reduced.
