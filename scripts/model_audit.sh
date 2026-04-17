#!/bin/bash
# scripts/model_audit.sh
#
# Audit all operational scripts, eval code, and agent configs for:
#   1. Deprecated model IDs (from eval/deprecated_models.json)
#   2. Deprecated 1M context beta headers (sunsets 2026-04-30)
#
# This closes the gap between eval/model_deprecation_check.sh (deploy-time only)
# and cron scripts / eval runners that call the API directly outside the hook chain.
#
# Exit 0 = clean. Exit 1 = deprecated references found (blocks deploy when called
# from pre-deploy.sh).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPRECATED_MODELS_FILE="$REPO_ROOT/eval/deprecated_models.json"

# --- CLI flags ---
RETIRED_ON=""
LOG_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --retired-on) RETIRED_ON="$2"; shift 2 ;;
    --log) LOG_FILE="$2"; shift 2 ;;
    *) echo "[MODEL-AUDIT] Unknown flag: $1"; exit 1 ;;
  esac
done

FOUND=0

# --- 1. Load deprecated model IDs from deprecated_models.json ---
if [ ! -f "$DEPRECATED_MODELS_FILE" ]; then
  echo "[MODEL-AUDIT] WARN: $DEPRECATED_MODELS_FILE not found — skipping model ID check"
else
  # Extract model IDs. If --retired-on is set, only check models retired on that date.
  # Otherwise, check all models with retirement_date >= today.
  TODAY=$(date +%Y-%m-%d)
  FILTER_DATE="${RETIRED_ON:-$TODAY}"
  FILTER_MODE="${RETIRED_ON:+exact}"  # "exact" if --retired-on set, empty otherwise
  mapfile -t DEPRECATED_IDS < <(
    python3 -c "
import json, sys
with open('$DEPRECATED_MODELS_FILE') as f:
    data = json.load(f)
entries = data if isinstance(data, list) else data.get('models', [])
for e in entries:
    mid = e.get('model_id', '')
    ret = e.get('retirement_date', '')
    if not mid or not ret:
        continue
    if '${FILTER_MODE}' == 'exact':
        if ret == '${FILTER_DATE}':
            print(mid)
    else:
        if ret >= '${FILTER_DATE}':
            print(mid)
" 2>/dev/null || true
  )

  # --- 2. Grep operational code for deprecated model IDs ---
  # Scope: scripts/, eval/, .claude/agents/, .claude/skills/, .claude/hooks/
  # Also: ~/.claude/agents/ (global role library embeds model IDs in examples)
  # Exclude: knowledge_base/, proposals/, analysis/ (documentation — not operational)
  SEARCH_DIRS=(
    "$REPO_ROOT/scripts"
    "$REPO_ROOT/eval"
    "$REPO_ROOT/.claude/agents"
    "$REPO_ROOT/.claude/skills"
    "$REPO_ROOT/.claude/hooks"
  )
  GLOBAL_AGENTS="$HOME/.claude/agents"
  [ -d "$GLOBAL_AGENTS" ] && SEARCH_DIRS+=("$GLOBAL_AGENTS")

  for MODEL_ID in "${DEPRECATED_IDS[@]}"; do
    [ -z "$MODEL_ID" ] && continue
    for DIR in "${SEARCH_DIRS[@]}"; do
      [ -d "$DIR" ] || continue
      # Exclude: the registry file itself, this script, and documentation-only references
      # Documentation references: lines where the model ID appears only inside backticks
      # or in a retirement schedule context (e.g., "2026-04-19: `claude-3-haiku-20240307`")
      HITS=$(grep -rn "$MODEL_ID" "$DIR" \
        --include="*.sh" --include="*.py" --include="*.md" --include="*.json" \
        --exclude="deprecated_models.json" \
        --exclude="model_audit.sh" \
        2>/dev/null \
        | grep -v "retirement" \
        | grep -v "Known retirement schedule" \
        | grep -v "deprecated_models" \
        | grep -v "# .*$MODEL_ID" \
        | grep -v "^.*[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}:.*\`$MODEL_ID\`" \
        || true)
      if [ -n "$HITS" ]; then
        echo "[MODEL-AUDIT] FAIL: Deprecated model '$MODEL_ID' found in operational code:"
        echo "$HITS" | while IFS= read -r line; do
          echo "  $line"
        done
        FOUND=1
      fi
    done
  done
