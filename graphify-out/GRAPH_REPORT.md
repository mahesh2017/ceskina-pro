# Graph Report - lib  (2026-07-23)

## Corpus Check
- 158 files · ~120,420 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3182 nodes · 4361 edges · 154 communities (153 shown, 1 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Data/Database Layer
- SRS Flashcard Review
- Domain Entities
- Progress Tracking UI
- SRS Review Screen & TTS
- Lesson Exercise System
- Gamification State
- Exam System & Grading
- Design Tokens & Theming
- Learning Tips
- Curriculum Access Router
- Speech-to-Text & Pronunciation
- Gamification Engine
- Progress DAO
- Asset Bundle & Pack Validation
- Soft UI Components
- Audio & TTS Services
- Curriculum Contract Validation
- Learning Loop & Lesson Player
- Settings & Theme
- Drift Progress Repository
- Placement Engine
- Settings Providers
- Content Seeding & Installation
- Chat Messages Entity
- Backend Sync Service
- Conversations DB Table
- Account Screen
- Vocabulary DAO
- Chat Screen
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132
- Community 133
- Community 134
- Community 135
- Community 136
- Community 137
- Community 138
- Community 139
- Community 140
- Community 141
- Community 142
- Community 143
- Community 144
- Community 145
- Community 146
- Community 147
- Community 148
- Community 149
- Community 150
- Community 151
- Community 152
- Community 153

## God Nodes (most connected - your core abstractions)
1. `DataClass` - 25 edges
2. `gamificationProvider` - 21 edges
3. `AppDatabase` - 18 edges
4. `OnExerciseAnswered` - 17 edges
5. `build` - 14 edges
6. `settingsProvider` - 13 edges
7. `czechTtsProvider` - 11 edges
8. `CzechifyApp` - 8 edges
9. `pronunciationProvider` - 8 edges
10. `AppException` - 7 edges

## Surprising Connections (you probably didn't know these)
- `DriftConversationRepository` --implements--> `ConversationRepository`  [EXTRACTED]
  data/repositories/drift_conversation_repository.dart → domain/repositories/conversation_repository.dart
- `DriftCurriculumRepository` --implements--> `CurriculumRepository`  [EXTRACTED]
  data/repositories/drift_curriculum_repository.dart → domain/repositories/curriculum_repository.dart
- `DriftExamRepository` --implements--> `ExamRepository`  [EXTRACTED]
  data/repositories/drift_exam_repository.dart → domain/repositories/exam_repository.dart
- `DriftProgressRepository` --implements--> `ProgressRepository`  [EXTRACTED]
  data/repositories/drift_progress_repository.dart → domain/repositories/progress_repository.dart
- `DriftVocabularyRepository` --implements--> `VocabularyRepository`  [EXTRACTED]
  data/repositories/drift_vocabulary_repository.dart → domain/repositories/vocabulary_repository.dart

## Import Cycles
- None detected.

## Communities (154 total, 1 thin omitted)

### Community 0 - "Data/Database Layer"
Cohesion: 0.01
Nodes (370): class ContentReleaseInstallation extends, class ContentReleasePack extends, class DelayedTransferAssignment extends, class GamificationStateTableData extends, class LearningEvidenceEvent extends, class LessonProgressData extends, class PlacementProfile extends, class RewardLedgerData extends (+362 more)

### Community 1 - "SRS Flashcard Review"
Cohesion: 0.04
Nodes (56): Flashcard get, againCount, allDue, build, cards, commitError, copyWith, currentCard (+48 more)

### Community 2 - "Domain Entities"
Cohesion: 0.06
Nodes (54): ChatMessage, ExamResult?, Flashcard, Insertable, Lesson, Unit, UpdateCompanion, ChatMessage (+46 more)

### Community 3 - "Progress Tracking UI"
Cohesion: 0.05
Nodes (51): ../../../domain/engines/curriculum_tracker.dart, ProgressSnapshot, _MiniScoreRow, _ScoreRow, _NoDueCardsScreen, _RatingButton, _RatingButtons, _RatingRow (+43 more)

### Community 4 - "SRS Review Screen & TTS"
Cohesion: 0.05
Nodes (49): ../../../domain/engines/srs_scheduler.dart, CardDirection, reviewSessionProvider, czechTtsProvider, _TtsIconButton, build, _finish, build (+41 more)

### Community 5 - "Lesson Exercise System"
Cohesion: 0.04
Nodes (46): Exercise? get, _answerInFlightIndex, _attemptId, _attemptStartedAt, build, completionError, copyWith, correctCount (+38 more)

### Community 6 - "Gamification State"
Cohesion: 0.04
Nodes (45): concept_error_evidence.dart, a1CompletionRate, a2CompletionRate, all, Badge, BadgeCriteria, completedLessonsByUnit, componentEvidence (+37 more)

### Community 7 - "Exam System & Grading"
Cohesion: 0.04
Nodes (45): ../../../domain/engines/exam_grader.dart, ../../../domain/entities/exam_speaking_task.dart, dynamic get, _answer, _answers, build, _buildAnswerReview, _buildChoiceBody (+37 more)

### Community 8 - "Design Tokens & Theming"
Cohesion: 0.05
Nodes (38): @immutable, AppTokens get, BuildContext, amber, amberSoft, AppFonts, AppTokens, AppTokensX (+30 more)

### Community 9 - "Learning Tips"
Cohesion: 0.05
Nodes (37): dart:math, all, body, emoji, forToday, LearningTip, random, title (+29 more)

### Community 10 - "Curriculum Access Router"
Cohesion: 0.05
Nodes (38): ../../domain/engines/curriculum_access_policy.dart, ../../domain/engines/learning_router.dart, a1, a2, allUnits, candidates, completedLessonIds, curriculumAccessProvider (+30 more)

### Community 11 - "Speech-to-Text & Pronunciation"
Cohesion: 0.06
Nodes (36): AudioRecorderService, ../../data/services/stt/audio_recorder.dart, ../../../domain/engines/pronunciation_scorer.dart, AudioRecorderPort, ../../domain/repositories/stt_service.dart, package:speech_to_text/speech_to_text.dart, assess, _assessWithNativeStt (+28 more)

### Community 12 - "Gamification Engine"
Cohesion: 0.06
Nodes (34): ../../data/database/daos/gamification_dao.dart, ../../../domain/engines/gamification_engine.dart, ../../../domain/entities/gamification_state.dart, GamificationState, databaseProvider, progressRepositoryProvider, awardBadge, build (+26 more)

### Community 13 - "Progress DAO"
Cohesion: 0.06
Nodes (34): _asJsonValue, completeTransfer, earnBadge, getCompletedLessons, getDueTransfers, getEarnedBadgeIds, getLearningEvidence, getLessonsByUnit (+26 more)

### Community 14 - "Asset Bundle & Pack Validation"
Cohesion: 0.06
Nodes (33): AssetBundle, ContentRelease? get, curriculum_contract_validator.dart, aggregateChecksum, _backend, _bundle, _canonicalJson, _canonicalMap (+25 more)

### Community 15 - "Soft UI Components"
Cohesion: 0.06
Nodes (33): BoxBorder?, EdgeInsetsGeometry, FontWeight, bg, bold, border, build, child (+25 more)

### Community 16 - "Audio & TTS Services"
Cohesion: 0.06
Nodes (32): AudioPlayer, Dio, FlutterTts, package:crypto/crypto.dart, package:dio/dio.dart, package:flutter_tts/flutter_tts.dart, package:just_audio/just_audio.dart, _audioBucket (+24 more)

### Community 17 - "Curriculum Contract Validation"
Cohesion: 0.06
Nodes (32): _addDataIssue, _canonicalSentence, collectSnapshotIssues, CurriculumContractIssue, CurriculumContractValidator, exerciseId, _intList, issues (+24 more)

### Community 18 - "Learning Loop & Lesson Player"
Cohesion: 0.07
Nodes (31): ../../../domain/engines/learning_loop_engine.dart, lessonUnlockedProvider, lessonSessionProvider, _buildFeedbackBanner, card, createState, _expired, _feedbackPrompt (+23 more)

### Community 19 - "Settings & Theme"
Cohesion: 0.07
Nodes (29): Color?, IconData, AppThemeMode, TtsVoiceGender, children, createState, _Divider, fg (+21 more)

### Community 20 - "Drift Progress Repository"
Cohesion: 0.06
Nodes (30): add, addError, addRepair, _buildUnitEvidence, _ConceptErrorAggregate, _db, _decodeExerciseData, _EvidenceAggregate (+22 more)

### Community 21 - "Placement Engine"
Cohesion: 0.07
Nodes (30): DiagnosticItem? get, ../../../domain/engines/placement_engine.dart, ttsProvider, accepted, _answerController, correctIndex, createState, difficulty (+22 more)

### Community 22 - "Settings Providers"
Cohesion: 0.06
Nodes (30): build, completeOnboarding, copyWith, dailyGoalXp, getBool, heartsEnabled, isOnboardingDone, _kDailyGoalXp (+22 more)

### Community 23 - "Content Seeding & Installation"
Cohesion: 0.07
Nodes (29): ../content/curriculum_pack_source.dart, CurriculumPackSource, _asNullableString, _createMissingSrsCards, _db, ensureBundledContent, hasUsableLocalContent, _installCurrentSnapshot (+21 more)

### Community 24 - "Chat Messages Entity"
Cohesion: 0.07
Nodes (29): audioPath, ChatMessage, content, conversationId, correct, Correction, corrections, CorrectionType (+21 more)

### Community 25 - "Backend Sync Service"
Cohesion: 0.07
Nodes (28): backend_service.dart, _accountTransition, _activeRun, _applyRemote, _backend, beginAccountTransition, _conflictKeys, _db (+20 more)

### Community 26 - "Conversations DB Table"
Cohesion: 0.09
Nodes (25): cefrLevel, createdAt, id, primaryKey, scenario, badgeId, earnedAt, EarnedBadges (+17 more)

### Community 27 - "Account Screen"
Cohesion: 0.08
Nodes (28): accountServiceProvider, accountUserProvider, _AccountHeader, AccountScreen, _AccountScreenState, _askCredentials, _askText, build (+20 more)

### Community 28 - "Vocabulary DAO"
Cohesion: 0.07
Nodes (27): commitSrsReview, _enqueueSrsCard, findByWordCz, flashcardIdsWithoutSrsCards, getAllFlashcards, getDueCards, getDueCount, getFlashcardsByIds (+19 more)

### Community 29 - "Chat Screen"
Cohesion: 0.08
Nodes (27): chatProvider, build, ChatScreen, _ChatScreenState, controller, correction, _CorrectionCard, createState (+19 more)

### Community 30 - "Community 30"
Cohesion: 0.07
Nodes (26): ../../../core/config/backend_config.dart, authChanges, authenticateExisting, client, _clientOrNull, currentSession, currentUser, deleteCloudAccount (+18 more)

### Community 31 - "Community 31"
Cohesion: 0.08
Nodes (25): CustomPainter, ../lesson/delayed_transfer_screen.dart, _ConcentricRings, _DailyGoalHero, dailyGoalXp, dailyXp, fg, icon (+17 more)

### Community 32 - "Community 32"
Cohesion: 0.08
Nodes (25): ../../../../domain/entities/exercise_outcome.dart, AnswerMatch, color, controller, correctAnswer, correctTint, CzechCharBar, enabled (+17 more)

### Community 33 - "Community 33"
Cohesion: 0.08
Nodes (25): apiName, complete, content, context, corrections, delta, fromJson, inputTokens (+17 more)

### Community 34 - "Community 34"
Cohesion: 0.08
Nodes (24): _back, build, _buildGoalStep, _buildLevelStep, _buildNameStep, _buildStep, _buildWelcomeStep, _ChoiceCard (+16 more)

### Community 35 - "Community 35"
Cohesion: 0.09
Nodes (23): ../../common/grammar_tip_card.dart, answered, build, _buildWordChip, _controller, createState, dispose, enabled (+15 more)

### Community 36 - "Community 36"
Cohesion: 0.08
Nodes (23): ExamGrader, ExamScores, fullyScored, grade, _gradeChoiceSection, listening, listeningMax, listeningPoints (+15 more)

### Community 37 - "Community 37"
Cohesion: 0.09
Nodes (23): answered, _answerKey, build, _controller, createState, dispose, exercise, _feedbackText (+15 more)

### Community 38 - "Community 38"
Cohesion: 0.09
Nodes (22): CurriculumDaoManager get, getAllGrammarRules, getExercisesByLesson, getGrammarRuleById, getGrammarRulesByUnit, getLesson, getLessonsByUnit, getUnit (+14 more)

### Community 39 - "Community 39"
Cohesion: 0.09
Nodes (22): ContentReleasePacks, Conversations, ExerciseAttempts, Flashcards, GamificationStateTable, attempts, deadLetteredAt, deviceId (+14 more)

### Community 40 - "Community 40"
Cohesion: 0.09
Nodes (22): correct, DiagnosticItem, DiagnosticObservation, difficulty, estimates, estimateSkill, id, independent (+14 more)

### Community 41 - "Community 41"
Cohesion: 0.09
Nodes (21): app_scaffold.dart, GoRouter, child, onboardingDone, state, ../../providers/settings_providers.dart, ../screens/chat/chat_screen.dart, ../screens/curriculum/curriculum_screen.dart (+13 more)

### Community 42 - "Community 42"
Cohesion: 0.10
Nodes (20): ../coordinators/sync_trigger_coordinator.dart, BackendService, ../../data/sync/backend_service.dart, _cached, ../../data/sync/device_id.dart, DeviceId, _key, _storage (+12 more)

### Community 43 - "Community 43"
Cohesion: 0.11
Nodes (21): ../../../../core/utils/score_colors.dart, double?, pronunciationProvider, build, initState, build, createState, didUpdateWidget (+13 more)

### Community 44 - "Community 44"
Cohesion: 0.10
Nodes (20): audioHash, caseInfo, exampleCz, exampleEn, gender, id, imagePath, ipa (+12 more)

### Community 45 - "Community 45"
Cohesion: 0.10
Nodes (20): audioHash, caseInfo, exampleCz, exampleEn, Flashcard, fromJson, gender, id (+12 more)

### Community 46 - "Community 46"
Cohesion: 0.10
Nodes (20): ../../../../domain/entities/learning_evidence.dart, _allAnswered, _allCorrect, build, _buildQuestion, createState, data, exercise (+12 more)

### Community 47 - "Community 47"
Cohesion: 0.10
Nodes (20): ../../../domain/entities/pronunciation_result.dart, attemptId, _attemptSequence, build, copyWith, error, expectedText, isProcessing (+12 more)

### Community 48 - "Community 48"
Cohesion: 0.10
Nodes (19): app_tokens.dart, accent, AppColors, base, _build, copyWith, darkTheme, _display (+11 more)

### Community 49 - "Community 49"
Cohesion: 0.10
Nodes (19): ../../core/utils/phoneme_mapper.dart, ../../../../core/utils/text_normalizer.dart, actual, _AlignPair, _alignWords, _calculateAccuracy, expected, _generateFeedback (+11 more)

### Community 50 - "Community 50"
Cohesion: 0.11
Nodes (19): ../../../data/database/database.dart, _assignment, assignmentId, _complete, _correct, createState, DelayedTransferScreen, _DelayedTransferScreenState (+11 more)

### Community 51 - "Community 51"
Cohesion: 0.12
Nodes (18): ../../../domain/entities/exercise.dart, Exercise, exercise_widget.dart, OnExerciseAnswered, answered, build, createState, exercise (+10 more)

### Community 52 - "Community 52"
Cohesion: 0.10
Nodes (19): exercises/declension_table_view.dart, exercises/dialogue_view.dart, exercises/dictation_view.dart, exercises/error_correction_view.dart, exercises/exercise_shared.dart, exercises/fill_blank_view.dart, exercises/listening_comprehension_view.dart, exercises/matching_view.dart (+11 more)

### Community 53 - "Community 53"
Cohesion: 0.14
Nodes (19): ConsumerWidget, gamificationProvider, _onLessonComplete, _ScenarioPicker, _ExamCompleteScreen, _LessonCompleteScreen, _TeachPhaseScreen, _TeachWordCard (+11 more)

### Community 54 - "Community 54"
Cohesion: 0.11
Nodes (18): ../../data/content/curriculum_pack_source.dart, ../../data/repositories/drift_conversation_repository.dart, ../../data/repositories/drift_curriculum_repository.dart, DriftCurriculumRepository, ../../data/repositories/drift_exam_repository.dart, ../../data/repositories/drift_progress_repository.dart, ../../data/repositories/drift_vocabulary_repository.dart, ContentSeeder (+10 more)

### Community 55 - "Community 55"
Cohesion: 0.11
Nodes (18): buildSampleExam, _cache, _db, getAllMockExams, getMockExam, getResults, isA1, listeningQuestions (+10 more)

### Community 56 - "Community 56"
Cohesion: 0.11
Nodes (18): ../../data/repositories/llm_service_exception.dart, llm_providers.dart, _boundedScore, build, coherence, copyWith, error, errors (+10 more)

### Community 57 - "Community 57"
Cohesion: 0.12
Nodes (18): sttServiceProvider, _startVoiceInput, _recordSpeaking, _autoSubmitPending, build, createState, exercise, feedback (+10 more)

### Community 58 - "Community 58"
Cohesion: 0.11
Nodes (17): icon, isCompleted, isUnlocked, label, lesson, _LessonTile, _LevelChip, onTap (+9 more)

### Community 59 - "Community 59"
Cohesion: 0.11
Nodes (17): AccountService, _backend, _clearAccountScopedArtifacts, createExportFile, _db, deleteAccountAndLocalData, _exportLocalPreferences, linkEmail (+9 more)

### Community 60 - "Community 60"
Cohesion: 0.11
Nodes (17): conceptKeys, correct, evidenceId, exerciseId, independent, isDelayedTransfer, LearningEvidence, LearningSkill (+9 more)

### Community 61 - "Community 61"
Cohesion: 0.11
Nodes (17): all, build, ChatScenario, conversationId, copyWith, description, error, id (+9 more)

### Community 62 - "Community 62"
Cohesion: 0.19
Nodes (17): _, @DriftAccessor, @DriftDatabase, _$ConversationDaoMixin, _$CurriculumDaoMixin, ConversationDao, CurriculumDao, GamificationDao (+9 more)

### Community 63 - "Community 63"
Cohesion: 0.12
Nodes (16): AnimationController, _controller, createState, dispose, error, _ErrorDisplay, exerciseId, expectedText (+8 more)

### Community 64 - "Community 64"
Cohesion: 0.12
Nodes (16): currentStreak, dailyGoalXp, dailyXp, dailyXpResetDate, earnedBadges, gems, hearts, key (+8 more)

### Community 65 - "Community 65"
Cohesion: 0.12
Nodes (16): _allFilled, answered, _blankAnswers, build, _buildDialogueLines, _checkAnswer, _controllers, createState (+8 more)

### Community 66 - "Community 66"
Cohesion: 0.12
Nodes (16): answered, available, build, _checkAnswer, _checkOrder, color, createState, _czechWords (+8 more)

### Community 67 - "Community 67"
Cohesion: 0.12
Nodes (15): AudioRecorder, cancel, cleanup, _currentPath, dispose, _isRecording, _log, _recorder (+7 more)

### Community 68 - "Community 68"
Cohesion: 0.12
Nodes (15): AppConstants, appName, appVersion, audioBitsPerSample, audioChannels, dbName, defaultDailyGoalXp, heartRegenMinutes (+7 more)

### Community 69 - "Community 69"
Cohesion: 0.12
Nodes (15): ack, deadLetterCount, enqueue, markFailed, pending, pendingCount, PullCursor, setPullCursor (+7 more)

### Community 70 - "Community 70"
Cohesion: 0.12
Nodes (15): DriftExamRepository, ExamRepository, getMockExam, getResults, level, maxScore, MockExam, MockExamSection (+7 more)

### Community 71 - "Community 71"
Cohesion: 0.12
Nodes (15): _client, duration, end, fromJson, isAvailable, language, _log, probability (+7 more)

### Community 72 - "Community 72"
Cohesion: 0.14
Nodes (15): buildConversationRequest, buildGrammarCheckRequest, buildWritingEvaluationRequest, _log, parseTutorResponse, parseTutorResponseSafe, rawLength, reason (+7 more)

### Community 73 - "Community 73"
Cohesion: 0.13
Nodes (15): package:flutter/services.dart, _assetPath, build, _buildBody, _buildCheatSheets, _buildTables, createState, _data (+7 more)

### Community 74 - "Community 74"
Cohesion: 0.12
Nodes (14): package:go_router/go_router.dart, AdaptiveScaffold, build, child, _destinations, _selectedIndex, build, correctAnswer (+6 more)

### Community 75 - "Community 75"
Cohesion: 0.13
Nodes (15): answered, _blankPattern, build, _checkAnswer, _controllerFor, _controllers, createState, _displayAnswer (+7 more)

### Community 76 - "Community 76"
Cohesion: 0.14
Nodes (14): class, _allAnswered, answered, build, _buildOption, _buildQuestion, createState, exercise (+6 more)

### Community 77 - "Community 77"
Cohesion: 0.13
Nodes (14): addManualCard, _db, getCardsForLesson, getCardsForUnit, getDueCards, getDueCount, introducedCardCountForDay, searchCards (+6 more)

### Community 78 - "Community 78"
Cohesion: 0.13
Nodes (14): DriftVocabularyRepository, addManualCard, flashcard, getCardsForLesson, getCardsForUnit, getDueCards, getDueCount, introducedCardCountForDay (+6 more)

### Community 79 - "Community 79"
Cohesion: 0.13
Nodes (14): componentKey, EvidenceDepth, exposures, firstPassAccuracy, initialAttempts, initialCorrect, label, latestAt (+6 more)

### Community 80 - "Community 80"
Cohesion: 0.14
Nodes (13): dart:async, ../../data/sync/sync_service.dart, SyncService, package:connectivity_plus/connectivity_plus.dart, package:flutter/widgets.dart, didChangeAppLifecycleState, dispose, _onConnectivityChanged (+5 more)

### Community 81 - "Community 81"
Cohesion: 0.14
Nodes (13): conceptKeysJson, correct, evidenceId, exerciseId, LearningEvidenceEvents, lessonId, novelTask, observedAt (+5 more)

### Community 82 - "Community 82"
Cohesion: 0.14
Nodes (13): _db, getExercises, getLesson, getLessons, getUnit, getUnits, _parseExerciseType, _toEntityExercise (+5 more)

### Community 83 - "Community 83"
Cohesion: 0.14
Nodes (13): card, getDueCards, _initialEaseFactor, _minEaseFactor, nextReviewDate, previewIntervalDays, schedule, SchedulingResult (+5 more)

### Community 84 - "Community 84"
Cohesion: 0.16
Nodes (14): nextLessonProvider, dueCardCountProvider, build, _ContinueLearningCard, HomeScreen, dueTransferProvider, build, Route /chat (+6 more)

### Community 85 - "Community 85"
Cohesion: 0.15
Nodes (13): answered, build, _checkAnswers, _controllers, correctCount, createState, DeclensionTableView, _DeclensionTableViewState (+5 more)

### Community 86 - "Community 86"
Cohesion: 0.15
Nodes (12): chat_providers.dart, curriculum_providers.dart, ../../data/account/account_service.dart, database_providers.dart, gamification_providers.dart, lesson_providers.dart, backend, watch (+4 more)

### Community 87 - "Community 87"
Cohesion: 0.15
Nodes (12): ConversationDaoManager get, createConversation, deleteConversation, getAllConversations, getMessagesByConversation, insertMessage, ../database.dart, tables/chat_messages.dart (+4 more)

### Community 88 - "Community 88"
Cohesion: 0.15
Nodes (12): answerKey, data, Exercises, grammarRuleId, id, isActive, lessonId, primaryKey (+4 more)

### Community 89 - "Community 89"
Cohesion: 0.15
Nodes (12): attemptId, committedAt, correctCount, incorrectCount, LessonAttempts, lessonId, phase, primaryKey (+4 more)

### Community 90 - "Community 90"
Cohesion: 0.15
Nodes (12): cardType, difficulty, due, flashcardId, grammarPatternKey, id, lastReviewed, reps (+4 more)

### Community 91 - "Community 91"
Cohesion: 0.18
Nodes (12): ../../data/repositories/supabase_llm_service.dart, SupabaseLlmService, ../../domain/engines/llm_orchestrator.dart, LLMOrchestrator, LlmChunk, LlmService, backend, complete (+4 more)

### Community 92 - "Community 92"
Cohesion: 0.15
Nodes (12): details, ExamResult, id, level, listeningScore, passed, readingScore, sectionAverage (+4 more)

### Community 93 - "Community 93"
Cohesion: 0.19
Nodes (12): _canonical, evaluationCriteria, ExamOpenResponseTask, ExamPromptedResponseTask, ExamReadAloudTask, ExamSpeakingTask, expectedPhrases, fromJson (+4 more)

### Community 94 - "Community 94"
Cohesion: 0.15
Nodes (12): feedback, isCorrect, isPassing, overallScore, phoneme, ProblemSound, problemSounds, PronunciationResult (+4 more)

### Community 95 - "Community 95"
Cohesion: 0.15
Nodes (12): CardState, CardType, copyWith, difficulty, due, id, lastReview, Rating (+4 more)

### Community 96 - "Community 96"
Cohesion: 0.17
Nodes (12): exercise_shared.dart, answered, build, _checkAnswer, _controller, createState, dispose, exercise (+4 more)

### Community 97 - "Community 97"
Cohesion: 0.17
Nodes (11): bool?, answered, build, _checkAnswer, _controller, createState, dispose, exercise (+3 more)

### Community 98 - "Community 98"
Cohesion: 0.17
Nodes (11): bool get, ../../data/services/stt/whisper_service.dart, WhisperService, cleanup, CloudTranscriber, isAvailable, isRecording, listenFor (+3 more)

### Community 99 - "Community 99"
Cohesion: 0.17
Nodes (11): conversations.dart, audioPath, ChatMessages, content, conversationId, corrections, createdAt, id (+3 more)

### Community 100 - "Community 100"
Cohesion: 0.17
Nodes (11): core/diagnostics/safe_diagnostics.dart, ../../../core/theme/app_theme.dart, detail, main, _startupErrorMessage, package:flutter/foundation.dart, presentation/providers/database_providers.dart, presentation/providers/settings_providers.dart (+3 more)

### Community 101 - "Community 101"
Cohesion: 0.17
Nodes (11): load, mergeRemote, _primaryKey, save, watchState, _write, GamificationDaoManager get, tables/gamification_state.dart (+3 more)

### Community 102 - "Community 102"
Cohesion: 0.17
Nodes (11): assignmentId, completedAt, completedEvidenceId, createdAt, DelayedTransferAssignments, dueAt, lessonId, primaryKey (+3 more)

### Community 103 - "Community 103"
Cohesion: 0.17
Nodes (11): details, ExamResults, id, level, listeningScore, passed, readingScore, speakingScore (+3 more)

### Community 104 - "Community 104"
Cohesion: 0.17
Nodes (11): caseAffected, examples, explanation, GrammarRules, id, isActive, pattern, primaryKey (+3 more)

### Community 105 - "Community 105"
Cohesion: 0.17
Nodes (11): description, durationMinutes, id, isActive, isReview, Lessons, lessonType, orderInUnit (+3 more)

### Community 106 - "Community 106"
Cohesion: 0.17
Nodes (11): description, grammarTags, id, isActive, isExamPrep, lessonCount, orderIndex, phase (+3 more)

### Community 107 - "Community 107"
Cohesion: 0.17
Nodes (11): completed, conceptKeys, LearningCandidate, LearningRoute, LearningRouter, lessonId, order, priority (+3 more)

### Community 108 - "Community 108"
Cohesion: 0.17
Nodes (11): answerKey, data, Exercise, fromJson, grammarRuleId, id, lessonId, prompt (+3 more)

### Community 109 - "Community 109"
Cohesion: 0.17
Nodes (10): answeredAt, ExerciseAttemptEvidence, ExerciseEvidencePhase, exerciseId, outcome, phase, presentationId, storageValue (+2 more)

### Community 110 - "Community 110"
Cohesion: 0.17
Nodes (11): description, fromJson, grammarTags, id, isExamPrep, lessonCount, orderIndex, phase (+3 more)

### Community 111 - "Community 111"
Cohesion: 0.23
Nodes (12): _ExamTimer, _ExamTimerState, LearningTipCard, _LearningTipCardState, RecordButton, _RecordButtonState, _TextInputCorrection, _TextInputCorrectionState (+4 more)

### Community 112 - "Community 112"
Cohesion: 0.27
Nodes (10): AllProvidersFailedError, AppException, cause, ContentNotSeededError, InvalidApiKeyError, message, OfflineTranscriptionError, toString (+2 more)

### Community 113 - "Community 113"
Cohesion: 0.18
Nodes (10): czechToIpa, getProblemPhonemes, getWeight, longVowels, palatalized, PhonemeMapper, problemSounds, toIpa (+2 more)

### Community 114 - "Community 114"
Cohesion: 0.18
Nodes (10): clearConversation, createConversation, _db, getConversationIds, getHistory, saveMessage, _toEntityChatMessage, ../database/database.dart (+2 more)

### Community 115 - "Community 115"
Cohesion: 0.18
Nodes (10): calculateXp, canRefill, checkBadges, GamificationEngine, getLeague, HeartResult, hearts, isGameOver (+2 more)

### Community 116 - "Community 116"
Cohesion: 0.18
Nodes (10): advance, begin, delayedTransferDue, FeedbackStep, LearningLoopEngine, LearningLoopState, phase, unsuccessfulAttempts (+2 more)

### Community 117 - "Community 117"
Cohesion: 0.18
Nodes (10): description, durationMinutes, fromJson, id, isReview, Lesson, lessonType, orderInUnit (+2 more)

### Community 118 - "Community 118"
Cohesion: 0.20
Nodes (10): LiveTranscriber, confidence, isAvailable, isFinal, PartialTranscript, SttService, text, transcribe (+2 more)

### Community 119 - "Community 119"
Cohesion: 0.20
Nodes (11): allUnitsProvider, unitLessonsProvider, unlockedUnitIdsProvider, unlockedUnits, build, CurriculumScreen, _UnitCard, GrammarReferenceScreen (+3 more)

### Community 120 - "Community 120"
Cohesion: 0.27
Nodes (10): ConsumerState, ConsumerStatefulWidget, OnboardingScreen, _OnboardingScreenState, PronunciationScreen, _PronunciationScreenState, SettingsScreen, _SettingsScreenState (+2 more)

### Community 121 - "Community 121"
Cohesion: 0.22
Nodes (9): dart:convert, ../../../domain/entities/unit.dart, grammarRulesByUnitProvider, build, highlightRuleId, _parseExamples, unit, _UnitGrammarSection (+1 more)

### Community 122 - "Community 122"
Cohesion: 0.20
Nodes (9): contentChecksum, ContentReleaseInstallations, installedAt, isActive, isPrevious, notes, primaryKey, releaseId (+1 more)

### Community 123 - "Community 123"
Cohesion: 0.20
Nodes (9): attempts, bestScore, isCompleted, lastAttempted, lessonId, LessonProgress, primaryKey, unitId (+1 more)

### Community 124 - "Community 124"
Cohesion: 0.20
Nodes (9): awardedAt, primaryKey, rewardId, RewardLedger, rewardType, sourceId, uniqueKeys, xp (+1 more)

### Community 125 - "Community 125"
Cohesion: 0.20
Nodes (9): _client, complete, isAvailable, _messageForStatus, streamComplete, ../../domain/repositories/llm_service.dart, llm_service_exception.dart, package:supabase_flutter/supabase_flutter.dart (+1 more)

### Community 126 - "Community 126"
Cohesion: 0.31
Nodes (10): ChatNotifier, ChatState, loadConversation, sendMessage, _sendTutorGreeting, conversationRepositoryProvider, llmOrchestratorProvider, llmServiceProvider (+2 more)

### Community 127 - "Community 127"
Cohesion: 0.22
Nodes (8): BoolColumn get, introducedNewCard, primaryKey, rating, ReviewAttempts, reviewedAt, reviewId, srsCardId

### Community 128 - "Community 128"
Cohesion: 0.22
Nodes (8): content_release_installations.dart, checksum, content, packKey, packVersion, primaryKey, releaseId, IntColumn get

### Community 129 - "Community 129"
Cohesion: 0.22
Nodes (8): error, _identifier, _logger, SafeDiagnostics, _safeIdentifier, package:logging/logging.dart, static final Logger, static final RegExp

### Community 130 - "Community 130"
Cohesion: 0.22
Nodes (8): ../../../core/theme/app_tokens.dart, ../../../domain/entities/learning_tip.dart, build, createState, initState, _shuffle, _tip, soft_ui.dart

### Community 131 - "Community 131"
Cohesion: 0.22
Nodes (8): estimatesJson, key, learnerOverrideUnit, PlacementProfiles, primaryKey, provisionalUnit, sampleSize, updatedAt

### Community 132 - "Community 132"
Cohesion: 0.22
Nodes (8): DriftConversationRepository, clearConversation, ConversationRepository, createConversation, getConversationIds, getHistory, saveMessage, ../entities/chat_message.dart

### Community 133 - "Community 133"
Cohesion: 0.22
Nodes (8): CurriculumProgressTracker, estimateLevel, isLessonUnlocked, masteryThreshold, phaseCompletion, phaseLessonCoverage, unitCompletion, ../entities/enums.dart

### Community 134 - "Community 134"
Cohesion: 0.22
Nodes (8): ConceptErrorEvidence, conceptKey, initialErrors, label, latestErrorAt, repairedErrors, unresolvedErrors, int? get

### Community 135 - "Community 135"
Cohesion: 0.22
Nodes (8): getExercises, getLesson, getLessons, getUnit, getUnits, ../entities/exercise.dart, ../entities/lesson.dart, ../entities/unit.dart

### Community 136 - "Community 136"
Cohesion: 0.22
Nodes (8): getCompletedLessonIds, getSnapshot, recordCompletion, recordExamPassed, updateStreak, watchProgress, ../entities/exercise_attempt_evidence.dart, ../entities/gamification_state.dart

### Community 137 - "Community 137"
Cohesion: 0.25
Nodes (7): BackendConfig, isConfigured, supabaseAnonKey, supabaseUrl, static bool get, static const String, _

### Community 138 - "Community 138"
Cohesion: 0.25
Nodes (7): CurriculumAccess, CurriculumAccessPolicy, evaluate, lessonPrerequisites, unlockedLessonIds, unlockedUnitIds, Map

### Community 139 - "Community 139"
Cohesion: 0.25
Nodes (7): CEFRLevel, ExamLevel, ExamSectionType, ExerciseType, label, LessonType, Phase

### Community 140 - "Community 140"
Cohesion: 0.43
Nodes (8): build, CzechifyApp, appInitializationProvider, backgroundInitializationProvider, onboardingDoneProvider, themeModeProvider, syncTriggerCoordinatorProvider, appRouterProvider

### Community 141 - "Community 141"
Cohesion: 0.39
Nodes (5): package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, _engine, _leagueColor, ../../providers/gamification_providers.dart

### Community 142 - "Community 142"
Cohesion: 0.29
Nodes (8): curriculumRepositoryProvider, LessonSessionNotifier, LessonSessionState, loadLesson, nextExercise, retry, settingsProvider, _editName

### Community 143 - "Community 143"
Cohesion: 0.29
Nodes (6): goodThreshold, label, of, okThreshold, ScoreColors, static const

### Community 144 - "Community 144"
Cohesion: 0.29
Nodes (6): dart:io, getAvailableVoices, getCachedOrSynthesize, isAvailable, synthesize, TtsService

### Community 145 - "Community 145"
Cohesion: 0.29
Nodes (7): vocabularyRepositoryProvider, loadDueCards, rateCard, ReviewSessionNotifier, ReviewSessionState, _addVocabToDeck, _MessageBubble

### Community 146 - "Community 146"
Cohesion: 0.33
Nodes (5): czechDiacriticChars, matchesIgnoringDiacritics, normalize, stripDiacritics, TextNormalizer

### Community 147 - "Community 147"
Cohesion: 0.33
Nodes (5): CurriculumContractException, LlmServiceException, message, toString, Exception

### Community 148 - "Community 148"
Cohesion: 0.33
Nodes (5): classify, ConceptClassifier, _containsAny, _slug, _titleCase

### Community 149 - "Community 149"
Cohesion: 0.33
Nodes (6): examRepositoryProvider, writingEvalProvider, _finishExam, MockExamScreen, _MockExamScreenState, _startExam

### Community 150 - "Community 150"
Cohesion: 0.33
Nodes (5): build, error, LoadingScreen, onRetry, String?

### Community 151 - "Community 151"
Cohesion: 0.40
Nodes (5): _buildComponentEvidence, _buildConceptErrors, DriftProgressRepository, DateTime?, ProgressRepository

### Community 152 - "Community 152"
Cohesion: 0.67
Nodes (3): Notifier, AppSettings, SettingsNotifier

## Knowledge Gaps
- **2247 isolated node(s):** `BackendConfig`, `supabaseUrl`, `supabaseAnonKey`, `isConfigured`, `_` (+2242 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **1 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppDatabase` connect `Community 62` to `Data/Database Layer`, `Community 77`, `Community 114`, `Community 82`, `Drift Progress Repository`, `Content Seeding & Installation`, `Community 54`, `Community 55`, `Backend Sync Service`, `Community 59`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `ProgressRepository` connect `Community 151` to `Community 136`, `Community 54`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `CurriculumContractException` connect `Community 147` to `Curriculum Contract Validation`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `BackendConfig`, `supabaseUrl`, `supabaseAnonKey` to the rest of the system?**
  _2247 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Data/Database Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.005390835579514825 - nodes in this community are weakly interconnected._
- **Should `SRS Flashcard Review` be split into smaller, more focused modules?**
  _Cohesion score 0.03508771929824561 - nodes in this community are weakly interconnected._
- **Should `Domain Entities` be split into smaller, more focused modules?**
  _Cohesion score 0.06429070580013976 - nodes in this community are weakly interconnected._