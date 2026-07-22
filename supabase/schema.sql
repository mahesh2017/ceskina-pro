-- Čeština Pro — backend schema for offline-first progress sync.
--
-- Design:
--   * One row-owner per row via `user_id = auth.uid()`, enforced by RLS so a
--     user can only ever read/write their own rows. This is the strongest
--     privacy posture: isolation is at the database, not the app.
--   * Every table carries `updated_at` + `device_id` for per-row
--     last-write-wins. Clients push the outbox; the server keeps the row with
--     the newer `updated_at` (ties broken by `device_id`).
--   * Natural keys mirror the on-device Drift tables so autoincrement ids
--     never cross device boundaries.
--
-- Historical schema snapshot for human reference only.
--
-- Deploy and evolve the backend exclusively through `supabase/migrations/`.
-- Running this file manually is unsupported because it cannot represent the
-- ordered migration history or validate a fresh-project deployment.

-- ── lesson_progress ─────────────────────────────────────────────────────────
create table if not exists public.lesson_progress (
  user_id       uuid        not null references auth.users (id) on delete cascade,
  lesson_id     integer     not null,
  unit_id       integer     not null,
  is_completed  boolean     not null default false,
  best_score    real        not null default 0,
  attempts      integer     not null default 0,
  last_attempted timestamptz,
  device_id     text        not null,
  updated_at    timestamptz not null default now(),
  sync_id       bigint      generated always as identity unique,
  primary key (user_id, lesson_id)
);

-- ── earned_badges ───────────────────────────────────────────────────────────
create table if not exists public.earned_badges (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  badge_id   text        not null,
  earned_at  timestamptz not null default now(),
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  sync_id    bigint      generated always as identity unique,
  primary key (user_id, badge_id)
);

-- ── user_progress (KV: streak, xp, settings-ish counters) ────────────────────
create table if not exists public.user_progress (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  value      jsonb       not null,
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  sync_id    bigint      generated always as identity unique,
  primary key (user_id, key)
);

-- ── srs_cards (spaced-repetition state) ─────────────────────────────────────
-- Keyed by content, not local id: (card_type, content_key). content_key is the
-- flashcard's stable content key for vocabulary, or grammar_pattern_key for
-- grammar. This keeps ids stable across devices.
create table if not exists public.srs_cards (
  user_id            uuid        not null references auth.users (id) on delete cascade,
  card_type          text        not null,
  content_key        text        not null,
  stability          real        not null default 0,
  difficulty         real        not null default 0,
  due                timestamptz not null default now(),
  reps               integer     not null default 0,
  state              text        not null default 'newCard',
  last_reviewed      timestamptz,
  device_id          text        not null,
  updated_at         timestamptz not null default now(),
  sync_id            bigint      generated always as identity unique,
  primary key (user_id, card_type, content_key)
);

-- ── gamification state ──────────────────────────────────────────────────────
create table if not exists public.gamification_state (
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

create index if not exists gamification_state_sync_pull_idx
  on public.gamification_state (user_id, updated_at, sync_id);

-- ── AI quota accounting (server-only writes) ────────────────────────────────
create table if not exists public.ai_daily_usage (
  user_id       uuid        not null references auth.users (id) on delete cascade,
  usage_date    date        not null default (timezone('utc', now()))::date,
  request_count integer     not null default 0 check (request_count >= 0),
  updated_at    timestamptz not null default now(),
  primary key (user_id, usage_date)
);

alter table public.ai_daily_usage enable row level security;

-- Atomic check-and-increment. Only the Edge Function's service-role client may
-- execute it; mobile clients cannot forge or reset their quota counters.
create or replace function public.consume_ai_quota(
  p_user_id uuid,
  p_daily_limit integer
) returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  insert into public.ai_daily_usage (user_id, usage_date, request_count)
  values (p_user_id, (timezone('utc', now()))::date, 1)
  on conflict (user_id, usage_date) do update
    set request_count = public.ai_daily_usage.request_count + 1,
        updated_at = now()
    where public.ai_daily_usage.request_count < p_daily_limit
  returning request_count into new_count;

  return new_count is not null and new_count <= p_daily_limit;
end;
$$;

revoke all on function public.consume_ai_quota(uuid, integer)
  from public, anon, authenticated;
grant execute on function public.consume_ai_quota(uuid, integer)
  to service_role;

-- ── Published curriculum packs ───────────────────────────────────────────────
-- One row mirrors one source JSON file. This keeps authoring/versioning simple
-- while Drift remains the normalized offline database used by the app UI.
create table if not exists public.curriculum_packs (
  pack_key      text        primary key,
  content       jsonb       not null,
  checksum      text        not null check (checksum ~ '^[0-9a-f]{64}$'),
  version       integer     not null default 1 check (version > 0),
  is_published  boolean     not null default false,
  updated_at    timestamptz not null default now(),
  constraint curriculum_packs_key_format
    check (pack_key ~ '^assets/(curriculum|vocabulary)/[a-zA-Z0-9_./-]+\.json$')
);

alter table public.curriculum_packs enable row level security;
revoke all on table public.curriculum_packs from anon, authenticated;
grant select on table public.curriculum_packs to anon, authenticated;

drop policy if exists curriculum_packs_public_read
  on public.curriculum_packs;
create policy curriculum_packs_public_read
on public.curriculum_packs
for select
to anon, authenticated
using (is_published = true);

-- ── Row-Level Security: users touch only their own rows ──────────────────────
do $$
declare t text;
begin
  foreach t in array array['lesson_progress','earned_badges','user_progress','srs_cards','gamification_state']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format('drop policy if exists %1$s_owner on public.%1$I;', t);
    execute format($f$
      create policy %1$s_owner on public.%1$I
        for all
        to authenticated
        using ((select auth.uid()) = user_id)
        with check ((select auth.uid()) = user_id);
    $f$, t);
  end loop;
end $$;

-- Data API privileges are separate from RLS. New Supabase projects do not
-- automatically expose public-schema tables, so grant only the operations the
-- authenticated sync client uses.
revoke all on table public.lesson_progress from anon, authenticated;
revoke all on table public.earned_badges from anon, authenticated;
revoke all on table public.user_progress from anon, authenticated;
revoke all on table public.srs_cards from anon, authenticated;
revoke all on table public.gamification_state from anon, authenticated;

grant select, insert, update, delete on table public.lesson_progress
  to authenticated;
grant select, insert, update, delete on table public.earned_badges
  to authenticated;
grant select, insert, update, delete on table public.user_progress
  to authenticated;
grant select, insert, update, delete on table public.srs_cards
  to authenticated;
grant select, insert, update, delete on table public.gamification_state
  to authenticated;

-- ── Public neural course audio ──────────────────────────────────────────────
-- Public buckets expose object downloads without an objects SELECT policy.
-- With no INSERT/UPDATE/DELETE policies, app clients cannot mutate this pack.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'course-audio',
  'course-audio',
  true,
  1048576,
  array['audio/mpeg', 'application/json']::text[]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;
