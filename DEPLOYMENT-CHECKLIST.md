# Deployment Checklist

## Phase 1: Build & Test (5 minutes)

### Build the App
- [ ] Open Terminal
- [ ] Run: `bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh`
- [ ] Wait for "✅ Calendar Agent rebuilt with auto-update functionality!"
- [ ] Verify app at: `/Applications/Calendar Agent.app`

### Test the App
- [ ] Launch: Open `/Applications/Calendar Agent.app`
- [ ] Check Logs tab for: "App is up to date" or similar message
- [ ] Click through each tab (Logs, Tasks, Workflows, Settings, Status)
- [ ] Verify all CRUD operations still work:
  - [ ] Create a task
  - [ ] Complete a task
  - [ ] Create a workflow
  - [ ] Toggle workflow enabled/disabled
  - [ ] Delete task/workflow
- [ ] Quit the app: `Cmd+Q`

### Verify Installation
- [ ] Open Finder → Applications
- [ ] Verify "Calendar Agent" is there
- [ ] Verify it's not called "Python"
- [ ] Double-click to launch (should work)

**Status: ✅ Build Complete**

---

## Phase 2: GitHub Setup (10 minutes)

### Create GitHub Account (if needed)
- [ ] Go to https://github.com/signup
- [ ] Create free account
- [ ] Verify email

### Create Repository
- [ ] Go to https://github.com/new
- [ ] **Repository name**: `calendar-agent`
- [ ] **Description**: Calendar Agent - Native macOS App
- [ ] **Public** (required for update checks)
- [ ] Leave other options as default
- [ ] Click "Create repository"

### Initialize Git
- [ ] Open Terminal in project directory:
  ```bash
  cd /Users/Shared/Projects/claude/calendar-agent
  ```
- [ ] Run:
  ```bash
  git init
  git add .
  git commit -m "Initial commit: Calendar Agent v1.0.0"
  ```
- [ ] Copy the git remote URL from GitHub (green "Code" button)
- [ ] Run:
  ```bash
  git remote add origin [PASTE_GITHUB_URL_HERE]
  git branch -M main
  git push -u origin main
  ```
- [ ] Verify files appear on GitHub (refresh page)

**Status: ✅ GitHub Repository Created**

---

## Phase 3: Create Release (5 minutes)

### Create First Release
- [ ] Go to: https://github.com/YOUR_USERNAME/calendar-agent
- [ ] Click "Releases" (right side menu)
- [ ] Click "Create a new release"
- [ ] **Tag version**: `v1.0.0`
- [ ] **Release title**: `Calendar Agent v1.0.0`
- [ ] **Description**:
  ```
  Initial release of Calendar Agent with auto-update support.
  
  Features:
  - Native macOS application
  - Auto-update checking and installation
  - Task and workflow management
  - Professional UI with dark mode support
  ```

### Attach App Bundle
- [ ] Open Terminal:
  ```bash
  cd /Applications
  zip -r Calendar-Agent-1.0.0.zip "Calendar Agent.app"
  mv Calendar-Agent-1.0.0.zip ~/Desktop/
  ```
- [ ] Back on GitHub release page
- [ ] Scroll to bottom
- [ ] Drag `Calendar-Agent-1.0.0.zip` from Desktop to "Attach binaries" area
- [ ] Or click to browse and select the ZIP file
- [ ] Click "Publish release"

