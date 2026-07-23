/// The learner-visible outcome of one exercise presentation.
///
/// Skipped is intentionally distinct from an incorrect attempt: it provides
/// no mastery evidence, costs no heart, earns no XP, and is not re-queued.
enum ExerciseOutcome { correct, incorrect, skipped }
