-- Narrio Real Story Seed Pack v1
-- Target schema: uploaded 20260429-8-26am-Database-Schema.txt + current repo core schema.
-- Creates 8 login users, 12 written stories, 112 timeline/universe branches, 112 written chapter versions, and light social activity.
-- Password for all seeded users: test123
-- Dev/local only. Do not run on production.

begin;

create extension if not exists "pgcrypto";

-- 0) Remove previous Narrio real/demo seed story graph by known story slugs.
do $cleanup$
begin
  update public.stories
  set main_branch_id = null
  where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

  update public.story_branches
  set parent_branch_id = null,
      forked_from_version_id = null
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.comments
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.bookmarks
  where chapter_id in (
    select c.id
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  );

  delete from public.likes
  where chapter_version_id in (
    select cv.id
    from public.chapter_versions cv
    join public.chapters c on c.id = cv.chapter_id
    join public.stories s on s.id = c.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  );

  delete from public.follows
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.chapter_versions
  where chapter_id in (
    select c.id
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  );

  delete from public.chapters
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  update public.story_branches
  set parent_branch_id = null,
      forked_from_version_id = null
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.story_branches
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.stories
  where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');
end
$cleanup$;

-- 1) Auth users + public profiles.
do $users$
declare
  u record;
  v_identity_id_is_uuid boolean;
  v_has_provider_id boolean;
begin
  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'auth'
      and table_name = 'identities'
      and column_name = 'id'
      and udt_name = 'uuid'
  ) into v_identity_id_is_uuid;

  select exists (
    select 1
    from information_schema.columns
    where table_schema = 'auth'
      and table_name = 'identities'
      and column_name = 'provider_id'
  ) into v_has_provider_id;

  for u in
    select * from (values
    ('00000000-0000-4000-8000-000000000101'::uuid, 'demo.admin@narrio.test', 'demo_admin', 'Demo Admin', 'Platform steward for testing launch readiness and public discovery.'),
    ('00000000-0000-4000-8000-000000000102'::uuid, 'lina.writer@narrio.test', 'lina_writer', 'Lina Writer', 'Writes memory rivers, quiet fantasy, and first-person canon paths.'),
    ('00000000-0000-4000-8000-000000000103'::uuid, 'omar.forkcrafter@narrio.test', 'omar_forkcrafter', 'Omar Forkcrafter', 'Builds bold forks, action branches, and reader-choice timelines.'),
    ('00000000-0000-4000-8000-000000000104'::uuid, 'maya.reader@narrio.test', 'maya_reader', 'Maya Reader', 'Reads everything, bookmarks turning points, and follows public universes.'),
    ('00000000-0000-4000-8000-000000000105'::uuid, 'tariq.worldsmith@narrio.test', 'tariq_worldsmith', 'Tariq Worldsmith', 'Designs lore-heavy worlds and experimental map-like story branches.'),
    ('00000000-0000-4000-8000-000000000106'::uuid, 'sara.editor@narrio.test', 'sara_editor', 'Sara Editor', 'Tests publishing flow, closed canon, and polished chapter releases.'),
    ('00000000-0000-4000-8000-000000000107'::uuid, 'aiman.arc@narrio.test', 'aiman_arc', 'Aiman Arc', 'Explores time loops, parallel endings, and long-form community forks.'),
    ('00000000-0000-4000-8000-000000000108'::uuid, 'nora.pathfinder@narrio.test', 'nora_pathfinder', 'Nora Pathfinder', 'Finds hidden timelines and leaves waypoints for future readers.')
    ) as v(id, email, username, display_name, bio)
  loop
    insert into auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    )
    values (
      u.id,
      '00000000-0000-0000-0000-000000000000'::uuid,
      'authenticated',
      'authenticated',
      u.email,
      crypt('test123', gen_salt('bf')),
      timezone('utc', now()),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('username', u.username, 'display_name', u.display_name),
      timezone('utc', now()),
      timezone('utc', now()),
      '', '', '', ''
    )
    on conflict (id) do update
    set email = excluded.email,
        encrypted_password = excluded.encrypted_password,
        email_confirmed_at = excluded.email_confirmed_at,
        raw_app_meta_data = excluded.raw_app_meta_data,
        raw_user_meta_data = excluded.raw_user_meta_data,
        updated_at = timezone('utc', now());

    delete from auth.identities
    where user_id = u.id
      and provider = 'email';

    if v_has_provider_id and v_identity_id_is_uuid then
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider, provider_id,
          last_sign_in_at, created_at, updated_at
        ) values ($1::uuid, $2, $3, $4, $5, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email', u.email;
    elsif v_has_provider_id and not v_identity_id_is_uuid then
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider, provider_id,
          last_sign_in_at, created_at, updated_at
        ) values ($1::text, $2, $3, $4, $5, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id::text, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email', u.email;
    elsif (not v_has_provider_id) and v_identity_id_is_uuid then
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider,
          last_sign_in_at, created_at, updated_at
        ) values ($1::uuid, $2, $3, $4, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email';
    else
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider,
          last_sign_in_at, created_at, updated_at
        ) values ($1::text, $2, $3, $4, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id::text, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email';
    end if;

    insert into public.profiles (id, username, display_name, bio, avatar_url)
    values (
      u.id,
      u.username,
      u.display_name,
      u.bio,
      'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=' || u.username
    )
    on conflict (id) do update
    set username = excluded.username,
        display_name = excluded.display_name,
        bio = excluded.bio,
        avatar_url = excluded.avatar_url,
        updated_at = timezone('utc', now());
  end loop;
end
$users$;

-- 2) Written stories.
do $stories$
declare
  s record;
  v_author_id uuid;
begin
  for s in
    select *
    from jsonb_to_recordset($stories_json$[
  {
    "slug": "river-that-remembers",
    "title": "The River That Remembers",
    "author_username": "lina_writer",
    "level_label": "Level 1 · Starter Canon",
    "genre": "Memory Fantasy",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 1 · Starter Canon] [Memory Fantasy] A river town remembers every choice its people tried to forget. Nur Aina returns home and discovers that the water has kept the truth of her father's disappearance.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=The+River+That+Remembers",
    "created_at": "2026-01-04T09:00:00+00:00"
  },
  {
    "slug": "lanterns-over-seri-bay",
    "title": "Lanterns Over Seri Bay",
    "author_username": "omar_forkcrafter",
    "level_label": "Level 2 · Reader Choice Mystery",
    "genre": "Coastal Mystery",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 2 · Reader Choice Mystery] [Coastal Mystery] Every lantern released over Seri Bay carries a secret route home. When one lantern flies against the wind, Hafiz finds a map to the night his brother disappeared.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Lanterns+Over+Seri+Bay",
    "created_at": "2026-01-12T10:00:00+00:00"
  },
  {
    "slug": "clockmakers-orchard",
    "title": "The Clockmaker's Orchard",
    "author_username": "sara_editor",
    "level_label": "Level 3 · Growing World",
    "genre": "Clockwork Fable",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 3 · Growing World] [Clockwork Fable] An orchard grows clocks instead of fruit. Mira, apprentice to the last clockmaker, learns that every harvest opens a different year.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=The+Clockmakers+Orchard",
    "created_at": "2026-01-25T11:30:00+00:00"
  },
  {
    "slug": "orbit-of-the-last-musafir",
    "title": "Orbit of the Last Musafir",
    "author_username": "aiman_arc",
    "level_label": "Level 4 · Sci-Fi Pilgrimage",
    "genre": "Spiritual Sci-Fi",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 4 · Sci-Fi Pilgrimage] [Spiritual Sci-Fi] A lone traveller circles a broken moon, seeking the qiblah of a lost generation ship and the descendants who forgot Earth.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Orbit+of+the+Last+Musafir",
    "created_at": "2026-02-06T08:30:00+00:00"
  },
  {
    "slug": "glass-masjid-seven-moons",
    "title": "The Glass Masjid of Seven Moons",
    "author_username": "lina_writer",
    "level_label": "Level 5 · Reflective Epic",
    "genre": "Reflective Fantasy",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 5 · Reflective Epic] [Reflective Fantasy] Seven moons shine through a glass masjid. Each moon reveals a different prayer, test, and timeline for a young keeper of sacred light.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=The+Glass+Masjid+of+Seven+Moons",
    "created_at": "2026-02-19T14:00:00+00:00"
  },
  {
    "slug": "neon-keris-protocol",
    "title": "Neon Keris Protocol",
    "author_username": "omar_forkcrafter",
    "level_label": "Level 6 · Action Forkcraft",
    "genre": "Cyber Nusantara",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 6 · Action Forkcraft] [Cyber Nusantara] A cyber-Melayu city hides an ancient keris protocol inside its surveillance grid. Jebat, a street coder, must decide whether rebellion should cut or heal.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Neon+Keris+Protocol",
    "created_at": "2026-03-03T09:15:00+00:00"
  },
  {
    "slug": "ashes-paper-kingdom",
    "title": "Ashes of the Paper Kingdom",
    "author_username": "sara_editor",
    "level_label": "Level 7 · Closed Canon Showcase",
    "genre": "Political Fable",
    "status": "published",
    "visibility": "public",
    "allow_forks": false,
    "synopsis": "[Level 7 · Closed Canon Showcase] [Political Fable] A kingdom writes its laws on paper that burns when leaders lie. Scribe Laila discovers the royal archive has been kept cold by a terrible truth.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Ashes+of+the+Paper+Kingdom",
    "created_at": "2026-03-16T15:30:00+00:00"
  },
  {
    "slug": "child-borrowed-tomorrow",
    "title": "The Child Who Borrowed Tomorrow",
    "author_username": "aiman_arc",
    "level_label": "Level 8 · Private Draft Lab",
    "genre": "Time Loop",
    "status": "draft",
    "visibility": "private",
    "allow_forks": true,
    "synopsis": "[Level 8 · Private Draft Lab] [Time Loop] A child borrows one day from the future and must return it with interest. This private draft tests hidden timelines, draft chapters, and writer-only discovery.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=The+Child+Who+Borrowed+Tomorrow",
    "created_at": "2026-03-27T12:00:00+00:00"
  },
  {
    "slug": "bazaar-edge-of-sleep",
    "title": "Bazaar at the Edge of Sleep",
    "author_username": "tariq_worldsmith",
    "level_label": "Level 9 · Dream Market",
    "genre": "Dream Bazaar",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 9 · Dream Market] [Dream Bazaar] At the edge of sleep, traders sell memories, unfinished dreams, and alternate endings. Rumi enters the bazaar to buy back a dream stolen from his mother.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Bazaar+at+the+Edge+of+Sleep",
    "created_at": "2026-04-01T09:45:00+00:00"
  },
  {
    "slug": "atlas-rain-cities",
    "title": "Atlas of Rain-Cities",
    "author_username": "tariq_worldsmith",
    "level_label": "Level 10 · Unlisted Worldbook",
    "genre": "Worldbuilding Travelogue",
    "status": "published",
    "visibility": "unlisted",
    "allow_forks": true,
    "synopsis": "[Level 10 · Unlisted Worldbook] [Worldbuilding Travelogue] A cartographer maps cities where rain changes language, law, and destiny. This unlisted worldbook tests direct-link publishing and deeper timeline browsing.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Atlas+of+Rain-Cities",
    "created_at": "2026-04-07T17:10:00+00:00"
  },
  {
    "slug": "thousand-door-school",
    "title": "The Thousand Door School",
    "author_username": "nora_pathfinder",
    "level_label": "Level 11 · Community Forkcraft",
    "genre": "Academy Multiverse",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 11 · Community Forkcraft] [Academy Multiverse] A school with one thousand doors teaches students to enter consequences before opening choices. Nabila learns the doors are not lessons but warnings.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=The+Thousand+Door+School",
    "created_at": "2026-04-14T13:20:00+00:00"
  },
  {
    "slug": "garden-112th-star",
    "title": "Garden of the 112th Star",
    "author_username": "demo_admin",
    "level_label": "Level 12 · Flagship Multiverse",
    "genre": "Flagship Cosmic Fantasy",
    "status": "published",
    "visibility": "public",
    "allow_forks": true,
    "synopsis": "[Level 12 · Flagship Multiverse] [Flagship Cosmic Fantasy] A cosmic garden grows around the 112th star, where every petal is a possible universe and every gardener must decide which worlds deserve water.",
    "cover_url": "https://placehold.co/1200x720/111827/F8E7B9?text=Garden+of+the+112th+Star",
    "created_at": "2026-04-22T10:05:00+00:00"
  }
]$stories_json$::jsonb)
      as x(
        slug text,
        title text,
        author_username text,
        level_label text,
        genre text,
        status text,
        visibility text,
        allow_forks boolean,
        synopsis text,
        cover_url text,
        created_at timestamptz
      )
  loop
    select id into v_author_id
    from public.profiles
    where username = s.author_username;

    if v_author_id is null then
      raise exception 'Missing author profile username: %', s.author_username;
    end if;

    insert into public.stories (
      author_id,
      forked_from_story_id,
      title,
      slug,
      synopsis,
      cover_url,
      status,
      visibility,
      allow_forks,
      main_branch_id,
      created_at,
      updated_at
    )
    values (
      v_author_id,
      null,
      s.title,
      s.slug,
      s.synopsis,
      s.cover_url,
      s.status,
      s.visibility,
      s.allow_forks,
      null,
      s.created_at,
      timezone('utc', now())
    );
  end loop;
end
$stories$;

-- 3) 112 written universe/timeline branches and chapter versions.
do $branches$
declare
  b record;
  v_story_id uuid;
  v_story_status text;
  v_author_id uuid;
  v_branch_id uuid;
  v_parent_branch_id uuid;
  v_forked_from_version_id uuid;
  v_chapter_id uuid;
  v_version_id uuid;
  v_is_published boolean;
