#!/bin/bash
# check_all_permissions.sh — Aggregator for eval/check-permissions.sh
#
# Runs eval/check-permissions.sh on every agent definition and SKILL.md
# in the repo, reports per-file pass/fail, and returns a non-zero exit
# code if any file violates the permission matrix.
#
# Used by the factory steward's quality_gates (see configs/factory.yaml).
#
# Usage: scripts/check_all_permissions.sh [--quiet]
#   --quiet  Only emit the summary line and any failures.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERM_CHECK="$REPO_ROOT/eval/check-permissions.sh"

QUIET=0
if [ "${1:-}" = "--quiet" ]; then QUIET=1; fi

if [ ! -x "$PERM_CHECK" ] && [ ! -f "$PERM_CHECK" ]; then
  echo "ERROR: $PERM_CHECK not found"
  exit 2
fi

PASS=0
FAIL=0
FAILED_FILES=()

while IFS= read -r f; do
  if bash "$PERM_CHECK" "$f" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    [ "$QUIET" -eq 0 ] && echo "PASS  $f"
  else
    FAIL=$((FAIL + 1))
    FAILED_FILES+=("$f")
    echo "FAIL  $f"
    bash "$PERM_CHECK" "$f" 2>&1 | sed 's/^/      /'
  fi
done < <(find "$REPO_ROOT/.claude/agents" "$REPO_ROOT/.claude/skills" \
            -name "*.md" -type f 2>/dev/null \
          | grep -v -E '/(README|TEMPLATE|EXAMPLES?)\.md$' \
          | sort)

echo ""
echo "Permission matrix: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
