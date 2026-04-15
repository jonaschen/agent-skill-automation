#!/bin/bash
# scripts/closed_loop_gemini.sh — Gemini-powered Closed-loop pipeline orchestrator
#
# State machine: START -> GENERATE -> VALIDATE -> {SECURITY_SCAN, OPTIMIZE, DEPLOY, SKIP_OPTIMIZE, REPORT_FAILURE}
#
# Same logic as closed_loop.sh but uses the Gemini CLI as the backend engine.
#
# Usage: ./scripts/closed_loop_gemini.sh <requirements-file> [--max-optimize-retries N] [--inter-test-delay N] [--pilot-mode]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_SCRIPT="$SCRIPT_DIR/deploy.sh"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"
MCP_VALIDATOR="$REPO_ROOT/eval/mcp_config_validator.sh"
PERMISSIONS_CHECK="$REPO_ROOT/eval/check-permissions.sh"
STRESS_LOG="$REPO_ROOT/eval/stress_test_log_gemini.json"

# Defaults
MAX_OPTIMIZE_RETRIES=3
INTER_TEST_DELAY=30
SCORE_SKIP_OPTIMIZE=0.95
SCORE_DEPLOY=0.90
SCORE_OPTIMIZE=0.75
PILOT_MODE=0

# Parse args
REQUIREMENTS_FILE="${1:-}"
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-optimize-retries) MAX_OPTIMIZE_RETRIES="$2"; shift 2 ;;
    --inter-test-delay) INTER_TEST_DELAY="$2"; shift 2 ;;
    --pilot-mode) PILOT_MODE=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$REQUIREMENTS_FILE" ] || [ ! -f "$REQUIREMENTS_FILE" ]; then
  echo "Usage: $0 <requirements-file> [--max-optimize-retries N] [--inter-test-delay N]" >&2
  exit 1
fi

# Initialize stress test log
if [ ! -f "$STRESS_LOG" ]; then
  echo "[]" > "$STRESS_LOG"
fi

# --- Helper functions ---

log_lifecycle() {
  local skill="$1" stage="$2" note="${3:-}"
  if [ -f "$LIFECYCLE_TRACKER" ]; then
    python3 "$LIFECYCLE_TRACKER" --skill "$skill" --stage "$stage" --note "$note" 2>/dev/null || true
  fi
}

get_trigger_score() {
  local eval_target="$1"
  local eval_output
  eval_output=$(python3 "$REPO_ROOT/eval/run_eval_async.py" "$eval_target" --no-cache 2>&1) || true
  local score
  score=$(echo "$eval_output" | grep -oP 'posterior_mean["\s:]+\K[0-9.]+' | head -1 || true)
  if [ -z "$score" ]; then
    score=$(echo "$eval_output" | grep -oP 'pass_rate["\s:]+\K[0-9.]+' | head -1 || true)
  fi
  echo "${score:-0.0}"
}

run_security_scan() {
  local skill_name="$1" eval_target="$2"
  local security_suite="$REPO_ROOT/eval/security_suite.sh"
  if [ -f "$security_suite" ]; then
    local mcp_config="$REPO_ROOT/.claude/skills/$skill_name/.mcp.json"
    local mcp_arg=""
    [ -f "$mcp_config" ] && mcp_arg="$mcp_config"
    bash "$security_suite" "$eval_target" "$mcp_arg" >/dev/null
  else
    return 0
  fi
}

validate_skill_structure() {
  local skill_name="$1"
  local skill_md="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
  local agent_md="$REPO_ROOT/.claude/agents/$skill_name.md"
  local target=""
  [ -s "$skill_md" ] && target="$skill_md"
  [ -z "$target" ] && [ -s "$agent_md" ] && target="$agent_md"
  [ -z "$target" ] && return 1
  [ -f "$PERMISSIONS_CHECK" ] && bash "$PERMISSIONS_CHECK" "$target" >/dev/null 2>&1
}

log_result() {
  local line_num="$1" requirement="$2" skill_name="$3" status="$4" optimize_retries="$5" duration="$6" score="$7"
  python3 -c "
import json, sys
log_path = sys.argv[1]
with open(log_path) as f: log = json.load(f)
log.append({
    'line': int(sys.argv[2]), 'requirement': sys.argv[3], 'skill_name': sys.argv[4],
    'status': sys.argv[5], 'optimize_retries': int(sys.argv[6]),
    'duration_seconds': int(sys.argv[7]), 'trigger_score': float(sys.argv[8])
})
with open(log_path, 'w') as f: json.dump(log, f, indent=2)
" "$STRESS_LOG" "$line_num" "$requirement" "$skill_name" "$status" "$optimize_retries" "$duration" "$score" 2>/dev/null || true
}

# --- Main loop ---

