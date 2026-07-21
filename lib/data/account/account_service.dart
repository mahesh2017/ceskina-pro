import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import '../sync/backend_service.dart';

class AccountService {
  AccountService(this._backend, this._db);

  final BackendService _backend;
  final AppDatabase _db;

  Future<void> linkEmail(String email) => _backend.requestEmailLink(email);

  Future<void> setPassword(String password) => _backend.setPassword(password);

  Future<void> sendPasswordRecovery(String email) =>
      _backend.sendPasswordRecovery(email);

  Future<void> switchToExistingAccount({
    required String email,
    required String password,
  }) async {
    final session = await _backend.authenticateExisting(
      email: email,
      password: password,
    );
    await _db.clearLearnerData();
    await _backend.installSession(session);
  }

  Future<File> createExportFile() async {
    final local = await _db.exportLearnerData();
    Map<String, dynamic>? cloud;
    if (_backend.isSignedIn) cloud = await _backend.exportCloudData();
    final payload = {
      'format': 'czechify-user-export',
      'format_version': 1,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'local_data': local,
      'cloud_export': cloud,
    };
    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/czechify-export-${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file;
  }

  Future<void> shareExport() async {
    final file = await createExportFile();
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Czechify data export',
        ),
      );
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> deleteAccountAndLocalData() async {
    if (_backend.isSignedIn) await _backend.deleteCloudAccount();
    await _db.clearLearnerData();
    await _backend.ensureAnonymousSession();
  }
}
