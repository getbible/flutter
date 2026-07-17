import '../models/bible.dart';
import '../models/cache.dart';

abstract interface class BibleRepository {
  Future<RepositoryResult<List<Translation>>> getTranslations({
    bool forceRefresh = false,
  });
  Future<RepositoryResult<List<BibleBook>>> getBooks(
    String translation, {
    bool forceRefresh = false,
  });
  Future<RepositoryResult<List<ChapterInfo>>> getChapters(
    String translation,
    int book, {
    bool forceRefresh = false,
  });
  Future<RepositoryResult<BibleChapter>> getChapter(
    String translation,
    int book,
    int chapter,
  );
  Future<RepositoryResult<WholeTranslation>> getWholeTranslation(
    Translation translation,
  );
  Future<void> clearScriptureCache();
}
