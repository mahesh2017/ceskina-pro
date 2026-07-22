
create table public.curriculum_packs (
  pack_key text primary key,
  content jsonb not null,
  checksum text not null check (checksum ~ '^[0-9a-f]{64}$'),
  version integer not null default 1 check (version > 0),
  is_published boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint curriculum_packs_key_format
    check (pack_key ~ '^assets/(curriculum|vocabulary)/[a-zA-Z0-9_./-]+\.json$')
);

alter table public.curriculum_packs enable row level security;

revoke all on table public.curriculum_packs from anon, authenticated;
grant select on table public.curriculum_packs to anon, authenticated;

create policy curriculum_packs_public_read
on public.curriculum_packs
for select
to anon, authenticated
using (is_published = true);

comment on table public.curriculum_packs is
  'Versioned JSON curriculum source. Mobile clients read published rows and seed local Drift for offline use.';
;
