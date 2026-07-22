
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
