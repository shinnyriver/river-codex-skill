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

echo "--- Changed Files ---"
git diff --name-only "$BASE_BRANCH"...HEAD 2>/dev/null || git diff --name-only "$BASE_BRANCH" HEAD
echo
echo "--- File Stats ---"
git diff --stat "$BASE_BRANCH"...HEAD 2>/dev/null || git diff --stat "$BASE_BRANCH" HEAD
echo
echo "--- Full Diff ---"
git diff "$BASE_BRANCH"...HEAD 2>/dev/null || git diff "$BASE_BRANCH" HEAD
