/// Backend (Supabase) configuration.
///
/// Fill these with your Supabase project's values (Project Settings → API).
/// The anon key is safe to ship in the client — row-level security is what
/// protects data, not key secrecy. (Your DeepSeek key is a different story and
/// must move behind an Edge Function; it is NOT stored here.)
///
/// Prefer passing these at build time so they never live in source control:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// When both are empty the app runs fully offline — [isConfigured] is false and
/// all sync/auth becomes a no-op, so nothing breaks before you set up a project.
class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');

  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// True once a project URL + anon key are supplied.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
