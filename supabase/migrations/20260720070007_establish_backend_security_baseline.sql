begin;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

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

create table if not exists public.ai_daily_usage (
  user_id       uuid        not null references auth.users (id) on delete cascade,
  usage_date    date        not null default (timezone('utc', now()))::date,
  request_count integer     not null default 0,
  updated_at    timestamptz not null default now(),
  primary key (user_id, usage_date)
);

create table if not exists public.curriculum_packs (
  pack_key     text        primary key,
  content      jsonb       not null,
  checksum     text        not null,
  version      integer     not null default 1,
  is_published boolean     not null default false,
  updated_at   timestamptz not null default now()
);

-- Recreate named constraints so existing manually provisioned projects gain
-- the same invariants as a fresh migration-based project.
alter table public.lesson_progress
  drop constraint if exists lesson_progress_ids_positive,
  drop constraint if exists lesson_progress_score_range,
  drop constraint if exists lesson_progress_attempts_nonnegative,
  drop constraint if exists lesson_progress_device_id_valid,
  add constraint lesson_progress_ids_positive
    check (lesson_id > 0 and unit_id > 0),
  add constraint lesson_progress_score_range
    check (best_score >= 0 and best_score <= 100),
  add constraint lesson_progress_attempts_nonnegative check (attempts >= 0),
  add constraint lesson_progress_device_id_valid
    check (length(device_id) between 1 and 128);

alter table public.earned_badges
  drop constraint if exists earned_badges_badge_id_valid,
  drop constraint if exists earned_badges_device_id_valid,
  add constraint earned_badges_badge_id_valid
    check (length(badge_id) between 1 and 128),
  add constraint earned_badges_device_id_valid
    check (length(device_id) between 1 and 128);

alter table public.user_progress
  drop constraint if exists user_progress_key_valid,
  drop constraint if exists user_progress_device_id_valid,
  add constraint user_progress_key_valid check (length(key) between 1 and 128),
  add constraint user_progress_device_id_valid
    check (length(device_id) between 1 and 128);

alter table public.srs_cards
  drop constraint if exists srs_cards_card_type_valid,
  drop constraint if exists srs_cards_content_key_valid,
  drop constraint if exists srs_cards_stability_nonnegative,
  drop constraint if exists srs_cards_difficulty_range,
  drop constraint if exists srs_cards_reps_nonnegative,
  drop constraint if exists srs_cards_state_valid,
  drop constraint if exists srs_cards_device_id_valid,
  add constraint srs_cards_card_type_valid
    check (card_type in ('vocabulary', 'grammar')),
  add constraint srs_cards_content_key_valid
    check (length(content_key) between 1 and 256),
  add constraint srs_cards_stability_nonnegative check (stability >= 0),
  add constraint srs_cards_difficulty_range
    check (difficulty >= 0 and difficulty <= 10),
  add constraint srs_cards_reps_nonnegative check (reps >= 0),
  add constraint srs_cards_state_valid
    check (state in ('newCard', 'learning', 'review', 'relearning')),
  add constraint srs_cards_device_id_valid
    check (length(device_id) between 1 and 128);

alter table public.ai_daily_usage
  drop constraint if exists ai_daily_usage_request_count_nonnegative,
  add constraint ai_daily_usage_request_count_nonnegative
    check (request_count >= 0);

alter table public.curriculum_packs
  drop constraint if exists curriculum_packs_checksum_format,
  drop constraint if exists curriculum_packs_version_positive,
  drop constraint if exists curriculum_packs_key_format,
  add constraint curriculum_packs_checksum_format
    check (checksum ~ '^[0-9a-f]{64}$'),
  add constraint curriculum_packs_version_positive check (version > 0),
  add constraint curriculum_packs_key_format
    check (pack_key ~ '^assets/(curriculum|vocabulary)/[a-zA-Z0-9_./-]+\.json$');

create index if not exists lesson_progress_sync_pull_idx
  on public.lesson_progress (user_id, updated_at, lesson_id);
create index if not exists earned_badges_sync_pull_idx
  on public.earned_badges (user_id, updated_at, badge_id);
create index if not exists user_progress_sync_pull_idx
  on public.user_progress (user_id, updated_at, key);
create index if not exists srs_cards_sync_pull_idx
  on public.srs_cards (user_id, updated_at, card_type, content_key);

-- Keep the documented deterministic LWW rule at the database boundary. This
-- protects newer rows from an older offline client's unconditional upsert.
create or replace function private.keep_newest_sync_row()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.updated_at < old.updated_at
     or (new.updated_at = old.updated_at and new.device_id <= old.device_id)
  then
    return old;
  end if;
  return new;
end;
$$;

revoke all on function private.keep_newest_sync_row()
  from public, anon, authenticated;

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'lesson_progress',
    'earned_badges',
    'user_progress',
    'srs_cards'
  ]
  loop
    execute format(
      'drop trigger if exists keep_newest_sync_row on public.%I',
      table_name
    );
    execute format(
      'create trigger keep_newest_sync_row '
      'before update on public.%I for each row '
      'execute function private.keep_newest_sync_row()',
      table_name
    );
  end loop;
end $$;

alter table public.ai_daily_usage enable row level security;
revoke all on table public.ai_daily_usage from anon, authenticated;

create or replace function public.consume_ai_quota(
  p_user_id uuid,
  p_daily_limit integer
) returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  new_count integer;
begin
  if p_user_id is null or p_daily_limit < 1 then
    return false;
  end if;

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

do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'lesson_progress',
    'earned_badges',
    'user_progress',
    'srs_cards'
  ]
  loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('drop policy if exists %1$s_owner on public.%1$I', table_name);
    execute format(
      'create policy %1$s_owner on public.%1$I '
      'for all to authenticated '
      'using ((select auth.uid()) = user_id) '
      'with check ((select auth.uid()) = user_id)',
      table_name
    );
  end loop;
end $$;

revoke all on table public.lesson_progress from anon, authenticated;
revoke all on table public.earned_badges from anon, authenticated;
revoke all on table public.user_progress from anon, authenticated;
revoke all on table public.srs_cards from anon, authenticated;

grant select, insert, update, delete on table public.lesson_progress
  to authenticated;
grant select, insert, update, delete on table public.earned_badges
  to authenticated;
grant select, insert, update, delete on table public.user_progress
  to authenticated;
grant select, insert, update, delete on table public.srs_cards
  to authenticated;

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

commit;
