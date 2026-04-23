#!/bin/bash
# daily_project_reviewer_gemini.sh — Cron-triggered nightly review of steward agent work (Gemini version)
#
# Runs the project-reviewer agent to assess the quality and direction of
# tonight's android-sw-steward, arm-mrs-steward, bsp-knowledge-steward, and
# ltc-steward runs. Writes feedback reviews and steering notes for the next session.
#
# Runs at 7am — after all stewards finish (3-6am nightly, LTC 8am-6pm daily).
#
# Usage: Called by cron, or manually: ./scripts/daily_project_reviewer_gemini.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/reviewer-gemini-${DATE}.log"
PERF_FILE="$PERF_DIR/reviewer-gemini-${DATE}.json"
GEMINI="/home/jonas/.nvm/versions/node/v24.14.0/bin/gemini"
# Ensure the correct Node version is used for gemini-cli and its dependencies
export PATH="/home/jonas/.nvm/versions/node/v24.14.0/bin:$PATH"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR" "$REPO_ROOT/knowledge_base/steward-reviews"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export GEMINI_INITIATOR_TYPE=cron-automated

# Per-agent effort level (discussion 2026-04-09: prepared commented-out, enable if costs spike >50%)
# Reasoning-heavy agent → high effort; uncomment to override default
# export GEMINI_CODE_EFFORT=high

# Post-session commit recovery: if Gemini wrote files but failed to commit, catch them
recover_uncommitted() {
  local repo_dir="$1"
  local session_name="$2"
  local log_file="$3"
  cd "$repo_dir" || return 0
  local dirty
  dirty=$(git status --porcelain 2>/dev/null | head -1 || true)
  if [ -n "$dirty" ]; then
    echo "[RECOVERY] $session_name left uncommitted changes — auto-committing" >> "$log_file"
    git status --short >> "$log_file" 2>&1
    git add -A >> "$log_file" 2>&1
    git commit -m "reviewer-gemini(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "reviewer-gemini" "$REPO_ROOT"

# Capture pre-run state (before trap setup so they're available in finalize)
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  # Kill watchdog if still running
  if [ -n "${WATCHDOG_PID:-}" ]; then
    kill "$WATCHDOG_PID" 2>/dev/null || true
  fi

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  local review_file="$REPO_ROOT/knowledge_base/steward-reviews/${DATE}.md"
  local on_track
  # Count unique steward verdicts (in summary table or ### Verdict lines), not all string occurrences
  on_track=$(grep -E "^\| .* \| \*\*on-track\*\*|^### Verdict: on-track" "$review_file" 2>/dev/null | wc -l) || on_track="0"
  local needs_correction
  needs_correction=$(grep -E "^\| .* \| \*\*needs-correction\*\*|^### Verdict: needs-correction" "$review_file" 2>/dev/null | wc -l) || needs_correction="0"
  local escalations
  escalations=$(grep -c "\[ESCALATE\]" "$review_file" 2>/dev/null) || escalations="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "project-reviewer-gemini",
  "date": "$DATE",
  "duration_seconds": $duration,
  "commits_made": $commits_made,
  "stewards_on_track": $on_track,
  "stewards_needs_correction": $needs_correction,
  "escalations": $escalations,
  "effort_level": "${GEMINI_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  check_cost_ceiling "reviewer-gemini" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | On-track: $on_track | Needs correction: $needs_correction | Escalations: $escalations" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "reviewer-gemini-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "reviewer-gemini-*.json" -mtime +30 -delete 2>/dev/null
}

# Start incremental watchdog
WATCHDOG_PID=$(start_incremental_watchdog "reviewer-gemini" "$$" "$PERF_DIR" "$SECURITY_LOG_DIR")
echo "[$(date)] Started cost watchdog (PID: $WATCHDOG_PID)" >> "$LOG_FILE"

trap finalize EXIT INT TERM HUP

echo "=== Project Reviewer Session (Gemini) — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$GEMINI" "$LOG_FILE" < /dev/null
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "review"

