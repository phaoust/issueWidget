# Quick Start Guide

## Build & Run (Easiest Method)

```bash
# 1. Build everything
./build.sh

# 2. Set your current issue (auto-launches the app!)
./build/issueWidget --user phaoust --repo myproject --issue 266

# 3. Look at your menu bar - you should see "#266"
# 4. Click it - your browser opens the GitHub issue
```

The CLI automatically launches the menu bar app if it's not running.

## Install for Daily Use

### Easy Install (Recommended)
```bash
./install.sh
```

This installs:
- CLI tool to `~/bin/issueWidget`
- App to `~/Applications/IssueWidget.app`

The script will warn you if `~/bin` is not in your PATH.

### Manual Install
```bash
# Install CLI to ~/bin
cp build/issueWidget ~/bin/
chmod +x ~/bin/issueWidget

# Copy app to Applications
cp -r build/IssueWidget.app ~/Applications/
```

### Add to Login Items (Auto-start)
1. System Settings → General → Login Items
2. Click "+" under "Open at Login"
3. Select IssueWidget.app from Applications
4. Done! App will start automatically when you log in

## Usage Examples

### From a Git Repository
When you're inside a git repository with a GitHub remote:

```bash
cd ~/my-github-project
issueWidget --issue 266
```

Auto-detects user and repo from git remote URL.

### Explicit Repository
```bash
issueWidget --user microsoft --repo vscode --issue 12345
```

### Check Current Issue
```bash
issueWidget --status
```

Returns JSON with current issue info:
```json
{
  "user": "phaoust",
  "repository": "myproject",
  "issue": 266,
  "url": "https://github.com/phaoust/myproject/issues/266"
}
```

Returns empty object `{}` when no issue is set.

### Clear Current Issue
```bash
issueWidget --clear
```

The menu bar will show "○" when no issue is set.

### Quit the App
```bash
issueWidget --quit
```

Shuts down the menu bar app.

## How It Works

1. **Auto-Launch**: CLI automatically launches the menu bar app if not running
2. **Menu Bar Icon**: Shows current issue number (e.g., "#266")
3. **Tooltip**: Hover to see repository (e.g., "phaoust/myproject")
4. **Click**: Opens GitHub issue in your default browser
5. **CLI Updates**: Running the CLI command updates the menu bar in real-time

## Troubleshooting

### App doesn't show in menu bar
- The CLI auto-launches the app, but you can manually launch: `open build/IssueWidget.app`
- Check if app is running: Activity Monitor → search "IssueWidget"

### Git auto-detection not working
- Make sure you're in a git repository: `git remote -v`
- Use explicit `--user` and `--repo` flags as fallback

## What's Next?

- The app runs invisibly in your menu bar
- Use the CLI command whenever you switch issues
- Click the number to quickly open the issue in your browser
- Add to your shell aliases for even faster access:
  ```bash
  alias issue='issueWidget --issue'
  ```
  Then just: `issue 266`
