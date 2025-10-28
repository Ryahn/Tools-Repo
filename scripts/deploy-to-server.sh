#!/bin/bash
# Example Server Deployment Script
# Customize this script for your specific server deployment needs

set -euo pipefail

# Configuration - Customize these for your server
SERVER="${SERVER:-user@example.com}"
REMOTE_PATH="${REMOTE_PATH:-/opt/rule7/app}"
PLATFORM="${PLATFORM:-linux}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-./releases}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Check if download script exists
if [ ! -f "./scripts/download-latest-release.sh" ]; then
    echo "Error: download-latest-release.sh not found"
    echo "Please run this script from the project root directory"
    exit 1
fi

info "Starting deployment process..."
info "Server: $SERVER"
info "Remote Path: $REMOTE_PATH"
info "Platform: $PLATFORM"

# Step 1: Download latest release
info "Step 1: Downloading latest $PLATFORM release..."
PLATFORM="$PLATFORM" DOWNLOAD_DIR="$DOWNLOAD_DIR" ./scripts/download-latest-release.sh

# Step 2: Get latest release path
LATEST_RELEASE=$(readlink -f "$DOWNLOAD_DIR/latest" 2>/dev/null || echo "")
if [ -z "$LATEST_RELEASE" ] || [ ! -d "$LATEST_RELEASE" ]; then
    echo "Error: Could not find latest release in $DOWNLOAD_DIR"
    exit 1
fi

success "Found release: $(basename "$LATEST_RELEASE")"

# Step 3: Prepare files based on platform
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

info "Step 2: Preparing files for deployment..."

case "$PLATFORM" in
    linux)
        # Extract Linux bundle
        if [ -f "$LATEST_RELEASE/rule7_app-linux.tar.gz" ]; then
            info "Extracting Linux bundle..."
            tar -xzf "$LATEST_RELEASE/rule7_app-linux.tar.gz" -C "$TEMP_DIR"
            DEPLOY_SOURCE="$TEMP_DIR/bundle"
        elif [ -f "$LATEST_RELEASE/rule7_app-linux.AppImage" ]; then
            info "Preparing AppImage..."
            mkdir -p "$TEMP_DIR/app"
            cp "$LATEST_RELEASE/rule7_app-linux.AppImage" "$TEMP_DIR/app/"
            chmod +x "$TEMP_DIR/app/rule7_app-linux.AppImage"
            DEPLOY_SOURCE="$TEMP_DIR/app"
        else
            echo "Error: No Linux release files found"
            exit 1
        fi
        ;;
    macos)
        # Extract macOS app bundle
        if [ -f "$LATEST_RELEASE/rule7_app-macos.zip" ]; then
            info "Extracting macOS bundle..."
            unzip -q "$LATEST_RELEASE/rule7_app-macos.zip" -d "$TEMP_DIR"
            DEPLOY_SOURCE="$TEMP_DIR"
        else
            echo "Error: No macOS release files found"
            exit 1
        fi
        ;;
    windows)
        # Extract Windows bundle
        if [ -f "$LATEST_RELEASE/rule7_app-windows.zip" ]; then
            info "Extracting Windows bundle..."
            unzip -q "$LATEST_RELEASE/rule7_app-windows.zip" -d "$TEMP_DIR"
            DEPLOY_SOURCE="$TEMP_DIR"
        else
            echo "Error: No Windows release files found"
            exit 1
        fi
        ;;
    *)
        # Default: upload all files as-is
        info "Preparing all files..."
        cp -r "$LATEST_RELEASE"/* "$TEMP_DIR/"
        DEPLOY_SOURCE="$TEMP_DIR"
        ;;
esac

# Step 4: Upload to server
info "Step 3: Uploading to server..."
if scp -r "$DEPLOY_SOURCE"/* "$SERVER:$REMOTE_PATH/"; then
    success "Files uploaded successfully"
else
    echo "Error: Failed to upload files to server"
    exit 1
fi

# Step 5: Optional: Run post-deployment commands
if [ -n "${POST_DEPLOY_COMMAND:-}" ]; then
    info "Step 4: Running post-deployment commands..."
    ssh "$SERVER" "$POST_DEPLOY_COMMAND"
    success "Post-deployment commands completed"
fi

success "Deployment complete!"
info "Release deployed to: $SERVER:$REMOTE_PATH"

