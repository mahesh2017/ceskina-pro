// @ts-nocheck
// Whisper proxy Edge Function — transcribes audio via OpenAI Whisper API.
// The OpenAI API key is stored as a Supabase secret; the client never sees it.
// Returns verbose_json with word-level timestamps and confidence scores.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

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
    const body = await req.json();
    const audioBase64 = body.audio_base64 as string;
    const language = (body.language as string) || "cs";
    const prompt = (body.prompt as string) | undefined;

    if (!audioBase64) {
      return json({ error: "Missing audio_base64" }, 400);
    }

    // Decode base64 audio to bytes
    const audioBytes = Uint8Array.from(atob(audioBase64), (c) =>
      c.charCodeAt(0)
    );

    // Build multipart form data for OpenAI
    const formData = new FormData();
    const blob = new Blob([audioBytes], { type: "audio/wav" });
    formData.append("file", blob, "audio.wav");
    formData.append("model", MODEL);
    formData.append("language", language);
    formData.append("response_format", "verbose_json");

    // Optional: pass reference text as prompt to improve accuracy
    if (prompt) {
      formData.append("prompt", prompt);
    }

    const response = await fetch(
      "https://api.openai.com/v1/audio/transcriptions",
      {
        method: "POST",
        headers: { Authorization: `Bearer ${OPENAI_API_KEY}` },
        body: formData,
      }
    );

    if (!response.ok) {
      const errorText = await response.text();
      return json({ error: `Whisper API error: ${response.status}`, detail: errorText }, 502);
    }

    const result = await response.json();

    // Extract word-level data for pronunciation scoring
    const words: Array<{
      word: string;
      start: number;
      end: number;
      probability: number;
    }> = [];

    if (result.segments && Array.isArray(result.segments)) {
      for (const seg of result.segments) {
        if (seg.words && Array.isArray(seg.words)) {
          for (const w of seg.words) {
            words.push({
              word: w.word?.trim() ?? "",
              start: w.start ?? 0,
              end: w.end ?? 0,
              probability: w.probability ?? 0,
            });
          }
        }
      }
    }

    return json({
      text: result.text ?? "",
      language: result.language ?? language,
      duration: result.duration ?? 0,
      words,
      segments: (result.segments ?? []).map((s: any) => ({
        id: s.id,
        start: s.start,
        end: s.end,
        text: s.text?.trim() ?? "",
        confidence: s.avg_logprob ?? 0,
      })),
    }, 200);
  } catch (error) {
    return json({ error: "Internal error", detail: error.message }, 500);
  }
};

function json(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}