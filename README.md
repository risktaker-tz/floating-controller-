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

Requires JDK 17 and Android SDK 35. With `signingConfig` intentionally not set in `build.gradle.kts` (see comments there — AGP 8.7.x silently ignores `enableV1Signing` for `minSdkVersion >= 24`), `assembleRelease` produces an **unsigned** release APK. The CI workflow then signs it directly with `apksigner sign --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true` to force all three signing schemes.

For local verification (no signing required):

```bash
gradle :app:testDebugUnitTest :app:lintRelease :app:assembleRelease :app:bundleRelease :mock-target:lintRelease :mock-target:assembleRelease
```

To produce a signed APK locally (after running `scripts/setup-signing.sh` once to create and upload your keystore to GitHub Secrets, then downloading the keystore to `/tmp/aegis.keystore`):

```bash
APKSIGNER="$ANDROID_HOME/build-tools/35.0.0/apksigner"
"$APKSIGNER" sign \
  --ks /tmp/aegis.keystore \
  --ks-pass pass:YOUR_KS_PASSWORD \
  --ks-key-alias aegis-release \
  --key-pass pass:YOUR_KEY_PASSWORD \
  --v1-signing-enabled true \
  --v2-signing-enabled true \
  --v3-signing-enabled true \
  --out app/build/outputs/apk/release/app-release.apk \
  app/build/outputs/apk/release/app-release-unsigned.apk
```

Grant overlay and accessibility permissions; install the mock target; map controls; keep DEMO selected. The app does not bypass authentication, CAPTCHA, anti-bot controls, or Android security, stores no credentials, and has no hard-coded SportyBet selectors. Live SportyBet operation is not claimed verified until its Android accessibility hierarchy and state transitions are captured and tested.
