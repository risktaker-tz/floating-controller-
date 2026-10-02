# Aegis Floating Controller

Native Android floating controller following **observe → identify → verify → act → verify result → persist → continue**. DEMO is default. REAL requires exact risk acknowledgment, valid preflight, and deliberate START after every restart.

## Install directly from GitHub

After uploading this full repository to `main`, GitHub Actions builds and publishes:

- `aegis-controller.apk`
- `aegis-mock-target.apk`

Phone download page:

https://github.com/risktaker-tz/aegis-floating-controller/releases/tag/latest

Before the first build, open **Settings → Actions → General → Workflow permissions**, select **Read and write permissions**, and save. Then run **Actions → Build downloadable Android APKs**.

## Local verification

Requires JDK 17 and Android SDK 35:

```bash
gradle :app:testDebugUnitTest :app:lintDebug :app:assembleDebug :mock-target:lintDebug :mock-target:assembleDebug
```

Grant overlay and accessibility permissions; install the mock target; map controls; keep DEMO selected. The app does not bypass authentication, CAPTCHA, anti-bot controls, or Android security, stores no credentials, and has no hard-coded SportyBet selectors. Live SportyBet operation is not claimed verified until its Android accessibility hierarchy and state transitions are captured and tested.
