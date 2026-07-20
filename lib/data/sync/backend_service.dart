import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/backend_config.dart';

/// Owns the Supabase client lifecycle and authentication.
///
/// Anonymous-first: when a backend is explicitly configured, launch creates an
/// anonymous session used for curriculum access, progress sync, and AI quota.
/// Anonymous users can later link email/password without changing their user
/// id, or authenticate an existing account on a new device.
///
/// When [BackendConfig.isConfigured] is false the service is inert and the app
/// continues with its bundled curriculum and local-only progress.
class BackendService {
  BackendService({Logger? log}) : _log = log ?? Logger('BackendService');

  final Logger _log;
  bool _initialized = false;

  bool get isEnabled => BackendConfig.isConfigured && _initialized;

  /// Supabase client, or null when the backend is disabled.
  SupabaseClient? get _clientOrNull =>
      isEnabled ? Supabase.instance.client : null;

  /// Authenticated client for backend-backed repositories.
  SupabaseClient? get client => _clientOrNull;

  /// Current user id (anonymous or linked), or null when signed out/disabled.
  String? get userId => _clientOrNull?.auth.currentUser?.id;

  bool get isSignedIn => userId != null;

  /// True while the session is anonymous (not yet linked to an identity).
  bool get isAnonymous => _clientOrNull?.auth.currentUser?.isAnonymous ?? false;

  User? get currentUser => _clientOrNull?.auth.currentUser;

  Stream<AuthState> get authChanges => _requireClient().auth.onAuthStateChange;

  SupabaseClient _requireClient() {
    final value = _clientOrNull;
    if (value == null) {
      throw const AuthException('Cloud account service is unavailable.');
    }
    return value;
  }

  Future<void> requestEmailLink(String email) async {
    final client = _requireClient();
    if (client.auth.currentUser?.isAnonymous != true) {
      throw const AuthException('This account is already linked.');
    }
    await client.auth.updateUser(
      UserAttributes(email: email.trim()),
      emailRedirectTo: 'ceskinapro://auth-callback',
    );
  }

  Future<void> setPassword(String password) async {
    final user = _requireClient().auth.currentUser;
    if (user == null || user.emailConfirmedAt == null) {
      throw const AuthException('Verify the account email first.');
    }
    await _requireClient().auth.updateUser(UserAttributes(password: password));
  }

  /// Validate credentials without replacing the current anonymous session.
  /// The caller can safely clear account-scoped local state only after this
  /// returns a verified session.
  Future<Session> authenticateExisting({
    required String email,
    required String password,
  }) async {
    if (!BackendConfig.isConfigured) {
      throw const AuthException('Cloud account service is unavailable.');
    }
    final temporary = SupabaseClient(
      BackendConfig.supabaseUrl,
      BackendConfig.supabaseAnonKey,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    try {
      final response = await temporary.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final session = response.session;
      if (session == null) throw const AuthException('Sign in failed.');
      return session;
    } finally {
      await temporary.dispose();
    }
  }

  Future<void> installSession(Session session) async {
    await _requireClient().auth.setSession(
      session.refreshToken!,
      accessToken: session.accessToken,
    );
  }

  Future<void> sendPasswordRecovery(String email) async {
    await _requireClient().auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'ceskinapro://auth-callback',
    );
  }

  Future<Map<String, dynamic>> exportCloudData() async {
    final response = await _requireClient().functions.invoke(
      'account-data',
      method: HttpMethod.get,
    );
    if (response.status != 200 || response.data is! Map) {
      throw const AuthException('Cloud export failed.');
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteCloudAccount() async {
    final client = _requireClient();
    final response = await client.functions.invoke(
      'account-data',
      method: HttpMethod.delete,
      headers: const {'x-confirm-account-deletion': 'DELETE MY ACCOUNT'},
    );
    if (response.status != 204) {
      throw const AuthException('Cloud account deletion failed.');
    }
    await client.auth.signOut(scope: SignOutScope.local);
  }

  Future<void> ensureAnonymousSession() async {
    final auth = _requireClient().auth;
    if (auth.currentUser == null) await auth.signInAnonymously();
  }

  /// Initialize Supabase and ensure an (anonymous) session exists.
  /// Safe to retry at startup. Failures are logged and leave the client
  /// disabled; bundled/local course content remains available.
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
