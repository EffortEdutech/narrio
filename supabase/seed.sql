do $$
declare
  v_user_id uuid;
  v_story_id uuid;
  v_branch_id uuid;
  v_chapter_id uuid;
begin
  select id into v_user_id
  from auth.users
  order by created_at asc
  limit 1;

  if v_user_id is null then
    raise notice 'No auth.users record found. Create a user first, then re-run seed.sql';
    return;
  end if;

  insert into public.profiles (id, username, display_name)
  values (v_user_id, 'demo_writer', 'Demo Writer')
  on conflict (id) do update
  set username = excluded.username,
      display_name = excluded.display_name;

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
    'A memory-haunted river town where every branch changes what the water knows.',
    'published',
    'public',
    true
  )
  on conflict (slug) do update
  set title = excluded.title,
      synopsis = excluded.synopsis,
      status = excluded.status,
      visibility = excluded.visibility
  returning id, main_branch_id into v_story_id, v_branch_id;

  if v_branch_id is null then
    select main_branch_id into v_branch_id
    from public.stories
    where id = v_story_id;
  end if;

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
    'When the water spoke her name',
    'when-the-water-spoke-her-name',
    'Lina returns to the riverbank and hears the current answer her grief.',
    true,
    timezone('utc', now()),
    v_user_id
  )
  on conflict (branch_id, chapter_number) do update
  set title = excluded.title,
      slug = excluded.slug,
      summary = excluded.summary,
      is_published = excluded.is_published,
      published_at = excluded.published_at
  returning id into v_chapter_id;

  insert into public.chapter_versions (
    chapter_id,
    version_number,
    title,
    excerpt,
    content_md,
    source,
    commit_message,
    is_current,
    created_by
  )
  values (
    v_chapter_id,
    1,
    'When the water spoke her name',
    'Lina returns to the riverbank and hears the current answer her grief.',
    '# Chapter 1\n\nLina stood at the ruined jetty where the river widened into dusk. The reeds hissed. The tide should have been moving out, yet the water drifted upstream as if it had changed its mind.\n\n"You came back late," the river said.\n\nShe did not run. Not this time. She stepped closer until the mud took her shoes and the cold reached her ankles. Somewhere beneath the surface, memory was moving like silver fish.',
    'human',
    'Seeded opening chapter',
    true,
    v_user_id
  )
  on conflict (chapter_id, version_number) do update
  set title = excluded.title,
      excerpt = excluded.excerpt,
      content_md = excluded.content_md,
      source = excluded.source,
      commit_message = excluded.commit_message,
      is_current = excluded.is_current;

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
end $$;
