#!/bin/bash
# agent_review.sh — Review dashboard for all daily agents
#
# Summarizes recent performance of active agents:
#   1. agentic-ai-researcher (1am + 2pm daily)
#   2. agentic-ai-research-lead (2am + 3pm daily)
#   3. factory-steward (3am + 6pm daily)
#   4. ltc-steward (8am daily)
# Also shows historical data for suspended agents if present.
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

    # Count runs in the period (check both perf JSON and log files)
    local RUN_COUNT=0
    local TOTAL_DURATION=0
    local SUCCESS_COUNT=0
    local LATEST_DATE=""
    local LATEST_DURATION=0
    local LOG_ONLY_COUNT=0

    for i in $(seq 0 $((DAYS - 1))); do
        local CHECK_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
        local PERF_FILE="$PERF_DIR/${PERF_PREFIX}-${CHECK_DATE}.json"
        local PERF_FILE_PM="$PERF_DIR/${PERF_PREFIX}-${CHECK_DATE}-afternoon.json"
        local CHECK_LOG="$LOG_DIR/${LOG_PREFIX}-${CHECK_DATE}.log"

        # Check both morning and afternoon perf files
        for pf in "$PERF_FILE" "$PERF_FILE_PM"; do
            if [ -f "$pf" ]; then
                RUN_COUNT=$((RUN_COUNT + 1))
                if [ -z "$LATEST_DATE" ]; then
                    LATEST_DATE="$CHECK_DATE"
                fi

                local DURATION=$(grep -oP '"duration_seconds"\s*:\s*\K\d+' "$pf" 2>/dev/null || echo "0")
                local EXIT_CODE=$(grep -oP '"exit_code"\s*:\s*\K\d+' "$pf" 2>/dev/null || echo "1")

                TOTAL_DURATION=$((TOTAL_DURATION + DURATION))
                LATEST_DURATION=$DURATION

                if [ "$EXIT_CODE" -eq 0 ]; then
                    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                fi
            fi
        done

        if [ ! -f "$PERF_FILE" ] && [ ! -f "$PERF_FILE_PM" ] && [ -f "$CHECK_LOG" ]; then
            # Log exists but no perf JSON — script ran but crashed before writing metrics
            LOG_ONLY_COUNT=$((LOG_ONLY_COUNT + 1))
            if [ -z "$LATEST_DATE" ]; then
                LATEST_DATE="$CHECK_DATE"
            fi
        fi
    done

    if [ "$RUN_COUNT" -eq 0 ] && [ "$LOG_ONLY_COUNT" -eq 0 ]; then
        echo -e "  ${YELLOW}No runs found in the last ${DAYS} days${RESET}"
        echo ""
        return
    fi

    if [ "$RUN_COUNT" -eq 0 ]; then
        # Only log-based runs detected
        echo -e "  Runs:         ${YELLOW}${LOG_ONLY_COUNT} (log only, no perf data — script crashed before metrics)${RESET}"
        local LATEST_LOG="$LOG_DIR/${LOG_PREFIX}-${LATEST_DATE}.log"
        if [ -f "$LATEST_LOG" ]; then
            echo "  Last log:     $LATEST_DATE"
            echo ""
            echo "  Latest log tail:"
            tail -5 "$LATEST_LOG" | sed 's/^/    /'
        fi
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

    local RUN_SUMMARY="$RUN_COUNT / $DAYS days"
    if [ "$LOG_ONLY_COUNT" -gt 0 ]; then
        RUN_SUMMARY="$RUN_COUNT / $DAYS days (+ $LOG_ONLY_COUNT log-only, no perf data)"
    fi
    echo "  Runs:         $RUN_SUMMARY"

    # For multi-run agents, count total sessions from session logs
    local SESSION_DIR="$LOG_DIR/sessions"
    local TOTAL_SESSIONS=0
    for i in $(seq 0 $((DAYS - 1))); do
        local SESS_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
        local SESS_FILE="$SESSION_DIR/${PERF_PREFIX}-${SESS_DATE}.jsonl"
        if [ -f "$SESS_FILE" ]; then
            local DAY_SESSIONS=$(grep -c '"SESSION_START"' "$SESS_FILE" 2>/dev/null || echo "0")
            TOTAL_SESSIONS=$((TOTAL_SESSIONS + DAY_SESSIONS))
        fi
    done
    if [ "$TOTAL_SESSIONS" -gt "$RUN_COUNT" ]; then
        echo "  Sessions:     $TOTAL_SESSIONS total (across $RUN_COUNT days with data)"
    fi

    echo -e "  Success rate: ${RATE_COLOR}${SUCCESS_RATE}%${RESET} ($SUCCESS_COUNT/$RUN_COUNT)"
    echo "  Avg duration: $((AVG_DURATION / 60))m $((AVG_DURATION % 60))s"
    echo "  Last run:     $LATEST_DATE ($((LATEST_DURATION / 60))m $((LATEST_DURATION % 60))s)"

    # Show effort level if tracked
    # Find the latest perf file for this date (prefer afternoon if exists)
    local LATEST_PERF="$PERF_DIR/${PERF_PREFIX}-${LATEST_DATE}-afternoon.json"
    if [ ! -f "$LATEST_PERF" ]; then
        LATEST_PERF="$PERF_DIR/${PERF_PREFIX}-${LATEST_DATE}.json"
    fi
    if [ -f "$LATEST_PERF" ]; then
        local EFFORT=$(grep -oP '"effort_level"\s*:\s*"\K[^"]+' "$LATEST_PERF" 2>/dev/null || echo "")
        if [ -n "$EFFORT" ]; then
            echo "  Effort level: $EFFORT"
        fi
    fi

    # Duration trend (last 3 runs) — helps detect cost spikes from effort level changes
    local TREND_DURATIONS=()
    local TREND_DATES=()
    for i in $(seq 0 $((DAYS - 1))); do
        local TREND_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
        # Check afternoon first (most recent), then morning
        for TREND_SUFFIX in "-afternoon" ""; do
            local TREND_FILE="$PERF_DIR/${PERF_PREFIX}-${TREND_DATE}${TREND_SUFFIX}.json"
            if [ -f "$TREND_FILE" ]; then
                local TREND_DUR=$(grep -oP '"duration_seconds"\s*:\s*\K\d+' "$TREND_FILE" 2>/dev/null || echo "0")
                TREND_DURATIONS+=("$TREND_DUR")
                TREND_DATES+=("$TREND_DATE")
            fi
            [ "${#TREND_DURATIONS[@]}" -ge 3 ] && break
        done
        [ "${#TREND_DURATIONS[@]}" -ge 3 ] && break
    done
    if [ "${#TREND_DURATIONS[@]}" -ge 2 ]; then
        local TREND_STR="  Duration trend:"
        for idx in $(seq $((${#TREND_DURATIONS[@]} - 1)) -1 0); do
            local d=${TREND_DURATIONS[$idx]}
            TREND_STR="$TREND_STR $((d / 60))m$((d % 60))s"
            if [ "$idx" -gt 0 ]; then
                TREND_STR="$TREND_STR →"
            fi
        done
        echo "$TREND_STR"
    fi

    # Agent-specific metrics from latest perf file
    if [ -f "$LATEST_PERF" ]; then
        case "$AGENT_NAME" in
            ltc)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local TESTS=$(grep -oP '"test_count_after"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local COMPLIANCE=$(grep -oP '"compliance_violations"\s*:\s*"\K[^"]+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | Tests: $TESTS | Compliance violations: $COMPLIANCE"
                ;;
            factory)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local ADOPT=$(grep -oP '"adopt_items_available"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | ADOPT items: $ADOPT"
                ;;
            researcher)
                local KB_FILES=$(grep -oP '"kb_files_updated"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local STATUS=$(grep -oP '"status"\s*:\s*"\K[^"]+' "$LATEST_PERF" 2>/dev/null || echo "run")
                local SKIPS=$(grep -oP '"consecutive_skips"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "0")
                if [ "$STATUS" = "skip" ]; then
                    echo -e "  ${YELLOW}SKIPPED${RESET} (no new releases) | Consecutive skips: $SKIPS"
                else
                    echo "  Last KB updates: $KB_FILES files | Commits: $COMMITS | Files changed: $FILES"
                fi
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
            bsp-knowledge)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local EVALS=$(grep -oP '"eval_count_after"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local NODES=$(grep -oP '"graph_nodes"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | Eval cases: $EVALS | Graph nodes: $NODES"
                ;;
            reviewer)
                local ON_TRACK=$(grep -oP '"stewards_on_track"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local CORRECTIONS=$(grep -oP '"stewards_needs_correction"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local ESCALATIONS=$(grep -oP '"escalations"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  On-track: $ON_TRACK | Needs correction: $CORRECTIONS | Escalations: $ESCALATIONS"
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

# Print each agent section — active agents first
print_agent_section "researcher" "Agentic AI Researcher" "sweep" "researcher" "1am + 2pm"
print_agent_section "research-lead" "Research Lead" "research-lead" "research-lead" "2am + 3pm"
print_agent_section "factory" "Factory Steward" "factory" "factory" "3am + 6pm"
print_agent_section "ltc" "LTC Steward" "ltc" "ltc" "8:00 AM"
# Suspended agents — will show "No runs found" if no recent data
print_agent_section "android-sw" "Android-SW Steward (suspended)" "android-sw" "android-sw" "suspended"
print_agent_section "arm-mrs" "ARM MRS Steward (suspended)" "arm-mrs" "arm-mrs" "suspended"
print_agent_section "bsp-knowledge" "BSP Knowledge Steward (suspended)" "bsp-knowledge" "bsp-knowledge" "suspended"
print_agent_section "reviewer" "Project Reviewer (suspended)" "reviewer" "reviewer" "suspended"

# Fleet Version Status
echo -e "${BOLD}--- Fleet Version Status ---${RESET}"
echo ""

FLEET_MIN_FILE="$SCRIPT_DIR/lib/fleet_min_version.txt"
FLEET_ALERT_FILE="$LOG_DIR/security/fleet_version.jsonl"

if [ -f "$FLEET_MIN_FILE" ]; then
    FLEET_MIN=$(cat "$FLEET_MIN_FILE" | tr -d '[:space:]')
    # Get current running version
    CLAUDE_BIN="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"
    FLEET_CURRENT=$("$CLAUDE_BIN" --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || claude --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
    if [ "$FLEET_CURRENT" = "unknown" ]; then
        echo -e "  Current:  ${YELLOW}unknown (could not detect)${RESET}"
        echo "  Required: >= $FLEET_MIN"
    else
        FLEET_OLDEST=$(printf '%s\n%s\n' "$FLEET_MIN" "$FLEET_CURRENT" | sort -V | head -1)
        if [ "$FLEET_OLDEST" = "$FLEET_MIN" ]; then
            echo -e "  Current:  ${GREEN}$FLEET_CURRENT${RESET}"
            echo "  Required: >= $FLEET_MIN"
            echo -e "  Status:   ${GREEN}OK${RESET}"
        else
            # Calculate days since first escalation
            FLEET_DAYS_SINCE=0
            if [ -f "$FLEET_ALERT_FILE" ]; then
                FLEET_FIRST_DATE=$(head -1 "$FLEET_ALERT_FILE" 2>/dev/null | grep -oP '"timestamp"\s*:\s*"\K[0-9-]+' || echo "")
                if [ -n "$FLEET_FIRST_DATE" ]; then
                    FLEET_FIRST_EPOCH=$(date -d "$FLEET_FIRST_DATE" +%s 2>/dev/null || echo "0")
                    FLEET_NOW_EPOCH=$(date +%s)
                    if [ "$FLEET_FIRST_EPOCH" -gt 0 ]; then
                        FLEET_DAYS_SINCE=$(( (FLEET_NOW_EPOCH - FLEET_FIRST_EPOCH) / 86400 ))
                    fi
                fi
            fi
            echo -e "  Current:  ${RED}$FLEET_CURRENT${RESET}"
            echo "  Required: >= $FLEET_MIN"
            echo -e "  Status:   ${RED}UPGRADE NEEDED${RESET} (${FLEET_DAYS_SINCE} days since first escalation)"
            echo -e "  Action:   ${YELLOW}Human must run: npm i -g @anthropic-ai/claude-code@latest${RESET}"
        fi
    fi
else
    echo -e "  ${YELLOW}fleet_min_version.txt not found${RESET}"
fi
echo ""

# Summary table
echo -e "${BOLD}--- Weekly Summary ---${RESET}"
echo ""

# Count total perf files
TOTAL_RUNS=$(find "$PERF_DIR" -name "*.json" -newer "$PERF_DIR" -mtime -"$DAYS" 2>/dev/null | wc -l || echo "0")
# Count runs from both perf JSON and log files
TOTAL_RUNS=0
TOTAL_LOG_ONLY=0
LOG_PREFIXES=("factory" "ltc" "sweep" "android-sw" "arm-mrs" "bsp-knowledge" "reviewer")
PERF_PREFIXES=("factory" "ltc" "researcher" "android-sw" "arm-mrs" "bsp-knowledge" "reviewer")
for i in $(seq 0 $((DAYS - 1))); do
    CHECK_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
    for j in 0 1 2 3 4 5 6; do
        found_perf=0
        if [ -f "$PERF_DIR/${PERF_PREFIXES[$j]}-${CHECK_DATE}.json" ]; then
            TOTAL_RUNS=$((TOTAL_RUNS + 1))
            found_perf=1
        fi
        if [ -f "$PERF_DIR/${PERF_PREFIXES[$j]}-${CHECK_DATE}-afternoon.json" ]; then
            TOTAL_RUNS=$((TOTAL_RUNS + 1))
            found_perf=1
        fi
        if [ "$found_perf" -eq 0 ] && [ -f "$LOG_DIR/${LOG_PREFIXES[$j]}-${CHECK_DATE}.log" ]; then
            TOTAL_LOG_ONLY=$((TOTAL_LOG_ONLY + 1))
        fi
    done
done

# Count total sessions from session logs (more accurate for multi-run agents)
SESSION_DIR="$LOG_DIR/sessions"
TOTAL_SESSIONS=0
if [ -d "$SESSION_DIR" ]; then
    for i in $(seq 0 $((DAYS - 1))); do
        SESS_DATE=$(date -d "-${i} days" +"%Y-%m-%d" 2>/dev/null || date -v-${i}d +"%Y-%m-%d" 2>/dev/null)
        for PREFIX in "${PERF_PREFIXES[@]}"; do
            SESS_FILE="$SESSION_DIR/${PREFIX}-${SESS_DATE}.jsonl"
            if [ -f "$SESS_FILE" ]; then
                DAY_SESSIONS=$(grep -c '"SESSION_START"' "$SESS_FILE" 2>/dev/null || echo "0")
                TOTAL_SESSIONS=$((TOTAL_SESSIONS + DAY_SESSIONS))
            fi
        done
    done
fi

echo "  Total agent runs: $TOTAL_RUNS with metrics + $TOTAL_LOG_ONLY log-only (across all 7 agents, last $DAYS days)"
if [ "$TOTAL_SESSIONS" -gt 0 ]; then
    echo "  Total sessions:   $TOTAL_SESSIONS (from session logs — includes multi-run agents)"
fi
echo "  Expected runs:    ~$((DAYS * 7)) (varies — LTC runs 5x wkday, 3x weekend)"
echo ""

# Check git activity in target repos
echo -e "${BOLD}--- Git Activity ---${RESET}"
echo ""

for REPO_PATH in "/home/jonas/gemini-home/agent-skill-automation" "/home/jonas/gemini-home/long-term-care-expert"; do
    REPO_NAME=$(basename "$REPO_PATH")
    COMMIT_COUNT=$(cd "$REPO_PATH" && git rev-list --after="$(date -d "-${DAYS} days" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d)" HEAD 2>/dev/null | wc -l) || COMMIT_COUNT="?"
    echo "  $REPO_NAME: $COMMIT_COUNT commits in last $DAYS days"
done

echo ""
echo -e "${BOLD}=========================================${RESET}"
echo "  Run ./scripts/agent_review.sh 30 for monthly view"
echo -e "${BOLD}=========================================${RESET}"
