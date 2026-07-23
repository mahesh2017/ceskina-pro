# Czechify — Roadmap & Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan phase-by-phase. Each phase is independently shippable.

**Goal:** Ship Czechify as a production-ready app with remote content delivery, working exercise types, visual assets, and a clean main branch.

**Architecture:** Offline-first Flutter app with Drift (local SQLite), Supabase (remote content packs + auth + sync), Riverpod state. Content is bundled as skeleton in APK, full curriculum fetched from Supabase `curriculum_packs` table on first launch, cached locally. 14 exercise types dispatched from a single widget router.

**Tech Stack:** Flutter 3.x, Drift 2.20, Riverpod 3, go_router 14, supabase_flutter 2.5, just_audio, speech_to_text, flutter_tts, Dio

**Repo:** `~/czech-learning-app/ceskina_pro/` · Branch: `ux-learning-improvements` · 127 tests passing · Analyzer clean

---

## Current State Summary

| Area | Status |
|------|--------|
| **Units/Lessons** | 31 units, 60 lessons, 726 exercises in JSON |
| **Vocabulary** | 1,005 words (A1 + A2) |
| **Grammar** | 110 rules, 18 declension tables, 8 conjugation tables |
| **SRS** | 500 flashcard starter deck |
| **Exercise types** | 14 types defined; 9 have widget views; 5 new views uncommitted |
| **Infographics** | 17 SVG grammar diagrams |
| **Supabase migrations** | 10 migrations written (curriculum_packs, content_releases, auth, sync, gamification, rate limits) — NOT pushed to remote |
| **Backend code** | BackendService, CurriculumPackSource, ContentSeeder, SyncService all exist and handle offline-first gracefully |
| **Edge Functions** | 2: account-data, deepseek-proxy |
| **Uncommitted work** | 14 modified files + 7 new files (new exercise widgets, grammar quick-ref screen, lesson player enhancements) |
| **Branch divergence** | `ux-learning-improvements` is 25+ commits ahead of `main` |
| **Images** | 56 AI prompts ready at `docs/image_prompts.json`, no images generated |
| **Audio** | Deferred to specialized AI model |
| **CCE exam bank** | Not started |
| **Speech recognition** | Deferred (quality concerns) |

---

## Phase 1: Commit & Stabilize (≈30 min)

**Goal:** Get the working tree clean, tests green, and the branch ready for merge.

### Task 1.1: Run analyzer + tests on current state

**Files:** all existing

**Step 1:** Run analyzer
```bash
cd ~/czech-learning-app/ceskina_pro
flutter analyze
```
Expected: no errors

**Step 2:** Run tests
```bash
flutter test
```
Expected: 127+ pass

### Task 1.2: Commit new exercise widget views

**Files:**
- Create: `lib/presentation/widgets/lesson/exercises/error_correction_view.dart` (already exists, untracked)
- Create: `lib/presentation/widgets/lesson/exercises/listening_comprehension_view.dart`
- Create: `lib/presentation/widgets/lesson/exercises/matching_view.dart`
- Create: `lib/presentation/widgets/lesson/exercises/reading_comprehension_view.dart`
- Create: `lib/presentation/widgets/lesson/exercises/speaking_task_view.dart`
- Create: `lib/presentation/widgets/lesson/exercises/writing_task_view.dart`
- Modify: `lib/presentation/widgets/lesson/exercise_widget.dart` (dispatcher)
- Modify: `lib/domain/entities/enums.dart` (new ExerciseType values)
- Modify: `test/exercise_widget_test.dart` (new dispatch tests)

**Step 1:** Verify all 14 exercise types dispatch correctly
```bash
flutter test test/exercise_widget_test.dart
```

**Step 2:** Commit
```bash
git add lib/presentation/widgets/lesson/exercises/ lib/presentation/widgets/lesson/exercise_widget.dart lib/domain/entities/enums.dart test/exercise_widget_test.dart
git commit -m "feat: add 5 new exercise type widgets (error_correction, listening_comprehension, matching, reading_comprehension, speaking_task, writing_task)"
```

### Task 1.3: Commit curriculum screen + lesson player + grammar screen changes

**Files:**
- Modify: `lib/presentation/screens/curriculum/curriculum_screen.dart`
- Modify: `lib/presentation/screens/lesson/lesson_player_screen.dart`
- Modify: `lib/presentation/screens/grammar/grammar_reference_screen.dart`
- Create: `lib/presentation/screens/grammar/quick_reference_screen.dart`
- Modify: `lib/presentation/providers/curriculum_providers.dart`
- Modify: `lib/presentation/providers/lesson_providers.dart`
- Modify: `lib/presentation/routes/app_router.dart`
- Modify: `assets/curriculum/a1_units.json`
- Modify: `assets/curriculum/a2_units.json`

**Step 1:** Verify tests still pass
```bash
flutter test
```

**Step 2:** Commit
```bash
git add lib/presentation/ assets/curriculum/ lib/domain/
git commit -m "feat: curriculum screen enhancements, grammar quick-reference, lesson player improvements"
```

### Task 1.4: Commit content seeder + test updates

