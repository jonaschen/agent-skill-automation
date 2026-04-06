#!/bin/bash
# daily_project_reviewer.sh — Cron-triggered nightly review of steward agent work
#
# Runs the project-reviewer agent to assess the quality and direction of
# tonight's android-sw-steward, arm-mrs-steward, and bsp-knowledge-steward runs.
# Writes feedback reviews and steering notes for the next session.
#
# Runs at 6am — after all three stewards finish (3am, 4am, 5am).
#
# Usage: Called by cron, or manually: ./scripts/daily_project_reviewer.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/reviewer-${DATE}.log"
PERF_FILE="$PERF_DIR/reviewer-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

mkdir -p "$LOG_DIR" "$PERF_DIR" "$REPO_ROOT/knowledge_base/steward-reviews"

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
    git commit -m "reviewer(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)

# Capture pre-run state (before trap setup so they're available in finalize)
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  local review_file="$REPO_ROOT/knowledge_base/steward-reviews/${DATE}.md"
  local on_track
  on_track=$(grep -ci "on-track" "$review_file" 2>/dev/null) || on_track="0"
  local needs_correction
  needs_correction=$(grep -ci "needs-correction" "$review_file" 2>/dev/null) || needs_correction="0"
  local escalations
  escalations=$(grep -c "ESCALATE" "$review_file" 2>/dev/null) || escalations="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "project-reviewer",
  "date": "$DATE",
  "duration_seconds": $duration,
  "commits_made": $commits_made,
  "stewards_on_track": $on_track,
  "stewards_needs_correction": $needs_correction,
  "escalations": $escalations,
  "exit_code": $exit_code
}
PERF_EOF

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | On-track: $on_track | Needs correction: $needs_correction | Escalations: $escalations" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "reviewer-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "reviewer-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT

echo "=== Project Reviewer Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "--- Review All Three Stewards ---" >> "$LOG_FILE"
cd "$REPO_ROOT" && "$CLAUDE" --dangerously-skip-permissions -p "You are the project-reviewer agent. Read .claude/agents/project-reviewer.md for your full instructions.

Execute a review session for today's steward runs ($DATE):

For each of the three stewards (android-sw, arm-mrs, bsp-knowledge):
1. Read their log: logs/{android-sw,arm-mrs,bsp-knowledge}-${DATE}.log
2. Read their perf JSON: logs/performance/{android-sw,arm-mrs,bsp-knowledge}-${DATE}.json
3. Go to the target repo, run 'git log --oneline -5' and 'git diff HEAD~1' to see actual changes
4. Read the target repo's ROADMAP.md and CLAUDE.md for alignment check
5. Assess: correctness, alignment with ROADMAP, meaningful progress, risks, next priorities

Then:
6. Write a structured review to knowledge_base/steward-reviews/${DATE}.md with per-steward verdicts (on-track / needs-correction / blocked), findings, and advice
7. Check if any steward modified skill files (skill.md/SKILL.md) — if so, invoke the skill-quality-validator via Task tool and include the quality verdict in your review
8. For any steward that needs correction (including failed skill validation), append a dated steering note to the target repo's .claude/steering-notes.md
9. Look for cross-project insights (findings in one repo relevant to another)
10. If any steward is stalled, regressing, or off-track, flag it clearly with [ESCALATE] in the review

If a steward didn't run today (no log file), note it as 'no run' and skip.

Commit the review file: git add knowledge_base/steward-reviews/${DATE}.md && git commit -m 'review: steward work assessment ${DATE}'" >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$REPO_ROOT" "review" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
