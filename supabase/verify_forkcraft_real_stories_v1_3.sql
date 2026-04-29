-- Narrio Real Story Seed Pack v1.3 - verification
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
from public.story_branches branch_item
join public.stories story_item on story_item.id = branch_item.story_id
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'chapters', count(*)::int
from public.chapters chapter_item
join public.stories story_item on story_item.id = chapter_item.story_id
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'chapter_versions', count(*)::int
from public.chapter_versions current_version
join public.chapters chapter_item on chapter_item.id = current_version.chapter_id
join public.stories story_item on story_item.id = chapter_item.story_id
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
union all
select 'current_versions', count(*)::int
from public.chapter_versions current_version
join public.chapters chapter_item on chapter_item.id = current_version.chapter_id
join public.stories story_item on story_item.id = chapter_item.story_id
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star') and current_version.is_current = true
union all
select 'public_published_stories', count(*)::int
from public.stories
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star') and status = 'published' and visibility = 'public'
union all
select 'public_published_chapters', count(*)::int
from public.chapters chapter_item
join public.stories story_item on story_item.id = chapter_item.story_id
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star') and chapter_item.is_published = true
order by item;

select story_item.title as story_title,
       branch_item.name as timeline,
       chapter_item.title as chapter_title,
       left(current_version.content_md, 500) as opening_prose
from public.stories story_item
join public.story_branches branch_item on branch_item.story_id = story_item.id
join public.chapters chapter_item on chapter_item.branch_id = branch_item.id
join public.chapter_versions current_version on current_version.chapter_id = chapter_item.id and current_version.is_current = true
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
order by story_item.created_at, branch_item.created_at
limit 12;
