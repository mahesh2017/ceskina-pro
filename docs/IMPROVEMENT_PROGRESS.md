# Improvement Plan Progress

**Started:** 20 July 2026  
**Source review:** `docs/CODE_ARCHITECTURE_REVIEW_2026-07-20.md`

## Phase 0 batch 1 — implemented locally

- **REV-001:** replaced materially inaccurate privacy claims with the
  actual Supabase sync, DeepSeek, and platform speech data flows. The policy and
  in-app dialog now describe anonymous/linkable accounts, portable export, and
  cloud/local deletion controls.
- **REV-002:** the active curriculum manifest now requires and seeds both
  lessons for all 22 units. The duplicate obsolete loader was removed and a
  44-lesson manifest regression test was added.
- **REV-003, interim:** the backend migration adds a deterministic database
  trigger that rejects older LWW updates and breaks timestamp ties by device ID.
  Server-issued revisions/domain merges remain the target design.
- **REV-006, partial:** the AI gateway now accepts only three product operations,
  rejects client system messages, owns all prompts and model parameters, uses
  allow-listed scenarios, caps input and output, pins dependencies, and has
  policy tests. IP/device/project-wide spend protection and CAPTCHA remain.
- **REV-007:** Android release tasks fail when production signing is absent;
  debug builds remain available.
- **REV-014:** a Supabase CLI-created migration now contains explicit Data API
  grants, RLS, constraints, query-shaped sync indexes, hardened functions, and
  repeatable policies. Manual SQL-editor deployment is no longer documented.
- **REV-023:** backend configuration now fails closed instead of targeting
  production by default. Generated Supabase link state and environment secret
  files are ignored; previously tracked `.temp` metadata was removed.
- **REV-025:** learner text is sent as user-role data rather than embedded in
  client-authored system prompts. Writing scores are clamped to 0–100 and
  malformed error entries are ignored.
- **REV-034, Android portion:** secure-storage preference files are excluded
  from Android cloud backup and device transfer.
- **REV-035, Edge portion:** Supabase JS and the Deno standard assertion module
  are exactly pinned, with a committed Deno lockfile.

## Verification completed

- Flutter analyzer with fatal infos: clean.
- Flutter suite: 103 tests passed.
- Deno type check: passed.
- Edge request-policy tests: 4 passed.
- Android XML parsing: passed.
- Android debug manifest processing: passed.
- Android release dry run: failed with the intended missing-keystore message.

## Verification still required

- Complete a real-email/device linking rehearsal after the staging Auth callback
  allowlist is configured; simulate DeepSeek timeout/error responses, and add
  Turnstile or equivalent signup protection plus anomaly
  and cost alerts. Supabase Auth already applies an IP limit to anonymous
  signup; a product-level device signal remains a future defense-in-depth layer.
- Perform real-device Android backup/restore and release-certificate checks.

## Phase 0 batch 2 — implemented locally

- **REV-004:** startup now validates the local Drift course shape and installs
  the complete packaged curriculum when needed. Backend initialization, sync,
  and remote curriculum refresh run only after local startup and cannot replace
  a usable course screen with a network error.
- **REV-005:** all 49 required curriculum packs are loaded and validated before
  installation, and units, grammar, lessons, exercises, vocabulary, and missing
  SRS cards are committed in one Drift transaction. A forced mid-install
  database error is covered by a regression test proving no partial course is
  left behind. Release IDs/checksums and explicit rollback history remain.
- **REV-013, transaction portion:** lesson completion, earned badges, user
  progress KV writes, and SRS reviews now commit atomically with their sync
  outbox rows. Failure-injection tests prove all four mutation paths roll back
  when enqueue fails.

## Verification completed for batch 2

- Flutter analyzer with fatal infos: clean.
- Bundled curriculum integration test: 22 units, 44 lessons, and SRS content
  installed successfully without backend configuration.
- Atomic curriculum rollback test: passed.
- Transactional outbox rollback tests for lesson progress, badges, KV progress,
  and SRS state: passed.
- Existing schema migration and curriculum manifest regression tests: passed.

## Phase 1 batch 3 — implemented locally

- **REV-010, partial:** sync calls now share one serialized in-flight cycle.
  Startup, lifecycle resume, and connectivity-restoration events trigger the
  same coordinator without overlapping push/pull work. Post-mutation triggers,
  debounce/periodic policy, user-visible health, and cancellation remain.
- **REV-012, partial:** one failed outbox row no longer blocks later rows.
  Failures receive exponential retry timestamps, retain a bounded diagnostic,
  and are quarantined locally after five attempts. Error classification,
  jitter, and a repair UI remain.
- **REV-013:** pulls use explicit 100-row keyset pages ordered by
  `(updated_at, sync_id)`, persist both cursor components after each applied
  page, and continue safely through equal timestamps. A Supabase CLI-created
  migration adds server-generated pagination IDs and matching composite
  `(user_id, updated_at, sync_id)` indexes to all four sync tables.
- **Drift v5:** adds `next_attempt_at`, `dead_lettered_at`, and `last_error` to
  the durable outbox, with tested v1 and v4 upgrade paths.

## Verification completed for batch 3

- Flutter analyzer with fatal infos: clean.
- Concurrent sync coalescing test: passed.
- Poison-row isolation, retry, and dead-letter test: passed.
- Same-timestamp 205-row pagination test: passed across three pages.
- Drift v1 → v5 and v4 → v5 migration tests: passed.
- App smoke test with lifecycle/connectivity coordinator: passed.
- Android debug APK build with the connectivity plugin: passed.
- Fresh local Supabase reset replayed the complete seven-migration history
  successfully. The fetched historical RLS migration now idempotently captures
  the four progress tables that predated migration tracking.