total=$(grep -cve '^\s*$' "$REQUIREMENTS_FILE" | head -1 || echo 0)
passed=0; failed=0; skipped=0

echo "=========================================="
echo "Gemini Closed-Loop Pipeline"
echo "Requirements: $total"
echo "=========================================="

line_num=0
while IFS= read -r requirement || [ -n "$requirement" ]; do
  line_num=$((line_num + 1))
  [ -z "$requirement" ] && continue
  [[ "$requirement" == \#* ]] && continue

  echo "[$line_num/$total] $requirement"
  start_time=$(date +%s)
  state="GENERATE"; status="UNKNOWN"; skill_name=""; optimize_retries=0; score="0.0"

  while true; do
    case "$state" in
      GENERATE)
        echo "[GENERATE] Invoking meta-agent-factory via Gemini..."
        skills_before=$(ls -1 "$REPO_ROOT/.claude/skills/" 2>/dev/null | sort || true)
        factory_log_file="$REPO_ROOT/logs/stress_test/gemini_skill_${line_num}_factory_output.txt"
        mkdir -p "$(dirname "$factory_log_file")"
        
        # Using Gemini CLI with explicit agent routing. 
        # Note: gemini handles permissions natively, but we specify write intent.
        factory_output=$(gemini -p "Use the meta-agent-factory agent to complete this task: $requirement

Your deliverable: (1) the skill_name (used for the directory), (2) a fully-populated SKILL.md at .claude/skills/<skill_name>/SKILL.md with YAML frontmatter. Use your Write tool to create the file. Do NOT only mkdir." 2>&1) || true
        echo "$factory_output" > "$factory_log_file"

        skill_name=$(echo "$factory_output" | grep -oP '(?<=skills/)[a-z0-9-]+(?=/)' | head -1 || true)
        if [ -z "$skill_name" ]; then
          skills_after=$(ls -1 "$REPO_ROOT/.claude/skills/" 2>/dev/null | sort || true)
          skill_name=$(comm -13 <(echo "$skills_before") <(echo "$skills_after") | head -1 || true)
        fi

        if [ -n "$skill_name" ]; then
          git -C "$REPO_ROOT" add ".claude/skills/$skill_name/" ".claude/agents/$skill_name.md" 2>/dev/null || true
          state="VALIDATE"
        else
          state="REPORT_FAILURE"; status="FAILED_GENERATION"
        fi
        ;;

      VALIDATE)
        echo "[VALIDATE] Evaluating $skill_name..."
        eval_target="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
        [ ! -f "$eval_target" ] && eval_target="$REPO_ROOT/.claude/agents/$skill_name.md"

        if [ "$PILOT_MODE" -eq 1 ]; then
          validate_skill_structure "$skill_name" && score="0.95" || score="0.0"
          [ "$score" = "0.95" ] && state="SECURITY_SCAN" || { state="REPORT_FAILURE"; status="FAILED_STRUCTURAL_VALIDATION"; }
        else
          score=$(get_trigger_score "$eval_target")
          if python3 -c "exit(0 if float('$score') >= $SCORE_DEPLOY else 1)" 2>/dev/null; then
            state="SECURITY_SCAN"
          elif [ "$optimize_retries" -lt "$MAX_OPTIMIZE_RETRIES" ] && python3 -c "exit(0 if float('$score') >= $SCORE_OPTIMIZE else 1)" 2>/dev/null; then
            state="OPTIMIZE"
          else
            state="REPORT_FAILURE"; status="FAILED_LOW_SCORE"
          fi
        fi
        ;;

      OPTIMIZE)
        optimize_retries=$((optimize_retries + 1))
        echo "[OPTIMIZE] Gemini Retry $optimize_retries..."
        gemini -p "Use the autoresearch-optimizer to improve the trigger rate of $eval_target. Run one iteration only." >/dev/null 2>&1 || true
        sleep "$INTER_TEST_DELAY"
        state="VALIDATE"
        ;;

      SECURITY_SCAN)
        run_security_scan "$skill_name" "$eval_target" && state="DEPLOY" || { state="REPORT_FAILURE"; status="FAILED_SECURITY_SCAN"; }
        ;;

      DEPLOY)
        echo "[DEPLOY] Gemini Success: $skill_name"
        status="DEPLOYED"
        break
        ;;

      REPORT_FAILURE)
        echo "[REPORT_FAILURE] $status"
        break
        ;;
    esac
  done

  duration=$(( $(date +%s) - start_time ))
  log_result "$line_num" "$requirement" "$skill_name" "$status" "$optimize_retries" "$duration" "$score"
  [ "$status" = "DEPLOYED" ] && passed=$((passed + 1)) || failed=$((failed + 1))
done < "$REQUIREMENTS_FILE"

echo "=========================================="
echo "Summary: $passed passed, $failed failed"
echo "=========================================="