fi

# --- 3. Check for deprecated 1M context beta headers (sunset 2026-04-30) ---
# These headers on Sonnet 4 / Sonnet 4.5 will error after April 30.
# Sonnet 4.6 and Opus 4.6 support 1M context natively; no header needed.
BETA_SUNSET="2026-04-30"
TODAY=$(date +%Y-%m-%d)
if [[ "$TODAY" < "$BETA_SUNSET" || "$TODAY" == "$BETA_SUNSET" ]]; then
  SUNSET_PATTERNS=(
    "context-1m-2025-08-07"
    "interleaved-thinking"
    "max-tokens-3-5-sonnet"
  )
  SEARCH_DIRS_BETA=(
    "$REPO_ROOT/scripts"
    "$REPO_ROOT/eval"
    "$REPO_ROOT/.claude"
  )
  for PATTERN in "${SUNSET_PATTERNS[@]}"; do
    for DIR in "${SEARCH_DIRS_BETA[@]}"; do
      [ -d "$DIR" ] || continue
      HITS=$(grep -rl "$PATTERN" "$DIR" \
        --include="*.sh" --include="*.py" --include="*.md" --include="*.json" \
        --exclude="model_audit.sh" \
        2>/dev/null || true)
      if [ -n "$HITS" ]; then
        echo "[MODEL-AUDIT] WARN: Deprecated beta header '$PATTERN' (sunsets $BETA_SUNSET) found:"
        grep -rn "$PATTERN" "$DIR" \
          --include="*.sh" --include="*.py" --include="*.md" --include="*.json" \
          --exclude="model_audit.sh" \
          2>/dev/null | while IFS= read -r line; do
          echo "  $line"
        done
        # Beta headers are warning-only until sunset date; do not fail
      fi
    done
  done
fi

# --- 4. Report ---
RESULT="PASS"
if [ "$FOUND" -ne 0 ]; then
  RESULT="FAIL"
fi

# Log to structured JSONL if --log specified
if [ -n "$LOG_FILE" ]; then
  mkdir -p "$(dirname "$LOG_FILE")"
  python3 -c "
import json, datetime
entry = {
    'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'event': 'model_audit',
    'result': '$RESULT',
    'retired_on': '${RETIRED_ON:-null}',
    'filter_mode': '${FILTER_MODE:-upcoming}',
    'deprecated_ids_checked': ${#DEPRECATED_IDS[@]}
}
if entry['retired_on'] == 'null':
    entry['retired_on'] = None
print(json.dumps(entry))
" >> "$LOG_FILE"
fi

# Post-retirement clean verification: append to deprecated_models.json entry
if [ "$FOUND" -eq 0 ] && [ -n "$RETIRED_ON" ]; then
  python3 -c "
import json
with open('$DEPRECATED_MODELS_FILE') as f:
    data = json.load(f)
entries = data.get('models', data if isinstance(data, list) else [])
updated = False
for e in entries:
    if e.get('retirement_date') == '$RETIRED_ON' and 'verified_clean_post_retirement' not in e:
        e['verified_clean_post_retirement'] = '$RETIRED_ON'
        updated = True
if updated:
    with open('$DEPRECATED_MODELS_FILE', 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    print('[MODEL-AUDIT] Marked retired models as verified clean in deprecated_models.json')
" 2>/dev/null || true
fi

if [ "$FOUND" -eq 0 ]; then
  echo "[MODEL-AUDIT] PASS: No deprecated model IDs found in operational code."
  exit 0
else
  echo "[MODEL-AUDIT] FAIL: Migrate deprecated model IDs before deployment."
  echo "[MODEL-AUDIT] Replacement models listed in eval/deprecated_models.json."
  exit 1
fi
