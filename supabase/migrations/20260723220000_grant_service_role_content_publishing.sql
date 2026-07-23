-- Reproducibility fix: make service_role's write access on the content-release
-- tables explicit in migrations.
--
-- Hosted Supabase auto-grants service_role DML on newly created public tables
-- via an event trigger, so the linked project could publish content and the
-- pgTAP suite passed there. A clean migration-only database (CI `db reset`, a
-- fresh environment, disaster recovery) gets no such grant, so content
-- publishing and `content_releases.test.sql` fail with "permission denied for
-- table curriculum_pack_versions". Grant explicitly so the schema is
-- self-contained and CI's clean-reset pgTAP run is green.
--
-- Immutability is unaffected: curriculum_pack_versions still rejects UPDATE and
-- DELETE via its trigger regardless of these grants; the grant only lets the
-- trigger run and raise (rather than failing earlier on a missing privilege),
-- and lets a privileged publisher INSERT new immutable versions.
--
-- Rollback: revoke insert, update, delete, select on the three tables from
-- service_role.

grant select, insert, update, delete
  on table public.curriculum_pack_versions to service_role;
grant select, insert, update, delete
  on table public.content_release_items to service_role;
grant select, insert, update, delete
  on table public.content_releases to service_role;
