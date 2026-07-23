-- Phase 0D: server-owned monotonic pull cursor.
--
-- The previous pull cursor ordered by (updated_at, sync_id). `updated_at` is
-- written by the client's wall clock and `sync_id` is IDENTITY (assigned on
-- INSERT only, never bumped on UPDATE). A device with a lagging clock, or any
-- row updated after another device advanced its cursor, could be stranded and
-- never pulled. This replaces that with a `revision` stamped from a per-table
-- sequence by a BEFORE INSERT OR UPDATE trigger, so every write — insert or
-- update — gets a strictly larger, server-owned value. Pull orders by
-- `revision` alone, which no client clock can perturb.
--
-- Rollback (reverse order):
--   drop trigger <t>_stamp_revision on public.<t>;   -- each table
--   drop index public.<t>_revision_pull_idx;         -- each table
--   alter table public.<t> drop column revision;     -- each table
--   drop sequence public.<t>_revision_seq;           -- each table
--   drop function public.stamp_sync_revision();

create or replace function public.stamp_sync_revision()
returns trigger
language plpgsql
as $$
begin
  -- tg_argv[0] is the fully-qualified sequence name for the triggering table.
  execute format('select nextval(%L)', tg_argv[0]) into new.revision;
  return new;
end;
$$;

do $$
declare
  t text;
  tables text[] := array[
    'lesson_progress',
    'earned_badges',
    'user_progress',
    'srs_cards',
    'gamification_state'
  ];
begin
  foreach t in array tables loop
    -- 1. per-table sequence
    execute format(
      'create sequence if not exists public.%I_revision_seq', t);

    -- 2. nullable column (added before backfill so the trigger can populate it)
    execute format(
      'alter table public.%I add column if not exists revision bigint', t);

    -- 3. backfill existing rows (near-empty tables; monotonic + unique).
    --    The existing `keep_newest_sync_row` last-write-wins trigger returns
    --    OLD for any UPDATE that is not strictly newer, which would silently
    --    skip this backfill (identical updated_at/device_id) and leave
    --    revision NULL. Disable it for the backfill only, then re-enable.
    execute format(
      'alter table public.%I disable trigger keep_newest_sync_row', t);
    execute format(
      'update public.%I set revision = nextval(''public.%I_revision_seq'')
         where revision is null', t, t);
    execute format(
      'alter table public.%I enable trigger keep_newest_sync_row', t);

    -- 4. stamp on every future insert or update
    execute format(
      'create trigger %I_stamp_revision
         before insert or update on public.%I
         for each row execute function public.stamp_sync_revision(''public.%I_revision_seq'')',
      t, t, t);

    -- 5. enforce presence and index the pull order
    execute format(
      'alter table public.%I alter column revision set not null', t);
    execute format(
      'create index if not exists %I_revision_pull_idx
         on public.%I (user_id, revision)', t, t);
  end loop;
end;
$$;