echo "" >> "$LOG_FILE"
echo "--- Review All Four Stewards ---" >> "$LOG_FILE"
log_task_start "steward-review"
# Run Gemini in a subshell to isolate process-group signals from the parent script
(cd "$REPO_ROOT" && timeout 2400 "$GEMINI" --approval-mode yolo -p "You are the project-reviewer agent. Read .gemini/agents/project-reviewer.md for your full instructions.

Execute a review session for today's steward runs ($DATE):

For each of the four stewards (android-sw, arm-mrs, bsp-knowledge, ltc):
1. Read their log: logs/{android-sw-gemini,arm-mrs-gemini,bsp-knowledge-gemini,ltc-gemini}-${DATE}.log
2. Read their perf JSON: logs/performance/{android-sw-gemini,arm-mrs-gemini,bsp-knowledge-gemini,ltc-gemini}-${DATE}.json
3. Go to the target repo, run 'git log --oneline -5' and 'git diff HEAD~1' to see actual changes
4. Read the target repo's ROADMAP.md and CLAUDE.md for alignment check
5. Assess: correctness, alignment with ROADMAP, meaningful progress, risks, next priorities
Note: LTC steward runs multiple times daily — review the previous day's logs if the reviewer runs at 7am before LTC's first session.

Then:
6. Write a structured review to knowledge_base/steward-reviews/${DATE}.md with per-steward verdicts (on-track / needs-correction / blocked), findings, and advice
7. Check if any steward modified skill files (skill.md/SKILL.md) — if so, invoke the skill-quality-validator via Task tool and include the quality verdict in your review
8. For any steward that needs correction (including failed skill validation), include steering notes WITHIN the review file (do NOT attempt to write .gemini/steering-notes.md in external repos — sandbox permissions block it)
9. Look for cross-project insights (findings in one repo relevant to another)
10. If any steward is stalled, regressing, or off-track, flag it clearly with [ESCALATE] in the review

If a steward didn't run today (no log file), note it as 'no run' and skip.

Commit the review file: git add knowledge_base/steward-reviews/${DATE}.md && git commit -m 'review-gemini: steward work assessment ${DATE}'" < /dev/null) >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Review session complete" >> "$LOG_FILE"
log_task_complete "steward-review"

(recover_uncommitted "$REPO_ROOT" "review" "$LOG_FILE") || true

# Post-review: propagate steering notes from review file to target repos
# The reviewer can't write to external repos from Gemini sandbox, so we do it via bash
REVIEW_FILE="$REPO_ROOT/knowledge_base/steward-reviews/${DATE}.md"
if [ -f "$REVIEW_FILE" ]; then
  propagate_steering() {
    local steward_name="$1"
    local target_repo="$2"
    local review_file="$3"
    local log_file="$4"

    # Only propagate if steward needs correction
    if ! grep -q "needs-correction" "$review_file" 2>/dev/null; then
      return 0
    fi

    # Extract the steward's section with Required Actions
    local section
    section=$(awk "/^## ${steward_name}/,/^## [^${steward_name:0:1}]|^---/" "$review_file" 2>/dev/null) || return 0

    # Check if this section has Required Actions or steering content
    if ! echo "$section" | grep -qi "required actions\|steering note\|needs-correction" 2>/dev/null; then
      return 0
    fi

    local steering_file="${target_repo}/.gemini/steering-notes.md"
    mkdir -p "$(dirname "$steering_file")"

    # Create header if file doesn't exist
    if [ ! -f "$steering_file" ]; then
      cat > "$steering_file" << 'HEADER_EOF'
# Steering Notes

This file contains dated feedback from the project-reviewer agent.
Steward agents should read this file at the start of each session and
address any outstanding items.

HEADER_EOF
    fi

    # Skip if today's note already appended
    if grep -q "^## $DATE" "$steering_file" 2>/dev/null; then
      return 0
    fi

    # Extract Required Actions block
    local actions
    actions=$(echo "$section" | awk '/\*\*Required Actions/,/^$|^\*\*Context/' | head -20) || actions=""
    local verdict
    verdict=$(echo "$section" | grep -o 'needs-correction\|on-track\|blocked' | head -1) || verdict="unknown"

    if [ -n "$actions" ]; then
      cat >> "$steering_file" << NOTES_EOF

## $DATE — Project Reviewer Feedback

**Verdict**: $verdict

$actions

NOTES_EOF
      echo "[STEERING] Propagated steering notes to $steering_file" >> "$log_file"
    fi
  }

  propagate_steering "ARM MRS" "/home/jonas/arm-mrs-2025-03-aarchmrs" "$REVIEW_FILE" "$LOG_FILE" || true
  propagate_steering "BSP Knowledge" "/home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets" "$REVIEW_FILE" "$LOG_FILE" || true
  propagate_steering "Android-SW" "/home/jonas/gemini-home/Android-Software" "$REVIEW_FILE" "$LOG_FILE" || true
  propagate_steering "LTC" "/home/jonas/gemini-home/long-term-care-expert" "$REVIEW_FILE" "$LOG_FILE" || true
fi

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
