#!/bin/bash
# daily_research_lead.sh — Cron-triggered research direction session
#
# Runs the agentic-ai-research-lead agent to review researcher output,
# evaluate quality and direction, and write priority directives that
# guide the next researcher sweep and factory-steward implementation.
#
# Runs twice daily:
#   3:00 AM — after night researcher (2am), before night factory (4am)
#   11:00 AM — after morning researcher (10am), before morning factory (12pm)
#
# Usage: Called by cron, or manually: ./scripts/daily_research_lead.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/research-lead-${DATE}.log"
PERF_FILE="$PERF_DIR/research-lead-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR" "$REPO_ROOT/knowledge_base/agentic-ai/directives"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export CLAUDE_INITIATOR_TYPE=cron-automated

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
    git commit -m "research-lead(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "research-lead" "$REPO_ROOT"

# Capture pre-run state
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

# Finalize: write perf JSON and log footer on ANY exit
finalize() {
  local exit_code=$?
  set +euo pipefail

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local files_changed
  files_changed=$(cd "$REPO_ROOT" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"
  local directive_written="false"
  if [ -f "$REPO_ROOT/knowledge_base/agentic-ai/directives/${DATE}.md" ]; then
    directive_written="true"
  fi

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "agentic-ai-research-lead",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "directive_written": $directive_written,
  "effort_level": "${CLAUDE_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling
  check_cost_ceiling "research-lead" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | Directive written: $directive_written" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "research-lead-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "research-lead-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== Research Lead Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
log_session_start "direction"

# Recover any uncommitted changes from a previous crashed session
(recover_uncommitted "$REPO_ROOT" "research-lead-previous" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research Direction Session ---" >> "$LOG_FILE"
log_task_start "direction-session"
(cd "$REPO_ROOT" && timeout 1800 "$CLAUDE" --dangerously-skip-permissions -p "You are the agentic-ai-research-lead. Read .claude/agents/agentic-ai-research-lead.md for your full instructions.

IMPORTANT: You are running UNATTENDED via cron. Today is ${DATE}. You have write permission to knowledge_base/agentic-ai/directives/ and knowledge_base/agentic-ai/proposals/. Do NOT ask for permission — proceed directly.

Execute your full flow:
1. Mandatory orientation: Read CLAUDE.md, ROADMAP.md, knowledge_base/agentic-ai/INDEX.md
2. Phase 1 — Assess: Read the last 3-5 sweep reports, analysis files, discussion transcripts, and proposals from knowledge_base/agentic-ai/
3. Phase 2 — Evaluate: Assess research direction (relevance to pipeline, depth vs breadth, gaps, signal-to-noise)
4. Phase 3 — Set Priorities: Write a research directive to knowledge_base/agentic-ai/directives/${DATE}.md with P0/P1/P2 priority topics, deprioritized topics, new research areas, and quality feedback
5. Phase 4 — Evaluate Team: Consider researcher workload, pipeline bottlenecks, team composition. Write proposals to knowledge_base/agentic-ai/proposals/team-${DATE}.md if changes are needed
6. Phase 5 — Commit: git add knowledge_base/agentic-ai/directives/ knowledge_base/agentic-ai/proposals/ && git commit

Also: Read your own most recent prior directive from knowledge_base/agentic-ai/directives/ (if any). Compare it against the researcher's actual output to evaluate whether your previous direction was followed. Include this assessment in the directive's Research Quality Feedback section.

Focus on actionable, specific direction. Every priority must have a 'why' and 'what specifically to look for'.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Direction session complete" >> "$LOG_FILE"
log_task_complete "direction-session"

(recover_uncommitted "$REPO_ROOT" "direction" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
