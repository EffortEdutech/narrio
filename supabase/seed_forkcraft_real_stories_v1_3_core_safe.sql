-- Narrio Real Story Seed Pack v1.3 - core-safe schema-locked seed
-- Creates: 8 demo login users, 12 stories, 112 timeline/universe branches, 112 chapters, 112 current chapter versions.
-- Password for all users: test123
-- Local/dev only. Do not run on production.

begin;

create extension if not exists "pgcrypto";

-- 0) Clean previous Narrio demo story graph by known story slugs.
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
    select chapter_item.id
    from public.chapters chapter_item
    join public.stories story_item on story_item.id = chapter_item.story_id
    where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  );

  delete from public.likes
  where chapter_version_id in (
    select current_version.id
    from public.chapter_versions current_version
    join public.chapters chapter_item on chapter_item.id = current_version.chapter_id
    join public.stories story_item on story_item.id = chapter_item.story_id
    where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  );

  delete from public.follows
  where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

  delete from public.chapter_versions
  where chapter_id in (
    select chapter_item.id
    from public.chapters chapter_item
    join public.stories story_item on story_item.id = chapter_item.story_id
    where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
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
    ) as demo_user(id, email, username, display_name, bio)
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

    insert into public.profiles (id, username, display_name, bio, avatar_url, updated_at)
    values (u.id, u.username, u.display_name, u.bio, null, timezone('utc', now()))
    on conflict (id) do update
    set username = excluded.username,
        display_name = excluded.display_name,
        bio = excluded.bio,
        avatar_url = excluded.avatar_url,
        updated_at = timezone('utc', now());
  end loop;
end
$users$;

-- 2) Stories, timelines/universes, chapters, and real prose.
do $real_stories$
declare
  st record;
  v_story_id uuid;
  v_author_id uuid;
  v_branch_id uuid;
  v_main_branch_id uuid;
  v_main_version_id uuid;
  v_chapter_id uuid;
  v_version_id uuid;
  v_branch_count integer;
  v_branch_index integer;
  v_universe_no integer := 0;
  v_motifs text[] := array['Borrowed Map', 'Silver Rain', 'Door Under Water', 'Moon with No Shadow', 'Child of Salt', 'Black Kite', 'Lantern Debt', 'Clock of Bees', 'Red Stair', 'Mirror Bridge', 'Silent Reef', 'Folded Crown', 'Storm Page', 'Glass Bird', 'Last Radio', 'Market of Names', 'Forgotten Bell', 'Blue Thread', 'River Oath', 'Paper Crown', 'Secret Orchard', 'Neon Monsoon', 'Compass of Ash', 'Seed of Mercy', 'Door 404', 'Seven Moon Reflection', 'Atlas Key', 'Dream Coin'];
  v_consequences text[] := array['a friend becomes the first witness', 'the safest road asks for a price', 'a hidden enemy chooses mercy', 'the map refuses to show home', 'the old promise wakes up hungry', 'a child remembers the wrong future', 'the city changes its name overnight', 'the mentor admits the first lie', 'the missing door opens from inside', 'the river carries a voice upstream', 'the stars rearrange their witnesses', 'the market sells back an old mistake'];
  v_senses text[] := array['rain on zinc', 'salt and lamp oil', 'burnt sugar', 'wet paper', 'old brass', 'monsoon dust', 'jasmine smoke', 'warm circuitry', 'river mud', 'storm leather', 'chalk sunlight', 'cold moon glass'];
  v_motif text;
  v_consequence text;
  v_sense text;
  v_branch_slug text;
  v_branch_name text;
  v_branch_type text;
  v_branch_visibility text;
  v_chapter_title text;
  v_summary text;
  v_excerpt text;
  v_content text;
  v_is_published boolean;
