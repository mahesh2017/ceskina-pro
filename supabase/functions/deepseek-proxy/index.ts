import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
};

const jsonResponse = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return jsonResponse({ error: "Authentication required." }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const deepSeekKey = Deno.env.get("DEEPSEEK_API_KEY");
  if (!supabaseUrl || !serviceRoleKey || !deepSeekKey) {
    console.error("Missing required server secrets.");
    return jsonResponse({ error: "AI tutor is not configured." }, 503);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const jwt = authorization.slice("Bearer ".length);
  const { data: userData, error: authError } = await admin.auth.getUser(jwt);
  if (authError || !userData.user) {
    return jsonResponse({ error: "Invalid or expired session." }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: "Invalid JSON request." }, 400);
  }

  const messages = body.messages;
  if (!Array.isArray(messages) || messages.length < 1 || messages.length > 24) {
    return jsonResponse({ error: "Messages must contain 1–24 items." }, 400);
  }
  const allowedRoles = new Set(["system", "user", "assistant"]);
  let totalCharacters = 0;
  for (const message of messages) {
    if (
      typeof message !== "object" || message === null ||
      !allowedRoles.has(message.role) || typeof message.content !== "string"
    ) {
      return jsonResponse({ error: "Invalid message format." }, 400);
    }
    totalCharacters += message.content.length;
  }
  if (totalCharacters > 20_000) {
    return jsonResponse({ error: "Conversation is too long." }, 413);
  }

  const configuredLimit = Number(Deno.env.get("AI_DAILY_REQUEST_LIMIT") ?? "20");
  const dailyLimit = Number.isFinite(configuredLimit)
    ? Math.max(1, Math.min(500, Math.floor(configuredLimit)))
    : 20;
  const { data: allowed, error: quotaError } = await admin.rpc("consume_ai_quota", {
    p_user_id: userData.user.id,
    p_daily_limit: dailyLimit,
  });
  if (quotaError) {
    console.error("Quota check failed", quotaError);
    return jsonResponse({ error: "AI tutor is temporarily unavailable." }, 503);
  }
  if (!allowed) {
    return jsonResponse({ error: "Daily AI tutor limit reached. Try again tomorrow." }, 429);
  }

  const requestedTemperature = Number(body.temperature ?? 0.7);
  const temperature = Number.isFinite(requestedTemperature)
    ? Math.max(0, Math.min(1.5, requestedTemperature))
    : 0.7;

  let upstream: Response;
  try {
    upstream = await fetch("https://api.deepseek.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${deepSeekKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "deepseek-chat",
        messages,
        temperature,
        response_format: { type: "json_object" },
      }),
      signal: AbortSignal.timeout(60_000),
    });
  } catch (error) {
    console.error("DeepSeek request failed", error);
    return jsonResponse({ error: "AI tutor request timed out." }, 504);
  }

  const upstreamBody = await upstream.json().catch(() => null);
  if (!upstream.ok) {
    console.error("DeepSeek error", upstream.status, upstreamBody);
    const status = upstream.status === 429 ? 429 : 502;
    return jsonResponse({ error: "AI tutor is temporarily unavailable." }, status);
  }

  const content = upstreamBody?.choices?.[0]?.message?.content;
  if (typeof content !== "string" || content.length === 0) {
    return jsonResponse({ error: "AI tutor returned an empty response." }, 502);
  }
  const usage = upstreamBody.usage ?? {};
  return jsonResponse({
    content,
    input_tokens: Number(usage.prompt_tokens ?? 0),
    output_tokens: Number(usage.completion_tokens ?? 0),
    model: String(upstreamBody.model ?? "deepseek-chat"),
  });
});
