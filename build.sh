#!/bin/bash
set -e

echo "=== Sensi Ultralock - Build Script ==="
echo ""

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    brew install xcodegen
fi

# Generate project
echo "Generating Xcode project..."
xcodegen generate

if [ "$1" == "unsigned" ]; then
    echo "Building unsigned .ipa for sideloading..."
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
    mkdir -p build/output/Payload
    cp -R "$APP_PATH" build/output/Payload/
    cd build/output
    zip -r ../SensiUltralock.ipa Payload/
    cd ../..
    echo "Unsigned .ipa created at: build/SensiUltralock.ipa"
    echo "Use AltStore/Sideloadly/Scarlet to sign and install on your iPhone."
elif [ "$1" == "sim" ]; then
    echo "Building for Simulator (Appetize-ready)..."
    xcodebuild -project SensiUltralock.xcodeproj \
               -scheme SensiUltralock \
               -configuration Release \
               -sdk iphonesimulator \
               -destination "generic/platform=iOS Simulator" \
               -derivedDataPath build/derived \
               CODE_SIGN_STYLE=Manual \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO \
               build

    APP_PATH=$(find build/derived -name "*.app" -type d | head -1)
    mkdir -p build/output
    cp -R "$APP_PATH" build/output/SensiUltralock.app
    cd build/output
    zip -r ../SensiUltralock.zip SensiUltralock.app
    cd ../..
    echo "Simulator .zip created at: build/SensiUltralock.zip"
else
    echo "Opening Xcode... (select your iPhone and press Run)"
    open SensiUltralock.xcodeproj
fi
