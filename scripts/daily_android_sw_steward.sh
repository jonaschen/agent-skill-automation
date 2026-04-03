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

START_TIME=$(date +%s)
echo "=== Android-SW Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Capture pre-run state
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_TEST_COUNT=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null || echo "0")

echo "" >> "$LOG_FILE"
echo "--- Phase 4 Work ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read .claude/agents/android-sw-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents from /home/jonas/gemini-home/Android-Software/
2. Assess: Check ROADMAP.md for current Phase 4 status, identify next incomplete deliverable
3. Execute: Work on the next Phase 4 deliverable (4.1-4.5 in order)
4. If Phase 4 is complete, perform gap analysis and propose Phase 5+ improvements
5. Validate: Run existing tests to ensure no regressions
6. Record: Update ROADMAP.md with any completed tasks

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false}" >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Research & Gap Analysis ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read .claude/agents/android-sw-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md from /home/jonas/gemini-home/Android-Software/
2. Research: WebSearch for latest Android 15/16 AOSP changes relevant to the skill set
3. Check for new GKI requirements, AIDL updates, pKVM evolution
4. If you find relevant changes, update affected skills or create hindsight notes
5. Update dirty_pages.json if any skills need refresh

Output a brief summary of findings." >> "$LOG_FILE" 2>&1 || true

# Capture post-run state
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
POST_TEST_COUNT=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null || echo "0")
FILES_CHANGED=$(cd "$TARGET_REPO" && git diff --name-only "$PRE_COMMIT" HEAD 2>/dev/null | wc -l || echo "0")
COMMITS_MADE=$(cd "$TARGET_REPO" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l || echo "0")

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
