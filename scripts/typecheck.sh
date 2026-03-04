#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

if [ -f "tsconfig.json" ]; then
  npx tsc --noEmit
  exit 0
fi

if [ -f "mypy.ini" ] || [ -f ".mypy.ini" ] || ( [ -f "pyproject.toml" ] && grep -q "mypy" pyproject.toml ); then
  mypy .
  exit 0
fi

if [ -f "go.mod" ]; then
  go vet ./...
  exit 0
fi

if [ -f "Cargo.toml" ]; then
  cargo check
  exit 0
fi

echo "No supported type checker detected."
