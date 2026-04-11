#!/bin/bash
# cmd_chain_monitor.sh — Command-chain length + metacharacter security monitor
#
# Two detection layers:
# 1. Chain length: Mitigates deny-rule bypass via 50+ subcommand chains
#    (Adversa disclosure, April 2026).
# 2. Metacharacter detection: Logs shell metacharacter patterns in Claude-generated
#    Bash tool inputs. Detect-only mode builds a 30-day baseline for Phase 5.5
#    PreToolUse allowlist calibration. Known-safe patterns (grep|head, git log|sort)
#    are allowlisted to avoid false positive flood.
#
# Usage: source this script from post-tool-use.sh, or call directly:
#   CMD_INPUT="cmd1 | cmd2 && cmd3" bash scripts/cmd_chain_monitor.sh
#
# Environment variables:
#   CMD_INPUT — the command string to analyze
#   CMD_CHAIN_WARN — warning threshold (default 30)
#   CMD_CHAIN_BLOCK — hard block threshold (default 45)
#   METACHAR_MODE — "detect" (default, advisory only) or "block" (reject)
#
# Exit codes:
#   0 — safe (below warning threshold)
#   0 — warning logged (above warn, below block)
#   1 — blocked (chain too long or metachar blocked)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CMD_CHAIN_LOG="$REPO_ROOT/logs/security/cmd-chain-alerts.log"
METACHAR_LOG="$REPO_ROOT/logs/security/metachar_alert.jsonl"

CMD_INPUT="${CMD_INPUT:-}"
CMD_CHAIN_WARN="${CMD_CHAIN_WARN:-30}"
CMD_CHAIN_BLOCK="${CMD_CHAIN_BLOCK:-45}"
# Set to "block" to reject metacharacter commands; "detect" (default) only logs
METACHAR_MODE="${METACHAR_MODE:-detect}"

if [[ -z "$CMD_INPUT" ]]; then
  exit 0
fi

# --- Metacharacter pattern detection (detect-only baseline) ---
# Scope: Claude-generated Bash tool inputs only (not our own scripts).
# Builds a 30-day baseline for Phase 5.5 PreToolUse allowlist calibration.
#
# Known-safe command binaries — legitimate commands that agents use in pipes/chains.
# Each individual command in a chain is checked against this list.
# If ALL commands in the chain are safe, the entire command is allowlisted.
SAFE_BINARIES="grep|rg|git|jq|cat|sort|wc|head|tail|awk|sed|cut|tr|tee|xargs|python3|python|cd|mkdir|npm|npx|bash|echo|printf|ls|find|date|test|true|false|set|unset|export|source|readlink|dirname|basename|sha256sum|md5sum|diff|comm|uniq|column|less|more|rev|stat|file|touch|cp|mv|ln"

