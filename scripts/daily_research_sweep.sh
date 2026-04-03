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
3. Update knowledge_base/agentic-ai/INDEX.md with today's date for all updated topics" >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Deep Analysis (L2-L3) ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2b: Deep Analysis.
Read .claude/agents/agentic-ai-researcher.md for the full L2-L3 instructions.

1. Read ROADMAP.md to understand our pipeline phases and current state
2. Read today's sweep findings from knowledge_base/agentic-ai/anthropic/ and knowledge_base/agentic-ai/google-deepmind/
3. Perform gap analysis: for each significant finding, assess impact on our pipeline
4. Identify cross-pollination opportunities between Anthropic and Google approaches
5. Flag any threats to our architecture (breaking changes, competing frameworks, security issues)
6. Write analysis to knowledge_base/agentic-ai/analysis/$(date +%Y-%m-%d).md" >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Strategic Planning (L4) ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2c: Strategic Planning.
Read .claude/agents/agentic-ai-researcher.md for the full L4 instructions.

1. Read today's analysis from knowledge_base/agentic-ai/analysis/$(date +%Y-%m-%d).md
2. Read ROADMAP.md for current pipeline state
3. For each identified gap or opportunity, write a skill proposal to knowledge_base/agentic-ai/proposals/ following the proposal format in the agent definition
4. Write ROADMAP update recommendations to knowledge_base/agentic-ai/proposals/roadmap-updates-$(date +%Y-%m-%d).md
5. Write any needed skill update suggestions to knowledge_base/agentic-ai/proposals/skill-updates-$(date +%Y-%m-%d).md
6. Focus on actionable, specific proposals with clear priority (P0-P3)" >> "$LOG_FILE" 2>&1 || true

echo "" >> "$LOG_FILE"
echo "--- Action (L5) ---" >> "$LOG_FILE"
"$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2d: Action.
Read .claude/agents/agentic-ai-researcher.md for the full L5 instructions and safety constraints.

1. Read all proposals from knowledge_base/agentic-ai/proposals/ dated today
2. For P0 proposals that suggest new Changeling roles: create them directly in ~/.claude/@lib/agents/
3. For P0/P1 proposals that suggest new skills: write a ready-to-execute prompt to knowledge_base/agentic-ai/proposals/ready/
4. Do NOT modify ROADMAP.md or existing skills directly
5. Log all actions taken to knowledge_base/agentic-ai/actions/$(date +%Y-%m-%d).md
6. Git add all changed files and commit with message 'research: daily agentic AI sweep $(date +%Y-%m-%d) (L1-L5)'" >> "$LOG_FILE" 2>&1 || true

EXIT_CODE=$?
echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Exit code: $EXIT_CODE" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "sweep-*.log" -mtime +30 -delete 2>/dev/null || true

exit $EXIT_CODE
