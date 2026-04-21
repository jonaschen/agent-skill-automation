#!/bin/bash
# daily_kings_hand_steward.sh — Cron-triggered King's Hand stewardship session
#
# Runs the steward skill with kings-hand config to maintain The King's Hand project.
#
# Schedule: 7pm daily (Asia/Taipei)
#
# Usage: Called by cron, or manually: ./scripts/daily_kings_hand_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_REPO="/home/jonas/gemini-home/The-King-s-Hand/The-King-s-Hand"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/kings-hand-${DATE}.log"
PERF_FILE="$PERF_DIR/kings-hand-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

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

# Post-session commit recovery
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
    git commit -m "steward(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "kings-hand" "$REPO_ROOT"

PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")

finalize() {
  local exit_code=$?
  set +euo pipefail

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local files_changed
  files_changed=$(cd "$TARGET_REPO" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$TARGET_REPO" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "kings-hand-steward",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "effort_level": "${CLAUDE_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"
  check_cost_ceiling "kings-hand" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "kings-hand-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "kings-hand-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== King's Hand Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
log_session_start "steward"

(recover_uncommitted "$TARGET_REPO" "kings-hand-previous" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Stewardship Session ---" >> "$LOG_FILE"
log_task_start "steward-session"
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the steward agent for the 'kings-hand' project. Read $REPO_ROOT/.claude/skills/steward/SKILL.md for the shared execution flow, then read $REPO_ROOT/.claude/skills/steward/configs/kings-hand.yaml for project-specific configuration.

IMPORTANT: You are running UNATTENDED via cron. Today is ${DATE}. Do NOT ask for permission — proceed directly.

Execute a full stewardship session:
1. Load config and orient (read all mandatory documents)
2. Assess current project state (ROADMAP status, recent git log)
3. Work on highest-priority incomplete task
4. Validate changes (run tests)
5. Commit with descriptive message") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Steward session complete" >> "$LOG_FILE"
log_task_complete "steward-session"

(recover_uncommitted "$TARGET_REPO" "steward" "$LOG_FILE") || true

exit 0