begin
  for st in
    select * from (values
    (1, 'river-that-remembers', 'The River That Remembers', 'lina_writer', 'quiet fantasy', 'Level 1 - Canon Path', 'published', 'public', true, 'Nur Aina', 'Kampung Seraga jetty', 'a brass river compass', 'the river returned a childhood voice that should have been buried', 'Mak Teh Suri', 'follow the voice downstream', 'burn the map and protect the village', 'the current carried a lantern against the tide'),
    (2, 'lanterns-over-seri-bay', 'Lanterns over Seri Bay', 'lina_writer', 'coastal mystery', 'Level 2 - Reader Forks', 'published', 'public', true, 'Hana Rahim', 'Seri Bay lighthouse market', 'a lantern with blue fire', 'every boat bell rang at the wrong hour', 'Old Captain Ilyas', 'sail toward the silent reef', 'hide the lantern beneath the mosque steps', 'twelve lanterns rose without hands'),
    (3, 'clockmakers-orchard', 'The Clockmakers Orchard', 'tariq_worldsmith', 'time orchard fantasy', 'Level 3 - Branching Lore', 'published', 'public', true, 'Idris Vale', 'an orchard where every fruit kept a different minute', 'a clockwork pear', 'the oldest tree dropped a fruit from tomorrow', 'Madam Renata', 'bite the future fruit', 'bury it under the present tree', 'bees ticked inside the afternoon'),
    (4, 'orbit-of-the-last-musafir', 'Orbit of the Last Musafir', 'aiman_arc', 'soft science fiction', 'Level 4 - Parallel Routes', 'published', 'public', true, 'Safwan Qamar', 'the prayer deck of a drifting orbital caravan', 'a cracked astrolabe chip', 'Earth vanished from the navigation window', 'Commander Nura', 'trust the impossible qiblah marker', 'turn the caravan toward the last radio call', 'stars folded like a prayer mat'),
    (5, 'glass-masjid-seven-moons', 'The Glass Masjid of Seven Moons', 'sara_editor', 'mythic architecture', 'Level 5 - Polished Public', 'published', 'public', true, 'Maryam Binte Noor', 'a transparent masjid standing between seven moons', 'a shard of moon glass', 'the mihrab reflected a city no one remembered', 'Imam Farid', 'step through the reflected city', 'seal the glass before dawn', 'each moon answered with a different shadow'),
    (6, 'neon-keris-protocol', 'The Neon Keris Protocol', 'omar_forkcrafter', 'cyberpunk silat', 'Level 6 - Action Forks', 'published', 'public', true, 'Rafiq Azlan', 'Kuala Lumina beneath a monsoon of advertisements', 'a keris shaped access key', 'the city firewall began reciting his family name', 'Kak Suraya', 'upload the forbidden silat pattern', 'cut the network cable with the old blade', 'neon rain sparked on the edge of the keris'),
    (7, 'ashes-paper-kingdom', 'Ashes of the Paper Kingdom', 'sara_editor', 'political fantasy', 'Level 7 - Closed Canon', 'published', 'public', false, 'Puteri Inas', 'a kingdom where laws were folded into paper birds', 'a crown made of burnt letters', 'the royal archive coughed ash into the throne room', 'Archivist Darun', 'release the paper birds to the people', 'lock the final decree in her own name', 'ash settled like snow on the crown'),
    (8, 'child-borrowed-tomorrow', 'The Child Who Borrowed Tomorrow', 'aiman_arc', 'time loop fable', 'Level 8 - Time Branches', 'published', 'public', true, 'Nabil', 'a one room school at the edge of next week', 'a slate that wrote tomorrows date', 'his younger self knocked from the other side of the classroom door', 'Teacher Salmah', 'open the door before the bell', 'erase tomorrow and accept today', 'chalk dust moved backward through sunlight'),
    (9, 'bazaar-edge-of-sleep', 'The Bazaar at the Edge of Sleep', 'nora_pathfinder', 'dream market', 'Level 9 - Social Discovery', 'published', 'public', true, 'Sofia Maran', 'a midnight bazaar built on sleeping rooftops', 'a coin warm from someone elses dream', 'the dream sellers refused to wake up', 'The Masked Hawker', 'buy back her lost nightmare', 'sell her happiest memory for a key', 'awnings fluttered like eyelids'),
    (10, 'atlas-rain-cities', 'The Atlas of Rain Cities', 'tariq_worldsmith', 'map fantasy', 'Level 10 - Deep ForkCraft', 'published', 'public', true, 'Khalil Sen', 'a library where maps grew moss after rain', 'an atlas bound in storm cloud leather', 'one city disappeared every time he turned a page', 'Librarian Jannah', 'tear out the page that lied', 'walk into the map before the ink dried', 'rain wrote street names on his palms'),
    (11, 'thousand-door-school', 'The Thousand Door School', 'omar_forkcrafter', 'academy adventure', 'Level 11 - Community Forks', 'published', 'unlisted', true, 'Ari Mahmud', 'a school hallway with a thousand numbered doors', 'a timetable with no Mondays', 'Door 404 opened onto his missing year', 'Prefect Leela', 'enter the door that knew his name', 'lead the other students away from it', 'the bell rang from inside his pocket'),
    (12, 'garden-112th-star', 'Garden of the 112th Star', 'demo_admin', 'cosmic garden fable', 'Level 12 - Experimental Draft', 'draft', 'private', true, 'Zahra Samat', 'a garden floating behind the last visible star', 'a black seed that hummed at night', 'the 112th star asked to be planted in human soil', 'Elder Samat', 'plant the star and risk a new sky', 'keep the seed dark until mercy returned', 'one petal opened into a small universe')
    ) as story_seed(
      story_no, slug, title, author_username, genre, level_label, status, visibility, allow_forks,
      protagonist, setting, story_object, inciting_event, mentor, choice_a, choice_b, final_image
    )
    order by story_no
  loop
    select id into v_author_id
    from public.profiles
    where username = st.author_username;

    if v_author_id is null then
      raise exception 'Missing author profile username: %', st.author_username;
    end if;

    insert into public.stories (
      author_id, forked_from_story_id, title, slug, synopsis, cover_url, status, visibility,
      allow_forks, main_branch_id, created_at, updated_at
    )
    values (
      v_author_id,
      null,
      st.title,
      st.slug,
      st.level_label || ' / ' || st.genre || '. ' || st.protagonist || ' enters ' || st.setting || ' after ' || st.inciting_event || '. The first major choice is whether to ' || st.choice_a || ' or to ' || st.choice_b || '.',
      null,
      st.status,
      st.visibility,
      st.allow_forks,
      null,
      timezone('utc', now()) - ((13 - st.story_no) * interval '1 day'),
      timezone('utc', now())
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

    v_branch_count := case when st.story_no <= 4 then 10 else 9 end;
    v_main_branch_id := null;
    v_main_version_id := null;

    for v_branch_index in 1..v_branch_count loop
      v_universe_no := v_universe_no + 1;
      v_motif := v_motifs[((v_universe_no - 1) % array_length(v_motifs, 1)) + 1];
      v_consequence := v_consequences[((v_universe_no - 1) % array_length(v_consequences, 1)) + 1];
      v_sense := v_senses[((v_universe_no - 1) % array_length(v_senses, 1)) + 1];

      if v_branch_index = 1 then
        v_branch_slug := 'main';
        v_branch_name := 'Main Canon - ' || st.level_label;
        v_branch_type := 'main';
      else
        v_branch_slug := 'u' || lpad(v_universe_no::text, 3, '0') || '-' || lower(regexp_replace(v_motif, '[^a-zA-Z0-9]+', '-', 'g'));
        v_branch_name := 'Universe ' || lpad(v_universe_no::text, 3, '0') || ' - ' || v_motif;
        v_branch_type := case when (v_branch_index % 5) = 0 then 'experimental' when (v_branch_index % 3) = 0 then 'alternate' else 'fork' end;
      end if;

      v_branch_visibility := case when st.visibility = 'private' then 'private' when (v_branch_index % 7) = 0 then 'unlisted' else st.visibility end;
      v_chapter_title := case when v_branch_index = 1 then 'The First Turning' else 'The ' || v_motif || ' Turning' end;
      v_summary := st.protagonist || ' faces a turning point in ' || st.title || ': ' || v_consequence || '.';
      v_excerpt := st.protagonist || ' found ' || st.story_object || ' in ' || st.setting || ', while the air smelled of ' || v_sense || '.';
      v_is_published := (st.status = 'published' and v_branch_visibility in ('public', 'unlisted'));

      v_content := format(
        '# Chapter 1 - %s

%s found %s where %s. The place was not quiet; it breathed with %s, and every small sound seemed to know what had happened before she arrived.

%s waited near the edge of the scene, holding back the answer like a match sheltered from wind. "A story does not split because someone is brave," %s said. "It splits because someone finally pays attention."

The first sign came through %s. It warmed, then darkened, then showed a path where %s. In that possible world, %s was not a prophecy but a debt asking to be paid.

%s could %s. She could also %s. Both choices would save something. Both choices would leave someone outside the door.

When she lifted her eyes, %s. The chapter ended there, not because the road was finished, but because the next step belonged to the timeline that dared to continue.',
        v_chapter_title, st.protagonist, st.story_object, st.inciting_event, v_sense, st.mentor, st.mentor, st.story_object, v_consequence, v_motif, st.protagonist, st.choice_a, st.choice_b, st.final_image
      );

      select id into v_branch_id
      from public.story_branches
      where story_id = v_story_id and slug = v_branch_slug
      order by created_at asc
      limit 1;

      if v_branch_id is null then
        insert into public.story_branches (
          story_id, parent_branch_id, created_by, name, slug, description, branch_type, status, visibility,
          forked_from_version_id, created_at, updated_at
        )
        values (
          v_story_id,
          case when v_branch_index = 1 then null else v_main_branch_id end,
          v_author_id,
          v_branch_name,
          v_branch_slug,
          st.genre || ' timeline. ' || v_summary,
          v_branch_type,
          'active',
          v_branch_visibility,
          case when v_branch_index = 1 then null else v_main_version_id end,
          timezone('utc', now()) - ((112 - v_universe_no) * interval '1 hour'),
          timezone('utc', now())
        ) returning id into v_branch_id;
      else
        update public.story_branches
        set parent_branch_id = case when v_branch_index = 1 then null else v_main_branch_id end,
            created_by = v_author_id,
            name = v_branch_name,
            description = st.genre || ' timeline. ' || v_summary,
            branch_type = v_branch_type,
            status = 'active',
            visibility = v_branch_visibility,
            forked_from_version_id = case when v_branch_index = 1 then null else v_main_version_id end,
            updated_at = timezone('utc', now())
        where id = v_branch_id;
      end if;

      if v_branch_index = 1 then
        v_main_branch_id := v_branch_id;
        update public.stories set main_branch_id = v_main_branch_id, updated_at = timezone('utc', now()) where id = v_story_id;
      end if;

      select id into v_chapter_id
      from public.chapters
      where branch_id = v_branch_id and chapter_number = 1
      order by created_at asc
      limit 1;

      if v_chapter_id is null then
        insert into public.chapters (
          story_id, branch_id, chapter_number, title, slug, summary, is_published, published_at, created_by, created_at, updated_at
        )
        values (
          v_story_id,
          v_branch_id,
          1,
          v_chapter_title,
          'chapter-1-' || lower(regexp_replace(v_chapter_title, '[^a-zA-Z0-9]+', '-', 'g')),
          v_summary,
          v_is_published,
          case when v_is_published then timezone('utc', now()) - ((112 - v_universe_no) * interval '1 hour') else null end,
          v_author_id,
          timezone('utc', now()) - ((112 - v_universe_no) * interval '1 hour'),
          timezone('utc', now())
        ) returning id into v_chapter_id;
      else
        update public.chapters
        set story_id = v_story_id,
            title = v_chapter_title,
            slug = 'chapter-1-' || lower(regexp_replace(v_chapter_title, '[^a-zA-Z0-9]+', '-', 'g')),
            summary = v_summary,
            is_published = v_is_published,
            published_at = case when v_is_published then timezone('utc', now()) - ((112 - v_universe_no) * interval '1 hour') else null end,
            created_by = v_author_id,
            updated_at = timezone('utc', now())
        where id = v_chapter_id;
      end if;

      delete from public.likes where chapter_version_id in (select id from public.chapter_versions where chapter_id = v_chapter_id);
      delete from public.chapter_versions where chapter_id = v_chapter_id;

      insert into public.chapter_versions (
        chapter_id, version_number, title, excerpt, content_md, source, commit_message, is_current, created_by, created_at
      )
      values (
        v_chapter_id,
        1,
        v_chapter_title,
        v_excerpt,
        v_content,
        'import',
        'Real narrative seed v1.3: core-safe written prose for ForkCraft timeline simulation.',
        true,
        v_author_id,
        timezone('utc', now()) - ((112 - v_universe_no) * interval '1 hour')
      ) returning id into v_version_id;

      if v_branch_index = 1 then
        v_main_version_id := v_version_id;
      end if;
    end loop;
  end loop;

  if v_universe_no <> 112 then
    raise exception 'Expected 112 universe/timeline branches, got %', v_universe_no;
  end if;
end
$real_stories$;

commit;
