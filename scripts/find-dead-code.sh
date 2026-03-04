#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"
PROJECT_DIR="${2:-.}"
cd "$PROJECT_DIR"

if ! git rev-parse --verify "$BASE_BRANCH" >/dev/null 2>&1; then
  if git rev-parse --verify "master" >/dev/null 2>&1; then
    BASE_BRANCH="master"
  else
    BASE_BRANCH="HEAD~1"
  fi
fi

CHANGED_FILES="$(git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null || git diff --name-only "$BASE_BRANCH" HEAD)"

if [ -z "$CHANGED_FILES" ]; then
  echo "No changed files found."
  exit 0
fi

for file in $CHANGED_FILES; do
  [ -f "$file" ] || continue
  echo "--- $file ---"
  grep -nE "console\.log|console\.debug|debugger;|print\(" "$file" || true
  grep -nE "TODO.*remove|FIXME.*remove|TODO.*delete|FIXME.*delete" "$file" || true
  grep -nE "^\s*//.*(function|class|const|let|var)|^\s*#.*(def |class )" "$file" || true
  echo
done
