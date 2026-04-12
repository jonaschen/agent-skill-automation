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
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/sweep-${DATE}.log"
PERF_FILE="$PERF_DIR/researcher-${DATE}.json"
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

# Per-agent effort level (discussion 2026-04-09: prepared commented-out, enable if costs spike >50%)
# Reasoning-heavy agent → high effort; uncomment to override default
# export CLAUDE_CODE_EFFORT=high

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
    git commit -m "research(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "researcher" "$REPO_ROOT"
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  # Recover any uncommitted changes from this session
  recover_uncommitted "$REPO_ROOT" "researcher" "$LOG_FILE"

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local kb_files
  kb_files=$(find "$REPO_ROOT/knowledge_base" -name "*.md" -newermt "@${START_TIME}" 2>/dev/null | wc -l) || kb_files="0"
  local commit
  commit=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null) || commit="unknown"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"
  local files_changed
  files_changed=$(cd "$REPO_ROOT" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "agentic-ai-researcher",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "commit": "$commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "kb_files_updated": $kb_files,
  "effort_level": "${CLAUDE_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  check_cost_ceiling "researcher" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | KB files updated: $kb_files | Commits: $commits_made | Files changed: $files_changed | Exit code: $exit_code" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "sweep-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "researcher-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== Agentic AI Research Sweep — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "research-sweep"

# Recover any uncommitted changes from a previous crashed session
recover_uncommitted "$REPO_ROOT" "researcher-previous" "$LOG_FILE"

# Run the research sweep — split into Anthropic and Google tracks to avoid timeouts
cd "$REPO_ROOT"

echo "" >> "$LOG_FILE"
echo "--- Anthropic Track ---" >> "$LOG_FILE"
log_task_start "anthropic-track"
# Run Claude in a subshell to isolate process-group signals from the parent script
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

Research the ANTHROPIC track only. For each topic (Claude Code, Agent SDK, MCP, Tool Use, Computer Use, Multi-agent Patterns, Model Releases):
1. WebSearch for latest developments
2. WebFetch the top 2 results
3. Write or append findings to the correct file under knowledge_base/agentic-ai/anthropic/
4. Follow the KB format from the agent definition. Always cite sources with URLs. Date every finding with today's date.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Anthropic track complete" >> "$LOG_FILE"
log_task_complete "anthropic-track"

echo "" >> "$LOG_FILE"
echo "--- Google/DeepMind Track ---" >> "$LOG_FILE"
log_task_start "google-deepmind-track"
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

Research the GOOGLE/DEEPMIND track only. For each topic (Gemini Agents, A2A Protocol, ADK, Vertex AI Agents, Project Mariner, Project Astra, Gemma):
1. WebSearch for latest developments
2. WebFetch the top 2 results
3. Write or append findings to the correct file under knowledge_base/agentic-ai/google-deepmind/
4. Follow the KB format from the agent definition. Always cite sources with URLs. Date every finding with today's date.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Google/DeepMind track complete" >> "$LOG_FILE"
log_task_complete "google-deepmind-track"

echo "" >> "$LOG_FILE"
echo "--- Sweep Report & Index ---" >> "$LOG_FILE"
log_task_start "sweep-report"
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher. Read .claude/agents/agentic-ai-researcher.md for format specs.

1. Read all files in knowledge_base/agentic-ai/anthropic/ and knowledge_base/agentic-ai/google-deepmind/
2. Write a sweep report to knowledge_base/agentic-ai/sweeps/$(date +%Y-%m-%d).md following the sweep report format in the agent definition
3. Update knowledge_base/agentic-ai/INDEX.md with today's date for all updated topics") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Sweep report complete" >> "$LOG_FILE"
log_task_complete "sweep-report"

echo "" >> "$LOG_FILE"
echo "--- Deep Analysis (L2-L3) ---" >> "$LOG_FILE"
log_task_start "deep-analysis"
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2b: Deep Analysis.
Read .claude/agents/agentic-ai-researcher.md for the full L2-L3 instructions.

1. Read ROADMAP.md to understand our pipeline phases and current state
2. Read today's sweep findings from knowledge_base/agentic-ai/anthropic/ and knowledge_base/agentic-ai/google-deepmind/
3. Perform gap analysis: for each significant finding, assess impact on our pipeline
4. Identify cross-pollination opportunities between Anthropic and Google approaches
5. Flag any threats to our architecture (breaking changes, competing frameworks, security issues)
6. Write analysis to knowledge_base/agentic-ai/analysis/$(date +%Y-%m-%d).md") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Deep analysis complete" >> "$LOG_FILE"
log_task_complete "deep-analysis"

echo "" >> "$LOG_FILE"
echo "--- Improvement Discussion (L3.5) ---" >> "$LOG_FILE"
log_task_start "discussion"
("$CLAUDE" --dangerously-skip-permissions -p "You are facilitating a structured discussion between two expert perspectives about how today's research findings can improve the agent-skill-automation pipeline.

First, read these files to understand the context:
1. knowledge_base/agentic-ai/analysis/$(date +%Y-%m-%d).md (today's research analysis)
2. ROADMAP.md (current pipeline state)
3. CLAUDE.md (architecture and design principles)

Then conduct a multi-round discussion between two perspectives:

## INNOVATOR (goes first each round)
Proposes concrete improvements to this repo's pipeline, agents, eval system, or architecture based on today's findings. Should be specific: name the file to change, the pattern to adopt, the tool to integrate. Think boldly — what could we build next?

## ENGINEER (responds each round)
Challenges each proposal on: implementation cost, blast radius, whether it conflicts with existing design principles, whether simpler alternatives exist. Not a blocker — but demands the proposal earn its complexity.

Run 3 rounds of back-and-forth. Each round: Innovator proposes 2-3 ideas → Engineer responds to each → they converge on a verdict (adopt / defer / reject with reason).

After all rounds, write a structured summary:
- ADOPT: ideas both perspectives agree should be implemented (with priority P0-P3)
- DEFER: good ideas that need more research or depend on future phases
- REJECT: ideas that don't justify their cost

Write the full discussion transcript and summary to knowledge_base/agentic-ai/discussions/$(date +%Y-%m-%d).md

Format the file with clear round headers, speaker labels, and the final ADOPT/DEFER/REJECT table.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Discussion complete" >> "$LOG_FILE"
log_task_complete "discussion"

echo "" >> "$LOG_FILE"
echo "--- Strategic Planning (L4) ---" >> "$LOG_FILE"
log_task_start "strategic-planning"
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2c: Strategic Planning.
Read .claude/agents/agentic-ai-researcher.md for the full L4 instructions.

1. Read today's analysis from knowledge_base/agentic-ai/analysis/$(date +%Y-%m-%d).md
2. Read today's improvement discussion from knowledge_base/agentic-ai/discussions/$(date +%Y-%m-%d).md — prioritize items marked ADOPT
3. Read ROADMAP.md for current pipeline state
4. For each identified gap or opportunity, write a skill proposal to knowledge_base/agentic-ai/proposals/ following the proposal format in the agent definition
5. Incorporate ADOPT items from the discussion as P0/P1 proposals; DEFER items as P2/P3
6. Write ROADMAP update recommendations to knowledge_base/agentic-ai/proposals/roadmap-updates-$(date +%Y-%m-%d).md
7. Write any needed skill update suggestions to knowledge_base/agentic-ai/proposals/skill-updates-$(date +%Y-%m-%d).md
8. Focus on actionable, specific proposals with clear priority (P0-P3)") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Strategic planning complete" >> "$LOG_FILE"
log_task_complete "strategic-planning"

echo "" >> "$LOG_FILE"
echo "--- Action (L5) ---" >> "$LOG_FILE"
log_task_start "action"
("$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-researcher running Mode 2d: Action.
Read .claude/agents/agentic-ai-researcher.md for the full L5 instructions and safety constraints.

1. Read all proposals from knowledge_base/agentic-ai/proposals/ dated today
2. For P0 proposals that suggest new Changeling roles: create them directly in ~/.claude/@lib/agents/
3. For P0/P1 proposals that suggest new skills: write a ready-to-execute prompt to knowledge_base/agentic-ai/proposals/ready/
4. Do NOT modify ROADMAP.md or existing skills directly
5. Log all actions taken to knowledge_base/agentic-ai/actions/$(date +%Y-%m-%d).md
6. Git add all changed files and commit with message 'research: daily agentic AI sweep $(date +%Y-%m-%d) (L1-L5)'") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Action phase complete" >> "$LOG_FILE"
log_task_complete "action"

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
