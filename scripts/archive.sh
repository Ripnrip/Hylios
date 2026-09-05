#!/bin/bash
# 🎭 The Hylios Ascension Rite — archive + export for TestFlight
#
# "Sign it as a distributor, not a tinkerer, and the gates swing open."
#
#   ./scripts/archive.sh            → archive + export a local .ipa (nothing leaves this Mac)
#   ./scripts/archive.sh --upload   → archive + export straight into App Store Connect
#
# 🔮 Why the old rite failed: it ran exportArchive WITHOUT the App Store Connect auth
# flags, so Xcode had no way to fetch (or mint) the Store provisioning profiles it needs
# to re-sign with — and perished with the delightfully opaque
# `IDEDistributionPackagingStep: Copy failed`.
#
# 🎭 Note for the next traveller: the .xcarchive itself is signed "Apple Development", and
# that is entirely correct — do not chase it. exportArchive is the step that re-signs with
# "Apple Distribution". The -authenticationKey* + -allowProvisioningUpdates incantations
# below are what make that re-signing possible across all three bundle IDs.

set -euo pipefail

# 🧹 Homebrew's rsync poisons xcodebuild's -E flag; banish it from the PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
PROJECT="$ROOT/EtherealDimension.xcodeproj"
SCHEME="EtherealDimension"
ARCHIVE="$OUT/EtherealDimension.xcarchive"
LOG="$OUT/archive.log"

# 🔐 This repo is public, so the App Store Connect identifiers live in a gitignored
#    .env at the repo root (or the environment). Only the team ID — already visible
#    in every provisioning profile — is inlined.
#      ASC_KEY_ID=...
#      ASC_ISSUER_ID=...
TEAM="${DEVELOPMENT_TEAM:-5Y7NBCKHJP}"
if [[ -f "$ROOT/.env" ]]; then
  set -a; . "$ROOT/.env"; set +a
fi
KEY_ID="${ASC_KEY_ID:?ASC_KEY_ID is unset — add it to $ROOT/.env or export it}"
ISSUER="${ASC_ISSUER_ID:?ASC_ISSUER_ID is unset — add it to $ROOT/.env or export it}"
KEY_PATH="${ASC_KEY_PATH:-$HOME/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8}"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "❌ App Store Connect key not found at $KEY_PATH" >&2
  exit 1
fi

# 🗝️ The credentials that transmute a development build into a distributable one
AUTH=(
  -authenticationKeyID "$KEY_ID"
  -authenticationKeyIssuerID "$ISSUER"
  -authenticationKeyPath "$KEY_PATH"
  -allowProvisioningUpdates
  -allowProvisioningDeviceRegistration
)

# 🚦 export keeps the .ipa home; upload sends it to Apple. Default is the timid one.
DESTINATION="export"
if [[ "${1:-}" == "--upload" ]]; then
  DESTINATION="upload"
fi

echo "=== 🎭 Hylios archive rite ==="
echo "Project:     $ROOT"
echo "Scheme:      $SCHEME"
echo "Team:        $TEAM"
echo "Destination: $DESTINATION"
echo "Log:         $LOG"
echo ""

mkdir -p "$OUT"
rm -rf "$ARCHIVE" "$OUT/export-ios" "$OUT/export-ios.plist"

# 📜 Automatic signing across all three bundle IDs (app · widget appex · App Clip)
cat > "$OUT/export-ios.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>${DESTINATION}</string>
  <key>teamID</key><string>${TEAM}</string>
  <key>uploadSymbols</key><true/>
  <key>signingStyle</key><string>automatic</string>
  <key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

{
  echo "=== ARCHIVE $(date) ==="
  xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE" \
    -configuration Release \
    DEVELOPMENT_TEAM="$TEAM" \
    CODE_SIGN_STYLE=Automatic \
    PROVISIONING_PROFILE_SPECIFIER="" \
    "${AUTH[@]}"

  echo "=== EXPORT (${DESTINATION}) $(date) ==="
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportOptionsPlist "$OUT/export-ios.plist" \
    -exportPath "$OUT/export-ios" \
    "${AUTH[@]}"

  echo "=== DONE $(date) ==="
} >"$LOG" 2>&1

echo "EXIT:0" >>"$LOG"

# 🎉 Proof of distribution signing — inspect the IPA, NOT the archive (see note up top)
echo "✨ Rite complete. Artifacts in $OUT/export-ios:"
ls -la "$OUT/export-ios" 2>/dev/null || true

IPA="$OUT/export-ios/EtherealDimension.ipa"
if [[ -f "$IPA" ]]; then
  echo ""
  echo "🔍 Verifying the exported IPA is truly App Store bound..."
  VERIFY="$(mktemp -d)"
  unzip -q "$IPA" -d "$VERIFY"
  APP="$VERIFY/Payload/EtherealDimension.app"
  # 🎯 Must read "Apple Distribution" — an "Apple Development" authority here means the
  #    auth flags failed and Apple will reject the upload.
  codesign -dv --verbose=2 "$APP" 2>&1 | grep '^Authority=Apple' | head -1
  # 🚪 get-task-allow must be false: debuggable builds are barred from the Store
  echo -n "get-task-allow: "
  codesign -d --entitlements - --xml "$APP" 2>/dev/null | plutil -convert xml1 -o - - \
    | grep -A1 'get-task-allow' | tail -1 | tr -d ' \t' || echo "absent"
  /usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleVersion" "$ARCHIVE/Info.plist" 2>/dev/null || true
  rm -rf "$VERIFY"
fi
