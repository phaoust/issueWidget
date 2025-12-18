# IssueWidget

A macOS menu bar app that displays your current GitHub issue. Click to open the issue in your browser.

## Quick Start

### Option 1: Build Everything with Xcode (Recommended)

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed Xcode setup.

### Option 2: Build CLI First (Easier to test)

Build just the command-line tool using Swift Package Manager:

```bash
swift build -c release
```

The CLI tool will be at `.build/release/issueWidget`

Test it:
```bash
.build/release/issueWidget --user microsoft --repo vscode --issue 266
```

**Note**: The CLI tool works, but without the menu bar app running, you won't see the visual widget.

### Option 3: Simple Build Script

I can create a build script that compiles both the app and CLI using `swiftc` directly, avoiding Xcode entirely.

## Usage

Once both the app and CLI are built:

1. Launch the IssueWidget app (it will appear in your menu bar as "○")
2. From any git repository:
   ```bash
   issueWidget --issue 266
   ```

3. Or specify explicitly:
   ```bash
   issueWidget --user microsoft --repo vscode --issue 12345
   ```

4. Check current issue (returns JSON):
   ```bash
   issueWidget --status
   ```

5. Clear the widget:
   ```bash
   issueWidget --clear
   ```

6. Quit the app:
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
