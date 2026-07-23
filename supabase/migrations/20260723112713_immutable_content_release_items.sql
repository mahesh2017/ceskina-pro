begin;

create table public.curriculum_pack_versions (
  pack_key   text        not null,
  version    integer     not null check (version > 0),
  content    jsonb       not null,
  checksum   text        not null check (checksum ~ '^[0-9a-f]{64}$'),
  created_at timestamptz not null default now(),
  primary key (pack_key, version),
  unique (pack_key, version, checksum),
  constraint curriculum_pack_versions_key_format
    check (pack_key ~ '^assets/(curriculum|vocabulary)/[a-zA-Z0-9_./-]+\.json$')
);

create table public.content_release_items (
  release_id   text    not null
    references public.content_releases(release_id) on delete restrict,
  pack_key     text    not null,
  pack_version integer not null,
  checksum     text    not null check (checksum ~ '^[0-9a-f]{64}$'),
  position     integer not null check (position >= 0),
  primary key (release_id, pack_key),
  unique (release_id, position),
  foreign key (pack_key, pack_version, checksum)
    references public.curriculum_pack_versions(pack_key, version, checksum)
    on update restrict on delete restrict
);

alter table public.curriculum_pack_versions enable row level security;
alter table public.content_release_items enable row level security;

revoke all on table public.curriculum_pack_versions from anon, authenticated;
revoke all on table public.content_release_items from anon, authenticated;
grant select on table public.curriculum_pack_versions to anon, authenticated;
grant select on table public.content_release_items to anon, authenticated;

create policy curriculum_pack_versions_published_read
  on public.curriculum_pack_versions
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.content_release_items item
      join public.content_releases release
        on release.release_id = item.release_id
      where item.pack_key = curriculum_pack_versions.pack_key
        and item.pack_version = curriculum_pack_versions.version
        and release.status = 'published'
    )
  );

create policy content_release_items_published_read
  on public.content_release_items
  for select
  to anon, authenticated
  using (
    exists (
      select 1
      from public.content_releases release
      where release.release_id = content_release_items.release_id
        and release.status = 'published'
    )
  );

create function public.reject_content_pack_version_mutation()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'curriculum pack versions are immutable'
    using errcode = '55000';
end;
$$;

revoke all on function public.reject_content_pack_version_mutation()
  from public, anon, authenticated;

create trigger curriculum_pack_versions_immutable
before update or delete on public.curriculum_pack_versions
for each row execute function public.reject_content_pack_version_mutation();

create index content_release_items_pack_idx
  on public.content_release_items (pack_key, pack_version);

comment on table public.curriculum_pack_versions is
  'Immutable, checksummed curriculum JSON identified by pack key and version.';
comment on table public.content_release_items is
  'Normalized exact pack membership for an atomic content release.';

commit;
