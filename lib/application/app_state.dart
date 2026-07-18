import 'package:flutter/foundation.dart';

import '../data/api/getbible_api_client.dart';
import '../data/database/local_database.dart';
import '../data/repositories/cached_bible_repository.dart';
import '../data/repositories/sql_annotation_repository.dart';
import '../data/repositories/sql_settings_repository.dart';
import '../domain/models/annotations.dart';
import '../domain/models/bible.dart';
import '../domain/models/cache.dart';
import '../domain/models/passage.dart';
import '../domain/models/preferences.dart';

export '../domain/models/preferences.dart' show AppearanceMode, ReaderLayout;

final class AppState extends ChangeNotifier {
  AppState._(this.database, this.bibles, this.annotations, this.settings);

  static Future<AppState> create() async {
    final LocalDatabase database = await LocalDatabase.open();
    final AppState state = AppState._(
      database,
      CachedBibleRepository(database, GetBibleApiClient()),
      SqlAnnotationRepository(database),
      SqlSettingsRepository(database),
    );
    await state.initialize();
    return state;
  }

  final LocalDatabase database;
  final CachedBibleRepository bibles;
  final SqlAnnotationRepository annotations;
  final SqlSettingsRepository settings;

  ReaderPreferences preferences = const ReaderPreferences();
  Passage passage = const Passage(translation: 'kjv', book: 49, chapter: 5);
  List<Translation> translations = const [];
  List<BibleBook> books = const [];
  BibleChapter? current;
  CacheFreshness? freshness;
  List<MarkingGroup> groups = const [];
  List<Marking> markings = const [];
  List<VerseNote> notes = const [];
  bool loading = true;
  String? error;

  Future<void> initialize() async {
    preferences = await settings.getPreferences();
    final LastReadingPosition? last = await settings.getLastReadingPosition();
    if (last != null) passage = last.passage;
    groups = await annotations.getGroups();
    await loadPassage(passage);
  }

  Future<void> loadPassage(Passage next) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final RepositoryResult<List<Translation>> translationResult = await bibles.getTranslations();
      translations = translationResult.data;
      final RepositoryResult<List<BibleBook>> bookResult = await bibles.getBooks(next.translation);
      books = bookResult.data;
      final RepositoryResult<BibleChapter> chapterResult = await bibles.getChapter(next.translation, next.book, next.chapter);
      passage = next;
      current = chapterResult.data;
      freshness = chapterResult.freshness;
      markings = await annotations.getMarkingsForPassage(next);
      notes = await annotations.getNotesForPassage(next);
      await settings.saveLastReadingPosition(LastReadingPosition(passage: next, verse: next.verse ?? 1, updatedAt: DateTime.now().toUtc()));
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setAppearance(AppearanceMode mode) async {
    preferences = preferences.copyWith(appearanceMode: mode);
    await settings.savePreferences(preferences);
    notifyListeners();
  }

  Future<void> setLayout(ReaderLayout layout) async {
    preferences = preferences.copyWith(layout: layout);
    await settings.savePreferences(preferences);
    notifyListeners();
  }

  Future<void> close() => database.close();
}
