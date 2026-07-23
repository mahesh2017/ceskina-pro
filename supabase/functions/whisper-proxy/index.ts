// Whisper proxy Edge Function — transcribes audio via OpenAI Whisper API.
// The OpenAI API key is stored as a Supabase secret; the client never sees it.
// Returns verbose_json with word-level timestamps and confidence scores.

import { isRecord, parseTranscriptionInput } from "./request_policy.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const MODEL = "whisper-1";

export default async (req: Request): Promise<Response> => {
  if (req.method !== "POST") {
    return json({ error: "Method not allowed" }, 405);
  }

  if (!OPENAI_API_KEY) {
    return json({ error: "Whisper API key not configured" }, 500);
  }

  try {
    const input = parseTranscriptionInput(await req.json());
    if (!input) {
      return json({ error: "Invalid transcription request" }, 400);
    }

    // Decode base64 audio to bytes
    const audioBytes = Uint8Array.from(
      atob(input.audioBase64),
      (c) => c.charCodeAt(0),
    );

    // Build multipart form data for OpenAI
    const formData = new FormData();
    const blob = new Blob([audioBytes], { type: "audio/wav" });
    formData.append("file", blob, "audio.wav");
    formData.append("model", MODEL);
    formData.append("language", input.language);
    formData.append("response_format", "verbose_json");

    // Optional: pass reference text as prompt to improve accuracy
    if (input.prompt) {
      formData.append("prompt", input.prompt);
    }

    const response = await fetch(
      "https://api.openai.com/v1/audio/transcriptions",
      {
        method: "POST",
        headers: { Authorization: `Bearer ${OPENAI_API_KEY}` },
        body: formData,
      },
    );

    if (!response.ok) {
      return json({
        error: `Whisper API error: ${response.status}`,
      }, 502);
    }

    const decoded: unknown = await response.json();
    if (!isRecord(decoded)) {
      return json({ error: "Invalid transcription response" }, 502);
    }
    const result = decoded;

    // Extract word-level data for pronunciation scoring
    const words: Array<{
      word: string;
      start: number;
      end: number;
      probability: number;
    }> = [];

    if (result.segments && Array.isArray(result.segments)) {
      for (const seg of result.segments) {
        if (isRecord(seg) && seg.words && Array.isArray(seg.words)) {
          for (const w of seg.words) {
            if (!isRecord(w)) continue;
            words.push({
              word: typeof w.word === "string" ? w.word.trim() : "",
              start: typeof w.start === "number" ? w.start : 0,
              end: typeof w.end === "number" ? w.end : 0,
              probability: typeof w.probability === "number"
                ? w.probability
                : 0,
            });
          }
        }
      }
    }

    return json({
      text: typeof result.text === "string" ? result.text : "",
      language: typeof result.language === "string"
        ? result.language
        : input.language,
      duration: typeof result.duration === "number" ? result.duration : 0,
      words,
      segments: Array.isArray(result.segments)
        ? result.segments.filter(isRecord).map((segment) => ({
          id: segment.id,
          start: segment.start,
          end: segment.end,
          text: typeof segment.text === "string" ? segment.text.trim() : "",
          confidence: typeof segment.avg_logprob === "number"
            ? segment.avg_logprob
            : 0,
        }))
        : [],
    }, 200);
  } catch (_) {
    return json({ error: "Internal error" }, 500);
  }
};

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
