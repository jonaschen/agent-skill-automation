#!/bin/bash
# daily_bsp_knowledge_steward_gemini.sh — Cron-triggered daily BSP Knowledge stewardship session (Gemini version)
#
# Runs the bsp-knowledge-steward-gemini agent to complete Phase 3 exit criteria,
# advance Phase 4 deliverables, expand the knowledge graph, and research BSP updates.
#
# Usage: Called by cron, or manually: ./scripts/daily_bsp_knowledge_steward_gemini.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/bsp-knowledge-gemini-${DATE}.log"
PERF_FILE="$PERF_DIR/bsp-knowledge-gemini-${DATE}.json"
GEMINI="/home/jonas/.nvm/versions/node/v24.14.0/bin/gemini"
# Ensure the correct Node version is used for gemini-cli and its dependencies
export PATH="/home/jonas/.nvm/versions/node/v24.14.0/bin:$PATH"
TARGET_REPO="/home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets"

SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
mkdir -p "$LOG_DIR" "$PERF_DIR" "$SECURITY_LOG_DIR"

# Source shared libraries
source "$SCRIPT_DIR/lib/cost_ceiling.sh"
source "$SCRIPT_DIR/lib/check_fleet_version.sh"
source "$SCRIPT_DIR/lib/session_log.sh"

# CVE-2026-35020 mitigation: neutralize TERMINAL env var injection (CVSS 8.4)
unset TERMINAL

# Initiator-type context for post-tool-use.sh policy enforcement
export GEMINI_INITIATOR_TYPE=cron-automated

# Per-agent effort level (discussion 2026-04-09: prepared commented-out, enable if costs spike >50%)
# Routine/mechanical agent → medium effort; uncomment to override default
# export GEMINI_CODE_EFFORT=medium

# Post-session commit recovery: if Gemini wrote files but failed to commit, catch them
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
    git commit -m "steward-gemini(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "bsp-knowledge-gemini" "$REPO_ROOT"

# Capture pre-run state (before trap setup so they're available in finalize)
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_EVAL_COUNT=$(find "$TARGET_REPO/evals/cases" -name "case_*.json" 2>/dev/null | wc -l || echo "0")

