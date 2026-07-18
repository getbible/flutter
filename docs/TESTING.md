# Testing and manual QA

## Automated

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```

Required suites cover serialization, API parsing, passage links, expiry/hash invalidation, offline fallback, Unicode/RTL search, marking overlap removal, annotation translation rules, note merge/order, backup fixtures, migrations, reader widgets, toolbar positioning, inline notes, and accessibility semantics.

## Primary manual journeys

1. Clean install opens daily/KJV behavior and changes translation.
2. Navigate books, chapters, previous/next boundaries, and swipe.
3. Restart and restore the last visible verse.
4. Open a cached chapter with networking disabled.
5. Mark/remove selected text and whole verses across translations.
6. Add/edit/delete an inline note.
7. Download/search a translation and open a highlighted result.
8. Export, clear data, import, and verify conflict rules.
9. Switch to RTL Scripture and exercise selection/navigation.
10. Test phone/tablet, portrait/landscape, dark/light, 200% text, keyboard, and screen reader.

Do not declare physical-device behavior verified from widget tests alone.
