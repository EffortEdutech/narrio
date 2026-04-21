create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text unique,
  display_name text,
  avatar_url text,
  bio text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute procedure public.set_updated_at();

create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles (id) on delete cascade,
  forked_from_story_id uuid references public.stories (id) on delete set null,
  title text not null,
  slug text not null unique,
  synopsis text,
  cover_url text,
  status text not null default 'draft',
  visibility text not null default 'public',
  allow_forks boolean not null default true,
  main_branch_id uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint stories_status_check check (status in ('draft', 'published', 'archived')),
  constraint stories_visibility_check check (visibility in ('public', 'unlisted', 'private'))
);

create trigger stories_set_updated_at
before update on public.stories
for each row
execute procedure public.set_updated_at();

create table if not exists public.story_branches (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories (id) on delete cascade,
  parent_branch_id uuid references public.story_branches (id) on delete set null,
  created_by uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  slug text not null,
  description text,
  branch_type text not null default 'main',
  status text not null default 'active',
  visibility text not null default 'public',
  forked_from_version_id uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint story_branches_type_check check (branch_type in ('main', 'fork', 'alternate', 'experimental')),
  constraint story_branches_status_check check (status in ('active', 'archived')),
  constraint story_branches_visibility_check check (visibility in ('public', 'unlisted', 'private')),
  constraint story_branches_story_slug_unique unique (story_id, slug)
);

create trigger story_branches_set_updated_at
before update on public.story_branches
for each row
execute procedure public.set_updated_at();

create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories (id) on delete cascade,
  branch_id uuid not null references public.story_branches (id) on delete cascade,
  chapter_number integer not null,
  title text not null,
  slug text,
  summary text,
  is_published boolean not null default false,
  published_at timestamptz,
  created_by uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint chapters_story_branch_number_unique unique (branch_id, chapter_number)
);

create trigger chapters_set_updated_at
before update on public.chapters
for each row
execute procedure public.set_updated_at();

create table if not exists public.chapter_versions (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters (id) on delete cascade,
  version_number integer not null,
  title text not null,
  excerpt text,
  content_md text not null,
  source text not null default 'human',
  commit_message text,
  is_current boolean not null default false,
  created_by uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint chapter_versions_source_check check (source in ('human', 'ai', 'import')),
  constraint chapter_versions_chapter_version_unique unique (chapter_id, version_number)
);

create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  chapter_id uuid not null references public.chapters (id) on delete cascade,
  tag text not null,
  is_public boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.follows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  story_id uuid not null references public.stories (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint follows_unique_user_story unique (user_id, story_id)
);

create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  chapter_version_id uuid not null references public.chapter_versions (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint likes_unique_user_version unique (user_id, chapter_version_id)
);

create index if not exists idx_stories_author_id on public.stories (author_id);
create index if not exists idx_story_branches_story_id on public.story_branches (story_id);
create index if not exists idx_chapters_branch_id on public.chapters (branch_id);
create index if not exists idx_chapter_versions_chapter_id on public.chapter_versions (chapter_id);
create index if not exists idx_bookmarks_user_id on public.bookmarks (user_id);
create index if not exists idx_bookmarks_chapter_id on public.bookmarks (chapter_id);
create index if not exists idx_follows_user_id on public.follows (user_id);
create index if not exists idx_likes_user_id on public.likes (user_id);
create index if not exists idx_likes_chapter_version_id on public.likes (chapter_version_id);

create or replace function public.chapter_versions_set_current()
returns trigger
language plpgsql
as $$
begin
  if new.is_current then
    update public.chapter_versions
    set is_current = false
    where chapter_id = new.chapter_id
      and id <> new.id;
  end if;

  return new;
end;
$$;

create trigger chapter_versions_set_current_trigger
after insert on public.chapter_versions
for each row
execute procedure public.chapter_versions_set_current();

create or replace function public.stories_create_main_branch()
returns trigger
language plpgsql
as $$
declare
  v_branch_id uuid;
begin
  insert into public.story_branches (
    story_id,
    parent_branch_id,
    created_by,
    name,
    slug,
    description,
    branch_type,
    status,
    visibility
  )
  values (
    new.id,
    null,
    new.author_id,
    'Main',
    'main',
    'Primary narrative branch',
    'main',
    'active',
    new.visibility
  )
  returning id into v_branch_id;

  update public.stories
  set main_branch_id = v_branch_id
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists stories_create_main_branch_trigger on public.stories;

create trigger stories_create_main_branch_trigger
after insert on public.stories
for each row
execute procedure public.stories_create_main_branch();

alter table public.stories
  add constraint stories_main_branch_fk
  foreign key (main_branch_id) references public.story_branches (id)
  on delete set null;
