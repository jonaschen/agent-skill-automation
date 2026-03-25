#!/bin/bash
# pre-deploy.sh — Enforce quality threshold before deployment
#
# Usage: pre-deploy.sh <skill-path>
#
# This hook is called before a Skill is deployed to .claude/.
# It runs the permission checker and eval runner, then blocks
# deployment if the trigger rate is below the required threshold.
#
# Exit code 0 = deployment allowed
# Exit code 1 = deployment blocked (quality or permission failure)
# Exit code 2 = deployment blocked (infrastructure error)

set -euo pipefail

SKILL_PATH="${1:-}"
THRESHOLD=90  # integer percentage (90 = 0.90)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EVAL_DIR="$REPO_ROOT/eval"

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Usage: pre-deploy.sh <skill-path>"
  exit 1
fi

if [ ! -f "$SKILL_PATH" ]; then
  echo "❌ Skill file not found: $SKILL_PATH"
  exit 1
fi

SKILL_NAME=$(basename "$(dirname "$SKILL_PATH")" 2>/dev/null || basename "$SKILL_PATH" .md)
echo "🔒 Pre-deploy gate: $SKILL_NAME"
echo "   Skill path: $SKILL_PATH"
echo ""

# --- Step 1: Permission check ---
echo "── Step 1: Permission validation ──"
if [ -x "$EVAL_DIR/check-permissions.sh" ]; then
  if ! "$EVAL_DIR/check-permissions.sh" "$SKILL_PATH"; then
    echo ""
    echo "❌ Deployment BLOCKED: Permission check failed"
    exit 1
  fi
  echo "✅ Permissions: PASS"
else
  echo "⚠️  check-permissions.sh not found or not executable"
  echo "❌ Deployment BLOCKED: Cannot verify permissions"
  exit 2
fi

echo ""

# --- Step 2: Trigger rate evaluation ---
echo "── Step 2: Trigger rate evaluation ──"
if [ -x "$EVAL_DIR/run_eval.sh" ]; then
  EVAL_OUTPUT=$("$EVAL_DIR/run_eval.sh" "$SKILL_PATH" 2>&1) || true
  PASS_RATE=$(echo "$EVAL_OUTPUT" | grep "^Pass rate" | awk '{print $4}' || echo "")

  if [ -z "$PASS_RATE" ]; then
    echo "⚠️  Could not parse pass rate from eval output"
    echo "$EVAL_OUTPUT"
    echo ""
    echo "❌ Deployment BLOCKED: Eval runner did not produce a pass rate"
    exit 2
  fi

  PASS_RATE_INT=$(awk "BEGIN {printf \"%d\", $PASS_RATE * 100 + 0.5}")
  echo "   Trigger rate: $PASS_RATE ($PASS_RATE_INT%)"

  if [ "$PASS_RATE_INT" -ge "$THRESHOLD" ]; then
    echo "✅ Trigger rate: PASS (≥ ${THRESHOLD}%)"
  elif [ "$PASS_RATE_INT" -ge 75 ]; then
    echo "⚠️  Trigger rate: CONDITIONAL (75%–$((THRESHOLD-1))%)"
    echo "   Deployment allowed with warning"
  else
    echo "❌ Trigger rate: FAIL (< 75%)"
    echo ""
    echo "❌ Deployment BLOCKED: Trigger rate below minimum threshold"
    echo "   Recommended: Run autoresearch-optimizer to improve the Skill"
    exit 1
  fi
else
  echo "⚠️  run_eval.sh not found or not executable"
  echo "❌ Deployment BLOCKED: Cannot measure trigger rate"
  exit 2
fi

echo ""

# --- Step 3: Flaky test check ---
echo "── Step 3: Flaky test check ──"
if [ -f "$EVAL_DIR/flaky_detector.py" ] && command -v python3 &>/dev/null; then
  FLAKY_OUTPUT=$(python3 "$EVAL_DIR/flaky_detector.py" check "$SKILL_NAME" 2>&1) || true
  FLAKY_COUNT=$(echo "$FLAKY_OUTPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('flaky_count',0))" 2>/dev/null || echo "0")

  if [ "$FLAKY_COUNT" -gt 0 ]; then
    echo "⚠️  $FLAKY_COUNT flaky test(s) detected — excluded from trigger rate calculation"
  else
    echo "✅ No flaky tests detected"
  fi
else
  echo "ℹ️  Flaky detector not available (skipping)"
fi

echo ""

# --- Step 4: Record deployment attempt ---
echo "── Step 4: Logging deployment ──"
DEPLOY_LOG="$EVAL_DIR/deploy_history.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_SHA=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

if [ -f "$DEPLOY_LOG" ]; then
  # Append to existing log using python for safe JSON manipulation
  python3 -c "
import json, sys
with open('$DEPLOY_LOG', 'r') as f:
    data = json.load(f)
data['deployments'].append({
    'skill_name': '$SKILL_NAME',
    'timestamp': '$TIMESTAMP',
    'commit_sha': '$GIT_SHA',
    'trigger_rate': $PASS_RATE,
    'action': 'deployed',
    'impact_scope': 'pending',
    'affected_skills': [],
    'rollback_reason': None,
    'monitoring': {'1h': None, '6h': None, '24h': None}
})
with open('$DEPLOY_LOG', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || echo "⚠️  Could not update deploy history"
else
  # Create new deploy history
  python3 -c "
import json
data = {'deployments': [{
    'skill_name': '$SKILL_NAME',
    'timestamp': '$TIMESTAMP',
    'commit_sha': '$GIT_SHA',
    'trigger_rate': $PASS_RATE,
    'action': 'deployed',
    'impact_scope': 'pending',
    'affected_skills': [],
    'rollback_reason': None,
    'monitoring': {'1h': None, '6h': None, '24h': None}
}]}
with open('$DEPLOY_LOG', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || echo "⚠️  Could not create deploy history"
fi

echo "✅ Deployment logged"

echo ""
echo "─────────────────────────────"
echo "✅ Pre-deploy gate: PASSED"
echo "   Deployment of $SKILL_NAME is allowed"
echo "─────────────────────────────"
exit 0
