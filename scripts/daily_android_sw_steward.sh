#!/bin/bash
# daily_android_sw_steward.sh — Cron-triggered daily Android-Software stewardship session
#
# Runs the android-sw-steward agent to advance Phase 4 deliverables,
# perform gap analysis, and research AOSP updates.
#
# Usage: Called by cron, or manually: ./scripts/daily_android_sw_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/android-sw-${DATE}.log"
PERF_FILE="$PERF_DIR/android-sw-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
TARGET_REPO="/home/jonas/gemini-home/Android-Software"

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
echo "=== Android-SW Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Capture pre-run state
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_TEST_COUNT=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null || echo "0")

echo "" >> "$LOG_FILE"
echo "--- Phase 4 Work ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read $REPO_ROOT/.claude/agents/android-sw-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents (CLAUDE.md, ANDROID_SW_OWNER_DEV_PLAN.md, ROADMAP.md, README.md)
2. Assess: Check ROADMAP.md for current Phase 4 status, identify next incomplete deliverable
3. Execute: Work on the next Phase 4 deliverable (4.1-4.5 in order)
4. If Phase 4 is complete, perform gap analysis and propose Phase 5+ improvements
5. Validate: Run existing tests to ensure no regressions
6. Record: Update ROADMAP.md with any completed tasks
7. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false}" >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$TARGET_REPO" "phase4-work" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research & Gap Analysis ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read $REPO_ROOT/.claude/agents/android-sw-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest Android 15/16 AOSP changes relevant to the skill set
3. Check for new GKI requirements, AIDL updates, pKVM evolution
4. If you find relevant changes, update affected skills or create hindsight notes
5. Update dirty_pages.json if any skills need refresh
6. Commit: If you made any changes, stage and commit with message 'research: AOSP updates ($DATE)'

Output a brief summary of findings." >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Capture post-run state (wrapped to ensure perf JSON is always written)
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || POST_COMMIT="unknown"
POST_TEST_COUNT=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null) || POST_TEST_COUNT="0"
FILES_CHANGED=$(cd "$TARGET_REPO" && git diff --name-only "$PRE_COMMIT" HEAD 2>/dev/null | wc -l) || FILES_CHANGED="0"
COMMITS_MADE=$(cd "$TARGET_REPO" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l) || COMMITS_MADE="0"

# Write performance record
cat > "$PERF_FILE" << EOF
{
  "agent": "android-sw-steward",
  "date": "$DATE",
  "duration_seconds": $DURATION,
  "pre_commit": "$PRE_COMMIT",
  "post_commit": "$POST_COMMIT",
  "commits_made": $COMMITS_MADE,
  "files_changed": $FILES_CHANGED,
  "test_count_before": $PRE_TEST_COUNT,
  "test_count_after": $POST_TEST_COUNT,
  "exit_code": 0
}
EOF

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Duration: ${DURATION}s | Commits: $COMMITS_MADE | Files changed: $FILES_CHANGED" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "android-sw-*.log" -mtime +30 -delete 2>/dev/null || true
find "$PERF_DIR" -name "android-sw-*.json" -mtime +30 -delete 2>/dev/null || true

exit 0
