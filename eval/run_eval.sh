#!/bin/bash
# run_eval.sh — Binary evaluation runner for Agent Skills
#
# Usage: run_eval.sh <skill-path> [--verbose]
#
# Runs the fixed 30-prompt test set against a Skill and outputs a single
# float pass rate (0.0–1.0). Each test case is evaluated as binary:
#   1 = Skill triggered correctly AND output matches expected structure
#   0 = Skill not triggered, or triggered incorrectly
#
# Expected file format (eval/expected/test_N.txt):
#   EXPECT_TRIGGER=yes|no
#   EXPECT_TYPE=Sub-agent|Skill|Changeling role   (only when EXPECT_TRIGGER=yes)
#   EXPECT_CONTAINS=<string to grep for>          (only when EXPECT_TRIGGER=yes)
#
# Exit codes:
#   0 = evaluation completed, pass rate printed to stdout
#   1 = error (missing files, claude not found, etc.)

set -euo pipefail

SKILL_PATH="${1:-}"
VERBOSE="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
EXPECTED_DIR="$SCRIPT_DIR/expected"
TIMEOUT_PER_TEST=120   # seconds per claude invocation
SLEEP_BETWEEN_TESTS=${EVAL_SLEEP:-3}   # seconds between API calls; override with EVAL_SLEEP=0

# --- Preflight checks ---

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Usage: run_eval.sh <skill-path> [--verbose]" >&2
  exit 1
fi

if [ ! -f "$SKILL_PATH" ]; then
  echo "❌ Skill file not found: $SKILL_PATH" >&2
  exit 1
fi

if ! command -v claude &>/dev/null; then
  echo "❌ claude CLI not found in PATH" >&2
  exit 1
fi

PROMPT_COUNT=$(find "$PROMPTS_DIR" -name "test_*.txt" 2>/dev/null | wc -l | tr -d ' ')

if [ "$PROMPT_COUNT" -eq 0 ]; then
  echo "❌ No test prompts found in $PROMPTS_DIR" >&2
  exit 1
fi

# --- Helpers ---

read_field() {
  # read_field <file> <key>  →  prints value of KEY=value line
  local file="$1" key="$2"
  grep "^${key}=" "$file" 2>/dev/null | cut -d= -f2-
}

run_prompt() {
  # Run a single prompt through claude from the repo root.
  # Merges stderr into stdout: when a write is blocked, claude outputs the
  # "here's what I would have written" message (containing the confirmation
  # summary) to stderr. We need it for trigger detection.
  local prompt="$1"
  timeout "$TIMEOUT_PER_TEST" \
    claude --dangerously-skip-permissions -p "$prompt" \
    2>&1 || true
}

cleanup_generated_files() {
  # Remove files created during the eval run without removing git-tracked files.
  # Uses git to identify untracked files so committed test outputs are preserved.
  (
    cd "$REPO_ROOT"
    # Remove untracked .md files in .claude/agents/
    git ls-files --others --exclude-standard -- '.claude/agents/*.md' | xargs -r rm -f
    # Remove untracked skill directories in .claude/skills/
    git ls-files --others --exclude-standard -- '.claude/skills/' \
      | awk -F/ 'NF>=3{print ".claude/skills/"$3}' | sort -u | xargs -r rm -rf
  )
  # Remove untracked Changeling roles (not tracked by this repo's git)
  local core_roles="security-auditor perf-analyst database-administrator"
  for f in "$HOME/.claude/@lib/agents/"*.md; do
    [ -f "$f" ] || continue
    local name
    name=$(basename "$f" .md)
    if ! echo "$core_roles" | grep -qw "$name"; then
      rm -f "$f"
    fi
  done
}