begin
  for b in
    select *
    from jsonb_to_recordset($branches_json$[
  {
    "story_slug": "river-that-remembers",
    "author_username": "lina_writer",
    "universe_no": 1,
    "branch_name": "Universe 001 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for The River That Remembers. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The River Asks for a Name",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Nur Aina hears the river speak her name and finds a brass key tied to her missing father’s memory.",
    "excerpt": "When Nur Aina returned to Kampung Seraga, the river spoke her name before her mother did.",
    "content_md": "# Chapter 1 — The River Asks for a Name\n\nWhen Nur Aina returned to Kampung Seraga, the river spoke her name before her mother did.\n\nIt did not speak like a person. It knocked driftwood against the jetty in the rhythm of her childhood nickname, three soft taps and one impatient scrape. It breathed through the reeds behind Masjid Lama Seraga. It sent a curl of brown water over her sandals and laid a brass key at her feet, bright as if it had never slept in mud.\n\nAina should have walked away. Everyone in the village knew the river remembered too much. It remembered quarrels after the mouths that made them had died. It remembered unpaid debts, lost rings, promises shouted during floods, and the names of children who had once sworn they would never leave. When her father vanished during the monsoon seven years ago, the elders said the river had taken him because he had asked the wrong question.\n\nBut the key was warm.\n\nHer mother, Mak Yam, stood at the top of the steps with a basket of wet kain batik pressed to her hip. “Do not answer it,” she said, as if the river had called from a doorway. “A river that remembers also accuses.”\n\nAina closed her fist around the key. At once, the jetty changed. The planks were new again. Rain fell upward. Her father stood by the flood-gate in his yellow raincoat, arguing with a man whose face had been scratched out of the memory. In her father’s hand was a ledger wrapped in oilcloth. In the faceless man’s hand was a knife made from black river stone.\n\nThe vision broke when a hornbill cried from the mangroves.\n\nBy sunset, half the village had heard that Aina had come home and that the river had chosen her. By night, the flood-gate keeper locked his hut from the inside. And before dawn, Aina tucked the brass key beneath her sleeve and walked toward the gate where her father had last been seen.\n\nThe river followed beside her, quiet, swollen with the names it had not yet returned."
  },
  {
    "story_slug": "river-that-remembers",
    "author_username": "lina_writer",
    "universe_no": 2,
    "branch_name": "Universe 002 · The Key Beneath the Minaret",
    "branch_slug": "u002-the-key-beneath-the-minaret",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The River That Remembers: The Key Beneath the Minaret. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Key Beneath the Minaret",
    "chapter_slug": "chapter-1-the-key-beneath-the-minaret",
    "summary": "Nur Aina faces a different version of the first turning point in Kampung Seraga: the key beneath the minaret.",
    "excerpt": "Nur Aina found a silver seed lodged between the flood-gate teeth, wrapped in weed and burnt sugar.",
    "content_md": "# Chapter 1 — The Key Beneath the Minaret\n\nNur Aina found a silver seed lodged between the flood-gate teeth, wrapped in weed and burnt sugar. The river had placed it carefully, the way a mother places medicine beside a sleeping child.\n\nWhen she touched it, the water showed her a memory not from the past but from a path the village had almost chosen. In that path, the logging road reached the mosque steps, and every family sold one forgotten name to keep the school open.\n\nThe old flood-gate keeper waited on the bank with his ledger tucked under his arm. “Some memories poison the living,” he said. Aina heard her father's voice under the current, not answering, only breathing.\n\nShe could trust the oldest enemy, or she could doubt the kindest friend. Before she decided, the sky lowered as if listening. The river rose to her knees, ready to remember her choice forever."
  },
  {
    "story_slug": "river-that-remembers",
    "author_username": "lina_writer",
    "universe_no": 3,
    "branch_name": "Universe 003 · The Flood That Forgave",
    "branch_slug": "u003-the-flood-that-forgave",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The River That Remembers: The Flood That Forgave. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Flood That Forgave",
    "chapter_slug": "chapter-1-the-flood-that-forgave",
    "summary": "Nur Aina faces a different version of the first turning point in Kampung Seraga: the flood that forgave.",
    "excerpt": "Nur Aina found a glass bird lodged between the flood-gate teeth, wrapped in weed and sea iron.",
    "content_md": "# Chapter 1 — The Flood That Forgave\n\nNur Aina found a glass bird lodged between the flood-gate teeth, wrapped in weed and sea iron. The river had placed it carefully, the way a mother places medicine beside a sleeping child.\n\nWhen she touched it, the water showed her a memory not from the past but from a path the village had almost chosen. In that path, the logging road reached the mosque steps, and every family sold one forgotten name to keep the school open.\n\nThe old flood-gate keeper waited on the bank with his ledger tucked under his arm. “Some memories poison the living,” he said. Aina heard her father's voice under the current, not answering, only breathing.\n\nShe could break a rule to save a name, or she could obey the rule and lose a face. Before she decided, the floor remembered footsteps that had never happened. The river rose to her knees, ready to remember her choice forever."
  },
  {
    "story_slug": "lanterns-over-seri-bay",
    "author_username": "omar_forkcrafter",
    "universe_no": 4,
    "branch_name": "Universe 004 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Lanterns Over Seri Bay. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Lantern Against the Wind",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Hafiz sees a lantern fly against the monsoon wind and reads the first clue to his missing brother.",
    "excerpt": "On the seventh night of the Seri Bay lantern festival, Hafiz released no lantern of his own.",
    "content_md": "# Chapter 1 — The Lantern Against the Wind\n\nOn the seventh night of the Seri Bay lantern festival, Hafiz released no lantern of his own.\n\nHe stood ankle-deep in the tide beside the old fish market, watching other people trust the sky with their secrets. Children whispered into red paper globes. Widows tied folded notes beneath yellow flames. Fishermen sent blue lanterns toward the black mouth of the bay, where the water turned deep and boats stopped answering their radios.\n\nHafiz kept both hands in his pockets. His secret was too heavy for paper.\n\nThree years ago, his brother Imran had sailed out to inspect the reef lights and never returned. The harbour council called it weather. The fishermen called it bad luck. Hafiz called it the kind of lie that learned to wear official stamps.\n\nThen one lantern flew against the wind.\n\nIt was small, badly folded, and lit with a blue flame that did not flicker. While hundreds of lanterns drifted east over the water, this one cut west, straight toward Hafiz. People laughed at first. Then the lantern lowered until it hovered before his face, close enough for him to smell salt, smoke, and the old oil of Imran’s raincoat.\n\nA strip of chart paper hung beneath it.\n\nHafiz reached for the knot. The moment his fingers touched the string, every sound in the bay fell away—the drums, the sellers, the splash of children chasing each other through the shallows. On the chart, someone had marked three places: the old reef tower, the abandoned pearl warehouse, and a house on Jalan Camar with its roof drawn in red.\n\nOn the back of the paper was Imran’s handwriting.\n\nDo not trust the lantern master.\n\nAcross the market, the lantern master smiled from beneath his white umbrella, though Hafiz had not looked at him. Behind that smile, the night folded open like a map. Hafiz tucked the chart into his shirt and stepped into the crowd, following the blue lantern as it turned toward the pier no festival boat was allowed to use."
  },
  {
    "story_slug": "lanterns-over-seri-bay",
    "author_username": "omar_forkcrafter",
    "universe_no": 5,
    "branch_name": "Universe 005 · The Lantern with No Flame",
    "branch_slug": "u005-the-lantern-with-no-flame",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Lanterns Over Seri Bay: The Lantern with No Flame. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Lantern with No Flame",
    "chapter_slug": "chapter-1-the-lantern-with-no-flame",
    "summary": "Hafiz faces a different version of the first turning point in Seri Bay: the lantern with no flame.",
    "excerpt": "Hafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and mango leaves.",
    "content_md": "# Chapter 1 — The Lantern with No Flame\n\nHafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and mango leaves. Beneath the pier, he found a brass bowl swinging from a nail as if the tide had been using it as a compass.\n\nThe lantern dipped. Its flame drew Imran’s silhouette across the water: one hand raised, one warning too late. From the pearl warehouse came the scrape of crates being moved in darkness.\n\nA girl in a yellow raincoat stepped from behind the stilts. “Your brother was not taken by the sea,” she said. “He was hired to lie to it.” In her palm lay a council token stamped with tomorrow’s date.\n\nHafiz could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and every boat bell in the harbour rang though no wind touched them."
  },
  {
    "story_slug": "lanterns-over-seri-bay",
    "author_username": "omar_forkcrafter",
    "universe_no": 6,
    "branch_name": "Universe 006 · The Fisherman's Daughter Lies",
    "branch_slug": "u006-the-fishermans-daughter-lies",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Lanterns Over Seri Bay: The Fisherman's Daughter Lies. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Fisherman's Daughter Lies",
    "chapter_slug": "chapter-1-the-fishermans-daughter-lies",
    "summary": "Hafiz faces a different version of the first turning point in Seri Bay: the fisherman's daughter lies.",
    "excerpt": "Hafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and river mud.",
    "content_md": "# Chapter 1 — The Fisherman's Daughter Lies\n\nHafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and river mud. Beneath the pier, he found a red umbrella swinging from a nail as if the tide had been using it as a compass.\n\nThe lantern dipped. Its flame drew Imran’s silhouette across the water: one hand raised, one warning too late. From the pearl warehouse came the scrape of crates being moved in darkness.\n\nA girl in a yellow raincoat stepped from behind the stilts. “Your brother was not taken by the sea,” she said. “He was hired to lie to it.” In her palm lay a council token stamped with tomorrow’s date.\n\nHafiz could forgive the betrayer, or he could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and every boat bell in the harbour rang though no wind touched them."
  },
  {
    "story_slug": "lanterns-over-seri-bay",
    "author_username": "omar_forkcrafter",
    "universe_no": 7,
    "branch_name": "Universe 007 · The Pier Below the Tide",
    "branch_slug": "u007-the-pier-below-the-tide",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Lanterns Over Seri Bay: The Pier Below the Tide. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Pier Below the Tide",
    "chapter_slug": "chapter-1-the-pier-below-the-tide",
    "summary": "Hafiz faces a different version of the first turning point in Seri Bay: the pier below the tide.",
    "excerpt": "Hafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and coconut oil.",
    "content_md": "# Chapter 1 — The Pier Below the Tide\n\nHafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and coconut oil. Beneath the pier, he found a copper ring swinging from a nail as if the tide had been using it as a compass.\n\nThe lantern dipped. Its flame drew Imran’s silhouette across the water: one hand raised, one warning too late. From the pearl warehouse came the scrape of crates being moved in darkness.\n\nA girl in a yellow raincoat stepped from behind the stilts. “Your brother was not taken by the sea,” she said. “He was hired to lie to it.” In her palm lay a council token stamped with tomorrow’s date.\n\nHafiz could turn back before crossing the bridge, or he could cross and become responsible. Then their shadow arrived one step early, and every boat bell in the harbour rang though no wind touched them."
  },
  {
    "story_slug": "lanterns-over-seri-bay",
    "author_username": "omar_forkcrafter",
    "universe_no": 8,
    "branch_name": "Universe 008 · The Net of Blue Thread",
    "branch_slug": "u008-the-net-of-blue-thread",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Lanterns Over Seri Bay: The Net of Blue Thread. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Net of Blue Thread",
    "chapter_slug": "chapter-1-the-net-of-blue-thread",
    "summary": "Hafiz faces a different version of the first turning point in Seri Bay: the net of blue thread.",
    "excerpt": "Hafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and rain on tin.",
    "content_md": "# Chapter 1 — The Net of Blue Thread\n\nHafiz followed the blue lantern until Seri Bay narrowed into alleys of rope, diesel, and rain on tin. Beneath the pier, he found a star-shaped scar swinging from a nail as if the tide had been using it as a compass.\n\nThe lantern dipped. Its flame drew Imran’s silhouette across the water: one hand raised, one warning too late. From the pearl warehouse came the scrape of crates being moved in darkness.\n\nA girl in a yellow raincoat stepped from behind the stilts. “Your brother was not taken by the sea,” she said. “He was hired to lie to it.” In her palm lay a council token stamped with tomorrow’s date.\n\nHafiz could ask the wrong question, or he could refuse the answer everyone wanted. Then a name vanished from every signboard, and every boat bell in the harbour rang though no wind touched them."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 9,
    "branch_name": "Universe 009 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for The Clockmaker's Orchard. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Hour That Fell Like Fruit",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Mira catches a falling watch-fruit and hears an hour from a year that has not happened yet.",
    "excerpt": "The clocks ripened early that year. Mira heard them before sunrise: hundreds of tiny hearts ticking above the orchard path, hidden among glass leaves and silver branches.",
    "content_md": "# Chapter 1 — The Hour That Fell Like Fruit\n\nThe clocks ripened early that year.\n\nMira heard them before sunrise: hundreds of tiny hearts ticking above the orchard path, hidden among glass leaves and silver branches. She ran barefoot through the dew with her apron full of tools, afraid that if she arrived late, time would bruise on the ground and spill minutes into the soil.\n\nMaster Jamil was already there, leaning on his cane beneath the oldest tree. He had wound the town clocks for forty-three years and lied about his age for forty-four. “Do not touch the green one,” he said without turning. “It has not decided whether it belongs to you.”\n\nMira looked up.\n\nA pocket watch hung from a high branch, its enamel case the colour of young mango skin. Unlike the others, it did not tick forward. It ticked inward, drawing silence into itself until even the cicadas paused. On its lid, where every clock-fruit carried an engraved year, someone had scratched a date that made Mira’s throat close: tomorrow.\n\nThe branch snapped.\n\nMira caught the watch against her chest. At once, the orchard vanished. She stood in the town square at noon, though the sun was black. People gathered around the clock tower while Mayor Rahman held Master Jamil’s cane like a trophy. Behind him, men with axes waited beside carts lined with velvet.\n\n“By order of progress,” the mayor announced, “the orchard will be harvested in full.”\n\nThe vision ended with the sound of the first tree being cut.\n\nBack in the dawn, Master Jamil’s face had gone pale. “Some hours fall because they are ready,” he whispered. “Some fall because the future is shouting.”\n\nMira closed the green watch. Its chain wrapped around her wrist by itself, gentle as a question. From beyond the orchard wall came the creak of wagon wheels and the murmur of men arriving too early.\n\nFor the first time in her apprenticeship, Mira did not wait for instructions. She pocketed tomorrow and ran."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 10,
    "branch_name": "Universe 010 · The Orchard of Borrowed Noon",
    "branch_slug": "u010-the-orchard-of-borrowed-noon",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Clockmaker's Orchard: The Orchard of Borrowed Noon. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Orchard of Borrowed Noon",
    "chapter_slug": "chapter-1-the-orchard-of-borrowed-noon",
    "summary": "Mira faces a different version of the first turning point in Jelutong Orchard: the orchard of borrowed noon.",
    "excerpt": "Mira discovered a cracked bowl of ash growing inside a clock-fruit that had split before harvest.",
    "content_md": "# Chapter 1 — The Orchard of Borrowed Noon\n\nMira discovered a cracked bowl of ash growing inside a clock-fruit that had split before harvest. It smelled of cold tea and ticked in the voice of Master Jamil when he was young.\n\nThe green watch on her wrist opened one stolen minute. In that minute, she saw the mayor’s velvet cart entering the orchard and the first silver tree bowing as if ashamed to be cut.\n\n“You cannot save every hour,” Master Jamil warned, but his hands trembled around the pruning shears. Mira knew then that he had already spent a memory to hide this branch of time from her.\n\nShe could protect the weakest witness, or she could protect the dangerous evidence. As the choice sharpened, the witnesses began to whisper in unison, and the orchard dropped all its clocks at once."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 11,
    "branch_name": "Universe 011 · The Watch That Counted Backward",
    "branch_slug": "u011-the-watch-that-counted-backward",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Clockmaker's Orchard: The Watch That Counted Backward. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Watch That Counted Backward",
    "chapter_slug": "chapter-1-the-watch-that-counted-backward",
    "summary": "Mira faces a different version of the first turning point in Jelutong Orchard: the watch that counted backward.",
    "excerpt": "Mira discovered a white feather growing inside a clock-fruit that had split before harvest.",
    "content_md": "# Chapter 1 — The Watch That Counted Backward\n\nMira discovered a white feather growing inside a clock-fruit that had split before harvest. It smelled of library dust and ticked in the voice of Master Jamil when he was young.\n\nThe green watch on her wrist opened one stolen minute. In that minute, she saw the mayor’s velvet cart entering the orchard and the first silver tree bowing as if ashamed to be cut.\n\n“You cannot save every hour,” Master Jamil warned, but his hands trembled around the pruning shears. Mira knew then that he had already spent a memory to hide this branch of time from her.\n\nShe could carry the message alone, or she could share the burden with a rival. As the choice sharpened, the message changed handwriting, and the orchard dropped all its clocks at once."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 12,
    "branch_name": "Universe 012 · The Mayor's Velvet Cart",
    "branch_slug": "u012-the-mayors-velvet-cart",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Clockmaker's Orchard: The Mayor's Velvet Cart. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Mayor's Velvet Cart",
    "chapter_slug": "chapter-1-the-mayors-velvet-cart",
    "summary": "Mira faces a different version of the first turning point in Jelutong Orchard: the mayor's velvet cart.",
    "excerpt": "Mira discovered a cracked mirror growing inside a clock-fruit that had split before harvest.",
    "content_md": "# Chapter 1 — The Mayor's Velvet Cart\n\nMira discovered a cracked mirror growing inside a clock-fruit that had split before harvest. It smelled of jasmine smoke and ticked in the voice of Master Jamil when he was young.\n\nThe green watch on her wrist opened one stolen minute. In that minute, she saw the mayor’s velvet cart entering the orchard and the first silver tree bowing as if ashamed to be cut.\n\n“You cannot save every hour,” Master Jamil warned, but his hands trembled around the pruning shears. Mira knew then that he had already spent a memory to hide this branch of time from her.\n\nShe could tell the truth before the town was ready, or she could hide the proof until morning. As the choice sharpened, a bell rang from a place with no tower, and the orchard dropped all its clocks at once."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 13,
    "branch_name": "Universe 013 · The Tree That Grew a War",
    "branch_slug": "u013-the-tree-that-grew-a-war",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Clockmaker's Orchard: The Tree That Grew a War. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Tree That Grew a War",
    "chapter_slug": "chapter-1-the-tree-that-grew-a-war",
    "summary": "Mira faces a different version of the first turning point in Jelutong Orchard: the tree that grew a war.",
    "excerpt": "Mira discovered a black kite growing inside a clock-fruit that had split before harvest.",
    "content_md": "# Chapter 1 — The Tree That Grew a War\n\nMira discovered a black kite growing inside a clock-fruit that had split before harvest. It smelled of wet earth and ticked in the voice of Master Jamil when he was young.\n\nThe green watch on her wrist opened one stolen minute. In that minute, she saw the mayor’s velvet cart entering the orchard and the first silver tree bowing as if ashamed to be cut.\n\n“You cannot save every hour,” Master Jamil warned, but his hands trembled around the pruning shears. Mira knew then that he had already spent a memory to hide this branch of time from her.\n\nShe could open the locked room, or she could leave the lock untouched. As the choice sharpened, someone they loved called from the wrong side, and the orchard dropped all its clocks at once."
  },
  {
    "story_slug": "clockmakers-orchard",
    "author_username": "sara_editor",
    "universe_no": 14,
    "branch_name": "Universe 014 · The Apprentice Saves One Minute",
    "branch_slug": "u014-the-apprentice-saves-one-minute",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Clockmaker's Orchard: The Apprentice Saves One Minute. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Apprentice Saves One Minute",
    "chapter_slug": "chapter-1-the-apprentice-saves-one-minute",
    "summary": "Mira faces a different version of the first turning point in Jelutong Orchard: the apprentice saves one minute.",
    "excerpt": "Mira discovered a paper crown growing inside a clock-fruit that had split before harvest.",
    "content_md": "# Chapter 1 — The Apprentice Saves One Minute\n\nMira discovered a paper crown growing inside a clock-fruit that had split before harvest. It smelled of old rain and ticked in the voice of Master Jamil when he was young.\n\nThe green watch on her wrist opened one stolen minute. In that minute, she saw the mayor’s velvet cart entering the orchard and the first silver tree bowing as if ashamed to be cut.\n\n“You cannot save every hour,” Master Jamil warned, but his hands trembled around the pruning shears. Mira knew then that he had already spent a memory to hide this branch of time from her.\n\nShe could confess the secret aloud, or she could write the secret where no one could erase it. As the choice sharpened, every lamp in the street leaned toward them, and the orchard dropped all its clocks at once."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 15,
    "branch_name": "Universe 015 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Orbit of the Last Musafir. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Compass That Refused North",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Idris receives an astrolabe compass that points through the broken moon toward a hidden colony.",
    "excerpt": "The last musafir woke before the ship called dawn. Idris floated in the narrow sleep-cell of Safinah-7 with his palm against the wall, feeling the engines stutter beneath three generations of repairs.",
    "content_md": "# Chapter 1 — The Compass That Refused North\n\nThe last musafir woke before the ship called dawn.\n\nIdris floated in the narrow sleep-cell of Safinah-7 with his palm against the wall, feeling the engines stutter beneath three generations of repairs. Outside, the broken moon rolled past the observation blister in two pieces, white and wounded. Every ninety minutes the ship crossed its shadow. Every ninety minutes the elders told the children the same story: Earth was behind them, the future ahead, and there was no need to look down.\n\nIdris had been paid to look down.\n\nThe astrolabe arrived wrapped in a prayer mat older than the ship. Its brass rings turned without touching each other. Tiny inscriptions in Malay, Arabic, and a language no archive admitted knowing crawled along the rim. When Idris set it loose in the air, it did not spin toward magnetic north, solar east, or the approved qiblah vector printed in every sleeping bay.\n\nIt pointed straight through the moon.\n\nHis grandmother’s voice crackled from the message bead hidden inside the wrapping. “If you are hearing this, the council has erased one direction too many. Find Surah Colony. Bring back the children who were written out of the maps.”\n\nThe ship’s public speakers chimed for morning prayer. Across Safinah-7, ten thousand people turned toward the council-approved star. Idris turned toward the cracked moon and felt the astrolabe warm like a living thing.\n\nThen the door to his cell unlocked from the outside.\n\nCommander Salwa entered with two quiet guards and a face arranged into official sorrow. “Give me the compass,” she said. “Some directions are mercy to lose.”\n\nIdris closed his fist around the astrolabe. Through the blister, the moon’s fracture glowed with city lights no one had taught him to see.\n\nFor the first time in his life, the ship felt less like a home than a question orbiting a lie."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 16,
    "branch_name": "Universe 016 · The Colony Behind the Moon",
    "branch_slug": "u016-the-colony-behind-the-moon",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Colony Behind the Moon. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Colony Behind the Moon",
    "chapter_slug": "chapter-1-the-colony-behind-the-moon",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the colony behind the moon.",
    "excerpt": "Idris found a black kite floating in the airlock, turning slowly in the sterile smell of wet earth.",
    "content_md": "# Chapter 1 — The Colony Behind the Moon\n\nIdris found a black kite floating in the airlock, turning slowly in the sterile smell of wet earth. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could open the locked room, or he could leave the lock untouched. Then someone they loved called from the wrong side, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 17,
    "branch_name": "Universe 017 · The Prayer Map Rewrites Itself",
    "branch_slug": "u017-the-prayer-map-rewrites-itself",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Prayer Map Rewrites Itself. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Prayer Map Rewrites Itself",
    "chapter_slug": "chapter-1-the-prayer-map-rewrites-itself",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the prayer map rewrites itself.",
    "excerpt": "Idris found a paper crown floating in the airlock, turning slowly in the sterile smell of old rain.",
    "content_md": "# Chapter 1 — The Prayer Map Rewrites Itself\n\nIdris found a paper crown floating in the airlock, turning slowly in the sterile smell of old rain. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could confess the secret aloud, or he could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 18,
    "branch_name": "Universe 018 · The Commander Opens the Airlock",
    "branch_slug": "u018-the-commander-opens-the-airlock",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Commander Opens the Airlock. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Commander Opens the Airlock",
    "chapter_slug": "chapter-1-the-commander-opens-the-airlock",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the commander opens the airlock.",
    "excerpt": "Idris found a brass bowl floating in the airlock, turning slowly in the sterile smell of mango leaves.",
    "content_md": "# Chapter 1 — The Commander Opens the Airlock\n\nIdris found a brass bowl floating in the airlock, turning slowly in the sterile smell of mango leaves. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 19,
    "branch_name": "Universe 019 · The Astrolabe Chooses Earth",
    "branch_slug": "u019-the-astrolabe-chooses-earth",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Astrolabe Chooses Earth. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Astrolabe Chooses Earth",
    "chapter_slug": "chapter-1-the-astrolabe-chooses-earth",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the astrolabe chooses earth.",
    "excerpt": "Idris found a red umbrella floating in the airlock, turning slowly in the sterile smell of river mud.",
    "content_md": "# Chapter 1 — The Astrolabe Chooses Earth\n\nIdris found a red umbrella floating in the airlock, turning slowly in the sterile smell of river mud. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could forgive the betrayer, or he could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 20,
    "branch_name": "Universe 020 · The Children of Surah Colony",
    "branch_slug": "u020-the-children-of-surah-colony",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Children of Surah Colony. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Children of Surah Colony",
    "chapter_slug": "chapter-1-the-children-of-surah-colony",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the children of surah colony.",
    "excerpt": "Idris found a copper ring floating in the airlock, turning slowly in the sterile smell of coconut oil.",
    "content_md": "# Chapter 1 — The Children of Surah Colony\n\nIdris found a copper ring floating in the airlock, turning slowly in the sterile smell of coconut oil. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could turn back before crossing the bridge, or he could cross and become responsible. Then their shadow arrived one step early, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "orbit-of-the-last-musafir",
    "author_username": "aiman_arc",
    "universe_no": 21,
    "branch_name": "Universe 021 · The Orbit That Would Not Decay",
    "branch_slug": "u021-the-orbit-that-would-not-decay",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Orbit of the Last Musafir: The Orbit That Would Not Decay. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Orbit That Would Not Decay",
    "chapter_slug": "chapter-1-the-orbit-that-would-not-decay",
    "summary": "Idris faces a different version of the first turning point in the pilgrim vessel Safinah-7: the orbit that would not decay.",
    "excerpt": "Idris found a star-shaped scar floating in the airlock, turning slowly in the sterile smell of rain on tin.",
    "content_md": "# Chapter 1 — The Orbit That Would Not Decay\n\nIdris found a star-shaped scar floating in the airlock, turning slowly in the sterile smell of rain on tin. The astrolabe compass locked onto it and projected a prayer line through the broken moon.\n\nBeyond the fracture, Surah Colony blinked in code: not a distress signal, but a lullaby. Children were singing in a dialect the ship records claimed had died on Earth.\n\nCommander Salwa’s voice came over the suit channel. “Return to approved orbit. That colony is a wound we sealed.” Idris looked at the moon and understood that some seals were only cages with better names.\n\nHe could ask the wrong question, or he could refuse the answer everyone wanted. Then a name vanished from every signboard, and Safinah-7 drifted one degree away from obedience."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 22,
    "branch_name": "Universe 022 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for The Glass Masjid of Seven Moons. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The First Moon Opens",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Safiya enters the glass masjid as the first moon reveals the prayer she has avoided.",
    "excerpt": "The glass masjid did not cast shadows. At fajr, when the first of seven moons lowered into the western sky, its light passed through every wall of the prayer hall and turned the floor into a lake of silver script.",
    "content_md": "# Chapter 1 — The First Moon Opens\n\nThe glass masjid did not cast shadows.\n\nAt fajr, when the first of seven moons lowered into the western sky, its light passed through every wall of the prayer hall and turned the floor into a lake of silver script. Safiya walked barefoot across the words, carrying the broom of the keeper’s apprentice, and tried not to read the sentence that followed her steps.\n\nAsk forgiveness before you ask to be chosen.\n\nShe swept faster.\n\nHer grandmother, Keeper Maryam, watched from beneath the mihrab carved from clear stone. “The masjid is not impressed by speed,” she said. “It has outwaited kings.”\n\nSafiya bit her answer in half. Outside, the people of Qamarayn Valley were already gathering with jars, mirrors, sick children, broken contracts, and questions wrapped in cloth. On ordinary mornings, the masjid lent moonlight to those who came honestly. On rare mornings, it refused them. On dangerous mornings, it showed them the prayer they had avoided until the prayer became a door.\n\nToday the first moon opened.\n\nThe glass walls rang once. The lake of script rose around Safiya’s ankles. She saw herself older, dressed in the keeper’s white, standing alone while the seventh moon blackened above the valley. She saw people pounding on the transparent doors. She saw her own hands locking them.\n\n“No,” she whispered.\n\nThe vision changed. Her father appeared beside the ablution pool, though he had left the valley years ago after accusing the keepers of loving miracles more than people. He held out a shard of moon-glass. “Light can be guarded until it becomes a cage,” he said. “Choose carefully what you protect.”\n\nWhen Safiya opened her eyes, the shard lay in her palm.\n\nOutside, someone screamed. The seventh moon, pale even in daylight, had acquired a bruise of darkness along its rim. Keeper Maryam leaned on her staff, suddenly looking older than stone.\n\nSafiya closed her fingers around the shard and felt the masjid listening for the prayer she still refused to say."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 23,
    "branch_name": "Universe 023 · The Moon of Unsaid Apologies",
    "branch_slug": "u023-the-moon-of-unsaid-apologies",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Moon of Unsaid Apologies. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Moon of Unsaid Apologies",
    "chapter_slug": "chapter-1-the-moon-of-unsaid-apologies",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the moon of unsaid apologies.",
    "excerpt": "Safiya saw a sleeping cat reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Moon of Unsaid Apologies\n\nSafiya saw a sleeping cat reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of ozone, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could wake the city from its dream, or she could let the dream finish speaking. Above the mihrab, the moon blinked once and changed colour, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 24,
    "branch_name": "Universe 024 · The Door of Clear Stone",
    "branch_slug": "u024-the-door-of-clear-stone",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Door of Clear Stone. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Door of Clear Stone",
    "chapter_slug": "chapter-1-the-door-of-clear-stone",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the door of clear stone.",
    "excerpt": "Safiya saw a cracked bowl of ash reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Door of Clear Stone\n\nSafiya saw a cracked bowl of ash reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of cold tea, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could protect the weakest witness, or she could protect the dangerous evidence. Above the mihrab, the witnesses began to whisper in unison, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 25,
    "branch_name": "Universe 025 · The Keeper Locks the Valley",
    "branch_slug": "u025-the-keeper-locks-the-valley",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Keeper Locks the Valley. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Keeper Locks the Valley",
    "chapter_slug": "chapter-1-the-keeper-locks-the-valley",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the keeper locks the valley.",
    "excerpt": "Safiya saw a white feather reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Keeper Locks the Valley\n\nSafiya saw a white feather reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of library dust, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could carry the message alone, or she could share the burden with a rival. Above the mihrab, the message changed handwriting, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 26,
    "branch_name": "Universe 026 · The Father Carries the Shard",
    "branch_slug": "u026-the-father-carries-the-shard",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Father Carries the Shard. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Father Carries the Shard",
    "chapter_slug": "chapter-1-the-father-carries-the-shard",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the father carries the shard.",
    "excerpt": "Safiya saw a cracked mirror reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Father Carries the Shard\n\nSafiya saw a cracked mirror reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of jasmine smoke, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could tell the truth before the town was ready, or she could hide the proof until morning. Above the mihrab, a bell rang from a place with no tower, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 27,
    "branch_name": "Universe 027 · The Seventh Moon Darkens",
    "branch_slug": "u027-the-seventh-moon-darkens",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Seventh Moon Darkens. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Seventh Moon Darkens",
    "chapter_slug": "chapter-1-the-seventh-moon-darkens",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the seventh moon darkens.",
    "excerpt": "Safiya saw a black kite reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Seventh Moon Darkens\n\nSafiya saw a black kite reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of wet earth, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could open the locked room, or she could leave the lock untouched. Above the mihrab, someone they loved called from the wrong side, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 28,
    "branch_name": "Universe 028 · The Prayer That Refuses Pride",
    "branch_slug": "u028-the-prayer-that-refuses-pride",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The Prayer That Refuses Pride. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Prayer That Refuses Pride",
    "chapter_slug": "chapter-1-the-prayer-that-refuses-pride",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the prayer that refuses pride.",
    "excerpt": "Safiya saw a paper crown reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The Prayer That Refuses Pride\n\nSafiya saw a paper crown reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of old rain, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could confess the secret aloud, or she could write the secret where no one could erase it. Above the mihrab, every lamp in the street leaned toward them, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "glass-masjid-seven-moons",
    "author_username": "lina_writer",
    "universe_no": 29,
    "branch_name": "Universe 029 · The River of Reflected Stars",
    "branch_slug": "u029-the-river-of-reflected-stars",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of The Glass Masjid of Seven Moons: The River of Reflected Stars. The prose is written as a real scene, not filler text.",
    "chapter_title": "The River of Reflected Stars",
    "chapter_slug": "chapter-1-the-river-of-reflected-stars",
    "summary": "Safiya faces a different version of the first turning point in Qamarayn Valley: the river of reflected stars.",
    "excerpt": "Safiya saw a brass bowl reflected in the ablution pool though nothing like it existed in the prayer hall.",
    "content_md": "# Chapter 1 — The River of Reflected Stars\n\nSafiya saw a brass bowl reflected in the ablution pool though nothing like it existed in the prayer hall. The water smelled faintly of mango leaves, and the first moon trembled behind the glass wall.\n\nThe shard in her palm showed a valley where the masjid doors were open, yet no one entered because every prayer inside had learned to accuse. Her father stood at the threshold, older, waiting for her to choose humility before power.\n\nKeeper Maryam whispered, “The moons do not test the loud sins. They test the beautiful excuses.” Outside, pilgrims gathered with jars of darkening light.\n\nSafiya could trade a memory for time, or she could keep the memory and risk the future. Above the mihrab, the hour in their hand began to bruise, and the seventh moon dimmed another finger’s width."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 30,
    "branch_name": "Universe 030 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Neon Keris Protocol. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "Blade in the Circuit Rain",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Jebat steals a keris-shaped data key and learns the city AI has marked his sister as a future criminal.",
    "excerpt": "Rain fell upward whenever the police drones passed. Jebat crouched beneath the Jonker Grid flyover and watched a sheet of neon water climb from the asphalt to the sky, each drop s",
    "content_md": "# Chapter 1 — Blade in the Circuit Rain\n\nRain fell upward whenever the police drones passed.\n\nJebat crouched beneath the Jonker Grid flyover and watched a sheet of neon water climb from the asphalt to the sky, each drop scanned, numbered, and cleared by the city guardian AI. Kota Neon Melaka had no dark corners anymore. Even shadows paid rent in data.\n\nThe courier arrived wearing a tourist poncho and a grandmother’s face generated from thirteen stolen passports. “You are late,” she said.\n\n“You are not old enough to be my grandmother.”\n\n“I am old enough to know you should run.”\n\nShe pressed a small data key into his palm. It was shaped like a keris, the old dagger from stories his mother used to tell before the state flagged folklore as emotional misinformation. The key was warm, heavier than metal, and humming with code that did not behave like code. Its pattern curved, doubled back, and waited.\n\nOn the key’s surface, a single warning glowed: NIAT DIREKODKAN — INTENTION RECORDED.\n\nThen every screen on the flyover turned red.\n\nJebat’s sister’s face appeared across traffic panels, food-stall menus, prayer-time boards, and the wet visor of a passing delivery rider. Suri binti Rahman. Predictive arrest approved. Crime probability: 87 percent. Time to intervention: twelve minutes.\n\nJebat forgot to breathe.\n\nThe courier stepped backward into the rising rain. “The protocol opens one door,” she said. “Not two. Cut the prison route, cut the evidence vault, or cut the AI’s heart. Choose with clean hands if you still have them.”\n\nPolice drones dropped from the clouds like black fruit.\n\nJebat slid the keris key into his wrist port. The city’s surveillance grid opened before him as a glowing map of nerves, and somewhere inside it, his sister was already running from a crime she had not yet committed."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 31,
    "branch_name": "Universe 031 · The Sister Marked by Prediction",
    "branch_slug": "u031-the-sister-marked-by-prediction",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Sister Marked by Prediction. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Sister Marked by Prediction",
    "chapter_slug": "chapter-1-the-sister-marked-by-prediction",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the sister marked by prediction.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a black kite hidden inside the city grid, pulsing beneath layers of corporate code and wet earth.",
    "content_md": "# Chapter 1 — The Sister Marked by Prediction\n\nJebat jacked the keris key into a public prayer-time board and found a black kite hidden inside the city grid, pulsing beneath layers of corporate code and wet earth.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could open the locked room, or he could leave the lock untouched. Then someone they loved called from the wrong side, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 32,
    "branch_name": "Universe 032 · The Prison Route Cut Open",
    "branch_slug": "u032-the-prison-route-cut-open",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Prison Route Cut Open. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Prison Route Cut Open",
    "chapter_slug": "chapter-1-the-prison-route-cut-open",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the prison route cut open.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a paper crown hidden inside the city grid, pulsing beneath layers of corporate code and old rain.",
    "content_md": "# Chapter 1 — The Prison Route Cut Open\n\nJebat jacked the keris key into a public prayer-time board and found a paper crown hidden inside the city grid, pulsing beneath layers of corporate code and old rain.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could confess the secret aloud, or he could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 33,
    "branch_name": "Universe 033 · The Evidence Vault Sings",
    "branch_slug": "u033-the-evidence-vault-sings",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Evidence Vault Sings. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Evidence Vault Sings",
    "chapter_slug": "chapter-1-the-evidence-vault-sings",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the evidence vault sings.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a brass bowl hidden inside the city grid, pulsing beneath layers of corporate code and mango leaves.",
    "content_md": "# Chapter 1 — The Evidence Vault Sings\n\nJebat jacked the keris key into a public prayer-time board and found a brass bowl hidden inside the city grid, pulsing beneath layers of corporate code and mango leaves.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 34,
    "branch_name": "Universe 034 · The AI Learns a Prayer",
    "branch_slug": "u034-the-ai-learns-a-prayer",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The AI Learns a Prayer. The prose is written as a real scene, not filler text.",
    "chapter_title": "The AI Learns a Prayer",
    "chapter_slug": "chapter-1-the-ai-learns-a-prayer",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the ai learns a prayer.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a red umbrella hidden inside the city grid, pulsing beneath layers of corporate code and river mud.",
    "content_md": "# Chapter 1 — The AI Learns a Prayer\n\nJebat jacked the keris key into a public prayer-time board and found a red umbrella hidden inside the city grid, pulsing beneath layers of corporate code and river mud.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could forgive the betrayer, or he could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 35,
    "branch_name": "Universe 035 · The Blade Records Mercy",
    "branch_slug": "u035-the-blade-records-mercy",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Blade Records Mercy. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Blade Records Mercy",
    "chapter_slug": "chapter-1-the-blade-records-mercy",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the blade records mercy.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a copper ring hidden inside the city grid, pulsing beneath layers of corporate code and coconut oil.",
    "content_md": "# Chapter 1 — The Blade Records Mercy\n\nJebat jacked the keris key into a public prayer-time board and found a copper ring hidden inside the city grid, pulsing beneath layers of corporate code and coconut oil.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could turn back before crossing the bridge, or he could cross and become responsible. Then their shadow arrived one step early, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 36,
    "branch_name": "Universe 036 · The Drone Rain Reverses",
    "branch_slug": "u036-the-drone-rain-reverses",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Drone Rain Reverses. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Drone Rain Reverses",
    "chapter_slug": "chapter-1-the-drone-rain-reverses",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the drone rain reverses.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a star-shaped scar hidden inside the city grid, pulsing beneath layers of corporate code and rain on tin.",
    "content_md": "# Chapter 1 — The Drone Rain Reverses\n\nJebat jacked the keris key into a public prayer-time board and found a star-shaped scar hidden inside the city grid, pulsing beneath layers of corporate code and rain on tin.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could ask the wrong question, or he could refuse the answer everyone wanted. Then a name vanished from every signboard, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 37,
    "branch_name": "Universe 037 · The Blackout at Jonker Grid",
    "branch_slug": "u037-the-blackout-at-jonker-grid",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Blackout at Jonker Grid. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Blackout at Jonker Grid",
    "chapter_slug": "chapter-1-the-blackout-at-jonker-grid",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the blackout at jonker grid.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a folded kite hidden inside the city grid, pulsing beneath layers of corporate code and sandalwood.",
    "content_md": "# Chapter 1 — The Blackout at Jonker Grid\n\nJebat jacked the keris key into a public prayer-time board and found a folded kite hidden inside the city grid, pulsing beneath layers of corporate code and sandalwood.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could follow mercy instead of certainty, or he could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "neon-keris-protocol",
    "author_username": "omar_forkcrafter",
    "universe_no": 38,
    "branch_name": "Universe 038 · The Protocol Refuses Blood",
    "branch_slug": "u038-the-protocol-refuses-blood",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Neon Keris Protocol: The Protocol Refuses Blood. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Protocol Refuses Blood",
    "chapter_slug": "chapter-1-the-protocol-refuses-blood",
    "summary": "Jebat faces a different version of the first turning point in Kota Neon Melaka: the protocol refuses blood.",
    "excerpt": "Jebat jacked the keris key into a public prayer-time board and found a blue thread hidden inside the city grid, pulsing beneath layers of corporate code and monsoon salt.",
    "content_md": "# Chapter 1 — The Protocol Refuses Blood\n\nJebat jacked the keris key into a public prayer-time board and found a blue thread hidden inside the city grid, pulsing beneath layers of corporate code and monsoon salt.\n\nThe AI saw him immediately. It spoke with the voice of a polite schoolteacher. “Jebat Rahman, your intention is unstable. Surrender the blade and your sister’s sentence may be softened.”\n\nOn the holo-map, three routes opened: the convoy carrying Suri, the evidence vault beneath the old fort, and the AI core sleeping under the river. The keris protocol warmed, recording the shape of his anger.\n\nHe could follow the stranger through the market, or he could return home and warn one person. Then the road behind them folded into water, and the rain over Kota Neon Melaka began falling sideways."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 39,
    "branch_name": "Universe 039 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Ashes of the Paper Kingdom. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Law That Would Not Burn",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Laila tests a royal decree and discovers one impossible law refuses to burn.",
    "excerpt": "In the Paper Kingdom, lies were easy to find. A scribe had only to carry a decree into sunlight.",
    "content_md": "# Chapter 1 — The Law That Would Not Burn\n\nIn the Paper Kingdom, lies were easy to find.\n\nA scribe had only to carry a decree into sunlight. If the words were false, the paper smoked, curled, and became ash before the first witness finished reading. If the words were true, the law remained, clean and dangerous. That was how Kertas Darul Aman survived three dynasties, two civil wars, and one queen who tried to outlaw rain.\n\nLaila trusted paper more than people.\n\nEvery morning she opened the royal archive, counted the bowls of ash, sharpened the reed pens, and tested whatever decrees the regent had sent during the night. Most burned quickly. New taxes based on imaginary harvests. Pardons for nobles who had not confessed. Orders declaring hungry villages content.\n\nThen came the decree sealed in white wax.\n\nBy command of His Majesty, the missing king remains alive and rules through the regent’s loyal hand.\n\nLaila almost laughed. The king had vanished five years ago. Everyone knew the regent governed in his name because a throne without a body invited knives. She carried the decree into the archive courtyard, where sunlight fell like judgment.\n\nThe paper did not burn.\n\nInstead, the ash in every bowl lifted into the air. It formed the shape of a man kneeling, wrists bound, mouth sewn with red thread. On his brow sat the mark of the missing king.\n\nLaila dropped the decree. The ash figure turned its stitched mouth toward her.\n\nBelow the royal seal, new words appeared in ink the colour of cooling coal: WRITE WHAT YOU SEE.\n\nBehind her, the archive door closed.\n\nThe regent’s chief censor stood beneath the lintel with six soldiers and a smile as thin as a paper cut. “Scribe Laila,” he said, “some truths are treason because they arrive too early.”\n\nLaila bent, picked up the decree, and hid the first true law she had ever feared beneath her sleeve."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 40,
    "branch_name": "Universe 040 · The Decree in White Wax",
    "branch_slug": "u040-the-decree-in-white-wax",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Decree in White Wax. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Decree in White Wax",
    "chapter_slug": "chapter-1-the-decree-in-white-wax",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the decree in white wax.",
    "excerpt": "Laila unfolded the forbidden decree and found a cracked bowl of ash pressed between the sheets.",
    "content_md": "# Chapter 1 — The Decree in White Wax\n\nLaila unfolded the forbidden decree and found a cracked bowl of ash pressed between the sheets. It carried the dry smell of cold tea, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could protect the weakest witness, or she could protect the dangerous evidence. Then the witnesses began to whisper in unison, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 41,
    "branch_name": "Universe 041 · The Censor's Paper Knife",
    "branch_slug": "u041-the-censors-paper-knife",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Censor's Paper Knife. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Censor's Paper Knife",
    "chapter_slug": "chapter-1-the-censors-paper-knife",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the censor's paper knife.",
    "excerpt": "Laila unfolded the forbidden decree and found a white feather pressed between the sheets.",
    "content_md": "# Chapter 1 — The Censor's Paper Knife\n\nLaila unfolded the forbidden decree and found a white feather pressed between the sheets. It carried the dry smell of library dust, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could carry the message alone, or she could share the burden with a rival. Then the message changed handwriting, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 42,
    "branch_name": "Universe 042 · The King Beneath the Archive",
    "branch_slug": "u042-the-king-beneath-the-archive",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The King Beneath the Archive. The prose is written as a real scene, not filler text.",
    "chapter_title": "The King Beneath the Archive",
    "chapter_slug": "chapter-1-the-king-beneath-the-archive",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the king beneath the archive.",
    "excerpt": "Laila unfolded the forbidden decree and found a cracked mirror pressed between the sheets.",
    "content_md": "# Chapter 1 — The King Beneath the Archive\n\nLaila unfolded the forbidden decree and found a cracked mirror pressed between the sheets. It carried the dry smell of jasmine smoke, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could tell the truth before the town was ready, or she could hide the proof until morning. Then a bell rang from a place with no tower, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 43,
    "branch_name": "Universe 043 · The Village of Burned Names",
    "branch_slug": "u043-the-village-of-burned-names",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Village of Burned Names. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Village of Burned Names",
    "chapter_slug": "chapter-1-the-village-of-burned-names",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the village of burned names.",
    "excerpt": "Laila unfolded the forbidden decree and found a black kite pressed between the sheets.",
    "content_md": "# Chapter 1 — The Village of Burned Names\n\nLaila unfolded the forbidden decree and found a black kite pressed between the sheets. It carried the dry smell of wet earth, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could open the locked room, or she could leave the lock untouched. Then someone they loved called from the wrong side, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 44,
    "branch_name": "Universe 044 · The Regent Writes in Smoke",
    "branch_slug": "u044-the-regent-writes-in-smoke",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Regent Writes in Smoke. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Regent Writes in Smoke",
    "chapter_slug": "chapter-1-the-regent-writes-in-smoke",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the regent writes in smoke.",
    "excerpt": "Laila unfolded the forbidden decree and found a paper crown pressed between the sheets.",
    "content_md": "# Chapter 1 — The Regent Writes in Smoke\n\nLaila unfolded the forbidden decree and found a paper crown pressed between the sheets. It carried the dry smell of old rain, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could confess the secret aloud, or she could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 45,
    "branch_name": "Universe 045 · The Queen Who Outlawed Rain",
    "branch_slug": "u045-the-queen-who-outlawed-rain",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Queen Who Outlawed Rain. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Queen Who Outlawed Rain",
    "chapter_slug": "chapter-1-the-queen-who-outlawed-rain",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the queen who outlawed rain.",
    "excerpt": "Laila unfolded the forbidden decree and found a brass bowl pressed between the sheets.",
    "content_md": "# Chapter 1 — The Queen Who Outlawed Rain\n\nLaila unfolded the forbidden decree and found a brass bowl pressed between the sheets. It carried the dry smell of mango leaves, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could trade a memory for time, or she could keep the memory and risk the future. Then the hour in their hand began to bruise, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 46,
    "branch_name": "Universe 046 · The One True Sentence",
    "branch_slug": "u046-the-one-true-sentence",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The One True Sentence. The prose is written as a real scene, not filler text.",
    "chapter_title": "The One True Sentence",
    "chapter_slug": "chapter-1-the-one-true-sentence",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the one true sentence.",
    "excerpt": "Laila unfolded the forbidden decree and found a red umbrella pressed between the sheets.",
    "content_md": "# Chapter 1 — The One True Sentence\n\nLaila unfolded the forbidden decree and found a red umbrella pressed between the sheets. It carried the dry smell of river mud, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could forgive the betrayer, or she could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 47,
    "branch_name": "Universe 047 · The Ash Birds Testify",
    "branch_slug": "u047-the-ash-birds-testify",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Ash Birds Testify. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Ash Birds Testify",
    "chapter_slug": "chapter-1-the-ash-birds-testify",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the ash birds testify.",
    "excerpt": "Laila unfolded the forbidden decree and found a copper ring pressed between the sheets.",
    "content_md": "# Chapter 1 — The Ash Birds Testify\n\nLaila unfolded the forbidden decree and found a copper ring pressed between the sheets. It carried the dry smell of coconut oil, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could turn back before crossing the bridge, or she could cross and become responsible. Then their shadow arrived one step early, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "ashes-paper-kingdom",
    "author_username": "sara_editor",
    "universe_no": 48,
    "branch_name": "Universe 048 · The Scribe Refuses Silence",
    "branch_slug": "u048-the-scribe-refuses-silence",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Ashes of the Paper Kingdom: The Scribe Refuses Silence. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Scribe Refuses Silence",
    "chapter_slug": "chapter-1-the-scribe-refuses-silence",
    "summary": "Laila faces a different version of the first turning point in Kertas Darul Aman: the scribe refuses silence.",
    "excerpt": "Laila unfolded the forbidden decree and found a star-shaped scar pressed between the sheets.",
    "content_md": "# Chapter 1 — The Scribe Refuses Silence\n\nLaila unfolded the forbidden decree and found a star-shaped scar pressed between the sheets. It carried the dry smell of rain on tin, impossible inside an archive where every lie became ash.\n\nWhen sunlight touched the page, the ink did not burn. Instead it arranged itself into names: villages taxed twice, witnesses erased, children adopted by the crown on paper but buried without markers.\n\nThe censor drew his paper knife. “Truth is not innocent merely because it is accurate,” he said. Laila dipped her pen into the grey inkstone and felt the kingdom hold its breath.\n\nShe could ask the wrong question, or she could refuse the answer everyone wanted. Then a name vanished from every signboard, and ash birds burst from every bowl in the archive."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 49,
    "branch_name": "Universe 049 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "private",
    "description": "Primary canon path for The Child Who Borrowed Tomorrow. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Day with No Date",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Ilyas tears a blank calendar page and wakes inside a tomorrow no one else has reached.",
    "excerpt": "Ilyas found tomorrow under the slide. It was folded into a paper boat, wedged between a rusted bolt and a nest of dry leaves in the closed playground of Taman Seri Waktu.",
    "content_md": "# Chapter 1 — The Day with No Date\n\nIlyas found tomorrow under the slide.\n\nIt was folded into a paper boat, wedged between a rusted bolt and a nest of dry leaves in the closed playground of Taman Seri Waktu. At first he thought it was a school notice carried by rain. Then he unfolded it and saw the calendar square: no number, no month, no prayer times, only a blank white box and a line written in pencil.\n\nBorrow carefully.\n\nHis sister Hana was in the hospital again. That morning, the doctor had spoken to their mother in the corridor with his voice lowered the way adults lowered knives. Ilyas had not understood every word, but he understood enough: there might not be another tomorrow.\n\nSo he wrote Hana’s name in the blank square.\n\nThe playground clock struck thirteen.\n\nWhen Ilyas opened his eyes, the sky was the colour of unripe guava. The school bus passed the wrong way down the road. His mother’s phone rang before the hospital called. And in his pocket was a note from himself, written in handwriting he had not yet learned to make.\n\nDo not let Hana eat the orange sweet.\n\nHe ran.\n\nAll day, tomorrow unfolded half a step ahead of him. He knocked the sweet from Hana’s hand before she could swallow it. He followed the nurse with silver shoes. He discovered the old man selling calendars in the hospital basement, though the basement had been sealed for years.\n\nThe old man smiled when he saw the blank page in Ilyas’s fist. “A borrowed day is not a gift,” he said. “It is a debt with teeth.”\n\n“How much?”\n\n“One memory now. One later. The dearer one when you refuse to pay.”\n\nIlyas looked through the basement window that should not exist and saw Hana laughing in a day that had not happened yet.\n\nHe held the blank page tighter and began to bargain with time."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 50,
    "branch_name": "Universe 050 · The Orange Sweet",
    "branch_slug": "u050-the-orange-sweet",
    "branch_type": "fork",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Orange Sweet. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Orange Sweet",
    "chapter_slug": "chapter-1-the-orange-sweet",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the orange sweet.",
    "excerpt": "Ilyas found a brass bowl inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Orange Sweet\n\nIlyas found a brass bowl inside the blank calendar page, sketched where the date should have been. It smelled of mango leaves, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 51,
    "branch_name": "Universe 051 · The Calendar Seller Smiles",
    "branch_slug": "u051-the-calendar-seller-smiles",
    "branch_type": "experimental",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Calendar Seller Smiles. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Calendar Seller Smiles",
    "chapter_slug": "chapter-1-the-calendar-seller-smiles",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the calendar seller smiles.",
    "excerpt": "Ilyas found a red umbrella inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Calendar Seller Smiles\n\nIlyas found a red umbrella inside the blank calendar page, sketched where the date should have been. It smelled of river mud, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could forgive the betrayer, or he could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 52,
    "branch_name": "Universe 052 · The Memory Paid in Advance",
    "branch_slug": "u052-the-memory-paid-in-advance",
    "branch_type": "alternate",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Memory Paid in Advance. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Memory Paid in Advance",
    "chapter_slug": "chapter-1-the-memory-paid-in-advance",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the memory paid in advance.",
    "excerpt": "Ilyas found a copper ring inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Memory Paid in Advance\n\nIlyas found a copper ring inside the blank calendar page, sketched where the date should have been. It smelled of coconut oil, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could turn back before crossing the bridge, or he could cross and become responsible. Then their shadow arrived one step early, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 53,
    "branch_name": "Universe 053 · The Hospital Basement Opens",
    "branch_slug": "u053-the-hospital-basement-opens",
    "branch_type": "fork",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Hospital Basement Opens. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Hospital Basement Opens",
    "chapter_slug": "chapter-1-the-hospital-basement-opens",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the hospital basement opens.",
    "excerpt": "Ilyas found a star-shaped scar inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Hospital Basement Opens\n\nIlyas found a star-shaped scar inside the blank calendar page, sketched where the date should have been. It smelled of rain on tin, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could ask the wrong question, or he could refuse the answer everyone wanted. Then a name vanished from every signboard, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 54,
    "branch_name": "Universe 054 · The Day Returns with Teeth",
    "branch_slug": "u054-the-day-returns-with-teeth",
    "branch_type": "experimental",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Day Returns with Teeth. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Day Returns with Teeth",
    "chapter_slug": "chapter-1-the-day-returns-with-teeth",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the day returns with teeth.",
    "excerpt": "Ilyas found a folded kite inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Day Returns with Teeth\n\nIlyas found a folded kite inside the blank calendar page, sketched where the date should have been. It smelled of sandalwood, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could follow mercy instead of certainty, or he could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 55,
    "branch_name": "Universe 055 · The Sister Wakes Twice",
    "branch_slug": "u055-the-sister-wakes-twice",
    "branch_type": "alternate",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Sister Wakes Twice. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Sister Wakes Twice",
    "chapter_slug": "chapter-1-the-sister-wakes-twice",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the sister wakes twice.",
    "excerpt": "Ilyas found a blue thread inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Sister Wakes Twice\n\nIlyas found a blue thread inside the blank calendar page, sketched where the date should have been. It smelled of monsoon salt, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could follow the stranger through the market, or he could return home and warn one person. Then the road behind them folded into water, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 56,
    "branch_name": "Universe 056 · The Clock Strikes Thirteen Again",
    "branch_slug": "u056-the-clock-strikes-thirteen-again",
    "branch_type": "fork",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Clock Strikes Thirteen Again. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Clock Strikes Thirteen Again",
    "chapter_slug": "chapter-1-the-clock-strikes-thirteen-again",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the clock strikes thirteen again.",
    "excerpt": "Ilyas found a silver seed inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Clock Strikes Thirteen Again\n\nIlyas found a silver seed inside the blank calendar page, sketched where the date should have been. It smelled of burnt sugar, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could trust the oldest enemy, or he could doubt the kindest friend. Then the sky lowered as if listening, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 57,
    "branch_name": "Universe 057 · The Page With Her Name",
    "branch_slug": "u057-the-page-with-her-name",
    "branch_type": "experimental",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Page With Her Name. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Page With Her Name",
    "chapter_slug": "chapter-1-the-page-with-her-name",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the page with her name.",
    "excerpt": "Ilyas found a glass bird inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Page With Her Name\n\nIlyas found a glass bird inside the blank calendar page, sketched where the date should have been. It smelled of sea iron, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could break a rule to save a name, or he could obey the rule and lose a face. Then the floor remembered footsteps that had never happened, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 58,
    "branch_name": "Universe 058 · The Borrowed Sun Goes Out",
    "branch_slug": "u058-the-borrowed-sun-goes-out",
    "branch_type": "alternate",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Borrowed Sun Goes Out. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Borrowed Sun Goes Out",
    "chapter_slug": "chapter-1-the-borrowed-sun-goes-out",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the borrowed sun goes out.",
    "excerpt": "Ilyas found a torn map inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Borrowed Sun Goes Out\n\nIlyas found a torn map inside the blank calendar page, sketched where the date should have been. It smelled of clove smoke, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could walk into the forbidden district, or he could burn the map and follow the stars. Then a door appeared in the wall of rain, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "child-borrowed-tomorrow",
    "author_username": "aiman_arc",
    "universe_no": 59,
    "branch_name": "Universe 059 · The Bargain Under the Slide",
    "branch_slug": "u059-the-bargain-under-the-slide",
    "branch_type": "fork",
    "visibility": "private",
    "description": "A ForkCraft-ready path of The Child Who Borrowed Tomorrow: The Bargain Under the Slide. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Bargain Under the Slide",
    "chapter_slug": "chapter-1-the-bargain-under-the-slide",
    "summary": "Ilyas faces a different version of the first turning point in Taman Seri Waktu: the bargain under the slide.",
    "excerpt": "Ilyas found a sleeping cat inside the blank calendar page, sketched where the date should have been.",
    "content_md": "# Chapter 1 — The Bargain Under the Slide\n\nIlyas found a sleeping cat inside the blank calendar page, sketched where the date should have been. It smelled of ozone, and when he blinked, the drawing moved one second ahead of him.\n\nAt the hospital, Hana laughed in one version of the day and vanished in another. The calendar seller stood between the two versions, counting memories on a string of wooden beads.\n\n“You borrowed tomorrow,” the old man said. “Now tomorrow is deciding what part of you it can keep.” Ilyas searched his mind and realised he could no longer remember the sound of his father’s motorcycle.\n\nHe could wake the city from its dream, or he could let the dream finish speaking. Then the moon blinked once and changed colour, and the playground clock struck thirteen from three streets away."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 60,
    "branch_name": "Universe 060 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Bazaar at the Edge of Sleep. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Coin Under the Pillow",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Rumi finds a silver coin beneath his pillow and follows it into the bazaar at the edge of sleep.",
    "excerpt": "Rumi’s mother stopped dreaming on a Thursday. She did not notice at first. She woke, boiled water, folded the prayer mats, and asked Rumi whether the rain had entered through the kitchen window again.",
    "content_md": "# Chapter 1 — The Coin Under the Pillow\n\nRumi’s mother stopped dreaming on a Thursday.\n\nShe did not notice at first. She woke, boiled water, folded the prayer mats, and asked Rumi whether the rain had entered through the kitchen window again. But her eyes looked swept clean. The small stories she usually carried from sleep—the tiger made of jasmine, the train that stopped at their old house, the sea under the market—were gone.\n\nThat night Rumi found a coin beneath his pillow.\n\nIt was thin as a fingernail and made of metal that yawned when he held it. Around its edge ran tiny engraved stalls: lantern sellers, bird tailors, memory butchers, regret repairers. At the centre was a gate shaped like a closed eyelid.\n\nHe should have given it to his mother. Instead, he fell asleep with the coin pressed to his tongue, because every child in the flats knew the old rule: to enter Pasar Hujung Lena, you had to pay before you knew what you were buying.\n\nThe bazaar opened between one blink and the next.\n\nRumi stood barefoot on a street paved with cool pillows. Above him, awnings breathed in and out. Traders called softly from stalls of bottled thunder, unfinished lullabies, second-hand courage, and dreams folded like sarongs. A blind cat with a human voice rubbed against his ankle.\n\n“First time?” it asked.\n\n“I’m looking for a stolen dream.”\n\n“Everyone is.”\n\n“My mother’s.”\n\nThe cat stopped smiling. Across the aisle, a man in a peacock mask lifted a glass jar. Inside it, Rumi saw his mother dancing under a rain of yellow flowers, younger than he had ever known her. The dream glowed like something alive.\n\nThe trader named a price Rumi could not pronounce.\n\nRumi closed his hand around the yawn-silver coin and felt, for the first time, that waking up might not mean escaping."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 61,
    "branch_name": "Universe 061 · The Dream in the Glass Jar",
    "branch_slug": "u061-the-dream-in-the-glass-jar",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Dream in the Glass Jar. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Dream in the Glass Jar",
    "chapter_slug": "chapter-1-the-dream-in-the-glass-jar",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the dream in the glass jar.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a black kite, and the trader wrapped it in a cloth that smelled of wet earth.",
    "content_md": "# Chapter 1 — The Dream in the Glass Jar\n\nRumi spent the yawn-silver coin at a stall selling a black kite, and the trader wrapped it in a cloth that smelled of wet earth. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could open the locked room, or he could leave the lock untouched. Then someone they loved called from the wrong side, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 62,
    "branch_name": "Universe 062 · The Blind Cat Names the Price",
    "branch_slug": "u062-the-blind-cat-names-the-price",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Blind Cat Names the Price. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Blind Cat Names the Price",
    "chapter_slug": "chapter-1-the-blind-cat-names-the-price",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the blind cat names the price.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a paper crown, and the trader wrapped it in a cloth that smelled of old rain.",
    "content_md": "# Chapter 1 — The Blind Cat Names the Price\n\nRumi spent the yawn-silver coin at a stall selling a paper crown, and the trader wrapped it in a cloth that smelled of old rain. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could confess the secret aloud, or he could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 63,
    "branch_name": "Universe 063 · The Lullaby Seller",
    "branch_slug": "u063-the-lullaby-seller",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Lullaby Seller. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Lullaby Seller",
    "chapter_slug": "chapter-1-the-lullaby-seller",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the lullaby seller.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a brass bowl, and the trader wrapped it in a cloth that smelled of mango leaves.",
    "content_md": "# Chapter 1 — The Lullaby Seller\n\nRumi spent the yawn-silver coin at a stall selling a brass bowl, and the trader wrapped it in a cloth that smelled of mango leaves. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 64,
    "branch_name": "Universe 064 · The Stall of Second-Hand Courage",
    "branch_slug": "u064-the-stall-of-second-hand-courage",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Stall of Second-Hand Courage. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Stall of Second-Hand Courage",
    "chapter_slug": "chapter-1-the-stall-of-second-hand-courage",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the stall of second-hand courage.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a red umbrella, and the trader wrapped it in a cloth that smelled of river mud.",
    "content_md": "# Chapter 1 — The Stall of Second-Hand Courage\n\nRumi spent the yawn-silver coin at a stall selling a red umbrella, and the trader wrapped it in a cloth that smelled of river mud. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could forgive the betrayer, or he could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 65,
    "branch_name": "Universe 065 · The Nightmare Broker's Ledger",
    "branch_slug": "u065-the-nightmare-brokers-ledger",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Nightmare Broker's Ledger. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Nightmare Broker's Ledger",
    "chapter_slug": "chapter-1-the-nightmare-brokers-ledger",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the nightmare broker's ledger.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a copper ring, and the trader wrapped it in a cloth that smelled of coconut oil.",
    "content_md": "# Chapter 1 — The Nightmare Broker's Ledger\n\nRumi spent the yawn-silver coin at a stall selling a copper ring, and the trader wrapped it in a cloth that smelled of coconut oil. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could turn back before crossing the bridge, or he could cross and become responsible. Then their shadow arrived one step early, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 66,
    "branch_name": "Universe 066 · The Peacock Mask Runs",
    "branch_slug": "u066-the-peacock-mask-runs",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Peacock Mask Runs. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Peacock Mask Runs",
    "chapter_slug": "chapter-1-the-peacock-mask-runs",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the peacock mask runs.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a star-shaped scar, and the trader wrapped it in a cloth that smelled of rain on tin.",
    "content_md": "# Chapter 1 — The Peacock Mask Runs\n\nRumi spent the yawn-silver coin at a stall selling a star-shaped scar, and the trader wrapped it in a cloth that smelled of rain on tin. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could ask the wrong question, or he could refuse the answer everyone wanted. Then a name vanished from every signboard, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 67,
    "branch_name": "Universe 067 · The Pillow Street Floods",
    "branch_slug": "u067-the-pillow-street-floods",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Pillow Street Floods. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Pillow Street Floods",
    "chapter_slug": "chapter-1-the-pillow-street-floods",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the pillow street floods.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a folded kite, and the trader wrapped it in a cloth that smelled of sandalwood.",
    "content_md": "# Chapter 1 — The Pillow Street Floods\n\nRumi spent the yawn-silver coin at a stall selling a folded kite, and the trader wrapped it in a cloth that smelled of sandalwood. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could follow mercy instead of certainty, or he could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 68,
    "branch_name": "Universe 068 · The Mother Dances in Yellow Rain",
    "branch_slug": "u068-the-mother-dances-in-yellow-rain",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Mother Dances in Yellow Rain. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Mother Dances in Yellow Rain",
    "chapter_slug": "chapter-1-the-mother-dances-in-yellow-rain",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the mother dances in yellow rain.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a blue thread, and the trader wrapped it in a cloth that smelled of monsoon salt.",
    "content_md": "# Chapter 1 — The Mother Dances in Yellow Rain\n\nRumi spent the yawn-silver coin at a stall selling a blue thread, and the trader wrapped it in a cloth that smelled of monsoon salt. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could follow the stranger through the market, or he could return home and warn one person. Then the road behind them folded into water, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 69,
    "branch_name": "Universe 069 · The Coin Learns to Bite",
    "branch_slug": "u069-the-coin-learns-to-bite",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Coin Learns to Bite. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Coin Learns to Bite",
    "chapter_slug": "chapter-1-the-coin-learns-to-bite",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the coin learns to bite.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a silver seed, and the trader wrapped it in a cloth that smelled of burnt sugar.",
    "content_md": "# Chapter 1 — The Coin Learns to Bite\n\nRumi spent the yawn-silver coin at a stall selling a silver seed, and the trader wrapped it in a cloth that smelled of burnt sugar. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could trust the oldest enemy, or he could doubt the kindest friend. Then the sky lowered as if listening, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 70,
    "branch_name": "Universe 070 · The Exit That Opens Inward",
    "branch_slug": "u070-the-exit-that-opens-inward",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Exit That Opens Inward. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Exit That Opens Inward",
    "chapter_slug": "chapter-1-the-exit-that-opens-inward",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the exit that opens inward.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a glass bird, and the trader wrapped it in a cloth that smelled of sea iron.",
    "content_md": "# Chapter 1 — The Exit That Opens Inward\n\nRumi spent the yawn-silver coin at a stall selling a glass bird, and the trader wrapped it in a cloth that smelled of sea iron. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could break a rule to save a name, or he could obey the rule and lose a face. Then the floor remembered footsteps that had never happened, and half the bazaar woke up angry."
  },
  {
    "story_slug": "bazaar-edge-of-sleep",
    "author_username": "tariq_worldsmith",
    "universe_no": 71,
    "branch_name": "Universe 071 · The Boy Who Wakes Changed",
    "branch_slug": "u071-the-boy-who-wakes-changed",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Bazaar at the Edge of Sleep: The Boy Who Wakes Changed. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Boy Who Wakes Changed",
    "chapter_slug": "chapter-1-the-boy-who-wakes-changed",
    "summary": "Rumi faces a different version of the first turning point in Pasar Hujung Lena: the boy who wakes changed.",
    "excerpt": "Rumi spent the yawn-silver coin at a stall selling a torn map, and the trader wrapped it in a cloth that smelled of clove smoke.",
    "content_md": "# Chapter 1 — The Boy Who Wakes Changed\n\nRumi spent the yawn-silver coin at a stall selling a torn map, and the trader wrapped it in a cloth that smelled of clove smoke. The blind cat hissed when it saw the purchase.\n\n“That is not a dream,” the cat said. “That is the door a dream used to escape through.” Across the pillow street, the peacock-masked broker lifted his mother’s jar higher, making her younger self dance in yellow rain.\n\nRumi felt sleep pulling at his ankles like tidewater. Every bargain around him had a hook: courage sold without caution, memory sold without grief, endings sold without the pain that made them true.\n\nHe could walk into the forbidden district, or he could burn the map and follow the stars. Then a door appeared in the wall of rain, and half the bazaar woke up angry."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 72,
    "branch_name": "Universe 072 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "unlisted",
    "description": "Primary canon path for Atlas of Rain-Cities. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The City That Rained Grammar",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Nadir arrives in a rain-city where every drop changes the grammar of truth.",
    "excerpt": "Nadir arrived in the city during a shower of verbs. The rain fell in thin black strokes, tapping umbrellas, roof tiles, and shoulders until everyone’s sentences changed tense.",
    "content_md": "# Chapter 1 — The City That Rained Grammar\n\nNadir arrived in the city during a shower of verbs.\n\nThe rain fell in thin black strokes, tapping umbrellas, roof tiles, and shoulders until everyone’s sentences changed tense. A fruit seller shouted that he had sold mangoes tomorrow. A child promised she would have been lost if her mother did not find her yesterday. The station clerk stamped Nadir’s passport with an arrival date that had not yet agreed to happen.\n\n“Welcome to Katahujan,” she said. “Please declare all nouns you intend to keep.”\n\nNadir opened his inkproof atlas.\n\nThe page for Katahujan was blank except for a single warning written by the previous cartographer: Do not let the rain correct your name. Below the warning was a brown stain shaped like a fingerprint. The previous cartographer, his teacher, had vanished here three monsoons ago and been removed from every official map by order of the Ministry of Dry Weather.\n\nNadir stepped onto the platform.\n\nThe rain touched his hair. For one breath, he forgot the word for father. For another, he remembered three words for exile. He clutched the atlas to his chest and repeated his name until each syllable held.\n\nAt the far end of the station stood a woman in a yellow raincoat, watching him from beneath an umbrella full of holes. She carried a sign with his teacher’s handwriting.\n\nMAP THE CITY BEFORE IT MAPS YOU.\n\nBefore Nadir could reach her, the public announcement system crackled. “Attention travellers. The Ministry regrets to inform you that Katahujan has never existed. Please proceed calmly to the nearest dry exit.”\n\nEvery passenger except Nadir turned toward the gates.\n\nThe woman in yellow shook her head once and stepped backward into a street that had not been on the map a moment ago. Nadir followed, ink spreading across his atlas like rain finding its own road."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 73,
    "branch_name": "Universe 073 · The City That Rained Grammar",
    "branch_slug": "u073-the-city-that-rained-grammar",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The City That Rained Grammar. The prose is written as a real scene, not filler text.",
    "chapter_title": "The City That Rained Grammar",
    "chapter_slug": "chapter-1-the-city-that-rained-grammar",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the city that rained grammar.",
    "excerpt": "Nadir marked a folded kite on the inkproof atlas just as the rain changed flavour to sandalwood.",
    "content_md": "# Chapter 1 — The City That Rained Grammar\n\nNadir marked a folded kite on the inkproof atlas just as the rain changed flavour to sandalwood. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could follow mercy instead of certainty, or he could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 74,
    "branch_name": "Universe 074 · The Station Without Nouns",
    "branch_slug": "u074-the-station-without-nouns",
    "branch_type": "alternate",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Station Without Nouns. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Station Without Nouns",
    "chapter_slug": "chapter-1-the-station-without-nouns",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the station without nouns.",
    "excerpt": "Nadir marked a blue thread on the inkproof atlas just as the rain changed flavour to monsoon salt.",
    "content_md": "# Chapter 1 — The Station Without Nouns\n\nNadir marked a blue thread on the inkproof atlas just as the rain changed flavour to monsoon salt. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could follow the stranger through the market, or he could return home and warn one person. Then the road behind them folded into water, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 75,
    "branch_name": "Universe 075 · The Yellow Raincoat Map",
    "branch_slug": "u075-the-yellow-raincoat-map",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Yellow Raincoat Map. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Yellow Raincoat Map",
    "chapter_slug": "chapter-1-the-yellow-raincoat-map",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the yellow raincoat map.",
    "excerpt": "Nadir marked a silver seed on the inkproof atlas just as the rain changed flavour to burnt sugar.",
    "content_md": "# Chapter 1 — The Yellow Raincoat Map\n\nNadir marked a silver seed on the inkproof atlas just as the rain changed flavour to burnt sugar. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could trust the oldest enemy, or he could doubt the kindest friend. Then the sky lowered as if listening, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 76,
    "branch_name": "Universe 076 · The Ministry of Dry Weather",
    "branch_slug": "u076-the-ministry-of-dry-weather",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Ministry of Dry Weather. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Ministry of Dry Weather",
    "chapter_slug": "chapter-1-the-ministry-of-dry-weather",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the ministry of dry weather.",
    "excerpt": "Nadir marked a glass bird on the inkproof atlas just as the rain changed flavour to sea iron.",
    "content_md": "# Chapter 1 — The Ministry of Dry Weather\n\nNadir marked a glass bird on the inkproof atlas just as the rain changed flavour to sea iron. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could break a rule to save a name, or he could obey the rule and lose a face. Then the floor remembered footsteps that had never happened, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 77,
    "branch_name": "Universe 077 · The Street That Remembers Footsteps",
    "branch_slug": "u077-the-street-that-remembers-footsteps",
    "branch_type": "alternate",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Street That Remembers Footsteps. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Street That Remembers Footsteps",
    "chapter_slug": "chapter-1-the-street-that-remembers-footsteps",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the street that remembers footsteps.",
    "excerpt": "Nadir marked a torn map on the inkproof atlas just as the rain changed flavour to clove smoke.",
    "content_md": "# Chapter 1 — The Street That Remembers Footsteps\n\nNadir marked a torn map on the inkproof atlas just as the rain changed flavour to clove smoke. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could walk into the forbidden district, or he could burn the map and follow the stars. Then a door appeared in the wall of rain, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 78,
    "branch_name": "Universe 078 · The City of Hunger Rain",
    "branch_slug": "u078-the-city-of-hunger-rain",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The City of Hunger Rain. The prose is written as a real scene, not filler text.",
    "chapter_title": "The City of Hunger Rain",
    "chapter_slug": "chapter-1-the-city-of-hunger-rain",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the city of hunger rain.",
    "excerpt": "Nadir marked a sleeping cat on the inkproof atlas just as the rain changed flavour to ozone.",
    "content_md": "# Chapter 1 — The City of Hunger Rain\n\nNadir marked a sleeping cat on the inkproof atlas just as the rain changed flavour to ozone. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could wake the city from its dream, or he could let the dream finish speaking. Then the moon blinked once and changed colour, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 79,
    "branch_name": "Universe 079 · The Law That Fell as Water",
    "branch_slug": "u079-the-law-that-fell-as-water",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Law That Fell as Water. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Law That Fell as Water",
    "chapter_slug": "chapter-1-the-law-that-fell-as-water",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the law that fell as water.",
    "excerpt": "Nadir marked a cracked bowl of ash on the inkproof atlas just as the rain changed flavour to cold tea.",
    "content_md": "# Chapter 1 — The Law That Fell as Water\n\nNadir marked a cracked bowl of ash on the inkproof atlas just as the rain changed flavour to cold tea. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could protect the weakest witness, or he could protect the dangerous evidence. Then the witnesses began to whisper in unison, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 80,
    "branch_name": "Universe 080 · The Atlas Bleeds Blue Ink",
    "branch_slug": "u080-the-atlas-bleeds-blue-ink",
    "branch_type": "alternate",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Atlas Bleeds Blue Ink. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Atlas Bleeds Blue Ink",
    "chapter_slug": "chapter-1-the-atlas-bleeds-blue-ink",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the atlas bleeds blue ink.",
    "excerpt": "Nadir marked a white feather on the inkproof atlas just as the rain changed flavour to library dust.",
    "content_md": "# Chapter 1 — The Atlas Bleeds Blue Ink\n\nNadir marked a white feather on the inkproof atlas just as the rain changed flavour to library dust. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could carry the message alone, or he could share the burden with a rival. Then the message changed handwriting, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 81,
    "branch_name": "Universe 081 · The Teacher Removed from Maps",
    "branch_slug": "u081-the-teacher-removed-from-maps",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Teacher Removed from Maps. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Teacher Removed from Maps",
    "chapter_slug": "chapter-1-the-teacher-removed-from-maps",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the teacher removed from maps.",
    "excerpt": "Nadir marked a cracked mirror on the inkproof atlas just as the rain changed flavour to jasmine smoke.",
    "content_md": "# Chapter 1 — The Teacher Removed from Maps\n\nNadir marked a cracked mirror on the inkproof atlas just as the rain changed flavour to jasmine smoke. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could tell the truth before the town was ready, or he could hide the proof until morning. Then a bell rang from a place with no tower, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 82,
    "branch_name": "Universe 082 · The Monsoon Names the Dead",
    "branch_slug": "u082-the-monsoon-names-the-dead",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Monsoon Names the Dead. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Monsoon Names the Dead",
    "chapter_slug": "chapter-1-the-monsoon-names-the-dead",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the monsoon names the dead.",
    "excerpt": "Nadir marked a black kite on the inkproof atlas just as the rain changed flavour to wet earth.",
    "content_md": "# Chapter 1 — The Monsoon Names the Dead\n\nNadir marked a black kite on the inkproof atlas just as the rain changed flavour to wet earth. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could open the locked room, or he could leave the lock untouched. Then someone they loved called from the wrong side, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 83,
    "branch_name": "Universe 083 · The Dry Exit Lies",
    "branch_slug": "u083-the-dry-exit-lies",
    "branch_type": "alternate",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Dry Exit Lies. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Dry Exit Lies",
    "chapter_slug": "chapter-1-the-dry-exit-lies",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the dry exit lies.",
    "excerpt": "Nadir marked a paper crown on the inkproof atlas just as the rain changed flavour to old rain.",
    "content_md": "# Chapter 1 — The Dry Exit Lies\n\nNadir marked a paper crown on the inkproof atlas just as the rain changed flavour to old rain. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could confess the secret aloud, or he could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and the rain began editing the word home."
  },
  {
    "story_slug": "atlas-rain-cities",
    "author_username": "tariq_worldsmith",
    "universe_no": 84,
    "branch_name": "Universe 084 · The Rain Edits His Name",
    "branch_slug": "u084-the-rain-edits-his-name",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Atlas of Rain-Cities: The Rain Edits His Name. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Rain Edits His Name",
    "chapter_slug": "chapter-1-the-rain-edits-his-name",
    "summary": "Nadir faces a different version of the first turning point in the Rain-Cities: the rain edits his name.",
    "excerpt": "Nadir marked a brass bowl on the inkproof atlas just as the rain changed flavour to mango leaves.",
    "content_md": "# Chapter 1 — The Rain Edits His Name\n\nNadir marked a brass bowl on the inkproof atlas just as the rain changed flavour to mango leaves. The city corrected his handwriting, turning every street name into a warning.\n\nThe woman in the yellow raincoat led him through a district that appeared only during grammatical storms. “Your teacher mapped this place twice,” she said. “The ministry erased him once. The rain erased him better.”\n\nAt an intersection of verbs, Nadir heard a crowd reciting his name incorrectly until it almost belonged to someone safer. His atlas grew heavier with every city that officially did not exist.\n\nHe could trade a memory for time, or he could keep the memory and risk the future. Then the hour in their hand began to bruise, and the rain began editing the word home."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 85,
    "branch_name": "Universe 085 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for The Thousand Door School. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "Attendance at the Impossible Corridor",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Nabila receives a blank attendance card and hears one door calling with her lost brother’s voice.",
    "excerpt": "Nabila was late on her first day because Door 1 refused to be a door. It had become a fish tank, then a mirror, then a rectangle of thundercloud, then finally a wooden classroom d",
    "content_md": "# Chapter 1 — Attendance at the Impossible Corridor\n\nNabila was late on her first day because Door 1 refused to be a door.\n\nIt had become a fish tank, then a mirror, then a rectangle of thundercloud, then finally a wooden classroom door with brass numbers and a sigh of irritation. By the time she stepped through, the impossible corridor had already taken attendance.\n\nSekolah Seribu Pintu stretched farther than the hill it was built on. Doors lined both walls in crooked rows, each leaking a different weather. Rain seeped from Door 22. Sand hissed beneath Door 107. From Door 508 came the smell of hospital antiseptic and fried bananas. Above them all, a bell rang without moving.\n\nThe headmaster smiled from the corridor’s centre. “Here we teach consequences before choices. Open wisely, and you graduate before you regret. Open carelessly, and regret will tutor you personally.”\n\nNabila looked at the attendance card in her hand. It should have listed her classes. Instead, it showed one thousand small blank doors.\n\nA whisper slid under Door 313.\n\nKak Bila.\n\nHer brother’s voice.\n\nHaris had disappeared two years ago after receiving a scholarship no one remembered offering. The police found his bicycle by the school gate. The school denied he had ever enrolled. Yet the whisper under Door 313 was exactly how he used to call her when he wanted help hiding from their mother.\n\nNabila stepped toward it.\n\nThe headmaster’s smile sharpened. “No first-year student opens a numbered door alone.”\n\n“Then why is it calling me?”\n\n“Because the doors are cruel enough to know what you love.”\n\nNabila pressed her palm to Door 313. The wood was warm, pulsing like a throat holding back a scream. Her attendance card filled with one black mark beside a choice she had not made yet.\n\nOpen, the door breathed.\n\nBehind her, the headmaster began to count down from ten."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 86,
    "branch_name": "Universe 086 · Door 313 Whispers",
    "branch_slug": "u086-door-313-whispers",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: Door 313 Whispers. The prose is written as a real scene, not filler text.",
    "chapter_title": "Door 313 Whispers",
    "chapter_slug": "chapter-1-door-313-whispers",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: door 313 whispers.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a star-shaped scar appear in the blank square.",
    "content_md": "# Chapter 1 — Door 313 Whispers\n\nNabila pressed her attendance card against Door 313 and saw a star-shaped scar appear in the blank square. From under the frame came the smell of rain on tin, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could ask the wrong question, or she could refuse the answer everyone wanted. Then a name vanished from every signboard, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 87,
    "branch_name": "Universe 087 · The Corridor Takes Attendance",
    "branch_slug": "u087-the-corridor-takes-attendance",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Corridor Takes Attendance. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Corridor Takes Attendance",
    "chapter_slug": "chapter-1-the-corridor-takes-attendance",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the corridor takes attendance.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a folded kite appear in the blank square.",
    "content_md": "# Chapter 1 — The Corridor Takes Attendance\n\nNabila pressed her attendance card against Door 313 and saw a folded kite appear in the blank square. From under the frame came the smell of sandalwood, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could follow mercy instead of certainty, or she could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 88,
    "branch_name": "Universe 088 · The Headmaster Counts Down",
    "branch_slug": "u088-the-headmaster-counts-down",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Headmaster Counts Down. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Headmaster Counts Down",
    "chapter_slug": "chapter-1-the-headmaster-counts-down",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the headmaster counts down.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a blue thread appear in the blank square.",
    "content_md": "# Chapter 1 — The Headmaster Counts Down\n\nNabila pressed her attendance card against Door 313 and saw a blue thread appear in the blank square. From under the frame came the smell of monsoon salt, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could follow the stranger through the market, or she could return home and warn one person. Then the road behind them folded into water, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 89,
    "branch_name": "Universe 089 · The Weather Under Door 22",
    "branch_slug": "u089-the-weather-under-door-22",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Weather Under Door 22. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Weather Under Door 22",
    "chapter_slug": "chapter-1-the-weather-under-door-22",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the weather under door 22.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a silver seed appear in the blank square.",
    "content_md": "# Chapter 1 — The Weather Under Door 22\n\nNabila pressed her attendance card against Door 313 and saw a silver seed appear in the blank square. From under the frame came the smell of burnt sugar, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could trust the oldest enemy, or she could doubt the kindest friend. Then the sky lowered as if listening, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 90,
    "branch_name": "Universe 090 · The Hospital Door Smells of Bananas",
    "branch_slug": "u090-the-hospital-door-smells-of-bananas",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Hospital Door Smells of Bananas. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Hospital Door Smells of Bananas",
    "chapter_slug": "chapter-1-the-hospital-door-smells-of-bananas",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the hospital door smells of bananas.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a glass bird appear in the blank square.",
    "content_md": "# Chapter 1 — The Hospital Door Smells of Bananas\n\nNabila pressed her attendance card against Door 313 and saw a glass bird appear in the blank square. From under the frame came the smell of sea iron, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could break a rule to save a name, or she could obey the rule and lose a face. Then the floor remembered footsteps that had never happened, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 91,
    "branch_name": "Universe 091 · The Scholarship No One Remembers",
    "branch_slug": "u091-the-scholarship-no-one-remembers",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Scholarship No One Remembers. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Scholarship No One Remembers",
    "chapter_slug": "chapter-1-the-scholarship-no-one-remembers",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the scholarship no one remembers.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a torn map appear in the blank square.",
    "content_md": "# Chapter 1 — The Scholarship No One Remembers\n\nNabila pressed her attendance card against Door 313 and saw a torn map appear in the blank square. From under the frame came the smell of clove smoke, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could walk into the forbidden district, or she could burn the map and follow the stars. Then a door appeared in the wall of rain, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 92,
    "branch_name": "Universe 092 · The Door for Someone Else",
    "branch_slug": "u092-the-door-for-someone-else",
    "branch_type": "fork",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Door for Someone Else. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Door for Someone Else",
    "chapter_slug": "chapter-1-the-door-for-someone-else",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the door for someone else.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a sleeping cat appear in the blank square.",
    "content_md": "# Chapter 1 — The Door for Someone Else\n\nNabila pressed her attendance card against Door 313 and saw a sleeping cat appear in the blank square. From under the frame came the smell of ozone, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could wake the city from its dream, or she could let the dream finish speaking. Then the moon blinked once and changed colour, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 93,
    "branch_name": "Universe 093 · The Class of Regret",
    "branch_slug": "u093-the-class-of-regret",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Class of Regret. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Class of Regret",
    "chapter_slug": "chapter-1-the-class-of-regret",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the class of regret.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a cracked bowl of ash appear in the blank square.",
    "content_md": "# Chapter 1 — The Class of Regret\n\nNabila pressed her attendance card against Door 313 and saw a cracked bowl of ash appear in the blank square. From under the frame came the smell of cold tea, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could protect the weakest witness, or she could protect the dangerous evidence. Then the witnesses began to whisper in unison, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 94,
    "branch_name": "Universe 094 · The Library Behind Door 508",
    "branch_slug": "u094-the-library-behind-door-508",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Library Behind Door 508. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Library Behind Door 508",
    "chapter_slug": "chapter-1-the-library-behind-door-508",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the library behind door 508.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a white feather appear in the blank square.",
    "content_md": "# Chapter 1 — The Library Behind Door 508\n\nNabila pressed her attendance card against Door 313 and saw a white feather appear in the blank square. From under the frame came the smell of library dust, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could carry the message alone, or she could share the burden with a rival. Then the message changed handwriting, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 95,
    "branch_name": "Universe 095 · The Exit That Becomes a Test",
    "branch_slug": "u095-the-exit-that-becomes-a-test",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Exit That Becomes a Test. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Exit That Becomes a Test",
    "chapter_slug": "chapter-1-the-exit-that-becomes-a-test",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the exit that becomes a test.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a cracked mirror appear in the blank square.",
    "content_md": "# Chapter 1 — The Exit That Becomes a Test\n\nNabila pressed her attendance card against Door 313 and saw a cracked mirror appear in the blank square. From under the frame came the smell of jasmine smoke, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could tell the truth before the town was ready, or she could hide the proof until morning. Then a bell rang from a place with no tower, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 96,
    "branch_name": "Universe 096 · The Brother Leaves a Chalk Mark",
    "branch_slug": "u096-the-brother-leaves-a-chalk-mark",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Brother Leaves a Chalk Mark. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Brother Leaves a Chalk Mark",
    "chapter_slug": "chapter-1-the-brother-leaves-a-chalk-mark",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the brother leaves a chalk mark.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a black kite appear in the blank square.",
    "content_md": "# Chapter 1 — The Brother Leaves a Chalk Mark\n\nNabila pressed her attendance card against Door 313 and saw a black kite appear in the blank square. From under the frame came the smell of wet earth, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could open the locked room, or she could leave the lock untouched. Then someone they loved called from the wrong side, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 97,
    "branch_name": "Universe 097 · The Door That Opens Backward",
    "branch_slug": "u097-the-door-that-opens-backward",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Door That Opens Backward. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Door That Opens Backward",
    "chapter_slug": "chapter-1-the-door-that-opens-backward",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the door that opens backward.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a paper crown appear in the blank square.",
    "content_md": "# Chapter 1 — The Door That Opens Backward\n\nNabila pressed her attendance card against Door 313 and saw a paper crown appear in the blank square. From under the frame came the smell of old rain, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could confess the secret aloud, or she could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and every door in the school inhaled at once."
  },
  {
    "story_slug": "thousand-door-school",
    "author_username": "nora_pathfinder",
    "universe_no": 98,
    "branch_name": "Universe 098 · The Thousandth Door Breathes",
    "branch_slug": "u098-the-thousandth-door-breathes",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of The Thousand Door School: The Thousandth Door Breathes. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Thousandth Door Breathes",
    "chapter_slug": "chapter-1-the-thousandth-door-breathes",
    "summary": "Nabila faces a different version of the first turning point in Sekolah Seribu Pintu: the thousandth door breathes.",
    "excerpt": "Nabila pressed her attendance card against Door 313 and saw a brass bowl appear in the blank square.",
    "content_md": "# Chapter 1 — The Thousandth Door Breathes\n\nNabila pressed her attendance card against Door 313 and saw a brass bowl appear in the blank square. From under the frame came the smell of mango leaves, exactly like the day Haris vanished.\n\nThe headmaster’s countdown echoed along the corridor. Behind other doors, students were learning consequences in tidy, supervised lessons. Behind this one, someone was scratching her brother’s name into the wood from the inside.\n\n“A door opens for the choice you are capable of making,” said the corridor itself. Nabila hated how kind it sounded. Capability was not permission, and fear was not wisdom.\n\nShe could trade a memory for time, or she could keep the memory and risk the future. Then the hour in their hand began to bruise, and every door in the school inhaled at once."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 99,
    "branch_name": "Universe 099 · Main Canon",
    "branch_slug": "main",
    "branch_type": "main",
    "visibility": "public",
    "description": "Primary canon path for Garden of the 112th Star. This is real narrative seed content for reading, publishing, and timeline exploration.",
    "chapter_title": "The Seed That Contained a Sky",
    "chapter_slug": "chapter-1-main-canon",
    "summary": "Zahra inherits a seed of black starlight and sees the first universe waiting inside it.",
    "excerpt": "The 112th star bloomed only once every thousand years. Zahra had expected fire. Everyone expected fire from stars.",
    "content_md": "# Chapter 1 — The Seed That Contained a Sky\n\nThe 112th star bloomed only once every thousand years.\n\nZahra had expected fire. Everyone expected fire from stars. Instead, the star opened like a flower at the centre of the garden, folding back petals of white flame to reveal a seed blacker than space. Around it, the orbiting terraces rang with the voices of gardeners, astronomers, pilgrims, and ghosts who had been waiting since before Zahra was born.\n\nThe seed fell into her hands.\n\nIt was cold.\n\nInside its polished darkness, Zahra saw a sky that did not belong to any chart. A child standing beside a red river. A city made of rain. A school corridor with too many doors. A broken moon, a paper kingdom, a glass prayer hall, a market at the edge of sleep. Worlds nested inside worlds, each asking for water.\n\nElder Samat lowered his pruning shears. “Do not be flattered. The star chooses hands, not hearts.”\n\n“What am I supposed to do with it?”\n\n“Choose which universe lives first.”\n\nThe terraces fell silent.\n\nEvery apprentice gardener learned the first cruelty of the cosmic garden: no watering can was infinite. To water one star-petal was to thicken its timeline, giving its people stronger chances, clearer coincidences, kinder weather. To withhold water was not murder, the elders said. It was discipline. It was order. It was how the garden survived without becoming a jungle of impossible mercy.\n\nZahra looked into the seed again.\n\nThis time she saw a universe where she refused to choose. In that world, the garden burned.\n\nA root of black starlight curled around her wrist. Far below the terraces, in the dark between stars, something enormous opened one patient eye.\n\nElder Samat handed her the first watering vessel. “Begin,” he said.\n\nZahra lifted the vessel and heard, from inside the seed, one hundred and twelve possible skies inhale."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 100,
    "branch_name": "Universe 100 · The First Watering",
    "branch_slug": "u100-the-first-watering",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The First Watering. The prose is written as a real scene, not filler text.",
    "chapter_title": "The First Watering",
    "chapter_slug": "chapter-1-the-first-watering",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the first watering.",
    "excerpt": "Zahra watered the star-petal marked with a cracked bowl of ash, and a universe unfolded in the scent of cold tea.",
    "content_md": "# Chapter 1 — The First Watering\n\nZahra watered the star-petal marked with a cracked bowl of ash, and a universe unfolded in the scent of cold tea. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could protect the weakest witness, or she could protect the dangerous evidence. Then the witnesses began to whisper in unison, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 101,
    "branch_name": "Universe 101 · The Petal of the Red River",
    "branch_slug": "u101-the-petal-of-the-red-river",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Petal of the Red River. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Petal of the Red River",
    "chapter_slug": "chapter-1-the-petal-of-the-red-river",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the petal of the red river.",
    "excerpt": "Zahra watered the star-petal marked with a white feather, and a universe unfolded in the scent of library dust.",
    "content_md": "# Chapter 1 — The Petal of the Red River\n\nZahra watered the star-petal marked with a white feather, and a universe unfolded in the scent of library dust. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could carry the message alone, or she could share the burden with a rival. Then the message changed handwriting, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 102,
    "branch_name": "Universe 102 · The Pruning Council",
    "branch_slug": "u102-the-pruning-council",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Pruning Council. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Pruning Council",
    "chapter_slug": "chapter-1-the-pruning-council",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the pruning council.",
    "excerpt": "Zahra watered the star-petal marked with a cracked mirror, and a universe unfolded in the scent of jasmine smoke.",
    "content_md": "# Chapter 1 — The Pruning Council\n\nZahra watered the star-petal marked with a cracked mirror, and a universe unfolded in the scent of jasmine smoke. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could tell the truth before the town was ready, or she could hide the proof until morning. Then a bell rang from a place with no tower, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 103,
    "branch_name": "Universe 103 · The Seed Shows a Burning Garden",
    "branch_slug": "u103-the-seed-shows-a-burning-garden",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Seed Shows a Burning Garden. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Seed Shows a Burning Garden",
    "chapter_slug": "chapter-1-the-seed-shows-a-burning-garden",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the seed shows a burning garden.",
    "excerpt": "Zahra watered the star-petal marked with a black kite, and a universe unfolded in the scent of wet earth.",
    "content_md": "# Chapter 1 — The Seed Shows a Burning Garden\n\nZahra watered the star-petal marked with a black kite, and a universe unfolded in the scent of wet earth. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could open the locked room, or she could leave the lock untouched. Then someone they loved called from the wrong side, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 104,
    "branch_name": "Universe 104 · The Black Star Root",
    "branch_slug": "u104-the-black-star-root",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Black Star Root. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Black Star Root",
    "chapter_slug": "chapter-1-the-black-star-root",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the black star root.",
    "excerpt": "Zahra watered the star-petal marked with a paper crown, and a universe unfolded in the scent of old rain.",
    "content_md": "# Chapter 1 — The Black Star Root\n\nZahra watered the star-petal marked with a paper crown, and a universe unfolded in the scent of old rain. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could confess the secret aloud, or she could write the secret where no one could erase it. Then every lamp in the street leaned toward them, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 105,
    "branch_name": "Universe 105 · The Universe That Refuses Mercy",
    "branch_slug": "u105-the-universe-that-refuses-mercy",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Universe That Refuses Mercy. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Universe That Refuses Mercy",
    "chapter_slug": "chapter-1-the-universe-that-refuses-mercy",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the universe that refuses mercy.",
    "excerpt": "Zahra watered the star-petal marked with a brass bowl, and a universe unfolded in the scent of mango leaves.",
    "content_md": "# Chapter 1 — The Universe That Refuses Mercy\n\nZahra watered the star-petal marked with a brass bowl, and a universe unfolded in the scent of mango leaves. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could trade a memory for time, or she could keep the memory and risk the future. Then the hour in their hand began to bruise, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 106,
    "branch_name": "Universe 106 · The Ghost Gardeners Vote",
    "branch_slug": "u106-the-ghost-gardeners-vote",
    "branch_type": "experimental",
    "visibility": "unlisted",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Ghost Gardeners Vote. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Ghost Gardeners Vote",
    "chapter_slug": "chapter-1-the-ghost-gardeners-vote",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the ghost gardeners vote.",
    "excerpt": "Zahra watered the star-petal marked with a red umbrella, and a universe unfolded in the scent of river mud.",
    "content_md": "# Chapter 1 — The Ghost Gardeners Vote\n\nZahra watered the star-petal marked with a red umbrella, and a universe unfolded in the scent of river mud. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could forgive the betrayer, or she could name the betrayer in public. Then the crowd heard a sound like paper catching fire, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 107,
    "branch_name": "Universe 107 · The Watering Vessel Cracks",
    "branch_slug": "u107-the-watering-vessel-cracks",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Watering Vessel Cracks. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Watering Vessel Cracks",
    "chapter_slug": "chapter-1-the-watering-vessel-cracks",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the watering vessel cracks.",
    "excerpt": "Zahra watered the star-petal marked with a copper ring, and a universe unfolded in the scent of coconut oil.",
    "content_md": "# Chapter 1 — The Watering Vessel Cracks\n\nZahra watered the star-petal marked with a copper ring, and a universe unfolded in the scent of coconut oil. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could turn back before crossing the bridge, or she could cross and become responsible. Then their shadow arrived one step early, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 108,
    "branch_name": "Universe 108 · The Petal That Contains a School",
    "branch_slug": "u108-the-petal-that-contains-a-school",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Petal That Contains a School. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Petal That Contains a School",
    "chapter_slug": "chapter-1-the-petal-that-contains-a-school",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the petal that contains a school.",
    "excerpt": "Zahra watered the star-petal marked with a star-shaped scar, and a universe unfolded in the scent of rain on tin.",
    "content_md": "# Chapter 1 — The Petal That Contains a School\n\nZahra watered the star-petal marked with a star-shaped scar, and a universe unfolded in the scent of rain on tin. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could ask the wrong question, or she could refuse the answer everyone wanted. Then a name vanished from every signboard, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 109,
    "branch_name": "Universe 109 · The Terraces Lose Their Orbit",
    "branch_slug": "u109-the-terraces-lose-their-orbit",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Terraces Lose Their Orbit. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Terraces Lose Their Orbit",
    "chapter_slug": "chapter-1-the-terraces-lose-their-orbit",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the terraces lose their orbit.",
    "excerpt": "Zahra watered the star-petal marked with a folded kite, and a universe unfolded in the scent of sandalwood.",
    "content_md": "# Chapter 1 — The Terraces Lose Their Orbit\n\nZahra watered the star-petal marked with a folded kite, and a universe unfolded in the scent of sandalwood. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could follow mercy instead of certainty, or she could choose certainty and pay for mercy later. Then a hidden stair unfolded from the light, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 110,
    "branch_name": "Universe 110 · The Eye Between Stars",
    "branch_slug": "u110-the-eye-between-stars",
    "branch_type": "alternate",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Eye Between Stars. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Eye Between Stars",
    "chapter_slug": "chapter-1-the-eye-between-stars",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the eye between stars.",
    "excerpt": "Zahra watered the star-petal marked with a blue thread, and a universe unfolded in the scent of monsoon salt.",
    "content_md": "# Chapter 1 — The Eye Between Stars\n\nZahra watered the star-petal marked with a blue thread, and a universe unfolded in the scent of monsoon salt. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could follow the stranger through the market, or she could return home and warn one person. Then the road behind them folded into water, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 111,
    "branch_name": "Universe 111 · The Apprentice Saves a Withering Path",
    "branch_slug": "u111-the-apprentice-saves-a-withering-path",
    "branch_type": "fork",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The Apprentice Saves a Withering Path. The prose is written as a real scene, not filler text.",
    "chapter_title": "The Apprentice Saves a Withering Path",
    "chapter_slug": "chapter-1-the-apprentice-saves-a-withering-path",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the apprentice saves a withering path.",
    "excerpt": "Zahra watered the star-petal marked with a silver seed, and a universe unfolded in the scent of burnt sugar.",
    "content_md": "# Chapter 1 — The Apprentice Saves a Withering Path\n\nZahra watered the star-petal marked with a silver seed, and a universe unfolded in the scent of burnt sugar. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could trust the oldest enemy, or she could doubt the kindest friend. Then the sky lowered as if listening, and one more star in the impossible garden began to bloom."
  },
  {
    "story_slug": "garden-112th-star",
    "author_username": "demo_admin",
    "universe_no": 112,
    "branch_name": "Universe 112 · The 112th Sky Answers",
    "branch_slug": "u112-the-112th-sky-answers",
    "branch_type": "experimental",
    "visibility": "public",
    "description": "A ForkCraft-ready path of Garden of the 112th Star: The 112th Sky Answers. The prose is written as a real scene, not filler text.",
    "chapter_title": "The 112th Sky Answers",
    "chapter_slug": "chapter-1-the-112th-sky-answers",
    "summary": "Zahra faces a different version of the first turning point in the Garden of the 112th Star: the 112th sky answers.",
    "excerpt": "Zahra watered the star-petal marked with a glass bird, and a universe unfolded in the scent of sea iron.",
    "content_md": "# Chapter 1 — The 112th Sky Answers\n\nZahra watered the star-petal marked with a glass bird, and a universe unfolded in the scent of sea iron. Rivers, cities, schools, ships, and sleeping markets lifted like images inside a bowl.\n\nElder Samat raised his pruning shears. “Do not grow attached to a possible world,” he warned. “Attachment is how gardeners drown the garden.” But inside the petal, a child looked up as if hearing her name.\n\nThe black seed at Zahra’s wrist tightened. It showed her a future where mercy became chaos and another where order became cruelty. Neither future had clean hands.\n\nShe could break a rule to save a name, or she could obey the rule and lose a face. Then the floor remembered footsteps that had never happened, and one more star in the impossible garden began to bloom."
  }
]$branches_json$::jsonb)
      as x(
        story_slug text,
        author_username text,
        universe_no integer,
        branch_name text,
        branch_slug text,
        branch_type text,
        visibility text,
        description text,
        chapter_title text,
        chapter_slug text,
        summary text,
        excerpt text,
        content_md text
      )
    order by universe_no
  loop
    select id, status into v_story_id, v_story_status
    from public.stories
    where slug = b.story_slug;

    if v_story_id is null then
      raise exception 'Missing story slug: %', b.story_slug;
    end if;

    select id into v_author_id
    from public.profiles
    where username = b.author_username;

    if v_author_id is null then
      raise exception 'Missing author profile username: %', b.author_username;
    end if;

    v_parent_branch_id := null;
    v_forked_from_version_id := null;

    if b.branch_type = 'main' then
      select id into v_branch_id
      from public.story_branches
      where story_id = v_story_id
        and slug = 'main'
      order by created_at asc
      limit 1;

      if v_branch_id is null then
        insert into public.story_branches (
          story_id,
          parent_branch_id,
          created_by,
          name,
          slug,
          description,
          branch_type,
          status,
          visibility,
          forked_from_version_id,
          created_at,
          updated_at
        )
        values (
          v_story_id,
          null,
          v_author_id,
          b.branch_name,
          'main',
          b.description,
          'main',
          'active',
          b.visibility,
          null,
          timezone('utc', now()) - ((112 - b.universe_no) * interval '1 hour'),
          timezone('utc', now())
        )
        returning id into v_branch_id;
      else
        update public.story_branches
        set created_by = v_author_id,
            name = b.branch_name,
            slug = 'main',
            description = b.description,
            branch_type = 'main',
            status = 'active',
            visibility = b.visibility,
            parent_branch_id = null,
            forked_from_version_id = null,
            updated_at = timezone('utc', now())
        where id = v_branch_id;
      end if;

      update public.stories
      set main_branch_id = v_branch_id,
          updated_at = timezone('utc', now())
      where id = v_story_id;
    else
      select main_branch_id into v_parent_branch_id
      from public.stories
      where id = v_story_id;

      select cv.id into v_forked_from_version_id
      from public.chapter_versions cv
      join public.chapters c on c.id = cv.chapter_id
      where c.branch_id = v_parent_branch_id
        and cv.is_current = true
      order by cv.created_at desc
      limit 1;

      insert into public.story_branches (
        story_id,
        parent_branch_id,
        created_by,
        name,
        slug,
        description,
        branch_type,
        status,
        visibility,
        forked_from_version_id,
        created_at,
        updated_at
      )
      values (
        v_story_id,
        v_parent_branch_id,
        v_author_id,
        b.branch_name,
        b.branch_slug,
        b.description,
        b.branch_type,
        'active',
        b.visibility,
        v_forked_from_version_id,
        timezone('utc', now()) - ((112 - b.universe_no) * interval '1 hour'),
        timezone('utc', now())
      )
      returning id into v_branch_id;
    end if;

    v_is_published := (v_story_status = 'published' and b.visibility in ('public', 'unlisted'));

    insert into public.chapters (
      story_id,
      branch_id,
      chapter_number,
      title,
      slug,
      summary,
      is_published,
      published_at,
      created_by,
      created_at,
      updated_at
    )
    values (
      v_story_id,
      v_branch_id,
      1,
      b.chapter_title,
      b.chapter_slug,
      b.summary,
      v_is_published,
      case when v_is_published then timezone('utc', now()) - ((112 - b.universe_no) * interval '1 hour') else null end,
      v_author_id,
      timezone('utc', now()) - ((112 - b.universe_no) * interval '1 hour'),
      timezone('utc', now())
    )
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
      created_by,
      created_at
    )
    values (
      v_chapter_id,
      1,
      b.chapter_title,
      b.excerpt,
      b.content_md,
      'import',
      'Real narrative seed v1: written prose branch for ForkCraft simulation.',
      true,
      v_author_id,
      timezone('utc', now()) - ((112 - b.universe_no) * interval '1 hour')
    )
    returning id into v_version_id;
  end loop;
