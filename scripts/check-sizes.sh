#!/usr/bin/env bash
set -euo pipefail

BASE_BRANCH="${1:-main}"
PROJECT_DIR="${2:-.}"
MAX_FILE_LINES="${3:-300}"
MAX_FUNC_LINES="${4:-50}"
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

echo "Oversized files:"
for file in $CHANGED_FILES; do
  [ -f "$file" ] || continue
  lines="$(wc -l < "$file" | tr -d ' ')"
  if [ "$lines" -gt "$MAX_FILE_LINES" ]; then
    echo "  $file: $lines lines"
  fi
done

echo
echo "Potentially oversized functions:"
for file in $(echo "$CHANGED_FILES" | grep -E "\.(ts|tsx|js|jsx|py|go|rs|java)$" || true); do
  [ -f "$file" ] || continue
  grep -nE "function |=> \{|^\s*def |^\s*async def |^\s*func |^\s*(public |private |protected )?.+\(" "$file" | while IFS=: read -r line_num _; do
    remaining="$(tail -n +"$line_num" "$file" | head -n "$((MAX_FUNC_LINES + 10))" | wc -l | tr -d ' ')"
    if [ "$remaining" -gt "$MAX_FUNC_LINES" ]; then
      echo "  $file:$line_num"
    fi
  done
done
