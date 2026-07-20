begin;

create table public.gamification_state (
  user_id                 uuid        not null references auth.users (id) on delete cascade,
  key                     text        not null default 'primary',
  hearts                  integer     not null default 5,
  max_hearts              integer     not null default 5,
  current_streak          integer     not null default 0,
  longest_streak          integer     not null default 0,
  total_xp                integer     not null default 0,
  daily_xp                integer     not null default 0,
  daily_goal_xp           integer     not null default 50,
  gems                    integer     not null default 0,
  earned_badges           jsonb       not null default '[]'::jsonb,
  last_heart_refill       timestamptz,
  streak_freeze_available boolean     not null default true,
  last_open_date          date,
  daily_xp_reset_date     date,
  device_id               text        not null,
  updated_at              timestamptz not null default now(),
  sync_id                 bigint      generated always as identity unique,
  primary key (user_id, key),
  constraint gamification_state_primary_key check (key = 'primary'),
  constraint gamification_state_hearts_range
    check (max_hearts > 0 and hearts between 0 and max_hearts),
  constraint gamification_state_streaks_nonnegative
    check (current_streak >= 0 and longest_streak >= current_streak),
  constraint gamification_state_counters_nonnegative
    check (total_xp >= 0 and daily_xp >= 0 and daily_goal_xp > 0 and gems >= 0),
  constraint gamification_state_badges_array
    check (jsonb_typeof(earned_badges) = 'array'),
  constraint gamification_state_device_id_valid
    check (length(device_id) between 1 and 128)
);

create index gamification_state_sync_pull_idx
  on public.gamification_state (user_id, updated_at, sync_id);

create trigger keep_newest_sync_row
before update on public.gamification_state
for each row execute function private.keep_newest_sync_row();

alter table public.gamification_state enable row level security;

create policy gamification_state_owner
on public.gamification_state
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.gamification_state from anon, authenticated;
grant select, insert, update, delete on table public.gamification_state
  to authenticated;

commit;
