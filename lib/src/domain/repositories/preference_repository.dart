import '../entities/app_pref.dart';

/// Repository contract for app preferences.
abstract class PreferenceRepository {
  Future<AppPreference?> findByKey(String key);
  Future<void> upsert(AppPreference preference);
}
