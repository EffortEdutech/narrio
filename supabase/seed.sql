-- Narrio local seed
-- This seed is intentionally safe:
-- it only seeds demo content if at least one auth user already exists.

do $$
declare
  v_user_id uuid;
  v_story_id uuid;
  v_branch_id uuid;
  v_chapter_id uuid;
begin
  select id
  into v_user_id
  from auth.users
  order by created_at asc
  limit 1;

  if v_user_id is null then
    raise notice 'No auth.users found. Skipping Narrio seed.';
    return;
  end if;

  insert into public.profiles (id, username, display_name, bio)
  values (
    v_user_id,
    'darya_malak',
    'Darya Malak',
    'Narrio demo creator'
  )
  on conflict (id) do update
  set
    username = excluded.username,
    display_name = excluded.display_name,
    bio = excluded.bio;

  insert into public.stories (
    author_id,
    forked_from_story_id,
    title,
    slug,
    synopsis,
    status,
    visibility,
    allow_forks
  )
  values (
    v_user_id,
    null,
    'The River That Remembers',
    'the-river-that-remembers',
    'A branch-first demo story seeded for Narrio local development.',
    'published',
    'public',
    true
  )
  on conflict (slug) do update
  set
    synopsis = excluded.synopsis,
    status = excluded.status,
    visibility = excluded.visibility
  returning id into v_story_id;

  if v_story_id is null then
    select id into v_story_id
    from public.stories
    where slug = 'the-river-that-remembers';
  end if;

  select main_branch_id
  into v_branch_id
  from public.stories
  where id = v_story_id;

  insert into public.chapters (
    story_id,
    branch_id,
    chapter_number,
    title,
    slug,
    summary,
    is_published,
    published_at,
    created_by
  )
  values (
    v_story_id,
    v_branch_id,
    1,
    'Chapter 1 — The First Boat',
    'chapter-1-the-first-boat',
    'The beginning of the seeded demo branch.',
    true,
    timezone('utc', now()),
    v_user_id
  )
  on conflict (branch_id, chapter_number) do update
  set
    title = excluded.title,
    summary = excluded.summary,
    is_published = excluded.is_published,
    published_at = excluded.published_at
  returning id into v_chapter_id;

  if v_chapter_id is null then
    select id into v_chapter_id
    from public.chapters
    where branch_id = v_branch_id
      and chapter_number = 1;
  end if;

  insert into public.chapter_versions (
    chapter_id,
    version_number,
    title,
    excerpt,
    content_md,
    source,
    commit_message,
    created_by
  )
  values (
    v_chapter_id,
    1,
    'Chapter 1 — The First Boat',
    'The river opens with a choice.',
    E'# Chapter 1 — The First Boat\n\nThe river was older than the village and kinder than memory.\n\nAt dawn, a weathered boat knocked softly against the jetty. A note lay under the rope:\n\n> **Choose well. This river remembers every version of you.**\n\nThis seeded chapter is here so the Narrio reader, branch explorer, and editor screens have real content on day one.',
    'human',
    'Seed initial chapter version',
    v_user_id
  )
  on conflict (chapter_id, version_number) do update
  set
    title = excluded.title,
    excerpt = excluded.excerpt,
    content_md = excluded.content_md,
    source = excluded.source,
    commit_message = excluded.commit_message;
end $$;


do $$
declare
  v_user_id uuid;
  v_chapter_id uuid;
begin
  select id into v_user_id from auth.users order by created_at asc limit 1;
  select c.id into v_chapter_id
  from public.chapters c
  join public.stories s on s.main_branch_id = c.branch_id
  where s.slug = 'the-river-that-remembers'
    and c.chapter_number = 1
  limit 1;

  if v_user_id is not null and v_chapter_id is not null then
    if not exists (
      select 1
      from public.bookmarks
      where user_id = v_user_id
        and chapter_id = v_chapter_id
        and tag = 'favorite'
    ) then
      insert into public.bookmarks (user_id, chapter_id, tag, is_public)
      values (v_user_id, v_chapter_id, 'favorite', false);
    end if;
  end if;
end $$;
