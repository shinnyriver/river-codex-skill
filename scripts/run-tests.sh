#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

if ! bash "$SCRIPT_DIR/setup-test-env.sh" "$PROJECT_DIR"; then
  echo "Test environment not ready. Skipping tests."
  exit 0
fi

if [ -f "package.json" ]; then
  if grep -q '"test"' package.json; then
    npm test
  fi
  exit 0
fi

if [ -f "Cargo.toml" ]; then
  cargo test
  exit 0
fi

if [ -f "go.mod" ]; then
  go test ./...
  exit 0
fi

if [ -f "pom.xml" ]; then
  mvn -q test
  exit 0
fi

if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  if [ -x "./gradlew" ]; then
    ./gradlew test
  else
    gradle test
  fi
  exit 0
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  if command -v pytest >/dev/null 2>&1; then
    pytest
  else
    python3 -m pytest
  fi
  exit 0
fi

echo "No supported test runner detected."
