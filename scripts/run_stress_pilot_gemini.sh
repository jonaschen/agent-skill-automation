#!/bin/bash
# scripts/run_stress_pilot_gemini.sh — Gemini Phase 4.2 stress test pilot
#
# Runs the 10-skill pilot via closed_loop_gemini.sh.
# Pauses overnight agents during the run.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$REPO_ROOT/logs/stress_pilot_gemini_${DATE}.log"
PILOT_FILE="$REPO_ROOT/eval/stress_test/pilot_10.txt"
CRONTAB_BACKUP="$REPO_ROOT/logs/crontab_backup_gemini_${DATE}.txt"

# Preflight
[ -f "$PILOT_FILE" ] || { echo "Missing $PILOT_FILE"; exit 1; }
command -v gemini >/dev/null || { echo "'gemini' CLI not found"; exit 1; }

# Backup crontab
crontab -l > "$CRONTAB_BACKUP" 2>/dev/null || true
echo "Pausing daily agents..."
crontab -l 2>/dev/null | grep -v "daily_" | crontab - || true

# Launch Gemini pilot
echo "Launching Gemini pilot in background..."
cd "$REPO_ROOT"
nohup bash -c "
  bash '$SCRIPT_DIR/closed_loop_gemini.sh' '$PILOT_FILE' --pilot-mode --inter-test-delay 30
  crontab '$CRONTAB_BACKUP'
" > "$LOG_FILE" 2>&1 &

echo "Pilot running. PID: $!"
echo "Log: tail -f $LOG_FILE"
