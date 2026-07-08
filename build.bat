@echo off
echo === Sensi Ultralock - Build Script ===
echo.

echo Generating Xcode project using XcodeGen...
call xcodegen generate

if "%1"=="unsigned" (
    echo Building unsigned .ipa for sideloading...
    xcodebuild -project SensiUltralock.xcodeproj ^
               -scheme SensiUltralock ^
               -configuration Release ^
               -sdk iphoneos ^
               -derivedDataPath build/derived ^
               CODE_SIGN_STYLE=Manual ^
               CODE_SIGNING_REQUIRED=NO ^
               CODE_SIGNING_ALLOWED=NO ^
               build

    for /f "delims=" %%i in ('dir /s /b build\derived\*.app ^| findstr /v ".dSYM"') do set APP_PATH=%%i
    mkdir build\output\Payload
    xcopy /E /I /Y "%APP_PATH%" build\output\Payload\
    cd build\output
    tar -a -c -f ..\SensiUltralock.ipa Payload\
    cd ..\..
    echo Unsigned .ipa created at: build\SensiUltralock.ipa
    echo Use AltStore/Sideloadly/Scarlet to sign and install.
) else if "%1"=="sim" (
    echo Building for Simulator...
    xcodebuild -project SensiUltralock.xcodeproj ^
               -scheme SensiUltralock ^
               -configuration Release ^
               -sdk iphonesimulator ^
               -destination "generic/platform=iOS Simulator" ^
               -derivedDataPath build/derived ^
               CODE_SIGN_STYLE=Manual ^
               CODE_SIGNING_REQUIRED=NO ^
               CODE_SIGNING_ALLOWED=NO ^
               build
    echo Simulator build complete.
) else (
    echo Opening Xcode...
    start SensiUltralock.xcodeproj
)
