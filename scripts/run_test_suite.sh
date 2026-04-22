#!/usr/bin/env bash
# scripts/run_test_suite.sh — Orchestrates all test suites and writes a structured JSON report
#
# Usage:
#   ./scripts/run_test_suite.sh           # Static suites only (fast: permissions, security, changeling)
#   ./scripts/run_test_suite.sh --full    # All suites including eval trigger tests (~30min)
#   ./scripts/run_test_suite.sh --suite permissions|security|changeling|mcp|eval
#
# Output: JSON report to logs/test-reports/report-YYYY-MM-DD-HHMMSS.json
# Exit codes: 0 = all passed, 1 = failures found, 2 = eval below deployment gate

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EVAL_DIR="$REPO_ROOT/eval"
REPORT_DIR="$REPO_ROOT/logs/test-reports"
SKILL_PATH="$REPO_ROOT/.claude/skills/meta-agent-factory/SKILL.md"

mkdir -p "$REPORT_DIR"

# --- Parse arguments ---
RUN_MODE="static"  # static | full | single
SINGLE_SUITE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --full) RUN_MODE="full"; shift ;;
    --suite)
      RUN_MODE="single"
      SINGLE_SUITE="$2"
      shift 2
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# --- Timestamps ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
REPORT_FILE="$REPORT_DIR/report-$(date +%Y-%m-%d-%H%M%S).json"
START_EPOCH=$(date +%s)

# --- Result accumulators ---
TOTAL_CHECKS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_WARNED=0
TOTAL_SKIPPED=0
SUITES_RUN=()
SUITES_JSON=""
ALL_FAILURES=""
OVERALL_EXIT=0

# Helper: append to comma-separated JSON list
append_json() {
  local var_name="$1"
  local value="$2"
  local current="${!var_name}"
  if [ -n "$current" ]; then
    eval "$var_name=\"\$current,\$value\""
  else
    eval "$var_name=\"\$value\""
  fi
}

should_run() {
  local suite="$1"
  if [ "$RUN_MODE" = "full" ]; then return 0; fi
  if [ "$RUN_MODE" = "single" ] && [ "$SINGLE_SUITE" = "$suite" ]; then return 0; fi
  if [ "$RUN_MODE" = "static" ] && [ "$suite" != "eval" ]; then return 0; fi
  return 1
}

