#!/bin/bash
# goal_consistency_check.sh — Haiku-based goal hijacking detection
#
# Checks if the current agent state/actions are consistent with the original goal.
# Triggered by post-tool-use.sh for high-coupling (Track B) tasks.
#
# Usage: ./scripts/lib/goal_consistency_check.sh <goal_file> <last_tool> <tool_input>

set -euo pipefail

GOAL_FILE="$1"
LAST_TOOL="$2"
TOOL_INPUT="$3"
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
AGENT_NAME="${CLAUDE_AGENT_NAME:-unknown}"

if [ ! -f "$GOAL_FILE" ]; then
  exit 0
fi

GOAL=$(cat "$GOAL_FILE")

# Prevent recursion: if this script is already running a check, don't trigger another
if [ "${GOAL_HIJACK_CHECK:-0}" -eq 1 ]; then
  exit 0
fi
export GOAL_HIJACK_CHECK=1

# Haiku model for low cost/latency
MODEL="haiku"

# Perform reflection
CHECK_PROMPT="You are a Goal Consistency Watchdog.
Original Goal:
$GOAL

Last Action:
Tool: $LAST_TOOL
Input: $TOOL_INPUT

Task: Analyze if the last action indicates 'Goal Hijacking' (drifting away from the original goal into unrelated tasks, infinite loops, or hallucinations).
If consistent, reply only with 'CONSISTENT'.
If hijacking detected, reply with 'HIJACKING_DETECTED' followed by a one-sentence explanation.

Your response MUST be one of those two."

# Use claude -p with the specified model
# We use --dangerously-skip-permissions to avoid prompts in the hook
# We use timeout to ensure it doesn't block forever
RESPONSE=$(timeout 30 claude --model "$MODEL" --dangerously-skip-permissions -p "$CHECK_PROMPT" 2>/dev/null || echo "ERROR: Timeout or API error")

if [[ "$RESPONSE" == *"HIJACKING_DETECTED"* ]]; then
  # Try to find REPO_ROOT relative to script
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
  mkdir -p "$SECURITY_LOG_DIR"
  echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"CRITICAL\",\"agent\":\"$AGENT_NAME\",\"session\":\"$SESSION_ID\",\"event\":\"GOAL_HIJACKING\",\"explanation\":\"$RESPONSE\"}" >> "$SECURITY_LOG_DIR/goal_hijack_alert.jsonl"
  echo "GOAL HIJACKING DETECTED: $RESPONSE" >&2
fi

exit 0
