-- Hotfix for Sprint 5 comments relation

alter table public.comments
  drop constraint if exists comments_user_id_fkey;

alter table public.comments
  add constraint comments_user_id_fkey
  foreign key (user_id)
  references public.profiles (id)
  on delete cascade;
