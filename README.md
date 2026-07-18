# Čeština Pro 🇨🇿

AI-powered Czech language learning app targeting CEFR A1 → A2 proficiency and CCE exam preparation.

Built with **Flutter, Clean Architecture, Riverpod, Drift/SQLite**, custom SM-2 spaced repetition, and DeepSeek LLM for AI tutoring.

## Tech Stack

- **Framework:** Flutter 3.44 (Dart, AOT compiled)
- **Architecture:** Clean Architecture (3 layers: Presentation, Domain, Data)
- **State Management:** Riverpod 3.x (Notifier + FutureProvider)
- **Navigation:** GoRouter with adaptive scaffold (mobile bottom nav / desktop side rail)
- **Database:** Drift (SQLite) — 12 tables, 4 DAOs
- **AI:** DeepSeek API (chat completions with JSON response format)
- **STT:** native `speech_to_text` (on-device, OS-native, `cs_CZ` locale)
- **TTS:** `flutter_tts` with hash-based file caching via `just_audio`
- **Spaced Repetition:** Custom SM-2 scheduler with ease factor accumulation
- **Platforms:** iOS, Android, macOS, Windows (~95% shared code)

## Features

### 📚 Interactive Lessons
- Units 1-3 seeded (100+ vocabulary, 13 grammar rules, 6 lessons, 69 exercises)
- 8 exercise types: multiple choice, fill-blank, translation, word-order, dictation, declension table, dialogue, pronunciation
- Global hearts system (5 lives, wrong answer = -1 heart, 1 heart regenerates every 30 min)
- XP rewards + streak tracking + daily XP that resets each day
- Unit unlocking based on progress

### 🔁 Spaced Repetition Review
- SM-2 scheduler with ease factor accumulation (reviews get spaced further apart)
- Four rating buttons: Again / Hard / Good / Easy
- Flashcard flip with Czech → English
- Gender badges, IPA, example sentences

### 🎤 Pronunciation Practice
- Record and compare with OS-native speech recognition
- Levenshtein-based pronunciation scoring engine
- Czech phoneme detection (ř, ě, long vowels, palatalized consonants)
- Per-word score breakdown with color-coded feedback
- Problem sounds detection with practice tips

### 💬 AI Conversation Tutor
- 6 role-play scenarios: Casual Chat, Restaurant, Directions, Shopping, Doctor, Job Interview
- Czech responses with English translations
- Grammar corrections with rule explanations
- New vocabulary chips per message
- TTS speak button on every tutor message
- Powered by DeepSeek API — `deepseek-chat` (mock fallback when no API key)

### 📝 Mock CCE Exams
- 4 timed sections: Reading, Listening, Writing, Speaking
- Per-section countdown timer with visual progress bar
- Listening plays real TTS audio (the sentence is never shown)
- Speaking is recorded and scored via speech recognition
- AI writing evaluation (grammar, vocabulary, coherence scores)
- Results persisted to the database; pass at 60% overall

### 📊 Progress & Stats
- CEFR level estimate (Pre-A1 / A1 / A2)
- A1 + A2 course completion progress bars
- Unit mastery breakdown per unit
- Badge display (earned / unearned with tooltips)
- Streak, XP, hearts, longest streak stats grid

### 🎨 Polish & Desktop
- Dark/light/system theme switching
- Adaptive layout: mobile bottom nav, desktop NavigationRail (≥600px)
- Onboarding flow (level assessment, goal setting, API key config)
- Settings screen (theme, daily goal, TTS rate, API key management)
- TTS audio file caching (MD5-hashed, plays cached via `just_audio`)

## Project Structure

```
lib/
├── core/              # Theme, constants, text normalizer, phoneme mapper
├── domain/
│   ├── engines/       # SM-2 Scheduler, Gamification, Pronunciation, LLM Orchestrator, CurriculumTracker
│   ├── entities/      # Unit, Lesson, Exercise, Flashcard, ChatMessage, GamificationState, etc.
│   └── repositories/  # Interface contracts (TTS, STT, LLM, Exam, Conversation, Progress)
├── data/
│   ├── database/      # Drift schema (12 tables, 4 DAOs), migrations
│   ├── repositories/  # Drift implementations + DeepSeek API client
│   └── seeds/         # Content seeder (JSON → DB) with SRS card seeding
└── presentation/
    ├── providers/     # 15+ Riverpod Notifier providers (gamification, chat, pronunciation,
    │                  #   writing eval, settings, curriculum, review, database, TTS, STT, LLM)
    ├── routes/        # GoRouter config + adaptive scaffold
    ├── screens/       # Home, Curriculum, Lesson, Review, Chat, Pronunciation, Exam,
    │                  #   Stats, Settings, Onboarding (welcome/level/goal/API key)
    └── widgets/       # ExerciseWidget (8 types), HeartsDisplay, StreakIndicator, XpBadge,
                       #   RecordButton, TtsButton
```

## Current Status

| Metric | Value |
|---|---|
| Dart files | **96 files** |
| `flutter analyze --fatal-infos` | **clean (0 issues)** |
| `flutter test` | **72/72 passing** |
| CI | GitHub Actions (analyze + test) |
| Phases 1-4 | **All complete** |

### Remaining before store release

- Generate a real Android upload keystore and fill in `android/key.properties`
  (see `android/app/build.gradle.kts` for the expected keys).
- Publish a privacy policy — chat messages and writing samples are sent to the
  DeepSeek API when an API key is configured.
- Replace the sample mock-exam content with a full CCE-format question bank.

## Development

```bash
cd ceskina_pro

# Get dependencies
flutter pub get

# Generate Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run tests
flutter test

# Release build (Android; requires android/key.properties for store signing)
flutter build appbundle

# Run on device/emulator
flutter run
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full 20-section architecture document covering:

- Layer architecture & dependency graph
- 5 domain engines (SM-2, Gamification, Pronunciation, LLM, Curriculum)
- Drift database schema (12 tables)
- AI integration (DeepSeek API, native STT, flutter_tts with caching)
- LLM JSON contracts for tutor AI with corrections + vocabulary extraction
- Audio pipeline & platform configs (mic permissions on Android + iOS)
- 4-phase roadmap (MVP → Production)
- Cost estimates (~$3-5/month with DeepSeek API for personal use)
