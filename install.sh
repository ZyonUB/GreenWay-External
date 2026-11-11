#!/bin/bash
# GreenWay installer build: 2026-11-11-parse-library-fix
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
curl -fL "https://raw.githubusercontent.com/ZyonUB/GreenWay-External/main/GreenWayExternal.swift?cache=$(date +%s)" -o "$WORK_DIR/GreenWayExternal.swift"

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

# Normalize older cached copies of the source before compiling.
sed -i '' '/^GreenWayExternalApp\.main()$/d' "$WORK_DIR/GreenWayExternal.swift"
if ! grep -q "^@main" "$WORK_DIR/GreenWayExternal.swift"; then
  sed -i '' 's/^struct GreenWayExternalApp: App {/@main\
struct GreenWayExternalApp: App {/' "$WORK_DIR/GreenWayExternal.swift"
fi
if ! grep -q "^@main" "$WORK_DIR/GreenWayExternal.swift"; then
  echo "Could not prepare the SwiftUI app entry point."
  exit 1
fi

echo "Building GreenWay..."
swiftc -parse-as-library -module-name GreenWay -O -framework SwiftUI -framework AppKit "$WORK_DIR/GreenWayExternal.swift" -o "$APP/Contents/MacOS/GreenWay"
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
