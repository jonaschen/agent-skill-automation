#!/bin/bash
# daily_factory_steward.sh — Cron-triggered nightly factory self-improvement session
#
# Runs the factory-steward agent to implement ADOPT items from yesterday's
# research discussion, act on proposals, review agent performance, improve
# the eval infrastructure, and advance the ROADMAP.
#
# Runs at 9pm — before the other nightly agents — so improvements are in
# place for tonight's runs.
#
# Usage: Called by cron, or manually: ./scripts/daily_factory_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
YESTERDAY=$(date -d "yesterday" +"%Y-%m-%d" 2>/dev/null || date -v-1d +"%Y-%m-%d" 2>/dev/null)
LOG_FILE="$LOG_DIR/factory-${DATE}.log"
PERF_FILE="$PERF_DIR/factory-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

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
    git commit -m "factory(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
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
  local files_changed
  files_changed=$(cd "$REPO_ROOT" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"
  local adopt_count
  adopt_count=$(grep -c "ADOPT" "$REPO_ROOT/knowledge_base/agentic-ai/discussions/${YESTERDAY:-1970-01-01}.md" 2>/dev/null) || adopt_count="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "factory-steward",
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

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | ADOPT items: $adopt_count" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "factory-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "factory-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT

echo "=== Factory Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "--- Implement ADOPT Items & Proposals ---" >> "$LOG_FILE"
cd "$REPO_ROOT" && "$CLAUDE" --dangerously-skip-permissions -p "You are the factory-steward agent. Read .claude/agents/factory-steward.md for your full instructions.

IMPORTANT: You are running UNATTENDED via cron. You have full write permission to all files in this repo including .claude/agents/*.md, .claude/skills/, .claude/hooks/, eval/, scripts/, and ROADMAP.md. Do NOT ask for permission — proceed directly with all changes.

Execute a factory improvement session:
1. Orient: Read CLAUDE.md, ROADMAP.md to understand current pipeline state
2. Read yesterday's discussion transcript: knowledge_base/agentic-ai/discussions/${YESTERDAY}.md — focus on ADOPT items
3. Read any pending proposals in knowledge_base/agentic-ai/proposals/ (P0/P1 priority)
4. Implement the highest-priority ADOPT items and P0/P1 proposals — make real code changes to eval/, scripts/, .claude/agents/, .claude/hooks/ as needed
5. Run tests to verify nothing is broken after changes
6. Update ROADMAP.md with completed work
7. Commit: Stage all changed files and commit with message 'factory: implement ADOPT items from ${YESTERDAY} discussion'

Focus on 1-2 high-impact improvements. Quality over quantity." >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$REPO_ROOT" "adopt-items" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Agent Performance Review & Tuning ---" >> "$LOG_FILE"
cd "$REPO_ROOT" && "$CLAUDE" --dangerously-skip-permissions -p "You are the factory-steward agent. Read .claude/agents/factory-steward.md for your full instructions.

IMPORTANT: You are running UNATTENDED via cron. You have full write permission to all files in this repo including .claude/agents/*.md, .claude/skills/, .claude/hooks/, eval/, scripts/, and ROADMAP.md. Do NOT ask for permission — proceed directly with all changes.

Run a performance review and tuning session:
1. Run: bash scripts/agent_review.sh 7
2. Read the latest performance JSON files in logs/performance/ for all agents
3. Read the latest log files in logs/ for any agents that had issues
4. Identify underperforming agents (low success rate, no commits, errors)
5. For underperforming agents: read their agent definition and daily script, propose or implement fixes
6. If eval infrastructure needs improvement (flaky tests, coverage gaps), make targeted fixes
7. Commit: If you made any changes, stage and commit with message 'factory: tune agents based on performance review ($DATE)'

Be conservative — only change agent scripts/definitions when there's clear evidence of a problem." >> "$LOG_FILE" 2>&1 || true

(recover_uncommitted "$REPO_ROOT" "perf-tuning" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
