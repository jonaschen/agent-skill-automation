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

# Run the research sweep — split into Anthropic and Google tracks to avoid timeouts
cd "$REPO_ROOT"

echo "" >> "$LOG_FILE"
echo "--- Anthropic Track ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

Research the ANTHROPIC track only. For each topic (Claude Code, Agent SDK, MCP, Tool Use, Computer Use, Multi-agent Patterns, Model Releases):
1. WebSearch for latest developments
2. WebFetch the top 2 results
3. Write or append findings to the correct file under knowledge_base/agentic-ai/anthropic/
4. Follow the KB format from the agent definition. Always cite sources with URLs. Date every finding with today's date." >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Google/DeepMind Track ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

Research the GOOGLE/DEEPMIND track only. For each topic (Gemini Agents, A2A Protocol, ADK, Vertex AI Agents, Project Mariner, Project Astra, Gemma):
1. WebSearch for latest developments
2. WebFetch the top 2 results
3. Write or append findings to the correct file under knowledge_base/agentic-ai/google-deepmind/
4. Follow the KB format from the agent definition. Always cite sources with URLs. Date every finding with today's date." >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Sweep Report & Index ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

1. Read all files in knowledge_base/agentic-ai/anthropic/ and knowledge_base/agentic-ai/google-deepmind/
2. Write a sweep report to knowledge_base/agentic-ai/sweeps/$(date +%Y-%m-%d).md following the sweep report format in the agent definition
3. Update knowledge_base/agentic-ai/INDEX.md with today's date for all updated topics
4. Git add all changed files under knowledge_base/ and commit with message 'research: daily agentic AI sweep $(date +%Y-%m-%d)'" >> "$LOG_FILE" 2>&1 || true

EXIT_CODE=$?
echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Exit code: $EXIT_CODE" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "sweep-*.log" -mtime +30 -delete 2>/dev/null || true

exit $EXIT_CODE
