#!/bin/sh
# Strict swift-format lint for the Navi example apps.
# Called from a Run Script build phase in each example .xcodeproj.
# Uses the Apple swift-format toolchain binary and the repo-root .swift-format config.
# Exits non-zero on violations (--strict), failing the build with Xcode file:line errors.
set -u

REPO_ROOT="$(cd "$SRCROOT/../.." && pwd)"
CONFIG="$REPO_ROOT/.swift-format"

if [ ! -f "$CONFIG" ]; then
  echo "warning: .swift-format config not found at $CONFIG, skipping lint"
  exit 0
fi

SWIFT_FORMAT="$(xcrun --find swift-format 2>/dev/null || true)"
if [ -z "$SWIFT_FORMAT" ]; then
  echo "warning: swift-format not found in toolchain, skipping lint"
  exit 0
fi

exec "$SWIFT_FORMAT" lint --strict --parallel --configuration "$CONFIG" --recursive "$SRCROOT"
