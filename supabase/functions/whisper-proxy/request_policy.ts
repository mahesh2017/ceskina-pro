export const maxAudioBase64Length = 14_000_000;
const supportedLanguages = new Set(["cs", "en"]);

export interface TranscriptionInput {
  audioBase64: string;
  language: string;
  prompt?: string;
}

export function parseTranscriptionInput(
  value: unknown,
): TranscriptionInput | null {
  if (!isRecord(value)) return null;
  const audioBase64 = value.audio_base64;
  if (
    typeof audioBase64 !== "string" ||
    audioBase64.length === 0 ||
    audioBase64.length > maxAudioBase64Length ||
    !/^[A-Za-z0-9+/]*={0,2}$/.test(audioBase64)
  ) {
    return null;
  }

  const requestedLanguage = value.language ?? "cs";
  if (
    typeof requestedLanguage !== "string" ||
    !supportedLanguages.has(requestedLanguage)
  ) {
    return null;
  }

  const prompt = value.prompt;
  if (
    prompt !== undefined && (typeof prompt !== "string" || prompt.length > 500)
  ) {
    return null;
  }
  return {
    audioBase64,
    language: requestedLanguage,
    ...(prompt?.trim() ? { prompt: prompt.trim() } : {}),
  };
}

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
