# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

IssueWidget is a macOS menu bar app that displays the current issue being worked on. It consists of two components: a Swift menu bar application and a CLI tool. They communicate via App Groups and DistributedNotificationCenter.

## Build and Development Commands

```bash
# Build both CLI and app
./build.sh

# Install to ~/bin and ~/Applications
./install.sh

# Test locally without installing
./build/issueWidget --issue 266

# Use installed version
issueWidget --issue 1
issueWidget --status
issueWidget --clear
```

## Project Structure

- **IssueWidget/IssueWidget/** - Menu bar app (SwiftUI + AppKit)
  - `IssueWidgetApp.swift` - App entry point
  - `MenuBarManager.swift` - Menu bar UI and click handling
- **IssueWidget/CLI/** - Command-line tool
  - `main.swift` - CLI logic, argument parsing, git detection, app launcher
- **IssueWidget/Shared/** - Shared code between app and CLI
  - `IssueData.swift` - Data model and storage (App Groups + UserDefaults)

## Architecture

**IPC Mechanism**: CLI and app communicate via:
- App Groups (`group.com.issuewidget.shared`) for data persistence
- `DistributedNotificationCenter` for notifying app of changes

**Key Flow**:
1. CLI writes issue data to shared UserDefaults
2. CLI posts `IssueDataChanged` notification
3. Menu bar app receives notification and updates UI
4. Click on menu bar item opens issue URL in browser

**Build System**: Uses `swiftc` directly (not Xcode project). The `build.sh` script:
1. Compiles CLI tool as standalone binary
2. Compiles app and creates `.app` bundle with Info.plist
3. Sets `LSUIElement=true` to hide from Dock

## Multi-Platform Support

The app supports multiple git hosts and project management platforms:
- **Git hosts**: GitHub, GitLab (uses `/-/issues/` format), Bitbucket
- **Other platforms**: Trello (board URLs), Asana (project URLs)
- Host detection: Auto-detected from git remote URL or specified via `--host`
- URL construction: Platform-specific logic in `IssueData.url` computed property

## Git Auto-Detection

The CLI auto-detects user/repo/host from git remote URL:
- Parses both HTTPS and SSH format URLs
- Regex pattern: `([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})[:/]([^/]+)/([^/]+?)(\.git)?$`
- Extracts host, user, and repo from `git remote get-url origin`
- Fallback to manual `--user`, `--repo`, `--host` flags

## Testing

Manual testing workflow:
```bash
./build.sh
./build/issueWidget --issue 1   # Should launch app and show "#1" in menu bar
./build/issueWidget --status    # Should show JSON with current issue
./build/issueWidget --clear     # Should show "○" in menu bar
```

## Bundle Identifier

- App: `com.issuewidget.IssueWidget`
- App Group: `group.com.issuewidget.shared`

If changing these, update in:
- `build.sh` (Info.plist)
- `IssueData.swift` (suiteName)
- `CLI/main.swift` (bundleID check)
