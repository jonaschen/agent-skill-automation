#!/bin/bash
# check_repeatability.sh — Verify eval measurement repeatability
#
# Usage: check_repeatability.sh <skill-path> [num-runs]
#
# Runs the eval suite multiple times against a Skill and checks that the
# results are within the acceptable repeatability threshold (≤ 5% difference
# between any two runs).
#
# This script addresses ROADMAP Phase 2.1: "Confirm two runs on the same
# Skill differ by ≤ 5%"
#
# Exit codes:
#   0 = repeatability confirmed (all runs within threshold)
#   1 = error (missing files, etc.)
#   2 = repeatability failed (runs differ by > 5%)

set -euo pipefail

SKILL_PATH="${1:-}"
NUM_RUNS="${2:-3}"
MAX_DIFF=5  # percentage points
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVAL_SCRIPT="$SCRIPT_DIR/run_eval.sh"

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Usage: check_repeatability.sh <skill-path> [num-runs]"
  echo "   num-runs defaults to 3"
  exit 1
fi

if [ ! -f "$SKILL_PATH" ]; then
  echo "❌ Skill file not found: $SKILL_PATH"
  exit 1
fi

if [ ! -x "$EVAL_SCRIPT" ]; then
  echo "❌ Eval script not found or not executable: $EVAL_SCRIPT"
  exit 1
fi

echo "🔄 Repeatability check: $SKILL_PATH"
echo "   Runs planned : $NUM_RUNS"
echo "   Max allowed diff: ${MAX_DIFF}%"
echo ""

RATES=()

for i in $(seq 1 "$NUM_RUNS"); do
  echo "── Run $i of $NUM_RUNS ──"
  OUTPUT=$("$EVAL_SCRIPT" "$SKILL_PATH" 2>&1) || true
  RATE=$(echo "$OUTPUT" | grep "^Pass rate" | awk '{print $4}')

  if [ -z "$RATE" ]; then
    echo "❌ Could not extract pass rate from run $i"
    echo "$OUTPUT"
    exit 1
  fi

  RATE_PCT=$(awk "BEGIN {printf \"%d\", $RATE * 100 + 0.5}")
  echo "   Pass rate: $RATE ($RATE_PCT%)"
  RATES+=("$RATE")

  # Record result for flaky detection
  if [ -f "$SCRIPT_DIR/flaky_detector.py" ] && command -v python3 &>/dev/null; then
    SKILL_NAME=$(basename "$(dirname "$SKILL_PATH")" 2>/dev/null || basename "$SKILL_PATH" .md)
    # Record individual test results if available
    while IFS= read -r line; do
      if echo "$line" | grep -qE "^  [✅❌]"; then
        TEST_NUM=$(echo "$line" | grep -oP 'Test \K[0-9]+')
        if echo "$line" | grep -q "✅"; then
          python3 "$SCRIPT_DIR/flaky_detector.py" record "$SKILL_NAME" "test_$TEST_NUM" pass 2>/dev/null || true
        else
          python3 "$SCRIPT_DIR/flaky_detector.py" record "$SKILL_NAME" "test_$TEST_NUM" fail 2>/dev/null || true
        fi
      fi
    done <<< "$OUTPUT"
  fi

  echo ""
done

# --- Check pairwise differences ---
echo "─────────────────────────────"
echo "Results:"
for i in "${!RATES[@]}"; do
  echo "  Run $((i+1)): ${RATES[$i]}"
done
echo ""

FAILED=0
for i in "${!RATES[@]}"; do
  for j in "${!RATES[@]}"; do
    if [ "$i" -lt "$j" ]; then
      DIFF=$(awk "BEGIN {d = (${RATES[$i]} - ${RATES[$j]}); if (d < 0) d = -d; printf \"%d\", d * 100 + 0.5}")
      echo "  Run $((i+1)) vs Run $((j+1)): ${DIFF}% difference"
      if [ "$DIFF" -gt "$MAX_DIFF" ]; then
        echo "  ❌ Exceeds ${MAX_DIFF}% threshold!"
        FAILED=1
      fi
    fi
  done
done

echo ""
echo "─────────────────────────────"
if [ "$FAILED" -eq 0 ]; then
  echo "✅ REPEATABILITY CONFIRMED: All runs within ${MAX_DIFF}% of each other"
  exit 0
else
  echo "❌ REPEATABILITY FAILED: Some runs differ by > ${MAX_DIFF}%"
  echo "   Consider investigating non-determinism sources"
  exit 2
fi