### Verify Release
- [ ] Refresh GitHub page
- [ ] Verify release tag shows `v1.0.0`
- [ ] Verify app ZIP is attached and downloadable
- [ ] Note the download URL (you'll need it for testing)

**Status: ✅ First Release Published**

---

## Phase 4: Test Auto-Update (10 minutes)

### Test Update Detection
- [ ] Quit Calendar Agent if running
- [ ] Launch it again: `/Applications/Calendar Agent.app`
- [ ] Check Logs tab
- [ ] Should see messages about update checking
- [ ] Should see: "App is up to date" (since you just released 1.0.0)

### Create Test Update
- [ ] Edit `Info.plist`:
  ```
  <key>CFBundleShortVersionString</key>
  <string>1.0.1</string>  <!-- Change 1.0.0 to 1.0.1 -->
  ```
- [ ] Save file
- [ ] Rebuild:
  ```bash
  bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
  ```
- [ ] This creates a new version at /Applications

### Create Release for New Version
- [ ] Create app ZIP:
  ```bash
  cd /Applications
  zip -r Calendar-Agent-1.0.1.zip "Calendar Agent.app"
  ```
- [ ] On GitHub: Create new release
- [ ] **Tag**: `v1.0.1`
- [ ] **Title**: `Calendar Agent v1.0.1`
- [ ] **Description**: "Bug fixes and improvements"
- [ ] Attach `Calendar-Agent-1.0.1.zip`
- [ ] Publish

### Test Update Installation
- [ ] Quit Calendar Agent
- [ ] Edit Info.plist to change version back to `1.0.0`
- [ ] Rebuild: `bash rebuild-with-updates.sh`
- [ ] Launch app (now running v1.0.0)
- [ ] Wait for update check (or restart app)
- [ ] Should see "Update Available v1.0.1" banner
- [ ] Click "Install Now"
- [ ] Watch progress bar
- [ ] App should restart with v1.0.1

### Verify Update Worked
- [ ] App restarted with new version
- [ ] All data still there (tasks, workflows, settings)
- [ ] Update banner gone (now on latest version)
- [ ] Logs show successful update

**Status: ✅ Auto-Update System Verified**

---

## Phase 5: Production Deployment (Ongoing)

### For Each Update
- [ ] Make code changes and test locally
- [ ] Update version in `Info.plist`
- [ ] Rebuild:
  ```bash
  bash /Users/Shared/Projects/claude/calendar-agent/rebuild-with-updates.sh
  ```
- [ ] Create app ZIP:
  ```bash
  cd /Applications
  zip -r Calendar-Agent-X.X.X.zip "Calendar Agent.app"
  ```
- [ ] Create GitHub release with version tag
- [ ] Attach app ZIP
- [ ] Publish release
- [ ] **Done!** Users get automatic notification 🎉

### Monitor Updates
- [ ] Check GitHub releases: https://github.com/YOUR_USERNAME/calendar-agent/releases
- [ ] See download counts
- [ ] Read user feedback/issues
- [ ] Update documentation as needed

**Status: ✅ Ready for Continuous Updates**

---

## Troubleshooting

### Build Fails
- [ ] Check internet connection
- [ ] Try again: `bash rebuild-with-updates.sh`
- [ ] Check Xcode installation: `xcode-select --install`

### GitHub Push Fails
- [ ] Check credentials: `git config --global user.email "you@example.com"`
- [ ] Try HTTPS instead of SSH in git remote URL

### Update Not Detected
- [ ] Restart app to force update check
- [ ] Check GitHub URL in `Sources/CalendarAgent.swift`
- [ ] Make sure repository is public
- [ ] Verify release tag starts with `v` (like `v1.0.1`)

### Update Installation Fails
- [ ] Check /Applications is writable: `ls -ld /Applications`
- [ ] Make sure ZIP file structure is correct
- [ ] Try manual installation: move app manually

---

## What's Next?

After completing this checklist:

1. **You have**: A working auto-updating macOS app
2. **Users can**: See and install updates automatically
3. **You do**: Just create releases on GitHub
4. **They see**: Automatic notifications and one-click install

### Future Enhancements
- Add custom app icon
- Add app preferences window
- Add keyboard shortcuts
- Add Notification Center integration
- Add menu bar extras
- Use a CDN for faster downloads

---

## Quick Reference

| Task | Time | Command |
|------|------|---------|
| Build | 1 min | `bash rebuild-with-updates.sh` |
| Create GitHub repo | 2 min | Web browser |
| Push to GitHub | 2 min | `git push -u origin main` |
| Create release | 3 min | Web browser + ZIP file |
| Test update | 5 min | Modify version, rebuild, create release |
| Deploy update | 3 min | Rebuild, create release, publish |

---

## Success Criteria

✅ You've completed deployment when:
- [ ] App builds without errors
- [ ] App launches from /Applications/
- [ ] All CRUD features work
- [ ] GitHub repository created and online
- [ ] First release published with app bundle
- [ ] Update checking works (seen in Logs)
- [ ] Update installation works (tested v1.0.0→v1.0.1)
- [ ] Data persists across updates

**Estimated total time: 30-45 minutes**

Once complete, you have a professional self-updating macOS app! 🚀
