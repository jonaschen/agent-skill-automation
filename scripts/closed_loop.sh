#!/bin/bash
# scripts/closed_loop.sh — Closed-loop pipeline orchestrator (state machine)
#
# State machine: START -> GENERATE -> VALIDATE -> {SECURITY_SCAN, OPTIMIZE, DEPLOY, SKIP_OPTIMIZE, REPORT_FAILURE}
#
# State transitions:
#   START       -> GENERATE
#   GENERATE    -> VALIDATE       (success) | REPORT_FAILURE (no skill extracted)
#   VALIDATE    -> SKIP_OPTIMIZE  (score >= 0.95 — deploy directly)
#                | DEPLOY         (score >= 0.90 — deploy after security scan)
#                | OPTIMIZE       (score >= 0.75 — optimize then re-validate)
#                | REPORT_FAILURE (score < 0.75 — unrecoverable)
#   OPTIMIZE    -> VALIDATE       (retry, max 3 attempts)
#                | REPORT_FAILURE (exhausted retries)
#   SKIP_OPTIMIZE -> SECURITY_SCAN
#   DEPLOY      -> SECURITY_SCAN
#   SECURITY_SCAN -> DEPLOYED     (pass) | REPORT_FAILURE (fail)
#
# Usage: ./scripts/closed_loop.sh <requirements-file> [--max-optimize-retries N] [--inter-test-delay N] [--pilot-mode]
# Example: ./scripts/closed_loop.sh eval/stress_test_requirements.txt
# Example: ./scripts/closed_loop.sh eval/stress_test/pilot_10.txt --pilot-mode

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_SCRIPT="$SCRIPT_DIR/deploy.sh"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"
MCP_VALIDATOR="$REPO_ROOT/eval/mcp_config_validator.sh"
PERMISSIONS_CHECK="$REPO_ROOT/eval/check-permissions.sh"
STRESS_LOG="$REPO_ROOT/eval/stress_test_log.json"

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
    if [ -n "$note" ]; then
      python3 "$LIFECYCLE_TRACKER" --skill "$skill" --stage "$stage" --note "$note" 2>/dev/null || true
    else
      python3 "$LIFECYCLE_TRACKER" --skill "$skill" --stage "$stage" 2>/dev/null || true
    fi
  fi
}

get_trigger_score() {
  local eval_target="$1"
  # Run eval and extract posterior mean
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

  # Use unified security suite if available; fall back to individual checks
  if [ -f "$security_suite" ]; then
    echo "  [SECURITY] Running unified security suite..."
    local mcp_config="$REPO_ROOT/.claude/skills/$skill_name/.mcp.json"
    local mcp_arg=""
    [ -f "$mcp_config" ] && mcp_arg="$mcp_config"
    if bash "$security_suite" "$eval_target" "$mcp_arg" >/dev/null; then
      return 0
    else
      echo "  [SECURITY] FAILED — security suite reported errors"
      return 1
    fi
  fi

  # Fallback: individual checks (pre-suite compatibility)
  local scan_passed=true

  if [ -f "$PERMISSIONS_CHECK" ]; then
    echo "  [SECURITY] Running permission check..."
    if ! bash "$PERMISSIONS_CHECK" "$eval_target" 2>/dev/null; then
      echo "  [SECURITY] FAILED — permission violation"
      scan_passed=false
    fi
  fi

  local mcp_config="$REPO_ROOT/.claude/skills/$skill_name/.mcp.json"
  if [ -f "$mcp_config" ] && [ -f "$MCP_VALIDATOR" ]; then
    echo "  [SECURITY] Running MCP config validation..."
    if ! bash "$MCP_VALIDATOR" "$mcp_config" 2>/dev/null; then
      echo "  [SECURITY] FAILED — MCP config violation"
      scan_passed=false
    fi
  fi

  $scan_passed
}

