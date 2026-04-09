#!/bin/bash
# effort_impact_analysis.sh — Analyze effort level impact on agent durations
#
# Compares agent durations before and after the Claude Code v2.1.94 effort
# default change (medium→high). Uses performance JSON data to determine
# whether to enable per-agent effort level overrides.
#
# Decision criteria (from 2026-04-09 discussion):
#   - If duration increases >50% for any agent: recommend enabling medium effort
#   - If cost_ceiling.sh alerts fired: recommend enabling medium effort
#   - If quality improved (more commits, fewer failures): accept cost increase
#
# Usage:
#   ./scripts/effort_impact_analysis.sh              # Analyze all data
#   ./scripts/effort_impact_analysis.sh --since 2026-04-09  # From specific date

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PERF_DIR="$REPO_ROOT/logs/performance"
SECURITY_DIR="$REPO_ROOT/logs/security"

# Parse arguments
SINCE_DATE=""
if [ "${1:-}" = "--since" ] && [ -n "${2:-}" ]; then
  SINCE_DATE="$2"
fi

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BOLD}================================================${RESET}"
echo -e "${BOLD}  Effort Level Impact Analysis${RESET}"
echo -e "${BOLD}================================================${RESET}"
echo ""

# Define agents and their expected effort classification
declare -A AGENT_CLASS
AGENT_CLASS[factory]="reasoning-heavy"
AGENT_CLASS[researcher]="reasoning-heavy"
AGENT_CLASS[reviewer]="reasoning-heavy"
AGENT_CLASS[android-sw]="routine"
AGENT_CLASS[arm-mrs]="routine"
AGENT_CLASS[bsp-knowledge]="routine"

# Collect duration data per agent
analyze_agent() {
  local agent="$1"
  local class="${AGENT_CLASS[$agent]}"
  local prefix="$agent"

  echo -e "${CYAN}--- $agent ($class) ---${RESET}"

  # Collect all perf files, sorted by date
  local perf_files
  perf_files=$(ls "$PERF_DIR/${prefix}"-*.json 2>/dev/null | sort)

  if [ -z "$perf_files" ]; then
    echo "  No performance data available"
    echo ""
    return
  fi

  # Split into before/after based on effort_level field presence
  local before_durations=()
  local after_durations=()
  local before_count=0
  local after_count=0
  local total_before=0
  local total_after=0

  while IFS= read -r pf; do
    local date_str
    date_str=$(python3 -c "import json; print(json.load(open('$pf'))['date'])" 2>/dev/null) || continue

    # Skip if before --since date
    if [ -n "$SINCE_DATE" ] && [[ "$date_str" < "$SINCE_DATE" ]]; then
      continue
    fi

    local duration
    duration=$(python3 -c "import json; print(json.load(open('$pf'))['duration_seconds'])" 2>/dev/null) || continue
    local effort
    effort=$(python3 -c "import json; print(json.load(open('$pf')).get('effort_level', 'untracked'))" 2>/dev/null) || effort="untracked"
    local exit_code
    exit_code=$(python3 -c "import json; print(json.load(open('$pf')).get('exit_code', 0))" 2>/dev/null) || exit_code="0"

    if [ "$effort" = "untracked" ]; then
      before_durations+=("$duration")
      before_count=$((before_count + 1))
      total_before=$((total_before + duration))
    else
      after_durations+=("$duration")
      after_count=$((after_count + 1))
      total_after=$((total_after + duration))
    fi
  done <<< "$perf_files"

  # Report
  if [ "$before_count" -gt 0 ]; then
    local avg_before=$((total_before / before_count))
    echo "  Before tracking ($before_count runs): avg ${avg_before}s ($(( avg_before / 60 ))m $(( avg_before % 60 ))s)"
  else
    echo "  Before tracking: no data"
  fi

  if [ "$after_count" -gt 0 ]; then
    local avg_after=$((total_after / after_count))
    echo "  After tracking  ($after_count runs):  avg ${avg_after}s ($(( avg_after / 60 ))m $(( avg_after % 60 ))s)"

    # Compare if we have both
    if [ "$before_count" -gt 0 ] && [ "$avg_before" -gt 0 ]; then
      local pct_change=$(( (avg_after - avg_before) * 100 / avg_before ))
      if [ "$pct_change" -gt 50 ]; then
        echo -e "  Change: ${RED}+${pct_change}% (EXCEEDS 50% THRESHOLD)${RESET}"
        echo -e "  ${RED}RECOMMEND: Enable 'export CLAUDE_CODE_EFFORT=medium' for $agent${RESET}"
      elif [ "$pct_change" -gt 20 ]; then
        echo -e "  Change: ${YELLOW}+${pct_change}% (elevated, monitoring)${RESET}"
      elif [ "$pct_change" -lt -10 ]; then
        echo -e "  Change: ${GREEN}${pct_change}% (improved)${RESET}"
      else
        echo -e "  Change: ${GREEN}${pct_change}% (stable)${RESET}"
      fi
    fi
  else
    echo "  After tracking:  no data yet (next runs will capture)"
  fi

  echo ""
}

# Analyze each agent
for agent in factory researcher android-sw arm-mrs bsp-knowledge reviewer; do
  analyze_agent "$agent"
done

# Check for cost ceiling alerts
echo -e "${BOLD}--- Cost Ceiling Alerts ---${RESET}"
if [ -f "$SECURITY_DIR/cost_alert.jsonl" ]; then
  alert_count=$(wc -l < "$SECURITY_DIR/cost_alert.jsonl")
  echo -e "  ${RED}$alert_count cost ceiling alert(s) found!${RESET}"
  echo "  Latest alerts:"
  tail -3 "$SECURITY_DIR/cost_alert.jsonl" | python3 -c "
import sys, json
for line in sys.stdin:
    try:
        d = json.loads(line)
        print(f\"    {d.get('timestamp','?')} | {d.get('agent','?')} | duration={d.get('duration','?')}s | ceiling={d.get('ceiling','?')}s\")
    except: pass
" 2>/dev/null || cat "$SECURITY_DIR/cost_alert.jsonl" | tail -3
else
  echo -e "  ${GREEN}No cost ceiling alerts found${RESET}"
fi
echo ""

# Summary recommendation
echo -e "${BOLD}--- Recommendation ---${RESET}"
echo ""
echo "  Monitoring window: 2026-04-09 to 2026-04-12 (3 days)"
echo "  Data available: check again after April 12 for full dataset"
echo ""
echo "  To enable effort overrides:"
echo "    Uncomment 'export CLAUDE_CODE_EFFORT=medium' in:"
echo "    - scripts/daily_android_sw_steward.sh"
echo "    - scripts/daily_arm_mrs_steward.sh"
echo "    - scripts/daily_bsp_knowledge_steward.sh"
echo ""
echo -e "${BOLD}================================================${RESET}"
