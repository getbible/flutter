import 'package:flutter_test/flutter_test.dart';
import 'package:getbible_live/core/ui_strings.dart';

void main() {
  test('normalizes API locale aliases', () {
    expect(UiStrings.normalizeLocale('zh_CN'), 'zh-Hans');
    expect(UiStrings.normalizeLocale('zh-tw'), 'zh-Hant');
    expect(UiStrings.normalizeLocale('enm'), 'enm');
  });

  test('English messages and interpolation are stable', () {
    expect(UiStrings.english('previousChapter'), 'Previous chapter');
    expect(UiStrings.english('unknown'), 'unknown');
  });
}
