@echo off
echo === Sensi Ultralock - Build Script ===
echo.

echo 🔧 Generating Xcode project using XcodeGen...
call xcodegen generate

if "%1"=="unsigned" (
    echo 📱 Building unsigned .app for sideloading...
    xcodebuild -project SensiUltralock.xcodeproj ^
               -scheme SensiUltralock ^
               -configuration Release ^
               -sdk iphoneos ^
               -derivedDataPath build/derived ^
               CODE_SIGN_STYLE=Manual ^
               CODE_SIGNING_REQUIRED=NO ^
               CODE_SIGNING_ALLOWED=NO ^
               build
    echo ✅ Unsigned .app created. Use AltStore/Sideloadly to install.
) else (
    echo 📱 Opening Xcode...
    start SensiUltralock.xcodeproj
)
