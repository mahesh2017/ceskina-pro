export const syncedUserTables = [
  "lesson_progress",
  "earned_badges",
  "user_progress",
  "srs_cards",
  "gamification_state",
  "ai_daily_usage",
] as const;

export const isSupportedMethod = (method: string): boolean =>
  method === "GET" || method === "DELETE" || method === "OPTIONS";

export const confirmsDeletion = (value: string | null): boolean =>
  value === "DELETE MY ACCOUNT";
