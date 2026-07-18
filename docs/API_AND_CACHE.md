# GetBible API and cache workflow

Base URL: `https://api.getbible.net/v2`.

| Resource | Endpoint | Cache behavior |
|---|---|---|
| Translations | `/translations.json` | Refresh after seven days; changed translation SHA invalidates subordinate indexes/corpus. |
| Books | `/{translation}/books.json` | Dynamic; changed book SHA invalidates that book. |
| Chapters | `/{translation}/{book}/chapters.json` | Dynamic; changed chapter SHA invalidates only that chapter. |
| Chapter | `/{translation}/{book}/{chapter}.json` | Cached after opening. |
| Chapter SHA | `/{translation}/{book}/{chapter}.sha` | Checked before using a network-verified cached chapter. |
| Full translation | `/{translation}.json` | Download only for deliberate search/offline workflows; bind cache to translation SHA. |

Freshness states are `fresh`, `cachedVerified`, and `cachedUnverified`. A failed network/hash check must not erase a valid cached chapter. Malformed cached JSON is discarded. Storage bookkeeping failure must not hide usable Scripture already fetched or verified.

API responses must remain dynamically discovered; never hard-code available translations, book names, chapter counts, or verse counts. Timeouts, non-2xx responses, malformed UTF-8/JSON, and empty resources are typed failures.
