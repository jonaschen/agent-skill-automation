#!/bin/bash
# daily_arm_mrs_steward.sh — Cron-triggered daily ARM MRS stewardship session
#
# Runs the arm-mrs-steward agent to advance H8 orchestration,
# expand data coverage, and research ARM architecture updates.
#
# Usage: Called by cron, or manually: ./scripts/daily_arm_mrs_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/arm-mrs-${DATE}.log"
PERF_FILE="$PERF_DIR/arm-mrs-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
TARGET_REPO="/home/jonas/arm-mrs-2025-03-aarchmrs"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared cost ceiling library
source "$SCRIPT_DIR/lib/cost_ceiling.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export CLAUDE_INITIATOR_TYPE=cron-automated

# Post-session commit recovery: if Claude wrote files but failed to commit, catch them
recover_uncommitted() {
  local repo_dir="$1"
  local session_name="$2"
  local log_file="$3"
  cd "$repo_dir" || return 0
  local dirty
  dirty=$(git status --porcelain 2>/dev/null | grep -v '^??' | head -1 || true)
  if [ -n "$dirty" ]; then
    echo "[RECOVERY] $session_name left uncommitted changes — auto-committing" >> "$log_file"
    git status --short >> "$log_file" 2>&1
    git add -A >> "$log_file" 2>&1
    git commit -m "steward(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)

# Capture pre-run state (before trap setup so they're available in finalize)
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
# Count tests by summing all *_TESTS list lengths (tests are list items, not def test_ functions)
PRE_EVAL_COUNT=$(cd "$TARGET_REPO" && python3 -c "
import ast, sys
with open('tools/eval_skill.py') as f:
    tree = ast.parse(f.read())
total = 0
for node in ast.walk(tree):
    if isinstance(node, ast.Assign):
        for t in node.targets:
            if isinstance(t, ast.Name) and t.id.endswith('_TESTS') and isinstance(node.value, ast.List):
                total += len(node.value.elts)
print(total)
" 2>/dev/null) || PRE_EVAL_COUNT="0"
PRE_EVAL_COUNT=$(echo "$PRE_EVAL_COUNT" | tr -d '[:space:]')
PRE_EVAL_COUNT="${PRE_EVAL_COUNT:-0}"

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local post_eval_count
  post_eval_count=$(cd "$TARGET_REPO" && python3 -c "
import ast, sys
with open('tools/eval_skill.py') as f:
    tree = ast.parse(f.read())
total = 0
for node in ast.walk(tree):
    if isinstance(node, ast.Assign):
        for t in node.targets:
            if isinstance(t, ast.Name) and t.id.endswith('_TESTS') and isinstance(node.value, ast.List):
                total += len(node.value.elts)
print(total)
" 2>/dev/null) || post_eval_count="0"
  post_eval_count=$(echo "$post_eval_count" | tr -d '[:space:]')
  post_eval_count="${post_eval_count:-0}"
  local files_changed
  files_changed=$(cd "$TARGET_REPO" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$TARGET_REPO" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "arm-mrs-steward",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "eval_count_before": ${PRE_EVAL_COUNT:-292},
  "eval_count_after": $post_eval_count,
  "exit_code": $exit_code
}
PERF_EOF

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  check_cost_ceiling "arm-mrs" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | Eval: $post_eval_count tests" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "arm-mrs-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "arm-mrs-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== ARM MRS Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "--- H8 / Next Milestone Work ---" >> "$LOG_FILE"
# Run Claude in a subshell to isolate process-group signals from the parent script
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the arm-mrs-steward agent. Read $REPO_ROOT/.claude/agents/arm-mrs-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents (CLAUDE.md, AARCH64_AGENT_SKILL_DEV_PLAN.md, ROADMAP.md, README.md)
2. **Check reviewer feedback**: Read $REPO_ROOT/knowledge_base/steward-reviews/ for the latest review file. If there are P0 or P1 items for arm-mrs-steward, address them FIRST before any new work. Skill file updates (.claude/skills/*.md) are high priority — these are user-facing.
3. Assess: Check ROADMAP.md for current status, identify next incomplete milestone
4. Execute: Work on the next milestone — design, implement, or expand
5. If current milestones are complete, work on data expansion (T32/A32, GIC, CoreSight, PMU)
6. Validate: Run python3 tools/eval_skill.py to ensure all tests pass
7. Record: Update ROADMAP.md with any completed tasks
8. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"milestone\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"eval_tests_passed\": true/false, \"eval_test_count\": N}") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Milestone session complete" >> "$LOG_FILE"

(recover_uncommitted "$TARGET_REPO" "milestone-work" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research & Data Expansion ---" >> "$LOG_FILE"
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the arm-mrs-steward agent. Read $REPO_ROOT/.claude/agents/arm-mrs-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest ARM architecture news — new MRS builds, v9Ap7+, new FEAT_* extensions
3. Check for new CPU profiles for PMU expansion (Cortex-X5, A730, Neoverse V3, etc.)
4. If you find relevant data, add it to the appropriate data directories (pmu/, gic/, coresight/, arm-arm/)
5. Add eval tests for any new data
6. Rebuild affected caches if data was added
7. Commit: If you made any changes, stage and commit with message 'research: ARM architecture updates ($DATE)'

Output a brief summary of findings.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Research session complete" >> "$LOG_FILE"

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
