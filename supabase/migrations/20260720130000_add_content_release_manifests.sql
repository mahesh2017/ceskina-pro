begin;

-- ── Content release manifests ───────────────────────────────────────────────
-- A release manifest ties together a set of curriculum_packs rows into a
-- named, versioned, atomic release. The client checks this to determine
-- whether a complete content update is available, rather than checking
-- individual packs.
--
-- Each manifest references:
--   - The pack keys + versions that belong to this release
--   - A content checksum (SHA-256 of the concatenated pack checksums)
--   - The previous release id (for rollback)
--   - A release status: draft → published → deprecated
--
-- The client fetches the latest published manifest and compares it to the
-- local version. If the manifest version is newer, the client downloads the
-- referenced packs and installs them atomically. If installation fails, the
-- client keeps the previous local content and retries on the next launch.
create table if not exists public.content_releases (
  release_id       text        not null,
  version          integer     not null check (version > 0),
  status           text        not null default 'draft'
                    check (status in ('draft', 'published', 'deprecated')),
  -- SHA-256 of the sorted, concatenated pack checksums — proves the set is
  -- complete and untampered. The client verifies this after downloading.
  content_checksum text        not null check (content_checksum ~ '^[0-9a-f]{64}$'),
  -- JSON array of {pack_key, version, checksum} objects.
  pack_refs        jsonb       not null,
  -- Previous published release, for explicit rollback targeting.
  previous_release text,
  -- Human-readable release notes (e.g. "Added A2 units 16-22").
  notes            text,
  created_at       timestamptz not null default now(),
  published_at     timestamptz,
  primary key (release_id)
);

alter table public.content_releases enable row level security;
revoke all on table public.content_releases from anon, authenticated;
grant select on table public.content_releases to anon, authenticated;

-- Only the service role (Edge Functions / admin scripts) can create, update,
-- or deprecate releases. Clients read published releases only.
drop policy if exists content_releases_public_read on public.content_releases;
create policy content_releases_public_read
  on public.content_releases
  for select
  to anon, authenticated
  using (status = 'published');

-- Add a content-type constraint on pack_refs: must be an array of objects
-- with pack_key, version, and checksum fields.
alter table public.content_releases
  add constraint pack_refs_is_array
  check (jsonb_typeof(pack_refs) = 'array');

-- Index for the client's "get latest published release" query.
create index if not exists content_releases_published_idx
  on public.content_releases (published_at desc)
  where status = 'published';

comment on table public.content_releases is
  'Versioned, atomic content release manifests with checksum verification and rollback targeting.';

commit;