-- Security advisor 0011: pin the search_path. Safe here because the trigger
-- receives the fully-qualified sequence name via tg_argv and only calls
-- pg_catalog functions (format/nextval).
alter function public.stamp_sync_revision() set search_path = '';
