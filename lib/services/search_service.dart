import 'dart:async';
import 'dart:isolate';

import '../domain/models/bible.dart';
import '../domain/models/search.dart';

Future<List<SearchVerse>> searchTranslation(WholeTranslation corpus, String query, SearchOptions options) {
  return Isolate.run(() => _search(corpus, query, options));
}

List<SearchVerse> _search(WholeTranslation corpus, String query, SearchOptions options) {
  final String needle = options.caseSensitive ? query : query.toLowerCase();
  if (needle.trim().isEmpty) return const <SearchVerse>[];
  final List<String> terms = needle.trim().split(RegExp(r'\s+'));
  final List<SearchVerse> result = <SearchVerse>[];
  for (final WholeTranslationBook book in corpus.books) {
    if (!options.scope.includes(book.number)) continue;
    for (final WholeTranslationChapter chapter in book.chapters) {
      for (final Verse verse in chapter.verses) {
        final String text = options.caseSensitive ? verse.text : verse.text.toLowerCase();
        final bool matches = switch (options.words) {
          SearchWordMode.phrase => text.contains(needle),
          SearchWordMode.all => terms.every(text.contains),
          SearchWordMode.any => terms.any(text.contains),
        };
        if (matches) result.add(SearchVerse(book: book.number, bookName: book.name, chapter: chapter.chapter, verse: verse.verse, reference: '${book.name} ${chapter.chapter}:${verse.verse}', text: verse.text));
      }
    }
  }
  return result;
}
