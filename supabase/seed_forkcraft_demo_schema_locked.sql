-- Narrio Demo Seed HOTFIX 3: schema-locked, no staging tables
-- Target: current uploaded schema 20260429-8-26am-Database-Schema.txt
-- Creates: 8 demo users, 12 stories, 112 total universe/timeline branches, 112 chapters, social activity.
-- Password for all demo users: test123
-- Safe for local/dev only. Do not run this file on production.

create extension if not exists "pgcrypto";

-- 1) Auth users + public profiles.
do $$
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
end $$;

-- 2) Stories and their main canon branches.
do $$
declare
  s record;
  v_author_id uuid;
  v_story_id uuid;
  v_main_branch_id uuid;
begin
  for s in
    select * from (values
    ('river-that-remembers', 'The River That Remembers', 'lina_writer', 'Level 1 · Starter Canon', 'Memory Fantasy', 3, 'published', 'public', 'A river town remembers every choice its people tried to forget. A gentle starter universe with a few clear Forkcraft paths.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+River+That+Remembers', true),
    ('lanterns-over-seri-bay', 'Lanterns Over Seri Bay', 'omar_forkcrafter', 'Level 2 · Reader Choice Mystery', 'Coastal Mystery', 5, 'published', 'public', 'Every lantern released over Seri Bay carries a secret route home. A compact mystery with reader-friendly timeline forks.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Lanterns+Over+Seri+Bay', true),
    ('clockmakers-orchard', 'The Clockmaker''s Orchard', 'sara_editor', 'Level 3 · Growing World', 'Clockwork Fable', 6, 'published', 'public', 'An orchard grows clocks instead of fruit, and every harvest opens a different year. A growing world with stable canon and side paths.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Clockmakers+Orchard', true),
    ('orbit-of-the-last-musafir', 'Orbit of the Last Musafir', 'aiman_arc', 'Level 4 · Sci-Fi Pilgrimage', 'Spiritual Sci-Fi', 7, 'published', 'public', 'A lone traveller circles a broken moon, seeking the qiblah of a lost generation ship. A mid-level universe for alternate journeys.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Orbit+of+the+Last+Musafir', true),
    ('glass-masjid-seven-moons', 'The Glass Masjid of Seven Moons', 'lina_writer', 'Level 5 · Reflective Epic', 'Reflective Fantasy', 8, 'published', 'public', 'Seven moons shine through a glass masjid, each revealing a different prayer, test, and timeline.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Glass+Masjid+of+Seven+Moons', true),
    ('neon-keris-protocol', 'Neon Keris Protocol', 'omar_forkcrafter', 'Level 6 · Action Forkcraft', 'Cyber Nusantara', 9, 'published', 'public', 'A cyber-Melayu city hides an ancient keris protocol inside its surveillance grid. Built for fast, high-energy forks.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Neon+Keris+Protocol', true),
    ('ashes-paper-kingdom', 'Ashes of the Paper Kingdom', 'sara_editor', 'Level 7 · Closed Canon Showcase', 'Political Fable', 10, 'published', 'public', 'A kingdom writes its laws on paper that burns when leaders lie. Official alternate timelines exist, but public Forkcraft is closed.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Ashes+of+the+Paper+Kingdom', false),
    ('child-borrowed-tomorrow', 'The Child Who Borrowed Tomorrow', 'aiman_arc', 'Level 8 · Private Draft Lab', 'Time Loop', 11, 'draft', 'private', 'A child borrows one day from the future and must return it with interest. Kept private to test draft and visibility gates.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Child+Who+Borrowed+Tomorrow', true),
    ('bazaar-edge-of-sleep', 'Bazaar at the Edge of Sleep', 'tariq_worldsmith', 'Level 9 · Dream Market', 'Dream Bazaar', 12, 'published', 'public', 'At the edge of sleep, traders sell memories, unfinished dreams, and alternate endings.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Bazaar+at+the+Edge+of+Sleep', true),
    ('atlas-rain-cities', 'Atlas of Rain-Cities', 'tariq_worldsmith', 'Level 10 · Unlisted Worldbook', 'Worldbuilding Travelogue', 13, 'published', 'unlisted', 'A cartographer maps cities where rain changes language, law, and destiny. Unlisted for direct-link testing.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Atlas+of+Rain-Cities', true),
    ('thousand-door-school', 'The Thousand Door School', 'nora_pathfinder', 'Level 11 · Community Forkcraft', 'Academy Multiverse', 14, 'published', 'public', 'A school with one thousand doors teaches students to enter consequences before opening choices.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Thousand+Door+School', true),
    ('garden-112th-star', 'Garden of the 112th Star', 'demo_admin', 'Level 12 · Flagship Multiverse', 'Flagship Cosmic Fantasy', 14, 'published', 'public', 'A cosmic garden grows around the 112th star, where every petal is a possible universe.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Garden+of+the+112th+Star', true)
    ) as v(slug, title, author_username, level_label, genre, total_universes, status, visibility, synopsis, cover_url, allow_forks)
  loop
    select id into v_author_id
    from public.profiles
    where username = s.author_username;

    insert into public.stories (
      author_id, forked_from_story_id, title, slug, synopsis, cover_url,
      status, visibility, allow_forks, main_branch_id
    )
    values (
      v_author_id,
      null,
      s.title,
      s.slug,
      '[' || s.level_label || '] [' || s.genre || '] ' || s.synopsis,
      s.cover_url,
      s.status,
      s.visibility,
      s.allow_forks,
      null
    )
    on conflict (slug) do update
    set author_id = excluded.author_id,
        title = excluded.title,
        synopsis = excluded.synopsis,
        cover_url = excluded.cover_url,
        status = excluded.status,
        visibility = excluded.visibility,
        allow_forks = excluded.allow_forks,
        updated_at = timezone('utc', now())
    returning id into v_story_id;

    select id into v_main_branch_id
    from public.story_branches
    where story_id = v_story_id
      and branch_type = 'main'
    order by created_at asc
    limit 1;

    if v_main_branch_id is null then
      insert into public.story_branches (
        story_id, parent_branch_id, created_by, name, slug, description,
        branch_type, status, visibility
      )
      values (
        v_story_id,
        null,
        v_author_id,
        'Main Canon · ' || s.level_label,
        'main',
        'Primary canon timeline for ' || s.title || '. Seeded as the main path for this story.',
        'main',
        'active',
        s.visibility
      )
      returning id into v_main_branch_id;
    end if;

    update public.story_branches
    set created_by = v_author_id,
        name = 'Main Canon · ' || s.level_label,
        slug = 'main',
        description = 'Primary canon timeline for ' || s.title || '. Seeded as the main path for this story.',
        branch_type = 'main',
        status = 'active',
        visibility = s.visibility,
        updated_at = timezone('utc', now())
    where id = v_main_branch_id;

    update public.stories
    set main_branch_id = v_main_branch_id,
        updated_at = timezone('utc', now())
    where id = v_story_id;
  end loop;
