#!/bin/bash
# paper_pipeline.sh — Run the paper research pipeline (experiment-designer + paper-synthesizer)
#
# Runs experiment analysis, then paper writing for the S2 multi-agent orchestration paper.
# NOT a daily cron job — run on-demand or weekly until the paper is complete.
#
# Usage: ./scripts/paper_pipeline.sh [phase]
#   phase 1 (default): experiment analysis + paper writing (independent work)
#   phase 2: + peer review of Gemini's candidate

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/paper-${DATE}.log"
PERF_FILE="$PERF_DIR/paper-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
PHASE="${1:-1}"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation
unset TERMINAL

export CLAUDE_INITIATOR_TYPE=manual

# Post-session commit recovery
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
    git commit -m "paper(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "paper" "$REPO_ROOT"
PRE_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

# Finalize: write perf JSON and log footer on ANY exit
finalize() {
  local exit_code=$?
  set +euo pipefail

  recover_uncommitted "$REPO_ROOT" "paper-pipeline" "$LOG_FILE"

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local paper_files
  paper_files=$(find "$REPO_ROOT/knowledge_base/agentic-ai/papers" -name "*.md" -newermt "@${START_TIME}" 2>/dev/null | wc -l) || paper_files="0"
  local experiment_files
  experiment_files=$(find "$REPO_ROOT/knowledge_base/agentic-ai/experiments" -name "*.md" -o -name "*.json" -newermt "@${START_TIME}" 2>/dev/null | wc -l) || experiment_files="0"
  local commit
  commit=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null) || commit="unknown"
  local commits_made
  commits_made=$(cd "$REPO_ROOT" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "paper-pipeline",
  "date": "$DATE",
  "phase": $PHASE,
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "commit": "$commit",
  "commits_made": $commits_made,
  "paper_files_updated": $paper_files,
  "experiment_files_updated": $experiment_files,
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  check_cost_ceiling "paper" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Paper files: $paper_files | Experiment files: $experiment_files | Commits: $commits_made | Exit: $exit_code" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "paper-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "paper-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== Paper Pipeline — Phase $PHASE — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "paper-pipeline-phase-$PHASE"

cd "$REPO_ROOT"

# --- Step 1: Experiment Designer ---
echo "" >> "$LOG_FILE"
echo "--- Experiment Designer ---" >> "$LOG_FILE"
log_task_start "experiment-designer"
("$CLAUDE" --dangerously-skip-permissions -p "You are the experiment-designer agent. Read .claude/agents/experiment-designer.md for your full instructions.

Your task for this session:
1. Read all experiment protocols in knowledge_base/agentic-ai/experiments/
2. Extract data from logs/performance/*.json into structured datasets
3. Parse discussion transcripts in knowledge_base/agentic-ai/discussions/ for ADOPT/DEFER/REJECT metrics
4. Run statistical analysis (descriptive stats, trends, efficiency metrics)
5. Write results to experiments/*/results/ and papers/s2-multi-agent-orchestration/data/
6. Generate figure source data in papers/s2-multi-agent-orchestration/figures/

Focus on Experiments 1 (Topology Comparison) and 2 (Debate Effectiveness) — Experiment 3 runs in Phase 2.
Git commit your results with message 'paper: experiment analysis $DATE'.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Experiment designer complete" >> "$LOG_FILE"
log_task_complete "experiment-designer"

recover_uncommitted "$REPO_ROOT" "experiment-designer" "$LOG_FILE"

# --- Step 2: Paper Synthesizer ---
echo "" >> "$LOG_FILE"
echo "--- Paper Synthesizer ---" >> "$LOG_FILE"
log_task_start "paper-synthesizer"
("$CLAUDE" --dangerously-skip-permissions -p "You are the paper-synthesizer agent. Read .claude/agents/paper-synthesizer.md for your full instructions.

Your task for this session:
1. Read the paper project README at knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/README.md
2. Read experimental results from experiments/*/results/ and papers/.../data/
3. Read the knowledge base (anthropic/, google-deepmind/, cross-cutting/, analysis/, discussions/)
4. Read CLAUDE.md and ROADMAP.md for system design material
5. Write or update the paper draft at knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/claude-candidate/paper.md
6. Conduct literature review — search arxiv for relevant multi-agent systems papers
7. Write literature notes to papers/.../literature/

Write ALL sections except Abstract (write that last, in a future session once results are finalized).
Git commit your draft with message 'paper: claude candidate draft $DATE'.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Paper synthesizer complete" >> "$LOG_FILE"
log_task_complete "paper-synthesizer"

recover_uncommitted "$REPO_ROOT" "paper-synthesizer" "$LOG_FILE"

# --- Step 3: Peer Review (Phase 2 only) ---
if [ "$PHASE" -ge 2 ]; then
  echo "" >> "$LOG_FILE"
  echo "--- Peer Review (Gemini candidate) ---" >> "$LOG_FILE"
  log_task_start "peer-reviewer"

  # Check if Gemini candidate exists
  GEMINI_PAPER="$REPO_ROOT/knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/gemini-candidate/paper.md"
  if [ -f "$GEMINI_PAPER" ]; then
    ("$CLAUDE" --dangerously-skip-permissions -p "You are the peer-reviewer agent. Read .claude/agents/peer-reviewer.md for your full instructions.

Your task: Review the Gemini team's paper candidate.
1. Read the paper at knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/gemini-candidate/paper.md
2. Read the paper project README for context
3. Spot-check claims against actual data in logs/performance/ and knowledge_base/
4. Write your review to knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/reviews/claude-reviews-gemini.md
5. Git commit with message 'paper: peer review of gemini candidate $DATE'") >> "$LOG_FILE" 2>&1 || true
    echo "[$(date)] Peer review complete" >> "$LOG_FILE"
  else
    echo "[$(date)] Gemini candidate not found at $GEMINI_PAPER — skipping peer review" >> "$LOG_FILE"
  fi
  log_task_complete "peer-reviewer"
fi

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
