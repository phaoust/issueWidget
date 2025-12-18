# Issue Widget - Project Description

## Overview
A minimal macOS widget that displays the current GitHub issue being worked on.

## Widget Display
- Shows: Repository name and issue number
- Primary focus: Issue number (e.g., "#266") - displayed prominently
- Secondary info: Repository name (smaller text)
- Interaction: Clicking the widget opens the GitHub issue in a browser

## Command Line Interface
A command line tool to control the widget:

```bash
# Set current issue
issueWidget --repo phaoust --issue 266

# Clear the widget (no current issue)
issueWidget --clear
```

## Technical Decisions

### Widget Type
**Primary Approach: macOS WidgetKit Desktop Widget** (native)
- Displays in Notification Center or on desktop
- Uses interactive buttons to open GitHub issues (available in macOS Sonoma+)
- Liquid glass design aesthetic

**Alternative Approach: Menu Bar App**
- If WidgetKit proves complex or impractical
- Lives in menu bar (top-right of screen)
- Shows issue number (e.g., "#266") as menu bar icon
- Click to open issue directly
- Optional: Dropdown menu with repository details and liquid glass design
- Simpler implementation, always visible, more reliable interactivity

### Technology Stack
- Swift + WidgetKit
- App Intents for interactive button actions
- Shared app group for CLI ↔ Widget communication

### Repository Format
Pragmatic approach with auto-detection:
1. Accept `--user` flag for GitHub username
2. Auto-detect from git config when run from a git repository:
   - Extract repository name from current directory's git remote
   - Extract username from git remote or git config
3. Fallback to explicit `--user` and `--repo` flags when not in a git directory

### Command Line Interface (Updated)
```bash
# Set current issue (auto-detect from git)
issueWidget --issue 266

# Set with explicit repo
issueWidget --repo phaoust --issue 266

# Set with explicit user
issueWidget --user microsoft --repo vscode --issue 12345

# Clear the widget
issueWidget --clear
```

## Requirements
- macOS Sonoma or later (for interactive widgets)
- Simple, minimal design with liquid glass aesthetic
- Issue number is the main visual element
- Repository name displayed but smaller
- Click to open issue URL in browser
- Auto-detection of git repository context
