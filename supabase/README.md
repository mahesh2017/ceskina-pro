# Supabase deployment

The app uses anonymous Supabase Auth for progress sync and an authenticated
Edge Function for AI. The DeepSeek key exists only as a server secret.

1. Create an EU Supabase project and enable anonymous sign-ins under
   **Authentication → Sign In / Providers → Anonymous**.
2. Run `schema.sql` in the project's SQL editor.
3. Install/login to the Supabase CLI, link the project, and deploy:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase secrets set DEEPSEEK_API_KEY='YOUR_DEEPSEEK_KEY'
supabase secrets set AI_DAILY_REQUEST_LIMIT='20'
supabase functions deploy deepseek-proxy
supabase storage cp -r AUDIO_MP3_DIRECTORY/. ss:///course-audio \
  --cache-control 'public,max-age=31536000,immutable' \
  --content-type audio/mpeg --experimental
supabase storage cp assets/audio/manifest.json ss:///course-audio/manifest.json \
  --cache-control 'public,max-age=300' \
  --content-type application/json --experimental
```

Do not create a `DEEPSEEK_API_KEY` Dart define and never put it in a checked-in
`.env` file. Supabase automatically provides `SUPABASE_URL` and
`SUPABASE_SERVICE_ROLE_KEY` to the deployed function.

Run the app with the project's public URL and publishable/anon key:

```sh
flutter run \
  --dart-define=SUPABASE_URL='https://YOUR_PROJECT_REF.supabase.co' \
  --dart-define=SUPABASE_ANON_KEY='YOUR_PUBLIC_KEY'
```

The public key is designed to ship in clients; RLS and authenticated Edge
Functions provide authorization. The service-role and DeepSeek keys must never
be shipped.
