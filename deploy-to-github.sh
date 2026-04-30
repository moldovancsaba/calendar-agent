#!/bin/bash

# Calendar Agent - GitHub Deployment Script
# This script automates the process of deploying the Calendar Agent to GitHub

set -e

echo "🚀 Calendar Agent - GitHub Deployment Script"
echo "=============================================="
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if we're in the calendar-agent directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Please run this script from the calendar-agent directory"
    exit 1
fi

# Get GitHub username
echo "📝 GitHub Configuration"
echo "======================"
read -p "Enter your GitHub username (default: moldovan): " GITHUB_USERNAME
GITHUB_USERNAME=${GITHUB_USERNAME:-moldovan}

# Check if remote already exists
if git remote get-url origin &> /dev/null; then
    echo ""
    echo "⚠️  Git remote 'origin' already exists:"
    git remote get-url origin
    read -p "Do you want to replace it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
    else
        echo "ℹ️  Keeping existing remote"
        SKIP_REMOTE=true
    fi
fi

# Add GitHub remote if needed
if [ -z "$SKIP_REMOTE" ]; then
    echo ""
    echo "🔗 Adding GitHub remote..."
    REPO_URL="https://github.com/${GITHUB_USERNAME}/calendar-agent.git"
    git remote add origin "$REPO_URL"
    echo "✅ Remote added: $REPO_URL"
fi

# Check branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo ""
echo "📊 Repository Status"
echo "===================="
echo "Current branch: $CURRENT_BRANCH"
echo "Commits: $(git rev-list --count HEAD)"
echo ""

# Ask if user wants to rename branch to main
if [ "$CURRENT_BRANCH" = "master" ]; then
    read -p "Rename branch 'master' to 'main'? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Renaming branch to main..."
        git branch -m master main
        echo "✅ Branch renamed to main"
        CURRENT_BRANCH="main"
    fi
fi

# Push to GitHub
echo ""
echo "📤 Pushing to GitHub..."
echo "======================="
echo ""
echo "This will push all commits and tags to: origin/$CURRENT_BRANCH"
echo ""
echo "If prompted for credentials:"
echo "  - Username: your GitHub username"
echo "  - Password: your GitHub Personal Access Token"
echo "    (NOT your GitHub password)"
echo ""
echo "Create a token at: https://github.com/settings/tokens"
echo "  - Scope: repo (Full control of private repositories)"
echo ""
read -p "Ready to push? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push -u origin "$CURRENT_BRANCH"
    echo "✅ Code pushed successfully!"
else
    echo "⏭️  Push cancelled"
    exit 1
fi

# Create git tag for version
echo ""
echo "🏷️  Creating version tag..."
VERSION=$(grep -A 1 'CFBundleShortVersionString' Info.plist | grep string | sed 's/<[^>]*>//g' | xargs)
if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
fi
TAG="v${VERSION}"

if ! git rev-parse "$TAG" &> /dev/null; then
    echo "Creating tag: $TAG"
    git tag -a "$TAG" -m "Release $TAG: Calendar Agent"
    git push origin "$TAG"
    echo "✅ Tag created and pushed: $TAG"
else
    echo "ℹ️  Tag $TAG already exists"
fi

echo ""
echo "✨ GitHub Deployment Complete!"
echo "==============================="
echo ""
echo "📍 Next Steps:"
echo "1. Visit: https://github.com/$GITHUB_USERNAME/calendar-agent"
echo "2. Create a release for tag: $TAG"
echo "3. Upload the app bundle: /Applications/Calendar Agent.app"
echo ""
echo "📖 For detailed instructions, see: GITHUB-DEPLOYMENT.md"
echo ""
echo "🎉 Your Calendar Agent is ready for distribution!"
