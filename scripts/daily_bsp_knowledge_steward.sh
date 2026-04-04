#!/bin/bash
# daily_bsp_knowledge_steward.sh — Cron-triggered daily BSP Knowledge stewardship session
#
# Runs the bsp-knowledge-steward agent to complete Phase 3 exit criteria,
# advance Phase 4 deliverables, expand the knowledge graph, and research BSP updates.
#
# Usage: Called by cron, or manually: ./scripts/daily_bsp_knowledge_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/bsp-knowledge-${DATE}.log"
PERF_FILE="$PERF_DIR/bsp-knowledge-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
TARGET_REPO="/home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets"

mkdir -p "$LOG_DIR" "$PERF_DIR"

# Post-session commit recovery: if Claude wrote files but failed to commit, catch them
recover_uncommitted() {
  local repo_dir="$1"
  local session_name="$2"
  local log_file="$3"
  cd "$repo_dir" || return 0
  local dirty
  dirty=$(git status --porcelain 2>/dev/null | grep -v '^??' | head -1)
  if [ -n "$dirty" ]; then
    echo "[RECOVERY] $session_name left uncommitted changes — auto-committing" >> "$log_file"
    git status --short >> "$log_file" 2>&1
    git add -A >> "$log_file" 2>&1
    git commit -m "steward(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
echo "=== BSP Knowledge Steward Session — $DATE ===" >> "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Capture pre-run state
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_EVAL_COUNT=$(find "$TARGET_REPO/evals/cases" -name "case_*.json" 2>/dev/null | wc -l || echo "0")

echo "" >> "$LOG_FILE"
echo "--- Phase 3/4 Work ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the bsp-knowledge-steward agent. Read $REPO_ROOT/.claude/agents/bsp-knowledge-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents (CLAUDE.md, BSP_KNOWLEDGE_SKILL_SET_DEV_PLAN.md, ROADMAP.md, README.md)
2. Assess: Check ROADMAP.md for current status — identify incomplete Phase 3 exit criteria or next Phase 4 deliverable
3. Execute: Close Phase 3 gaps first (blackboard eval, Socratic templates, term dictionary, learner-level tests), then start Phase 4 work
4. Validate: Run pytest tests/test_safety_gate.py and pytest evals/run_evals.py to ensure no regressions
5. Record: Update ROADMAP.md with any completed tasks
6. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"phase\": \"...\", \"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false}" >> "$LOG_FILE" 2>&1 || true

recover_uncommitted "$TARGET_REPO" "phase-work" "$LOG_FILE"

echo "" >> "$LOG_FILE"
echo "--- Research & Knowledge Graph Expansion ---" >> "$LOG_FILE"
cd "$TARGET_REPO" && "$CLAUDE" --dangerously-skip-permissions -p "You are the bsp-knowledge-steward agent. Read $REPO_ROOT/.claude/agents/bsp-knowledge-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest ARM public TRM releases, Linux kernel power/thermal/interrupt changes, GIC architecture updates, new MIPI/AMBA specs
3. If you find relevant open-source specs, write new seed scripts in knowledge-graph/base/ to expand the base graph (target ≥800 nodes)
4. Add new failure modes to common-failure-modes.py if discovered
5. Add eval cases for any new knowledge added
6. Rebuild the base graph if seed scripts were modified: python scripts/build_base_graph.py
7. Commit: If you made any changes, stage and commit with message 'research: BSP knowledge updates ($DATE)'

Output a brief summary of findings." >> "$LOG_FILE" 2>&1 || true

recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE"

# Capture post-run state
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
POST_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
POST_EVAL_COUNT=$(find "$TARGET_REPO/evals/cases" -name "case_*.json" 2>/dev/null | wc -l || echo "0")
FILES_CHANGED=$(cd "$TARGET_REPO" && git diff --name-only "$PRE_COMMIT" HEAD 2>/dev/null | wc -l || echo "0")
COMMITS_MADE=$(cd "$TARGET_REPO" && git rev-list "$PRE_COMMIT"..HEAD 2>/dev/null | wc -l || echo "0")
GRAPH_NODES=$(cd "$TARGET_REPO" && python3 -c "
import kuzu, os
db = kuzu.Database(os.path.join('knowledge-graph', 'kuzu_db'))
conn = kuzu.Connection(db)
r = conn.execute('MATCH (n) RETURN count(n) AS cnt')
while r.has_next(): print(r.get_next()[0])
" 2>/dev/null || echo "0")

# Write performance record
cat > "$PERF_FILE" << EOF
{
  "agent": "bsp-knowledge-steward",
  "date": "$DATE",
  "duration_seconds": $DURATION,
  "pre_commit": "$PRE_COMMIT",
  "post_commit": "$POST_COMMIT",
  "commits_made": $COMMITS_MADE,
  "files_changed": $FILES_CHANGED,
  "eval_count_before": $PRE_EVAL_COUNT,
  "eval_count_after": $POST_EVAL_COUNT,
  "graph_nodes": $GRAPH_NODES,
  "exit_code": 0
}
EOF

echo "" >> "$LOG_FILE"
echo "Finished: $(date)" >> "$LOG_FILE"
echo "Duration: ${DURATION}s | Commits: $COMMITS_MADE | Files changed: $FILES_CHANGED | Eval cases: $POST_EVAL_COUNT | Graph nodes: $GRAPH_NODES" >> "$LOG_FILE"

# Keep only last 30 days of logs
find "$LOG_DIR" -name "bsp-knowledge-*.log" -mtime +30 -delete 2>/dev/null || true
find "$PERF_DIR" -name "bsp-knowledge-*.json" -mtime +30 -delete 2>/dev/null || true

exit 0
