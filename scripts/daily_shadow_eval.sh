#!/bin/bash
# daily_shadow_eval.sh — Dedicated cron job for model migration shadow evals
#
# Runs the eval suite against a pending migration model as a direct Python
# invocation (no Claude session needed). Designed to run at 11:30 PM
# Asia/Taipei — before the night research cycle starts at 1:00 AM.
#
# Idempotent: checks experiment_log.json for existing results before running.
# Fires only when PENDING_MIGRATION_MODEL is set and has zero matching entries.
# Writes results that the factory-steward reads at 3:00 AM.
#
# This script solves the L12 time-budget mismatch: the ~88-minute eval cannot
# complete within the factory-steward's ~44-minute cron session. Running the
# eval as a standalone cron job eliminates the scheduling conflict.
#
# Usage: Called by cron, or manually: ./scripts/daily_shadow_eval.sh
#
# Schedule: 30 23 * * * /home/jonas/gemini-home/agent-skill-automation/scripts/daily_shadow_eval.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/shadow-eval-${DATE}.log"

mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation
unset TERMINAL

# ── Configuration ──────────────────────────────────────────────────────
# Set to the target model ID when a migration is pending.
# Set to empty string when no migration is pending.
PENDING_MIGRATION_MODEL="claude-opus-4-7"

SKILL_PATH=".claude/agents/meta-agent-factory.md"
EXPERIMENT_LOG="$REPO_ROOT/eval/experiment_log.json"
INTER_TEST_DELAY=15
# ──────────────────────────────────────────────────────────────────────

echo "=== Shadow Eval — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Initialize session logging
init_session_log "shadow-eval" "$REPO_ROOT"
log_session_start "shadow-eval"

START_TIME=$(date +%s)

