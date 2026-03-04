#!/usr/bin/env bash
set -uo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

if [ -f "package.json" ]; then
  if [ -d "node_modules" ]; then
    echo "[Node.js] ready"
    exit 0
  fi
  echo "[Node.js] node_modules missing"
  if npm install; then
    exit 0
  fi
  exit 1
fi

if [ -f "Cargo.toml" ]; then
  command -v cargo >/dev/null 2>&1
  exit $?
fi

if [ -f "go.mod" ]; then
  if ! command -v go >/dev/null 2>&1; then
    exit 1
  fi
  if [ ! -f "go.sum" ]; then
    go mod download
  fi
  exit 0
fi

if [ -f "pom.xml" ]; then
  if ! command -v mvn >/dev/null 2>&1; then
    exit 1
  fi
  if ! mvn -q -DskipTests dependency:resolve >/dev/null 2>&1; then
    exit 1
  fi
  exit 0
fi

if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  if [ -x "./gradlew" ] || command -v gradle >/dev/null 2>&1; then
    exit 0
  fi
  exit 1
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  if command -v pytest >/dev/null 2>&1 || python3 -m pytest --version >/dev/null 2>&1; then
    exit 0
  fi
  if [ -f "requirements.txt" ] && pip install -r requirements.txt; then
    exit 0
  fi
  if [ -f "pyproject.toml" ] && pip install -e ".[test]"; then
    exit 0
  fi
  exit 1
fi

exit 1
