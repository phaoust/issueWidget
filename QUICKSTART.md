# Quick Start Guide

## Build & Run (Easiest Method)

```bash
# 1. Build everything
./build.sh

# 2. Launch the menu bar app
open build/IssueWidget.app

# 3. Set your current issue
./build/issueWidget --user phaoust --repo myproject --issue 266

# 4. Look at your menu bar - you should see "#266"
# 5. Click it - your browser opens the GitHub issue
```

## Install for Daily Use

```bash
# Install CLI to PATH
sudo cp build/issueWidget /usr/local/bin/

# Copy app to Applications
cp -r build/IssueWidget.app /Applications/

# Launch app (do this once, then add to Login Items)
open /Applications/IssueWidget.app
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

1. **Menu Bar Icon**: Shows current issue number (e.g., "#266")
2. **Tooltip**: Hover to see repository (e.g., "phaoust/myproject")
3. **Click**: Opens GitHub issue in your default browser
4. **CLI Updates**: Running the CLI command updates the menu bar in real-time

## Troubleshooting

### App doesn't show in menu bar
- Check if app is running: Activity Monitor → search "IssueWidget"
- Relaunch: `killall IssueWidget && open build/IssueWidget.app`

### CLI doesn't update the menu bar
- Make sure the app is running first
- Check app group permissions (should work without sandbox)

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
