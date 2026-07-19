/// Backend (Supabase) configuration.
///
/// Defaults target the Čeština Pro project and can be overridden at build time.
/// The publishable key is safe to ship in the client — row-level security is what
/// protects data, not key secrecy. (Your DeepSeek key is a different story and
/// must move behind an Edge Function; it is NOT stored here.)
///
/// For staging or local projects, override them at build time:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Setting either override to an empty value disables the backend so development
/// builds can still run completely offline.
class BackendConfig {
  const BackendConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pxhjcazremdnsdzpeajo.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_ekIEz6xzgQN4uaQAgLwR0Q_ZfZ9e47r',
  );

  /// True once a project URL + anon key are supplied.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
