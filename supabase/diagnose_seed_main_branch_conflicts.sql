-- Diagnose any existing seeded story branches before/after running v1.2.
select s.slug as story_slug,
       sb.slug as branch_slug,
       count(*)::int as count
from public.story_branches sb
join public.stories s on s.id = sb.story_id
where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
group by s.slug, sb.slug
having count(*) > 1
order by s.slug, sb.slug;
