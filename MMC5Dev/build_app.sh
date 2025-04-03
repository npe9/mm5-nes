#!/bin/bash
swift build
rm -rf MMC5Dev.app
mkdir -p MMC5Dev.app/Contents/MacOS MMC5Dev.app/Contents/Resources
cp .build/debug/MMC5Dev MMC5Dev.app/Contents/MacOS/
chmod +x MMC5Dev.app/Contents/MacOS/MMC5Dev
cp Sources/MMC5Dev/Info.plist MMC5Dev.app/Contents/
cp Resources/AppIcon.icns MMC5Dev.app/Contents/Resources/
