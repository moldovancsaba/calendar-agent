# Quick Build & Deploy Guide

## For the Impatient 🚀

Get Calendar Agent with auto-updates running in 5 minutes.

## Step 1: Rebuild the App (5 minutes)

```bash
bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
```

That's it. The app is now updated with auto-update functionality and installed to `/Applications/`.

**What this does:**
- Compiles the Swift code
- Creates the app bundle
- Code-signs the app
- Installs to /Applications/
- Ready to use!

## Step 2: Test the Update System (2 minutes)

1. Launch the app: Open `/Applications/Calendar Agent.app`
2. Check the Logs tab
3. You should see: "App is up to date" or "Update check failed" (if GitHub not set up yet)

## Step 3: Set Up GitHub (5 minutes)

### 3A: Create Repository

1. Go to https://github.com/new
2. Create `calendar-agent` repository
3. Make it public
4. Create repository

### 3B: Initial GitHub Setup

```bash
cd /Users/Shared/Projects/claude/calendar-agent
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/calendar-agent.git
git branch -M main
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username.

### 3C: Create First Release

1. Go to https://github.com/YOUR_USERNAME/calendar-agent/releases/new
2. **Tag version**: `v1.0.0`
3. **Title**: `Calendar Agent v1.0.0`
4. Click "Publish release"

### 3D: Attach App Bundle

After creating the release:

```bash
# Create the app archive
cd /Applications
zip -r Calendar-Agent-1.0.0.zip "Calendar Agent.app"

# Move it somewhere
mv Calendar-Agent-1.0.0.zip ~/Downloads/
```

Back on the GitHub release page:
1. Click "Edit"
2. Click "Attach binaries..." or drag and drop
3. Upload the ZIP file from ~/Downloads/
4. Click "Update release"

## Step 4: Test Updates (Optional)

To test that updates work:

1. Change version in `Info.plist`:
   ```xml
   <key>CFBundleShortVersionString</key>
   <string>1.0.1</string>
   ```

2. Rebuild:
   ```bash
   bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
   ```

3. Create new release `v1.0.1` on GitHub with the updated app

4. Launch the old version of the app (or restart it)

5. You should see "Update Available" banner

6. Click "Install Now" to test the update process

## That's It! 

Your app now:
- ✅ Auto-checks for updates hourly
- ✅ Notifies users when updates are available
- ✅ Installs updates with one click
- ✅ Automatically restarts with new version

## Common Tasks

### Update the App

1. Make code changes
2. Update version in Info.plist: `<string>1.0.2</string>`
3. Rebuild: `bash rebuild-with-updates.sh`
4. Create GitHub release with tag `v1.0.2`
5. Attach new app ZIP
6. Users get notified automatically ✨

### Check Update Status

Launch the app and look at Logs tab for:
- "App is up to date" ← All good
- "Update available: vX.X.X" ← Update ready
- "Update check failed: ..." ← Problem (check GitHub setup)

### Fix GitHub Connection Issues

Edit `Sources/CalendarAgent.swift`:

Find this line (around line 55):
```swift
private let updateCheckURL = "https://api.github.com/repos/moldovan/calendar-agent/releases/latest"
```

Change it to:
```swift
private let updateCheckURL = "https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/releases/latest"
```

Then rebuild.

## Version Format

When creating releases, use semantic versioning:

| Version | Example | When to Use |
|---------|---------|------------|
| Major | v2.0.0 | Breaking changes |
| Minor | v1.1.0 | New features |
| Patch | v1.0.1 | Bug fixes |

The app automatically detects which is newer!

## Troubleshooting

| Problem | Solution |
|---------|----------|
| App says "up to date" when new version exists | Restart the app or wait up to 1 hour |
| "Update check failed" | Check GitHub URL in CalendarAgent.swift, check internet |
| Can't find GitHub release | Make sure tag starts with `v` (like `v1.0.0`) |
| Installation fails | Make sure ZIP contains `Calendar Agent.app` at root |

## Next Steps

1. See `AUTO-UPDATE-SETUP.md` for detailed setup guide
2. See `UPDATE-IMPLEMENTATION.md` for technical details
3. See `DEVELOPMENT.md` for code customization

## Done! 🎉

You now have a professional macOS app with auto-updates!

- Users get notified about updates automatically
- One-click installation
- Data preserved across updates
- No manual update process needed

That's everything needed for self-updating app distribution. 🚀
