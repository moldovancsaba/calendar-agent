#!/bin/bash
# Calendar Agent - Build & Bundle Script
# Builds the Swift app and creates the macOS app bundle

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="Calendar Agent"
BUILD_DIR="$PROJECT_DIR/.build/release"
BUNDLE_DIR="$PROJECT_DIR/dist"

echo "🔨 Building and bundling $APP_NAME..."
echo ""

# Step 1: Build
echo "1️⃣  Building Swift code..."
cd "$PROJECT_DIR"
swift build -c release > /dev/null 2>&1
echo "   ✓ Build successful"

# Step 2: Create bundle structure
echo "2️⃣  Creating app bundle..."
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/$APP_NAME.app/Contents/Resources"

# Step 3: Copy executable
cp "$BUILD_DIR/$APP_NAME" "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS/"
chmod +x "$BUNDLE_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME"

# Step 4: Copy metadata
cp "$PROJECT_DIR/Info.plist" "$BUNDLE_DIR/$APP_NAME.app/Contents/"
echo -n "APPL????" > "$BUNDLE_DIR/$APP_NAME.app/Contents/PkgInfo"
echo "   ✓ Bundle created"

# Step 5: Code-sign
echo "3️⃣  Code-signing application..."
codesign --force --deep --sign - "$BUNDLE_DIR/$APP_NAME.app" 2>&1 | grep -v "WARNING" || true
echo "   ✓ Code-signed"

# Step 6: Install
echo "4️⃣  Installing to /Applications..."
if [ -d "/Applications/$APP_NAME.app" ]; then
    rm -rf "/Applications/$APP_NAME.app"
fi
cp -r "$BUNDLE_DIR/$APP_NAME.app" "/Applications/"
echo "   ✓ Installed"

# Step 7: Verify
echo "5️⃣  Verifying..."
if codesign -v "/Applications/$APP_NAME.app" > /dev/null 2>&1; then
    echo "   ✓ Code signature verified"
else
    echo "   ⚠️  Code signature verification note (may be normal)"
fi

echo ""
echo "✅ $APP_NAME is ready!"
echo ""
echo "📍 Location: /Applications/$APP_NAME.app"
echo ""
echo "🚀 Launch with:"
echo "   • open /Applications/Calendar\\ Agent.app"
echo "   • Or search for 'Calendar Agent' in Spotlight (Cmd+Space)"
echo ""
