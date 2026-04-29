# Compatibility Notes Against Uploaded Schema

The uploaded `20260429-8-26am-Database-Schema.txt` schema has these important constraints:

- `profiles.id` references `auth.users.id`.
- `stories.slug` is unique.
- `stories.status` only allows: `draft`, `published`, `archived`.
- `stories.visibility` only allows: `public`, `unlisted`, `private`.
- `story_branches.branch_type` only allows: `main`, `fork`, `alternate`, `experimental`.
- `story_branches.status` only allows: `active`, `archived`.
- `chapter_versions.source` only allows: `human`, `ai`, `import`.

This hotfix avoids conflict targets that are not declared in the uploaded schema:

- No `ON CONFLICT (story_id, slug)` for `story_branches`.
- No `ON CONFLICT (branch_id, chapter_number)` for `chapters`.
- No `ON CONFLICT (chapter_id, version_number)` for `chapter_versions`.
- No `ON CONFLICT (user_id, story_id)` for `follows`.
- No `ON CONFLICT (user_id, chapter_version_id)` for `likes`.

Instead, it uses `SELECT ... LIMIT 1` and `IF NOT EXISTS` guards.
