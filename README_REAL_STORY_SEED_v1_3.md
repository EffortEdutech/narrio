# Narrio Real Story Seed Pack v1.3 - Core Safe

This pack replaces v1, v1.1, and v1.2.

The earlier seed could still trigger parser-style SQL errors such as `relation "a" does not exist`. This v1.3 version removes the fragile design:

- no base64 payload
- no JSON decoding
- no temp tables
- no staging tables
- no `_narrio_seed_*` tables
- core seed separated from optional social activity

## Run order

1. Run `files/supabase/seed_forkcraft_real_stories_v1_3_core_safe.sql`
2. Run `files/supabase/verify_forkcraft_real_stories_v1_3.sql`
3. Optional: run `files/supabase/seed_forkcraft_social_activity_v1_3_optional.sql`
4. Run verify again

## Expected core counts

```text
seed_login_users          8
profiles                  8
stories                   12
branches                  112
chapters                  112
chapter_versions          112
current_versions          112
```

## Demo password

```text
test123
```
