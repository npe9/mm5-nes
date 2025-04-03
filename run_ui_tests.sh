#!/bin/bash

# Build and run UI tests
xcodebuild test \
    -scheme MMC5Dev \
    -destination 'platform=macOS' \
    -resultBundlePath TestResults.xcresult

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✅ UI Tests passed successfully!"
else
    echo "❌ UI Tests failed. Check TestResults.xcresult for details."
    exit 1
fi 