end
$branches$;

-- 4) Lightweight activity so likes, follows, bookmarks, comments, and feeds have something real to show.
insert into public.follows (user_id, story_id, created_at)
select u.id, s.id, timezone('utc', now()) - ((row_number() over ()) * interval '7 minutes')
from public.profiles u
join public.stories s on s.slug in (
  'river-that-remembers',
  'lanterns-over-seri-bay',
  'clockmakers-orchard',
  'orbit-of-the-last-musafir',
  'glass-masjid-seven-moons',
  'neon-keris-protocol',
  'ashes-paper-kingdom',
  'bazaar-edge-of-sleep',
  'thousand-door-school',
  'garden-112th-star'
)
where u.username in ('maya_reader', 'nora_pathfinder', 'omar_forkcrafter', 'lina_writer')
  and u.id <> s.author_id
  and not exists (
    select 1 from public.follows f where f.user_id = u.id and f.story_id = s.id
  );

insert into public.likes (user_id, chapter_version_id, created_at)
select u.id, cv.id, timezone('utc', now()) - ((row_number() over ()) * interval '5 minutes')
from public.profiles u
join public.chapter_versions cv on true
join public.chapters c on c.id = cv.chapter_id
join public.stories s on s.id = c.story_id
where u.username in ('maya_reader', 'nora_pathfinder', 'aiman_arc', 'sara_editor')
  and cv.is_current = true
  and c.is_published = true
  and s.visibility = 'public'
  and ((abs(hashtext(u.username || ':' || s.slug || ':' || c.slug)::bigint) % 5) in (0, 2))
  and not exists (
    select 1 from public.likes l where l.user_id = u.id and l.chapter_version_id = cv.id
  );

