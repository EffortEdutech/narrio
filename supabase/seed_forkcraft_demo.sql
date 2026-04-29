-- Narrio Demo Seed HOTFIX 2: 12 stories, 112 universe/timeline varieties, 8 demo users
-- HOTFIX 2: Uses persistent public staging tables instead of temporary tables for Supabase Studio reliability.
-- Password for all demo users: test123
-- Safe for local/dev only. Do not run this file on production.

create extension if not exists "pgcrypto";

drop table if exists public._narrio_seed_users;
create table public._narrio_seed_users (
  id uuid primary key,
  email text not null,
  username text not null,
  display_name text not null,
  bio text not null
);

insert into public._narrio_seed_users (id, email, username, display_name, bio)
values
    ('00000000-0000-4000-8000-000000000101'::uuid, 'demo.admin@narrio.test', 'demo_admin', 'Demo Admin', 'Platform steward for testing launch readiness and public discovery.'),
    ('00000000-0000-4000-8000-000000000102'::uuid, 'lina.writer@narrio.test', 'lina_writer', 'Lina Writer', 'Writes memory rivers, quiet fantasy, and first-person canon paths.'),
    ('00000000-0000-4000-8000-000000000103'::uuid, 'omar.forkcrafter@narrio.test', 'omar_forkcrafter', 'Omar Forkcrafter', 'Builds bold forks, action branches, and reader-choice timelines.'),
    ('00000000-0000-4000-8000-000000000104'::uuid, 'maya.reader@narrio.test', 'maya_reader', 'Maya Reader', 'Reads everything, bookmarks turning points, and follows public universes.'),
    ('00000000-0000-4000-8000-000000000105'::uuid, 'tariq.worldsmith@narrio.test', 'tariq_worldsmith', 'Tariq Worldsmith', 'Designs lore-heavy worlds and experimental map-like story branches.'),
    ('00000000-0000-4000-8000-000000000106'::uuid, 'sara.editor@narrio.test', 'sara_editor', 'Sara Editor', 'Tests publishing flow, closed canon, and polished chapter releases.'),
    ('00000000-0000-4000-8000-000000000107'::uuid, 'aiman.arc@narrio.test', 'aiman_arc', 'Aiman Arc', 'Explores time loops, parallel endings, and long-form community forks.'),
    ('00000000-0000-4000-8000-000000000108'::uuid, 'nora.pathfinder@narrio.test', 'nora_pathfinder', 'Nora Pathfinder', 'Finds hidden timelines and leaves waypoints for future readers.');

do $$
declare
  u record;