validate_skill_structure() {
  local skill_name="$1"
  local skill_md="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
  local agent_md="$REPO_ROOT/.claude/agents/$skill_name.md"
  local target=""

  [ -s "$skill_md" ] && target="$skill_md"
  [ -z "$target" ] && [ -s "$agent_md" ] && target="$agent_md"

  if [ -z "$target" ]; then
    echo "  [STRUCTURAL] FAIL — no SKILL.md or agent .md found"
    return 1
  fi

  # Check frontmatter exists
  if ! head -1 "$target" | grep -q "^---"; then
    echo "  [STRUCTURAL] FAIL — missing YAML frontmatter"
    return 1
  fi

  # Check description exists and is non-empty
  local desc
  desc=$(python3 -c "
import yaml, sys
with open('$target') as f:
    content = f.read()
parts = content.split('---')
if len(parts) >= 3:
    meta = yaml.safe_load(parts[1])
    d = meta.get('description', '')
    print(d if d else '')
" 2>/dev/null || true)

  if [ -z "$desc" ]; then
    echo "  [STRUCTURAL] FAIL — empty or missing description"
    return 1
  fi

  if [ "${#desc}" -gt 1024 ]; then
    echo "  [STRUCTURAL] FAIL — description exceeds 1024 chars (${#desc})"
    return 1
  fi

  # Run permission check
  if [ -f "$PERMISSIONS_CHECK" ]; then
    if ! bash "$PERMISSIONS_CHECK" "$target" 2>/dev/null; then
      echo "  [STRUCTURAL] FAIL — permission violation"
      return 1
    fi
  fi

  echo "  [STRUCTURAL] PASS — valid frontmatter, description (${#desc} chars), permissions OK"
  return 0
}

log_result() {
  local line_num="$1" requirement="$2" skill_name="$3" status="$4" optimize_retries="$5" duration="$6" score="$7"
  python3 -c "
import json, sys
log_path = sys.argv[1]
with open(log_path) as f:
    log = json.load(f)
log.append({
    'line': int(sys.argv[2]),
    'requirement': sys.argv[3],
    'skill_name': sys.argv[4],
    'status': sys.argv[5],
    'optimize_retries': int(sys.argv[6]),
    'duration_seconds': int(sys.argv[7]),
    'trigger_score': float(sys.argv[8])
})
with open(log_path, 'w') as f:
    json.dump(log, f, indent=2)
" "$STRESS_LOG" "$line_num" "$requirement" "$skill_name" "$status" "$optimize_retries" "$duration" "$score" 2>/dev/null || true
}

# --- Main loop ---

total=$(grep -cve '^\s*$' "$REQUIREMENTS_FILE" | head -1 || echo 0)
passed=0
failed=0
skipped=0

echo "=========================================="
echo "Closed-Loop Pipeline (State Machine)"
echo "Requirements:           $total"
echo "Max optimize retries:   $MAX_OPTIMIZE_RETRIES"
echo "Skip optimize threshold: >= $SCORE_SKIP_OPTIMIZE"
echo "Deploy threshold:       >= $SCORE_DEPLOY"
echo "Optimize threshold:     >= $SCORE_OPTIMIZE"
echo "Pilot mode:             $([ $PILOT_MODE -eq 1 ] && echo "YES (structural validation)" || echo "NO (full eval)")"
echo "=========================================="

line_num=0
while IFS= read -r requirement || [ -n "$requirement" ]; do
  line_num=$((line_num + 1))
  [ -z "$requirement" ] && continue
  [[ "$requirement" == \#* ]] && continue

  echo ""
  echo "------------------------------------------"
  echo "[$line_num/$total] $requirement"
  echo "------------------------------------------"

  start_time=$(date +%s)
  state="GENERATE"
  status="UNKNOWN"
  skill_name=""
  optimize_retries=0
  score="0.0"

  # --- State machine ---
  while true; do
    case "$state" in

      GENERATE)
        echo "[GENERATE] Invoking meta-agent-factory..."
        # CRITICAL: redirect stdin from /dev/null to prevent claude from
        # consuming the outer while-loop's stdin (the REQUIREMENTS_FILE).
        # Without this, claude slurps remaining lines and outer loop exits early.
        # Capture skills/ dir state BEFORE the call so we can detect orphan dirs.
        skills_before=$(ls -1 "$REPO_ROOT/.claude/skills/" 2>/dev/null | sort || true)
        # EXPLICIT ROUTING: with 15+ agents, generic "Create a X skill..." prompts
        # get intercepted by steward agents (factory-steward Phase 1.5, changeling-router,
        # etc.). They explore but don't Write SKILL.md, leaving empty mkdir'd dirs.
        # Explicit agent invocation bypasses routing competition — matches OPTIMIZE pattern.
        # Also capture full factory output to file for post-hoc diagnosis.
        factory_log_dir="$REPO_ROOT/logs/stress_test"
        mkdir -p "$factory_log_dir"
        factory_log_file="$factory_log_dir/skill_${line_num}_factory_output.txt"
        factory_output=$(claude --dangerously-skip-permissions -p "Use the meta-agent-factory agent to complete this task: $requirement

Your deliverable: (1) the skill_name (used for the directory), (2) a fully-populated SKILL.md at .claude/skills/<skill_name>/SKILL.md with YAML frontmatter (name, description, tools, model) plus full operational instructions. Use the Write tool to create the file. Do NOT only mkdir the directory — the SKILL.md file MUST be written and non-empty." < /dev/null 2>&1) || true
        # Persist for debugging even after closed_loop exits
        echo "=== Requirement: $requirement ===" > "$factory_log_file"
        echo "$factory_output" >> "$factory_log_file"

        # Extract skill name from factory output (primary: explicit path mention)
        skill_name=$(echo "$factory_output" | grep -oP '(?<=skills/)[a-z0-9-]+(?=/)' | head -1 || true)
        if [ -z "$skill_name" ]; then
          skill_name=$(echo "$factory_output" | grep -oP '(?<=agents/)[a-z0-9-]+(?=\.md)' | head -1 || true)
        fi

        # Fallback: diff skills/ dir for newly-created entries
        if [ -z "$skill_name" ]; then
          skills_after=$(ls -1 "$REPO_ROOT/.claude/skills/" 2>/dev/null | sort || true)
          new_skills=$(comm -13 <(echo "$skills_before") <(echo "$skills_after") 2>/dev/null || true)
          # If exactly one new skill dir, use that
          if [ -n "$new_skills" ] && [ "$(echo "$new_skills" | wc -l)" = "1" ]; then
            skill_name="$new_skills"
            echo "[GENERATE] skill_name recovered from dir diff: $skill_name"
          elif [ -n "$new_skills" ]; then
            # Multiple new dirs — likely batch-generation artifact; clean up orphans
            echo "[GENERATE] WARNING: factory created multiple new dirs: $(echo $new_skills | tr '\n' ' ')"
            for orphan in $new_skills; do
              orphan_path="$REPO_ROOT/.claude/skills/$orphan"
              if [ -z "$(ls -A "$orphan_path" 2>/dev/null)" ]; then
                rmdir "$orphan_path" 2>/dev/null && echo "[GENERATE] cleaned orphan empty dir: $orphan"
              fi
            done
          fi
        fi

        # If we have a name but SKILL.md is empty/missing, it's an orphan stub
        if [ -n "$skill_name" ]; then
          skill_md="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
          agent_md="$REPO_ROOT/.claude/agents/$skill_name.md"
          if [ ! -s "$skill_md" ] && [ ! -s "$agent_md" ]; then
            echo "[GENERATE] FAILED — skill_name extracted ($skill_name) but SKILL.md/agent .md is empty/missing"
            # Clean up empty dir if we created one
            [ -d "$REPO_ROOT/.claude/skills/$skill_name" ] && [ -z "$(ls -A "$REPO_ROOT/.claude/skills/$skill_name" 2>/dev/null)" ] && rmdir "$REPO_ROOT/.claude/skills/$skill_name"
            skill_name=""
            state="REPORT_FAILURE"
            status="FAILED_GENERATION_STUB"
          fi
        fi

        if [ -z "$skill_name" ]; then
          echo "[GENERATE] FAILED — could not extract skill name"
          state="REPORT_FAILURE"
          status="${status:-FAILED_GENERATION}"
        else
          echo "[GENERATE] Created: $skill_name"
          log_lifecycle "$skill_name" "created" "meta-agent-factory"
          # Stage generated files so eval cleanup doesn't delete them
          git -C "$REPO_ROOT" add ".claude/skills/$skill_name/" ".claude/agents/$skill_name.md" 2>/dev/null || true
          state="VALIDATE"
        fi
        ;;

      VALIDATE)
        echo "[VALIDATE] Evaluating $skill_name..."
        local_skill_path="$REPO_ROOT/.claude/skills/$skill_name/SKILL.md"
        local_agent_path="$REPO_ROOT/.claude/agents/$skill_name.md"

        eval_target=""
        if [ -f "$local_skill_path" ]; then
          eval_target="$local_skill_path"
        elif [ -f "$local_agent_path" ]; then
          eval_target="$local_agent_path"
        fi

        if [ -z "$eval_target" ]; then
          echo "[VALIDATE] No SKILL.md or agent .md found"
          state="REPORT_FAILURE"
          status="FAILED_VALIDATION"
          continue
        fi

        if [ "$PILOT_MODE" -eq 1 ]; then
          # Pilot mode: structural validation only (no full eval suite).
          # Full eval is a meta-agent-factory regression test — run once
          # after pilot completes, not per-skill.
          if validate_skill_structure "$skill_name"; then
            score="0.95"
            echo "[VALIDATE] Pilot mode: structural check passed, score=$score"
            log_lifecycle "$skill_name" "validated" "pilot-structural score=$score"
            state="SECURITY_SCAN"
          else
            score="0.0"
            echo "[VALIDATE] Pilot mode: structural check failed"
            log_lifecycle "$skill_name" "validated" "pilot-structural FAIL"
            state="REPORT_FAILURE"
            status="FAILED_STRUCTURAL_VALIDATION"
          fi
        else
          score=$(get_trigger_score "$eval_target")
          echo "[VALIDATE] Score: $score"
          log_lifecycle "$skill_name" "validated" "score=$score"

          # Score-based routing
          if python3 -c "exit(0 if float('$score') >= $SCORE_SKIP_OPTIMIZE else 1)" 2>/dev/null; then
            echo "[VALIDATE] Score >= $SCORE_SKIP_OPTIMIZE — skipping optimization"
            state="SECURITY_SCAN"
          elif python3 -c "exit(0 if float('$score') >= $SCORE_DEPLOY else 1)" 2>/dev/null; then
            echo "[VALIDATE] Score >= $SCORE_DEPLOY — proceeding to security scan"
            state="SECURITY_SCAN"
          elif python3 -c "exit(0 if float('$score') >= $SCORE_OPTIMIZE else 1)" 2>/dev/null; then
            if [ "$optimize_retries" -ge "$MAX_OPTIMIZE_RETRIES" ]; then
              echo "[VALIDATE] Score >= $SCORE_OPTIMIZE but exhausted $MAX_OPTIMIZE_RETRIES optimize retries"
              state="REPORT_FAILURE"
              status="FAILED_OPTIMIZATION_EXHAUSTED"
            else
              echo "[VALIDATE] Score >= $SCORE_OPTIMIZE — routing to optimization"
              state="OPTIMIZE"
            fi
          else
            echo "[VALIDATE] Score < $SCORE_OPTIMIZE — unrecoverable"
            state="REPORT_FAILURE"
            status="FAILED_LOW_SCORE"
          fi
        fi
        ;;

      OPTIMIZE)
        optimize_retries=$((optimize_retries + 1))
        echo "[OPTIMIZE] Retry $optimize_retries/$MAX_OPTIMIZE_RETRIES for $skill_name..."
        log_lifecycle "$skill_name" "optimizing" "retry=$optimize_retries"

        claude --dangerously-skip-permissions -p \
          "Use the autoresearch-optimizer to improve the trigger rate of $eval_target. Run one iteration only." \
          < /dev/null 2>/dev/null || true

        sleep "$INTER_TEST_DELAY"
        state="VALIDATE"
        ;;

      SECURITY_SCAN)
        echo "[SECURITY_SCAN] Running security checks on $skill_name..."
        if run_security_scan "$skill_name" "$eval_target"; then
          echo "[SECURITY_SCAN] PASSED"
          state="DEPLOY"
        else
          echo "[SECURITY_SCAN] FAILED"
          state="REPORT_FAILURE"
          status="FAILED_SECURITY_SCAN"
        fi
        ;;

      DEPLOY)
        echo "[DEPLOY] Deploying $skill_name..."
        if [ "$PILOT_MODE" -eq 1 ]; then
          # Pilot mode: skip pre-deploy eval (already did structural + security).
          # Record deployment directly.
          DEPLOY_LOG="$REPO_ROOT/eval/deploy_log.json"
          [ ! -f "$DEPLOY_LOG" ] && echo "[]" > "$DEPLOY_LOG"
          TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
          GIT_SHA=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
          python3 -c "
