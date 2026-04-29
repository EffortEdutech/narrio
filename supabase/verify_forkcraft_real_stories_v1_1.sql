-- Narrio Real Story Seed v1.1 verification
select 'seed_login_users' as item, count(*)::int as count
from auth.users
where email in ('demo.admin@narrio.test', 'lina.writer@narrio.test', 'omar.forkcrafter@narrio.test', 'maya.reader@narrio.test', 'tariq.worldsmith@narrio.test', 'sara.editor@narrio.test', 'aiman.arc@narrio.test', 'nora.pathfinder@narrio.test')
union all
select 'profiles', count(*)::int
from public.profiles
where username in ('demo_admin', 'lina_writer', 'omar_forkcrafter', 'maya_reader', 'tariq_worldsmith', 'sara_editor', 'aiman_arc', 'nora_pathfinder')
union all
select 'stories', count(*)::int
from public.stories
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'branches', count(*)::int
from public.story_branches sb
join public.stories s on s.id = sb.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'chapters', count(*)::int
from public.chapters c
join public.stories s on s.id = c.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'chapter_versions', count(*)::int
from public.chapter_versions cv
join public.chapters c on c.id = cv.chapter_id
join public.stories s on s.id = c.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'follows', count(*)::int
from public.follows f
join public.stories s on s.id = f.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'likes', count(*)::int
from public.likes l
join public.chapter_versions cv on cv.id = l.chapter_version_id
join public.chapters c on c.id = cv.chapter_id
join public.stories s on s.id = c.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'bookmarks', count(*)::int
from public.bookmarks b
join public.chapters c on c.id = b.chapter_id
join public.stories s on s.id = c.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'comments', count(*)::int
from public.comments cm
join public.stories s on s.id = cm.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
order by item;

-- Spot-check real prose, not filler.
select s.title as story_title,
       sb.name as timeline,
       c.title as chapter_title,
       left(cv.content_md, 280) as opening_prose
from public.stories s
join public.story_branches sb on sb.story_id = s.id
join public.chapters c on c.branch_id = sb.id
join public.chapter_versions cv on cv.chapter_id = c.id and cv.is_current = true
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
order by s.created_at, sb.created_at
limit 12;
