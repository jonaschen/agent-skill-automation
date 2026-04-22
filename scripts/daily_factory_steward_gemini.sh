#!/bin/bash
# daily_factory_steward_gemini.sh — Cron-triggered nightly factory self-improvement session (Gemini version)
#
# Runs the factory-steward agent via Gemini CLI to implement ADOPT items from yesterday's
# research discussion, act on proposals, review agent performance, improve
# the eval infrastructure, and advance the ROADMAP.
#
# Usage: ./scripts/daily_factory_steward_gemini.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
YESTERDAY=$(date -d "yesterday" +"%Y-%m-%d" 2>/dev/null || date -v-1d +"%Y-%m-%d" 2>/dev/null)
LOG_FILE="$LOG_DIR/factory-gemini-${DATE}.log"
PERF_FILE="$PERF_DIR/factory-gemini-${DATE}.json"
GEMINI="/home/jonas/.nvm/versions/node/v24.14.0/bin/gemini"
# Ensure the correct Node version is used for gemini-cli and its dependencies
export PATH="/home/jonas/.nvm/versions/node/v24.14.0/bin:$PATH"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export GEMINI_INITIATOR_TYPE=cron-automated
export CLAUDE_AGENT_NAME="factory-steward-gemini" # For session_log and cost_ceiling compat
export AGENT_TRACK="B" # Factory steward is high-coupling (Track B)

# Save goal to file for goal-consistency hook
AGENT_GOAL_FILE="/tmp/factory_gemini_goal_${DATE}.txt"
export AGENT_GOAL_FILE

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
    git commit -m "factory-gemini(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)

# Initialize session logging
init_session_log "factory-gemini" "$REPO_ROOT"

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
  local files_changed
  files_changed=$(cd "$REPO_ROOT" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"
  local adopt_count
  adopt_count=$(grep -c "ADOPT" "$REPO_ROOT/knowledge_base/agentic-ai/discussions/${YESTERDAY:-1970-01-01}.md" 2>/dev/null) || adopt_count="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "factory-steward-gemini",
  "provider": "gemini",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "adopt_items_available": $adopt_count,
  "exit_code": $exit_code
}
PERF_EOF

  # Log session end
  log_session_end "$exit_code" "$duration"

  # Kill watchdog if still running
  if [ -n "${WATCHDOG_PID:-}" ]; then
    kill "$WATCHDOG_PID" 2>/dev/null || true
  fi

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  # Use "factory-gemini" as agent name for cost ceiling to track separately from Claude
  check_cost_ceiling "factory-gemini" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | ADOPT items: $adopt_count" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "factory-gemini-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "factory-gemini-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== Gemini Factory Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "main"
check_fleet_version "$GEMINI" "$LOG_FILE" < /dev/null

echo "" >> "$LOG_FILE"
echo "--- Implement ADOPT Items & Proposals ---" >> "$LOG_FILE"
log_task_start "adopt-items"
# Start incremental watchdog (P0 Discussion 2026-04-23)
WATCHDOG_PID=$(start_incremental_watchdog "factory-gemini" "$$" "$PERF_DIR" "$SECURITY_LOG_DIR")
echo "[$(date)] Started cost watchdog (PID: $WATCHDOG_PID)" >> "$LOG_FILE"

ADOPT_PROMPT="You are the steward agent for the 'factory' project. Read .gemini/skills/steward/SKILL.md for the shared execution flow, then read .gemini/skills/steward/configs/factory.yaml for project-specific configuration.

IMPORTANT: You are running UNATTENDED via cron. You have full write permission to all files in this repo including .gemini/agents/*.md, .gemini/skills/, .gemini/hooks/, eval/, scripts/, and ROADMAP.md. Do NOT ask for permission — proceed directly with all changes.

Execute a factory improvement session:
1. Orient: Read CLAUDE.md, ROADMAP.md to understand current pipeline state
2. Read today's research-lead directive: knowledge_base/agentic-ai/directives/${DATE}.md (if it exists) — this provides priority guidance from the research lead on what matters most
3. Read yesterday's discussion transcript: knowledge_base/agentic-ai/discussions/${YESTERDAY}.md — focus on ADOPT items
4. Read any pending proposals in knowledge_base/agentic-ai/proposals/ (P0/P1 priority)
5. Implement the highest-priority ADOPT items and P0/P1 proposals, prioritizing items that align with the research-lead's P0/P1 directive topics — make real code changes to eval/, scripts/, .gemini/agents/, .gemini/hooks/ as needed
5. Run tests to verify nothing is broken after changes
6. Update ROADMAP.md with completed work
7. Commit: Stage all changed files and commit with message 'factory-gemini: implement ADOPT items from ${YESTERDAY} discussion'

Focus on 1-2 high-impact improvements. Quality over quantity."

echo "$ADOPT_PROMPT" > "$AGENT_GOAL_FILE"

(cd "$REPO_ROOT" && timeout 2400 "$GEMINI" --approval-mode yolo -p "$ADOPT_PROMPT" < /dev/null) >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] ADOPT session complete" >> "$LOG_FILE"
log_task_complete "adopt-items"

(recover_uncommitted "$REPO_ROOT" "adopt-items" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Agent Performance Review & Tuning ---" >> "$LOG_FILE"
log_task_start "performance-review"
# Reset watchdog segment timer for next task (P0 Directive 2026-04-23)
watchdog_pulse "$WATCHDOG_PID"

PERF_PROMPT="You are the steward agent for the 'factory' project. Read .gemini/skills/steward/SKILL.md for the shared execution flow, then read .gemini/skills/steward/configs/factory.yaml for project-specific configuration.

IMPORTANT: You are running UNATTENDED via cron. You have full write permission to all files in this repo including .gemini/agents/*.md, .gemini/skills/, .gemini/hooks/, eval/, scripts/, and ROADMAP.md. Do NOT ask for permission — proceed directly with all changes.

Run a performance review and tuning session:
1. Run: bash scripts/agent_review.sh 7
2. Read the latest performance JSON files in logs/performance/ for all agents (both Claude and Gemini versions)
3. Read the latest log files in logs/ for any agents that had issues
4. Identify underperforming agents (low success rate, no commits, errors)
5. For underperforming agents: read their agent definition and daily script, propose or implement fixes
6. If eval infrastructure needs improvement (flaky tests, coverage gaps), make targeted fixes
7. Commit: If you made any changes, stage and commit with message 'factory-gemini: tune agents based on performance review ($DATE)'

Be conservative — only change agent scripts/definitions when there's clear evidence of a problem."

echo "$PERF_PROMPT" > "$AGENT_GOAL_FILE"

(cd "$REPO_ROOT" && timeout 2400 "$GEMINI" --approval-mode yolo -p "$PERF_PROMPT" < /dev/null) >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Performance review session complete" >> "$LOG_FILE"
log_task_complete "performance-review"

(recover_uncommitted "$REPO_ROOT" "perf-tuning" "$LOG_FILE") || true

exit 0
