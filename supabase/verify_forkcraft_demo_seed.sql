-- Narrio Demo Seed Verification HOTFIX 3
-- Run after seed_forkcraft_demo_schema_locked.sql.

select
  (select count(*) from public.profiles where username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder')) as demo_users,
  (select count(*) from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')) as demo_stories,
  (
    select count(*)
    from public.story_branches sb
    join public.stories s on s.id = sb.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  ) as demo_universe_timelines,
  (
    select count(*)
    from public.chapters c
    join public.stories s on s.id = c.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  ) as demo_chapters,
  (
    select count(*)
    from public.chapter_versions cv
    join public.chapters c on c.id = cv.chapter_id
    join public.stories s on s.id = c.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
      and cv.is_current = true
  ) as current_versions,
  (
    select count(*)
    from public.stories
    where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
      and status = 'published'
      and visibility = 'public'
  ) as public_published_stories,
  (
    select count(*)
    from public.story_branches sb
    join public.stories s on s.id = sb.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
      and sb.visibility = 'private'
  ) as private_timelines,
  (select count(*) from public.follows f join public.profiles p on p.id = f.user_id where p.username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder')) as demo_follows,
  (select count(*) from public.likes l join public.profiles p on p.id = l.user_id where p.username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder')) as demo_likes,
  (select count(*) from public.bookmarks b join public.profiles p on p.id = b.user_id where p.username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder') and b.is_public = true) as demo_public_bookmarks,
  (
    select count(*)
    from public.comments cm
    join public.stories s on s.id = cm.story_id
    where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  ) as demo_comments;
