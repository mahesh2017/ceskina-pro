import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/sync/backend_service.dart';
import '../../data/sync/device_id.dart';
import 'database_providers.dart';

/// Secure storage instance (shared).
final _secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Stable per-install device id used as the LWW tiebreaker.
final deviceIdProvider = Provider<DeviceId>((ref) {
  return DeviceId(ref.watch(_secureStorageProvider));
});

/// Supabase client + anonymous auth lifecycle.
final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService();
});

/// Sync outbox DAO.
final syncDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).syncDao;
});

/// Initializes the backend (Supabase + anonymous session). No-op and never
/// throws when the backend is unconfigured, so app startup can always await it.
final backendInitProvider = FutureProvider<void>((ref) async {
  await ref.watch(backendServiceProvider).init();
});
