#!/bin/bash
# Archive Hylios app for TestFlight
# Based on Clawket archive script pattern
#
# Usage: ./archive.sh
#
# NOTE: Per commit a1a7505, CLI exportArchive is blocked.
# This script creates the archive but upload must be done via Xcode Organizer GUI.

set -euo pipefail

# Fix PATH for xcodebuild (homebrew rsync breaks -E flag)
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Configuration
TEAM="5Y7NBCKHJP"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist"
PROJECT="$ROOT/EtherealDimension.xcodeproj"
SCHEME="EtherealDimension"
ARCHIVE="$OUT/EtherealDimension.xcarchive"
LOG=/tmp/hylios-archive.log

echo "=== Hylios TestFlight Archive Script ==="
echo "Project: $ROOT"
echo "Scheme: $SCHEME"
echo "Team: $TEAM"
echo "Output: $OUT"
echo ""

# Create output directory
mkdir -p "$OUT"

# Archive the app
echo "=== ARCHIVING iOS app (this may take a few minutes) ==="
if xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE" \
  -configuration Release \
  DEVELOPMENT_TEAM="$TEAM" \
  CODE_SIGN_STYLE=Automatic \
  PROVISIONING_PROFILE_SPECIFIER="" \
  2>&1 | tee -a "$LOG"; then
  
  echo ""
  echo "=== ARCHIVE SUCCESS ==="
  echo "Archive created at: $ARCHIVE"
  echo ""
  echo "Upload to TestFlight:"
  echo "  1. Open Xcode → Product → Archive (or open the .xcarchive directly)"
  echo "  2. In Organizer, click 'Distribute App'"
  echo "  3. Select 'App Store Connect' and follow prompts"
  echo ""
else
  EXIT_CODE=${PIPESTATUS[0]:-$?}
  echo ""
  echo "=== ARCHIVE FAILED ==="
  echo "Exit code: $EXIT_CODE"
  echo "Check log: $LOG"
  exit $EXIT_CODE
fi