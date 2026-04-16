#!/bin/bash
# .claude/hooks/pre-deploy.sh
#
# Enforce security checks and Bayesian quality thresholds before allowing a Skill deployment.
# Triggered by agentic-cicd-gate or manual deployment flow.

set -euo pipefail

SKILL_PATH="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EVAL_RUNNER="python3 $REPO_ROOT/eval/run_eval_async.py"

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Error: No SKILL_PATH provided to pre-deploy.sh" >&2
  exit 1
fi

echo "🚀 Pre-deploy check: $SKILL_PATH"

# --- Dependency Lock Check (Python) ---
check_python_deps() {
  if [ -f "$REPO_ROOT/requirements.txt" ]; then
    local diff_output
    diff_output=$(pip freeze 2>/dev/null | diff - "$REPO_ROOT/requirements.txt" 2>&1) || true
    if [ -n "$diff_output" ]; then
      echo "[DEPLOY-GATE] FAIL: Python dependencies differ from requirements.txt"
      echo "[DEPLOY-GATE] Run 'pip freeze > requirements.txt' and commit the update"
      return 1
    fi
    echo "[DEPLOY-GATE] PASS: Python dependencies match locked manifest"
  else
    echo "[DEPLOY-GATE] WARN: No requirements.txt found — run 'pip freeze > requirements.txt'"
  fi
  return 0
}

# --- npm Audit Check (warning-only) ---
check_npm_audit() {
  if command -v npm >/dev/null 2>&1 && [ -f "$REPO_ROOT/package-lock.json" ]; then
    set +e
    npm audit --audit-level=high 2>/dev/null
    local audit_exit=$?
    set -e
    if [ $audit_exit -ne 0 ]; then
      echo "[DEPLOY-GATE] WARN: npm audit found high-severity vulnerabilities"
    else
      echo "[DEPLOY-GATE] PASS: npm audit clean"
    fi
  fi
  return 0  # Always pass — npm audit is warning-only
}

echo "--- Dependency checks ---"
set +e
check_python_deps
PYTHON_DEPS_EXIT=$?
set -e

if [ "$PYTHON_DEPS_EXIT" -ne 0 ]; then
  echo "Dependency lock mismatch. Update requirements.txt before deployment."
  exit 1
fi

check_npm_audit

# --- Security Suite ---
# Run all security checks via the unified aggregator.
SECURITY_SUITE="$REPO_ROOT/eval/security_suite.sh"
if [ -f "$SECURITY_SUITE" ]; then
  echo "Running security suite..."
  set +e
  bash "$SECURITY_SUITE" "$SKILL_PATH" >/dev/null
  SECURITY_EXIT=$?
  set -e

  if [ "$SECURITY_EXIT" -ne 0 ]; then
    echo "❌ Security suite FAILED. Fix security issues before deployment."
    exit 1
  fi
  echo "✅ Security suite passed."
fi

# --- Model Deprecation Guard ---
DEPRECATION_CHECK="$REPO_ROOT/eval/model_deprecation_check.sh"
if [ -f "$DEPRECATION_CHECK" ]; then
  set +e
  bash "$DEPRECATION_CHECK"
  DEP_EXIT=$?
  set -e
  if [ "$DEP_EXIT" -ne 0 ]; then
    echo "❌ Deprecated model references detected. Update before deployment."
    exit 1
  fi
fi

# --- Model Audit (cron/eval scripts — closes gap vs. deploy-time-only guard) ---
MODEL_AUDIT="$REPO_ROOT/scripts/model_audit.sh"
if [ -f "$MODEL_AUDIT" ]; then
  set +e
  bash "$MODEL_AUDIT"
  AUDIT_EXIT=$?
  set -e
  if [ "$AUDIT_EXIT" -ne 0 ]; then
    echo "❌ Deprecated model IDs found in operational scripts/eval. Migrate before deployment."
    exit 1
  fi
fi

# Call the Bayesian async runner.
set +e
EVAL_OUTPUT=$($EVAL_RUNNER "$SKILL_PATH")
EXIT_CODE=$?
set -e

echo "$EVAL_OUTPUT"

# Extract Bayesian stats from the OVERALL line:
# Format: "OVERALL: 0.587 CI [0.443, 0.723]"
OVERALL_LINE=$(echo "$EVAL_OUTPUT" | grep "OVERALL:" || true)

if [ -z "$OVERALL_LINE" ]; then
  echo "❌ Error: Could not find Bayesian output in evaluation results."
  exit 1
fi

MEAN=$(echo "$OVERALL_LINE" | awk '{print $2}')
CI_LOWER=$(echo "$OVERALL_LINE" | awk '{print $4}' | tr -d '[],')
CI_UPPER=$(echo "$OVERALL_LINE" | awk '{print $5}' | tr -d '[],')

echo "----------------------------------------------------"
echo "Decision Metrics:"
echo "  Posterior Mean: $MEAN (Target: ≥ 0.90)"
echo "  Lower 95% CI:   $CI_LOWER (Target: ≥ 0.80)"
echo "----------------------------------------------------"

# Gate condition: posterior_mean >= 0.90 AND ci_lower >= 0.80
PASSED_GATE=$(echo "$MEAN >= 0.90 && $CI_LOWER >= 0.80" | bc)

if [ "$PASSED_GATE" -eq 1 ]; then
  echo "✅ Quality threshold passed. Deployment allowed."
  exit 0
else
  echo "❌ Deployment blocked: Skill quality does not meet the mandatory threshold."
  echo "   (Required: Mean ≥ 0.90 AND Lower CI ≥ 0.80)"
  echo "   Handing off to autoresearch-optimizer for automatic repair."
  exit 1
fi
