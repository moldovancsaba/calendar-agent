# Calendar Agent - Auto-Update Setup Guide

## Overview

Your Calendar Agent now includes automatic update checking and installation. The app periodically checks GitHub for new releases and notifies you when updates are available.

## How It Works

1. **Automatic Check**: The app checks for updates every hour (on launch and then hourly)
2. **Notification**: When an update is available, a banner appears in the app
3. **One-Click Install**: Click "Install Now" to download and install automatically
4. **Auto-Restart**: The app restarts automatically with the new version

## Setup Steps

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `calendar-agent`
3. Make it public (so update checks work without authentication)
4. Keep other settings as default

### Step 2: Initial Setup

```bash
cd /Users/Shared/Projects/claude/calendar-agent

# Initialize git if not already done
git init
git add .
git commit -m "Initial commit - Calendar Agent v1.0.0"

# Add your GitHub repository
git remote add origin https://github.com/YOUR_USERNAME/calendar-agent.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### Step 3: Create Your First Release

1. Go to your repository: https://github.com/YOUR_USERNAME/calendar-agent
2. Click "Releases" in the right sidebar
3. Click "Create a new release"
4. Fill in the details:
   - **Tag version**: `v1.0.0`
   - **Release title**: `Calendar Agent v1.0.0`
   - **Description**: Describe any changes

### Step 4: Build and Attach the App

Before creating a release, you need to build the app:

```bash
# Run the rebuild script
bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
```

This will:
- Compile the Swift code with auto-update functionality
- Create the app bundle
- Code-sign it
- Install it to /Applications/

### Step 5: Create App Archive

After building, create a release archive:

```bash
cd /Applications
zip -r Calendar-Agent.app.zip Calendar\ Agent.app
```

Move the zip file somewhere accessible, then upload it to your GitHub release.

### Step 6: Upload to Release

Back on the GitHub release page:
1. Click "Attach binaries by dragging and dropping" or "Attach files by clicking here"
2. Upload `Calendar-Agent.app.zip`
3. Click "Publish release"

## Version Format

The app uses semantic versioning. When creating releases, use tags like:
- `v1.0.0` - Full releases
- `v1.0.1` - Patch updates
- `v1.1.0` - Minor updates
- `v2.0.0` - Major updates

The app will automatically detect when a new version is higher than the current installed version.

## Testing Updates

### Test Version Checking

1. Launch the app
2. Check the Logs tab
3. You should see: "App is up to date" or "Update available: vX.X.X"

### Test Update Installation

1. Create a test release on GitHub with a higher version number
2. The app should detect it within an hour (or on next restart)
3. Click "Install Now" when the update banner appears
4. The app will download and install the update automatically

## Troubleshooting

### App can't find GitHub repository

**Problem**: Logs show "Update check failed"

**Solution**: Make sure your repository is public and the URL in the code matches:
```swift
private let updateCheckURL = "https://api.github.com/repos/YOUR_USERNAME/calendar-agent/releases/latest"
```

If your username is different, you'll need to update this in `Sources/CalendarAgent.swift` and rebuild.

### Updates not showing

**Problem**: Even though a new release exists, the app says it's up to date

**Causes**:
1. The version comparison might be failing
2. The app hasn't checked for updates yet (waits 1 hour or until restart)
3. The GitHub release tag format is wrong

**Solution**: 
- Restart the app to trigger an immediate update check
- Check the logs for any errors
- Make sure your release tag starts with `v` followed by numbers: `v1.0.0`

### Installation fails

**Problem**: "Installation failed" message in logs

**Causes**:
1. The downloaded file isn't a valid app bundle
2. Permission issues with /Applications/
3. The app can't write to /Applications/

**Solution**:
1. Make sure the ZIP file contains the correct app structure
2. Try rebuilding locally first: `bash rebuild-with-updates.sh`
3. Check that /Applications is writable: `ls -ld /Applications`

## Manual Rebuilding

If you need to rebuild the app locally:

```bash
# Full rebuild with bundling
bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh

# Or just compile
swift build -c release
```

## Advanced: Updating the Repository URL

If your GitHub username is different or you use a different repository name, update this line in `Sources/CalendarAgent.swift`:

```swift
private let updateCheckURL = "https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/releases/latest"
```

Then rebuild the app.

## How Versions Work

The app reads its current version from Info.plist:
```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

When you want to release an update:
1. Update this version in Info.plist
2. Build and test the app locally
3. Create a GitHub release with a matching tag (`v1.0.0`)
4. Attach the built app bundle to the release

Users with the old version will be notified about the update on their next launch or within an hour.

## What Gets Updated

The auto-update system replaces:
- The compiled Swift executable
- All SwiftUI components
- CRUD functionality
- Settings and data persist (stored in UserDefaults)

**Your data is safe**: 
- Tasks, workflows, and settings are stored separately and survive updates
- The Python backend script continues running without interruption

## Monitoring Updates

To check the update status programmatically, the app logs all update events:
- "Update available: vX.X.X" - New version found
- "App is up to date" - No new version available
- "Update check failed: ..." - Network or API error
- "Update installed successfully. Restarting app..." - Installation complete

Check the Logs tab in the app to see these messages.

## Next Steps

1. Create your GitHub repository
2. Run `bash rebuild-with-updates.sh` to build the app
3. Create your first release on GitHub
4. The app will automatically check and notify about future updates

That's it! You now have a self-updating macOS app. 🚀
