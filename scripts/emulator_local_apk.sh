#!/usr/bin/env bash
# Local APK emulator install + launch smoke test.
# Reads EXPECTED_CERT from env (substituted by GitHub Actions into the calling shell).
set -euo pipefail
echo "Expected release cert SHA-256: $EXPECTED_CERT"
for apk_label in controller mock; do
  if [ "$apk_label" = "controller" ]; then
    APK="$GITHUB_WORKSPACE/release/aegis-controller.apk"
    PKG="io.aegis"
    ACTIVITY="io.aegis/.MainActivity"
  else
    APK="$GITHUB_WORKSPACE/release/aegis-mock-target.apk"
    PKG="io.aegis.mock"
    ACTIVITY="io.aegis.mock/.MainActivity"
  fi
  echo "=========================================================="
  echo "Emulator install + launch: $apk_label ($PKG)"
  echo "----------------------------------------------------------"
  echo "adb install -r $APK"
  # Capture adb's real exit code (not tee's). The task requires the exact
  # Package Manager error if installation fails.
  adb install -r "$APK" > /tmp/install_$apk_label.log 2>&1
  INSTALL_RC=$?
  cat /tmp/install_$apk_label.log
  if [ $INSTALL_RC -ne 0 ]; then
    echo "::error::adb install failed for $apk_label (exit $INSTALL_RC). Exact Package Manager output above."
    exit 1
  fi
  echo "----------------------------------------------------------"
  echo "adb shell pm path $PKG"
  INSTALLED_PATH=$(adb shell pm path "$PKG" | head -1 | sed 's/^package://')
  if [ -z "$INSTALLED_PATH" ]; then
    echo "::error::$PKG is not present after install (pm path empty)."
    exit 1
  fi
  echo "Installed at: $INSTALLED_PATH"
  echo "----------------------------------------------------------"
  echo "adb shell am start -W -n $ACTIVITY"
  adb shell am start -W -n "$ACTIVITY" 2>&1 | tee /tmp/launch_$apk_label.log
  sleep 5
  echo "----------------------------------------------------------"
  echo "Recent logcat (errors only, last 300 lines):"
  adb logcat -d -t 300 *:E 2>/dev/null | tail -80 || true
  if adb shell dumpsys activity activities 2>/dev/null | grep -q "$PKG"; then
    echo "OK: $PKG is in the activity task stack — launch succeeded."
  else
    echo "::error::$PKG did not appear in activity task stack — launch failed or crashed immediately."
    exit 1
  fi
  echo "----------------------------------------------------------"
  echo "Installed cert vs expected release cert"
  adb pull "$INSTALLED_PATH" /tmp/installed_$apk_label.apk 2>&1 | tail -1
  INSTALLED_CERT=$("$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION/apksigner" verify --print-certs --min-sdk-version 26 /tmp/installed_$apk_label.apk 2>&1 | grep -E 'SHA-256 digest:' | head -1 | sed -E 's/.*SHA-256 digest: //; s/[^0-9A-Fa-f:]//g')
  echo "Installed cert SHA-256: $INSTALLED_CERT"
  echo "Expected  cert SHA-256: $EXPECTED_CERT"
  if [ -z "$INSTALLED_CERT" ] || [ "$INSTALLED_CERT" != "$EXPECTED_CERT" ]; then
    echo "::error::Installed cert does not match expected release cert for $apk_label."
    exit 1
  fi
  echo "OK: installed cert matches expected release cert."
  adb uninstall "$PKG" >/dev/null 2>&1 || true
done
echo "=========================================================="
echo "Emulator smoke test PASSED for both APKs."
