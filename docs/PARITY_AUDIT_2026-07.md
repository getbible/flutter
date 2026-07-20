# Web-to-Flutter parity audit (20 July 2026)

## Authority inspected

- `getbible/app.getbible.life` default branch at
  `aa3df41b8c419cdcffc930977732a7f30d7bcfba` (the current default branch is
  still the Version 27 baseline).
- The maintainer-supplied desktop screenshot of `app.getbible.life`.
- The web README, 36 passing source tests, `app/page.tsx`, `app/globals.css`,
  `config/reader.ts`, and all modules under `lib/`.
- `getbible/mcp` default branch at `c5dc435` for the newer defensive cache and
  SHA consistency contract.

The previous Flutter repository was a thin reader foundation, not a parity
implementation. In particular, it had no working search surface, Study panel,
contextual annotation workflow, inline note editor, cross-book navigation, or
web-aligned responsive shell. This audit is the correction contract.

## Exact behavior contract

### Shell and chapter navigation

Desktop uses a compact sticky header with menu, daily-home brand, live search,
centered passage reference, previous/next controls, Markdown control, and Study
button. At 720 logical pixels and below, desktop reference/arrows collapse and
a persistent Previous/current/Next navigation row is used.

All navigation routes through one boundary-aware chapter turn operation. It
crosses book boundaries, supports horizontal swipe over 70 logical pixels and
keyboard navigation, and deliberately requires a second outward gesture at a
scroll boundary. Top tolerance is 1 pixel, bottom tolerance is 2 pixels, wheel
gestures are separated by a 180 ms idle interval, and matching intent expires
after 2200 ms. A loading reader or open modal/drawer must suppress a turn.

### Scripture annotations and Study tools

The Study surface contains Markings and Notes tabs. It exposes all 60 starter
groups in their source order, searchable group selection, group management,
Bible-order saved markings, Bible-order notes, backup/reset actions, and
passage navigation.

Whole-verse markings are canonical book/chapter/verse data and therefore
appear across translations. Recoloring replaces the existing whole-verse
marking. Text markings use translation plus end-exclusive character offsets.
Overlapping text segments render deterministically with the newest applicable
marking winning. Removing a selected overlap deletes only overlapping ranged
records; whole-verse, other-translation, other-verse, and non-overlapping
records survive.

The contextual toolbar anchors to the verse row or native text range, prefers
12 pixels above, flips below if necessary, clamps to 10-pixel viewport edges,
reserves 58 pixels on mobile, follows scrolling/resizing, and closes with
Escape. It offers the active group, more groups, remove, note, and close.

Notes are one per canonical verse and appear across translations. The editor
opens inline directly beneath Scripture, preserves `createdAt`, advances
`updatedAt`, supports multiline input and Ctrl/Cmd+Enter, and folds back into a
compact saved note.

### Search

Search is limited to the active translation and starts the deliberate
`/v2/{translation}.json` corpus download only after query input. Modes are:

- all words, any word, or exact phrase;
- exact-token or partial-token matching;
- case-sensitive or locale-aware case-insensitive matching;
- whole Bible, Old Testament, New Testament, or a dynamically discovered
  individual book.

Text is NFC-normalized and split with Unicode-aware word boundaries. Results
remain in Bible order, arrive in 20-result pages, scan at most 400 verses per
cooperative slice, cancel stale searches, and load progressively near the end.
Opening a result centers its verse and emphasizes all matching text for seven
seconds, without forced animation under reduced-motion settings.

### API, cache, and daily Scripture

Translations, books, chapters, and verses are dynamically discovered. Indexes
are refreshed weekly and embedded child hashes invalidate the narrowest cache
prefix. Every opened chapter is checked against its `.sha`; valid last-known
Scripture remains readable when verification is offline and is visibly marked
SAVED rather than VERIFIED.

Flutter must additionally adopt the MCP implementation's stronger consistency
sequence: fetch SHA, download and fully validate JSON, fetch SHA again, retry
once if the hashes differ, then atomically activate the new value. A malformed,
partial, changed-during-download, or storage-failed response must never replace
last-known-good data. Full search corpora are keyed by translation abbreviation
and translation SHA.

Daily Scripture is cached by the current local date, resolves aliases safely,
and opens in KJV. Explicit deep links win over restored position; restored
position wins over daily behavior. The home brand action always invokes the
current daily-Scripture behavior.

### Appearance and localization

Light palettes are Pure white, Warm paper, Soft ivory, and Cool mist. Dark
palettes are Pure black, Warm brown, Soft charcoal, and Midnight blue. Reading
fonts are Classic serif, Book serif, Baskerville, Garamond, Charter, Cambria,
Times New Roman, Clean sans, and System sans. System/manual appearance,
line/paragraph layouts, full/page width, text size, RTL, large text, keyboard,
screen reader, reduced motion, and safe areas are all release gates.

## Verification gate

No row may be called equivalent merely because its data model or service
exists. Completion requires the native UI, persistence semantics, localization,
accessibility, regression tests, a green Flutter CI build, and documented
side-by-side manual verification. Store signing and physical-device checks are
tracked separately and cannot be represented as completed in CI.
