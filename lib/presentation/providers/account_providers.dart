import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/account/account_service.dart';
import 'database_providers.dart';
import 'sync_providers.dart';

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService(
    ref.watch(backendServiceProvider),
    ref.watch(databaseProvider),
  );
});

final accountUserProvider = StreamProvider<User?>((ref) async* {
  await ref.watch(backendInitProvider.future);
  final backend = ref.watch(backendServiceProvider);
  yield backend.currentUser;
  if (backend.client != null) {
    yield* backend.authChanges.map((state) => state.session?.user);
  }
});
