import { assertEquals } from "jsr:@std/assert@1.0.14";
import {
  maxAudioBase64Length,
  parseTranscriptionInput,
} from "./request_policy.ts";

Deno.test("accepts bounded Czech audio input", () => {
  assertEquals(
    parseTranscriptionInput({
      audio_base64: "UklGRg==",
      language: "cs",
      prompt: "  Dobrý den  ",
    }),
    {
      audioBase64: "UklGRg==",
      language: "cs",
      prompt: "Dobrý den",
    },
  );
});

Deno.test("rejects malformed, oversized, and unsupported audio requests", () => {
  assertEquals(parseTranscriptionInput({ audio_base64: "***" }), null);
  assertEquals(
    parseTranscriptionInput({
      audio_base64: "A".repeat(maxAudioBase64Length + 1),
    }),
    null,
  );
  assertEquals(
    parseTranscriptionInput({ audio_base64: "UklGRg==", language: "de" }),
    null,
  );
  assertEquals(
    parseTranscriptionInput({
      audio_base64: "UklGRg==",
      prompt: "x".repeat(501),
    }),
    null,
  );
});
