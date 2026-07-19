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
-- Run this in the Supabase SQL editor (EU / Frankfurt project recommended).

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
  primary key (user_id, lesson_id)
);

-- ── earned_badges ───────────────────────────────────────────────────────────
create table if not exists public.earned_badges (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  badge_id   text        not null,
  earned_at  timestamptz not null default now(),
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

-- ── user_progress (KV: streak, xp, settings-ish counters) ────────────────────
create table if not exists public.user_progress (
  user_id    uuid        not null references auth.users (id) on delete cascade,
  key        text        not null,
  value      jsonb       not null,
  device_id  text        not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);

-- ── srs_cards (FSRS state) ───────────────────────────────────────────────────
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
  primary key (user_id, card_type, content_key)
);

-- ── Row-Level Security: users touch only their own rows ──────────────────────
do $$
declare t text;
begin
  foreach t in array array['lesson_progress','earned_badges','user_progress','srs_cards']
  loop
    execute format('alter table public.%I enable row level security;', t);
    execute format($f$
      create policy %1$s_owner on public.%1$I
        for all
        using (user_id = auth.uid())
        with check (user_id = auth.uid());
    $f$, t);
  end loop;
end $$;
