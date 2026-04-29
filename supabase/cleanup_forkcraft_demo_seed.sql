-- Optional cleanup for Narrio demo seed HOTFIX 3
-- Dev/local only. This removes the seeded demo stories and demo users.

begin;

-- Remove social/activity rows first.
delete from public.bookmarks
where user_id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid)
   or chapter_id in (
     select c.id
     from public.chapters c
     join public.stories s on s.id = c.story_id
     where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
   );

delete from public.likes
where user_id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid)
   or chapter_version_id in (
     select cv.id
     from public.chapter_versions cv
     join public.chapters c on c.id = cv.chapter_id
     join public.stories s on s.id = c.story_id
     where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
   );

delete from public.comments
where user_id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid)
   or story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

delete from public.follows
where user_id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid)
   or story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

-- Remove story graph rows.
delete from public.chapter_versions
where chapter_id in (
  select c.id
  from public.chapters c
  join public.stories s on s.id = c.story_id
  where s.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
);

delete from public.chapters
where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

update public.stories
set main_branch_id = null
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

delete from public.story_branches
where story_id in (select id from public.stories where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star'));

delete from public.stories
where slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star');

-- Remove profiles/auth users last.
delete from public.profiles
where id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid);

delete from auth.identities
where user_id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid);

delete from auth.users
where id in ('00000000-0000-4000-8000-000000000101'::uuid, '00000000-0000-4000-8000-000000000102'::uuid, '00000000-0000-4000-8000-000000000103'::uuid, '00000000-0000-4000-8000-000000000104'::uuid, '00000000-0000-4000-8000-000000000105'::uuid, '00000000-0000-4000-8000-000000000106'::uuid, '00000000-0000-4000-8000-000000000107'::uuid, '00000000-0000-4000-8000-000000000108'::uuid);

commit;
