/// Backend (Supabase) configuration.
///
/// Backend selection is explicit: source builds never default to production.
/// The publishable key is safe to ship in the client, but accidentally targeting
/// production from development still creates users, writes sync data, and can
/// consume paid AI quota.
///
/// For staging or local projects, override them at build time:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Setting either value to an empty string disables the backend.
class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// True once a project URL + anon key are supplied.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
