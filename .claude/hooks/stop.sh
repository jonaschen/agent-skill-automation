#!/bin/bash
# stop.sh — Lifecycle termination hook
#
# Runs on Stop events for graceful shutdown.
# Ensures running eval processes complete and partial state is saved.
#
# Exit code 0 = clean shutdown
# Exit code 1 = error during shutdown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"

# 1. Wait for any running eval processes (max 30s)
eval_pids=$(pgrep -f "run_eval_async.py" 2>/dev/null || true)
if [ -n "$eval_pids" ]; then
  echo "Waiting for eval processes to finish (max 30s)..." >&2
  for pid in $eval_pids; do
    timeout 30 tail --pid="$pid" -f /dev/null 2>/dev/null || true
  done
fi

# 2. Log shutdown event
if [ -f "$LIFECYCLE_TRACKER" ]; then
  python3 "$LIFECYCLE_TRACKER" --skill "_system" --stage deprecated --note "graceful shutdown" 2>/dev/null || true
fi

echo "Shutdown complete." >&2
exit 0
