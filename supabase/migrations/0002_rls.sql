alter table public.profiles enable row level security;
alter table public.stories enable row level security;
alter table public.story_branches enable row level security;
alter table public.chapters enable row level security;
alter table public.chapter_versions enable row level security;
alter table public.bookmarks enable row level security;
alter table public.follows enable row level security;
alter table public.likes enable row level security;

-- profiles
create policy "profiles are readable by everyone"
on public.profiles
for select
using (true);

create policy "users can insert their own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "users can update their own profile"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);

-- stories
create policy "public can read published public stories"
on public.stories
for select
using (
  (status = 'published' and visibility = 'public')
  or auth.uid() = author_id
);

create policy "authors can insert stories"
on public.stories
for insert
with check (auth.uid() = author_id);

create policy "authors can update their stories"
on public.stories
for update
using (auth.uid() = author_id)
with check (auth.uid() = author_id);

create policy "authors can delete their stories"
on public.stories
for delete
using (auth.uid() = author_id);

-- branches
create policy "public can read public branches of published stories"
on public.story_branches
for select
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

create policy "authors can insert story branches"
on public.story_branches
for insert
with check (
  exists (
    select 1
    from public.stories s
    where s.id = story_branches.story_id
      and s.author_id = auth.uid()
  )
);

create policy "authors can update story branches"
on public.story_branches
for update
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

-- chapters
create policy "public can read published chapters"
on public.chapters
for select
using (
  is_published = true
  or exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
);

create policy "authors can insert chapters"
on public.chapters
for insert
with check (
  exists (
    select 1
    from public.stories s
    where s.id = chapters.story_id
      and s.author_id = auth.uid()
  )
);

create policy "authors can update chapters"
on public.chapters
for update
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

-- chapter versions
create policy "public can read current versions of published chapters"
on public.chapter_versions
for select
using (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    join public.story_branches b on b.id = c.branch_id
    where c.id = chapter_versions.chapter_id
      and (
        (s.status = 'published' and s.visibility = 'public' and b.visibility = 'public' and c.is_published = true and chapter_versions.is_current = true)
        or s.author_id = auth.uid()
      )
  )
);

create policy "authors can insert chapter versions"
on public.chapter_versions
for insert
with check (
  exists (
    select 1
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where c.id = chapter_versions.chapter_id
      and s.author_id = auth.uid()
  )
);

-- bookmarks
create policy "users can manage their own bookmarks"
on public.bookmarks
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- follows
create policy "users can manage their own follows"
on public.follows
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

-- likes
create policy "users can manage their own likes"
on public.likes
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
