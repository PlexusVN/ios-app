#!/bin/bash
set -e

echo "=== Sensi Ultralock - Build Script ==="
echo ""

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing XcodeGen..."
    brew install xcodegen
fi

# Generate project
echo "🔧 Generating Xcode project..."
xcodegen generate

# Check if user wants unsigned build for sideloading
if [ "$1" == "unsigned" ]; then
    echo "📱 Building unsigned .app for sideloading..."
    xcodebuild -project SensiUltralock.xcodeproj \
               -scheme SensiUltralock \
               -configuration Release \
               -sdk iphoneos \
               -derivedDataPath build/derived \
               CODE_SIGN_STYLE=Manual \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO \
               build

    APP_PATH=$(find build/derived -name "*.app" -type d | head -1)
    mkdir -p build/output
    cp -R "$APP_PATH" build/output/SensiUltralock.app
    echo "✅ Unsigned .app created at: build/output/SensiUltralock.app"
    echo "   Use AltStore/Sideloadly to install on your iPhone."
else
    echo "📱 Opening Xcode... (select your iPhone and press Run ▶️)"
    open SensiUltralock.xcodeproj
fi
