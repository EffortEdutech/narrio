-- Narrio Sprint 1
-- Row level security

alter table public.profiles enable row level security;
alter table public.stories enable row level security;
alter table public.story_branches enable row level security;
alter table public.chapters enable row level security;
alter table public.chapter_versions enable row level security;
alter table public.bookmarks enable row level security;
alter table public.follows enable row level security;
alter table public.likes enable row level security;

-- Profiles
drop policy if exists "profiles are publicly readable" on public.profiles;
create policy "profiles are publicly readable"
on public.profiles
for select
to anon, authenticated
using (true);

drop policy if exists "users can insert their own profile" on public.profiles;
create policy "users can insert their own profile"
on public.profiles
for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "users can update their own profile" on public.profiles;
create policy "users can update their own profile"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- Stories
drop policy if exists "public can read published public stories" on public.stories;
create policy "public can read published public stories"
on public.stories
for select
to anon, authenticated
using (
  (status = 'published' and visibility = 'public')
  or author_id = auth.uid()
);

drop policy if exists "owners can insert stories" on public.stories;
create policy "owners can insert stories"
on public.stories
for insert
to authenticated
with check (author_id = auth.uid());

drop policy if exists "owners can update stories" on public.stories;
create policy "owners can update stories"
on public.stories
for update
to authenticated
using (author_id = auth.uid())
with check (author_id = auth.uid());

drop policy if exists "owners can delete stories" on public.stories;
create policy "owners can delete stories"
on public.stories
for delete
to authenticated
using (author_id = auth.uid());

-- Branches
drop policy if exists "public can read visible story branches" on public.story_branches;
create policy "public can read visible story branches"
on public.story_branches
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and (
        (s.status = 'published' and s.visibility = 'public' and story_branches.visibility = 'public')
        or s.author_id = auth.uid()
      )
  )
);

drop policy if exists "owners can insert story branches" on public.story_branches;
create policy "owners can insert story branches"
on public.story_branches
for insert
to authenticated
with check (
  created_by = auth.uid()
  and exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can update story branches" on public.story_branches;
create policy "owners can update story branches"
on public.story_branches
for update
to authenticated
using (
  exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and s.author_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can delete story branches" on public.story_branches;
create policy "owners can delete story branches"
on public.story_branches
for delete
to authenticated
using (
  exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and s.author_id = auth.uid()
  )
);

-- Chapters
drop policy if exists "public can read published chapters" on public.chapters;
create policy "public can read published chapters"
on public.chapters
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.stories s
    join public.story_branches b on b.id = chapters.branch_id
    where s.id = chapters.story_id
      and b.id = chapters.branch_id
      and (
        (s.status = 'published' and s.visibility = 'public' and b.visibility = 'public' and chapters.is_published = true)
        or s.author_id = auth.uid()
      )
  )
);

drop policy if exists "owners can insert chapters" on public.chapters;
create policy "owners can insert chapters"
on public.chapters
for insert
to authenticated
with check (
  created_by = auth.uid()
  and exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can update chapters" on public.chapters;
create policy "owners can update chapters"
on public.chapters
for update
to authenticated
using (
  exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can delete chapters" on public.chapters;
create policy "owners can delete chapters"
on public.chapters
for delete
to authenticated
using (
  exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
);

-- Chapter versions
drop policy if exists "public can read current published chapter versions" on public.chapter_versions;
create policy "public can read current published chapter versions"
on public.chapter_versions
for select
to anon, authenticated
using (
  exists (
    select 1
    from public.chapters c
    join public.story_branches b on b.id = c.branch_id
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and (
        (s.status = 'published' and s.visibility = 'public' and b.visibility = 'public' and c.is_published = true and chapter_versions.is_current = true)
        or s.author_id = auth.uid()
      )
  )
);

drop policy if exists "owners can insert chapter versions" on public.chapter_versions;
create policy "owners can insert chapter versions"
on public.chapter_versions
for insert
to authenticated
with check (
  created_by = auth.uid()
  and exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can update chapter versions" on public.chapter_versions;
create policy "owners can update chapter versions"
on public.chapter_versions
for update
to authenticated
using (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and s.author_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and s.author_id = auth.uid()
  )
);

drop policy if exists "owners can delete chapter versions" on public.chapter_versions;
create policy "owners can delete chapter versions"
on public.chapter_versions
for delete
to authenticated
using (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and s.author_id = auth.uid()
  )
);

-- Personal engagement tables
drop policy if exists "users manage their own bookmarks" on public.bookmarks;
create policy "users manage their own bookmarks"
on public.bookmarks
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users manage their own follows" on public.follows;
create policy "users manage their own follows"
on public.follows
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "users manage their own likes" on public.likes;
create policy "users manage their own likes"
on public.likes
for all
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());
