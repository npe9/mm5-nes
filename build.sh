#!/bin/bash

# Exit on error
set -e

echo "Building MMC5Dev..."

# Build 6502 assembly code
echo "Building 6502 assembly code..."
mkdir -p build
cd src
ca65 -I ../inc main.s -o ../build/main.o
ld65 -C ../cfg/mmc5.cfg ../build/main.o -o ../build/main.nes
dd if=../build/main.nes of=../build/main.bin bs=1 skip=16
cd ..

# Build Swift project
cd MMC5Dev
swift build -c release
cd ..

# Create app bundle
echo "Creating app bundle..."
rm -rf MMC5Dev.app
mkdir -p MMC5Dev.app/Contents/MacOS
mkdir -p MMC5Dev.app/Contents/Resources

# Create Info.plist
cat > MMC5Dev.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MMC5Dev</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.MMC5Dev</string>
    <key>CFBundleName</key>
    <string>MMC5Dev</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

# Copy executable
cp MMC5Dev/.build/release/MMC5Dev MMC5Dev.app/Contents/MacOS/MMC5Dev
chmod +x MMC5Dev.app/Contents/MacOS/MMC5Dev

# Copy resources
cp -R MMC5Dev/Sources/MMC5Dev/Assets.xcassets MMC5Dev.app/Contents/Resources/
cp build/main.bin MMC5Dev.app/Contents/Resources/

echo "Build complete!"
open MMC5Dev.app 