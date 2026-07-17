import '../models/cache.dart';
import '../models/preferences.dart';

abstract interface class SettingsRepository {
  Future<ReaderPreferences> getPreferences();
  Future<void> savePreferences(ReaderPreferences preferences);
  Future<LastReadingPosition?> getLastReadingPosition();
  Future<void> saveLastReadingPosition(LastReadingPosition position);
  Future<DailyScriptureCache?> getDailyScripture();
  Future<void> saveDailyScripture(DailyScriptureCache daily);
  Future<void> clearSettings();
}