begin
  for u in select * from public._narrio_seed_users loop
    insert into auth.users (
      id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, recovery_token, email_change_token_new, email_change
    )
    values (
      u.id, '00000000-0000-0000-0000-000000000000'::uuid,
      'authenticated', 'authenticated', u.email,
      crypt('test123', gen_salt('bf')),
      timezone('utc', now()),
      '{"provider":"email","providers":["email"]}'::jsonb,
      jsonb_build_object('username', u.username, 'display_name', u.display_name),
      timezone('utc', now()), timezone('utc', now()), '', '', '', ''
    )
    on conflict (id) do update
    set email = excluded.email,
        encrypted_password = excluded.encrypted_password,
        email_confirmed_at = excluded.email_confirmed_at,
        raw_app_meta_data = excluded.raw_app_meta_data,
        raw_user_meta_data = excluded.raw_user_meta_data,
        updated_at = timezone('utc', now());

    delete from auth.identities where user_id = u.id and provider = 'email';

    if exists (
      select 1 from information_schema.columns
      where table_schema = 'auth' and table_name = 'identities' and column_name = 'provider_id'
    ) then
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider, provider_id,
          last_sign_in_at, created_at, updated_at
        ) values ($1, $2, $3, $4, $5, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email', u.email;
    else
      execute '
        insert into auth.identities (
          id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
        ) values ($1, $2, $3, $4, timezone(''utc'', now()), timezone(''utc'', now()), timezone(''utc'', now()))'
      using u.id, u.id,
            jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
            'email';
    end if;
  end loop;
end $$;

insert into public.profiles (id, username, display_name, bio, avatar_url)
select id, username, display_name, bio,
       'https://api.dicebear.com/9.x/bottts-neutral/svg?seed=' || username
from public._narrio_seed_users
on conflict (id) do update
set username = excluded.username,
    display_name = excluded.display_name,
    bio = excluded.bio,
    avatar_url = excluded.avatar_url,
    updated_at = timezone('utc', now());

drop table if exists public._narrio_seed_stories;
create table public._narrio_seed_stories (
  slug text primary key,
  title text not null,
  author_username text not null,
  level_label text not null,
  genre text not null,
  expected_universes integer not null,
  status text not null,
  visibility text not null,
  synopsis text not null,
  cover_url text,
  allow_forks boolean not null
);

insert into public._narrio_seed_stories (
  slug, title, author_username, level_label, genre, expected_universes,
  status, visibility, synopsis, cover_url, allow_forks
)
values
    ('river-that-remembers', 'The River That Remembers', 'lina_writer', 'Level 1 · Starter Canon', 'Memory Fantasy', 3, 'published', 'public', 'A river town remembers every choice its people tried to forget. A gentle starter universe with a few clear ForkCraft paths.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+River+That+Remembers', true),
    ('lanterns-over-seri-bay', 'Lanterns Over Seri Bay', 'omar_forkcrafter', 'Level 2 · Reader Choice Mystery', 'Coastal Mystery', 5, 'published', 'public', 'Every lantern released over Seri Bay carries a secret route home. A compact mystery with reader-friendly timeline forks.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Lanterns+Over+Seri+Bay', true),
    ('clockmakers-orchard', 'The Clockmaker''s Orchard', 'sara_editor', 'Level 3 · Growing World', 'Clockwork Fable', 6, 'published', 'public', 'An orchard grows clocks instead of fruit, and every harvest opens a different year. A growing world with stable canon and side paths.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Clockmakers+Orchard', true),
    ('orbit-of-the-last-musafir', 'Orbit of the Last Musafir', 'aiman_arc', 'Level 4 · Sci-Fi Pilgrimage', 'Spiritual Sci-Fi', 7, 'published', 'public', 'A lone traveller circles a broken moon, seeking the qiblah of a lost generation ship. A mid-level universe for alternate journeys.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Orbit+of+the+Last+Musafir', true),
    ('glass-masjid-seven-moons', 'The Glass Masjid of Seven Moons', 'lina_writer', 'Level 5 · Reflective Epic', 'Reflective Fantasy', 8, 'published', 'public', 'Seven moons shine through a glass masjid, each revealing a different prayer, test, and timeline.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Glass+Masjid+of+Seven+Moons', true),
    ('neon-keris-protocol', 'Neon Keris Protocol', 'omar_forkcrafter', 'Level 6 · Action ForkCraft', 'Cyber Nusantara', 9, 'published', 'public', 'A cyber-Melayu city hides an ancient keris protocol inside its surveillance grid. Built for fast, high-energy forks.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Neon+Keris+Protocol', true),
    ('ashes-paper-kingdom', 'Ashes of the Paper Kingdom', 'sara_editor', 'Level 7 · Closed Canon Showcase', 'Political Fable', 10, 'published', 'public', 'A kingdom writes its laws on paper that burns when leaders lie. Official alternate timelines exist, but public ForkCraft is closed.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Ashes+of+the+Paper+Kingdom', false),
    ('child-borrowed-tomorrow', 'The Child Who Borrowed Tomorrow', 'aiman_arc', 'Level 8 · Private Draft Lab', 'Time Loop', 11, 'draft', 'private', 'A child borrows one day from the future and must return it with interest. Kept private to test draft and visibility gates.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Child+Who+Borrowed+Tomorrow', true),
    ('bazaar-edge-of-sleep', 'Bazaar at the Edge of Sleep', 'tariq_worldsmith', 'Level 9 · Dream Market', 'Dream Bazaar', 12, 'published', 'public', 'At the edge of sleep, traders sell memories, unfinished dreams, and alternate endings.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Bazaar+at+the+Edge+of+Sleep', true),
    ('atlas-rain-cities', 'Atlas of Rain-Cities', 'tariq_worldsmith', 'Level 10 · Unlisted Worldbook', 'Worldbuilding Travelogue', 13, 'published', 'unlisted', 'A cartographer maps cities where rain changes language, law, and destiny. Unlisted for direct-link testing.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Atlas+of+Rain-Cities', true),
    ('thousand-door-school', 'The Thousand Door School', 'nora_pathfinder', 'Level 11 · Community ForkCraft', 'Academy Multiverse', 14, 'published', 'public', 'A school with one thousand doors teaches students to enter consequences before opening choices.', 'https://placehold.co/1200x720/111827/F8E7B9?text=The+Thousand+Door+School', true),
    ('garden-112th-star', 'Garden of the 112th Star', 'demo_admin', 'Level 12 · Flagship Multiverse', 'Flagship Cosmic Fantasy', 14, 'published', 'public', 'A cosmic garden grows around the 112th star, where every petal is a possible universe.', 'https://placehold.co/1200x720/111827/F8E7B9?text=Garden+of+the+112th+Star', true);

do $$
declare
  s record;
  v_author_id uuid;
  v_story_id uuid;
  v_main_branch_id uuid;
begin
  for s in select * from public._narrio_seed_stories loop
    select id into v_author_id from public.profiles where username = s.author_username;

    insert into public.stories (
      author_id, forked_from_story_id, title, slug, synopsis, cover_url,
      status, visibility, allow_forks
    )
    values (
      v_author_id, null, s.title, s.slug,
      '[' || s.level_label || '] [' || s.genre || '] ' || s.synopsis,
      s.cover_url, s.status, s.visibility, s.allow_forks
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
    returning id, main_branch_id into v_story_id, v_main_branch_id;

    if v_main_branch_id is null then
      select main_branch_id into v_main_branch_id from public.stories where id = v_story_id;
    end if;

    update public.story_branches
    set name = 'Main Canon · ' || s.level_label,
        description = 'Primary canon timeline for ' || s.title || '. Seeded as universe 001 for this story level.',
        branch_type = 'main',
        status = 'active',
        visibility = s.visibility,
        updated_at = timezone('utc', now())
    where id = v_main_branch_id;
  end loop;
end $$;

drop table if exists public._narrio_seed_branches;
create table public._narrio_seed_branches (
  story_slug text not null,
  name text not null,
  slug text not null,
  description text not null,
  branch_type text not null,
  visibility text not null
);

insert into public._narrio_seed_branches (story_slug, name, slug, description, branch_type, visibility)
values
    ('river-that-remembers', 'Universe 001 · Moonlit Canon', 'u001-moonlit-canon', 'Moonlit Canon variation for The River That Remembers. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('river-that-remembers', 'Universe 002 · Storm Door', 'u002-storm-door', 'Storm Door variation for The River That Remembers. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('lanterns-over-seri-bay', 'Universe 003 · Quiet Market', 'u003-quiet-market', 'Quiet Market variation for Lanterns Over Seri Bay. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('lanterns-over-seri-bay', 'Universe 004 · Broken Compass', 'u004-broken-compass', 'Broken Compass variation for Lanterns Over Seri Bay. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('lanterns-over-seri-bay', 'Universe 005 · Hidden Heir', 'u005-hidden-heir', 'Hidden Heir variation for Lanterns Over Seri Bay. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('lanterns-over-seri-bay', 'Universe 006 · Silver Rain', 'u006-silver-rain', 'Silver Rain variation for Lanterns Over Seri Bay. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('clockmakers-orchard', 'Universe 007 · Ash Lantern', 'u007-ash-lantern', 'Ash Lantern variation for The Clockmaker''s Orchard. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('clockmakers-orchard', 'Universe 008 · Mirror Road', 'u008-mirror-road', 'Mirror Road variation for The Clockmaker''s Orchard. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('clockmakers-orchard', 'Universe 009 · Forgotten Library', 'u009-forgotten-library', 'Forgotten Library variation for The Clockmaker''s Orchard. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('clockmakers-orchard', 'Universe 010 · Tiger Gate', 'u010-tiger-gate', 'Tiger Gate variation for The Clockmaker''s Orchard. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('clockmakers-orchard', 'Universe 011 · Clock Rain', 'u011-clock-rain', 'Clock Rain variation for The Clockmaker''s Orchard. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 012 · Saffron Dawn', 'u012-saffron-dawn', 'Saffron Dawn variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 013 · Blue Minaret', 'u013-blue-minaret', 'Blue Minaret variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 014 · Neon Wadi', 'u014-neon-wadi', 'Neon Wadi variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 015 · Paper Crown', 'u015-paper-crown', 'Paper Crown variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 016 · Star Orchard', 'u016-star-orchard', 'Star Orchard variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('orbit-of-the-last-musafir', 'Universe 017 · Black Kite', 'u017-black-kite', 'Black Kite variation for Orbit of the Last Musafir. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('glass-masjid-seven-moons', 'Universe 018 · Jasmine Signal', 'u018-jasmine-signal', 'Jasmine Signal variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('glass-masjid-seven-moons', 'Universe 019 · Glass River', 'u019-glass-river', 'Glass River variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('glass-masjid-seven-moons', 'Universe 020 · Copper Moon', 'u020-copper-moon', 'Copper Moon variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('glass-masjid-seven-moons', 'Universe 021 · Whisper Bazaar', 'u021-whisper-bazaar', 'Whisper Bazaar variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('glass-masjid-seven-moons', 'Universe 022 · Cloud Caravan', 'u022-cloud-caravan', 'Cloud Caravan variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('glass-masjid-seven-moons', 'Universe 023 · Final Ferry', 'u023-final-ferry', 'Final Ferry variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('glass-masjid-seven-moons', 'Universe 024 · Midnight Archive', 'u024-midnight-archive', 'Midnight Archive variation for The Glass Masjid of Seven Moons. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 025 · Garden Gate', 'u025-garden-gate', 'Garden Gate variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('neon-keris-protocol', 'Universe 026 · Old Radio', 'u026-old-radio', 'Old Radio variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('neon-keris-protocol', 'Universe 027 · Flooded School', 'u027-flooded-school', 'Flooded School variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 028 · Coral Bridge', 'u028-coral-bridge', 'Coral Bridge variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('neon-keris-protocol', 'Universe 029 · Ember Treaty', 'u029-ember-treaty', 'Ember Treaty variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('neon-keris-protocol', 'Universe 030 · Twin Eclipse', 'u030-twin-eclipse', 'Twin Eclipse variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('neon-keris-protocol', 'Universe 031 · Shadow Script', 'u031-shadow-script', 'Shadow Script variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('neon-keris-protocol', 'Universe 032 · Lunar Court', 'u032-lunar-court', 'Lunar Court variation for Neon Keris Protocol. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('ashes-paper-kingdom', 'Universe 033 · Borrowed Map', 'u033-borrowed-map', 'Borrowed Map variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 034 · Velvet Storm', 'u034-velvet-storm', 'Velvet Storm variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 035 · Wandering Imam', 'u035-wandering-imam', 'Wandering Imam variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 036 · Electric Monsoon', 'u036-electric-monsoon', 'Electric Monsoon variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 037 · Tin Soldier', 'u037-tin-soldier', 'Tin Soldier variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 038 · Rose Labyrinth', 'u038-rose-labyrinth', 'Rose Labyrinth variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 039 · Salt Kingdom', 'u039-salt-kingdom', 'Salt Kingdom variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('ashes-paper-kingdom', 'Universe 040 · Ivory Engine', 'u040-ivory-engine', 'Ivory Engine variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('ashes-paper-kingdom', 'Universe 041 · Fisherman Star', 'u041-fisherman-star', 'Fisherman Star variation for Ashes of the Paper Kingdom. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('child-borrowed-tomorrow', 'Universe 042 · Keris Circuit', 'u042-keris-circuit', 'Keris Circuit variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 043 · Rain Parliament', 'u043-rain-parliament', 'Rain Parliament variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 044 · Hollow Mountain', 'u044-hollow-mountain', 'Hollow Mountain variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 045 · Honey Clock', 'u045-honey-clock', 'Honey Clock variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 046 · Seven Keys', 'u046-seven-keys', 'Seven Keys variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 047 · Parrot Oracle', 'u047-parrot-oracle', 'Parrot Oracle variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 048 · Silent Train', 'u048-silent-train', 'Silent Train variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'private'),
    ('child-borrowed-tomorrow', 'Universe 049 · Broken Prayer Beads', 'u049-broken-prayer-beads', 'Broken Prayer Beads variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'private'),
    ('child-borrowed-tomorrow', 'Universe 050 · Firefly Accord', 'u050-firefly-accord', 'Firefly Accord variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'private'),
    ('child-borrowed-tomorrow', 'Universe 051 · Green Comet', 'u051-green-comet', 'Green Comet variation for The Child Who Borrowed Tomorrow. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'private'),
    ('bazaar-edge-of-sleep', 'Universe 052 · Lotus Station', 'u052-lotus-station', 'Lotus Station variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 053 · Rooftop Madrasa', 'u053-rooftop-madrasa', 'Rooftop Madrasa variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 054 · Sleeping Harbour', 'u054-sleeping-harbour', 'Sleeping Harbour variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 055 · Dust Palace', 'u055-dust-palace', 'Dust Palace variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 056 · Child of Noon', 'u056-child-of-noon', 'Child of Noon variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 057 · Tide Library', 'u057-tide-library', 'Tide Library variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 058 · Phoenix Ferry', 'u058-phoenix-ferry', 'Phoenix Ferry variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 059 · Mask Festival', 'u059-mask-festival', 'Mask Festival variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 060 · Amber Treaty', 'u060-amber-treaty', 'Amber Treaty variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 061 · River of Names', 'u061-river-of-names', 'River of Names variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('bazaar-edge-of-sleep', 'Universe 062 · Thunder Market', 'u062-thunder-market', 'Thunder Market variation for Bazaar at the Edge of Sleep. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('atlas-rain-cities', 'Universe 063 · Lantern Queen', 'u063-lantern-queen', 'Lantern Queen variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 064 · Clockless Tower', 'u064-clockless-tower', 'Clockless Tower variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 065 · Bird Parliament', 'u065-bird-parliament', 'Bird Parliament variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 066 · Hidden Qiblah', 'u066-hidden-qiblah', 'Hidden Qiblah variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 067 · Neon Kampung', 'u067-neon-kampung', 'Neon Kampung variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 068 · Floating Court', 'u068-floating-court', 'Floating Court variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 069 · Chalk Galaxy', 'u069-chalk-galaxy', 'Chalk Galaxy variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 070 · Sea of Ink', 'u070-sea-of-ink', 'Sea of Ink variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 071 · Paper Boat', 'u071-paper-boat', 'Paper Boat variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'unlisted'),
    ('atlas-rain-cities', 'Universe 072 · Secret Orchard', 'u072-secret-orchard', 'Secret Orchard variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'unlisted'),
    ('atlas-rain-cities', 'Universe 073 · The Third Door', 'u073-the-third-door', 'The Third Door variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'unlisted'),
    ('atlas-rain-cities', 'Universe 074 · Echo Mosque', 'u074-echo-mosque', 'Echo Mosque variation for Atlas of Rain-Cities. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'unlisted'),
    ('thousand-door-school', 'Universe 075 · Monsoon Archive', 'u075-monsoon-archive', 'Monsoon Archive variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 076 · Wounded Moon', 'u076-wounded-moon', 'Wounded Moon variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 077 · Crescent Engine', 'u077-crescent-engine', 'Crescent Engine variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 078 · Dragonfly Map', 'u078-dragonfly-map', 'Dragonfly Map variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 079 · Silver School', 'u079-silver-school', 'Silver School variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 080 · Rainbone Bridge', 'u080-rainbone-bridge', 'Rainbone Bridge variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 081 · Old King Road', 'u081-old-king-road', 'Old King Road variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 082 · Glass Umbrella', 'u082-glass-umbrella', 'Glass Umbrella variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 083 · Fever Garden', 'u083-fever-garden', 'Fever Garden variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 084 · Mirror Sultan', 'u084-mirror-sultan', 'Mirror Sultan variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('thousand-door-school', 'Universe 085 · Star Jasmine', 'u085-star-jasmine', 'Star Jasmine variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('thousand-door-school', 'Universe 086 · Kite Harbour', 'u086-kite-harbour', 'Kite Harbour variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('thousand-door-school', 'Universe 087 · Pearl Circuit', 'u087-pearl-circuit', 'Pearl Circuit variation for The Thousand Door School. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 088 · Dusk Treaty', 'u088-dusk-treaty', 'Dusk Treaty variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 089 · Clockwork Date Palm', 'u089-clockwork-date-palm', 'Clockwork Date Palm variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 090 · Thousand Steps', 'u090-thousand-steps', 'Thousand Steps variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 091 · Goldfish Moon', 'u091-goldfish-moon', 'Goldfish Moon variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 092 · Unwritten Exam', 'u092-unwritten-exam', 'Unwritten Exam variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 093 · Mango Eclipse', 'u093-mango-eclipse', 'Mango Eclipse variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 094 · Wayfarer Code', 'u094-wayfarer-code', 'Wayfarer Code variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 095 · Singing Well', 'u095-singing-well', 'Singing Well variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 096 · Cobalt Orchard', 'u096-cobalt-orchard', 'Cobalt Orchard variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 097 · Sleep Gate', 'u097-sleep-gate', 'Sleep Gate variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public'),
    ('garden-112th-star', 'Universe 098 · Ivory Monsoon', 'u098-ivory-monsoon', 'Ivory Monsoon variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'fork', 'public'),
    ('garden-112th-star', 'Universe 099 · Hijrah Star', 'u099-hijrah-star', 'Hijrah Star variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'alternate', 'public'),
    ('garden-112th-star', 'Universe 100 · Empty Throne', 'u100-empty-throne', 'Empty Throne variation for Garden of the 112th Star. This path is seeded to simulate ForkCraft discovery, timeline comparison, and alternate reader journeys.', 'experimental', 'public');

do $$
declare
  b record;
  v_story_id uuid;
  v_parent_branch_id uuid;
  v_author_id uuid;
begin
  for b in select * from public._narrio_seed_branches loop
    select id, main_branch_id, author_id
    into v_story_id, v_parent_branch_id, v_author_id
    from public.stories
    where slug = b.story_slug;

    insert into public.story_branches (
      story_id, parent_branch_id, created_by, name, slug, description,
      branch_type, status, visibility
    )
    values (
      v_story_id, v_parent_branch_id, v_author_id, b.name, b.slug, b.description,
      b.branch_type, 'active', b.visibility
    )
    on conflict (story_id, slug) do update
    set parent_branch_id = excluded.parent_branch_id,
        created_by = excluded.created_by,
        name = excluded.name,
        description = excluded.description,
        branch_type = excluded.branch_type,
        status = excluded.status,
        visibility = excluded.visibility,
        updated_at = timezone('utc', now());
  end loop;
end $$;

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
      s.id as story_id, s.slug as story_slug, s.title as story_title,
      s.status as story_status, s.visibility as story_visibility, s.allow_forks, s.author_id,
      sb.id as branch_id, sb.slug as branch_slug, sb.name as branch_name,
      sb.branch_type, sb.visibility as branch_visibility
    from public.stories s
    join public.story_branches sb on sb.story_id = s.id
    where s.slug in (select slug from public._narrio_seed_stories)
    order by s.slug, sb.slug
  loop
    v_is_published := br.story_status = 'published'
      and br.story_visibility in ('public', 'unlisted')
      and br.branch_visibility in ('public', 'unlisted');

    v_excerpt := 'A seeded opening signal for ' || br.branch_name || ' in ' || br.story_title || '.';
    v_body := '# ' || br.branch_name || E'\n\n'
      || 'This is a demo chapter generated for Narrio simulation. It belongs to **' || br.story_title || '** and represents the **' || br.branch_name || '** universe path.' || E'\n\n'
      || 'The reader reaches a fork point where the canon can continue, bend, or become a new path. This seeded text is intentionally short so the platform can demonstrate publishing, discovery, timeline exploration, bookmarks, likes, follows, and ForkCraft branches without overwhelming the test environment.' || E'\n\n'
      || '**ForkCraft prompt:** What would change if this universe chose courage before certainty?';

    insert into public.chapters (
      story_id, branch_id, chapter_number, title, slug, summary,
      is_published, published_at, created_by
    )
    values (
      br.story_id, br.branch_id, 1,
      'Opening Signal · ' || br.branch_name,
      'opening-signal-' || br.branch_slug,
      v_excerpt,
      v_is_published,
      case when v_is_published then timezone('utc', now()) else null end,
      br.author_id
    )
    on conflict (branch_id, chapter_number) do update
    set title = excluded.title,
        slug = excluded.slug,
        summary = excluded.summary,
        is_published = excluded.is_published,
        published_at = excluded.published_at,
        created_by = excluded.created_by,
        updated_at = timezone('utc', now())
    returning id into v_chapter_id;

    insert into public.chapter_versions (
      chapter_id, version_number, title, excerpt, content_md, source,
      commit_message, is_current, created_by
    )
    values (
      v_chapter_id, 1,
      'Opening Signal · ' || br.branch_name,
      v_excerpt, v_body, 'human',
      'Seed demo chapter for Sprint 6 simulation',
      true, br.author_id
    )
    on conflict (chapter_id, version_number) do update
    set title = excluded.title,
        excerpt = excluded.excerpt,
        content_md = excluded.content_md,
        source = excluded.source,
        commit_message = excluded.commit_message,
        is_current = excluded.is_current
    returning id into v_version_id;

    update public.chapter_versions
    set is_current = false
    where chapter_id = v_chapter_id
      and id <> v_version_id;
  end loop;
end $$;

drop table if exists public._narrio_seed_follows;
create table public._narrio_seed_follows (
  username text not null,
  story_slug text not null
);

insert into public._narrio_seed_follows (username, story_slug)
values
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
    ('nora_pathfinder', 'orbit-of-the-last-musafir');

insert into public.follows (user_id, story_id)
select p.id, s.id
from public._narrio_seed_follows f
join public.profiles p on p.username = f.username
join public.stories s on s.slug = f.story_slug
where s.status = 'published'
on conflict (user_id, story_id) do nothing;

do $$
declare
  r record;
  v_user_id uuid;
  v_chapter_id uuid;
  v_version_id uuid;
  v_tag text;
begin
  for r in select f.username, f.story_slug from public._narrio_seed_follows f loop
    select id into v_user_id from public.profiles where username = r.username;

    select c.id, cv.id
    into v_chapter_id, v_version_id
    from public.stories s
    join public.story_branches sb on sb.story_id = s.id
    join public.chapters c on c.branch_id = sb.id
    join public.chapter_versions cv on cv.chapter_id = c.id and cv.is_current = true
    where s.slug = r.story_slug
      and s.status = 'published'
      and c.is_published = true
    order by case when sb.slug = 'main' then 0 else 1 end, sb.slug
    limit 1;

    if v_chapter_id is not null then
      insert into public.likes (user_id, chapter_version_id)
      values (v_user_id, v_version_id)
      on conflict (user_id, chapter_version_id) do nothing;

      v_tag := case
        when r.story_slug like '%river%' then 'memory'
        when r.story_slug like '%neon%' then 'action'
        when r.story_slug like '%school%' then 'forkcraft'
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

do $$
declare
  v_story_count integer;
  v_branch_count integer;
  v_chapter_count integer;
  v_user_count integer;
begin
  select count(*) into v_user_count from public.profiles
  where username in (select username from public._narrio_seed_users);

  select count(*) into v_story_count from public.stories
  where slug in (select slug from public._narrio_seed_stories);

  select count(*) into v_branch_count
  from public.story_branches sb
  join public.stories s on s.id = sb.story_id
  where s.slug in (select slug from public._narrio_seed_stories);

  select count(*) into v_chapter_count
  from public.chapters c
  join public.stories s on s.id = c.story_id
  where s.slug in (select slug from public._narrio_seed_stories);

  raise notice 'Narrio demo seed complete: % users, % stories, % universe/timeline branches, % chapters.',
    v_user_count, v_story_count, v_branch_count, v_chapter_count;
end $$;

-- Clean up seed staging tables after successful run.
drop table if exists public._narrio_seed_follows;
drop table if exists public._narrio_seed_branches;
drop table if exists public._narrio_seed_stories;
drop table if exists public._narrio_seed_users;