**Files:**
- Modify: `lib/data/seeds/content_seeder.dart`
- Modify: `test/data/content_seeder_manifest_test.dart`
- Modify: `test/data/content_seeder_reliability_test.dart`

**Step 1:** Run seeder tests
```bash
flutter test test/data/
```

**Step 2:** Commit
```bash
git add lib/data/seeds/ test/data/
git commit -m "feat: content seeder updates for expanded curriculum (31 units, 60 lessons)"
```

### Task 1.5: Merge `ux-learning-improvements` → `main`

**Step 1:** Push current branch
```bash
git push origin ux-learning-improvements
```

**Step 2:** Merge to main
```bash
git checkout main
git merge ux-learning-improvements --no-ff -m "merge: ux-learning-improvements — rebrand, curriculum expansion, fonts, infographics, exercise types"
git push origin main
```

**Step 3:** Verify clean state
```bash
git status
flutter analyze
flutter test
```

---

## Phase 2: Supabase Backend Deployment (≈1-2 hours)

**Goal:** Push migrations to a linked Supabase project, seed curriculum packs, and verify the app fetches content remotely.

**Prerequisite:** Mahesh needs to create a Supabase project (or use an existing one) and provide the URL + anon key. This is a manual step.

### Task 2.1: Link Supabase project

**Step 1:** Check if already linked
```bash
cd ~/czech-learning-app/ceskina_pro
supabase status
supabase projects list
```

**Step 2:** Link to remote project (requires project ref from Supabase dashboard)
```bash
supabase link --project-ref <PROJECT_REF>
```

**Verification:** `supabase status` shows linked project info.

### Task 2.2: Push all migrations to remote

**Step 1:** Push migrations
```bash
supabase db push --linked
```

**Step 2:** Verify migration history on remote
```bash
supabase db migrations list
```
Expected: all 10 migrations applied:
1. `create_curriculum_packs`
2. `create_ai_daily_quota`
3. `fix_ai_quota_role_check`
4. `optimize_progress_rls_policies`
5. `create_course_audio_bucket`
6. `establish_backend_security_baseline`
7. `add_sync_pagination_ids`
8. `add_ai_burst_rate_limits`
9. `add_gamification_state_sync`
10. `add_content_release_manifests`

### Task 2.3: Write a curriculum pack seeder script

**Files:**
- Create: `supabase/scripts/seed_curriculum_packs.ts`

This script reads all JSON files from `assets/curriculum/` and `assets/vocabulary/`, computes SHA-256 checksums, and inserts them into the `curriculum_packs` table. Then creates a `content_releases` row marking the release as published.

**Step 1:** Write the seeder script that:
- Reads each JSON file from `assets/curriculum/*.json` and `assets/vocabulary/*.json` and `assets/curriculum/lessons/*.json`
- Computes SHA-256 of the file content
- Upserts into `curriculum_packs` with `pack_key`, `content` (JSONB), `checksum`, `version=1`, `is_published=true`
- Creates a `content_releases` row with all pack refs concatenated checksum, `status='published'`

**Step 2:** Run the seeder
```bash
npx tsx supabase/scripts/seed_curriculum_packs.ts
```

**Step 3:** Verify packs on remote
```bash
supabase db execute --sql "SELECT pack_key, version, is_published FROM curriculum_packs ORDER BY pack_key;"
```
Expected: ~70 rows (2 unit files + 2 vocab files + grammar_rules + cheat_sheets + conjugation_tables + declension_tables + cultural_notes + reading_passages + srs_starter_deck + 60 lesson files)

### Task 2.4: Build app with Supabase credentials and test remote fetch

**Step 1:** Run with credentials
```bash
flutter run \
  --dart-define=SUPABASE_URL=<URL> \
  --dart-define=SUPABASE_ANON_KEY=<KEY>
```

**Step 2:** Verify in logs:
- BackendService init succeeds
- Anonymous session created
- CurriculumPackSource.refreshRemote fetches packs from Supabase
- ContentSeeder installs remote snapshot into Drift
- All 31 units, 60 lessons visible in curriculum screen

**Step 3:** Kill network mid-session, verify offline mode works (content already cached in Drift)

---

## Phase 3: Exercise Type Polish (≈2-3 hours)

**Goal:** Ensure all 14 exercise types are fully functional with proper UI, scoring, and test coverage. 6 new types need verification: `listening_comprehension`, `dialogue_completion`, `error_spotting`, `picture_match`, `role_play`, `timed_challenge`.

### Task 3.1: Audit each new exercise widget

For each of the 6 new exercise types, verify:
- [ ] Widget renders correctly (no overflow, proper layout)
- [ ] Accepts user input appropriately
- [ ] Scores the answer (correct/incorrect/partial)
- [ ] Shows feedback (correct answer, explanation)
- [ ] Integrates with lesson player flow (next/previous)
- [ ] Has a widget test

**Files to check:**
- `lib/presentation/widgets/lesson/exercises/error_correction_view.dart`
- `lib/presentation/widgets/lesson/exercises/listening_comprehension_view.dart`
- `lib/presentation/widgets/lesson/exercises/matching_view.dart`
- `lib/presentation/widgets/lesson/exercises/reading_comprehension_view.dart`
- `lib/presentation/widgets/lesson/exercises/speaking_task_view.dart`
- `lib/presentation/widgets/lesson/exercises/writing_task_view.dart`

