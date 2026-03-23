#!/bin/bash
# run_eval.sh — Binary evaluation runner for Agent Skills
#
# Usage: run_eval.sh <skill-path>
#
# Runs a set of fixed test prompts against a Skill and outputs a single
# float pass rate (0.0–1.0). Each test case is evaluated as binary:
#   1 = Skill triggered correctly AND output matches expected structure
#   0 = Skill not triggered, or output does not match expectation
#
# Exit codes:
#   0 = evaluation completed successfully (check pass rate output)
#   1 = error or not yet implemented

set -euo pipefail

SKILL_PATH="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
EXPECTED_DIR="$SCRIPT_DIR/expected"

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Usage: run_eval.sh <skill-path>" >&2
  exit 1
fi

if [ ! -f "$SKILL_PATH" ]; then
  echo "❌ Skill file not found: $SKILL_PATH" >&2
  exit 1
fi

# Count available test cases
PROMPT_COUNT=$(find "$PROMPTS_DIR" -name "test_*.txt" 2>/dev/null | wc -l)

if [ "$PROMPT_COUNT" -eq 0 ]; then
  echo "❌ No test prompts found in $PROMPTS_DIR" >&2
  echo "   Create test_1.txt ... test_N.txt prompt files first" >&2
  exit 1
fi

echo "📊 Running binary evaluation for: $SKILL_PATH"
echo "   Test cases: $PROMPT_COUNT"
echo ""

# TODO (Phase 2): Implement the full binary eval loop
# For each test case:
#   1. Execute in isolated sandbox (no memory contamination)
#   2. Check if correct Skill was triggered
#   3. Validate output structure against expected schema
#   4. Record binary result (1 = pass, 0 = fail)
#
# Output: single float pass rate

PASSED=0
TOTAL=0

for PROMPT_FILE in "$PROMPTS_DIR"/test_*.txt; do
  TEST_NUM=$(basename "$PROMPT_FILE" .txt | sed 's/test_//')
  EXPECTED_FILE="$EXPECTED_DIR/test_${TEST_NUM}.txt"

  TOTAL=$((TOTAL + 1))

  if [ ! -f "$EXPECTED_FILE" ]; then
    echo "  ⚠️  Test $TEST_NUM: missing expected output file, marking as FAIL"
    continue
  fi

  # TODO (Phase 2): Run actual evaluation
  # output=$(execute_in_sandbox "$SKILL_PATH" "$PROMPT_FILE")
  # if validate_output "$output" "$EXPECTED_FILE"; then
  #   PASSED=$((PASSED + 1))
  #   echo "  ✅ Test $TEST_NUM: PASS"
  # else
  #   echo "  ❌ Test $TEST_NUM: FAIL"
  # fi

  echo "  ⏳ Test $TEST_NUM: NOT YET IMPLEMENTED"
done

if [ "$TOTAL" -gt 0 ]; then
  # Use awk for float division (portable)
  PASS_RATE=$(awk "BEGIN {printf \"%.2f\", $PASSED / $TOTAL}")
  echo ""
  echo "─────────────────────────────"
  echo "Pass rate: $PASS_RATE ($PASSED/$TOTAL)"
  echo "─────────────────────────────"
else
  echo "❌ No test cases executed" >&2
  exit 1
fi

# Exit non-zero until fully implemented (Phase 0 requirement)
echo ""
echo "⚠️  Evaluation runner not yet fully implemented (Phase 2)"
exit 1
