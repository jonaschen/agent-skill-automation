#!/bin/bash
# daily_ltc_steward.sh — Cron-triggered daily long-term-care-expert stewardship session
#
# Runs the ltc-steward agent to advance ROADMAP phases, run evaluations,
# maintain compliance, and research elderly care topics.
#
# Usage: Called by cron, or manually: ./scripts/daily_ltc_steward.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/ltc-${DATE}.log"
PERF_FILE="$PERF_DIR/ltc-${DATE}.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
TARGET_REPO="/home/jonas/gemini-home/long-term-care-expert"

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

# Post-session commit recovery: if Claude wrote files but failed to commit, catch them
recover_uncommitted() {
  local repo_dir="$1"
  local session_name="$2"
  local log_file="$3"
  cd "$repo_dir" || return 0
  local dirty
  dirty=$(git status --porcelain 2>/dev/null | head -1 || true)
  if [ -n "$dirty" ]; then
    echo "[RECOVERY] $session_name left uncommitted changes — auto-committing" >> "$log_file"
    git status --short >> "$log_file" 2>&1
    git add -A >> "$log_file" 2>&1
    git commit -m "steward(auto): $session_name uncommitted work ($DATE)" >> "$log_file" 2>&1 || true
  fi
}

START_TIME=$(date +%s)
init_session_log "ltc" "$REPO_ROOT"

# Capture pre-run state
PRE_COMMIT=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null || echo "unknown")
PRE_TEST_COUNT=$(cd "$TARGET_REPO" && find tests/ -name "*.json" -path "*/test_cases/*" 2>/dev/null | wc -l || echo "0")

# Finalize: write perf JSON and log footer on ANY exit
finalize() {
  local exit_code=$?
  set +euo pipefail

  # Kill watchdog if still running
  if [ -n "${WATCHDOG_PID:-}" ]; then
    kill "$WATCHDOG_PID" 2>/dev/null || true
  fi

  local end_time=$(date +%s)
  local duration=$((end_time - ${START_TIME:-$end_time}))
  local post_commit
  post_commit=$(cd "$TARGET_REPO" && git rev-parse HEAD 2>/dev/null) || post_commit="unknown"
  local post_test_count
  post_test_count=$(cd "$TARGET_REPO" && find tests/ -name "*.json" -path "*/test_cases/*" 2>/dev/null | wc -l) || post_test_count="0"
  local files_changed
  files_changed=$(cd "$TARGET_REPO" && git diff --name-only "${PRE_COMMIT:-unknown}" HEAD 2>/dev/null | wc -l) || files_changed="0"
  local commits_made
  commits_made=$(cd "$TARGET_REPO" && git rev-list "${PRE_COMMIT:-unknown}"..HEAD 2>/dev/null | wc -l) || commits_made="0"

  # Count compliance violations if scanner exists
  local compliance_violations="n/a"
  if [ -f "$TARGET_REPO/tests/compliance_tests/blacklist_scanner.py" ]; then
    compliance_violations=$(cd "$TARGET_REPO" && .venv/bin/python3 tests/compliance_tests/blacklist_scanner.py --scan-dir skills/ --json-output 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('total_violations',0))" 2>/dev/null) || compliance_violations="n/a"
  fi

  cat > "$PERF_FILE" << PERF_EOF
{
  "agent": "ltc-steward",
  "date": "$DATE",
  "duration_seconds": $duration,
  "pre_commit": "${PRE_COMMIT:-unknown}",
  "post_commit": "$post_commit",
  "commits_made": $commits_made,
  "files_changed": $files_changed,
  "test_count_before": ${PRE_TEST_COUNT:-0},
  "test_count_after": $post_test_count,
  "compliance_violations": "$compliance_violations",
  "effort_level": "${CLAUDE_CODE_EFFORT:-default}",
  "thinking_mode": "default",
  "exit_code": $exit_code
}
PERF_EOF

  log_session_end "$exit_code" "$duration"

  # Check duration against cost ceiling
  check_cost_ceiling "ltc" "$duration" "$PERF_DIR" "$SECURITY_LOG_DIR" 2>> "$LOG_FILE" || true

  echo "" >> "$LOG_FILE" 2>/dev/null
  echo "Finished: $(date)" >> "$LOG_FILE" 2>/dev/null
  echo "Duration: ${duration}s | Commits: $commits_made | Files changed: $files_changed | Compliance: $compliance_violations violations" >> "$LOG_FILE" 2>/dev/null

  find "$LOG_DIR" -name "ltc-*.log" -mtime +30 -delete 2>/dev/null
  find "$PERF_DIR" -name "ltc-*.json" -mtime +30 -delete 2>/dev/null
}

# Start incremental watchdog
WATCHDOG_PID=$(start_incremental_watchdog "ltc" "$$" "$PERF_DIR" "$SECURITY_LOG_DIR")
echo "[$(date)] Started cost watchdog (PID: $WATCHDOG_PID)" >> "$LOG_FILE"

