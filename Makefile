# Rule7 Laravel Application - Simplified Docker Management
# Single entry point for all Docker operations

# ========= Core =========
.SHELLFLAGS := -eu -o pipefail -c
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Detect docker compose flavor once
ifeq ($(shell docker compose version >/dev/null 2>&1 || echo no),no)
  DC := docker-compose
else
  DC := docker compose
endif

# Common knobs
ENV_FILE ?= .env
APP_SERVICE ?= app
PROJECT_NAME ?= rule7_app
SERVICE ?= $(APP_SERVICE)

# Auto-help printer (groups via lines starting with '##@', targets with '##')
# Usage: add `## description` after a target line; add `##@ Group Name` to start a section
help: ## Show this help message
	@awk 'BEGIN { \
	  FS=":.*##"; \
	  printf "\n\033[1mRule7 Laravel Application — Docker Management\033[0m\n"; \
	  printf "=================================================================\n"; \
	} \
	/^##@/ { \
	  gsub(/^##@ */,""); \
	  printf "\n\033[1m%s\033[0m\n", $$0; \
	} \
	/^[a-zA-Z0-9_.-]+:.*##/ { \
	  printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2; \
	}' $(MAKEFILE_LIST)
	@printf "\nTip: pass \033[33mSERVICE=name\033[0m to scope restart/logs, e.g., \033[33mmake restart SERVICE=$(APP_SERVICE)\033[0m\n\n"

.PHONY: help setup dev prod stop restart restart-all fresh build shell logs logs-app logs-mysql logs-redis cache-clear composer npm artisan schedule queue monitor run-schedule migrate migrate-fresh seed match-reports db-backup db-restore status health logs-size container-size cleanup-bloat clean clean-all fix-permissions flutter-fix-pods flutter-run flutter-run-profile flutter-build-macos flutter-build-android flutter-build-linux flutter-clean flutter-pub-get flutter-build-runner flutter-test ci

##@ Permissions
fix-permissions: ## Fix file permissions after Carbon Copy Cloner or similar backups
	@echo "🔧 Fixing file permissions across project..."
	@echo "📁 Setting directory permissions to 755..."
	@find . -type d -not -path "*/vendor/*" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/build/*" -exec chmod 755 {} \; 2>/dev/null || true
	@echo "📄 Setting regular file permissions to 644 (PHP, JS, CSS, etc.)..."
	@find . -type f -not -path "*/vendor/*" -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/build/*" \
		-not -name "*.sh" -not -name "*.phar" -not -name "gradlew" -not -name "artisan" \
		-not -name ".env*" -not -name "*.log" \
		-exec chmod 644 {} \; 2>/dev/null || true
	@echo "🔐 Keeping sensitive files private (600): .env, .env.*, *.log..."
	@find . -type f -not -path "*/vendor/*" -not -path "*/node_modules/*" -not -path "*/.git/*" \
		\( -name ".env" -o -name ".env.*" -o -name "*.log" \) \
		-exec chmod 600 {} \; 2>/dev/null || true
	@echo "⚙️ Making executable files (755)..."
	@echo "  → Shell scripts..."
	@find . -name "*.sh" -type f -not -path "*/vendor/*" -not -path "*/node_modules/*" -not -path "*/.git/*" -exec chmod 755 {} \; 2>/dev/null || true
	@echo "  → Laravel artisan..."
	@test -f artisan && chmod 755 artisan || true
	@echo "  → Flutter gradlew..."
	@test -f android/gradlew && chmod 755 android/gradlew || true
	@echo "  → PHAR files..."
	@find . -name "*.phar" -type f -not -path "*/vendor/*" -not -path "*/.git/*" -exec chmod 755 {} \; 2>/dev/null || true
	@echo "  → CocoaPods scripts..."
	@if [ -d "macos/Pods/Target Support Files" ]; then \
		find "macos/Pods/Target Support Files" -name "*.sh" -type f -exec chmod 755 {} \; 2>/dev/null || true; \
	fi
	@if [ -d "ios/Pods/Target Support Files" ]; then \
		find "ios/Pods/Target Support Files" -name "*.sh" -type f -exec chmod 755 {} \; 2>/dev/null || true; \
	fi
	@echo "  → Vendor/bin executables..."
	@if [ -d "vendor/bin" ]; then \
		find vendor/bin -type f -exec chmod 755 {} \; 2>/dev/null || true; \
	fi
	@echo "✅ Permissions fixed (dirs: 755, files: 644, executables: 755, sensitive: 600)"

##@ Flutter
flutter-fix-pods: ## Fix CocoaPods script permissions (macOS/iOS)
	@echo "🔧 Fixing CocoaPods script permissions..."
	@if [ -d "macos/Pods/Target Support Files" ]; then \
		find "macos/Pods/Target Support Files" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true; \
	fi
	@if [ -d "ios/Pods/Target Support Files" ]; then \
		find "ios/Pods/Target Support Files" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true; \
	fi
	@echo "✅ Pods scripts fixed"

flutter-run: ## Run Flutter app in debug mode (usage: make flutter-run DEVICE=macos)
	@flutter run -d $(or $(DEVICE),macos)

flutter-run-profile: ## Run Flutter app in profile mode (usage: make flutter-run-profile DEVICE=macos)
	@flutter run --profile -d $(or $(DEVICE),macos)

flutter-build-macos: flutter-fix-pods ## Build macOS release (with production URLs)
	@echo "🏗️ Building macOS release with production URLs..."
	@flutter build macos --release \
		--dart-define=API_BASE_URL=https://tools.zonies.xyz/api/mobile/v1 \
		--dart-define=WEB_BASE_URL=https://tools.zonies.xyz
	@echo "✅ macOS build complete: build/macos/Build/Products/Release/rule7_app.app"

flutter-build-android: ## Build Android APK (unsigned, with production URLs)
	@flutter build apk --release \
		--dart-define=API_BASE_URL=https://tools.zonies.xyz/api/mobile/v1 \
		--dart-define=WEB_BASE_URL=https://tools.zonies.xyz
	@echo "✅ Android APK built: build/app/outputs/flutter-apk/app-release.apk"

flutter-build-linux: ## Build Linux AppImage (with production URLs)
	@flutter build linux --release \
		--dart-define=API_BASE_URL=https://tools.zonies.xyz/api/mobile/v1 \
		--dart-define=WEB_BASE_URL=https://tools.zonies.xyz
	@echo "✅ Linux build complete: build/linux/x64/release/bundle/"

flutter-clean: ## Clean Flutter build artifacts
	@flutter clean

flutter-pub-get: ## Get Flutter dependencies
	@flutter pub get

flutter-build-runner: ## Run code generation (json_serializable, freezed, etc.)
	@dart run build_runner build --delete-conflicting-outputs

flutter-test: ## Run Flutter tests
	@flutter test
