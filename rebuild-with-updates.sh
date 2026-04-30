#!/bin/bash
# Rebuild Calendar Agent with Auto-Update Functionality

set -e

PROJECT_DIR="/Users/Shared/Projects/claude/calendar-agent"
APP_NAME="Calendar Agent"

echo "🔨 Rebuilding Calendar Agent with auto-update functionality..."
echo ""

# Build
echo "1️⃣  Building Swift code with updates..."
cd "$PROJECT_DIR"
swift build -c release

# Create bundle structure
echo "2️⃣  Creating app bundle..."
BUNDLE_DIR="$PROJECT_DIR/dist"
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/$APP_NAME.app/Contents/Resources"

# Copy executable
cp "$PROJECT_DIR/.build/release/$APP_NAME" "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS/"
chmod +x "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Copy metadata
cp "$PROJECT_DIR/Info.plist" "$BUNDLE_DIR/$APP_NAME.app/Contents/"
echo -n "APPL????" > "$BUNDLE_DIR/$APP_NAME.app/Contents/PkgInfo"

# Code-sign
echo "3️⃣  Code-signing application..."
codesign --force --deep --sign - "$BUNDLE_DIR/$APP_NAME.app" 2>&1 | grep -v "WARNING" || true

# Install
echo "4️⃣  Installing to /Applications..."
if [ -d "/Applications/$APP_NAME.app" ]; then
    rm -rf "/Applications/$APP_NAME.app"
fi
cp -r "$BUNDLE_DIR/$APP_NAME.app" "/Applications/"

# Verify
echo "5️⃣  Verifying installation..."
if codesign -v "/Applications/$APP_NAME.app" > /dev/null 2>&1; then
    echo "   ✓ Code signature verified"
else
    echo "   ℹ️  Code signature verification note (may be normal)"
fi

echo ""
echo "✅ Calendar Agent rebuilt with auto-update functionality!"
echo ""
echo "📍 Location: /Applications/$APP_NAME.app"
echo ""
echo "🚀 The app now includes:"
echo "   • Auto-update checking (checks GitHub releases hourly)"
echo "   • Update notifications in the app"
echo "   • One-click update installation"
echo ""
echo "⚙️  To enable auto-updates:"
echo "   1. Create a GitHub repository at: https://github.com/moldovan/calendar-agent"
echo "   2. Create releases with tag names like: v1.0.1, v1.0.2, etc."
echo "   3. Attach the app bundle to each release"
echo "   4. The app will automatically detect and notify about new versions"
echo ""