# Finalize: write perf JSON and log footer on ANY exit (normal, error, or signal)
finalize() {
  local exit_code=$?
  set +euo pipefail  # ensure cleanup completes even on errors

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local post_eval_count
  post_eval_count=$(find "$TARGET_REPO/evals/cases" -name "case_*.json" 2>/dev/null | wc -l) || post_eval_count="0"
  local files_changed
  files_changed=$(cd "$TARGET_REPO" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$TARGET_REPO" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"
  local graph_nodes
  # Try kuzu query on bsp_base.db (the actual graph); fall back to kuzu_db dir, then 0
  graph_nodes=$(timeout 15 python3 -c "
import kuzu, os, sys
base = '$TARGET_REPO'
candidates = [
    os.path.join(base, 'knowledge-graph', 'base', 'bsp_base.db'),
    os.path.join(base, 'knowledge-graph', 'kuzu_db'),
]
for db_path in candidates:
    if os.path.exists(db_path):
        try:
            db = kuzu.Database(db_path, read_only=True)
            conn = kuzu.Connection(db)
            r = conn.execute('MATCH (n) RETURN count(n) AS cnt')
            if r.has_next():
                print(r.get_next()[0])
                sys.exit(0)
        except Exception as e:
            print(f'kuzu error on {db_path}: {e}', file=sys.stderr)
            continue
print('0')
" 2>>"$LOG_FILE")
  local kuzu_exit=$?
  if [ $kuzu_exit -ne 0 ] || [ -z "$graph_nodes" ] || [ "$graph_nodes" = "0" ]; then
    echo "[WARN] graph_nodes query returned '$graph_nodes' (exit $kuzu_exit) — investigating" >> "$LOG_FILE" 2>/dev/null
    # Retry once with explicit path and verbose error
    graph_nodes=$(timeout 15 python3 -c "
import kuzu, os, sys
db_path = '$TARGET_REPO/knowledge-graph/base/bsp_base.db'
if not os.path.exists(db_path):
    print(f'DB not found: {db_path}', file=sys.stderr)
    print('0'); sys.exit(0)
print(f'DB size: {os.path.getsize(db_path)} bytes', file=sys.stderr)
try:
    db = kuzu.Database(db_path, read_only=True)
    conn = kuzu.Connection(db)
    r = conn.execute('MATCH (n) RETURN count(n) AS cnt')
    if r.has_next():
        print(r.get_next()[0])
    else:
        print('0')
except Exception as e:
    print(f'Retry error: {e}', file=sys.stderr)
    print('0')
" 2>>"$LOG_FILE") || graph_nodes="0"
  fi
  # Sanitize: ensure it's a plain integer (no trailing whitespace/newlines)
  graph_nodes=$(echo "$graph_nodes" | tail -1 | tr -dc '0-9')
  graph_nodes="${graph_nodes:-0}"

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "bsp-knowledge-steward-gemini",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "eval_count_before": ${PRE_EVAL_COUNT:-0},
  "eval_count_after": $post_eval_count,
  "graph_nodes": ${graph_nodes:-0},
  "effort_level": "${GEMINI_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling (advisory — logs warning if exceeded)
  check_cost_ceiling "bsp-knowledge-gemini" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | Eval cases: $post_eval_count | Graph nodes: ${graph_nodes:-0}" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "bsp-knowledge-gemini-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "bsp-knowledge-gemini-*.json" -mtime +30 -delete 2>/dev/null
}
trap finalize EXIT INT TERM HUP

echo "=== BSP Knowledge Steward Session (Gemini) — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$GEMINI" "$LOG_FILE" < /dev/null
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "steward"

# Pre-flight: check target repo for deprecated model references (warning-only, .gemini/ scoped)
echo "" >> "$LOG_FILE"
echo "--- Deprecation Pre-flight Check ---" >> "$LOG_FILE"
if [ -d "$TARGET_REPO/.gemini" ]; then
  bash "$REPO_ROOT/scripts/lib/check_target_deprecations.sh" "$TARGET_REPO" >> "$LOG_FILE" 2>&1 || true
else
  echo "SKIP: No .gemini/ directory in target repo" >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"
echo "--- Phase 3/4 Work ---" >> "$LOG_FILE"
log_task_start "phase-work"
# Run Gemini in a subshell to isolate process-group signals from the parent script
(cd "$TARGET_REPO" && timeout 2400 "$GEMINI" --approval-mode yolo -p "You are the bsp-knowledge-steward agent (Gemini). Read $REPO_ROOT/.gemini/agents/bsp-knowledge-steward.md for your full instructions.

Execute a stewardship session:
1. Orient: Read all four mandatory documents (CLAUDE.md, BSP_KNOWLEDGE_SKILL_SET_DEV_PLAN.md, ROADMAP.md, README.md)
2. **BLOCKING — Read steering notes**: Read $TARGET_REPO/.gemini/steering-notes.md (if it exists). Address ALL P0 items BEFORE any other work. Also check $REPO_ROOT/knowledge_base/steward-reviews/ for the latest review file. Graph quality issues (orphan nodes, disconnected FailureModes) take priority over adding new seed scripts.
3. Assess: Check ROADMAP.md for current status — identify incomplete Phase 3 exit criteria or next Phase 4 deliverable
4. Execute: Close Phase 3 gaps first (blackboard eval, Socratic templates, term dictionary, learner-level tests), then start Phase 4 work
5. Validate: Run pytest tests/test_safety_gate.py and pytest evals/run_evals.py to ensure no regressions
6. Record: Update ROADMAP.md with any completed tasks
7. Commit: Stage all changed files and commit with message 'steward-gemini: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"phase\": \"...\", \"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false}" < /dev/null) >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Phase work session complete" >> "$LOG_FILE"
log_task_complete "phase-work"

(recover_uncommitted "$TARGET_REPO" "phase-work" "$LOG_FILE") || true

echo "" >> "$LOG_FILE"
echo "--- Research & Knowledge Graph Expansion ---" >> "$LOG_FILE"
log_task_start "research"
(cd "$TARGET_REPO" && timeout 2400 "$GEMINI" --approval-mode yolo -p "You are the bsp-knowledge-steward agent (Gemini). Read $REPO_ROOT/.gemini/agents/bsp-knowledge-steward.md for your full instructions.

Run a research session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for latest ARM public TRM releases, Linux kernel power/thermal/interrupt changes, GIC architecture updates, new MIPI/AMBA specs
3. If you find relevant open-source specs, write new seed scripts in knowledge-graph/base/ to expand the base graph (target ≥800 nodes)
4. Add new failure modes to common-failure-modes.py if discovered
5. Add eval cases for any new knowledge added
6. Rebuild the base graph if seed scripts were modified: python scripts/build_base_graph.py
7. Commit: If you made any changes, stage and commit with message 'research-gemini: BSP knowledge updates ($DATE)'

Output a brief summary of findings." < /dev/null) >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Research session complete" >> "$LOG_FILE"
log_task_complete "research"

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
