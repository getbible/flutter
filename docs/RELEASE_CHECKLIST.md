# Release checklist

- [ ] Feature-parity ledger has no unexplained Partial mobile requirements.
- [ ] Formatting, analysis, unit, widget, migration, and integration tests pass.
- [ ] Dependency/license review is current; no secrets or signing files are tracked.
- [ ] API failure, malformed response, offline cache, and changed-hash behavior verified.
- [ ] Backup fixtures import and round-trip without duplicates/data loss.
- [ ] Android release APK/AAB build and install on phone/tablet.
- [ ] Unsigned iOS release builds; signed archive installs through TestFlight.
- [ ] Package IDs, display name, icons, splash, permissions, and deep links verified.
- [ ] RTL, screen reader, keyboard, reduced motion, contrast, and large text checked.
- [ ] Small/large screens, rotation, suspension, and process restoration checked.
- [ ] Privacy, store listing, screenshots, content rating, and translation attribution approved.
- [ ] Version/build numbers and release notes updated; tag points to green CI.

## Store publication checklist

- [ ] Play Data Safety and App Store privacy answers match local-first behavior.
- [ ] Support URL, privacy URL, category, age rating, descriptions, and screenshots supplied.
- [ ] Internal/TestFlight feedback resolved.
- [ ] Staged rollout and rollback owner identified.
