# Aegis Floating Controller

Native Android floating controller following **observe → identify → verify → act → verify result → persist → continue**. DEMO is default. REAL requires exact risk acknowledgment, valid preflight, and deliberate START after every restart.

## Install directly from GitHub

After pushing to `main`, GitHub Actions builds, signs, verifies, and publishes **release-signed** artifacts:

- `aegis-controller.apk` — release-signed, non-debuggable controller APK
- `aegis-mock-target.apk` — release-signed, non-debuggable mock target APK
- `app-release.aab` — release-signed Android App Bundle (for future Play Store distribution)
- `SHA256SUMS.txt` — SHA-256 checksums for the assets above

Every build passes unit tests, lint, ZIP alignment, apksigner verification (v1 + v2 + v3 where supported), an Android emulator install + launcher smoke test, and a re-download verification of the published asset before the stable release URL is updated.

Phone download page (stable URL, continuously replaced on every push to `main`):

https://github.com/risktaker-tz/floating-controller-/releases/tag/latest

## Release signing

The release pipeline signs every APK with the same stable identity, stored as GitHub repository secrets:

- `AEGIS_KEYSTORE_BASE64`
- `AEGIS_KEYSTORE_PASSWORD`
- `AEGIS_KEY_ALIAS`
- `AEGIS_KEY_PASSWORD`

The workflow refuses to fall back to debug signing when these secrets are missing. To create or replace the signing identity locally, run `scripts/setup-signing.sh` on a trusted machine (it generates a keystore with `keytool` and uploads the four secrets via `gh`). Never commit the keystore or passwords to the repository.

## Local verification

Requires JDK 17 and Android SDK 35. The release build requires a `keystore.properties` file at the repo root (gitignored) pointing at a local keystore:

```
storeFile=/absolute/path/to/aegis-release.keystore
storePassword=…
keyAlias=aegis-release
keyPassword=…
```

```bash
gradle :app:testDebugUnitTest :app:lintRelease :app:assembleRelease :app:bundleRelease :mock-target:lintRelease :mock-target:assembleRelease
```

Grant overlay and accessibility permissions; install the mock target; map controls; keep DEMO selected. The app does not bypass authentication, CAPTCHA, anti-bot controls, or Android security, stores no credentials, and has no hard-coded SportyBet selectors. Live SportyBet operation is not claimed verified until its Android accessibility hierarchy and state transitions are captured and tested.
