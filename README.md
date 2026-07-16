# Čeština Pro 🇨🇿

AI-powered Czech language learning app targeting CEFR A1 → A2 proficiency and CCE exam preparation.

Built with Flutter, Clean Architecture, Riverpod, Drift/SQLite, and a custom SM-2 spaced repetition scheduler.

## Tech Stack

- **Framework:** Flutter 3.44 (Dart, AOT compiled)
- **Architecture:** Clean Architecture (3 layers: Presentation, Domain, Data)
- **State Management:** Riverpod 3.x
- **Navigation:** GoRouter
- **Database:** Drift (SQLite) + SharedPreferences (KV store for gamification state)
- **Spaced Repetition:** Custom SM-2 fallback scheduler (dart-fsrs pending pub.dev availability)
- **Platforms:** iOS, Android, macOS, Windows (~95% shared code)

## Project Structure

```
lib/
├── core/              # Constants, theme, errors, utilities
├── domain/
│   ├── engines/       # FSRS Scheduler, Gamification, Pronunciation, LLM Orchestrator
│   ├── entities/      # Unit, Lesson, Exercise, Flashcard, ChatMessage, etc.
│   └── repositories/  # Interface contracts
├── data/
│   ├── database/      # Drift schema (12 tables, 4 DAOs), migrations
│   ├── repositories/  # Drift implementations
│   └── seeds/         # Content seeder (JSON → DB)
└── presentation/
    ├── providers/     # Riverpod Notifier providers
    ├── routes/        # GoRouter config
    ├── screens/       # Home, Curriculum, Lesson, Review, Chat, Stats, etc.
    └── widgets/       # ExerciseWidget, GrammarTipCard, HeartsDisplay, etc.
```

## Current Status

- ✅ **80 Dart files, ~17K lines, zero analyzer errors**
- ✅ Curriculum: Units 1-3 seeded (100+ vocabulary, 13 grammar rules, 6 lessons, 69 exercises)
- ✅ Lesson Player with hearts, XP, progress bar, feedback cards
- ✅ SRS Review with flashcard flip and SM-2 scheduling (cards seeded from vocabulary)
- ✅ Gamification: hearts, streak, XP — persisted to SharedPreferences
- ✅ Unit unlocking based on progress (previous unit completion required)
- ✅ Bottom navigation (Home, Learn, Review, Chat, Stats)
- ✅ Running on Android emulator — all screens verified

### Scaffolded (not yet implemented)

- Chat screen (placeholder)
- Pronunciation recording (hardcoded score)
- Mock exam (not wired)
- LLM/STT/TTS service implementations
- Mic permissions (added to manifests, ready for Phase 2)

## Development

```bash
cd ceskina_pro

# Get dependencies
flutter pub get

# Generate Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run
flutter run
```

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the full 20-section architecture document covering:

- Layer architecture & dependency graph
- 5 domain engines (FSRS, Gamification, Pronunciation, LLM, Curriculum)
- Drift database schema (12 tables)
- AI integration (Vosk STT, Whisper API, LLM orchestrator, TTS caching)
- LLM JSON contracts for tutor AI
- Audio pipeline & platform configs
- 4-phase roadmap (MVP → Production)
- Cost estimates (~$3-5/month for personal use)