trap finalize EXIT INT TERM HUP

echo "=== LTC Steward Session — $DATE ===" >> "$LOG_FILE"
check_fleet_version "$CLAUDE" "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"
log_session_start "steward"

# Pre-flight: check target repo for deprecated model references
echo "" >> "$LOG_FILE"
echo "--- Deprecation Pre-flight Check ---" >> "$LOG_FILE"
if [ -d "$TARGET_REPO/.claude" ]; then
  bash "$REPO_ROOT/scripts/lib/check_target_deprecations.sh" "$TARGET_REPO" >> "$LOG_FILE" 2>&1 || true
else
  echo "SKIP: No .claude/ directory in target repo" >> "$LOG_FILE"
fi

echo "" >> "$LOG_FILE"
echo "--- Phase Work ---" >> "$LOG_FILE"
log_task_start "phase-work"
watchdog_pulse "$WATCHDOG_PID"
PHASE_WORK_START=$(date +%s)
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the steward agent for the 'ltc' project. Read $REPO_ROOT/.claude/skills/steward/SKILL.md for the shared execution flow, then read $REPO_ROOT/.claude/skills/steward/configs/ltc.yaml for project-specific configuration.

Execute a stewardship session:
1. Orient: Read ALL mandatory documents (CLAUDE.md, ROADMAP.md, LONGTERM_CARE_EXPERT_DEV_PLAN.md, DIGITAL_SURROGATE_AGILE_POC.md, HANA_CHARACTER_SPEC.md, SAYO_PREFERENCE_SYSTEM.md, .claude/steering-notes.md if it exists)
2. **BLOCKING — Read steering notes**: Read $TARGET_REPO/.claude/steering-notes.md (if it exists). Address ALL P0 items BEFORE any other work. Also check $REPO_ROOT/knowledge_base/steward-reviews/ for the latest review file.
3. Assess: Check ROADMAP.md for current status across all phases, identify the highest-priority incomplete item per the priority tiers in your agent definition
4. Execute: Work on the highest-priority item. Follow TDD workflow for any new code. Run compliance scanner after any output-generating changes.
5. Validate: Run existing tests to ensure no regressions (.venv/bin/python3 -m pytest tests/ or specific test files)
6. Record: Update ROADMAP.md with any completed tasks
7. Commit: Stage all changed files and commit with message 'steward: <summary of work> ($DATE)'

Keep your work focused — aim to complete one deliverable or make substantial progress on one.
At the end, output a brief JSON summary: {\"deliverable\": \"...\", \"status\": \"...\", \"files_changed\": [...], \"tests_passed\": true/false, \"compliance_violations\": 0}") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Phase work session complete" >> "$LOG_FILE"
log_task_complete "phase-work"
PHASE_WORK_DURATION=$(( $(date +%s) - PHASE_WORK_START ))

(recover_uncommitted "$TARGET_REPO" "phase-work" "$LOG_FILE") || true

# Rate limit guard: if phase-work finished in < 60s it likely hit a rate limit or
# API key error. Skip the research session to avoid burning quota on a second 13s run.
echo "" >> "$LOG_FILE"
echo "--- Research & Quality Check ---" >> "$LOG_FILE"
if [ "$PHASE_WORK_DURATION" -lt 60 ]; then
  echo "[SKIP] Phase-work duration ${PHASE_WORK_DURATION}s < 60s — likely rate-limited or API key invalid." >> "$LOG_FILE"
  echo "[SKIP] Skipping research session to avoid burning quota. Human action required: check ANTHROPIC_API_KEY in $TARGET_REPO/.env" >> "$LOG_FILE"
  log_task_complete "research"
  exit 0
fi
log_task_start "research"
watchdog_pulse "$WATCHDOG_PID"
(cd "$TARGET_REPO" && timeout 2400 "$CLAUDE" --dangerously-skip-permissions -p "You are the steward agent for the 'ltc' project. Read $REPO_ROOT/.claude/skills/steward/SKILL.md for the shared execution flow, then read $REPO_ROOT/.claude/skills/steward/configs/ltc.yaml for project-specific configuration.

Run a research and quality session:
1. Orient: Read ROADMAP.md and CLAUDE.md
2. Research: WebSearch for relevant updates — Taiwan HPA elderly care guidelines, Google Gemini Live API changes, LINE Messaging API updates, dementia care best practices
3. Quality: If time permits, run compliance scanner on skills/ directory and report any violations
4. If you find relevant updates, create notes in reports/ or update knowledge base chunks as appropriate
5. Commit: If you made any changes, stage and commit with message 'research: <topic> ($DATE)'

Output a brief summary of findings.") >> "$LOG_FILE" 2>&1 || true
echo "[$(date)] Research session complete" >> "$LOG_FILE"
log_task_complete "research"

(recover_uncommitted "$TARGET_REPO" "research" "$LOG_FILE") || true

# Performance JSON, log footer, and cleanup handled by finalize() trap
exit 0
