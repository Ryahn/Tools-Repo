# rule7_app

A Flutter application for Rule7.

## Getting Started

This project is a Flutter application built with cross-platform support for Windows, macOS, Linux, and Android.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building Releases

This project uses GitHub Actions to automatically build release artifacts for all supported platforms when version tags are pushed to the repository.

### How Release Builds Work

When you push a Git tag matching the pattern `v*` (e.g., `v1.0.0`, `v1.2.3`), GitHub Actions will automatically:

1. Trigger the build workflow
2. Build release artifacts for all platforms in parallel:
   - **Windows**: ZIP archive and EXE installer
   - **macOS**: ZIP archive and DMG installer
   - **Linux**: TAR.GZ archive and AppImage
   - **Android**: Unsigned APK
3. Create a GitHub Release with the tag
4. Upload all build artifacts to the release

The builds typically take 15-30 minutes to complete. You can monitor progress in the **Actions** tab on GitHub.

### Creating a Release

To create a new release, follow these steps:

#### 1. Update the Version

First, update the version number in `pubspec.yaml`:

```yaml
version: 1.0.1+2  # Format: major.minor.patch+buildNumber
```

#### 2. Commit the Version Change

```bash
git add pubspec.yaml
git commit -m "Bump version to 1.0.1"
```

#### 3. Create an Annotated Tag

Annotated tags are recommended as they store metadata:

```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
```

The tag name must start with `v` (lowercase) followed by the version number (e.g., `v1.0.0`, `v1.2.3`, `v2.0.0-beta.1`).

#### 4. Push Commits and Tags

```bash
# Push your commits first
git push origin main

# Then push the tag (this triggers the build workflow)
git push origin v1.0.1
```

### Managing Tags

**List all tags:**
```bash
git tag
```

**View tag details:**
```bash
git show v1.0.1
```

**Delete a tag locally:**
```bash
git tag -d v1.0.0
```

**Delete a tag remotely (if you made a mistake):**
```bash
git push origin --delete v1.0.0
```

**Push all tags at once:**
```bash
git push origin --tags
```

### Downloading Release Artifacts

Once the build workflow completes successfully, you can download release artifacts:

#### Manual Download

1. Go to the **Releases** page on GitHub
2. Find the release associated with your tag
3. Download the artifacts you need:
   - `rule7_app-windows.zip` - Portable Windows version
   - `rule7_app-installer.exe` - Windows installer
   - `rule7_app-macos.zip` - macOS app bundle
   - `rule7_app-macos.dmg` - macOS disk image installer
   - `rule7_app-linux.tar.gz` - Linux bundle archive
   - `rule7_app-linux.AppImage` - Linux AppImage (portable)
   - `rule7_app-android.apk` - Android APK (unsigned)

#### Automated Download

Use the provided script to automatically download the latest release:

```bash
# Download all platforms
make download-release

# Download specific platform
PLATFORM=linux make download-release

# Download to custom directory
DOWNLOAD_DIR=/opt/releases PLATFORM=linux make download-release
```

Or use the script directly:

```bash
# Download all platforms
./scripts/download-latest-release.sh

# Download specific platform (windows, macos, linux, android)
PLATFORM=linux ./scripts/download-latest-release.sh

# With GitHub token (for private repos or rate limits)
GITHUB_TOKEN=ghp_xxxxx ./scripts/download-latest-release.sh
```

Downloads are organized in the `releases/` directory by release tag.

See [`scripts/README.md`](scripts/README.md) for detailed documentation on the download script.

#### Server Deployment

Deploy the latest release to a server:

```bash
# Deploy Linux release to server
make deploy-release-server SERVER=user@example.com:/opt/rule7 PLATFORM=linux
```

This will download the latest release and upload it to the specified server via SCP.

### Local Building

For local development and testing, you can build releases manually using the Makefile:

```bash
# Build macOS release
make flutter-build-macos

# Build Android APK
make flutter-build-android

# Build Linux bundle
make flutter-build-linux

# See all available Flutter commands
make help
```

### macOS Code Signing Setup

To enable code signing for macOS builds in CI/CD, you need to export your Apple Developer certificate and store it as GitHub Secrets.

#### Step 1: Export Your Certificate

1. **Open Keychain Access** on your Mac
2. **Find your certificate** (look for "Developer ID Application" for distribution or "Apple Development" for testing)
3. **Select the certificate and its private key** (expand the certificate to see the key)
4. **Right-click and select "Export 2 items..."**
5. **Save as `.p12` format** (e.g., `macos-certificate.p12`)
6. **Set a password** for the certificate export (remember this password)

#### Step 2: Convert to Base64

Convert the `.p12` file to base64 for GitHub Secrets:

```bash
base64 -i macos-certificate.p12 | pbcopy
```

This copies the base64-encoded certificate to your clipboard.

#### Step 3: Add GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

1. **`MACOS_CERTIFICATE_BASE64`**
   - Value: The base64-encoded certificate from Step 2
   - (Paste the entire base64 string)

2. **`MACOS_CERTIFICATE_PASSWORD`**
   - Value: The password you set when exporting the certificate in Step 1

3. **`KEYCHAIN_PASSWORD`** (optional)
   - Value: A password for the temporary keychain (defaults to `github-actions-keychain` if not set)

#### Step 4: Verify

After adding the secrets, the next build will automatically:
- Import your certificate
- Sign the macOS app with it
- Create a signed `.dmg` and `.zip`

**Note:** If the secrets are not set, builds will continue to work but the app will be unsigned (users will see a security warning when running it).

**Certificate Types:**
- **Developer ID Application**: For distributing apps outside the Mac App Store (recommended for releases)
- **Apple Development**: For testing/development (expires after 1 year)

### Production URLs

Release builds are configured with production URLs:
- API Base URL: `https://tools.zonies.xyz/api/mobile/v1`
- Web Base URL: `https://tools.zonies.xyz`

These are set via `--dart-define` flags during the build process.

## Development

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK (included with Flutter)
- Platform-specific development tools:
  - **Windows**: Visual Studio with C++ tools
  - **macOS**: Xcode
  - **Linux**: GTK development libraries
  - **Android**: Android Studio and SDK

### Running the App

```bash
# Get dependencies
flutter pub get

# Run code generation (if needed)
make flutter-build-runner

# Run in debug mode
make flutter-run DEVICE=macos  # or windows, linux, android

# Run in profile mode
make flutter-run-profile DEVICE=macos
```

### Code Generation

This project uses code generation for JSON serialization and state management:

```bash
# Run build_runner
make flutter-build-runner

# Watch for changes (during development)
dart run build_runner watch --delete-conflicting-outputs
```
