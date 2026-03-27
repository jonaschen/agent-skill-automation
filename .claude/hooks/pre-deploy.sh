#!/bin/bash
# .claude/hooks/pre-deploy.sh
#
# Enforce quality thresholds before allowing a Skill deployment.
# Triggered by agentic-cicd-gate or manual deployment flow.

set -euo pipefail

SKILL_PATH="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
EVAL_RUNNER="$REPO_ROOT/eval/run_eval.sh"

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Error: No SKILL_PATH provided to pre-deploy.sh" >&2
  exit 1
fi

echo "🚀 Pre-deploy check: $SKILL_PATH"

# Call the eval runner directly for an objective trigger rate measurement.
# The skill-quality-validator agent also uses this runner in its pipeline.
# We skip permissions for the eval run as it's an automated check.
set +e
EVAL_OUTPUT=$("$EVAL_RUNNER" "$SKILL_PATH")
EXIT_CODE=$?
set -e

# Extract pass rate from output (last line contains "Pass rate : 0.xx")
PASS_RATE=$(echo "$EVAL_OUTPUT" | grep "Pass rate :" | awk '{print $4}')

echo "$EVAL_OUTPUT"

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "✅ Quality threshold passed (Trigger rate: $PASS_RATE). Deployment allowed."
  exit 0
elif [ "$EXIT_CODE" -eq 2 ]; then
  echo "❌ Deployment blocked: Trigger rate $PASS_RATE is below the 75% failure threshold."
  echo "   Handing off to autoresearch-optimizer for automatic repair."
  exit 1
else
  echo "❌ Deployment blocked: Evaluation runner failed with exit code $EXIT_CODE."
  exit 1
fi
