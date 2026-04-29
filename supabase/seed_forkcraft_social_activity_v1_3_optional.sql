-- Narrio Real Story Seed Pack v1.3 - optional social activity
-- Run only after seed_forkcraft_real_stories_v1_3_core_safe.sql succeeds.

begin;

insert into public.follows (user_id, story_id, created_at)
select profile_user.id,
       story_item.id,
       timezone('utc', now()) - ((row_number() over ()) * interval '7 minutes')
from public.profiles profile_user
join public.stories story_item on story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
where profile_user.username in ('maya_reader', 'nora_pathfinder', 'omar_forkcrafter', 'lina_writer')
  and profile_user.id <> story_item.author_id
  and not exists (
    select 1 from public.follows existing_follow
    where existing_follow.user_id = profile_user.id and existing_follow.story_id = story_item.id
  );

insert into public.likes (user_id, chapter_version_id, created_at)
select profile_user.id,
       current_version.id,
       timezone('utc', now()) - ((row_number() over ()) * interval '5 minutes')
from public.profiles profile_user
join public.chapter_versions current_version on true
join public.chapters chapter_item on chapter_item.id = current_version.chapter_id
join public.stories story_item on story_item.id = chapter_item.story_id
where profile_user.username in ('maya_reader', 'nora_pathfinder', 'aiman_arc', 'sara_editor')
  and current_version.is_current = true
  and chapter_item.is_published = true
  and story_item.visibility = 'public'
  and story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  and ((abs(hashtext(profile_user.username || ':' || story_item.slug || ':' || chapter_item.slug)::bigint) % 5) in (0, 2))
  and not exists (
    select 1 from public.likes existing_like
    where existing_like.user_id = profile_user.id and existing_like.chapter_version_id = current_version.id
  );

insert into public.bookmarks (user_id, chapter_id, tag, is_public, created_at)
select profile_user.id,
       chapter_item.id,
       case when chapter_item.summary ilike '%turning point%' then 'fork-point' when story_item.synopsis ilike '%mystery%' then 'clue' else 'turning-point' end,
       ((abs(hashtext(profile_user.username || ':' || chapter_item.slug)::bigint) % 2) = 0),
       timezone('utc', now()) - ((row_number() over ()) * interval '11 minutes')
from public.profiles profile_user
join public.stories story_item on story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
join public.chapters chapter_item on chapter_item.story_id = story_item.id
where profile_user.username in ('maya_reader', 'nora_pathfinder')
  and chapter_item.is_published = true
  and ((abs(hashtext(profile_user.username || ':' || story_item.slug || ':' || chapter_item.slug)::bigint) % 7) in (0, 1))
  and not exists (
    select 1 from public.bookmarks existing_bookmark
    where existing_bookmark.user_id = profile_user.id and existing_bookmark.chapter_id = chapter_item.id
  );

insert into public.comments (chapter_id, story_id, user_id, parent_comment_id, body, is_spoiler, created_at, updated_at)
select chapter_item.id,
       story_item.id,
       profile_user.id,
       null,
       case (abs(hashtext(profile_user.username || ':' || story_item.slug)::bigint) % 6)
         when 0 then 'This turning point feels like a real ForkCraft doorway.'
         when 1 then 'I want to follow the consequence of this choice into a new timeline.'
         when 2 then 'The world rule is clear here. The branch has a reason to exist.'
         when 3 then 'Strong opening image. This chapter makes the universe easy to remember.'
         when 4 then 'This path should be compared beside the main canon in the timeline view.'
         else 'Bookmarking this because the last paragraph gives a strong choice point.'
       end,
       false,
       timezone('utc', now()) - ((row_number() over ()) * interval '13 minutes'),
       timezone('utc', now()) - ((row_number() over ()) * interval '13 minutes')
from public.stories story_item
join public.chapters chapter_item on chapter_item.story_id = story_item.id and chapter_item.chapter_number = 1
join public.story_branches branch_item on branch_item.id = chapter_item.branch_id and branch_item.branch_type = 'main'
join public.profiles profile_user on profile_user.username in ('maya_reader', 'nora_pathfinder', 'omar_forkcrafter')
where story_item.slug in ('river-that-remembers', 'lanterns-over-seri-bay', 'clockmakers-orchard', 'orbit-of-the-last-musafir', 'glass-masjid-seven-moons', 'neon-keris-protocol', 'ashes-paper-kingdom', 'child-borrowed-tomorrow', 'bazaar-edge-of-sleep', 'atlas-rain-cities', 'thousand-door-school', 'garden-112th-star')
  and not exists (
    select 1 from public.comments existing_comment
    where existing_comment.chapter_id = chapter_item.id
      and existing_comment.user_id = profile_user.id
      and existing_comment.body = case (abs(hashtext(profile_user.username || ':' || story_item.slug)::bigint) % 6)
         when 0 then 'This turning point feels like a real ForkCraft doorway.'
         when 1 then 'I want to follow the consequence of this choice into a new timeline.'
         when 2 then 'The world rule is clear here. The branch has a reason to exist.'
         when 3 then 'Strong opening image. This chapter makes the universe easy to remember.'
         when 4 then 'This path should be compared beside the main canon in the timeline view.'
         else 'Bookmarking this because the last paragraph gives a strong choice point.'
       end
  );

commit;
