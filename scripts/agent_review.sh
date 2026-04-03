#!/bin/bash
# agent_review.sh — Review dashboard for all three daily agents
#
# Summarizes recent performance of:
#   1. agentic-ai-researcher (2am daily)
#   2. android-sw-steward (3am daily)
#   3. arm-mrs-steward (4am daily)
#
# Usage:
#   ./scripts/agent_review.sh              # Last 7 days (default)
#   ./scripts/agent_review.sh 14           # Last 14 days
#   ./scripts/agent_review.sh 1            # Today only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DAYS=${1:-7}

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BOLD}=========================================${RESET}"
echo -e "${BOLD}  Agent Performance Review (last ${DAYS} days)${RESET}"
echo -e "${BOLD}=========================================${RESET}"
echo ""

# Helper: print agent section
print_agent_section() {
    local AGENT_NAME="$1"
    local AGENT_LABEL="$2"
    local LOG_PREFIX="$3"
    local PERF_PREFIX="$4"
    local SCHEDULE="$5"

    echo -e "${CYAN}--- ${AGENT_LABEL} (${SCHEDULE}) ---${RESET}"
    echo ""

    # Count runs in the period
    local RUN_COUNT=0
    local TOTAL_DURATION=0
    local SUCCESS_COUNT=0
    local LATEST_DATE=""
    local LATEST_DURATION=0

    for i in $(seq 0 $((DAYS - 1))); do
        local CHECK_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
        local PERF_FILE="$PERF_DIR/${PERF_PREFIX}-${CHECK_DATE}.json"

        if [ -f "$PERF_FILE" ]; then
            RUN_COUNT=$((RUN_COUNT + 1))
            if [ -z "$LATEST_DATE" ]; then
                LATEST_DATE="$CHECK_DATE"
            fi

            # Parse JSON (stdlib-only, no jq dependency)
            local DURATION=$(grep -oP '"duration_seconds"\s*:\s*\K\d+' "$PERF_FILE" 2>/dev/null || echo "0")
            local EXIT_CODE=$(grep -oP '"exit_code"\s*:\s*\K\d+' "$PERF_FILE" 2>/dev/null || echo "1")

            TOTAL_DURATION=$((TOTAL_DURATION + DURATION))
            LATEST_DURATION=$DURATION

            if [ "$EXIT_CODE" -eq 0 ]; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            fi
        fi
    done

    if [ "$RUN_COUNT" -eq 0 ]; then
        echo -e "  ${YELLOW}No runs found in the last ${DAYS} days${RESET}"
        echo ""
        return
    fi

    local AVG_DURATION=$((TOTAL_DURATION / RUN_COUNT))
    local SUCCESS_RATE=$((SUCCESS_COUNT * 100 / RUN_COUNT))

    # Color the success rate
    local RATE_COLOR="$GREEN"
    if [ "$SUCCESS_RATE" -lt 80 ]; then
        RATE_COLOR="$RED"
    elif [ "$SUCCESS_RATE" -lt 100 ]; then
        RATE_COLOR="$YELLOW"
    fi

    echo "  Runs:         $RUN_COUNT / $DAYS days"
    echo -e "  Success rate: ${RATE_COLOR}${SUCCESS_RATE}%${RESET} ($SUCCESS_COUNT/$RUN_COUNT)"
    echo "  Avg duration: $((AVG_DURATION / 60))m $((AVG_DURATION % 60))s"
    echo "  Last run:     $LATEST_DATE ($((LATEST_DURATION / 60))m $((LATEST_DURATION % 60))s)"

    # Agent-specific metrics from latest perf file
    local LATEST_PERF="$PERF_DIR/${PERF_PREFIX}-${LATEST_DATE}.json"
    if [ -f "$LATEST_PERF" ]; then
        case "$AGENT_NAME" in
            researcher)
                local KB_FILES=$(grep -oP '"kb_files_updated"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last KB updates: $KB_FILES files"
                ;;
            android-sw)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local TESTS=$(grep -oP '"test_count_after"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | Test cases: $TESTS"
                ;;
            arm-mrs)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local EVAL=$(grep -oP '"eval_count_after"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | Eval tests: $EVAL"
                ;;
        esac
    fi

    # Show last log tail
    local LATEST_LOG="$LOG_DIR/${LOG_PREFIX}-${LATEST_DATE}.log"
    if [ -f "$LATEST_LOG" ]; then
        echo ""
        echo "  Latest log tail:"
        tail -5 "$LATEST_LOG" | sed 's/^/    /'
    fi

    echo ""
}

# Print each agent section
print_agent_section "researcher" "Agentic AI Researcher" "sweep" "researcher" "2:00 AM"
print_agent_section "android-sw" "Android-SW Steward" "android-sw" "android-sw" "3:00 AM"
print_agent_section "arm-mrs" "ARM MRS Steward" "arm-mrs" "arm-mrs" "4:00 AM"

# Summary table
echo -e "${BOLD}--- Weekly Summary ---${RESET}"
echo ""

# Count total perf files
TOTAL_RUNS=$(find "$PERF_DIR" -name "*.json" -newer "$PERF_DIR" -mtime -"$DAYS" 2>/dev/null | wc -l || echo "0")
# Simpler: just count all json files from the period
TOTAL_RUNS=0
for i in $(seq 0 $((DAYS - 1))); do
    CHECK_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
    for PREFIX in researcher android-sw arm-mrs; do
        [ -f "$PERF_DIR/${PREFIX}-${CHECK_DATE}.json" ] && TOTAL_RUNS=$((TOTAL_RUNS + 1))
    done
done

echo "  Total agent runs: $TOTAL_RUNS (across all 3 agents, last $DAYS days)"
echo "  Expected runs:    $((DAYS * 3))"
echo ""

# Check git activity in target repos
echo -e "${BOLD}--- Git Activity ---${RESET}"
echo ""

for REPO_PATH in "/home/jonas/gemini-home/Android-Software" "/home/jonas/arm-mrs-2025-03-aarchmrs" "/home/jonas/gemini-home/agent-skill-automation"; do
    REPO_NAME=$(basename "$REPO_PATH")
    COMMIT_COUNT=$(cd "$REPO_PATH" && git rev-list --after="$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d)" HEAD 2>/dev/null | wc -l || echo "?")
    echo "  $REPO_NAME: $COMMIT_COUNT commits in last $DAYS days"
done

echo ""
echo -e "${BOLD}=========================================${RESET}"
echo "  Run ./scripts/agent_review.sh 30 for monthly view"
echo -e "${BOLD}=========================================${RESET}"