import json
with open('$DEPLOY_LOG') as f: log = json.load(f)
log.append({'skill': '$skill_name', 'timestamp': '$TIMESTAMP', 'git_sha': '$GIT_SHA', 'status': 'deployed-pilot'})
with open('$DEPLOY_LOG', 'w') as f: json.dump(log, f, indent=2)
" 2>/dev/null || true
          echo "[DEPLOY] SUCCESS (pilot mode — structural validation)"
          status="DEPLOYED"
          log_lifecycle "$skill_name" "deployed" "pilot score=$score retries=$optimize_retries"
        else
          if bash "$DEPLOY_SCRIPT" "$skill_name" 2>/dev/null; then
            echo "[DEPLOY] SUCCESS"
            status="DEPLOYED"
            log_lifecycle "$skill_name" "deployed" "score=$score retries=$optimize_retries"
          else
            echo "[DEPLOY] FAILED — deploy script returned error"
            status="FAILED_DEPLOY"
          fi
        fi
        break
        ;;

      REPORT_FAILURE)
        echo "[REPORT_FAILURE] $skill_name failed: $status"
        if [ -n "$skill_name" ]; then
          log_lifecycle "$skill_name" "failed" "$status"
        fi
        break
        ;;

      *)
        echo "[ERROR] Unknown state: $state"
        status="INTERNAL_ERROR"
        break
        ;;
    esac
  done

  end_time=$(date +%s)
  duration=$((end_time - start_time))

  log_result "$line_num" "$requirement" "$skill_name" "$status" "$optimize_retries" "$duration" "$score"

  case "$status" in
    DEPLOYED) passed=$((passed + 1)) ;;
    FAILED_*|INTERNAL_ERROR) failed=$((failed + 1)) ;;
    *) skipped=$((skipped + 1)) ;;
  esac

  echo "  State: $status | Score: $score | Retries: $optimize_retries | Duration: ${duration}s"

done < "$REQUIREMENTS_FILE"

echo ""
echo "=========================================="
echo "CLOSED-LOOP SUMMARY (State Machine)"
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
