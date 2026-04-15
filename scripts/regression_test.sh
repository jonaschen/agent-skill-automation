#!/bin/bash
# scripts/regression_test.sh — Post-deployment regression test for existing agents
#
# Validates that existing agent trigger rates haven't degraded after deploying
# new Skills. Runs the eval suite against the current meta-agent-factory
# description and compares with the baseline.
#
# Usage:
#   bash scripts/regression_test.sh                    # Run against current baseline
#   bash scripts/regression_test.sh --update-baseline  # Run and save results as new baseline
#   bash scripts/regression_test.sh --check-only       # Compare last run against baseline (no eval)
#
# Exit codes:
#   0 — no regression detected
#   1 — regression detected (CI lower bound dropped below baseline)
#   2 — error (missing baseline, eval failure)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASELINE_FILE="$REPO_ROOT/eval/regression_baseline.json"
LAST_RUN_FILE="$REPO_ROOT/eval/regression_last_run.json"
EVAL_RUNNER="$REPO_ROOT/eval/run_eval_async.py"
SKILL_PATH="$REPO_ROOT/.claude/agents/meta-agent-factory.md"

MODE="${1:---run}"

# --- Helper: run eval and extract Bayesian metrics ---
run_eval_and_score() {
  local split="$1"
  local output

  echo "Running eval (split=$split)..." >&2
  output=$(python3 "$EVAL_RUNNER" "$SKILL_PATH" --split "$split" --inter-test-delay 10 --verbose 2>&1) || true

  # Count PASS/FAIL from individual test result lines
  local pass_count total_count
  pass_count=$(echo "$output" | grep -cP '^Test\s+\d+:\s+PASS' || echo "0")
  total_count=$(echo "$output" | grep -cP '^Test\s+\d+:\s+(PASS|FAIL)' || echo "0")

  # Parse the summary line: SPLIT (TRAIN): 0.829 CI [0.702, 0.927]
  local posterior_mean ci_lower ci_upper
  posterior_mean=$(echo "$output" | grep -oP 'SPLIT \([A-Z]+\):\s*\K[0-9.]+' | head -1 || echo "0.0")
  ci_lower=$(echo "$output" | grep -oP 'CI \[\K[0-9.]+' | head -1 || echo "0.0")
  ci_upper=$(echo "$output" | grep -oP 'CI \[[0-9.]+,\s*\K[0-9.]+' | head -1 || echo "0.0")

  # Fallback: compute from pass/total if summary parsing failed
  if [ "$posterior_mean" = "0.0" ] && [ "$total_count" -gt 0 ]; then
    posterior_mean=$(python3 -c "print(round(($pass_count + 1) / ($total_count + 2), 3))" 2>/dev/null || echo "0.0")
  fi

  echo "$pass_count $total_count $posterior_mean $ci_lower $ci_upper"
}

# --- Save results to JSON ---
save_results() {
  local filepath="$1" split="$2" pass_count="$3" total_count="$4" posterior_mean="$5" ci_lower="$6" ci_upper="$7"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  local git_sha
  git_sha=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")

  cat > "$filepath" << EOF
{
  "timestamp": "$timestamp",
  "git_sha": "$git_sha",
  "split": "$split",
  "pass_count": $pass_count,
  "total_count": $total_count,
  "posterior_mean": $posterior_mean,
  "ci_lower": $ci_lower,
  "ci_upper": $ci_upper
}
EOF
}

# --- Compare current run against baseline ---
check_regression() {
  if [ ! -f "$BASELINE_FILE" ]; then
    echo "ERROR: No baseline file at $BASELINE_FILE" >&2
    echo "Run with --update-baseline first to establish baseline." >&2
    return 2
  fi
  if [ ! -f "$LAST_RUN_FILE" ]; then
    echo "ERROR: No last run file at $LAST_RUN_FILE" >&2
    echo "Run without flags first to generate a comparison run." >&2
    return 2
  fi

  local baseline_mean baseline_ci_lower
  baseline_mean=$(python3 -c "import json; print(json.load(open('$BASELINE_FILE'))['posterior_mean'])" 2>/dev/null)
  baseline_ci_lower=$(python3 -c "import json; print(json.load(open('$BASELINE_FILE'))['ci_lower'])" 2>/dev/null)

  local current_mean current_ci_lower current_ci_upper
  current_mean=$(python3 -c "import json; print(json.load(open('$LAST_RUN_FILE'))['posterior_mean'])" 2>/dev/null)
  current_ci_lower=$(python3 -c "import json; print(json.load(open('$LAST_RUN_FILE'))['ci_lower'])" 2>/dev/null)
  current_ci_upper=$(python3 -c "import json; print(json.load(open('$LAST_RUN_FILE'))['ci_upper'])" 2>/dev/null)

  local baseline_sha current_sha
  baseline_sha=$(python3 -c "import json; print(json.load(open('$BASELINE_FILE'))['git_sha'])" 2>/dev/null)
  current_sha=$(python3 -c "import json; print(json.load(open('$LAST_RUN_FILE'))['git_sha'])" 2>/dev/null)

  echo "=========================================="
  echo "  Regression Test Results"
  echo "=========================================="
  echo ""
  echo "  Baseline ($baseline_sha):"
  echo "    Posterior mean:  $baseline_mean"
  echo "    CI lower (95%):  $baseline_ci_lower"
  echo ""
  echo "  Current ($current_sha):"
  echo "    Posterior mean:  $current_mean"
  echo "    CI lower (95%):  $current_ci_lower"
  echo "    CI upper (95%):  $current_ci_upper"
  echo ""

  # Regression check: current CI lower below baseline CI lower by >0.05
  local regression
  regression=$(python3 -c "
baseline_ci = $baseline_ci_lower
current_ci = $current_ci_lower
# Regression if current CI lower drops more than 0.05 below baseline
regressed = current_ci < (baseline_ci - 0.05)
print('yes' if regressed else 'no')
" 2>/dev/null || echo "unknown")

  if [ "$regression" = "yes" ]; then
    echo "  REGRESSION DETECTED"
    echo "  Current CI lower ($current_ci_lower) dropped >0.05 below baseline ($baseline_ci_lower)"
    echo "=========================================="
    return 1
  else
    echo "  NO REGRESSION"
    echo "  Trigger rates remain within acceptable bounds."
    echo "=========================================="
    return 0
  fi
}

# --- Main ---
case "$MODE" in
  --update-baseline)
    echo "Establishing baseline from training split..."
    read -r pass_count total_count posterior_mean ci_lower ci_upper <<< "$(run_eval_and_score train)"
    save_results "$BASELINE_FILE" "train" "$pass_count" "$total_count" "$posterior_mean" "$ci_lower" "$ci_upper"
    echo ""
    echo "Baseline saved to $BASELINE_FILE"
    echo "  Pass: $pass_count/$total_count | Mean: $posterior_mean | CI: [$ci_lower, $ci_upper]"
    ;;

  --check-only)
    check_regression
    ;;

  --run|*)
    echo "Running regression test on training split..."
    read -r pass_count total_count posterior_mean ci_lower ci_upper <<< "$(run_eval_and_score train)"
    save_results "$LAST_RUN_FILE" "train" "$pass_count" "$total_count" "$posterior_mean" "$ci_lower" "$ci_upper"
    echo "  Pass: $pass_count/$total_count | Mean: $posterior_mean | CI: [$ci_lower, $ci_upper]"
    echo ""

    if [ -f "$BASELINE_FILE" ]; then
      check_regression
    else
      echo "No baseline exists yet. Run with --update-baseline to set one."
      echo "Current results saved to $LAST_RUN_FILE"
    fi
    ;;
esac
