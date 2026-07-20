import 'package:flutter_test/flutter_test.dart';
import 'package:getbible_live/services/daily_scripture_service.dart';

void main() {
  test('parses website daily aliases and deliberately opens KJV', () {
    final daily = parseDailyScripture(<String, Object?>{
      'date': 'Monday 20-July, 2026',
      'getbible': 'https://getbible.life/KJV/Ephesians/5/2',
      'name': 'Ephesians 5:2',
      'scripture': <Object?>[
        <String, Object?>{'nr': 2, 'text': 'Test'},
      ],
    }, DateTime.utc(2026, 7, 20));

    expect(daily.translation, 'kjv');
    expect(daily.bookName, 'Ephesians');
    expect(daily.chapter, 5);
    expect(daily.verse, 2);
    expect(daily.isCurrent(DateTime(2026, 7, 20)), isTrue);
  });
}
