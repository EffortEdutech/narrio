-- Narrio Real Story Seed Pack v1 verification

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
select 'published_public_stories', count(*)::text
from public.stories
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star') and status = 'published' and visibility = 'public'
union all
select 'seed_login_users', count(*)::text
from public.profiles
where username in ('demo_admin','lina_writer','omar_forkcrafter','maya_reader','tariq_worldsmith','sara_editor','aiman_arc','nora_pathfinder');

select s.title,
       s.slug,
       s.status,
       s.visibility,
       s.allow_forks,
       count(sb.id) as timelines,
       count(c.id) as chapters
from public.stories s
left join public.story_branches sb on sb.story_id = s.id
left join public.chapters c on c.story_id = s.id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
group by s.id, s.title, s.slug, s.status, s.visibility, s.allow_forks
order by min(s.created_at);
