# Local data and backup contracts

SQLite stores cache entries, marking groups, markings, notes, and settings. Reader preferences, last position, and daily Scripture are versioned JSON values in settings.

## Identity rules

- Notes: canonical book/chapter/verse; visible across translations.
- Whole-verse markings: canonical book/chapter/verse; visible across translations.
- Selected text: translation + book/chapter/verse + character range.
- Groups: stable string IDs; imported collisions must not overwrite distinct groups.

## Backup import

`BackupData` accepts website-compatible schema versions 1 and 2. The `colors`, `markings`, and optional `notes` arrays are validated before mutation. Imports merge by semantic identity, keep the newer note on canonical conflicts, and create safe IDs when unrelated records collide.

Export emits schema version 2 and website-compatible `value`/`colorId` fields. Flutter-only preferences are additive and may be ignored by the website.

The historical on-device database identifier remains `getbible_life` so an application-name or repository rename never strands existing local reader data.

## Migration procedure

1. Increment the database schema version.
2. Add forward-only transactional SQL.
3. Add a fixture representing every prior schema.
4. Verify data and cache survival after migration.
5. Update this document and the release notes.