end $$;

-- 3) Variant timeline branches. No staging tables. No assumed unique constraints on story_branches.
do $$
declare
  b record;
  v_story_id uuid;
  v_parent_branch_id uuid;
  v_author_id uuid;
  v_branch_id uuid;
begin
  for b in
    select * from (values
    ('river-that-remembers', 'Universe 013 · Moonlit Canon', 'u013-moonlit-canon', 'Moonlit Canon variation for The River That Remembers. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('river-that-remembers', 'Universe 014 · Storm Door', 'u014-storm-door', 'Storm Door variation for The River That Remembers. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('lanterns-over-seri-bay', 'Universe 015 · Quiet Market', 'u015-quiet-market', 'Quiet Market variation for Lanterns Over Seri Bay. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('lanterns-over-seri-bay', 'Universe 016 · Broken Compass', 'u016-broken-compass', 'Broken Compass variation for Lanterns Over Seri Bay. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('lanterns-over-seri-bay', 'Universe 017 · Hidden Heir', 'u017-hidden-heir', 'Hidden Heir variation for Lanterns Over Seri Bay. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('lanterns-over-seri-bay', 'Universe 018 · Silver Rain', 'u018-silver-rain', 'Silver Rain variation for Lanterns Over Seri Bay. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('clockmakers-orchard', 'Universe 019 · Ash Lantern', 'u019-ash-lantern', 'Ash Lantern variation for The Clockmaker''s Orchard. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('clockmakers-orchard', 'Universe 020 · Mirror Road', 'u020-mirror-road', 'Mirror Road variation for The Clockmaker''s Orchard. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('clockmakers-orchard', 'Universe 021 · Forgotten Library', 'u021-forgotten-library', 'Forgotten Library variation for The Clockmaker''s Orchard. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('clockmakers-orchard', 'Universe 022 · Tiger Gate', 'u022-tiger-gate', 'Tiger Gate variation for The Clockmaker''s Orchard. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('clockmakers-orchard', 'Universe 023 · Clock Rain', 'u023-clock-rain', 'Clock Rain variation for The Clockmaker''s Orchard. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 024 · Saffron Dawn', 'u024-saffron-dawn', 'Saffron Dawn variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 025 · Blue Minaret', 'u025-blue-minaret', 'Blue Minaret variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 026 · Neon Wadi', 'u026-neon-wadi', 'Neon Wadi variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 027 · Paper Crown', 'u027-paper-crown', 'Paper Crown variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 028 · Star Orchard', 'u028-star-orchard', 'Star Orchard variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 029 · Black Kite', 'u029-black-kite', 'Black Kite variation for Orbit of the Last Musafir. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('glass-masjid-seven-moons', 'Universe 030 · Jasmine Signal', 'u030-jasmine-signal', 'Jasmine Signal variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('glass-masjid-seven-moons', 'Universe 031 · Glass River', 'u031-glass-river', 'Glass River variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('glass-masjid-seven-moons', 'Universe 032 · Copper Moon', 'u032-copper-moon', 'Copper Moon variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('glass-masjid-seven-moons', 'Universe 033 · Whisper Bazaar', 'u033-whisper-bazaar', 'Whisper Bazaar variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('glass-masjid-seven-moons', 'Universe 034 · Cloud Caravan', 'u034-cloud-caravan', 'Cloud Caravan variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('glass-masjid-seven-moons', 'Universe 035 · Final Ferry', 'u035-final-ferry', 'Final Ferry variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('glass-masjid-seven-moons', 'Universe 036 · Midnight Archive', 'u036-midnight-archive', 'Midnight Archive variation for The Glass Masjid of Seven Moons. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('neon-keris-protocol', 'Universe 037 · Garden Gate', 'u037-garden-gate', 'Garden Gate variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 038 · Old Radio', 'u038-old-radio', 'Old Radio variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('neon-keris-protocol', 'Universe 039 · Flooded School', 'u039-flooded-school', 'Flooded School variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('neon-keris-protocol', 'Universe 040 · Coral Bridge', 'u040-coral-bridge', 'Coral Bridge variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 041 · Ember Treaty', 'u041-ember-treaty', 'Ember Treaty variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('neon-keris-protocol', 'Universe 042 · Twin Eclipse', 'u042-twin-eclipse', 'Twin Eclipse variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('neon-keris-protocol', 'Universe 043 · Shadow Script', 'u043-shadow-script', 'Shadow Script variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 044 · Lunar Court', 'u044-lunar-court', 'Lunar Court variation for Neon Keris Protocol. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('ashes-paper-kingdom', 'Universe 045 · Borrowed Map', 'u045-borrowed-map', 'Borrowed Map variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('ashes-paper-kingdom', 'Universe 046 · Velvet Storm', 'u046-velvet-storm', 'Velvet Storm variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 047 · Wandering Imam', 'u047-wandering-imam', 'Wandering Imam variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 048 · Electric Monsoon', 'u048-electric-monsoon', 'Electric Monsoon variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('ashes-paper-kingdom', 'Universe 049 · Tin Soldier', 'u049-tin-soldier', 'Tin Soldier variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 050 · Rose Labyrinth', 'u050-rose-labyrinth', 'Rose Labyrinth variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 051 · Salt Kingdom', 'u051-salt-kingdom', 'Salt Kingdom variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('ashes-paper-kingdom', 'Universe 052 · Firefly Ledger', 'u052-firefly-ledger', 'Firefly Ledger variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 053 · Cedar Key', 'u053-cedar-key', 'Cedar Key variation for Ashes of the Paper Kingdom. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('child-borrowed-tomorrow', 'Universe 054 · Broken Minaret', 'u054-broken-minaret', 'Broken Minaret variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 055 · Jade Signal', 'u055-jade-signal', 'Jade Signal variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 056 · River Engine', 'u056-river-engine', 'River Engine variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 057 · Silent Drum', 'u057-silent-drum', 'Silent Drum variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 058 · Golden Kite', 'u058-golden-kite', 'Golden Kite variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 059 · Hollow Crown', 'u059-hollow-crown', 'Hollow Crown variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 060 · Orchid Labyrinth', 'u060-orchid-labyrinth', 'Orchid Labyrinth variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 061 · Sunken Train', 'u061-sunken-train', 'Sunken Train variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 062 · Rainmaker Pact', 'u062-rainmaker-pact', 'Rainmaker Pact variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 063 · Crystal Compass', 'u063-crystal-compass', 'Crystal Compass variation for The Child Who Borrowed Tomorrow. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'private'),
    ('bazaar-edge-of-sleep', 'Universe 064 · Lamp of Names', 'u064-lamp-of-names', 'Lamp of Names variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 065 · Tiger Calendar', 'u065-tiger-calendar', 'Tiger Calendar variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 066 · Memory Market', 'u066-memory-market', 'Memory Market variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 067 · Clockwise Sea', 'u067-clockwise-sea', 'Clockwise Sea variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 068 · Sundial Child', 'u068-sundial-child', 'Sundial Child variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 069 · Nebula Serambi', 'u069-nebula-serambi', 'Nebula Serambi variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 070 · Sparrow Treaty', 'u070-sparrow-treaty', 'Sparrow Treaty variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 071 · Folded Planet', 'u071-folded-planet', 'Folded Planet variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 072 · Hidden Garden', 'u072-hidden-garden', 'Hidden Garden variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 073 · Bronze Telescope', 'u073-bronze-telescope', 'Bronze Telescope variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 074 · Rain-City Seven', 'u074-rain-city-seven', 'Rain-City Seven variation for Bazaar at the Edge of Sleep. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('atlas-rain-cities', 'Universe 075 · Ruby Stair', 'u075-ruby-stair', 'Ruby Stair variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 076 · Singing Archive', 'u076-singing-archive', 'Singing Archive variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 077 · Night Ferry', 'u077-night-ferry', 'Night Ferry variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 078 · Coral Observatory', 'u078-coral-observatory', 'Coral Observatory variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 079 · Monsoon Archive', 'u079-monsoon-archive', 'Monsoon Archive variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 080 · Chalk Galaxy', 'u080-chalk-galaxy', 'Chalk Galaxy variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 081 · Sea of Ink', 'u081-sea-of-ink', 'Sea of Ink variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 082 · Paper Boat', 'u082-paper-boat', 'Paper Boat variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 083 · Secret Orchard', 'u083-secret-orchard', 'Secret Orchard variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 084 · The Third Door', 'u084-the-third-door', 'The Third Door variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 085 · Echo Mosque', 'u085-echo-mosque', 'Echo Mosque variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 086 · Wounded Moon', 'u086-wounded-moon', 'Wounded Moon variation for Atlas of Rain-Cities. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'unlisted'),
    ('thousand-door-school', 'Universe 087 · Crescent Engine', 'u087-crescent-engine', 'Crescent Engine variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 088 · Dragonfly Map', 'u088-dragonfly-map', 'Dragonfly Map variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 089 · Silver School', 'u089-silver-school', 'Silver School variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 090 · Rainbow Bridge', 'u090-rainbow-bridge', 'Rainbow Bridge variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 091 · Old King Road', 'u091-old-king-road', 'Old King Road variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 092 · Glass Umbrella', 'u092-glass-umbrella', 'Glass Umbrella variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 093 · Fever Garden', 'u093-fever-garden', 'Fever Garden variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 094 · Mirror Sultan', 'u094-mirror-sultan', 'Mirror Sultan variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 095 · Star Jasmine', 'u095-star-jasmine', 'Star Jasmine variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 096 · Kite Harbour', 'u096-kite-harbour', 'Kite Harbour variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 097 · Pearl Circuit', 'u097-pearl-circuit', 'Pearl Circuit variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 098 · Dusk Treaty', 'u098-dusk-treaty', 'Dusk Treaty variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 099 · Clockwork Date Palm', 'u099-clockwork-date-palm', 'Clockwork Date Palm variation for The Thousand Door School. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 100 · Thousand Steps', 'u100-thousand-steps', 'Thousand Steps variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 101 · Goldfish Moon', 'u101-goldfish-moon', 'Goldfish Moon variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 102 · Unwritten Exam', 'u102-unwritten-exam', 'Unwritten Exam variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 103 · Mango Eclipse', 'u103-mango-eclipse', 'Mango Eclipse variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 104 · Wayfarer Code', 'u104-wayfarer-code', 'Wayfarer Code variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 105 · Singing Well', 'u105-singing-well', 'Singing Well variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 106 · Cobalt Orchard', 'u106-cobalt-orchard', 'Cobalt Orchard variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 107 · Sleep Gate', 'u107-sleep-gate', 'Sleep Gate variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 108 · Ivory Monsoon', 'u108-ivory-monsoon', 'Ivory Monsoon variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 109 · Hijrah Star', 'u109-hijrah-star', 'Hijrah Star variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 110 · Empty Throne', 'u110-empty-throne', 'Empty Throne variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 111 · First Petal', 'u111-first-petal', 'First Petal variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 112 · Last Lantern', 'u112-last-lantern', 'Last Lantern variation for Garden of the 112th Star. Seeded to simulate Forkcraft discovery, timeline comparison, alternate reader journeys, and public/private visibility gates.', 'alternate', 'public')
    ) as v(story_slug, name, slug, description, branch_type, visibility)
  loop
    select id, main_branch_id, author_id
    into v_story_id, v_parent_branch_id, v_author_id
    from public.stories
    where slug = b.story_slug;

    select id into v_branch_id
    from public.story_branches
    where story_id = v_story_id
      and slug = b.slug
    order by created_at asc
    limit 1;

    if v_branch_id is null then
      insert into public.story_branches (
        story_id, parent_branch_id, created_by, name, slug, description,
        branch_type, status, visibility
      )
      values (
        v_story_id,
        v_parent_branch_id,
        v_author_id,
        b.name,
        b.slug,
        b.description,
        b.branch_type,
        'active',
        b.visibility
      )
      returning id into v_branch_id;
    end if;

    update public.story_branches
    set parent_branch_id = v_parent_branch_id,
        created_by = v_author_id,
        name = b.name,
        description = b.description,
        branch_type = b.branch_type,
        status = 'active',
        visibility = b.visibility,
        updated_at = timezone('utc', now())
    where id = v_branch_id;
  end loop;
end $$;

-- 4) One seeded chapter and one current version for every seeded branch.
do $$
declare
  br record;
  v_chapter_id uuid;
  v_version_id uuid;
  v_is_published boolean;
  v_excerpt text;
  v_body text;
begin
  for br in
    select
      s.id as story_id,
      s.slug as story_slug,
      s.title as story_title,
      s.status as story_status,
      s.visibility as story_visibility,
      s.author_id,
      sb.id as branch_id,
      sb.slug as branch_slug,
      sb.name as branch_name,
      sb.branch_type,
      sb.visibility as branch_visibility
    from public.stories s
    join public.story_branches sb on sb.story_id = s.id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
    order by s.slug, case when sb.branch_type = 'main' then 0 else 1 end, sb.slug
  loop
    v_is_published := br.story_status = 'published'
      and br.story_visibility in ('public', 'unlisted')
      and br.branch_visibility in ('public', 'unlisted');

    v_excerpt := 'A seeded opening signal for ' || br.branch_name || ' in ' || br.story_title || '.';
    v_body := '# ' || br.branch_name || E'

'
      || 'This is a demo chapter generated for Narrio simulation. It belongs to **' || br.story_title || '** and represents the **' || br.branch_name || '** universe path.' || E'

'
      || 'The reader reaches a fork point where the canon can continue, bend, or become a new path. This seeded text is intentionally short so the platform can demonstrate publishing, discovery, timeline exploration, bookmarks, likes, follows, comments, and Forkcraft branches without overwhelming the test environment.' || E'

'
      || '**Forkcraft prompt:** What would change if this universe chose courage before certainty?';

    select id into v_chapter_id
    from public.chapters
    where branch_id = br.branch_id
      and chapter_number = 1
    order by created_at asc
    limit 1;

    if v_chapter_id is null then
      insert into public.chapters (
        story_id, branch_id, chapter_number, title, slug, summary,
        is_published, published_at, created_by
      )
      values (
        br.story_id,
        br.branch_id,
        1,
        'Opening Signal · ' || br.branch_name,
        'opening-signal-' || br.branch_slug,
        v_excerpt,
        v_is_published,
        case when v_is_published then timezone('utc', now()) else null end,
        br.author_id
      )
      returning id into v_chapter_id;
    end if;

    update public.chapters
    set story_id = br.story_id,
        branch_id = br.branch_id,
        chapter_number = 1,
        title = 'Opening Signal · ' || br.branch_name,
        slug = 'opening-signal-' || br.branch_slug,
        summary = v_excerpt,
        is_published = v_is_published,
        published_at = case when v_is_published then coalesce(published_at, timezone('utc', now())) else null end,
        created_by = br.author_id,
        updated_at = timezone('utc', now())
    where id = v_chapter_id;

    select id into v_version_id
    from public.chapter_versions
    where chapter_id = v_chapter_id
      and version_number = 1
    order by created_at asc
    limit 1;

    if v_version_id is null then
      insert into public.chapter_versions (
        chapter_id, version_number, title, excerpt, content_md, source,
        commit_message, is_current, created_by
      )
      values (
        v_chapter_id,
        1,
        'Opening Signal · ' || br.branch_name,
        v_excerpt,
        v_body,
        'human',
        'Seed demo chapter for Sprint 6 simulation',
        true,
        br.author_id
      )
      returning id into v_version_id;
    end if;

    update public.chapter_versions
    set title = 'Opening Signal · ' || br.branch_name,
        excerpt = v_excerpt,
        content_md = v_body,
        source = 'human',
        commit_message = 'Seed demo chapter for Sprint 6 simulation',
        is_current = true
    where id = v_version_id;

    update public.chapter_versions
    set is_current = false
    where chapter_id = v_chapter_id
      and id <> v_version_id;
  end loop;
end $$;

-- 5) Follows, likes, public bookmarks. Uses NOT EXISTS because current schema has no unique constraints here.
do $$
declare
  f record;
  v_user_id uuid;
  v_story_id uuid;
  v_chapter_id uuid;
  v_version_id uuid;
  v_tag text;
begin
  for f in
    select * from (values
    ('demo_admin', 'river-that-remembers'),
    ('demo_admin', 'clockmakers-orchard'),
    ('demo_admin', 'neon-keris-protocol'),
    ('demo_admin', 'bazaar-edge-of-sleep'),
    ('lina_writer', 'lanterns-over-seri-bay'),
    ('lina_writer', 'orbit-of-the-last-musafir'),
    ('lina_writer', 'ashes-paper-kingdom'),
    ('lina_writer', 'atlas-rain-cities'),
    ('omar_forkcrafter', 'clockmakers-orchard'),
    ('omar_forkcrafter', 'glass-masjid-seven-moons'),
    ('omar_forkcrafter', 'child-borrowed-tomorrow'),
    ('omar_forkcrafter', 'thousand-door-school'),
    ('maya_reader', 'orbit-of-the-last-musafir'),
    ('maya_reader', 'neon-keris-protocol'),
    ('maya_reader', 'bazaar-edge-of-sleep'),
    ('maya_reader', 'garden-112th-star'),
    ('tariq_worldsmith', 'glass-masjid-seven-moons'),
    ('tariq_worldsmith', 'ashes-paper-kingdom'),
    ('tariq_worldsmith', 'atlas-rain-cities'),
    ('tariq_worldsmith', 'river-that-remembers'),
    ('sara_editor', 'neon-keris-protocol'),
    ('sara_editor', 'child-borrowed-tomorrow'),
    ('sara_editor', 'thousand-door-school'),
    ('sara_editor', 'lanterns-over-seri-bay'),
    ('aiman_arc', 'ashes-paper-kingdom'),
    ('aiman_arc', 'bazaar-edge-of-sleep'),
    ('aiman_arc', 'garden-112th-star'),
    ('aiman_arc', 'clockmakers-orchard'),
    ('nora_pathfinder', 'child-borrowed-tomorrow'),
    ('nora_pathfinder', 'atlas-rain-cities'),
    ('nora_pathfinder', 'river-that-remembers'),
    ('nora_pathfinder', 'orbit-of-the-last-musafir')
    ) as v(username, story_slug)
  loop
    select id into v_user_id from public.profiles where username = f.username;
    select id into v_story_id from public.stories where slug = f.story_slug;

    if v_user_id is not null and v_story_id is not null then
      if not exists (
        select 1 from public.follows
        where user_id = v_user_id
          and story_id = v_story_id
      ) then
        insert into public.follows (user_id, story_id)
        values (v_user_id, v_story_id);
      end if;
    end if;

    select c.id, cv.id
    into v_chapter_id, v_version_id
    from public.stories s
    join public.story_branches sb on sb.story_id = s.id
    join public.chapters c on c.branch_id = sb.id
    join public.chapter_versions cv on cv.chapter_id = c.id and cv.is_current = true
    where s.slug = f.story_slug
      and c.is_published = true
    order by case when sb.branch_type = 'main' then 0 else 1 end, sb.slug
    limit 1;

    if v_user_id is not null and v_chapter_id is not null and v_version_id is not null then
      if not exists (
        select 1 from public.likes
        where user_id = v_user_id
          and chapter_version_id = v_version_id
      ) then
        insert into public.likes (user_id, chapter_version_id)
        values (v_user_id, v_version_id);
      end if;

      v_tag := case
        when f.story_slug like '%river%' then 'memory'
        when f.story_slug like '%neon%' then 'action'
        when f.story_slug like '%school%' then 'forkcraft'
        when f.story_slug like '%garden%' then 'flagship'
        else 'waypoint'
      end;

      if not exists (
        select 1 from public.bookmarks
        where user_id = v_user_id
          and chapter_id = v_chapter_id
          and tag = v_tag
      ) then
        insert into public.bookmarks (user_id, chapter_id, tag, is_public)
        values (v_user_id, v_chapter_id, v_tag, true);
      end if;
    end if;
  end loop;
end $$;

-- 6) Lightweight comments for activity feed and chapter discussion testing.
do $$
declare
  cm record;
  v_user_id uuid;
  v_story_id uuid;
  v_chapter_id uuid;
begin
  for cm in
    select * from (values
    ('maya_reader', 'river-that-remembers', 'This opening feels like a memory I want to fork later.', false),
    ('omar_forkcrafter', 'river-that-remembers', 'The branch point is clear. Good starter Forkcraft sample.', false),
    ('lina_writer', 'lanterns-over-seri-bay', 'I like how the lantern choice can become three timelines.', false),
    ('nora_pathfinder', 'clockmakers-orchard', 'Bookmarking this because the orchard-year idea is strong.', false),
    ('demo_admin', 'orbit-of-the-last-musafir', 'Useful for testing public discovery and spiritual sci-fi tagging.', false),
    ('sara_editor', 'glass-masjid-seven-moons', 'This one should demonstrate reflective pacing in the reader page.', false),
    ('aiman_arc', 'neon-keris-protocol', 'Fast action path. Great for testing fork counts later.', false),
    ('tariq_worldsmith', 'ashes-paper-kingdom', 'Closed canon visibility works nicely for governance testing.', true),
    ('maya_reader', 'bazaar-edge-of-sleep', 'The dream market has many possible reader loops.', false),
    ('lina_writer', 'atlas-rain-cities', 'Unlisted worldbook is a good direct-link test.', false),
    ('omar_forkcrafter', 'thousand-door-school', 'Community Forkcraft should start from this school door.', false),
    ('nora_pathfinder', 'garden-112th-star', 'Flagship multiverse sample. The 112th star theme fits the seed.', false)
    ) as v(username, story_slug, body, is_spoiler)
  loop
    select id into v_user_id from public.profiles where username = cm.username;
    select id into v_story_id from public.stories where slug = cm.story_slug;

    select c.id into v_chapter_id
    from public.chapters c
    join public.story_branches sb on sb.id = c.branch_id
    where c.story_id = v_story_id
      and c.is_published = true
    order by case when sb.branch_type = 'main' then 0 else 1 end, sb.slug
    limit 1;

    if v_user_id is not null and v_story_id is not null and v_chapter_id is not null then
      if not exists (
        select 1 from public.comments
        where user_id = v_user_id
          and story_id = v_story_id
          and chapter_id = v_chapter_id
          and body = cm.body
      ) then
        insert into public.comments (chapter_id, story_id, user_id, body, is_spoiler)
        values (v_chapter_id, v_story_id, v_user_id, cm.body, cm.is_spoiler);
      end if;
    end if;
  end loop;
end $$;

-- 7) Completion notice.
do $$
declare
  v_user_count integer;
  v_story_count integer;
  v_branch_count integer;
  v_chapter_count integer;
  v_version_count integer;
  v_comment_count integer;
begin
  select count(*) into v_user_count
  from public.profiles
  where username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder');

  select count(*) into v_story_count
  from public.stories
  where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

  select count(*) into v_branch_count
  from public.story_branches sb
  join public.stories s on s.id = sb.story_id
  where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

  select count(*) into v_chapter_count
  from public.chapters c
  join public.stories s on s.id = c.story_id
  where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

  select count(*) into v_version_count
  from public.chapter_versions cv
  join public.chapters c on c.id = cv.chapter_id
  join public.stories s on s.id = c.story_id
  where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
    and cv.is_current = true;

  select count(*) into v_comment_count
  from public.comments cm
  join public.stories s on s.id = cm.story_id
  where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

  raise notice 'Narrio demo seed complete: % demo users, % stories, % branches/timelines, % chapters, % current versions, % comments.',
    v_user_count, v_story_count, v_branch_count, v_chapter_count, v_version_count, v_comment_count;
end $$;
