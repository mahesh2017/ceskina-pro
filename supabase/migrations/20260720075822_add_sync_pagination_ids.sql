alter table public.lesson_progress
  add column sync_id bigint generated always as identity;
alter table public.earned_badges
  add column sync_id bigint generated always as identity;
alter table public.user_progress
  add column sync_id bigint generated always as identity;
alter table public.srs_cards
  add column sync_id bigint generated always as identity;

drop index if exists public.lesson_progress_sync_pull_idx;
drop index if exists public.earned_badges_sync_pull_idx;
drop index if exists public.user_progress_sync_pull_idx;
drop index if exists public.srs_cards_sync_pull_idx;

create unique index lesson_progress_sync_id_idx
  on public.lesson_progress (sync_id);
create unique index earned_badges_sync_id_idx
  on public.earned_badges (sync_id);
create unique index user_progress_sync_id_idx
  on public.user_progress (sync_id);
create unique index srs_cards_sync_id_idx
  on public.srs_cards (sync_id);

create index lesson_progress_sync_pull_idx
  on public.lesson_progress (user_id, updated_at, sync_id);
create index earned_badges_sync_pull_idx
  on public.earned_badges (user_id, updated_at, sync_id);
create index user_progress_sync_pull_idx
  on public.user_progress (user_id, updated_at, sync_id);
create index srs_cards_sync_pull_idx
  on public.srs_cards (user_id, updated_at, sync_id);