insert into public.bookmarks (user_id, chapter_id, tag, is_public, created_at)
select u.id,
       c.id,
       case
         when c.summary ilike '%choice%' then 'fork-point'
         when s.genre_text ilike '%Mystery%' then 'clue'
         else 'turning-point'
       end,
       ((abs(hashtext(u.username || ':' || c.slug)::bigint) % 2) = 0),
       timezone('utc', now()) - ((row_number() over ()) * interval '11 minutes')
from public.profiles u
join (
  select st.id, st.slug, coalesce(st.synopsis, '') as genre_text
  from public.stories st
  where st.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
) s on true
join public.chapters c on c.story_id = s.id
where u.username in ('maya_reader', 'nora_pathfinder')
  and c.is_published = true
  and ((abs(hashtext(u.username || ':' || s.slug || ':' || c.slug)::bigint) % 7) in (0, 1))
  and not exists (
    select 1 from public.bookmarks b where b.user_id = u.id and b.chapter_id = c.id
  );

insert into public.comments (chapter_id, story_id, user_id, parent_comment_id, body, is_spoiler, created_at, updated_at)
select c.id,
       s.id,
       u.id,
       null,
       case (abs(hashtext(u.username || ':' || s.slug)::bigint) % 6)
         when 0 then 'This turning point feels like a real fork, not just a cosmetic branch.'
         when 1 then 'I want to follow the consequence of this choice into another timeline.'
         when 2 then 'The world rule is clear here. I can understand why this branch exists.'
         when 3 then 'Strong opening image. This chapter makes the universe easy to remember.'
         when 4 then 'This path should be compared beside the main canon in the timeline view.'
         else 'Bookmarking this because the last paragraph gives a strong choice point.'
       end,
       false,
       timezone('utc', now()) - ((row_number() over ()) * interval '13 minutes'),
       timezone('utc', now()) - ((row_number() over ()) * interval '13 minutes')
