import '../../core/json.dart';

const int bibleModelVersion = 1;

final class Translation {
  const Translation({
    required this.translation,
    required this.abbreviation,
    required this.lang,
    required this.language,
    required this.direction,
    required this.sha,
    this.description = '',
    this.encoding = '',
    this.distributionLcsh = '',
    this.distributionVersion = '',
    this.distributionVersionDate = '',
    this.distributionAbbreviation = '',
    this.distributionAbout = '',
    this.distributionLicense = '',
    this.distributionSourceType = '',
    this.distributionSource = '',
    this.distributionVersification = '',
    this.distributionHistory = const <String, String>{},
    this.url = '',
    this.extra = const <String, Object?>{},
  });

  factory Translation.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'translation');
    const Set<String> known = <String>{
      'translation',
      'abbreviation',
      'description',
      'lang',
      'language',
      'direction',
      'encoding',
      'distribution_lcsh',
      'distribution_version',
      'distribution_version_date',
      'distribution_abbreviation',
      'distribution_about',
      'distribution_license',
      'distribution_sourcetype',
      'distribution_source',
      'distribution_versification',
      'distribution_history',
      'url',
      'sha',
      'modelVersion',
    };
    return Translation(
      translation: requireString(json, 'translation'),
      abbreviation: requireString(json, 'abbreviation').toLowerCase(),
      description: optionalString(json, 'description'),
      lang: optionalString(json, 'lang', 'en'),
      language: optionalString(json, 'language'),
      direction: optionalString(json, 'direction', 'LTR'),
      encoding: optionalString(json, 'encoding'),
      distributionLcsh: optionalString(json, 'distribution_lcsh'),
      distributionVersion: optionalString(json, 'distribution_version'),
      distributionVersionDate: optionalString(
        json,
        'distribution_version_date',
      ),
      distributionAbbreviation: optionalString(
        json,
        'distribution_abbreviation',
      ),
      distributionAbout: optionalString(json, 'distribution_about'),
      distributionLicense: optionalString(json, 'distribution_license'),
      distributionSourceType: optionalString(json, 'distribution_sourcetype'),
      distributionSource: optionalString(json, 'distribution_source'),
      distributionVersification: optionalString(
        json,
        'distribution_versification',
      ),
      distributionHistory: stringMap(json['distribution_history']),
      url: optionalString(json, 'url'),
      sha: requireString(json, 'sha'),
      extra: Map<String, Object?>.fromEntries(
        json.entries.where(
          (MapEntry<String, Object?> item) => !known.contains(item.key),
        ),
      ),
    );
  }

  final String translation;
  final String abbreviation;
  final String description;
  final String lang;
  final String language;
  final String direction;
  final String encoding;
  final String distributionLcsh;
  final String distributionVersion;
  final String distributionVersionDate;
  final String distributionAbbreviation;
  final String distributionAbout;
  final String distributionLicense;
  final String distributionSourceType;
  final String distributionSource;
  final String distributionVersification;
  final Map<String, String> distributionHistory;
  final String url;
  final String sha;
  final Map<String, Object?> extra;

  bool get isRtl => direction.toUpperCase() == 'RTL';
  String get resolvedLanguage =>
      language.trim().isEmpty ? lang.toUpperCase() : language.trim();

  JsonMap toJson() => <String, Object?>{
    ...extra,
    'modelVersion': bibleModelVersion,
    'translation': translation,
    'abbreviation': abbreviation,
    'description': description,
    'lang': lang,
    'language': language,
    'direction': direction,
    'encoding': encoding,
    'distribution_lcsh': distributionLcsh,
    'distribution_version': distributionVersion,
    'distribution_version_date': distributionVersionDate,
    'distribution_abbreviation': distributionAbbreviation,
    'distribution_about': distributionAbout,
    'distribution_license': distributionLicense,
    'distribution_sourcetype': distributionSourceType,
    'distribution_source': distributionSource,
    'distribution_versification': distributionVersification,
    'distribution_history': distributionHistory,
    'url': url,
    'sha': sha,
  };
}

final class BibleBook {
  const BibleBook({
    required this.number,
    required this.name,
    required this.sha,
    this.direction = 'LTR',
  });

  factory BibleBook.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'book');
    return BibleBook(
      number: requireInt(json, 'nr'),
      name: requireString(json, 'name'),
      sha: requireString(json, 'sha'),
      direction: optionalString(json, 'direction', 'LTR'),
    );
  }

  final int number;
  final String name;
  final String sha;
  final String direction;

  bool get isRtl => direction.toUpperCase() == 'RTL';

  JsonMap toJson() => <String, Object?>{
    'modelVersion': bibleModelVersion,
    'nr': number,
    'name': name,
    'sha': sha,
    'direction': direction,
  };
}

final class ChapterInfo {
  const ChapterInfo({
    required this.chapter,
    required this.name,
    required this.sha,
  });

