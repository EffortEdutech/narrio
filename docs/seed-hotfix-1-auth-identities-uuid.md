# Seed Hotfix 1 — auth.identities UUID Fix

## Error fixed

```text
ERROR: 42804: column "id" is of type uuid but expression is of type text
```

## Changed line

Before:

```sql
using u.id::text, u.id,
```

After:

```sql
using u.id, u.id,
```

## Reason

Your local Supabase version defines `auth.identities.id` as UUID. The demo seed was passing text.

## Rerun note

The seed is wrapped in a transaction. The failed run should have rolled back before inserting platform content. Rerun the fixed SQL file from the beginning.
