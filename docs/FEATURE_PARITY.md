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
| Swipe and cross-book navigation | Implemented core | Shared cross-book turn operation, horizontal swipe, Alt+arrow shortcuts, arrows/mobile row, and tested deliberate double-boundary intent; device gesture QA remains |
| Deep links/shareable links | Partial | Parser exists; GoRouter/platform association needs integration tests |
| RTL and appearance modes | Implemented | Device selection behavior still requires QA |
| Contextual selection toolbar | Partial | Verse-number menu anchors to its row and native selected-text toolbar exposes active marking/removal; compact all-group anchored palette and positioning widget tests remain |
| Whole/text markings and overlap rules | Implemented core | Whole-verse recolor/removal, selected-range marking/removal, overlap rendering, active group memory, Study lists, and add/edit/recolor/delete group UI exist; full journey tests and backup UI remain |
| Inline notes | Implemented core | Add/edit/delete editor opens under its verse and saved note folds inline; keyboard-shortcut and full widget journey tests remain |
| Search modes and isolate execution | Partial | Full filter UI and isolate search exist with progressive 20-result rendering; cooperative corpus parsing, match highlighting, seven-second arrival emphasis, and cancellation tests remain |
| Website-compatible backups | Implemented core | Model validation/merge exists; native file picker/share UI remains |
| Markdown generation | Implemented core | Native copy/share/save UI remains |
| Complete website localization | Partial | All 69 compact website locale packs are mirrored and contract-tested; Flutter runtime message loading and full widget adoption remain |
| Approved GetBible branding | Implemented | Supplied artwork is installed for Android, iOS, macOS, Windows, Linux, web, splash, and the reader header; CI verifies exact hashes |
| Accessibility | Partial | Safe area, semantics, scaling foundations; full focus/screen-reader audit remains |
| CI | Implemented | Format, analyze, tests, Android debug artifact |
| Signed store distribution | External | Requires Apple/Google credentials and store review |

This ledger is intentionally candid. “Ready for distribution” means every Partial row applicable to mobile is completed, automated checks pass, release artifacts build, and the manual QA matrix is signed off.
