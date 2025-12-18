# IssueWidget

A macOS menu bar app that displays your current GitHub issue. Click to open the issue in your browser.

## Quick Start

### Simple Build & Install (Recommended)

```bash
# Build everything
./build.sh

# Install system-wide
./install.sh

# Use it!
issueWidget --issue 266
```

### Alternative: Xcode

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed Xcode setup.

## Usage

Once both the app and CLI are built:

1. From any git repository (CLI auto-launches the app):
   ```bash
   issueWidget --issue 266
   ```

2. Or specify explicitly:
   ```bash
   issueWidget --user microsoft --repo vscode --issue 12345
   ```

3. Check current issue (returns JSON):
   ```bash
   issueWidget --status
   ```

4. Clear the widget:
   ```bash
   issueWidget --clear
   ```

5. Quit the app:
   ```bash
   issueWidget --quit
   ```

The menu bar will show your issue number (e.g., "#266"). Click it to open the issue in your browser.

## Architecture

- **IssueWidget App**: SwiftUI menu bar application
- **CLI Tool**: Command-line interface with git auto-detection
- **Shared Storage**: Uses App Groups to communicate between app and CLI
- **Click Action**: Opens GitHub issue URL in default browser

## Files

- `IssueWidget/IssueWidget/` - Menu bar app source
- `IssueWidget/CLI/` - Command-line tool source
- `IssueWidget/Shared/` - Shared data models
- `Package.swift` - Swift Package Manager configuration (for CLI)
