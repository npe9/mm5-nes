#!/bin/bash

# Build the executable
swift build -c debug

# Create app bundle structure
mkdir -p .build/debug/MMC5Dev.app/Contents/MacOS
mkdir -p .build/debug/MMC5Dev.app/Contents/Resources

# Copy executable
cp .build/debug/MMC5Dev .build/debug/MMC5Dev.app/Contents/MacOS/

# Copy Info.plist
cp MMC5Dev/Sources/MMC5Dev/Info.plist .build/debug/MMC5Dev.app/Contents/

# Copy resources
cp -r MMC5Dev/Sources/MMC5Dev/Assets.xcassets .build/debug/MMC5Dev.app/Contents/Resources/

# Make executable
chmod +x .build/debug/MMC5Dev.app/Contents/MacOS/MMC5Dev 