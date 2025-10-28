# Release Deployment Scripts

Scripts for downloading and deploying releases from GitHub.

## download-latest-release.sh

Downloads the latest release artifacts from the GitHub repository to a local directory.

### Features

- Downloads latest release automatically
- Supports filtering by platform (windows, macos, linux, android, or all)
- Organizes downloads by release tag
- Creates symlink to latest release
- Supports GitHub token for private repos or rate limits
- Provides detailed progress and error reporting

### Prerequisites

- `curl` - for HTTP requests
- `jq` - for JSON parsing (install with: `brew install jq` on macOS, `apt-get install jq` on Linux)

### Usage

#### Basic Usage

```bash
# Download all platforms to default directory (./releases)
./scripts/download-latest-release.sh
```

#### Platform-Specific Downloads

```bash
# Download only Windows releases
PLATFORM=windows ./scripts/download-latest-release.sh

# Download only macOS releases
PLATFORM=macos ./scripts/download-latest-release.sh

# Download only Linux releases
PLATFORM=linux ./scripts/download-latest-release.sh

# Download only Android releases
PLATFORM=android ./scripts/download-latest-release.sh
```

#### Custom Download Directory

```bash
# Download to custom directory
DOWNLOAD_DIR=/opt/rule7/releases ./scripts/download-latest-release.sh

# Download Linux releases to server directory
PLATFORM=linux DOWNLOAD_DIR=/var/www/rule7/releases ./scripts/download-latest-release.sh
```

#### Using GitHub Token

For private repositories or to avoid rate limits:

```bash
# Set token as environment variable
GITHUB_TOKEN=ghp_your_token_here ./scripts/download-latest-release.sh

# Or export it first
export GITHUB_TOKEN=ghp_your_token_here
./scripts/download-latest-release.sh
```

#### Using Makefile

```bash
# Download all platforms
make download-release

# Download specific platform
PLATFORM=linux make download-release

# Download to custom directory
DOWNLOAD_DIR=/opt/releases PLATFORM=linux make download-release
```

### Output Structure

Downloads are organized by release tag:

```
releases/
├── v1.0.0/
│   ├── rule7_app-windows.zip
│   ├── rule7_app-installer.exe
│   ├── rule7_app-macos.zip
│   ├── rule7_app-macos.dmg
│   ├── rule7_app-linux.tar.gz
│   ├── rule7_app-linux.AppImage
│   └── rule7_app-android.apk
├── v1.0.1/
│   └── ...
└── latest -> v1.0.1  (symlink to latest)
```

### Server Deployment

#### Manual Deployment

1. Download the release:
```bash
PLATFORM=linux DOWNLOAD_DIR=/tmp/releases ./scripts/download-latest-release.sh
```

2. Extract and deploy:
```bash
# Extract Linux bundle
tar -xzf /tmp/releases/latest/rule7_app-linux.tar.gz -C /opt/rule7/

# Or copy AppImage
cp /tmp/releases/latest/rule7_app-linux.AppImage /opt/rule7/
chmod +x /opt/rule7/rule7_app-linux.AppImage
```

#### Using Makefile for Server Deployment

```bash
# Deploy Linux release to server
make deploy-release-server SERVER=user@example.com:/opt/rule7 PLATFORM=linux
```

This will:
1. Download the latest Linux release
2. Upload files to the specified server via SCP
3. Provide deployment confirmation

### Example: Automated Server Deployment Script

Here's an example script for automated deployment to a server:

```bash
#!/bin/bash
# deploy-to-server.sh

SERVER="user@example.com"
REMOTE_PATH="/opt/rule7/app"
PLATFORM="linux"

# Download latest release
PLATFORM=$PLATFORM ./scripts/download-latest-release.sh

# Get latest release path
LATEST=$(readlink -f releases/latest)

# Extract Linux bundle
echo "Extracting release..."
tar -xzf "$LATEST/rule7_app-linux.tar.gz" -C /tmp/rule7-extract/

# Upload to server
echo "Uploading to server..."
scp -r /tmp/rule7-extract/bundle/* "$SERVER:$REMOTE_PATH/"

# Cleanup
rm -rf /tmp/rule7-extract/

echo "Deployment complete!"
```

### Troubleshooting

#### Rate Limit Errors

If you hit GitHub API rate limits, use a GitHub token:

```bash
GITHUB_TOKEN=ghp_your_token_here ./scripts/download-latest-release.sh
```

#### Missing Dependencies

Install missing dependencies:

**macOS:**
```bash
brew install jq curl
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y jq curl
```

**Linux (CentOS/RHEL):**
```bash
sudo yum install -y jq curl
```

#### No Releases Found

If the script reports no releases:
- Verify the repository has releases: https://github.com/Ryahn/Tools-Repo/releases
- Check that releases have assets attached
- Ensure you have proper access (use GITHUB_TOKEN for private repos)

## Integration with CI/CD

You can integrate this script into CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Download Latest Release
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    PLATFORM: linux
    DOWNLOAD_DIR: /tmp/releases
  run: |
    chmod +x scripts/download-latest-release.sh
    ./scripts/download-latest-release.sh
```

