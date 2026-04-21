#!/bin/bash
# agent_review_gemini.sh — Review dashboard for all daily agents (Gemini version)
#
# Summarizes recent performance of active Gemini agents:
#   1. agentic-ai-researcher-gemini
#   2. agentic-ai-research-lead-gemini
#   3. factory-steward-gemini
#   4. ltc-steward-gemini
#
# Usage:
#   ./scripts/agent_review_gemini.sh              # Last 7 days (default)
#   ./scripts/agent_review_gemini.sh 14           # Last 14 days
#   ./scripts/agent_review_gemini.sh 1            # Today only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DAYS=${1:-7}

# Source shared libraries to ensure Node.js v24 is in PATH for Gemini CLI
source "$SCRIPT_DIR/lib/session_log.sh"

# Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BOLD}=========================================${RESET}"
echo -e "${BOLD}  Gemini Agent Performance Review (last ${DAYS} days)${RESET}"
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
        local CHECK_LOG="$LOG_DIR/${LOG_PREFIX}-${CHECK_DATE}.log"

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
        elif [ -f "$CHECK_LOG" ]; then
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
    local LATEST_PERF="$PERF_DIR/${PERF_PREFIX}-${LATEST_DATE}.json"
    if [ -f "$LATEST_PERF" ]; then
        local EFFORT=$(grep -oP '"effort_level"\s*:\s*"\K[^"]+' "$LATEST_PERF" 2>/dev/null || echo "")
        if [ -n "$EFFORT" ]; then
            echo "  Effort level: $EFFORT"
        fi
    fi

    # Agent-specific metrics from latest perf file
    if [ -f "$LATEST_PERF" ]; then
        case "$AGENT_NAME" in
            ltc-gemini)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES"
                ;;
            factory-gemini)
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local ADOPT=$(grep -oP '"adopt_items_available"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                echo "  Last commits: $COMMITS | Files changed: $FILES | ADOPT items: $ADOPT"
                ;;
            researcher-gemini)
                local KB_FILES=$(grep -oP '"kb_files_updated"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local COMMITS=$(grep -oP '"commits_made"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local FILES=$(grep -oP '"files_changed"\s*:\s*\K\d+' "$LATEST_PERF" 2>/dev/null || echo "?")
                local STATUS=$(grep -oP '"status"\s*:\s*"\K[^"]+' "$LATEST_PERF" 2>/dev/null || echo "run")
                if [ "$STATUS" = "skip" ]; then
                    echo -e "  ${YELLOW}SKIPPED${RESET} (no new releases)"
                else
                    echo "  Last KB updates: $KB_FILES files | Commits: $COMMITS | Files changed: $FILES"
                fi
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
print_agent_section "researcher-gemini" "Agentic AI Researcher (Gemini)" "sweep-gemini" "researcher-gemini" "2am + 10am"
print_agent_section "research-lead-gemini" "Research Lead (Gemini)" "research-lead-gemini" "research-lead-gemini" "3am + 11am"
print_agent_section "factory-gemini" "Factory Steward (Gemini)" "factory-gemini" "factory-gemini" "4am + 12pm"
print_agent_section "ltc-gemini" "LTC Steward (Gemini)" "ltc-gemini" "ltc-gemini" "8:00 AM"
print_agent_section "reviewer-gemini" "Project Reviewer (Gemini)" "reviewer-gemini" "reviewer-gemini" "suspended"

# Fleet Version Status
echo -e "${BOLD}--- Gemini Fleet Version Status ---${RESET}"
echo ""

FLEET_MIN_FILE="$SCRIPT_DIR/lib/gemini_min_version.txt"
FLEET_ALERT_FILE="$LOG_DIR/security/fleet_version_gemini.jsonl"

if [ -f "$FLEET_MIN_FILE" ]; then
    FLEET_MIN=$(cat "$FLEET_MIN_FILE" | tr -d '[:space:]')
    # Get current running version
    GEMINI_BIN="/home/jonas/.nvm/versions/node/v24.14.0/bin/gemini"
    FLEET_CURRENT=$("$GEMINI_BIN" --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
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
            echo -e "  Current:  ${RED}$FLEET_CURRENT${RESET}"
            echo "  Required: >= $FLEET_MIN"
            echo -e "  Status:   ${RED}UPGRADE NEEDED${RESET}"
        fi
    fi
else
    echo -e "  ${YELLOW}gemini_min_version.txt not found${RESET}"
fi
echo ""

echo -e "${BOLD}=========================================${RESET}"
echo "  Gemini dashboard active"
echo -e "${BOLD}=========================================${RESET}"
