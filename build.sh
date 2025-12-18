#!/bin/bash

set -e

echo "Building IssueWidget..."

# Build directory
BUILD_DIR="build"
APP_NAME="IssueWidget"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CLI_NAME="issueWidget"

# Create build directory
mkdir -p "$BUILD_DIR"

# Build CLI tool first
echo "Building CLI tool..."
swiftc \
    -o "$BUILD_DIR/$CLI_NAME" \
    IssueWidget/Shared/IssueData.swift \
    IssueWidget/CLI/main.swift \
    -framework Foundation

echo "CLI tool built: $BUILD_DIR/$CLI_NAME"

# Create app bundle structure
echo "Creating app bundle..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Build the app executable
echo "Compiling app..."
swiftc \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    IssueWidget/Shared/IssueData.swift \
    IssueWidget/IssueWidget/IssueWidgetApp.swift \
    IssueWidget/IssueWidget/MenuBarManager.swift \
    -framework SwiftUI \
    -framework AppKit \
    -framework Foundation

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.issuewidget.IssueWidget</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo ""
echo "Build complete!"
echo ""
echo "To install:"
echo "  1. App: open $APP_BUNDLE"
echo "  2. CLI: sudo cp $BUILD_DIR/$CLI_NAME /usr/local/bin/"
echo ""
echo "Or run locally:"
echo "  1. App: open $APP_BUNDLE"
echo "  2. CLI: ./$BUILD_DIR/$CLI_NAME --issue 266"
