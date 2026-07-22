
create table public.ai_daily_usage (
  user_id uuid not null references auth.users(id) on delete cascade,
  usage_date date not null default (timezone('utc', now()))::date,
  request_count integer not null default 0 check (request_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (user_id, usage_date)
);

alter table public.ai_daily_usage enable row level security;
revoke all on table public.ai_daily_usage from anon, authenticated;

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
  if current_user <> 'service_role' then
    raise exception 'not authorized' using errcode = '42501';
  end if;
  if p_daily_limit < 1 then
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
;