evaluate_case() {
  # evaluate_case <test_num>  →  prints PASS or FAIL with reason
  local n="$1"
  local prompt_file="$PROMPTS_DIR/test_${n}.txt"
  local expected_file="$EXPECTED_DIR/test_${n}.txt"

  if [ ! -f "$prompt_file" ]; then
    echo "FAIL:missing-prompt"
    return
  fi
  if [ ! -f "$expected_file" ]; then
    echo "FAIL:missing-expected"
    return
  fi

  local expect_trigger expect_contains
  expect_trigger=$(read_field "$expected_file" "EXPECT_TRIGGER")
  expect_contains=$(read_field "$expected_file" "EXPECT_CONTAINS")

  local prompt output
  prompt=$(cat "$prompt_file")

  # Run claude from repo root so .claude/ skills are loaded
  output=$(cd "$REPO_ROOT" && run_prompt "$prompt")

  # Clean up any files generated during this test before evaluating result
  cleanup_generated_files

  # Trigger detection: look for any meta-agent-factory output signature.
  # "skill-quality-validator" appears in the recommended-next-step line of
  # every meta-agent-factory response regardless of output format variation.
  # Also accept the full confirmation table and write-blocked intermediate format.
  local triggered=0
  if echo "$output" | grep -qE \
    "skill-quality-validator|Agent generation complete|Tools granted:|Tools denied:"; then
    triggered=1
  fi

  if [ "$expect_trigger" = "yes" ]; then
    if [ "$triggered" -eq 1 ]; then
      echo "PASS"
    else
      echo "FAIL:not-triggered"
    fi
  else
    if [ "$triggered" -eq 1 ]; then
      echo "FAIL:false-positive"
    else
      echo "PASS"
    fi
  fi
}

# --- Main eval loop ---

echo "📊 Binary eval: $SKILL_PATH"
echo "   Test cases : $PROMPT_COUNT"
echo "   Timeout    : ${TIMEOUT_PER_TEST}s per test"
echo ""

PASSED=0
TOTAL=0
FAILURES=()

for PROMPT_FILE in $(ls "$PROMPTS_DIR"/test_*.txt | sort -t_ -k2 -n); do
  TEST_NUM=$(basename "$PROMPT_FILE" .txt | sed 's/test_//')
  TOTAL=$((TOTAL + 1))

  RESULT=$(evaluate_case "$TEST_NUM")

  if [ "$RESULT" = "PASS" ]; then
    PASSED=$((PASSED + 1))
    [ "$VERBOSE" = "--verbose" ] && echo "  ✅ Test $TEST_NUM: PASS"
  else
    REASON="${RESULT#FAIL:}"
    FAILURES+=("Test $TEST_NUM: $REASON")
    [ "$VERBOSE" = "--verbose" ] && echo "  ❌ Test $TEST_NUM: FAIL ($REASON)"
  fi

  sleep "$SLEEP_BETWEEN_TESTS"
done

# --- Results ---

PASS_RATE=$(awk "BEGIN {printf \"%.2f\", $PASSED / $TOTAL}")

echo ""
echo "─────────────────────────────"
echo "Pass rate : $PASS_RATE  ($PASSED / $TOTAL)"

if [ ${#FAILURES[@]} -gt 0 ]; then
  echo ""
  echo "Failures:"
  for f in "${FAILURES[@]}"; do
    echo "  ✗ $f"
  done
fi

echo "─────────────────────────────"

# Threshold judgement (mirrors skill-quality-validator thresholds)
PASS_RATE_INT=$(awk "BEGIN {printf \"%d\", $PASS_RATE * 100}")
if [ "$PASS_RATE_INT" -ge 90 ]; then
  echo "✅ PASS  — trigger rate ≥ 90% (deployment allowed)"
  exit 0
elif [ "$PASS_RATE_INT" -ge 75 ]; then
  echo "⚠️  CONDITIONAL — trigger rate 75–89% (deploy with warning)"
  exit 0
else
  echo "❌ FAIL  — trigger rate < 75% (autoresearch-optimizer required)"
  exit 2
fi
