#!/bin/bash
# .claude/hooks/pre-deploy.sh
#
# Enforce Bayesian quality thresholds before allowing a Skill deployment.
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

# Call the Bayesian async runner.
# We skip permissions for the eval run as it's an automated check.
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
# Use bc for float comparison
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