- Database pgTAP suite: 23/23 grant, RLS, quota-execution, constraint, LWW,
  pagination-ID/index, and storage-bucket checks passed.
- Supabase database lint: no schema warnings or errors.
- Pre-release staging deployment: the linked `Ceskina-pro` project received
  `20260720070007_establish_backend_security_baseline.sql` and
  `20260720075822_add_sync_pagination_ids.sql` after an exact dry run.
- Staging migration history: all seven local and remote versions align.
- Staging validation: database lint is clean and the pgTAP suite reports 23/23
  successful. Fifteen hosted checks execute directly; eight mutation/RLS tests
  are explicitly skipped because the managed CLI login cannot create temporary
  `auth.users`, while all eight execute and pass against the clean local stack.
- Edge staging deployment: `deepseek-proxy` version 6 is active with platform
  JWT verification enabled. Its four Deno policy tests and type check pass.
- Live Edge checks passed for missing authentication (401), malformed JWT
  (401), anonymous signup (200), malformed JSON (400), unsupported operation
  (400), a real DeepSeek response (200), and quota exhaustion (429). The
  one-request quota override was removed afterward, restoring the default of
  20, and the disposable anonymous user was deleted.
- **REV-006, burst protection:** a service-role-only atomic PostgreSQL limiter
  now enforces five requests per user per minute and sixty project-wide per
  minute before consuming daily quota or calling DeepSeek. Counters are hashed,
  stored in the non-exposed `private` schema, and retained for at most two days.
- Burst-limit verification: all eight migrations replay locally; database
  pgTAP is 29/29, application-schema lint is clean locally and on staging, Deno
  policy tests are 5/5, and type-checking passes. A live disposable-user test
  returned 200 then 429 with `Retry-After: 60`; its one-request override was
  removed and the account deleted. Hosted pgTAP could not reconnect after the
  migration, so the service-role live invocation provides the remote execution
  check while the complete SQL suite remains locally green.
- **REV-004, account identity:** anonymous users can link a verified email
  without changing their Supabase user ID. Existing-account recovery validates
  credentials in an isolated client before clearing account-scoped local state,
  installs the recovered session, and pulls its cloud state.
- **REV-001, data controls:** Settings now provides a portable JSON export of
  local learner-created state plus all owned cloud rows. Confirmed deletion
  revokes refresh sessions, deletes the Auth user so owned rows cascade, clears
  local learner data while retaining bundled course content, and creates a new
  anonymous session.
- Account lifecycle verification: analyzer clean, 103 Flutter tests pass,
  three account-function policy tests pass, and Deno type-checking is clean.
  The staging `account-data` function passed live checks for unauthenticated
  denial, owned-row export, exact deletion confirmation, 204 deletion,
  post-deletion token rejection, and database cascade cleanup.
- A rollback-only 10,000-row `EXPLAIN` selected
  `lesson_progress_sync_pull_idx` for the production keyset query shape.

## Phase 1 batch 4 — implemented locally

- Timestamp-derived conversation and chat IDs now use UUID v4 values.
- The inaccurately named `FSRSScheduler`/`FSRSCard` API is now
  `SrsScheduler`/`SrsCard`; source, tests, and architecture documentation state
  that the current implementation is simplified SM-2 rather than FSRS.
- Pronunciation scoring now uses Needleman–Wunsch word alignment, rolling-row
  Levenshtein distance, and explicit insertion penalties. Extra, missing, and
  reordered words all affect the final score.
- Production chat and greeting paths now consume the sealed
  `TutorParseResult` API. Empty, malformed, non-object, missing-field, and
  wrong-type responses are logged and handled without exception-driven parsing
  control flow.
- The lesson exercise dispatcher is 88 lines and delegates all eleven exercise
  types to nine focused view/shared files. Widget tests cover every dispatch
  mapping.
- **Drift v6:** gamification state is stored in a single-row Drift table and
  legacy SharedPreferences values are migrated once. Initialization shares one
  readiness future, preventing concurrent startup loads from racing a learner
  mutation.
- Gamification writes now commit atomically with a transactional outbox row.
  Pull applies the server-authoritative whole-state LWW row without echoing it
  back into the queue.
- Supabase migration `20260720120938_add_gamification_state_sync.sql` adds the
  owner-isolated gamification table, explicit authenticated grants, RLS,
  constraints, LWW trigger, pagination identity, and query-shaped pull index.
  Cloud account export includes the table and Auth deletion removes it through
  the user foreign-key cascade.
- Drift upgrade tests now remove the v6 table from their simulated v1/v4
  fixtures before reopening, so they prove that the migration creates it.

## Verification completed for batch 4

- Flutter analyzer with fatal infos: clean.
- Flutter suite: 127 tests pass, including gamification migration/persistence,
  transactional rollback, remote pull without outbox echo, all eleven exercise
  dispatcher mappings, sync triggers, and account export/clear coverage.
- Fresh local Supabase reset replayed all nine migrations successfully.
- Database pgTAP suite: 32/32 table, grant, RLS, constraint, LWW, pagination,
  quota, and storage checks pass.
- Edge policy suites: 8/8 Deno tests pass and both functions type-check.
- Local Supabase application-schema lint: no warnings or errors.
- Local migration history lists all nine versions in alignment.

## Next implementation batch

1. Add a signed/versioned content release manifest with checksums and explicit
   last-known-good rollback metadata.
2. Complete sync error classification, jitter, mutation-triggered drains,
   health/repair UI, and cancellation.
3. Manual flashcard aggregate/global-ID redesign before cross-device SRS sync.
4. Chat, review, lesson, exam, and speech lifecycle race fixes.
