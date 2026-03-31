#!/bin/bash
# scripts/closed_loop.sh — Closed-loop pipeline orchestrator
#
# Runs the full factory→validate→optimize→deploy pipeline for each requirement.
# Input: A requirements file (one natural-language requirement per line)
#
# Usage: ./scripts/closed_loop.sh <requirements-file> [--max-optimize-iters N]
# Example: ./scripts/closed_loop.sh eval/stress_test_requirements.txt

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_SCRIPT="$SCRIPT_DIR/deploy.sh"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"
STRESS_LOG="$REPO_ROOT/eval/stress_test_log.json"
MAX_OPTIMIZE_ITERS=10
INTER_TEST_DELAY=30

# Parse args
REQUIREMENTS_FILE="${1:-}"
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-optimize-iters) MAX_OPTIMIZE_ITERS="$2"; shift 2 ;;
    --inter-test-delay) INTER_TEST_DELAY="$2"; shift 2 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$REQUIREMENTS_FILE" ] || [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "Usage: $0 <requirements-file> [--max-optimize-iters N]" >&2
  exit 1
fi

# Initialize stress test log
if [ ! -f "$STRESS_LOG" ]; then
  echo "[]" > "$STRESS_LOG"
fi

total=$(wc -l < "$REQUIREMENTS_FILE")
passed=0
failed=0
skipped=0

echo "=========================================="
echo "Closed-Loop Pipeline: $total requirements"
echo "Max optimize iterations: $MAX_OPTIMIZE_ITERS"
echo "=========================================="

line_num=0
while IFS= read -r requirement || [ -n "$requirement" ]; do
  line_num=$((line_num + 1))
  [ -z "$requirement" ] && continue
  [[ "$requirement" == \#* ]] && continue  # skip comments

  echo ""
  echo "------------------------------------------"
  echo "[$line_num/$total] $requirement"
  echo "------------------------------------------"

  start_time=$(date +%s)
  status="UNKNOWN"
  skill_name=""
  optimize_iters=0

  # Stage 1: Generate with meta-agent-factory
  echo "[GENERATE] Invoking meta-agent-factory..."
  factory_output=$(claude --dangerously-skip-permissions -p "$requirement" 2>&1) || true

  # Extract skill name from generated output
  skill_name=$(echo "$factory_output" | grep -oP '(?<=skills/)[a-z0-9-]+(?=/)' | head -1 || true)
  if [ -z "$skill_name" ]; then
    skill_name=$(echo "$factory_output" | grep -oP '(?<=agents/)[a-z0-9-]+(?=\.md)' | head -1 || true)
  fi

  if [ -z "$skill_name" ]; then
    echo "[GENERATE] FAILED — could not extract skill name from output"
    status="FAILED_GENERATION"
  else
    echo "[GENERATE] Created: $skill_name"

    # Log lifecycle event
    if [ -f "$LIFECYCLE_TRACKER" ]; then
      python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage created --source meta-agent-factory 2>/dev/null || true
    fi

    # Stage 2: Validate
    echo "[VALIDATE] Running quality check..."
    skill_path="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
    agent_path="$REPO_ROOT/.claude/agents/$skill_name.md"

    eval_target=""
    if [ -f "$skill_path" ]; then
      eval_target="$skill_path"
    elif [ -f "$agent_path" ]; then
      eval_target="$agent_path"
    fi

    if [ -z "$eval_target" ]; then
      echo "[VALIDATE] SKIP — no SKILL.md or agent .md found for $skill_name"
      status="FAILED_VALIDATION"
    else
      # Permission check
      if [ -f "$REPO_ROOT/eval/check-permissions.sh" ]; then
        if ! bash "$REPO_ROOT/eval/check-permissions.sh" "$eval_target" 2>/dev/null; then
          echo "[VALIDATE] FAILED — permission check"
          status="FAILED_PERMISSIONS"
        fi
      fi

      if [ "$status" = "UNKNOWN" ]; then
        # Log validation event
        if [ -f "$LIFECYCLE_TRACKER" ]; then
          python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage validated 2>/dev/null || true
        fi

        # Stage 3: Deploy (runs pre-deploy gate internally)
        echo "[DEPLOY] Attempting deployment..."
        if bash "$DEPLOY_SCRIPT" "$skill_name" 2>/dev/null; then
          echo "[DEPLOY] SUCCESS"
          status="DEPLOYED"
          if [ -f "$LIFECYCLE_TRACKER" ]; then
            python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage deployed 2>/dev/null || true
          fi
        else
          # Stage 4: Optimize if deploy gate fails
          echo "[OPTIMIZE] Deploy gate failed, starting optimization (max $MAX_OPTIMIZE_ITERS iters)..."
          if [ -f "$LIFECYCLE_TRACKER" ]; then
            python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage optimizing 2>/dev/null || true
          fi

          optimize_iters=0
          optimized=false
          while [ "$optimize_iters" -lt "$MAX_OPTIMIZE_ITERS" ]; do
            optimize_iters=$((optimize_iters + 1))
            echo "  [OPTIMIZE] Iteration $optimize_iters/$MAX_OPTIMIZE_ITERS"

            # Run optimizer via claude
            claude --dangerously-skip-permissions -p \
              "Use the autoresearch-optimizer to improve the trigger rate of $eval_target. Run one iteration only." \
              2>/dev/null || true

            # Re-attempt deploy
            if bash "$DEPLOY_SCRIPT" "$skill_name" 2>/dev/null; then
              echo "[OPTIMIZE] SUCCESS after $optimize_iters iterations"
              status="DEPLOYED_AFTER_OPTIMIZATION"
              optimized=true
              if [ -f "$LIFECYCLE_TRACKER" ]; then
                python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage deployed --note "optimized in $optimize_iters iters" 2>/dev/null || true
              fi
              break
            fi

            sleep "$INTER_TEST_DELAY"
          done

          if [ "$optimized" = false ]; then
            echo "[OPTIMIZE] FAILED after $optimize_iters iterations"
            status="FAILED_OPTIMIZATION"
          fi
        fi
      fi
    fi
  fi

  end_time=$(date +%s)
  duration=$((end_time - start_time))

  # Log to stress test log
  python3 -c "
import json
log_path = '$STRESS_LOG'
with open(log_path) as f:
    log = json.load(f)
log.append({
    'line': $line_num,
    'requirement': '''$requirement''',
    'skill_name': '$skill_name',
    'status': '$status',
    'optimize_iterations': $optimize_iters,
    'duration_seconds': $duration
})
with open(log_path, 'w') as f:
    json.dump(log, f, indent=2)
" 2>/dev/null || true

  case "$status" in
    DEPLOYED|DEPLOYED_AFTER_OPTIMIZATION) passed=$((passed + 1)) ;;
    FAILED_*) failed=$((failed + 1)) ;;
    *) skipped=$((skipped + 1)) ;;
  esac

  echo "  Status: $status | Duration: ${duration}s"

done < "$REQUIREMENTS_FILE"

echo ""
echo "=========================================="
echo "CLOSED-LOOP SUMMARY"
echo "=========================================="
echo "Total:    $total"
echo "Passed:   $passed"
echo "Failed:   $failed"
echo "Skipped:  $skipped"
echo "Success:  $(( total > 0 ? passed * 100 / total : 0 ))%"
echo "=========================================="

# Exit with failure if autonomous completion rate < 70%
threshold=$(( total * 70 / 100 ))
if [ "$passed" -lt "$threshold" ]; then
  echo "Below 70% autonomous completion target."
  exit 1
fi
