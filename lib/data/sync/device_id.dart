import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// A stable, per-install device identifier used as the last-write-wins
/// tiebreaker. Generated once and persisted in secure storage; survives app
/// restarts but is intentionally reset on reinstall (it identifies an install,
/// not a user).
class DeviceId {
  DeviceId(this._storage);

  static const _key = 'sync_device_id';
  final FlutterSecureStorage _storage;
  String? _cached;

  Future<String> get() async {
    if (_cached != null) return _cached!;
    var id = await _storage.read(key: _key);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      await _storage.write(key: _key, value: id);
    }
    _cached = id;
    return id;
  }
}
