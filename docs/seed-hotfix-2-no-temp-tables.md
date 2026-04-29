# Narrio Seed Hotfix 2 — No Temporary Tables

## Problem fixed

Supabase returned:

```text
ERROR: 42P01: relation "narrio_seed_users" does not exist
```

The earlier seed used temporary tables such as `narrio_seed_users`. In some SQL Editor / execution modes, later statements can lose access to those temporary tables.

## Fix

This hotfix changes the seed to use normal staging tables:

```text
public._narrio_seed_users
public._narrio_seed_stories
public._narrio_seed_branches
public._narrio_seed_follows
```

The script drops/recreates them at the start and drops them again after a successful run.

## How to run

Replace:

```text
supabase/seed_forkcraft_demo.sql
```

with the hotfixed file from this pack.

Then run the **full SQL file** in Supabase Studio SQL Editor.

Do not select only part of the file.

## Expected final notice

```text
Narrio demo seed complete: 8 users, 12 stories, 112 universe/timeline branches, 112 chapters.
```

## Demo password

All demo users use:

```text
test123
```
