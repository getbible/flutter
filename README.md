# getBible.Life Mobile

Native Flutter client for [getBible.Life](https://app.getbible.life), designed for Android and iOS with compatible Flutter desktop and web targets. Scripture comes from GetBible API v2; reader data remains on the device. The primary reader is native Flutter and does not use a WebView.

> Development status: the repository contains the native foundation, typed domain model, API client, SQLite persistence, cache verification, reader shell, search/backup/Markdown services, tests, and CI. Store publication still requires complete feature-parity verification, physical-device QA, signing identities, and store-console access. See [feature parity](docs/FEATURE_PARITY.md).

## Requirements

- Flutter stable 3.44.6 or newer
- Dart 3.12.2 or newer
- Android Studio/SDK for Android builds
- macOS with Xcode for iOS builds

## Start developing

```bash
flutter doctor -v
flutter pub get
flutter run
```

The application ID and iOS bundle ID are `life.getbible.mobile`. No API key is required for the public GetBible API.

## Quality checks

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

CI runs the same checks and uploads an unsigned debug APK. Consult [testing](docs/TESTING.md) before merging reader, storage, backup, or cache changes.

## Release builds

Android:

```bash
flutter build apk --release
flutter build appbundle --release
```

iOS, on macOS:

```bash
flutter build ios --release --no-codesign
```

Signing keys and provisioning profiles must never be committed. Complete instructions are in [deployment and distribution](docs/DEPLOYMENT.md).

## Architecture

The code is divided into domain models/contracts, data adapters, application state, services, and presentation. SQLite is accessed through Drift's executor; network responses are parsed into strongly typed immutable models. Opened chapters are cached, their SHA endpoints are checked, and usable cached Scripture remains available when verification cannot reach the network.

```text
lib/
  application/       lifecycle and reader state
  core/              errors, JSON validation, starter groups
  data/api/          GetBible API v2 client
  data/database/     local SQLite schema and platform executors
  data/repositories/ cache and persistence implementations
  domain/models/     versioned data contracts
  domain/repositories/abstract persistence contracts
  presentation/      native Flutter reader UI
  services/          backup, search, Markdown
```

See [architecture](docs/ARCHITECTURE.md) and [data contracts](docs/DATA_AND_BACKUPS.md).

## Privacy

Notes, markings, preferences, cached Scripture, and reading position are stored locally. The app has no accounts, advertising, analytics, or tracking. Network traffic is limited to resources required for Scripture and daily-passage retrieval. See [privacy policy draft](docs/PRIVACY.md).

## Documentation index

- [Agent operating guide](AGENTS.md)
- [Architecture](docs/ARCHITECTURE.md)
- [API and cache workflow](docs/API_AND_CACHE.md)
- [Data and backup compatibility](docs/DATA_AND_BACKUPS.md)
- [Feature-parity ledger](docs/FEATURE_PARITY.md)
- [Testing and QA](docs/TESTING.md)
- [Deployment and distribution](docs/DEPLOYMENT.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Privacy policy draft](docs/PRIVACY.md)

## License

The existing repository license is retained in [LICENSE](LICENSE). Scripture translations remain subject to the license and copyright metadata returned by GetBible API v2; the application license does not relicense translation content.