# Finalize: write perf JSON on any exit
finalize() {
  local exit_code=$?
  set +euo pipefail
  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))

  cat > "$PERF_DIR/shadow-eval-${DATE}.json" << PERF_EOF
{
  "agent": "shadow-eval",
  "date": "$DATE",
  "duration_seconds": $duration,
  "target_model": "${PENDING_MIGRATION_MODEL:-none}",
  "exit_code": $exit_code,
  "status": "${EVAL_STATUS:-unknown}"
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  check_cost_ceiling "shadow-eval" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "Finished: $(date)" >> "$LOG_FILE"
  echo "Duration: ${duration}s | Status: ${EVAL_STATUS:-unknown}" >> "$LOG_FILE"

  find "$LOG_DIR" -name "shadow-eval-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "shadow-eval-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

EVAL_STATUS="skip"

# Gate 1: Is a migration pending?
if [ -z "$PENDING_MIGRATION_MODEL" ]; then
  echo "[SKIP] No pending migration model configured" >> "$LOG_FILE"
  exit 0
fi

# Gate 2: Has the eval already been run for this model?
shadow_eval_done=$(cd "$REPO_ROOT" && python3 -c "
import json
try:
    data = json.load(open('$EXPERIMENT_LOG'))
    exps = data.get('experiments', data) if isinstance(data, dict) else data
    print('yes' if any('$PENDING_MIGRATION_MODEL' in json.dumps(e) for e in exps) else 'no')
except:
    print('no')
" 2>/dev/null || echo "no")

if [ "$shadow_eval_done" = "yes" ]; then
  echo "[SKIP] Shadow eval for $PENDING_MIGRATION_MODEL already in experiment_log.json" >> "$LOG_FILE"
  exit 0
fi

# Pre-flight: validate experiment log integrity before we read/write it
if ! python3 "$REPO_ROOT/eval/validate_experiment_log.py" "$EXPERIMENT_LOG" 2>> "$LOG_FILE"; then
  echo "[FAIL] experiment_log.json is malformed — refusing to proceed" >> "$LOG_FILE"
  EVAL_STATUS="log-validation-failed"
  log_event "ERROR" "{\"reason\":\"experiment_log_validation_failed\"}"
  exit 1
fi

echo "[RUN] Starting shadow eval for $PENDING_MIGRATION_MODEL" >> "$LOG_FILE"
log_event "SHADOW_EVAL_START" "{\"model\":\"$PENDING_MIGRATION_MODEL\"}"
EVAL_STATUS="running"

# Run the eval with timeout safety net (5400s = 90 min)
# Prevents overlap with 1:00 AM researcher session if eval runs long
EVAL_TIMEOUT=5400
cd "$REPO_ROOT"
EVAL_OUTPUT=$(timeout "$EVAL_TIMEOUT" python3 eval/run_eval_async.py \
  --model "$PENDING_MIGRATION_MODEL" \
  --split train \
  --inter-test-delay "$INTER_TEST_DELAY" \
  "$SKILL_PATH" 2>&1)
EVAL_EXIT=$?

if [ "$EVAL_EXIT" -eq 124 ]; then
  echo "[TIMEOUT] Eval exceeded ${EVAL_TIMEOUT}s limit" >> "$LOG_FILE"
  echo "$EVAL_OUTPUT" >> "$LOG_FILE"
  EVAL_STATUS="timeout"
  log_event "SHADOW_EVAL_TIMEOUT" "{\"model\":\"$PENDING_MIGRATION_MODEL\",\"timeout_seconds\":$EVAL_TIMEOUT}"
  exit 1
elif [ "$EVAL_EXIT" -ne 0 ]; then
  echo "[FAIL] Eval runner exited with error (code $EVAL_EXIT)" >> "$LOG_FILE"
  echo "$EVAL_OUTPUT" >> "$LOG_FILE"
  EVAL_STATUS="eval-failed"
  log_event "SHADOW_EVAL_FAIL" "{\"model\":\"$PENDING_MIGRATION_MODEL\",\"reason\":\"eval_runner_error\",\"exit_code\":$EVAL_EXIT}"
  exit 1
fi

echo "$EVAL_OUTPUT" >> "$LOG_FILE"

# Parse results from eval output
PASS_COUNT=$(echo "$EVAL_OUTPUT" | grep -oP 'PASS:\s*\K\d+' | tail -1 || echo "0")
TOTAL_COUNT=$(echo "$EVAL_OUTPUT" | grep -oP 'TOTAL:\s*\K\d+' | tail -1 || echo "0")

if [ "$TOTAL_COUNT" -eq 0 ]; then
  echo "[FAIL] Could not parse eval results (TOTAL=0)" >> "$LOG_FILE"
  EVAL_STATUS="parse-failed"
  exit 1
fi

# Compute Bayesian posterior
BAYESIAN_OUTPUT=$(python3 eval/bayesian_eval.py --passes "$PASS_COUNT" --total "$TOTAL_COUNT" 2>&1) || {
  echo "[FAIL] Bayesian eval failed" >> "$LOG_FILE"
  echo "$BAYESIAN_OUTPUT" >> "$LOG_FILE"
  EVAL_STATUS="bayesian-failed"
  exit 1
}

POSTERIOR_MEAN=$(echo "$BAYESIAN_OUTPUT" | grep -oP 'posterior_mean[:\s]*\K[0-9.]+' | head -1 || echo "0")
CI_LOWER=$(echo "$BAYESIAN_OUTPUT" | grep -oP 'ci_lower[:\s]*\K[0-9.]+' | head -1 || echo "0")
CI_UPPER=$(echo "$BAYESIAN_OUTPUT" | grep -oP 'ci_upper[:\s]*\K[0-9.]+' | head -1 || echo "0")

echo "" >> "$LOG_FILE"
echo "Results: $PASS_COUNT/$TOTAL_COUNT PASS" >> "$LOG_FILE"
echo "Posterior: mean=$POSTERIOR_MEAN CI=[$CI_LOWER, $CI_UPPER]" >> "$LOG_FILE"

# Append to experiment_log.json
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
python3 -c "
import json
data = json.load(open('$EXPERIMENT_LOG'))
exps = data.get('experiments', [])
exps.append({
    'iteration': len(exps),
    'timestamp': '$TIMESTAMP',
    'branch': 'shadow-eval-$PENDING_MIGRATION_MODEL',
    'model': '$PENDING_MIGRATION_MODEL',
    'pass_rate': $PASS_COUNT / $TOTAL_COUNT,
    'posterior_mean': $POSTERIOR_MEAN,
    'ci_lower': $CI_LOWER,
    'ci_upper': $CI_UPPER,
    'passes': $PASS_COUNT,
    'total': $TOTAL_COUNT,
    'change_description': 'Shadow eval: $PENDING_MIGRATION_MODEL on training set (T=$TOTAL_COUNT)',
    'outcome': 'shadow-eval'
})
data['experiments'] = exps
with open('$EXPERIMENT_LOG', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
print('Written to experiment_log.json')
" >> "$LOG_FILE" 2>&1

# Go/No-Go assessment
echo "" >> "$LOG_FILE"
echo "=== Go/No-Go Assessment ===" >> "$LOG_FILE"

# G1: CI overlap with baseline [0.702, 0.927]
G1_PASS=$(python3 -c "
ci_l, ci_u = $CI_LOWER, $CI_UPPER
base_l, base_u = 0.702, 0.927
overlap = ci_l <= base_u and ci_u >= base_l
print('PASS' if overlap else 'FAIL')
" 2>/dev/null || echo "ERROR")

# G3: Duration within 2x (baseline ~88 min estimated)
END_TIME=$(date +%s)
EVAL_DURATION=$((END_TIME - START_TIME))
G3_PASS="PASS"
if [ "$EVAL_DURATION" -gt 10560 ]; then  # 2x 88min = 176min = 10560s
  G3_PASS="FAIL"
fi

echo "G1 (CI overlap with [0.702, 0.927]): $G1_PASS" >> "$LOG_FILE"
echo "G2 (zero 400 errors): CHECK MANUALLY in eval output above" >> "$LOG_FILE"
echo "G3 (duration ≤ 2x baseline): $G3_PASS (${EVAL_DURATION}s)" >> "$LOG_FILE"

if [ "$G1_PASS" = "PASS" ] && [ "$G3_PASS" = "PASS" ]; then
  echo "" >> "$LOG_FILE"
  echo "VERDICT: PRELIMINARY GO (G2 requires manual 400-error review)" >> "$LOG_FILE"
  EVAL_STATUS="preliminary-go"
else
  echo "" >> "$LOG_FILE"
  echo "VERDICT: NO-GO (G1=$G1_PASS, G3=$G3_PASS)" >> "$LOG_FILE"
  EVAL_STATUS="no-go"
fi

log_event "SHADOW_EVAL_COMPLETE" "{\"model\":\"$PENDING_MIGRATION_MODEL\",\"posterior_mean\":$POSTERIOR_MEAN,\"ci_lower\":$CI_LOWER,\"ci_upper\":$CI_UPPER,\"verdict\":\"$EVAL_STATUS\"}"

exit 0
