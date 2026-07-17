import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/errors.dart';
import '../../core/json.dart';
import '../../domain/models/bible.dart';

const String getBibleApiRoot = 'https://api.getbible.net/v2';
const String dailyScriptureUrl =
    'https://raw.githubusercontent.com/trueChristian/daily-scripture/refs/heads/master/README.json';

final class GetBibleApiClient {
  GetBibleApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  Future<List<Translation>> getTranslations() async {
    final JsonMap json = await _getJsonMap(
      '$getBibleApiRoot/translations.json',
    );
    final List<Translation> result = json.values
        .map(Translation.fromJson)
        .toList();
    _requireItems(result, 'translations');
    result.sort((Translation left, Translation right) {
      final int language = left.resolvedLanguage.compareTo(
        right.resolvedLanguage,
      );
      return language != 0
          ? language
          : left.translation.compareTo(right.translation);
    });
    return result;
  }

  Future<List<BibleBook>> getBooks(String translation) async {
    final JsonMap json = await _getJsonMap(
      '$getBibleApiRoot/$translation/books.json',
    );
    final List<BibleBook> result = sortedNumericValues(
      json,
      BibleBook.fromJson,
    );
    _requireItems(result, 'books');
    return result;
  }

  Future<List<ChapterInfo>> getChapters(String translation, int book) async {
    final JsonMap json = await _getJsonMap(
      '$getBibleApiRoot/$translation/$book/chapters.json',
    );
    final List<ChapterInfo> result = sortedNumericValues(
      json,
      ChapterInfo.fromJson,
    );
    _requireItems(result, 'chapters');
    return result;
  }

  Future<BibleChapter> getChapter(
    String translation,
    int book,
    int chapter,
  ) async {
    final JsonMap json = await _getJsonMap(
      '$getBibleApiRoot/$translation/$book/$chapter.json',
    );
    final BibleChapter result = BibleChapter.fromJson(json);
    _requireItems(result.verses, 'verses');
    return result;
  }

  Future<String> getChapterSha(
    String translation,
    int book,
    int chapter,
  ) async {
    final String sha = (await _getText(
      '$getBibleApiRoot/$translation/$book/$chapter.sha',
    )).trim();
    if (!RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(sha)) {
      throw const ApiFormatException(
        'The GetBible API returned an invalid chapter hash.',
      );
    }
    return sha.toLowerCase();
  }

  Future<WholeTranslation> getWholeTranslation(String translation) async {
    final JsonMap json = await _getJsonMap(
      '$getBibleApiRoot/$translation.json',
    );
    final WholeTranslation result = WholeTranslation.fromJson(json);
    _requireItems(result.books, 'translation books');
    return result;
  }

  Future<JsonMap> getDailyScripture() => _getJsonMap(dailyScriptureUrl);

  Future<JsonMap> _getJsonMap(String url) async {
    final String body = await _getText(url, accept: 'application/json');
    try {
      return requireJsonMap(jsonDecode(body), 'GetBible response');
    } on FormatException catch (error) {
      throw ApiFormatException(
        'The GetBible API returned malformed JSON.',
        error,
      );
    }
  }

  Future<String> _getText(String url, {String accept = 'text/plain'}) async {
    try {
      final http.Response response = await _client
          .get(Uri.parse(url), headers: <String, String>{'accept': accept})
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw NetworkException(
          'GetBible returned HTTP ${response.statusCode}.',
        );
      }
      return utf8.decode(response.bodyBytes, allowMalformed: false);
    } on TimeoutException catch (error) {
      throw NetworkException('The GetBible request timed out.', error);
    } on http.ClientException catch (error) {
      throw NetworkException('The GetBible service is unavailable.', error);
    } on FormatException catch (error) {
      throw ApiFormatException(
        'The GetBible response is not valid UTF-8.',
        error,
      );
    }
  }

  void close() => _client.close();

  void _requireItems(List<Object?> values, String resource) {
    if (values.isEmpty) {
      throw ApiFormatException('The GetBible API returned no $resource.');
    }
  }
}
