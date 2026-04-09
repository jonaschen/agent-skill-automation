#!/bin/bash
# check_target_deprecations.sh — Check a target repo's .claude/ for deprecated model references
#
# Warning-only: logs findings but never blocks the steward run.
# Scoped to .claude/ directory only — avoids matching model IDs in docs/tests/comments.
#
# Usage: bash scripts/lib/check_target_deprecations.sh /path/to/target/repo
# Exit: always 0 (advisory only)

set -euo pipefail

TARGET_REPO="${1:?Usage: check_target_deprecations.sh <target-repo-path>}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEPRECATED_JSON="$REPO_ROOT/eval/deprecated_models.json"

if [ ! -f "$DEPRECATED_JSON" ]; then
  echo "SKIP: deprecated_models.json not found"
  exit 0
fi

if [ ! -d "$TARGET_REPO/.claude" ]; then
  echo "SKIP: No .claude/ directory in $TARGET_REPO"
  exit 0
fi

# Calculate deadline (today + 30 days)
DEADLINE=$(date -d "+30 days" +%Y-%m-%d 2>/dev/null || date -v+30d +%Y-%m-%d 2>/dev/null || echo "2099-12-31")

# Extract model IDs retiring within 30 days
DEPRECATED_IDS=$(python3 -c "
import json
with open('$DEPRECATED_JSON') as f:
    data = json.load(f)
for m in data.get('models', []):
    if m.get('retirement_date', '9999') <= '$DEADLINE':
        print(m['model_id'])
" 2>/dev/null || true)

if [ -z "$DEPRECATED_IDS" ]; then
  echo "OK: No models retiring within 30 days"
  exit 0
fi

FOUND=0
while IFS= read -r model_id; do
  [ -z "$model_id" ] && continue
  matches=$(grep -rl "$model_id" "$TARGET_REPO/.claude/" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    FOUND=1
    echo "WARN: Deprecated model '$model_id' found in target repo:"
    echo "$matches" | sed 's/^/  /'
  fi
done <<< "$DEPRECATED_IDS"

if [ "$FOUND" -eq 1 ]; then
  echo "[STEERING-NOTE] Target repo references deprecated models — consider migration"
else
  echo "OK: No deprecated model references in $TARGET_REPO/.claude/"
fi

exit 0
