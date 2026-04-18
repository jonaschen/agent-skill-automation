#!/bin/bash
# check_fleet_version.sh — Pre-flight Claude Code version check for daily agent fleet
#
# Sources from all daily_*.sh scripts. Warns (never blocks) when the running
# Claude Code version is below the minimum specified in fleet_min_version.txt.
#
# Proposal: 2026-04-10-fleet-version-check.md (P1)
# Discussion: 2026-04-09 Round 3B (ADOPT)
#
# Usage: source "$SCRIPT_DIR/lib/check_fleet_version.sh"
#        check_fleet_version "$CLAUDE" "$LOG_FILE"

check_fleet_version() {
  local claude_bin="${1:-claude}"
  local log_file="${2:-/dev/null}"
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local min_version_file="$lib_dir/fleet_min_version.txt"
  if [[ "$claude_bin" == *"gemini"* ]]; then
    min_version_file="$lib_dir/gemini_min_version.txt"
  fi

  # Read minimum version
  local min_version
  if [ -f "$min_version_file" ]; then
    min_version=$(cat "$min_version_file" | tr -d '[:space:]')
  else
    echo "[FLEET-VERSION] missing $min_version_file — skipping check" >> "$log_file"
    return 0
  fi

  # Get running version
  local running_version
  running_version=$("$claude_bin" --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1) || running_version=""

  if [ -z "$running_version" ]; then
    echo "[FLEET-VERSION] could not determine version from '$claude_bin --version' — skipping check" >> "$log_file"
    return 0
  fi

  # Compare versions using sort -V (version sort)
  local oldest
  oldest=$(printf '%s\n%s\n' "$min_version" "$running_version" | sort -V | head -1)

  # Ensure security alert directory exists
  local alert_dir="$(cd "$lib_dir/../.." && pwd)/logs/security"
  mkdir -p "$alert_dir"
  local alert_file="$alert_dir/fleet_version.jsonl"

  if [ "$oldest" = "$min_version" ]; then
    echo "[FLEET-VERSION] running=$running_version minimum=$min_version status=OK" >> "$log_file"
  else
    echo "[FLEET-VERSION] running=$running_version minimum=$min_version status=WARN — version below minimum!" >> "$log_file"
    # Write structured JSON alert for dashboard consumption
    local ts
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local agent_name="${CLAUDE_AGENT_NAME:-unknown}"
    # Calculate days since first escalation from alert file
    local first_escalation_date=""
    local days_since_escalation=0
    if [ -f "$alert_file" ]; then
      first_escalation_date=$(head -1 "$alert_file" 2>/dev/null | grep -oP '"timestamp"\s*:\s*"\K[0-9-]+' || echo "")
    fi
    if [ -n "$first_escalation_date" ]; then
      local first_epoch
      local now_epoch
      first_epoch=$(date -d "$first_escalation_date" +%s 2>/dev/null || echo "0")
      now_epoch=$(date +%s)
      if [ "$first_epoch" -gt 0 ]; then
        days_since_escalation=$(( (now_epoch - first_epoch) / 86400 ))
      fi
    fi
    echo "{\"timestamp\":\"$ts\",\"agent\":\"$agent_name\",\"current_version\":\"$running_version\",\"min_required\":\"$min_version\",\"status\":\"MISMATCH\",\"days_since_escalation\":$days_since_escalation}" >> "$alert_file"
  fi

  return 0  # Never block — warning only
}
