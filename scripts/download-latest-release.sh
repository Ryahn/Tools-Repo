#!/bin/bash
# Download Latest Release Script
# Downloads the latest release artifacts from GitHub to a specified directory

set -euo pipefail

# Configuration
REPO_OWNER="Ryahn"
REPO_NAME="Tools-Repo"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-./releases}"
PLATFORM="${PLATFORM:-all}"  # Options: all, windows, macos, linux, android
GITHUB_TOKEN="${GITHUB_TOKEN:-}"  # Optional: for private repos or rate limit

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    local missing=()
    
    if ! command_exists curl; then
        missing+=("curl")
    fi
    
    if ! command_exists jq; then
        missing+=("jq")
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        error "Missing required dependencies: ${missing[*]}. Please install them first."
    fi
}

# Get latest release info from GitHub API
get_latest_release() {
    local api_url="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
    local headers=()
    
    if [ -n "$GITHUB_TOKEN" ]; then
        headers=(-H "Authorization: token ${GITHUB_TOKEN}")
        info "Using GitHub token for authentication"
    fi
    
    info "Fetching latest release information..."
    local response
    response=$(curl -s "${headers[@]}" "$api_url")
    
    if echo "$response" | jq -e '.message' >/dev/null 2>&1; then
        local msg
        msg=$(echo "$response" | jq -r '.message')
        error "GitHub API error: $msg"
    fi
    
    echo "$response"
}

# Download a file
download_file() {
    local url=$1
    local output_file=$2
    local headers=()
    
    if [ -n "$GITHUB_TOKEN" ]; then
        headers=(-H "Authorization: token ${GITHUB_TOKEN}")
    fi
    
    info "Downloading $(basename "$output_file")..."
    if curl -L -f -s "${headers[@]}" "$url" -o "$output_file"; then
        success "Downloaded: $(basename "$output_file")"
        return 0
    else
        warning "Failed to download: $(basename "$output_file")"
        return 1
    fi
}

# Filter assets by platform
filter_assets() {
    local platform=$1
    local assets=$2
    
    case "$platform" in
        windows)
            echo "$assets" | jq 'map(select(.name | contains("windows")))'
            ;;
        macos)
            echo "$assets" | jq 'map(select(.name | contains("macos")))'
            ;;
        linux)
            echo "$assets" | jq 'map(select(.name | contains("linux")))'
            ;;
        android)
            echo "$assets" | jq 'map(select(.name | contains("android")))'
            ;;
        all)
            echo "$assets"
            ;;
        *)
            error "Invalid platform: $platform. Use: all, windows, macos, linux, or android"
            ;;
    esac
}

# Main function
main() {
    check_dependencies
    
    # Get release info
    local release_info
    release_info=$(get_latest_release)
    
    local tag_name
    local release_name
    tag_name=$(echo "$release_info" | jq -r '.tag_name')
    release_name=$(echo "$release_info" | jq -r '.name // .tag_name')
    
    success "Found latest release: $release_name ($tag_name)"
    
    # Get assets
    local assets
    assets=$(echo "$release_info" | jq '.assets')
    local asset_count
    asset_count=$(echo "$assets" | jq 'length')
    
    if [ "$asset_count" -eq 0 ]; then
        warning "No assets found in this release"
        exit 0
    fi
    
    # Filter by platform
    local filtered_assets
    filtered_assets=$(filter_assets "$PLATFORM" "$assets")
    local filtered_count
    filtered_count=$(echo "$filtered_assets" | jq 'length')
    
    if [ "$filtered_count" -eq 0 ]; then
        warning "No assets found for platform: $PLATFORM"
        exit 0
    fi
    
    info "Found $filtered_count asset(s) for platform: $PLATFORM"
    
    # Create download directory
    local download_path="${DOWNLOAD_DIR}/${tag_name}"
    mkdir -p "$download_path"
    success "Created download directory: $download_path"
    
    # Download each asset
    local downloaded=0
    local failed=0
    
    while IFS= read -r asset; do
        local name
        local url
        name=$(echo "$asset" | jq -r '.name')
        url=$(echo "$asset" | jq -r '.browser_download_url')
        local output_file="${download_path}/${name}"
        
        if download_file "$url" "$output_file"; then
            ((downloaded++))
        else
            ((failed++))
        fi
    done < <(echo "$filtered_assets" | jq -c '.[]')
    
    # Summary
    echo ""
    success "Download complete!"
    info "Downloaded: $downloaded file(s)"
    if [ $failed -gt 0 ]; then
        warning "Failed: $failed file(s)"
    fi
    info "Release files saved to: $download_path"
    
    # Show file sizes
    echo ""
    info "Downloaded files:"
    ls -lh "$download_path" | tail -n +2 | awk '{printf "  %9s  %s\n", $5, $9}'
    
    # Create a symlink to latest
    if [ -L "${DOWNLOAD_DIR}/latest" ]; then
        rm "${DOWNLOAD_DIR}/latest"
    fi
    ln -s "$tag_name" "${DOWNLOAD_DIR}/latest"
    success "Created symlink: ${DOWNLOAD_DIR}/latest -> $tag_name"
}

# Help message
show_help() {
    cat << EOF
Download Latest Release Script

Downloads the latest release artifacts from GitHub to a specified directory.

Usage:
    $0 [OPTIONS]

Environment Variables:
    DOWNLOAD_DIR      Directory to download releases (default: ./releases)
    PLATFORM          Platform to download (default: all)
                      Options: all, windows, macos, linux, android
    GITHUB_TOKEN      Optional GitHub token for private repos or rate limits

Examples:
    # Download all platforms to default directory
    $0

    # Download only Windows releases to custom directory
    PLATFORM=windows DOWNLOAD_DIR=/opt/releases $0

    # Download with GitHub token (for private repos or rate limits)
    GITHUB_TOKEN=ghp_xxxxx $0

    # Download only Linux releases
    PLATFORM=linux $0

Requirements:
    - curl (for HTTP requests)
    - jq (for JSON parsing)

EOF
}

# Parse arguments
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    show_help
    exit 0
fi

# Run main function
main

