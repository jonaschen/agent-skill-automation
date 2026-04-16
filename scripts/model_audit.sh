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

FOUND=0

# --- 1. Load deprecated model IDs from deprecated_models.json ---
if [ ! -f "$DEPRECATED_MODELS_FILE" ]; then
  echo "[MODEL-AUDIT] WARN: $DEPRECATED_MODELS_FILE not found — skipping model ID check"
else
  # Extract model IDs with a retirement date that has not yet passed
  TODAY=$(date +%Y-%m-%d)
  mapfile -t DEPRECATED_IDS < <(
    python3 -c "
import json, sys
with open('$DEPRECATED_MODELS_FILE') as f:
    data = json.load(f)
# data may be a list or {'models': [...]}
entries = data if isinstance(data, list) else data.get('models', [])
for e in entries:
    mid = e.get('model_id', '')
    ret = e.get('retirement_date', '')
    if mid and ret >= '$TODAY':
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
      # Exclude the registry file itself (deprecated_models.json is the data source, not a usage)
      HITS=$(grep -rl "$MODEL_ID" "$DIR" \
        --include="*.sh" --include="*.py" --include="*.md" --include="*.json" \
        --exclude="deprecated_models.json" \
        2>/dev/null || true)
      if [ -n "$HITS" ]; then
        echo "[MODEL-AUDIT] FAIL: Deprecated model '$MODEL_ID' found in operational code:"
        grep -rn "$MODEL_ID" "$DIR" \
          --include="*.sh" --include="*.py" --include="*.md" --include="*.json" \
          --exclude="deprecated_models.json" \
          2>/dev/null | while IFS= read -r line; do
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
if [ "$FOUND" -eq 0 ]; then
  echo "[MODEL-AUDIT] PASS: No deprecated model IDs found in operational code."
  exit 0
else
  echo "[MODEL-AUDIT] FAIL: Migrate deprecated model IDs before deployment."
  echo "[MODEL-AUDIT] Replacement models listed in eval/deprecated_models.json."
  exit 1
fi
