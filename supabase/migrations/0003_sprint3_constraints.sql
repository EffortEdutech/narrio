create unique index if not exists bookmarks_unique_user_chapter_tag
on public.bookmarks (user_id, chapter_id, tag);
