# Testing and manual QA

## Interactive platform testing

Run `flutter devices` to list available targets. Use `flutter run -d chrome` for the quickest browser test, or `flutter run -d <device-id>` for a connected phone, emulator, simulator, or desktop target. A successful GitHub Actions run exposes Android APK and web-build artifacts from its summary page.

pub.dev distributes Dart/Flutter libraries; it does not host or execute this application. Browser previews should use a locally served web build or an explicitly configured GitHub Pages deployment. Mobile prereleases should use Android APK/Play internal testing and iOS TestFlight.

## Automated

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```

Required suites cover serialization, API parsing, passage links, expiry/hash invalidation, offline fallback, Unicode/RTL search, marking overlap removal, annotation translation rules, note merge/order, backup fixtures, migrations, reader widgets, toolbar positioning, inline notes, and accessibility semantics.

The cached-Scripture status regression suite renders both verified and
unverified offline states in a narrow viewport at 200% text scaling. This
guards the web and small-screen reader against assertion failures and layout
overflow before an offline-cache change is merged.

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

## Side-by-side parity review

Before a release, run the Flutter app beside `https://app.getbible.life/` using equivalent viewport sizes and the same passage. Compare navigation, daily Scripture, typography/layout, themes, toolbar anchoring, marking and note behavior, search results, Markdown, translation metadata, offline indicators, localization, RTL, restoration, and destructive confirmations. Record every material difference in `FEATURE_PARITY.md`; do not normalize a missing Flutter workflow as a platform difference.

Visually inspect the launcher, splash, task-switcher/window icon, browser favicon/PWA icon, and in-app wordmark on light and dark system surfaces. `sha256sum -c assets/branding/BRAND_ASSETS.sha256` must pass before testing release artifacts.

Do not declare physical-device behavior verified from widget tests alone.
