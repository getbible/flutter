import '../../core/json.dart';

enum SearchWordMode { all, any, phrase }

enum SearchMatchMode { partial, exact }

enum SearchScopeType { all, oldTestament, newTestament, book }

final class SearchScope {
  const SearchScope.all() : type = SearchScopeType.all, book = null;
  const SearchScope.oldTestament()
    : type = SearchScopeType.oldTestament,
      book = null;
  const SearchScope.newTestament()
    : type = SearchScopeType.newTestament,
      book = null;
  const SearchScope.book(this.book) : type = SearchScopeType.book;

  factory SearchScope.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'search scope');
    final SearchScopeType type = SearchScopeType.values.firstWhere(
      (SearchScopeType item) => item.name == requireString(json, 'type'),
      orElse: () => SearchScopeType.all,
    );
    return switch (type) {
      SearchScopeType.all => const SearchScope.all(),
      SearchScopeType.oldTestament => const SearchScope.oldTestament(),
      SearchScopeType.newTestament => const SearchScope.newTestament(),
      SearchScopeType.book => SearchScope.book(requireInt(json, 'book')),
    };
  }

  final SearchScopeType type;
  final int? book;

  bool includes(int bookNumber) => switch (type) {
    SearchScopeType.all => true,
    SearchScopeType.oldTestament => bookNumber <= 39,
    SearchScopeType.newTestament => bookNumber > 39,
    SearchScopeType.book => bookNumber == book,
  };

  JsonMap toJson() => <String, Object?>{'type': type.name, 'book': book};

  @override
  bool operator ==(Object other) =>
      other is SearchScope && other.type == type && other.book == book;

  @override
  int get hashCode => Object.hash(type, book);
}

final class SearchOptions {
  const SearchOptions({
    this.words = SearchWordMode.all,
    this.match = SearchMatchMode.partial,
    this.caseSensitive = false,
    this.scope = const SearchScope.all(),
    this.locale = 'und',
  });

  factory SearchOptions.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'search options');
    return SearchOptions(
      words: SearchWordMode.values.firstWhere(
        (SearchWordMode item) => item.name == requireString(json, 'words'),
      ),
      match: SearchMatchMode.values.firstWhere(
        (SearchMatchMode item) => item.name == requireString(json, 'match'),
      ),
      caseSensitive: optionalBool(json, 'caseSensitive'),
      scope: SearchScope.fromJson(json['scope']),
      locale: optionalString(json, 'locale', 'und'),
    );
  }

  final SearchWordMode words;
  final SearchMatchMode match;
  final bool caseSensitive;
  final SearchScope scope;
  final String locale;

  JsonMap toJson() => <String, Object?>{
    'words': words.name,
    'match': match.name,
    'caseSensitive': caseSensitive,
    'scope': scope.toJson(),
    'locale': locale,
  };
}

final class SearchVerse {
  const SearchVerse({
    required this.book,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.reference,
    required this.text,
  });

  factory SearchVerse.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'search verse');
    return SearchVerse(
      book: requireInt(json, 'book'),
      bookName: requireString(json, 'bookName'),
      chapter: requireInt(json, 'chapter'),
      verse: requireInt(json, 'verse'),
      reference: requireString(json, 'reference'),
      text: requireString(json, 'text'),
    );
  }

  final int book;
  final String bookName;
  final int chapter;
  final int verse;
  final String reference;
  final String text;

  JsonMap toJson() => <String, Object?>{
    'book': book,
    'bookName': bookName,
    'chapter': chapter,
    'verse': verse,
    'reference': reference,
    'text': text,
  };
}

final class SearchPage {
  const SearchPage({
    required this.results,
    required this.nextCursor,
    required this.complete,
  });

  final List<SearchVerse> results;
  final int nextCursor;
  final bool complete;
}

final class HighlightSegment {
  const HighlightSegment(this.text, {required this.highlighted});

  final String text;
  final bool highlighted;
}
