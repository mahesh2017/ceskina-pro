import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/backend_config.dart';

/// Owns the Supabase client lifecycle and authentication.
///
/// Anonymous-first: on launch the user gets an anonymous session so learning
/// works immediately with zero data collected. They link a real identity
/// (Apple / Google / email) only later, when they want sync across devices —
/// at which point the anonymous account is upgraded in place, preserving
/// everything already synced.
///
/// When [BackendConfig.isConfigured] is false the whole service is inert: the
/// app stays fully offline and no network calls are made.
class BackendService {
  BackendService({Logger? log}) : _log = log ?? Logger('BackendService');

  final Logger _log;
  bool _initialized = false;

  bool get isEnabled => BackendConfig.isConfigured && _initialized;

  /// Supabase client, or null when the backend is disabled.
  SupabaseClient? get _clientOrNull =>
      isEnabled ? Supabase.instance.client : null;

  /// Current user id (anonymous or linked), or null when signed out/disabled.
  String? get userId => _clientOrNull?.auth.currentUser?.id;

  bool get isSignedIn => userId != null;

  /// True while the session is anonymous (not yet linked to an identity).
  bool get isAnonymous =>
      _clientOrNull?.auth.currentUser?.isAnonymous ?? false;

  /// Initialize Supabase and ensure an (anonymous) session exists.
  /// Safe to call once at startup; a no-op when unconfigured or on failure —
  /// the app must never fail to launch because the backend is unreachable.
  Future<void> init() async {
    if (!BackendConfig.isConfigured) {
      _log.info('Backend not configured; running offline-only.');
      return;
    }
    try {
      await Supabase.initialize(
        url: BackendConfig.supabaseUrl,
        // A legacy anon JWT or a new sb_publishable_... key both work here.
        publishableKey: BackendConfig.supabaseAnonKey,
      );
      _initialized = true;

      final auth = Supabase.instance.client.auth;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
        _log.info('Signed in anonymously: ${auth.currentUser?.id}');
      } else {
        _log.info('Restored session: ${auth.currentUser?.id}');
      }
    } catch (e, st) {
      // Degrade gracefully to offline; sync simply won't run this session.
      _initialized = false;
      _log.warning('Backend init failed; continuing offline.', e, st);
    }
  }
}
