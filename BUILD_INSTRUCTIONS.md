# Build Instructions

## Setting up the Xcode Project

Since this is your first macOS native app, here's how to create the Xcode project:

### 1. Open Xcode
Launch Xcode (install from Mac App Store if you don't have it)

### 2. Create New Project
1. File → New → Project
2. Select **macOS** → **App**
3. Click **Next**

### 3. Configure Project
- **Product Name**: `IssueWidget`
- **Team**: Select your team (or leave as None for local development)
- **Organization Identifier**: `com.issuewidget` (or your preference)
- **Bundle Identifier**: Will auto-fill as `com.issuewidget.IssueWidget`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Uncheck** "Use Core Data"
- **Uncheck** "Include Tests"
- Click **Next**

### 4. Save Location
- Navigate to `/Users/alexander/development/issueWidget`
- **IMPORTANT**: Uncheck "Create Git repository"
- Click **Create**

### 5. Replace Generated Files
Xcode will create some default files. Delete these and use ours:
1. In Xcode's left sidebar, delete the generated `IssueWidgetApp.swift` and `ContentView.swift`
2. Drag the `IssueWidget` folder from Finder into your Xcode project
3. When prompted, select **"Create groups"** and check **"Copy items if needed"**

### 6. Add CLI Target
1. Click on the project name at the top of the left sidebar
2. At the bottom of the targets list, click the **+** button
3. Select **macOS** → **Command Line Tool**
4. **Product Name**: `issueWidget`
5. **Language**: Swift
6. Click **Finish**
7. Delete the generated `main.swift` for the CLI target
8. Add the CLI folder to this target

### 7. Add Shared Files
1. Create a new group called "Shared"
2. Add `IssueData.swift` to both targets (App and CLI)

### 8. Configure App Target
1. Select the **IssueWidget** app target
2. Go to **Signing & Capabilities**
3. Under **App Sandbox**, toggle it **OFF** (or configure entitlements)
4. Click **+ Capability** → **App Groups**
5. Add group: `group.com.issuewidget.shared`
6. Go to **Info** tab
7. Find "Application is agent (UIElement)" and set to **YES** (this hides from Dock)

### 9. Configure CLI Target
1. Select the **issueWidget** CLI target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → **App Groups**
4. Add group: `group.com.issuewidget.shared`
5. Go to **Build Settings**
6. Search for "Product Name"
7. Make sure it's set to `issueWidget` (lowercase)

### 10. Build and Run
1. Select the **IssueWidget** scheme at the top
2. Click the **Run** button (▶)
3. The app should launch and show "○" in your menu bar

### 11. Build CLI Tool
1. Select the **issueWidget** scheme
2. Product → Build
3. The CLI tool will be in `~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug/issueWidget`

## Easier Alternative: Manual Setup

If Xcode setup is too complex, I can help you create a simpler build script using `swiftc` directly.
