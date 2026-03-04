#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

WORKFLOW_DIR="$PROJECT_DIR/.river/workflow"
MEMORY_DIR="$PROJECT_DIR/.river/memory"
REPORTS_DIR="$PROJECT_DIR/.river/reports"
WORKTREES_DIR="$PROJECT_DIR/.river/worktrees"

mkdir -p "$WORKFLOW_DIR" "$MEMORY_DIR" "$REPORTS_DIR" "$WORKTREES_DIR"

if [ ! -f "$WORKFLOW_DIR/config.yaml" ]; then
  cp "$SKILL_DIR/assets/config-template.yaml" "$WORKFLOW_DIR/config.yaml"
  echo "Created $WORKFLOW_DIR/config.yaml"
else
  echo "Preserved existing $WORKFLOW_DIR/config.yaml"
fi

if [ ! -f "$REPORTS_DIR/report-template.md" ]; then
  cp "$SKILL_DIR/assets/report-template.md" "$REPORTS_DIR/report-template.md"
  echo "Created $REPORTS_DIR/report-template.md"
else
  echo "Preserved existing $REPORTS_DIR/report-template.md"
fi

if [ ! -f "$MEMORY_DIR/retrospective.md" ]; then
  cat <<'EOF' > "$MEMORY_DIR/retrospective.md"
# River retrospective

- Record reusable lessons from completed runs.
EOF
  echo "Created $MEMORY_DIR/retrospective.md"
fi

if [ ! -f "$MEMORY_DIR/unresolved-decisions.md" ]; then
  cat <<'EOF' > "$MEMORY_DIR/unresolved-decisions.md"
# Unresolved decisions

- Track decisions that should be revisited after implementation.
EOF
  echo "Created $MEMORY_DIR/unresolved-decisions.md"
fi

echo "River workflow initialized at $PROJECT_DIR/.river"
