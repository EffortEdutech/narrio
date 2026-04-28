-- Sprint 5.3 optional hardening: keep one bookmark row per user/chapter/tag.
-- Safe for existing local data: duplicates are collapsed before the unique index is created.

delete from public.bookmarks duplicate
using public.bookmarks kept
where duplicate.user_id = kept.user_id
  and duplicate.chapter_id = kept.chapter_id
  and duplicate.tag = kept.tag
  and duplicate.ctid > kept.ctid;

create unique index if not exists idx_bookmarks_unique_user_chapter_tag
on public.bookmarks (user_id, chapter_id, tag);
