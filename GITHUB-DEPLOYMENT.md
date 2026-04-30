# GitHub Deployment Guide - Calendar Agent v1.0.0

## Status
✅ Git repository initialized
✅ All source files committed
⏳ Pending: GitHub repository creation and remote push

## Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository with these settings:
   - **Repository name:** `calendar-agent`
   - **Description:** Native SwiftUI macOS application with task management, workflows, and auto-update functionality
   - **Public:** Yes (required for auto-updates to work)
   - **Initialize with:** No (we already have commits)
3. Click "Create repository"

## Step 2: Add GitHub Remote and Push

After creating the repository, run these commands in your terminal:

```bash
cd /Users/Shared/Projects/claude/calendar-agent

# Add GitHub as remote
git remote add origin https://github.com/moldovan/calendar-agent.git

# Rename branch to main (optional but recommended)
git branch -m master main

# Push to GitHub
git push -u origin main
```

**Note:** When prompted for credentials, use:
- Username: your GitHub username
- Password: your GitHub Personal Access Token (not your GitHub password)
  - Create one at: https://github.com/settings/tokens
  - Required scopes: `repo` (full control of private repositories)

## Step 3: Create First Release

Once the code is pushed, create the first release:

1. Go to: https://github.com/moldovan/calendar-agent/releases/new
2. Fill in the release details:
   - **Tag version:** `v1.0.0`
   - **Release title:** `Calendar Agent v1.0.0`
   - **Description:** 
     ```
     ## ✨ Features
     - Native SwiftUI macOS application
     - Complete task management system
     - Workflow automation with scheduling
     - Task dependencies and blocking logic
     - Priority-based task coloring
     - Persistent execution logs
     - Custom function system
     - Advanced filtering and search
     - Automatic update checking via GitHub
     
     ## 📦 System Requirements
     - macOS 13.0 or later
     - Apple Silicon (M1+) or Intel (x86_64)
     
     ## 🚀 What's New in v1.0.0
     - Initial release of native macOS version
     - Complete rewrite from Python/PyQt6 to Swift/SwiftUI
     - Professional UI with dark mode support
     - All features from previous versions plus enhancements
     ```

3. **Upload the app bundle:**
   - Click "Attach binaries by dropping them here..."
   - Locate: `/Applications/Calendar Agent.app`
   - Or compress it first:
     ```bash
     cd /Applications
     zip -r ~/Downloads/Calendar-Agent-v1.0.0.zip Calendar\ Agent.app
     ```
   - Then upload the ZIP file

4. **Set as pre-release:** Uncheck (this is the stable 1.0.0 release)

5. Click "Publish release"

## Step 4: Verify Auto-Update System

Once the release is published, the app will automatically detect it:

1. Launch Calendar Agent
2. Go to **Settings** tab
3. Check the **Logs** tab
4. You should see messages like:
   ```
   [timestamp] Checking for updates...
   [timestamp] Found new version: v1.0.0
   ```

If you see an update banner, click "Install Now" to test the update mechanism.

## Step 5: Subsequent Releases

For future releases, follow this workflow:

1. Make changes and test locally
2. Update version in `Info.plist`:
   ```xml
   <key>CFBundleShortVersionString</key>
   <string>1.0.1</string>  <!-- Change this -->
   ```
3. Rebuild the app:
   ```bash
   bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
   ```
4. Create a git tag and push:
   ```bash
   git tag v1.0.1
   git push origin main --tags
   ```
5. Create a new GitHub release with the updated app bundle

## Troubleshooting

### Git Push Fails - Authentication Issues

If you get "fatal: Authentication failed":

1. Generate a GitHub Personal Access Token:
   - Visit: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Select scopes: `repo` (check "Full control of private repositories")
   - Copy the generated token

2. When git asks for password, paste the token instead

3. To save credentials for future use:
   ```bash
   git config --global credential.helper osxkeychain
   ```

### Release Not Appearing in App

If the app isn't detecting the new release:

1. Verify the GitHub URL in `CalendarAgent.swift` line ~73:
   ```swift
   private let updateCheckURL = "https://api.github.com/repos/moldovan/calendar-agent/releases/latest"
   ```

2. Test the API endpoint directly:
   ```bash
   curl https://api.github.com/repos/moldovan/calendar-agent/releases/latest
   ```

3. Ensure the release tag **starts with `v`** (e.g., `v1.0.0`)

4. Force a version check by restarting the app

## Success Indicators

✅ Git repository created locally
✅ Initial commit with all source files
✅ GitHub remote configured
✅ Code pushed to main branch
✅ GitHub repository public and accessible
✅ First release (v1.0.0) created
✅ App bundle attached to release
✅ Auto-update system verifies new version
✅ Users can download and install updates

## Next Steps After Deployment

1. **Share the link:** https://github.com/moldovan/calendar-agent
2. **Monitor issues:** Watch the Issues tab for bug reports
3. **Plan future releases:** Use Milestones and Projects
4. **Engage the community:** Consider adding a CONTRIBUTING.md

## Quick Reference

| Command | Purpose |
|---------|---------|
| `git status` | Check current status |
| `git log` | View commit history |
| `git remote -v` | Show configured remotes |
| `git push origin main` | Push commits to GitHub |
| `git tag v1.0.1` | Create a version tag |
| `git push origin --tags` | Push all tags |

## Files in This Release

- **Sources/CalendarAgent.swift** - Main app entry point and view model (1144 lines)
- **Sources/ContentView.swift** - Complete SwiftUI user interface (1356 lines)
- **Sources/AppDelegate.swift** - App lifecycle management
- **Package.swift** - Swift Package Manager configuration
- **Info.plist** - macOS app metadata
- **Documentation:** README.md, DEVELOPMENT.md, AUTO-UPDATE-SETUP.md
- **Build scripts:** build.sh, build-bundle.sh, rebuild-with-updates.sh

## Final Notes

✨ **Your Calendar Agent is production-ready and self-updating!**

The app is now:
- Compiled as a native macOS binary
- Stored in version control with full history
- Released on GitHub with automatic update capability
- Ready for distribution to other users

Users who install v1.0.0 will automatically:
- Check for updates hourly
- Be notified of new releases
- Download and install updates with one click
- Have all their data preserved across updates

---

**Questions?** Check the DEVELOPMENT.md and AUTO-UPDATE-SETUP.md files for more details.

**Last Updated:** April 30, 2026
**Status:** Ready for GitHub deployment