detect_metachar_patterns() {
  local cmd="$1"
  local timestamp
  timestamp="$(date -Iseconds)"

  # Detect shell metacharacters: ; | && || $() backticks
  # Only flag if the command contains metacharacters
  local has_metachar=false
  local metachar_types=""

  if echo "$cmd" | grep -qE '\$\(' ; then
    has_metachar=true
    metachar_types="${metachar_types}command_substitution,"
  fi
  if echo "$cmd" | grep -qE '`[^`]+`' ; then
    has_metachar=true
    metachar_types="${metachar_types}backtick_substitution,"
  fi
  # Semicolons (but not inside quotes — simple heuristic: bare ; not preceded by echo/printf)
  if echo "$cmd" | grep -qE ';\s' ; then
    has_metachar=true
    metachar_types="${metachar_types}semicolon,"
  fi
  # Pipes (single |, not ||)
  if echo "$cmd" | grep -qE '\|[^|]' ; then
    has_metachar=true
    metachar_types="${metachar_types}pipe,"
  fi
  # Logical operators
  if echo "$cmd" | grep -qE '&&' ; then
    has_metachar=true
    metachar_types="${metachar_types}and_chain,"
  fi
  if echo "$cmd" | grep -qE '\|\|' ; then
    has_metachar=true
    metachar_types="${metachar_types}or_chain,"
  fi

  if [[ "$has_metachar" != "true" ]]; then
    return 0
  fi

  # Sanitize command for JSON output (escape backslashes, quotes, newlines)
  local safe_cmd
  safe_cmd="$(printf '%s' "${cmd:0:300}" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')"

  # Check if ALL commands in the chain use known-safe binaries.
  # Split the command on metacharacters and check each segment's first word.
  local all_safe=true
  local unsafe_cmds=""
  # Split on |, ||, ;, && and check each segment
  while IFS= read -r segment; do
    # Trim whitespace and get first word (the binary)
    segment="$(echo "$segment" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    [[ -z "$segment" ]] && continue
    local first_word
    first_word="$(echo "$segment" | awk '{print $1}')"
    # Strip any path prefix (e.g., /usr/bin/grep -> grep)
    first_word="$(basename "$first_word")"
    if ! echo "$first_word" | grep -qE "^($SAFE_BINARIES)$" ; then
      all_safe=false
      unsafe_cmds="${unsafe_cmds}${first_word},"
    fi
  done < <(echo "$cmd" | sed 's/||\|&&\||/\n/g; s/;/\n/g')

  if [[ "$all_safe" == "true" ]]; then
    # All commands are known-safe — log for baseline but mark as safe
    mkdir -p "$(dirname "$METACHAR_LOG")"
    printf '{"timestamp":"%s","level":"safe","metachar_types":"%s","command":"%s"}\n' \
      "$timestamp" "${metachar_types%,}" "$safe_cmd" >> "$METACHAR_LOG"
    return 0
  fi

  # Contains unsafe binaries — log as advisory alert
  mkdir -p "$(dirname "$METACHAR_LOG")"
  printf '{"timestamp":"%s","level":"advisory","metachar_types":"%s","unsafe_binaries":"%s","command":"%s"}\n' \
    "$timestamp" "${metachar_types%,}" "${unsafe_cmds%,}" "$safe_cmd" >> "$METACHAR_LOG"

  if [[ "$METACHAR_MODE" == "block" ]]; then
    echo "BLOCKED: Shell metacharacter detected in command (types: ${metachar_types%,}). Command not in allowlist." >&2
    return 1
  fi

  return 0
}

# Run metacharacter detection (detect-only, advisory)
detect_metachar_patterns "$CMD_INPUT" || {
  if [[ "$METACHAR_MODE" == "block" ]]; then
    exit 1
  fi
}

# --- Command chain length monitor (existing) ---

# Count command separators: |, ||, ;, &&
# Use a subshell to avoid pipefail exit when grep finds no matches
chain_count=$(set +o pipefail; echo "$CMD_INPUT" | grep -oE '\|{1,2}|;|&&' | wc -l)
# Add 1 for the base command
chain_count=$((chain_count + 1))

if [[ $chain_count -ge $CMD_CHAIN_BLOCK ]]; then
  mkdir -p "$(dirname "$CMD_CHAIN_LOG")"
  echo "[$(date -Iseconds)] BLOCKED chain_count=$chain_count command=${CMD_INPUT:0:200}" >> "$CMD_CHAIN_LOG"
  echo "ERROR: Command chain too long ($chain_count subcommands, limit $CMD_CHAIN_BLOCK). Blocked for security." >&2
  exit 1
elif [[ $chain_count -ge $CMD_CHAIN_WARN ]]; then
  mkdir -p "$(dirname "$CMD_CHAIN_LOG")"
  echo "[$(date -Iseconds)] WARNING chain_count=$chain_count command=${CMD_INPUT:0:200}" >> "$CMD_CHAIN_LOG"
  echo "WARNING: Long command chain detected ($chain_count subcommands, alert threshold $CMD_CHAIN_WARN)." >&2
fi

exit 0
