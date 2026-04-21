-- Narrio Sprint 1
-- Core schema
-- Branch-first storytelling foundation

create extension if not exists pgcrypto;

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
  updated_at timestamptz not null default timezone('utc', now()),
  constraint profiles_username_format check (
    username is null
    or username ~ '^[a-z0-9_]{3,32}$'
  )
);

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

create table if not exists public.story_branches (
  id uuid primary key default gen_random_uuid(),
  story_id uuid not null references public.stories (id) on delete cascade,
  parent_branch_id uuid references public.story_branches (id) on delete set null,
  created_by uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  slug text not null,
  description text,
  branch_type text not null default 'fork',
  status text not null default 'active',
  visibility text not null default 'public',
  forked_from_version_id uuid,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint story_branches_branch_type_check check (branch_type in ('main', 'fork', 'alternate', 'experimental')),
  constraint story_branches_status_check check (status in ('active', 'archived')),
  constraint story_branches_visibility_check check (visibility in ('public', 'unlisted', 'private')),
  constraint story_branches_story_slug_unique unique (story_id, slug)
);

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
  constraint chapters_number_positive check (chapter_number > 0),
  constraint chapters_branch_number_unique unique (branch_id, chapter_number)
);

create table if not exists public.chapter_versions (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters (id) on delete cascade,
  version_number integer not null,
  title text not null,
  excerpt text,
  content_md text not null default '',
  source text not null default 'human',
  commit_message text,
  is_current boolean not null default true,
  created_by uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  constraint chapter_versions_version_positive check (version_number > 0),
  constraint chapter_versions_source_check check (source in ('human', 'ai', 'import')),
  constraint chapter_versions_unique_version unique (chapter_id, version_number)
);

alter table public.story_branches
  add constraint story_branches_forked_from_version_id_fkey
  foreign key (forked_from_version_id)
  references public.chapter_versions (id)
  on delete set null;

alter table public.stories
  add constraint stories_main_branch_id_fkey
  foreign key (main_branch_id)
  references public.story_branches (id)
  on delete set null;

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

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    null,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1))
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.create_main_branch_for_story()
returns trigger
language plpgsql
security definer
set search_path = public
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
    'Default story branch',
    'main',
    'active',
    case
      when new.visibility = 'private' then 'private'
      when new.visibility = 'unlisted' then 'unlisted'
      else 'public'
    end
  )
  returning id into v_branch_id;

  update public.stories
  set main_branch_id = v_branch_id
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists stories_create_main_branch on public.stories;
create trigger stories_create_main_branch
after insert on public.stories
for each row execute procedure public.create_main_branch_for_story();

create or replace function public.chapter_versions_set_current()
returns trigger
language plpgsql
as $$
begin
  update public.chapter_versions
  set is_current = false
  where chapter_id = new.chapter_id
    and id <> new.id;

  return new;
end;
$$;

drop trigger if exists chapter_versions_mark_current on public.chapter_versions;
create trigger chapter_versions_mark_current
after insert on public.chapter_versions
for each row execute procedure public.chapter_versions_set_current();

create index if not exists idx_profiles_username on public.profiles (username);
create index if not exists idx_stories_author_id on public.stories (author_id);
create index if not exists idx_stories_status_visibility on public.stories (status, visibility);
create index if not exists idx_story_branches_story_id on public.story_branches (story_id);
create index if not exists idx_chapters_story_branch on public.chapters (story_id, branch_id);
create index if not exists idx_chapter_versions_chapter_current on public.chapter_versions (chapter_id, is_current);
create index if not exists idx_bookmarks_user_id on public.bookmarks (user_id);
create index if not exists idx_bookmarks_chapter_id on public.bookmarks (chapter_id);
create index if not exists idx_follows_user_id on public.follows (user_id);
create index if not exists idx_likes_user_id on public.likes (user_id);
create index if not exists idx_likes_chapter_version_id on public.likes (chapter_version_id);

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
before update on public.profiles
for each row execute procedure public.set_updated_at();

drop trigger if exists set_stories_updated_at on public.stories;
create trigger set_stories_updated_at
before update on public.stories
for each row execute procedure public.set_updated_at();

drop trigger if exists set_story_branches_updated_at on public.story_branches;
create trigger set_story_branches_updated_at
before update on public.story_branches
for each row execute procedure public.set_updated_at();

drop trigger if exists set_chapters_updated_at on public.chapters;
create trigger set_chapters_updated_at
before update on public.chapters
for each row execute procedure public.set_updated_at();
