-- Phase 0D: cross-device sync of user-created ("manual") vocabulary cards.
--
-- Custom cards are identified by a stable client-generated UUID (content_uid),
-- so two devices cannot collide the way the local autoincrement id did. The
-- card DEFINITION syncs through this table; its SRS scheduling syncs through
-- srs_cards keyed by the same content_uid. On pull, custom_cards is merged
-- before srs_cards so the referenced local flashcard exists first.
--
-- Rollback:
--   drop table public.custom_cards;               -- cascades its triggers/policy
--   drop sequence public.custom_cards_revision_seq;

begin;

create table public.custom_cards (
  user_id     uuid        not null references auth.users (id) on delete cascade,
  content_uid text        not null,
  word_cz     text        not null,
  word_en     text        not null,
  ipa         text,
  device_id   text        not null,
  updated_at  timestamptz not null default now(),
  revision    bigint      not null,
  primary key (user_id, content_uid),
  constraint custom_cards_content_uid_valid
    check (length(content_uid) between 1 and 64),
  constraint custom_cards_words_nonempty
    check (length(word_cz) between 1 and 200 and length(word_en) between 1 and 200),
  constraint custom_cards_device_id_valid
    check (length(device_id) between 1 and 128)
);

create sequence public.custom_cards_revision_seq;
alter table public.custom_cards
  alter column revision set default nextval('public.custom_cards_revision_seq');

-- Server-owned monotonic revision on every insert AND update.
create trigger custom_cards_stamp_revision
before insert or update on public.custom_cards
for each row execute function public.stamp_sync_revision('public.custom_cards_revision_seq');

-- Last-write-wins across devices, consistent with the other sync tables.
create trigger keep_newest_sync_row
before update on public.custom_cards
for each row execute function private.keep_newest_sync_row();

create index custom_cards_revision_pull_idx
  on public.custom_cards (user_id, revision);

alter table public.custom_cards enable row level security;

create policy custom_cards_owner
on public.custom_cards
for all
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

revoke all on table public.custom_cards from anon, authenticated;
grant select, insert, update, delete on table public.custom_cards to authenticated;

commit;