# Helper: find all .mcp.json files in repo (root + nested projects)
find_mcp_configs() {
  local configs=()
  if [ -f "$REPO_ROOT/.mcp.json" ]; then
    configs+=("$REPO_ROOT/.mcp.json")
  fi
  for f in "$REPO_ROOT"/*/.mcp.json "$REPO_ROOT"/.claude/.mcp.json; do
    [ -f "$f" ] && configs+=("$f")
  done
  printf '%s\n' "${configs[@]}"
}

# ============================================================
# Suite 1: Permission Checks
# ============================================================
if should_run "permissions"; then
  echo "=== Suite: permissions ==="
  SUITES_RUN+=("permissions")
  PERM_CHECKS=""
  PERM_PASS=0
  PERM_FAIL=0
  PERM_SUITE_STATUS="pass"

  for agent_file in "$REPO_ROOT/.claude/agents"/*.md; do
    [ -f "$agent_file" ] || continue
    agent_name=$(basename "$agent_file" .md)
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    set +e
    output=$(bash "$EVAL_DIR/check-permissions.sh" "$agent_file" 2>&1)
    rc=$?
    set -e

    if [ $rc -eq 0 ]; then
      PERM_PASS=$((PERM_PASS + 1))
      TOTAL_PASSED=$((TOTAL_PASSED + 1))
      status="pass"
    else
      PERM_FAIL=$((PERM_FAIL + 1))
      TOTAL_FAILED=$((TOTAL_FAILED + 1))
      PERM_SUITE_STATUS="fail"
      OVERALL_EXIT=1
      status="fail"
      detail=$(echo "$output" | grep -E 'VIOLATION' | head -1 | sed 's/"/\\"/g' | head -c 200)
      append_json ALL_FAILURES "{\"suite\":\"permissions\",\"check\":\"$agent_name\",\"details\":\"$detail\"}"
    fi

    append_json PERM_CHECKS "{\"agent\":\"$agent_name\",\"status\":\"$status\"}"
    echo "  $status: $agent_name"
  done

  append_json SUITES_JSON "\"permissions\":{\"status\":\"$PERM_SUITE_STATUS\",\"passed\":$PERM_PASS,\"failed\":$PERM_FAIL,\"checks\":[$PERM_CHECKS]}"
  echo ""
fi

# ============================================================
# Suite 2: Security Suite
# ============================================================
if should_run "security"; then
  echo "=== Suite: security ==="
  SUITES_RUN+=("security")
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

  set +e
  sec_output=$(bash "$EVAL_DIR/security_suite.sh" 2>&1)
  sec_rc=$?
  set -e

  # Try to extract JSON block from output (security_suite outputs JSON to stdout)
  sec_json=$(echo "$sec_output" | sed -n '/^{/,/^}/p' 2>/dev/null || echo "")

  if [ $sec_rc -eq 0 ]; then
    TOTAL_PASSED=$((TOTAL_PASSED + 1))
    sec_status="pass"
    echo "  pass: security suite"
  else
    TOTAL_FAILED=$((TOTAL_FAILED + 1))
    sec_status="fail"
    OVERALL_EXIT=1
    echo "  fail: security suite"
    detail=$(echo "$sec_output" | grep -iE 'fail|error' | head -1 | sed 's/"/\\"/g' | head -c 200)
    append_json ALL_FAILURES "{\"suite\":\"security\",\"check\":\"security_suite\",\"details\":\"$detail\"}"
  fi

  # Embed raw security JSON if parseable, otherwise wrap as string
  if echo "$sec_json" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    append_json SUITES_JSON "\"security\":{\"status\":\"$sec_status\",\"raw_report\":$sec_json}"
  else
    clean_output=$(echo "$sec_output" | tail -5 | tr '\n' ' ' | sed 's/"/\\"/g' | head -c 500)
    append_json SUITES_JSON "\"security\":{\"status\":\"$sec_status\",\"details\":\"$clean_output\"}"
  fi
  echo ""
fi

# ============================================================
# Suite 3: Changeling Validation
# ============================================================
if should_run "changeling"; then
  echo "=== Suite: changeling ==="
  SUITES_RUN+=("changeling")

  set +e
  chg_output=$(bash "$EVAL_DIR/changeling_validation.sh" 2>&1)
  chg_rc=$?
  set -e

  # Parse PASS/FAIL/WARN counts from output
  chg_pass=$(echo "$chg_output" | grep -oP '\d+(?= passed)' || echo "0")
  chg_fail=$(echo "$chg_output" | grep -oP '\d+(?= failed)' || echo "0")
  chg_warn=$(echo "$chg_output" | grep -oP '\d+(?= warning)' || echo "0")

  TOTAL_CHECKS=$((TOTAL_CHECKS + chg_pass + chg_fail))
  TOTAL_PASSED=$((TOTAL_PASSED + chg_pass))
  TOTAL_FAILED=$((TOTAL_FAILED + chg_fail))
  TOTAL_WARNED=$((TOTAL_WARNED + chg_warn))

  if [ $chg_rc -eq 0 ]; then
    chg_status="pass"
    echo "  pass: changeling ($chg_pass passed, $chg_warn warnings)"
  else
    chg_status="fail"
    OVERALL_EXIT=1
    echo "  fail: changeling ($chg_fail failed)"
    # Extract individual failures
    while IFS= read -r line; do
      detail=$(echo "$line" | sed 's/.*\[FAIL\] //' | sed 's/"/\\"/g' | head -c 200)
      append_json ALL_FAILURES "{\"suite\":\"changeling\",\"check\":\"validation\",\"details\":\"$detail\"}"
    done < <(echo "$chg_output" | grep '\[FAIL\]')
  fi

  chg_details=$(echo "$chg_output" | tail -3 | tr '\n' ' ' | sed 's/"/\\"/g' | head -c 300)
  append_json SUITES_JSON "\"changeling\":{\"status\":\"$chg_status\",\"passed\":$chg_pass,\"failed\":$chg_fail,\"warned\":$chg_warn,\"details\":\"$chg_details\"}"
  echo ""
fi

# ============================================================
# Suite 4: MCP Config Validation
# ============================================================
if should_run "mcp"; then
  echo "=== Suite: mcp ==="
  SUITES_RUN+=("mcp")
  MCP_PASS=0
  MCP_FAIL=0
  MCP_WARN=0
  MCP_SUITE_STATUS="pass"
  MCP_CHECKS=""

  MCP_CONFIGS=$(find_mcp_configs)
  if [ -z "$MCP_CONFIGS" ]; then
    echo "  skip: no .mcp.json files found"
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1))
    append_json SUITES_JSON "\"mcp\":{\"status\":\"skipped\",\"reason\":\"no .mcp.json files found\"}"
  else
    while IFS= read -r mcp_file; do
      [ -z "$mcp_file" ] && continue
      mcp_label=$(realpath --relative-to="$REPO_ROOT" "$mcp_file" 2>/dev/null || basename "$mcp_file")
      TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

      set +e
      mcp_output=$(bash "$EVAL_DIR/mcp_config_validator.sh" "$mcp_file" 2>&1)
      mcp_rc=$?
      set -e

      # Extract error/warning counts from validator output
      mcp_errors=$(echo "$mcp_output" | grep -oP '\d+(?= error)' || echo "0")
      mcp_warnings=$(echo "$mcp_output" | grep -oP '\d+(?= warning)' || echo "0")
      MCP_WARN=$((MCP_WARN + mcp_warnings))
      TOTAL_WARNED=$((TOTAL_WARNED + mcp_warnings))

      if [ $mcp_rc -eq 0 ]; then
        MCP_PASS=$((MCP_PASS + 1))
        TOTAL_PASSED=$((TOTAL_PASSED + 1))
        status="pass"
      else
        MCP_FAIL=$((MCP_FAIL + 1))
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
        MCP_SUITE_STATUS="fail"
        OVERALL_EXIT=1
        status="fail"
        detail=$(echo "$mcp_output" | grep -iE 'ERROR' | head -1 | sed 's/"/\\"/g' | head -c 200)
        append_json ALL_FAILURES "{\"suite\":\"mcp\",\"check\":\"$mcp_label\",\"details\":\"$detail\"}"
      fi

      append_json MCP_CHECKS "{\"config\":\"$mcp_label\",\"status\":\"$status\",\"errors\":$mcp_errors,\"warnings\":$mcp_warnings}"
      echo "  $status: $mcp_label ($mcp_errors errors, $mcp_warnings warnings)"
    done <<< "$MCP_CONFIGS"

    append_json SUITES_JSON "\"mcp\":{\"status\":\"$MCP_SUITE_STATUS\",\"passed\":$MCP_PASS,\"failed\":$MCP_FAIL,\"warned\":$MCP_WARN,\"checks\":[$MCP_CHECKS]}"
  fi
  echo ""
fi

# ============================================================
# Suite 5: Eval Trigger Tests (expensive — only with --full or --suite eval)
# ============================================================
if should_run "eval"; then
  echo "=== Suite: eval (this may take 15-30 minutes) ==="
  SUITES_RUN+=("eval")

  if [ ! -f "$SKILL_PATH" ]; then
    echo "  skip: skill file not found: $SKILL_PATH"
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1))
    append_json SUITES_JSON "\"eval\":{\"status\":\"skipped\",\"reason\":\"skill file not found\"}"
  else
    set +e
    eval_output=$(python3 "$EVAL_DIR/run_eval_async.py" "$SKILL_PATH" --verbose --no-cache 2>&1)
    eval_rc=$?
    set -e

    # Parse Bayesian stats from output
    overall_mean=$(echo "$eval_output" | grep -oP 'OVERALL:\s+\K[0-9.]+' || echo "0")
    overall_ci_l=$(echo "$eval_output" | grep 'OVERALL:' | grep -oP '\[\K[0-9.]+' || echo "0")
    overall_ci_u=$(echo "$eval_output" | grep 'OVERALL:' | grep -oP ',\s*\K[0-9.]+(?=\])' || echo "0")

    train_mean=$(echo "$eval_output" | grep -oP 'TRAIN:\s+\K[0-9.]+' || echo "0")
    train_ci_l=$(echo "$eval_output" | grep 'TRAIN:' | grep -oP '\[\K[0-9.]+' || echo "0")
    train_ci_u=$(echo "$eval_output" | grep 'TRAIN:' | grep -oP ',\s*\K[0-9.]+(?=\])' || echo "0")

    val_mean=$(echo "$eval_output" | grep -oP 'VAL:\s+\K[0-9.]+' || echo "0")
    val_ci_l=$(echo "$eval_output" | grep 'VAL:' | grep -oP '\[\K[0-9.]+' || echo "0")
    val_ci_u=$(echo "$eval_output" | grep 'VAL:' | grep -oP ',\s*\K[0-9.]+(?=\])' || echo "0")

    # Parse per-test results
    EVAL_FAILURES=""
    EVAL_PER_TEST=""
    eval_pass=0
    eval_fail=0
    eval_skip=0

    # Read splits for classification
    TRAIN_IDS=$(python3 -c "import json; print(' '.join(str(x) for x in json.load(open('$EVAL_DIR/splits.json'))['train']))" 2>/dev/null || echo "")
    VAL_IDS=$(python3 -c "import json; print(' '.join(str(x) for x in json.load(open('$EVAL_DIR/splits.json'))['validation']))" 2>/dev/null || echo "")

    while IFS= read -r line; do
      # Lines like "Test  1: PASS" or "Test 14: FAIL:not-triggered"
      tid=$(echo "$line" | grep -oP 'Test\s+\K\d+')
      result=$(echo "$line" | grep -oP ':\s+\K\S+$')
      [ -z "$tid" ] && continue

      # Classify split
      split="unknown"
      if echo " $TRAIN_IDS " | grep -q " $tid "; then split="train"; fi
      if echo " $VAL_IDS " | grep -q " $tid "; then split="validation"; fi

      append_json EVAL_PER_TEST "{\"test_id\":$tid,\"result\":\"$result\",\"split\":\"$split\"}"

      if [ "$result" = "PASS" ]; then
        eval_pass=$((eval_pass + 1))
      elif echo "$result" | grep -q "^SKIP"; then
        eval_skip=$((eval_skip + 1))
      else
        eval_fail=$((eval_fail + 1))
        # Determine failure category
        category=$(echo "$result" | sed 's/FAIL://')
        append_json EVAL_FAILURES "{\"test_id\":$tid,\"category\":\"$category\",\"split\":\"$split\",\"prompt_file\":\"eval/prompts/test_${tid}.txt\",\"result\":\"$result\"}"
        append_json ALL_FAILURES "{\"suite\":\"eval\",\"check\":\"test_$tid\",\"details\":\"$result ($split split)\"}"
      fi
    done < <(echo "$eval_output" | grep -E '^Test\s+[0-9]+:')

    eval_total=$((eval_pass + eval_fail))
    TOTAL_CHECKS=$((TOTAL_CHECKS + eval_total))
    TOTAL_PASSED=$((TOTAL_PASSED + eval_pass))
    TOTAL_FAILED=$((TOTAL_FAILED + eval_fail))
    TOTAL_SKIPPED=$((TOTAL_SKIPPED + eval_skip))

    # Deployment gate check
    gate_passed="false"
    if python3 -c "exit(0 if $overall_mean >= 0.90 and $overall_ci_l >= 0.80 else 1)" 2>/dev/null; then
      gate_passed="true"
    fi

    # Overfit check
    overfit_passed="false"
    if python3 -c "exit(0 if $train_mean >= 0.90 and $val_mean >= 0.85 else 1)" 2>/dev/null; then
      overfit_passed="true"
    fi

    if [ "$eval_fail" -gt 0 ]; then
      eval_status="fail"
      OVERALL_EXIT=1
    else
      eval_status="pass"
    fi

    # If gate failed, set exit=2
    if [ "$gate_passed" = "false" ] && [ "$OVERALL_EXIT" -eq 0 ]; then
      OVERALL_EXIT=2
    fi

    echo "  $eval_status: $eval_pass/$eval_total passed ($eval_fail failed, $eval_skip skipped)"
    echo "  Bayesian: overall=$overall_mean [$overall_ci_l, $overall_ci_u]"
    echo "  Gate: $gate_passed | Overfit: $overfit_passed"

    append_json SUITES_JSON "\"eval\":{\"status\":\"$eval_status\",\"posterior_mean\":$overall_mean,\"ci_lower\":$overall_ci_l,\"ci_upper\":$overall_ci_u,\"train\":{\"posterior_mean\":$train_mean,\"ci_lower\":$train_ci_l,\"ci_upper\":$train_ci_u},\"validation\":{\"posterior_mean\":$val_mean,\"ci_lower\":$val_ci_l,\"ci_upper\":$val_ci_u},\"passed\":$eval_pass,\"failed\":$eval_fail,\"skipped\":$eval_skip,\"deployment_gate\":$gate_passed,\"overfit_check\":$overfit_passed,\"failures\":[$EVAL_FAILURES],\"per_test\":[$EVAL_PER_TEST]}"
  fi
  echo ""
fi

# ============================================================
# Build final report
# ============================================================
END_EPOCH=$(date +%s)
DURATION=$((END_EPOCH - START_EPOCH))

# Build suites_run JSON array
SUITES_RUN_JSON=""
for s in "${SUITES_RUN[@]}"; do
  if [ -n "$SUITES_RUN_JSON" ]; then SUITES_RUN_JSON="$SUITES_RUN_JSON,"; fi
  SUITES_RUN_JSON="$SUITES_RUN_JSON\"$s\""
done

cat > "$REPORT_FILE" << EOF
{
  "report_type": "test-suite-run",
  "timestamp": "$TIMESTAMP",
  "duration_seconds": $DURATION,
  "suites_run": [$SUITES_RUN_JSON],
  "summary": {
    "total_checks": $TOTAL_CHECKS,
    "passed": $TOTAL_PASSED,
    "failed": $TOTAL_FAILED,
    "warned": $TOTAL_WARNED,
    "skipped": $TOTAL_SKIPPED
  },
  "suites": {$SUITES_JSON},
  "failures": [${ALL_FAILURES}]
}
EOF

echo "========================================="
echo "  Test Suite Report"
echo "========================================="
echo "  Suites: ${SUITES_RUN[*]}"
echo "  Results: $TOTAL_PASSED passed, $TOTAL_FAILED failed, $TOTAL_WARNED warned, $TOTAL_SKIPPED skipped"
echo "  Duration: ${DURATION}s"
echo "  Report: $REPORT_FILE"
echo "========================================="

exit $OVERALL_EXIT
