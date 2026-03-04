#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

if [ -f "package.json" ]; then
  if grep -q '"build"' package.json; then
    npm run build
  fi
  exit 0
fi

if [ -f "Cargo.toml" ]; then
  cargo build
  exit 0
fi

if [ -f "go.mod" ]; then
  go build ./...
  exit 0
fi

if [ -f "pom.xml" ]; then
  mvn -q compile
  exit 0
fi

if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  if [ -x "./gradlew" ]; then
    ./gradlew build -x test
  else
    gradle build -x test
  fi
  exit 0
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  python3 -m py_compile $(find . -name "*.py" -not -path "./venv/*" -not -path "./.venv/*" | head -50)
  exit 0
fi

echo "No supported build step detected."
