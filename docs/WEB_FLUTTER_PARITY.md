# Web-to-Flutter parity contract

## Authority and goal

The current default branch of `getbible/app.getbible.life`, its README/tests, and `https://app.getbible.life/` define product behavior. Flutter implements that behavior with native Flutter widgets and local platform services. Slight platform-appropriate differences are acceptable; missing workflows, altered persistence semantics, or generic branding are not.

## Shared concepts and ownership

| Product contract | Web authority | Flutter authority |
|---|---|---|
| GetBible API parsing | `lib/getbible.ts` | `lib/data/api/`, `lib/domain/models/bible.dart` |
| Hash/cache invalidation | `lib/cache.ts` | `CachedBibleRepository`, `LocalDatabase` |
| Reader restoration | `lib/reader-state.ts` | settings repository and `AppState` |
| Marking overlap/identity | `lib/markings.ts` | annotation models/repository |
| Canonical notes | `lib/notes.ts` | `VerseNote`, annotation repository |
| Search modes | `lib/search.ts` | search models/service |
| Markdown contract | `lib/markdown.ts` | `markdown_service.dart` |
| Daily Scripture | `lib/daily.ts` | API/cache models and application use case |
| Appearance | `lib/appearance.ts` | `ReaderPreferences` and presentation theme |
| UI localization | `lib/i18n.ts`, `public/locales/` | `assets/locales/` and Flutter localization service |
| Reader defaults/groups | `config/reader.ts` | `starter_marking_groups.dart` |

## Synchronization workflow

For every product change:

1. Identify the behavioral contract and persistence impact in both repositories.
2. Add or update shared JSON fixtures before implementation when serialization/API behavior changes.
3. Implement web and Flutter behavior without changing canonical note, marking, or backup rules.
4. Add equivalent unit tests plus platform-appropriate UI/integration tests.
5. Refresh locale packs when UI messages change; never translate Scripture or user labels.
6. Update this document and `FEATURE_PARITY.md` in the Flutter repository.
7. Compare the applications side by side on phone and desktop widths, light/dark, RTL, offline, and large text.

Synchronize the compact locale files from a sibling web checkout with:

```bash
dart run tool/sync_web_locales.dart ../app.getbible.life
flutter test test/localization_contract_test.dart
```

## Release gate

No Flutter release may be described as feature-equivalent while applicable rows in `FEATURE_PARITY.md` remain Partial. CI, build artifacts, and manual side-by-side QA are all required. External signing/store access is tracked separately and is not a reason to waive application parity.
