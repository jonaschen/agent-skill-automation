#!/bin/bash
# stop.sh — Lifecycle termination hook
#
# This hook runs on Stop events for graceful shutdown and cleanup.
# It ensures any in-progress operations are safely terminated and
# temporary resources are cleaned up.
#
# Usage: stop.sh
#
# Exit code 0 = clean shutdown
# Exit code 1 = error during shutdown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EVAL_DIR="$REPO_ROOT/eval"
SANDBOX_DIR="/tmp/skill-eval-sandbox"
SANDBOX_TMP_PATTERN="/tmp/skill-eval-*"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "🛑 Graceful shutdown initiated: $TIMESTAMP"

# --- Step 1: Terminate running eval processes ---
EVAL_PIDS=$(pgrep -f "run_eval.sh" 2>/dev/null || true)
if [ -n "$EVAL_PIDS" ]; then
  echo "  Terminating running eval processes..."
  for pid in $EVAL_PIDS; do
    kill "$pid" 2>/dev/null || true
  done
  echo "  ✅ Eval processes terminated"
else
  echo "  ℹ️  No running eval processes"
fi

# --- Step 2: Save partial experiment state ---
EXPERIMENT_LOG="$EVAL_DIR/experiment_log.json"
if [ -f "$EXPERIMENT_LOG" ]; then
  # Mark any in-progress experiments as interrupted
  if command -v python3 &>/dev/null; then
    python3 -c "
import json
with open('$EXPERIMENT_LOG', 'r') as f:
    data = json.load(f)
modified = False
for exp in data.get('experiments', []):
    if exp.get('status') == 'in_progress':
        exp['status'] = 'interrupted'
        exp['interrupted_at'] = '$TIMESTAMP'
        modified = True
if modified:
    with open('$EXPERIMENT_LOG', 'w') as f:
        json.dump(data, f, indent=2)
    print('  ✅ Marked in-progress experiments as interrupted')
else:
    print('  ℹ️  No in-progress experiments to save')
" 2>/dev/null || echo "  ⚠️  Could not update experiment log"
  fi
else
  echo "  ℹ️  No experiment log found"
fi

# --- Step 3: Clean up temporary sandbox environments ---
if [ -d "$SANDBOX_DIR" ]; then
  rm -rf "$SANDBOX_DIR"
  echo "  ✅ Cleaned up sandbox: $SANDBOX_DIR"
else
  echo "  ℹ️  No sandbox to clean up"
fi

# --- Step 4: Clean up any test-generated files ---
# Remove temporary files created during eval runs
find "$REPO_ROOT" -name "*.eval.tmp" -type f -delete 2>/dev/null || true
find /tmp -name "${SANDBOX_TMP_PATTERN##/tmp/}" -type f -mmin +60 -delete 2>/dev/null || true
echo "  ✅ Temporary files cleaned up"

# --- Step 5: Log shutdown event ---
DEPLOY_LOG="$EVAL_DIR/deploy_history.json"
if [ -f "$DEPLOY_LOG" ] && command -v python3 &>/dev/null; then
  python3 -c "
import json
with open('$DEPLOY_LOG', 'r') as f:
    data = json.load(f)
data['deployments'].append({
    'skill_name': '_system',
    'timestamp': '$TIMESTAMP',
    'action': 'graceful_shutdown',
    'commit_sha': '$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")'
})
with open('$DEPLOY_LOG', 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || echo "  ⚠️  Could not log shutdown event"
fi

echo ""
echo "🛑 Graceful shutdown complete: $TIMESTAMP"
exit 0
