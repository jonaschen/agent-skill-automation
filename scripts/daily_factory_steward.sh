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

START_TIME=$(date +%s)
echo "=== Factory Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Capture pre-run state
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

echo "" >> "$LOG_FILE"
echo "--- Implement ADOPT Items & Proposals ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions --cwd "$REPO_ROOT" -p "You are the factory-steward agent. Read .claude/agents/factory-steward.md for your full instructions.

Execute a factory improvement session:
1. Orient: Read CLAUDE.md, ROADMAP.md to understand current pipeline state
2. Read yesterday's discussion transcript: knowledge_base/agentic-ai/discussions/${YESTERDAY}.md — focus on ADOPT items
3. Read any pending proposals in knowledge_base/agentic-ai/proposals/ (P0/P1 priority)
4. Implement the highest-priority ADOPT items and P0/P1 proposals — make real code changes to eval/, scripts/, .claude/agents/, .claude/hooks/ as needed
5. Run tests to verify nothing is broken after changes
6. Update ROADMAP.md with completed work
7. Commit: Stage all changed files and commit with message 'factory: implement ADOPT items from ${YESTERDAY} discussion'

Focus on 1-2 high-impact improvements. Quality over quantity." >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Agent Performance Review & Tuning ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions --cwd "$REPO_ROOT" -p "You are the factory-steward agent. Read .claude/agents/factory-steward.md for your full instructions.

Run a performance review and tuning session:
1. Run: bash scripts/agent_review.sh 7
2. Read the latest performance JSON files in logs/performance/ for all agents
3. Read the latest log files in logs/ for any agents that had issues
4. Identify underperforming agents (low success rate, no commits, errors)
5. For underperforming agents: read their agent definition and daily script, propose or implement fixes
6. If eval infrastructure needs improvement (flaky tests, coverage gaps), make targeted fixes
7. Commit: If you made any changes, stage and commit with message 'factory: tune agents based on performance review ($DATE)'

Be conservative — only change agent scripts/definitions when there's clear evidence of a problem." >> "$LOG_FILE" 2>&1 || true

# Capture post-run state
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")
FILES_CHANGED=$(cd "$REPO_ROOT" && git diff --name-only "$PRE_COMMIT" HEAD 2>/dev/null | wc -l || echo "0")
COMMITS_MADE=$(cd "$REPO_ROOT" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l || echo "0")
ADOPT_COUNT=$(grep -c "ADOPT" "$REPO_ROOT/knowledge_base/agentic-ai/discussions/${YESTERDAY}.md" 2>/dev/null || echo "0")

# Write performance record
cat > "$PERF_FILE" << EOF
{
  "agent": "factory-steward",
  "date": "$DATE",
  "duration_seconds": $DURATION,
  "pre_commit": "$PRE_COMMIT",
  "post_commit": "$POST_COMMIT",
  "commits_made": $COMMITS_MADE,
  "files_changed": $FILES_CHANGED,
  "adopt_items_available": $ADOPT_COUNT,
  "exit_code": 0
}
EOF

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Duration: ${DURATION}s | Commits: $COMMITS_MADE | Files changed: $FILES_CHANGED | ADOPT items: $ADOPT_COUNT" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "factory-*.log" -mtime +30 -delete 2>/dev/null || true
find "$PERF_DIR" -name "factory-*.json" -mtime +30 -delete 2>/dev/null || true

exit 0
