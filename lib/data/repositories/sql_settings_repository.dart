import 'dart:convert';

import '../../domain/models/cache.dart';
import '../../domain/models/preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/local_database.dart';

const String _preferencesKey = 'readerPreferences';
const String _lastReadingKey = 'lastReadingPosition';
const String _dailyKey = 'dailyScripture';

final class SqlSettingsRepository implements SettingsRepository {
  const SqlSettingsRepository(this._database);

  final LocalDatabase _database;

  @override
  Future<ReaderPreferences> getPreferences() async {
    final String? value = await _database.readSetting(_preferencesKey);
    return value == null
        ? const ReaderPreferences()
        : ReaderPreferences.fromJson(jsonDecode(value));
  }

  @override
  Future<void> savePreferences(ReaderPreferences preferences) =>
      _database.writeSetting(_preferencesKey, preferences.toJson());

  @override
  Future<LastReadingPosition?> getLastReadingPosition() async {
    final String? value = await _database.readSetting(_lastReadingKey);
    return value == null
        ? null
        : LastReadingPosition.fromJson(jsonDecode(value));
  }

  @override
  Future<void> saveLastReadingPosition(LastReadingPosition position) =>
      _database.writeSetting(_lastReadingKey, position.toJson());

  @override
  Future<DailyScriptureCache?> getDailyScripture() async {
    final String? value = await _database.readSetting(_dailyKey);
    return value == null
        ? null
        : DailyScriptureCache.fromJson(jsonDecode(value));
  }

  @override
  Future<void> saveDailyScripture(DailyScriptureCache daily) =>
      _database.writeSetting(_dailyKey, daily.toJson());

  @override
  Future<void> clearSettings() => _database.deleteSettings();
}
