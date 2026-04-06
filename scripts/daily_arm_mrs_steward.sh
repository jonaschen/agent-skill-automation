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

mkdir -p "$LOG_DIR" "$PERF_DIR"

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
echo "=== ARM MRS Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Capture pre-run state
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_EVAL_COUNT=$(cd "$TARGET_REPO" && grep -c "def test_" tools/eval_skill.py 2>/dev/null || echo "292")

echo "" >> "$LOG_FILE"
echo "--- H8 / Next Milestone Work ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the arm-mrs-steward agent. Read $REPO_ROOT/.claude/agents/arm-mrs-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents (CLAUDE.md, AARCH64_AGENT_SKILL_DEV_PLAN.md, ROADMAP.md, README.md)
2. Assess: Check ROADMAP.md for current status, identify next incomplete milestone
3. Execute: Work on the next milestone — design, implement, or expand
4. If current milestones are complete, work on data expansion (T32/A32, GIC, CoreSight, PMU)
5. Validate: Run python3 tools/eval_skill.py to ensure all tests pass
6. Record: Update ROADMAP.md with any completed tasks
7. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"milestone\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"eval_tests_passed\": true/false, \"eval_test_count\": N}" >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$TARGET_REPO" "milestone-work" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research & Data Expansion ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the arm-mrs-steward agent. Read $REPO_ROOT/.claude/agents/arm-mrs-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest ARM architecture news — new MRS builds, v9Ap7+, new FEAT_* extensions
3. Check for new CPU profiles for PMU expansion (Cortex-X5, A730, Neoverse V3, etc.)
4. If you find relevant data, add it to the appropriate data directories (pmu/, gic/, coresight/, arm-arm/)
5. Add eval tests for any new data
6. Rebuild affected caches if data was added
7. Commit: If you made any changes, stage and commit with message 'research: ARM architecture updates ($DATE)'

Output a brief summary of findings." >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Capture post-run state
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
POST_EVAL_COUNT=$(cd "$TARGET_REPO" && grep -c "def test_" tools/eval_skill.py 2>/dev/null || echo "292")
FILES_CHANGED=$(cd "$TARGET_REPO" && git diff --name-only "$PRE_COMMIT" HEAD 2>/dev/null | wc -l || echo "0")
COMMITS_MADE=$(cd "$TARGET_REPO" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l || echo "0")

# Write performance record
cat > "$PERF_FILE" << EOF
{
  "agent": "arm-mrs-steward",
  "date": "$DATE",
  "duration_seconds": $DURATION,
  "pre_commit": "$PRE_COMMIT",
  "post_commit": "$POST_COMMIT",
  "commits_made": $COMMITS_MADE,
  "files_changed": $FILES_CHANGED,
  "eval_count_before": $PRE_EVAL_COUNT,
  "eval_count_after": $POST_EVAL_COUNT,
  "exit_code": 0
}
EOF

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Duration: ${DURATION}s | Commits: $COMMITS_MADE | Files changed: $FILES_CHANGED | Eval: $POST_EVAL_COUNT tests" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "arm-mrs-*.log" -mtime +30 -delete 2>/dev/null || true
find "$PERF_DIR" -name "arm-mrs-*.json" -mtime +30 -delete 2>/dev/null || true

exit 0
