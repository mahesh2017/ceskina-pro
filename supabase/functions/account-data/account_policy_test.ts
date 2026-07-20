import { assertEquals } from "jsr:@std/assert@1.0.14";
import {
  confirmsDeletion,
  isSupportedMethod,
  syncedUserTables,
} from "./account_policy.ts";

Deno.test("only export, deletion, and preflight methods are supported", () => {
  assertEquals(isSupportedMethod("GET"), true);
  assertEquals(isSupportedMethod("DELETE"), true);
  assertEquals(isSupportedMethod("POST"), false);
});

Deno.test("account deletion requires an exact confirmation phrase", () => {
  assertEquals(confirmsDeletion("DELETE MY ACCOUNT"), true);
  assertEquals(confirmsDeletion("delete my account"), false);
  assertEquals(confirmsDeletion(null), false);
});

Deno.test("export includes every user-owned cloud table", () => {
  assertEquals(syncedUserTables, [
    "lesson_progress",
    "earned_badges",
    "user_progress",
    "srs_cards",
    "gamification_state",
    "ai_daily_usage",
  ]);
});