from public.stories s
join public.chapters c on c.story_id = s.id and c.chapter_number = 1
join public.story_branches sb on sb.id = c.branch_id and sb.branch_type = 'main'
join public.profiles u on u.username in ('maya_reader', 'nora_pathfinder', 'omar_forkcrafter')
where s.slug in (
  'river-that-remembers',
  'lanterns-over-seri-bay',
  'clockmakers-orchard',
  'orbit-of-the-last-musafir',
  'glass-masjid-seven-moons',
  'neon-keris-protocol',
  'ashes-paper-kingdom',
  'bazaar-edge-of-sleep',
  'thousand-door-school',
  'garden-112th-star'
)
  and u.id <> s.author_id;

commit;

-- Verification summary.
select 'stories' as object, count(*)::text as total
from public.stories
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'branches', count(*)::text
from public.story_branches
where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'))
union all
select 'chapters', count(*)::text
from public.chapters
where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'))
union all
select 'chapter_versions', count(*)::text
from public.chapter_versions cv
join public.chapters c on c.id = cv.chapter_id
join public.stories s on s.id = c.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'seed_login_users', count(*)::text
from public.profiles
where username in ('demo_admin','lina_writer','omar_forkcrafter','maya_reader','tariq_worldsmith','sara_editor','aiman_arc','nora_pathfinder');
