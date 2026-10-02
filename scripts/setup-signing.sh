#!/usr/bin/env bash
# Set up release signing identity for the Aegis floating controller.
#
# Run this LOCALLY on a trusted machine. It will:
#   1. Prompt for a keystore password and a key password (input is hidden).
#   2. Generate a stable RSA-4096 keystore with keytool.
#   3. Upload four GitHub Secrets to the repository using `gh`:
#        AEGIS_KEYSTORE_BASE64     (base64 of the keystore bytes)
#        AEGIS_KEYSTORE_PASSWORD   (keystore password)
#        AEGIS_KEY_ALIAS           (key alias)
#        AEGIS_KEY_PASSWORD        (key password)
#
# SECURITY:
#   - The keystore file is generated locally and never uploaded anywhere except
#     to GitHub Secrets via the `gh` CLI over HTTPS.
#   - Passwords are read from the TTY (never echoed) and piped to `gh secret set`
#     via stdin; they never appear in the script's process listing.
#   - Nothing in this script writes secrets to source code, chat, or any file
#     outside the local keystore file you choose to keep.
#   - The local keystore file MUST be backed up by you. GitHub Secrets are
#     write-only — you CANNOT read them back. If you lose the local keystore,
#     you must re-run this script to create a NEW identity and replace the
#     secrets (existing installs signed by the previous key will need to be
#     uninstalled before they can be updated).

set -euo pipefail

REPO="risktaker-tz/floating-controller-"
ALIAS="aegis-release"
VALIDITY_DAYS=36500  # 100 years — stable identity
KEYSTORE_NAME="aegis-release.keystore"

echo "Aegis release signing setup"
echo "Target repository: $REPO"
echo "Key alias:          $ALIAS"
echo

command -v keytool >/dev/null 2>&1 || { echo "ERROR: keytool not found. Install a JDK." >&2; exit 1; }
command -v gh     >/dev/null 2>&1 || { echo "ERROR: gh CLI not found. Install from https://cli.github.com/" >&2; exit 1; }
gh auth status >/dev/null 2>&1    || { echo "ERROR: gh not authenticated. Run: gh auth login" >&2; exit 1; }
gh repo view "$REPO" >/dev/null 2>&1 || { echo "ERROR: cannot access $REPO with current gh auth." >&2; exit 1; }

read -r -p "Output keystore file path [./$KEYSTORE_NAME]: " KEYSTORE_FILE
KEYSTORE_FILE="${KEYSTORE_FILE:-./$KEYSTORE_NAME}"
if [ -f "$KEYSTORE_FILE" ]; then
  echo "ERROR: $KEYSTORE_FILE already exists. Move it aside or pick a different path." >&2
  exit 1
fi

read -s -r -p "Signing password (>= 6 chars; used for both keystore and key): " PASS; echo
read -s -r -p "Confirm signing password: " PASS2; echo
[ "$PASS" = "$PASS2" ] || { echo "ERROR: passwords do not match." >&2; exit 1; }
[ "${#PASS}" -ge 6 ]    || { echo "ERROR: password too short." >&2; exit 1; }

echo
echo "Generating PKCS12 keystore: $KEYSTORE_FILE"
DN="CN=Aegis Floating Controller Release,O=Aegis,C=US"
# PKCS12 does not support different store/key passwords, so we use one
# password for both. Use -storepass:env / -keypass:env to keep the
# password out of the process listing.
export KS_PASS="$PASS"
keytool -genkeypair \
  -keystore "$KEYSTORE_FILE" \
  -storetype PKCS12 \
  -storepass:env KS_PASS \
  -alias "$ALIAS" \
  -keypass:env KS_PASS \
  -keyalg RSA -keysize 4096 -sigalg SHA256withRSA \
  -validity "$VALIDITY_DAYS" \
  -dname "$DN"
unset KS_PASS

echo "Keystore generated. Certificate fingerprints:"
export KS_PASS="$PASS"
keytool -list -v -keystore "$KEYSTORE_FILE" -storepass:env KS_PASS -alias "$ALIAS" | grep -iE "SHA-256|SHA-1|Owner"
unset KS_PASS

echo
echo "Uploading 4 secrets to GitHub repository: $REPO"
KEYSTORE_BASE64="$(base64 -w 0 < "$KEYSTORE_FILE")"

# Pipe each value through stdin so it does not appear in the process table.
printf '%s' "$KEYSTORE_BASE64" | gh secret set AEGIS_KEYSTORE_BASE64   --repo "$REPO"
printf '%s' "$PASS"            | gh secret set AEGIS_KEYSTORE_PASSWORD --repo "$REPO"
printf '%s' "$ALIAS"           | gh secret set AEGIS_KEY_ALIAS         --repo "$REPO"
printf '%s' "$PASS"            | gh secret set AEGIS_KEY_PASSWORD      --repo "$REPO"

echo
echo "All 4 secrets uploaded to GitHub repository: $REPO"
echo
echo "BACK UP the local keystore file now:"
echo "  $KEYSTORE_FILE"
echo "Store it in a secure offline location (password manager, encrypted USB, etc.)."
echo "If lost, you must generate a NEW keystore and re-run this script."
echo "Existing installs signed by the old key must be uninstalled before updating."
