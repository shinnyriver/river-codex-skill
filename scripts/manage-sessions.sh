#!/usr/bin/env bash
set -euo pipefail

COMMAND="${1:-help}"
PROJECT_DIR="${2:-$(pwd)}"
BRANCH="${3:-}"

ROOT_DIR="$(cd "$PROJECT_DIR" && pwd)"
WORKTREES_DIR="$ROOT_DIR/.river/worktrees"

list_sessions() {
  local found=0

  if [ ! -d "$WORKTREES_DIR" ]; then
    echo "No River worktree directory found at $WORKTREES_DIR"
    exit 0
  fi

  while IFS= read -r line; do
    local wt_path wt_sha wt_branch
    wt_path="$(echo "$line" | awk '{print $1}')"
    wt_sha="$(echo "$line" | awk '{print $2}')"
    wt_branch="$(echo "$line" | grep -o '\[[^]]*\]' | tr -d '[]')"

    if [[ "$wt_path" != "$WORKTREES_DIR/"* ]]; then
      continue
    fi

    found=1
    echo "Branch: $wt_branch"
    echo "Path: $wt_path"
    echo "Base: $wt_sha"
    if [ -f "$wt_path/.river/memory/plan-summary.md" ]; then
      echo "Plan: present"
    else
      echo "Plan: missing"
    fi
    echo
  done < <(git -C "$ROOT_DIR" worktree list)

  if [ "$found" -eq 0 ]; then
    echo "No active River sessions."
  fi
}

info_session() {
  local wt_path
  wt_path="$(git -C "$ROOT_DIR" worktree list | awk -v branch="$BRANCH" '$0 ~ "\\[" branch "\\]" {print $1; exit}')"

  if [ -z "$wt_path" ]; then
    echo "Session not found for branch: $BRANCH" >&2
    exit 1
  fi

  echo "Path: $wt_path"
  echo
  echo "Recent commits:"
  git -C "$wt_path" log -5 --format="  %h %s (%cr)"
  echo
  echo "Git status:"
  git -C "$wt_path" status --short || true
  echo
  echo "Memory files:"
  if [ -d "$wt_path/.river/memory" ]; then
    find "$wt_path/.river/memory" -type f -name "*.md" | sort
  else
    echo "  none"
  fi
}

delete_session() {
  local wt_path
  wt_path="$(git -C "$ROOT_DIR" worktree list | awk -v branch="$BRANCH" '$0 ~ "\\[" branch "\\]" {print $1; exit}')"

  if [ -z "$wt_path" ]; then
    echo "Session not found for branch: $BRANCH" >&2
    exit 1
  fi

  git -C "$ROOT_DIR" worktree remove "$wt_path" --force
  git -C "$ROOT_DIR" branch -D "$BRANCH"
  echo "Deleted session: $BRANCH"
}

case "$COMMAND" in
  list)
    list_sessions
    ;;
  info)
    if [ -z "$BRANCH" ]; then
      echo "Usage: manage-sessions.sh info <project-dir> <branch>" >&2
      exit 1
    fi
    info_session
    ;;
  delete)
    if [ -z "$BRANCH" ]; then
      echo "Usage: manage-sessions.sh delete <project-dir> <branch>" >&2
      exit 1
    fi
    delete_session
    ;;
  help|*)
    cat <<'EOF'
Usage:
  manage-sessions.sh list <project-dir>
  manage-sessions.sh info <project-dir> <branch>
  manage-sessions.sh delete <project-dir> <branch>
EOF
    ;;
esac
