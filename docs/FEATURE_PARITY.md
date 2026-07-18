# Feature-parity ledger

Status meanings: **Implemented** exists in source; **Partial** needs remaining UX/integration work; **Pending verification** requires platform/device confirmation.

| Area | Status | Implementation / remaining gate |
|---|---|---|
| Typed API v2 and dynamic indexes | Implemented | `GetBibleApiClient`, `CachedBibleRepository` |
| SQLite notes/markings/preferences/cache | Implemented | `LocalDatabase` and SQL repositories |
| SHA verification and offline chapter fallback | Implemented | Three freshness states shown by reader |
| Native line/paragraph reader | Implemented | `ReaderScreen`; no WebView |
| Translation/book/chapter selection | Implemented | Dynamic selectors |
| Last passage persistence | Implemented | Exact verse restoration/centering needs expanded widget integration |
| Swipe and cross-book navigation | Partial | Add gesture thresholds and chapter-boundary resolution |
| Deep links/shareable links | Partial | Parser exists; GoRouter/platform association needs integration tests |
| RTL and appearance modes | Implemented | Device selection behavior still requires QA |
| Contextual selection toolbar | Partial | Native selectable text exists; anchored marking/note actions remain |
| Whole/text markings and overlap rules | Partial | Models/database/merge rules exist; complete reader overlays and editor remain |
| Inline notes | Partial | Persistence exists; inline editor widget remains |
| Search modes and isolate execution | Partial | Corpus search service exists; paging/highlight/search screen remain |
| Website-compatible backups | Implemented core | Model validation/merge exists; native file picker/share UI remains |
| Markdown generation | Implemented core | Native copy/share/save UI remains |
| Complete website localization | Partial | English fallback exists; convert and verify all website locale files |
| Accessibility | Partial | Safe area, semantics, scaling foundations; full focus/screen-reader audit remains |
| CI | Implemented | Format, analyze, tests, Android debug artifact |
| Signed store distribution | External | Requires Apple/Google credentials and store review |

This ledger is intentionally candid. “Ready for distribution” means every Partial row applicable to mobile is completed, automated checks pass, release artifacts build, and the manual QA matrix is signed off.