  factory ChapterInfo.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'chapter index');
    return ChapterInfo(
      chapter: requireInt(json, 'chapter'),
      name: requireString(json, 'name'),
      sha: requireString(json, 'sha'),
    );
  }

  final int chapter;
  final String name;
  final String sha;

  JsonMap toJson() => <String, Object?>{
    'modelVersion': bibleModelVersion,
    'chapter': chapter,
    'name': name,
    'sha': sha,
  };
}

final class Verse {
  const Verse({
    required this.chapter,
    required this.verse,
    required this.name,
    required this.text,
  });

  factory Verse.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'verse');
    return Verse(
      chapter: requireInt(json, 'chapter'),
      verse: requireInt(json, 'verse'),
      name: optionalString(json, 'name'),
      text: requireString(json, 'text'),
    );
  }

  final int chapter;
  final int verse;
  final String name;
  final String text;

  JsonMap toJson() => <String, Object?>{
    'modelVersion': bibleModelVersion,
    'chapter': chapter,
    'verse': verse,
    'name': name,
    'text': text,
  };
}

final class BibleChapter {
  const BibleChapter({
    required this.translation,
    required this.abbreviation,
    required this.language,
    required this.direction,
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    required this.name,
    required this.verses,
  });

  factory BibleChapter.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'chapter');
    return BibleChapter(
      translation: optionalString(json, 'translation'),
      abbreviation: requireString(json, 'abbreviation').toLowerCase(),
      language: optionalString(json, 'language'),
      direction: optionalString(json, 'direction', 'LTR'),
      bookNumber: requireInt(json, 'book_nr'),
      bookName: requireString(json, 'book_name'),
      chapter: requireInt(json, 'chapter'),
      name: requireString(json, 'name'),
      verses: requireJsonList(
        json['verses'],
        'chapter verses',
      ).map(Verse.fromJson).toList(growable: false),
    );
  }

  final String translation;
  final String abbreviation;
  final String language;
  final String direction;
  final int bookNumber;
  final String bookName;
  final int chapter;
  final String name;
  final List<Verse> verses;

  bool get isRtl => direction.toUpperCase() == 'RTL';

  JsonMap toJson() => <String, Object?>{
    'modelVersion': bibleModelVersion,
    'translation': translation,
    'abbreviation': abbreviation,
    'language': language,
    'direction': direction,
    'book_nr': bookNumber,
    'book_name': bookName,
    'chapter': chapter,
    'name': name,
    'verses': verses.map((Verse item) => item.toJson()).toList(),
  };
}

final class WholeTranslation {
  const WholeTranslation({
    required this.translation,
    required this.abbreviation,
    required this.language,
    required this.lang,
    required this.direction,
    required this.books,
  });

  factory WholeTranslation.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'whole translation');
    return WholeTranslation(
      translation: requireString(json, 'translation'),
      abbreviation: requireString(json, 'abbreviation').toLowerCase(),
      language: optionalString(json, 'language'),
      lang: optionalString(json, 'lang', 'en'),
      direction: optionalString(json, 'direction', 'LTR'),
      books: requireJsonList(
        json['books'],
        'whole translation books',
      ).map(WholeTranslationBook.fromJson).toList(growable: false),
    );
  }

  final String translation;
  final String abbreviation;
  final String language;
  final String lang;
  final String direction;
  final List<WholeTranslationBook> books;

  JsonMap toJson() => <String, Object?>{
    'modelVersion': bibleModelVersion,
    'translation': translation,
    'abbreviation': abbreviation,
    'language': language,
    'lang': lang,
    'direction': direction,
    'books': books.map((WholeTranslationBook item) => item.toJson()).toList(),
  };
}

final class WholeTranslationBook {
  const WholeTranslationBook({
    required this.number,
    required this.name,
    required this.chapters,
  });

  factory WholeTranslationBook.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'whole translation book');
    return WholeTranslationBook(
      number: requireInt(json, 'nr'),
      name: requireString(json, 'name'),
      chapters: requireJsonList(
        json['chapters'],
        'whole translation chapters',
      ).map(WholeTranslationChapter.fromJson).toList(growable: false),
    );
  }

  final int number;
  final String name;
  final List<WholeTranslationChapter> chapters;

  JsonMap toJson() => <String, Object?>{
    'nr': number,
    'name': name,
    'chapters': chapters
        .map((WholeTranslationChapter item) => item.toJson())
        .toList(),
  };
}

final class WholeTranslationChapter {
  const WholeTranslationChapter({
    required this.chapter,
    required this.name,
    required this.verses,
  });

  factory WholeTranslationChapter.fromJson(Object? value) {
    final JsonMap json = requireJsonMap(value, 'whole translation chapter');
    return WholeTranslationChapter(
      chapter: requireInt(json, 'chapter'),
      name: requireString(json, 'name'),
      verses: requireJsonList(
        json['verses'],
        'whole translation verses',
      ).map(Verse.fromJson).toList(growable: false),
    );
  }

  final int chapter;
  final String name;
  final List<Verse> verses;

  JsonMap toJson() => <String, Object?>{
    'chapter': chapter,
    'name': name,
    'verses': verses.map((Verse item) => item.toJson()).toList(),
  };
}
