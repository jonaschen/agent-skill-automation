#!/bin/bash
# daily_elite_research_gemini.sh — High-end adversarial research synthesis (Gemini version)
#
# This script performs the "Top Gun" research cycle:
# 1. Ingests findings from BOTH Claude and Gemini researcher teams.
# 2. Performs "Adversarial Synthesis" (Gemini reviews Claude's ideas).
# 3. Formulates "Elite Hypotheses" for the next cycle.
# 4. Generates a joint publication-ready Technical Report.
#
# Usage: ./scripts/daily_elite_research_gemini.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/elite-research-gemini-${DATE}.log"
GEMINI="/home/jonas/.nvm/versions/node/v24.14.0/bin/gemini"
# Ensure the correct Node version is used for gemini-cli and its dependencies
export PATH="/home/jonas/.nvm/versions/node/v24.14.0/bin:$PATH"

mkdir -p "$LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/session_log.sh"

echo "=== Gemini Elite Research Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
init_session_log "elite-research" "$REPO_ROOT"

echo "" >> "$LOG_FILE"
echo "--- Cross-Vendor Adversarial Synthesis ---" >> "$LOG_FILE"
log_task_start "adversarial-synthesis"

(cd "$REPO_ROOT" && "$GEMINI" --approval-mode yolo -p "You are the Gemini Research Lead. Execute the 'Adversarial Synthesis' cycle.

1. Read ALL research sweep reports from today:
   - knowledge_base/agentic-ai/sweeps/${DATE}.md (Claude's sweep)
   - knowledge_base/agentic-ai/sweeps/${DATE}-gemini.md (Gemini's sweep - if exists)

2. Act as the CRITICAL REVIEWER of the Claude team's findings. Identify:
   - Gaps in their logic.
   - Missing ArXiv citations.
   - Potential 'Regressive Evolution' risks in their proposals.

3. Write a 'Cross-Vendor Synthesis Report' to knowledge_base/agentic-ai/analysis/${DATE}-joint-synthesis.md.
   This report should combine the best ideas from both teams into a single, unified strategic priority." < /dev/null) >> "$LOG_FILE" 2>&1 || true

log_task_complete "adversarial-synthesis"

echo "" >> "$LOG_FILE"
echo "--- Elite Hypothesis Formulation ---" >> "$LOG_FILE"
log_task_start "elite-hypothesis"

(cd "$REPO_ROOT" && "$GEMINI" --approval-mode yolo -p "You are the Gemini Technical Scrivener.
Based on today's 'Joint Synthesis Report' (knowledge_base/agentic-ai/analysis/${DATE}-joint-synthesis.md), formulate ONE high-novelty Academic Hypothesis.

This hypothesis must focus on solving a core bottleneck (e.g., the Freezer Effect or Urgency Bias).
Write it to knowledge_base/agentic-ai/hypotheses/${DATE}-elite-hypothesis.md in formal scientific format." < /dev/null) >> "$LOG_FILE" 2>&1 || true

log_task_complete "elite-hypothesis"

echo "" >> "$LOG_FILE"
echo "--- Joint Paper Generation ---" >> "$LOG_FILE"
log_task_start "joint-paper"

(cd "$REPO_ROOT" && "$GEMINI" --approval-mode yolo -p "You are the Agentic AI Research Writer.
Generate the final daily Technical Report.

1. Synthesize the findings from:
   - Claude's candidate: knowledge_base/agentic-ai/papers/${DATE}-claude-candidate.md (if exists)
   - Gemini's candidate: knowledge_base/agentic-ai/papers/${DATE}-gemini-candidate.md
   - The Elite Hypothesis: knowledge_base/agentic-ai/hypotheses/${DATE}-elite-hypothesis.md

2. Produce a unified paper that presents a COHESIVE research direction for the project.
3. Incorporate Bayesian evidence from logs/performance/ where applicable.
4. Write the paper to knowledge_base/agentic-ai/papers/${DATE}-joint-technical-report.md.

This is the document we will use to publish our progress." < /dev/null) >> "$LOG_FILE" 2>&1 || true

log_task_complete "joint-paper"

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
exit 0
