#!/bin/bash

set -e

echo "Installing IssueWidget..."
echo ""

# Check if built
if [ ! -f "build/issueWidget" ] || [ ! -d "build/IssueWidget.app" ]; then
    echo "Error: Build files not found. Please run ./build.sh first"
    exit 1
fi

# Create ~/bin if it doesn't exist
mkdir -p ~/bin

# Install CLI tool
echo "Installing CLI tool..."
if [ -f ~/bin/issueWidget ]; then
    echo "  Replacing existing version..."
fi
cp -f build/issueWidget ~/bin/
chmod +x ~/bin/issueWidget
echo "✓ CLI installed to ~/bin/issueWidget"

# Check if ~/bin is in PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    echo ""
    echo "⚠️  Note: ~/bin is not in your PATH"
    echo "   Add this to your ~/.zshrc or ~/.bashrc:"
    echo "   export PATH=\"\$HOME/bin:\$PATH\""
fi

# Create ~/Applications if it doesn't exist
mkdir -p ~/Applications

# Install App
echo ""
echo "Installing menu bar app..."
if [ -d ~/Applications/IssueWidget.app ]; then
    echo "  Replacing existing version..."
    # Quit running app before replacing
    killall IssueWidget 2>/dev/null || true
    rm -rf ~/Applications/IssueWidget.app
fi
cp -r build/IssueWidget.app ~/Applications/
echo "✓ App installed to ~/Applications/IssueWidget.app"

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  issueWidget --issue 266"
echo ""
echo "The CLI will automatically launch the menu bar app when needed."
echo ""
echo "Optional: Add to Login Items for auto-start"
echo "  System Settings → General → Login Items → Add IssueWidget from ~/Applications"
