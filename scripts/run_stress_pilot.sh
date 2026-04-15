#!/bin/bash
# scripts/run_stress_pilot.sh — Phase 4.2 stress test pilot kickoff
#
# Runs the 10-skill pilot via closed_loop.sh to validate end-to-end pipeline.
# Pauses overnight agents during the run to avoid quota contention, then
# restores them.
#
# Expected wall-clock: ~1-2 hours with --pilot-mode (structural validation)
#   (1-2 min GENERATE + ~1 min VALIDATE per skill; full eval runs 8-12h without --pilot-mode)
#
# Usage:
#   ./scripts/run_stress_pilot.sh              # Run 10-skill pilot
#   ./scripts/run_stress_pilot.sh --dry-run    # Show plan without executing
#   ./scripts/run_stress_pilot.sh --no-pause   # Don't pause overnight agents
#
# Outputs:
#   logs/stress_pilot_YYYY-MM-DD.log  — full execution log
#   eval/stress_test_log.json         — per-skill results (append-only)
#   eval/stress_test/pilot_summary.md — human-readable summary on completion

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DATE=$(date +"%Y-%m-%d")
PILOT_FILE="$REPO_ROOT/eval/stress_test/pilot_10.txt"   # default; override with --requirements
CRONTAB_BACKUP="$REPO_ROOT/logs/crontab_backup_${DATE}.txt"

DRY_RUN=0
PAUSE_CRON=1
LOG_SUFFIX=""

# Argument parsing — supports --requirements <file> for retry runs (e.g., 6-10 only)
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)  DRY_RUN=1; shift ;;
    --no-pause) PAUSE_CRON=0; shift ;;
    --requirements)
      [ -f "$2" ] || { echo "--requirements file not found: $2" >&2; exit 1; }
      PILOT_FILE="$2"
      # Derive log suffix from filename stem so retries get distinct log files
      LOG_SUFFIX="_$(basename "$2" .txt)"
      shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Log file depends on suffix (default: stress_pilot_YYYY-MM-DD.log; retry: stress_pilot_YYYY-MM-DD_<stem>.log)
LOG_FILE="$REPO_ROOT/logs/stress_pilot_${DATE}${LOG_SUFFIX}.log"

# Preflight checks
[ -f "$PILOT_FILE" ] || { echo "Missing $PILOT_FILE"; exit 1; }
[ -x "$SCRIPT_DIR/closed_loop.sh" ] || { echo "closed_loop.sh not executable"; exit 1; }
command -v claude >/dev/null || { echo "'claude' CLI not found in PATH"; exit 1; }

# Flexible requirement count: 1-10 supported (typical pilot=10, retry subset=1-9)
REQ_COUNT=$(grep -cE "^[A-Z]" "$PILOT_FILE")
if [ "$REQ_COUNT" -lt 1 ] || [ "$REQ_COUNT" -gt 10 ]; then
  echo "Expected 1-10 requirements, found $REQ_COUNT in $PILOT_FILE" >&2
  exit 1
fi

echo "=== Stress Test Pilot — $DATE ==="
echo "Requirements file: $PILOT_FILE ($REQ_COUNT skills)"
echo "Log file:          $LOG_FILE"
echo "Crontab backup:    $CRONTAB_BACKUP"
echo "Pause overnight agents: $([ $PAUSE_CRON -eq 1 ] && echo YES || echo NO)"
echo "Dry run:                $([ $DRY_RUN -eq 1 ] && echo YES || echo NO)"
echo ""

if [ $DRY_RUN -eq 1 ]; then
  echo "DRY RUN — would execute:"
  echo "  1. Back up crontab → $CRONTAB_BACKUP"
  [ $PAUSE_CRON -eq 1 ] && echo "  2. Pause ALL daily agents (researcher, 3 stewards, reviewer, ltc, factory-steward)"
  echo "  3. nohup $SCRIPT_DIR/closed_loop.sh $PILOT_FILE > $LOG_FILE 2>&1 &"
  echo "  4. Write PID to $REPO_ROOT/logs/stress_pilot.pid"
  echo "  5. Display monitoring commands"
  echo ""
  echo "To actually run, drop --dry-run"
  exit 0
fi

# Back up crontab
crontab -l > "$CRONTAB_BACKUP" 2>/dev/null || { echo "No existing crontab — nothing to pause"; PAUSE_CRON=0; }
echo "[1/4] Crontab backed up → $CRONTAB_BACKUP"

# Pause ALL agents — including factory-steward — during the pilot.
# Previous version kept factory-steward active under the assumption its Phase 1.5
# triage would stand down. That didn't work: factory-steward's cron just called
# claude -p concurrently with the pilot's claude -p, starving the pilot of quota.
# Pilot 2026-04-12 failed because of this quota contention. Never again.
if [ $PAUSE_CRON -eq 1 ]; then
  cat "$CRONTAB_BACKUP" \
    | grep -v "daily_research_sweep\|daily_android_sw_steward\|daily_arm_mrs_steward\|daily_bsp_knowledge_steward\|daily_project_reviewer\|daily_ltc_steward\|daily_factory_steward" \
    | crontab -
  echo "[2/4] Paused: ALL daily agents (researcher, 3 stewards, reviewer, ltc, factory)"
  echo "      Only non-agent crons (if any) remain active"
fi

# Kick off pilot in background
# --pilot-mode: use structural validation instead of full 59-test eval per skill.
# This cuts wall-clock from ~12h to ~1-2h. Full regression test runs after pilot.
cd "$REPO_ROOT"
nohup bash -c "
  bash '$SCRIPT_DIR/closed_loop.sh' '$PILOT_FILE' --pilot-mode --inter-test-delay 30
  PILOT_EXIT=\$?
  echo ''
  echo '=========================================='
  echo 'POST-PILOT: Running regression test...'
  echo '=========================================='
  bash '$SCRIPT_DIR/regression_test.sh' --check-only 2>&1 || true
  echo ''
  echo 'Pilot exit code: '\$PILOT_EXIT
  # Auto-restore crontab so nightly agents resume without manual intervention
  if [ -f '$CRONTAB_BACKUP' ]; then
    crontab '$CRONTAB_BACKUP'
    echo '[AUTO-RESTORE] Crontab restored from $CRONTAB_BACKUP'
  else
    echo '[WARN] Crontab backup not found at $CRONTAB_BACKUP — manual restore needed'
  fi
" > "$LOG_FILE" 2>&1 &
PID=$!
echo $PID > "$REPO_ROOT/logs/stress_pilot.pid"
echo "[3/4] Pilot launched — PID $PID"
echo "      Log: tail -f $LOG_FILE"

# Summary + restoration instructions
cat << EOF
[4/4] Pilot is running. To monitor:

    tail -f $LOG_FILE
    ps -p $PID           # check if still alive
    jobs -l              # see background processes

When pilot finishes (or you want to abort):

    kill \$(cat $REPO_ROOT/logs/stress_pilot.pid)    # abort
    crontab $CRONTAB_BACKUP                                    # restore overnight agents

Review results:

    cat $REPO_ROOT/eval/stress_test_log.json | jq '.'
    grep -E "DEPLOYED|FAILED" $LOG_FILE | sort | uniq -c
EOF

exit 0
