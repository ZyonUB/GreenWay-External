#!/bin/bash
set -euo pipefail

REPO="https://raw.githubusercontent.com/ZyonUB/GreenWay-External/main"
APP_NAME="GreenWay"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "GreenWay's installer currently supports macOS only."
  exit 1
fi

if ! command -v swiftc >/dev/null 2>&1; then
  echo "Swift compiler not found. Install Xcode Command Line Tools with:"
  echo "  xcode-select --install"
  exit 1
fi

echo "Downloading GreenWay source..."
curl -fL "https://raw.githubusercontent.com/ZyonUB/GreenWay-External/a682890077ec265ff8f7cd9f03617b9244252c33/GreenWayExternal.swift" -o "$WORK_DIR/GreenWayExternal.swift"

APP="$WORK_DIR/$APP_NAME.app"
mkdir -p "$APP/Contents/MacOS"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>GreenWay</string>
  <key>CFBundleDisplayName</key><string>GreenWay</string>
  <key>CFBundleIdentifier</key><string>com.greenway.companion</string>
  <key>CFBundleVersion</key><string>1.0.0</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

if grep -q "^@main" "$WORK_DIR/GreenWayExternal.swift"; then
  echo "Downloaded source is outdated; refusing to build."
  exit 1
fi

cat > "$WORK_DIR/main.swift" <<'SWIFTMAIN'
import SwiftUI

GreenWayExternalApp.main()
SWIFTMAIN

echo "Building GreenWay..."
swiftc -module-name GreenWay -O -framework SwiftUI -framework AppKit "$WORK_DIR/GreenWayExternal.swift" "$WORK_DIR/main.swift" -o "$APP/Contents/MacOS/GreenWay"
chmod +x "$APP/Contents/MacOS/GreenWay"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true

DEST="/Applications"
if [[ ! -w "$DEST" ]]; then
  DEST="$HOME/Applications"
  mkdir -p "$DEST"
fi

rm -rf "$DEST/$APP_NAME.app"
ditto "$APP" "$DEST/$APP_NAME.app"
echo
echo "GreenWay installed to: $DEST/$APP_NAME.app"
echo "You can open it from Applications or run:"
echo "  open \"$DEST/$APP_NAME.app\""
