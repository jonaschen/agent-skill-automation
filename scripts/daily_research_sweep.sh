#!/bin/bash
# daily_research_sweep.sh — Cron-triggered daily agentic AI research sweep
#
# Runs the agentic-ai-researcher agent to scan all tracked topics
# and update the knowledge base.
#
# Usage: Called by cron, or manually: ./scripts/daily_research_sweep.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/sweep-${DATE}.log"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

mkdir -p "$LOG_DIR"

echo "=== Agentic AI Research Sweep — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Run the research sweep
cd "$REPO_ROOT"
"$CLAUDE" --dangerously-skip-permissions -p "$(cat <<'PROMPT'
You are the agentic-ai-researcher. Run a full research sweep (Mode 2).

Instructions:
1. Read .claude/agents/agentic-ai-researcher.md for the full execution flow
2. Read knowledge_base/agentic-ai/INDEX.md to see what was last updated
3. For each topic in BOTH the Anthropic and Google/DeepMind tracks:
   - WebSearch for recent developments
   - WebFetch the top 3 most relevant new results
   - Write findings to the appropriate KB file under knowledge_base/agentic-ai/
   - If the file exists, APPEND new findings (never overwrite)
   - If the file doesn't exist, create it following the KB format
4. Write a sweep report to knowledge_base/agentic-ai/sweeps/ with today's date
5. Update INDEX.md with new entries and today's date as last-sweep
6. Git add all changed files and commit with message "research: daily agentic AI sweep <today's date>"

Follow the knowledge base format and sweep report format defined in the agent definition exactly.
Always cite sources with URLs. Date every finding.
PROMPT
)" >> "$LOG_FILE" 2>&1

EXIT_CODE=$?
echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Exit code: $EXIT_CODE" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "sweep-*.log" -mtime +30 -delete 2>/dev/null || true

exit $EXIT_CODE