### Task 3.2: Add missing exercise widget tests

**Files:**
- Modify: `test/exercise_widget_test.dart`
- Or create: `test/exercise_widget_new_types_test.dart`

For each new type, add a test that:
1. Constructs the widget with sample exercise data
2. Pumps the widget
3. Verifies key UI elements render
4. Simulates user interaction
5. Verifies scoring callback fires

### Task 3.3: Verify `dialogue_completion` and `picture_match` types

These two types from the curriculum expansion may not have dedicated widget views yet. Check:
- `lib/domain/entities/enums.dart` — are both types in the enum?
- `lib/presentation/widgets/lesson/exercise_widget.dart` — is there a dispatch case?
- If missing: create widget views following the pattern of existing views

**Files if needed:**
- Create: `lib/presentation/widgets/lesson/exercises/dialogue_completion_view.dart`
- Create: `lib/presentation/widgets/lesson/exercises/picture_match_view.dart`
- Modify: `lib/presentation/widgets/lesson/exercise_widget.dart`

### Task 3.4: Run full test suite + commit

```bash
flutter analyze
flutter test
git add .
git commit -m "feat: complete all 14 exercise type widgets with tests"
```

---

## Phase 4: Image Asset Generation (≈1-2 hours, parallel with Phase 2-3)

**Goal:** Generate the 56 images referenced in `docs/image_prompts.json` and integrate them into the app.

### Task 4.1: Review the image prompt catalog

**Files:** `docs/image_prompts.json`

Verify the 56 prompts cover:
- Unit header images (31 units)
- Exercise illustration images
- Grammar infographic renders
- App store screenshots / marketing

### Task 4.2: Generate images via Gemini/Imagen

This is a manual step for Mahesh — run the prompts through Gemini Pro / Nano Banana / Imagen.

**Output:** Save generated images to `assets/images/` with names matching the prompt catalog.

### Task 4.3: Integrate images into the app

**Files:**
- Modify: `pubspec.yaml` — declare `assets/images/` directory
- Modify: Unit header widgets / curriculum screen to display unit images
- Modify: Exercise widgets that reference images (picture_match, etc.)

### Task 4.4: Commit

```bash
git add assets/images/ pubspec.yaml lib/
git commit -m "feat: add 56 generated images for units, exercises, and grammar"
```

---

## Phase 5: CCE Exam Bank (≈3-4 hours, can be deferred)

**Goal:** Create a dedicated CCE (Czech Certificate Exam) practice bank with A1 and A2 mock exams.

### Task 5.1: Research CCE exam format

Verify the exam structure: reading, listening, writing, speaking sections, question types, time limits, scoring.

### Task 5.2: Create exam bank JSON

**Files:**
- Create: `assets/curriculum/exam_bank_a1.json`
- Create: `assets/curriculum/exam_bank_a2.json`

Each file contains multiple full mock exams with all sections.

### Task 5.3: Wire exam bank into app

**Files:**
- Modify: `lib/data/seeds/content_seeder.dart` — add exam bank to `requiredPackPaths`
- Modify: `lib/data/database/daos/` — exam DAO if not already present
- Modify: `lib/presentation/screens/exam/` — mock exam screens

### Task 5.4: Test + commit

```bash
flutter test
git add .
git commit -m "feat: add CCE A1/A2 exam bank with mock exams"
```

---

## Phase 6: Audio Integration (deferred)

**Goal:** Generate and integrate Czech audio for vocabulary, dialogues, and pronunciation exercises.

**Status:** Deferred to specialized AI model. Supabase Storage bucket `course-audio` migration already exists.

**When ready:**
1. Generate audio files using neural TTS (ElevenLabs, Azure, or similar)
2. Upload to Supabase Storage `course-audio` bucket
3. Add audio URL fields to vocabulary/lesson JSON
4. Wire `just_audio` playback in exercise widgets
5. Test offline: download audio on first access, cache locally

---

## Open Questions

1. **Supabase project** — Does Mahesh have a Supabase project already, or does he need to create one? The migrations are written but never pushed.
2. **Image generation tool** — Gemini Pro / Nano Banana / Imagen? Which has access?
3. **Audio model** — Which neural TTS service to use for Czech audio?
4. **CCE exam bank priority** — Is this needed for v1 launch or can it be post-launch?
5. **Branch merge strategy** — Squash merge or no-ff merge to main?

---

## Verification Checklist (after all phases)

- [ ] `flutter analyze` — no errors
- [ ] `flutter test` — all tests pass (target: 140+)
- [ ] `main` branch is up to date with all work
- [ ] Supabase migrations pushed and verified
- [ ] App builds with `--dart-define` Supabase credentials
- [ ] Remote content fetch works on first launch
- [ ] Offline mode works after content cached
- [ ] All 14 exercise types functional
- [ ] Images integrated and displaying
- [ ] App runs on iOS simulator + Android emulator