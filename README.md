# Narrio Real Story Seed Pack v1

This pack is for local/dev Supabase testing.

It creates:

- 8 login users, password `test123`
- 12 written stories at different levels
- 112 total timelines/universes using `story_branches`
- 112 chapters
- 112 current `chapter_versions`
- lightweight follows, likes, bookmarks, and comments

The SQL follows the uploaded schema `20260429-8-26am-Database-Schema.txt`: there is no standalone `universes` table, so universes are represented as timeline branches.

## How to run

In Supabase SQL Editor, run:

```sql
-- files/supabase/seed_forkcraft_real_stories_v1.sql
```

Then verify:

```sql
-- files/supabase/verify_forkcraft_real_stories_v1.sql
```

Expected verification:

```text
stories            12
branches           112
chapters           112
chapter_versions   112
seed_login_users   8
```

## Cleanup

Run:

```sql
-- files/supabase/cleanup_forkcraft_real_stories_v1.sql
```

The cleanup removes the seeded story graph but keeps the auth users/profiles.
