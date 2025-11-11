import 'package:drift/drift.dart';

import '../../domain/entities/app_pref.dart';
import '../../domain/repositories/preference_repository.dart';
import '../local/faktur_database.dart';

/// Drift implementation of [PreferenceRepository].
class DriftPreferenceRepository implements PreferenceRepository {
  DriftPreferenceRepository(this._database);

  final FakturDatabase _database;

  @override
  Future<AppPreference?> findByKey(String key) async {
    final row = await (_database.select(_database.appPrefs)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return AppPreference(id: row.id, key: row.key, valueJson: row.valueJson);
  }

  @override
  Future<void> upsert(AppPreference preference) {
    final companion = AppPrefsCompanion(
      id: preference.id == 0 ? const Value.absent() : Value(preference.id),
      key: Value(preference.key),
      valueJson: Value(preference.valueJson),
    );
    return _database.into(_database.appPrefs).insertOnConflictUpdate(companion);
  }
}
