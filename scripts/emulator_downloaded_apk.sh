#!/usr/bin/env bash
# Downloaded-asset emulator install + launch smoke test.
# Reads EXPECTED_CERT from env (substituted by GitHub Actions into the calling shell).
set -euo pipefail
APK="/tmp/downloaded/aegis-controller.apk"
echo "Installing downloaded asset: $APK"
# Capture adb's real exit code (not tee's).
adb install -r "$APK" > /tmp/dl_install.log 2>&1
INSTALL_RC=$?
cat /tmp/dl_install.log
if [ $INSTALL_RC -ne 0 ]; then
  echo "::error::Downloaded asset failed to install (exit $INSTALL_RC). Exact Package Manager output above."
  exit 1
fi
adb shell pm path io.aegis
adb shell am start -W -n io.aegis/.MainActivity 2>&1 | tee /tmp/dl_launch.log
sleep 5
adb logcat -d -t 200 *:E 2>/dev/null | tail -50 || true
if adb shell dumpsys activity activities 2>/dev/null | grep -q "io.aegis"; then
  echo "OK: downloaded asset launches successfully on a fresh emulator."
else
  echo "::error::Downloaded asset did not appear in activity task stack."
  exit 1
fi
adb pull "$(adb shell pm path io.aegis | head -1 | sed 's/^package://')" /tmp/dl_installed.apk 2>&1 | tail -1
DL_CERT=$("$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/apksigner" verify --print-certs --min-sdk-version 26 /tmp/dl_installed.apk 2>&1 | grep -E 'SHA-256 digest:' | head -1 | sed -E 's/.*SHA-256 digest: //; s/[^0-9A-Fa-f:]//g')
echo "Downloaded+installed cert: $DL_CERT"
echo "Expected release cert     : $EXPECTED_CERT"
if [ -z "$DL_CERT" ] || [ "$DL_CERT" != "$EXPECTED_CERT" ]; then
  echo "::error::Downloaded+installed asset cert does not match expected release cert."
  exit 1
fi
echo "OK: downloaded asset cert matches expected release cert."
adb uninstall io.aegis >/dev/null 2>&1 || true
