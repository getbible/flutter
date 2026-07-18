# GetBible brand assets

The files in `assets/branding/` are the approved source artwork supplied by the GetBible maintainer. They are authoritative for every release target.

| Source | Purpose |
|---|---|
| `getbible_app_icon.png` | Square launcher, window, and favicon source |
| `getbible_book.png` | Splash and larger book artwork |
| `getbible_wordmark.png` | In-app getBible.Life wordmark |
| `apple_touch_icon.png` | Preserved web/Apple source asset |
| `favicon.ico` | Preserved original small favicon |

Derived files are committed for deterministic native builds: Android mipmaps and splash image, the complete iOS and macOS app-icon sets, iOS launch images, Windows ICO, and Flutter web icons/favicon.

After an explicitly approved source-art update, regenerate every target size, visually inspect transparent and opaque backgrounds, then refresh and verify the checksum manifest. CI runs:

```bash
sha256sum -c assets/branding/BRAND_ASSETS.sha256
```

Do not use `flutter create` over the platform directories without immediately restoring and verifying these assets. Default Flutter icons are forbidden for release artifacts.
