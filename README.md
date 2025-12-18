# IssueWidget

A macOS menu bar app that displays your current GitHub issue. Click the issue number in your menu bar to instantly open it in your browser. I use it within my AI Coding workflows.

## Features

- **Menu bar widget** showing current issue number (e.g., "#1")
- **Auto-launch** - CLI automatically starts the menu bar app
- **Git auto-detection** - Reads user/repo from current directory's git remote
- **One command** to set your current issue: `issueWidget --issue 1`
- **Click to open** - Opens GitHub issue in your default browser
- **Lightweight** - Native Swift, no dependencies

## Quick Start

```bash
# Build everything
./build.sh

# Install to ~/bin and ~/Applications
./install.sh

# Use it!
issueWidget --issue 1
```

The CLI tool automatically launches the menu bar app if it's not running.

## Installation

### Build from Source

```bash
./build.sh
```

This compiles:
- Menu bar app: `build/IssueWidget.app`
- CLI tool: `build/issueWidget`

### Install

```bash
./install.sh
```

Installs to:
- CLI: `~/bin/issueWidget`
- App: `~/Applications/IssueWidget.app`

The installer will warn you if `~/bin` is not in your PATH.

### Requirements

- macOS 13.0 (Ventura) or later
- Swift toolchain (included with Xcode or Command Line Tools)

## Usage

### Set Current Issue

From any git repository:
```bash
issueWidget --issue 1
```

Auto-detects user and repository from git remote URL.

Specify explicitly:
```bash
issueWidget --user phaoust --repo issueWidget --issue 1
```

### Check Current Issue

```bash
issueWidget --status
```

Returns JSON:
```json
{
  "user": "phaoust",
  "repository": "issueWidget",
  "issue": 1,
  "url": "https://github.com/phaoust/issueWidget/issues/1"
}
```

### Clear Current Issue

```bash
issueWidget --clear
```

Menu bar shows "○" when no issue is set.

### Quit the App

```bash
issueWidget --quit
```

## How It Works

1. **CLI Tool** writes issue data to shared storage (App Groups)
2. **Menu Bar App** reads from shared storage and displays the issue number
3. **Auto-Launch** - CLI checks if app is running and launches it if needed
4. **Click Handler** - Clicking the menu bar item opens the GitHub issue URL
5. **Git Detection** - Parses `git remote get-url origin` to extract user/repo

## Development

### Project Structure

```
IssueWidget/
├── IssueWidget/          # Menu bar app source
│   ├── IssueWidgetApp.swift
│   └── MenuBarManager.swift
├── CLI/                  # Command-line tool source
│   └── main.swift
├── Shared/               # Shared data models
│   └── IssueData.swift
├── build.sh              # Build script
├── install.sh            # Install script
└── Package.swift         # Swift Package Manager config
```

### Building with Xcode

See [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) for detailed Xcode setup.

### Architecture

- **Language**: Swift
- **UI Framework**: SwiftUI + AppKit
- **IPC**: App Groups + DistributedNotificationCenter
- **App Type**: LSUIElement (menu bar only, no dock icon)

## Troubleshooting

### CLI not found after install

Make sure `~/bin` is in your PATH:
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Git auto-detection not working

Ensure you're in a git repository with a GitHub remote:
```bash
git remote -v
```

Use explicit `--user` and `--repo` flags as fallback.

### App doesn't appear in menu bar

The CLI auto-launches the app, but you can manually check:
```bash
# Check if running
pgrep IssueWidget

# Manually launch
open ~/Applications/IssueWidget.app
```

## Optional: Auto-start on Login

1. System Settings → General → Login Items
2. Click "+" under "Open at Login"
3. Select IssueWidget from ~/Applications
4. The app will start automatically when you log in

## Contributing

This is a simple, focused tool. Contributions welcome for bug fixes and improvements.

## License

MIT License - see [LICENSE](LICENSE) file for details.
