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
  dirty=$(git status --porcelain 2>/dev/null | grep -v '^??' | head -1)
  if [ -n "$dirty" ]; then
    echo "[RECOVERY] $session_name left uncommitted changes — auto-committing" >> "$log_file"
    git status --short >> "$log_file" 2>&1
    git add -A >> "$log_file" 2>&1
    git commit -m "reviewer(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
echo "=== Project Reviewer Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

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

recover_uncommitted "$REPO_ROOT" "review" "$LOG_FILE"

# Capture post-run state
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")
COMMITS_MADE=$(cd "$REPO_ROOT" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l || echo "0")

# Count verdicts from review file
REVIEW_FILE="$REPO_ROOT/knowledge_base/steward-reviews/${DATE}.md"
ON_TRACK=$(grep -ci "on-track" "$REVIEW_FILE" 2>/dev/null || echo "0")
NEEDS_CORRECTION=$(grep -ci "needs-correction" "$REVIEW_FILE" 2>/dev/null || echo "0")
ESCALATIONS=$(grep -c "ESCALATE" "$REVIEW_FILE" 2>/dev/null || echo "0")

# Write performance record
cat > "$PERF_FILE" << EOF
{
  "agent": "project-reviewer",
  "date": "$DATE",
  "duration_seconds": $DURATION,
  "commits_made": $COMMITS_MADE,
  "stewards_on_track": $ON_TRACK,
  "stewards_needs_correction": $NEEDS_CORRECTION,
  "escalations": $ESCALATIONS,
  "exit_code": 0
}
EOF

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Duration: ${DURATION}s | On-track: $ON_TRACK | Needs correction: $NEEDS_CORRECTION | Escalations: $ESCALATIONS" >> "$LOG_FILE"

# Keep only last 30 days
find "$LOG_DIR" -name "reviewer-*.log" -mtime +30 -delete 2>/dev/null || true
find "$PERF_DIR" -name "reviewer-*.json" -mtime +30 -delete 2>/dev/null || true

exit 0
