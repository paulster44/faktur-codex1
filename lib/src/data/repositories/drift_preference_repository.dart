import 'package:drift/drift.dart';

import '../../domain/entities/app_pref.dart' as model;
import '../../domain/repositories/preference_repository.dart';
import '../local/faktur_database.dart' as db;

/// Drift implementation of [PreferenceRepository].
class DriftPreferenceRepository implements PreferenceRepository {
  DriftPreferenceRepository(this._database);

  final db.FakturDatabase _database;

  @override
  Future<model.AppPreference?> findByKey(String key) async {
    final row = await (_database.select(_database.appPrefs)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return model.AppPreference(id: row.id, key: row.key, valueJson: row.valueJson);
  }

  @override
  Future<void> upsert(model.AppPreference preference) {
    final companion = db.AppPrefsCompanion(
      id: preference.id == 0 ? const Value.absent() : Value(preference.id),
      key: Value(preference.key),
      valueJson: Value(preference.valueJson),
    );
    return _database.into(_database.appPrefs).insertOnConflictUpdate(companion);
  }
}
