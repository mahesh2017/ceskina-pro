begin;

create table private.ai_burst_usage (
  scope         text        not null,
  subject_hash  text        not null,
  window_start  timestamptz not null,
  request_count integer     not null default 0,
  updated_at    timestamptz not null default now(),
  primary key (scope, subject_hash, window_start),
  constraint ai_burst_usage_scope_valid
    check (scope in ('project', 'user')),
  constraint ai_burst_usage_hash_valid
    check (subject_hash ~ '^[0-9a-f]{64}$'),
  constraint ai_burst_usage_count_nonnegative
    check (request_count >= 0)
);

alter table private.ai_burst_usage enable row level security;
revoke all on table private.ai_burst_usage from public, anon, authenticated;
grant select, insert, update, delete on table private.ai_burst_usage to service_role;

create index ai_burst_usage_window_cleanup_idx
  on private.ai_burst_usage (window_start);

create or replace function public.consume_ai_burst_quota(
  p_user_id uuid,
  p_user_limit integer default 5,
  p_project_limit integer default 60
)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_window timestamptz := date_trunc('minute', now());
  v_user_hash text := encode(
    extensions.digest(p_user_id::text, 'sha256'),
    'hex'
  );
  v_project_hash constant text := encode(
    extensions.digest('deepseek-proxy', 'sha256'),
    'hex'
  );
begin
  if p_user_id is null
     or p_user_limit not between 1 and 100
     or p_project_limit not between 1 and 5000 then
    raise exception 'invalid AI burst quota arguments'
      using errcode = '22023';
  end if;

  insert into private.ai_burst_usage (
    scope, subject_hash, window_start, request_count
  ) values
    ('project', v_project_hash, v_window, 0),
    ('user', v_user_hash, v_window, 0)
  on conflict do nothing;

  -- A stable lock order prevents deadlocks when many users contend on the
  -- shared project row while retaining independent per-user counters.
  perform 1
  from private.ai_burst_usage
  where window_start = v_window
    and (
      (scope = 'project' and subject_hash = v_project_hash)
      or (scope = 'user' and subject_hash = v_user_hash)
    )
  order by scope, subject_hash
  for update;

  if exists (
    select 1
    from private.ai_burst_usage
    where window_start = v_window
      and (
        (scope = 'project' and subject_hash = v_project_hash
          and request_count >= p_project_limit)
        or (scope = 'user' and subject_hash = v_user_hash
          and request_count >= p_user_limit)
      )
  ) then
    return false;
  end if;

  update private.ai_burst_usage
  set request_count = request_count + 1,
      updated_at = now()
  where window_start = v_window
    and (
      (scope = 'project' and subject_hash = v_project_hash)
      or (scope = 'user' and subject_hash = v_user_hash)
    );

  delete from private.ai_burst_usage
  where window_start < now() - interval '2 days';

  return true;
end;
$$;

revoke all on function public.consume_ai_burst_quota(uuid, integer, integer)
  from public, anon, authenticated;
grant execute on function public.consume_ai_burst_quota(uuid, integer, integer)
  to service_role;

comment on function public.consume_ai_burst_quota(uuid, integer, integer) is
  'Atomically enforces per-user and project-wide fixed-window AI burst limits.';

commit;
