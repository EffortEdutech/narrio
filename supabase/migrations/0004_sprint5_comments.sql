create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters(id) on delete cascade,
  story_id uuid not null references public.stories(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  parent_comment_id uuid null references public.comments(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 3000),
  is_spoiler boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists comments_chapter_id_created_at_idx
on public.comments (chapter_id, created_at desc);

drop trigger if exists comments_set_updated_at on public.comments;
create trigger comments_set_updated_at
before update on public.comments
for each row execute function public.set_updated_at();

alter table public.comments enable row level security;

drop policy if exists "comments_select_public_or_owner" on public.comments;
create policy "comments_select_public_or_owner"
on public.comments
for select
using (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = comments.chapter_id
      and (
        (c.is_published = true and s.status = 'published' and s.visibility = 'public')
        or s.author_id = auth.uid()
        or comments.user_id = auth.uid()
      )
  )
);

drop policy if exists "comments_insert_on_visible_chapter" on public.comments;
create policy "comments_insert_on_visible_chapter"
on public.comments
for insert
with check (
  auth.uid() = user_id
  and exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = comments.chapter_id
      and comments.story_id = s.id
      and (
        (c.is_published = true and s.status = 'published' and s.visibility = 'public')
        or s.author_id = auth.uid()
      )
  )
);

drop policy if exists "comments_update_own" on public.comments;
create policy "comments_update_own"
on public.comments
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "comments_delete_own" on public.comments;
create policy "comments_delete_own"
on public.comments
for delete
using (auth.uid() = user_id);
