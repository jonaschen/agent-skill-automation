#!/bin/bash
# model_deprecation_check.sh — Pre-deploy gate: detect deprecated model references
#
# Greps all agent definitions and eval configs for model IDs listed in
# deprecated_models.json. Fails (exit 1) if any referenced model retires
# within WARNING_DAYS (default: 30).
#
# Usage: bash eval/model_deprecation_check.sh [warning_days]
# Exit: 0 = clean, 1 = deprecated model found within warning window

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPRECATED_JSON="$SCRIPT_DIR/deprecated_models.json"
WARNING_DAYS="${1:-30}"

if [ ! -f "$DEPRECATED_JSON" ]; then
  echo "WARN: deprecated_models.json not found — skipping deprecation check" >&2
  exit 0
fi

# Check if jq is available; fall back to python3 if not
if command -v jq &>/dev/null; then
  PARSER="jq"
elif command -v python3 &>/dev/null; then
  PARSER="python3"
else
  echo "WARN: neither jq nor python3 available — skipping deprecation check" >&2
  exit 0
fi

# Calculate the warning deadline (today + WARNING_DAYS)
TODAY=$(date +%Y-%m-%d)
if date -d "+${WARNING_DAYS} days" +%Y-%m-%d &>/dev/null; then
  DEADLINE=$(date -d "+${WARNING_DAYS} days" +%Y-%m-%d)
else
  DEADLINE=$(date -v+${WARNING_DAYS}d +%Y-%m-%d 2>/dev/null || echo "2099-12-31")
fi

# Extract model IDs retiring before the deadline
if [ "$PARSER" = "jq" ]; then
  DEPRECATED_IDS=$(jq -r --arg deadline "$DEADLINE" \
    '.models[] | select(.retirement_date <= $deadline) | .model_id' \
    "$DEPRECATED_JSON" 2>/dev/null || true)
else
  DEPRECATED_IDS=$(python3 -c "
import json, sys
with open('$DEPRECATED_JSON') as f:
    data = json.load(f)
for m in data.get('models', []):
    if m.get('retirement_date', '9999') <= '$DEADLINE':
        print(m['model_id'])
" 2>/dev/null || true)
fi

if [ -z "$DEPRECATED_IDS" ]; then
  echo "OK: No model deprecations within ${WARNING_DAYS} days"
  exit 0
fi

# Search agent definitions and eval configs for deprecated model IDs
SCAN_DIRS=(
  "$REPO_ROOT/.claude/agents"
  "$REPO_ROOT/.claude/skills"
  "$REPO_ROOT/eval"
)

FOUND=0
while IFS= read -r model_id; do
  [ -z "$model_id" ] && continue
  for dir in "${SCAN_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    matches=$(grep -rl --exclude="deprecated_models.json" "$model_id" "$dir" 2>/dev/null || true)
    if [ -n "$matches" ]; then
      FOUND=1
      echo "FAIL: Deprecated model '$model_id' found in:" >&2
      echo "$matches" | sed 's/^/  /' >&2
    fi
  done
done <<< "$DEPRECATED_IDS"

if [ "$FOUND" -eq 1 ]; then
  echo "FAIL: Deprecated model references detected — update to replacement models before deploy" >&2
  exit 1
fi

echo "OK: No deprecated model references found in agent configs"
exit 0
