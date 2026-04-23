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

# compute_average_duration <agent_name> <perf_dir>
compute_average_duration() {
  local agent_name="$1"
  local perf_dir="$2"

  local sum=0
  local count=0

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
    echo "$((DEFAULT_CEILING_SECONDS / MAX_DURATION_MULTIPLIER))"
    return
  fi

  echo "$((sum / count))"
}

# compute_duration_ceiling <agent_name> <perf_dir>
# Outputs the ceiling in seconds to stdout
compute_duration_ceiling() {
  local agent_name="$1"
  local perf_dir="$2"

  local avg
  avg=$(compute_average_duration "$agent_name" "$perf_dir")
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

# watchdog_pulse <watchdog_pid>
# Resets the segment timer for the watchdog.
watchdog_pulse() {
  local watchdog_pid="$1"
  local pulse_file="/tmp/watchdog_pulse_${watchdog_pid}"
  touch "$pulse_file"
}

# start_incremental_watchdog <agent_name> <parent_pid> <perf_dir> <security_log_dir>
# Starts a background process that monitors the parent_pid's duration.
# Halts (kills) the parent_pid if it exceeds the ceiling or an incremental gate.
start_incremental_watchdog() {
  local agent_name="$1"
  local parent_pid="$2"
  local perf_dir="$3"
  local security_log_dir="$4"

  local avg
  avg=$(compute_average_duration "$agent_name" "$perf_dir")
  local ceiling=$((avg * MAX_DURATION_MULTIPLIER))
  local pulse_limit=$((avg * 25 / 100)) # P0 Directive: 25% of 30-day average
  
  if ! [[ "$ceiling" =~ ^[0-9]+$ ]]; then
    ceiling="$DEFAULT_CEILING_SECONDS"
    pulse_limit=$((ceiling * 25 / 100 / MAX_DURATION_MULTIPLIER))
  fi

  # Floor pulse_limit at 60s to avoid instant kills
  if [ "$pulse_limit" -lt 60 ]; then pulse_limit=60; fi

  (
    local start_time=$(date +%s)
    local segment_start_time=$(date +%s)
    local gate_25=$((ceiling * 25 / 100))
    local gate_50=$((ceiling * 50 / 100))
    local gate_75=$((ceiling * 75 / 100))
    local alerted_25=0
    local alerted_50=0
    local alerted_75=0
    local watchdog_pid=$$
    local pulse_file="/tmp/watchdog_pulse_${watchdog_pid}"

    while kill -0 "$parent_pid" 2>/dev/null; do
      sleep 10 # More frequent checks for "Watchdog Pulse"
      local current_time=$(date +%s)
      local elapsed=$((current_time - start_time))
      local segment_elapsed=$((current_time - segment_start_time))

      # Check for pulse (segment reset)
      if [ -f "$pulse_file" ]; then
        segment_start_time=$(date +%s)
        segment_elapsed=0
        rm -f "$pulse_file"
      fi

      # Watchdog Pulse: Alert and halt if segment exceeds 25% of average
      if [ "$segment_elapsed" -gt "$pulse_limit" ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"CRITICAL\",\"agent\":\"$agent_name\",\"event\":\"WATCHDOG_PULSE_HALT\",\"segment_elapsed\":$segment_elapsed,\"pulse_limit\":$pulse_limit}" >> "$security_log_dir/cost_alert.jsonl"
        echo "COST CRITICAL: $agent_name reached Watchdog Pulse limit (${pulse_limit}s). Halting session." >&2
        kill -TERM "$parent_pid" 2>/dev/null
        exit 1
      fi

      # Overall Ceiling
      if [ "$elapsed" -gt "$ceiling" ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"CRITICAL\",\"agent\":\"$agent_name\",\"event\":\"CEILING_REACHED\",\"elapsed\":$elapsed,\"ceiling\":$ceiling}" >> "$security_log_dir/cost_alert.jsonl"
        echo "COST CRITICAL: $agent_name exceeded ceiling (${ceiling}s). Halting session." >&2
        kill -TERM "$parent_pid" 2>/dev/null
        exit 1
      fi

      # Incremental Gates (logging only)
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
    rm -f "$pulse_file"
  ) &
  echo $!
}

