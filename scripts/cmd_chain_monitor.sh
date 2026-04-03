#!/bin/bash
# cmd_chain_monitor.sh — Command-chain length security monitor
#
# Mitigates Claude Code deny-rule bypass via 50+ subcommand chains
# (Adversa disclosure, April 2026).
#
# Usage: source this script from post-tool-use.sh, or call directly:
#   CMD_INPUT="cmd1 | cmd2 && cmd3" bash scripts/cmd_chain_monitor.sh
#
# Environment variables:
#   CMD_INPUT — the command string to analyze
#   CMD_CHAIN_WARN — warning threshold (default 30)
#   CMD_CHAIN_BLOCK — hard block threshold (default 45)
#
# Exit codes:
#   0 — safe (below warning threshold)
#   0 — warning logged (above warn, below block)
#   1 — blocked (above block threshold)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CMD_CHAIN_LOG="$REPO_ROOT/logs/security/cmd-chain-alerts.log"

CMD_INPUT="${CMD_INPUT:-}"
CMD_CHAIN_WARN="${CMD_CHAIN_WARN:-30}"
CMD_CHAIN_BLOCK="${CMD_CHAIN_BLOCK:-45}"

if [[ -z "$CMD_INPUT" ]]; then
  exit 0
fi

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
