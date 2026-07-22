
-- These tables predated migration tracking in the original project. Keep their
-- definitions here so the fetched remote history can also replay from an empty
-- database; IF NOT EXISTS leaves the already-provisioned project unchanged.
create table if not exists public.lesson_progress (
  user_id        uuid        not null references auth.users (id) on delete cascade,
  lesson_id      integer     not null,
  unit_id        integer     not null,
  is_completed   boolean     not null default false,
  best_score     real        not null default 0,
  attempts       integer     not null default 0,
  last_attempted timestamptz,
  device_id      text        not null,
  updated_at     timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

create table if not exists public.earned_badges (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  badge_id   text        not null,
  earned_at  timestamptz not null default now(),
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

create table if not exists public.user_progress (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  value      jsonb       not null,
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

create table if not exists public.srs_cards (
  user_id       uuid        not null references auth.users (id) on delete cascade,
  card_type     text        not null,
  content_key   text        not null,
  stability     real        not null default 0,
  difficulty    real        not null default 0,
  due           timestamptz not null default now(),
  reps          integer     not null default 0,
  state         text        not null default 'newCard',
  last_reviewed timestamptz,
  device_id     text        not null,
  updated_at    timestamptz not null default now(),
  primary key (user_id, card_type, content_key)
);

alter table public.lesson_progress enable row level security;
alter table public.earned_badges enable row level security;
alter table public.user_progress enable row level security;
alter table public.srs_cards enable row level security;

drop policy if exists lesson_progress_owner on public.lesson_progress;
create policy lesson_progress_owner on public.lesson_progress
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists earned_badges_owner on public.earned_badges;
create policy earned_badges_owner on public.earned_badges
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists user_progress_owner on public.user_progress;
create policy user_progress_owner on public.user_progress
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists srs_cards_owner on public.srs_cards;
create policy srs_cards_owner on public.srs_cards
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
;
