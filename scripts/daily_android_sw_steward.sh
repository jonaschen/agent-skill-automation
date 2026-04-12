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

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export CLAUDE_INITIATOR_TYPE=cron-automated

# Per-agent effort level (discussion 2026-04-09: prepared commented-out, enable if costs spike >50%)
# Routine/mechanical agent → medium effort; uncomment to override default
# export CLAUDE_CODE_EFFORT=medium

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
init_session_log "android-sw" "$REPO_ROOT"

# Capture pre-run state (before trap setup so they're available in finalize)
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_TEST_COUNT=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null || echo "0")

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local post_test_count
  post_test_count=$(cd "$TARGET_REPO" && grep -c "TC-" tests/routing_accuracy/test_router.py 2>/dev/null) || post_test_count="0"
  local files_changed
  files_changed=$(cd "$TARGET_REPO" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$TARGET_REPO" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "android-sw-steward",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "test_count_before": ${PRE_TEST_COUNT:-0},
  "test_count_after": $post_test_count,
  "effort_level": "${CLAUDE_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  check_cost_ceiling "android-sw" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "android-sw-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "android-sw-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== Android-SW Steward Session — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "steward"

# Pre-flight: check target repo for deprecated model references (warning-only, .claude/ scoped)
echo "" >> "$LOG_FILE"
echo "--- Deprecation Pre-flight Check ---" >> "$LOG_FILE"
if [ -d "$TARGET_REPO/.claude" ]; then
  bash "$REPO_ROOT/scripts/lib/check_target_deprecations.sh" "$TARGET_REPO" >> "$LOG_FILE" 2>&1 || true
else
  echo "SKIP: No .claude/ directory in target repo" >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"
echo "--- Phase 4 Work ---" >> "$LOG_FILE"
log_task_start "phase4-work"
# Run Claude in a subshell to isolate process-group signals from the parent script
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read $REPO_ROOT/.claude/agents/android-sw-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all mandatory documents (CLAUDE.md, ANDROID_SW_OWNER_DEV_PLAN.md, ROADMAP.md, README.md, .claude/steering-notes.md if it exists)
2. **BLOCKING — Read steering notes**: Read $TARGET_REPO/.claude/steering-notes.md (if it exists). Address ALL P0 items BEFORE any other work. Also check $REPO_ROOT/knowledge_base/steward-reviews/ for the latest review file.
3. Assess: Check ROADMAP.md for current Phase 4 status, identify next incomplete deliverable
4. Execute: Work on the next Phase 4 deliverable (4.1-4.5 in order)
5. If Phase 4 is complete, perform gap analysis and propose Phase 5+ improvements
6. Validate: Run existing tests to ensure no regressions
7. Record: Update ROADMAP.md with any completed tasks
8. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false}") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Phase 4 session complete" >> "$LOG_FILE"
log_task_complete "phase4-work"

(recover_uncommitted "$TARGET_REPO" "phase4-work" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research & Gap Analysis ---" >> "$LOG_FILE"
log_task_start "research"
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the android-sw-steward agent. Read $REPO_ROOT/.claude/agents/android-sw-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest Android 15/16 AOSP changes relevant to the skill set
3. Check for new GKI requirements, AIDL updates, pKVM evolution
4. If you find relevant changes, update affected skills or create hindsight notes
5. Update dirty_pages.json if any skills need refresh
6. Commit: If you made any changes, stage and commit with message 'research: AOSP updates ($DATE)'

Output a brief summary of findings.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Research session complete" >> "$LOG_FILE"
log_task_complete "research"

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
