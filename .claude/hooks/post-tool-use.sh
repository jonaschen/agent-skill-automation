#!/bin/bash
# post-tool-use.sh — Post-tool-use lifecycle hook
#
# Runs after a tool execution (PostToolUse event).
# Detects writes to .claude/skills/ or ~/.claude/@lib/agents/ and:
#   1. Logs the lifecycle event via lifecycle_tracker.py
#   2. Runs permission check on modified SKILL.md files
#
# Exit code 0 = success
# Exit code 1 = error (blocks the tool use)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"
PERM_CHECK="$REPO_ROOT/eval/check-permissions.sh"

# The hook receives tool name and file path as environment variables
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
FILE_PATH="${CLAUDE_FILE_PATH:-}"

# Only act on Write/Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Check if the file is a SKILL.md or agent definition
if [[ "$FILE_PATH" == *".claude/skills/"*"/SKILL.md" ]]; then
  skill_name=$(echo "$FILE_PATH" | grep -oP '(?<=skills/)[^/]+' || true)
  if [ -n "$skill_name" ]; then
    # Log lifecycle event
    if [ -f "$LIFECYCLE_TRACKER" ]; then
      python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage validated --source "post-tool-use" 2>/dev/null || true
    fi

    # Run permission check
    if [ -f "$PERM_CHECK" ] && [ -f "$FILE_PATH" ]; then
      if ! bash "$PERM_CHECK" "$FILE_PATH" 2>/dev/null; then
        echo "WARNING: Permission check failed for $skill_name" >&2
      fi
    fi
  fi
elif [[ "$FILE_PATH" == *"@lib/agents/"*".md" ]]; then
  role_name=$(basename "$FILE_PATH" .md)
  if [ -f "$LIFECYCLE_TRACKER" ]; then
    python3 "$LIFECYCLE_TRACKER" --skill "$role_name" --stage created --source "changeling-role" 2>/dev/null || true
  fi
fi

exit 0
