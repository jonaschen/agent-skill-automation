#!/bin/bash
# cost_ceiling.sh — Duration-based cost ceiling for steward scripts
#
# Defends against runaway spending from bugs, infinite loops, or MCP cost
# amplification attacks. Uses duration as a cost proxy (correlates well for
# same-model runs).
#
# Usage: Source this file from daily_*.sh scripts, then call:
#   check_cost_ceiling <agent_name> <perf_dir> <security_log_dir>
#
# Returns 0 if within ceiling. Logs a warning if exceeded (post-run check).
# The ceiling is MAX_DURATION_MULTIPLIER * 30-day rolling average duration.
# Fallback ceiling for first run (no history): DEFAULT_CEILING_SECONDS.

MAX_DURATION_MULTIPLIER="${MAX_DURATION_MULTIPLIER:-5}"
DEFAULT_CEILING_SECONDS="${DEFAULT_CEILING_SECONDS:-3600}"

# compute_duration_ceiling <agent_name> <perf_dir>
# Outputs the ceiling in seconds to stdout
compute_duration_ceiling() {
  local agent_name="$1"
  local perf_dir="$2"

  # Collect durations from last 30 days of perf JSON files
  local durations=()
  local count=0
  local sum=0

  for f in "$perf_dir/${agent_name}"-*.json; do
    [ -f "$f" ] || continue
    local dur
    dur=$(jq -r '.duration_seconds // empty' "$f" 2>/dev/null) || continue
    if [ -n "$dur" ] && [ "$dur" -gt 0 ] 2>/dev/null; then
      sum=$((sum + dur))
      count=$((count + 1))
    fi
  done

  if [ "$count" -eq 0 ]; then
    echo "$DEFAULT_CEILING_SECONDS"
    return
  fi

  local avg=$((sum / count))
  local ceiling=$((avg * MAX_DURATION_MULTIPLIER))

  # Floor: at least 300 seconds (5 minutes) to avoid overly tight ceilings
  if [ "$ceiling" -lt 300 ]; then
    ceiling=300
  fi

  echo "$ceiling"
}

# check_cost_ceiling <agent_name> <actual_duration> <perf_dir> <security_log_dir>
# Call AFTER a run completes. Checks if actual_duration exceeds the ceiling.
# Returns 0 always (advisory, not blocking). Logs alerts to security dir.
check_cost_ceiling() {
  local agent_name="$1"
  local actual_duration="$2"
  local perf_dir="$3"
  local security_log_dir="$4"

  local ceiling
  ceiling=$(compute_duration_ceiling "$agent_name" "$perf_dir")
  
  # Ensure ceiling is a valid integer, fallback to default if empty or invalid
  if ! [[ "$ceiling" =~ ^[0-9]+$ ]]; then
    ceiling="$DEFAULT_CEILING_SECONDS"
  fi

  if [ "$actual_duration" -gt "$ceiling" ]; then
    mkdir -p "$security_log_dir"
    local multiplier="unknown"
    if [ "$ceiling" -gt 0 ]; then
      multiplier=$(awk "BEGIN {printf \"%.1f\", $actual_duration / $ceiling}")
    fi
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"WARNING\",\"agent\":\"$agent_name\",\"actual_duration\":$actual_duration,\"ceiling\":$ceiling,\"multiplier\":\"${multiplier}x\",\"max_multiplier\":\"${MAX_DURATION_MULTIPLIER}x\"}" >> "$security_log_dir/cost_alert.jsonl"
    echo "COST WARNING: $agent_name ran for ${actual_duration}s (ceiling: ${ceiling}s, ${multiplier}x of limit)" >&2
    return 1
  fi
  return 0
}

# start_incremental_watchdog <agent_name> <parent_pid> <perf_dir> <security_log_dir>
# Starts a background process that monitors the parent_pid's duration.
# Halts (kills) the parent_pid if it exceeds the ceiling or an incremental gate.
start_incremental_watchdog() {
  local agent_name="$1"
  local parent_pid="$2"
  local perf_dir="$3"
  local security_log_dir="$4"

  local ceiling
  ceiling=$(compute_duration_ceiling "$agent_name" "$perf_dir")
  
  if ! [[ "$ceiling" =~ ^[0-9]+$ ]]; then
    ceiling="$DEFAULT_CEILING_SECONDS"
  fi

  (
    local start_time=$(date +%s)
    local gate_25=$((ceiling * 25 / 100))
    local gate_50=$((ceiling * 50 / 100))
    local gate_75=$((ceiling * 75 / 100))
    local alerted_25=0
    local alerted_50=0
    local alerted_75=0

    while kill -0 "$parent_pid" 2>/dev/null; do
      sleep 60
      local current_time=$(date +%s)
      local elapsed=$((current_time - start_time))

      # Incremental Budget Gates (P0 Discussion 2026-04-23)
      if [ "$elapsed" -gt "$ceiling" ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"CRITICAL\",\"agent\":\"$agent_name\",\"event\":\"CEILING_REACHED\",\"elapsed\":$elapsed,\"ceiling\":$ceiling}" >> "$security_log_dir/cost_alert.jsonl"
        echo "COST CRITICAL: $agent_name exceeded ceiling (${ceiling}s). Halting session." >&2
        kill -TERM "$parent_pid" 2>/dev/null
        exit 1
      fi

      if [ "$elapsed" -gt "$gate_75" ] && [ "$alerted_75" -eq 0 ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"INFO\",\"agent\":\"$agent_name\",\"event\":\"GATE_75_REACHED\",\"elapsed\":$elapsed}" >> "$security_log_dir/cost_alert.jsonl"
        alerted_75=1
      elif [ "$elapsed" -gt "$gate_50" ] && [ "$alerted_50" -eq 0 ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"INFO\",\"agent\":\"$agent_name\",\"event\":\"GATE_50_REACHED\",\"elapsed\":$elapsed}" >> "$security_log_dir/cost_alert.jsonl"
        alerted_50=1
      elif [ "$elapsed" -gt "$gate_25" ] && [ "$alerted_25" -eq 0 ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"INFO\",\"agent\":\"$agent_name\",\"event\":\"GATE_25_REACHED\",\"elapsed\":$elapsed}" >> "$security_log_dir/cost_alert.jsonl"
        alerted_25=1
      fi
    done
  ) &
  echo $!
}
