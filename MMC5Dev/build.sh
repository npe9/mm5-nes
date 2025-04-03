#!/bin/bash

# Exit on error
set -e

echo "Building MMC5Dev..."

# Build using Swift Package Manager
swift build

# Create app bundle
mkdir -p MMC5Dev.app/Contents/MacOS
cp .build/debug/MMC5Dev MMC5Dev.app/Contents/MacOS/MMC5Dev
chmod +x MMC5Dev.app/Contents/MacOS/MMC5Dev

# Copy Info.plist and Assets
mkdir -p MMC5Dev.app/Contents/Resources
cp Sources/MMC5Dev/Info.plist MMC5Dev.app/Contents/
cp -r Assets.xcassets MMC5Dev.app/Contents/Resources/

echo "Build completed successfully!"

# Run the app
echo "Launching MMC5Dev..."
open MMC5Dev.app 