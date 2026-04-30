#!/bin/bash
# Calendar Agent - Build Script
# Builds the native Swift/SwiftUI macOS application

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="Calendar Agent"
BUILD_DIR="$PROJECT_DIR/.build/release"

echo "🔨 Building $APP_NAME..."
cd "$PROJECT_DIR"

# Build with Swift Package Manager
echo "   Compiling Swift code..."
swift build -c release 2>&1 | grep -E "error:|warning:" || echo "   ✓ Build successful"

# Check executable exists
if [ ! -x "$BUILD_DIR/$APP_NAME" ]; then
    echo "❌ Build failed - executable not found"
    exit 1
fi

echo "✅ Build complete"
echo ""
echo "To create and install the app bundle:"
echo "  bash build-bundle.sh"
