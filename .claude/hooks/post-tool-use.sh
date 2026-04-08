#!/bin/bash
# post-tool-use.sh — Post-tool-use lifecycle hook
#
# Runs after a tool execution (PostToolUse event).
# 1. Initiator-type policy enforcement (blocks destructive git ops in cron context)
# 2. MCP tool-call depth monitoring (cost amplification defense)
# 3. Detects writes to .claude/skills/ or ~/.claude/@lib/agents/ and:
#    a. Logs the lifecycle event via lifecycle_tracker.py
#    b. Runs permission check on modified SKILL.md files
#
# Exit code 0 = success
# Exit code 1 = error (blocks the tool use)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIFECYCLE_TRACKER="$REPO_ROOT/eval/lifecycle_tracker.py"
PERM_CHECK="$REPO_ROOT/eval/check-permissions.sh"

# The hook receives tool name and file path as environment variables
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
FILE_PATH="${CLAUDE_FILE_PATH:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# --- Initiator-Type Policy Enforcement ---
# Differentiates cron-automated from human-interactive sessions (AWS IAM pattern).
# Blocks destructive git operations in automated contexts.
INITIATOR_TYPE="${CLAUDE_INITIATOR_TYPE:-human-interactive}"

if [ "$INITIATOR_TYPE" = "cron-automated" ] && [ "$TOOL_NAME" = "Bash" ]; then
  case "$TOOL_INPUT" in
    *"push --force"*|*"push -f "*|*"reset --hard"*|*"branch -D "*|*"checkout -- ."*|*"clean -fd"*|*"clean -f"*)
      SECURITY_LOG_DIR="$REPO_ROOT/logs/security"
      mkdir -p "$SECURITY_LOG_DIR"
      echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"BLOCK\",\"agent\":\"${CLAUDE_AGENT_NAME:-unknown}\",\"initiator\":\"$INITIATOR_TYPE\",\"tool\":\"Bash\",\"blocked_command\":\"$(echo "$TOOL_INPUT" | head -c 200)\"}" >> "$SECURITY_LOG_DIR/initiator_policy.jsonl"
      echo "SECURITY BLOCK: destructive git operation blocked in cron-automated context: $(echo "$TOOL_INPUT" | head -c 100)" >&2
      exit 1
      ;;
  esac
fi

# --- Command-Chain Length Monitor ---
# Defends against deny-rule bypass via 50+ subcommand chains (Adversa disclosure).
# Only applies to Bash tool calls.
CMD_CHAIN_MONITOR="$REPO_ROOT/scripts/cmd_chain_monitor.sh"

if [ "$TOOL_NAME" = "Bash" ] && [ -f "$CMD_CHAIN_MONITOR" ]; then
  CMD_INPUT="$TOOL_INPUT" bash "$CMD_CHAIN_MONITOR" || exit 1
fi

# --- MCP Tool-Call Depth Monitor ---
# Defends against MCP cost amplification attacks (658x inflation, <3% detection).
# Pattern-matches mcp__* tool names, tracks per-session counter.
# Alert at 15 calls, block at 25 calls per session.
MCP_ALERT_THRESHOLD=15
MCP_BLOCK_THRESHOLD=25

if [[ "$TOOL_NAME" == mcp__* ]]; then
  SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
  MCP_COUNTER_FILE="/tmp/mcp_depth_${SESSION_ID}"
  SECURITY_LOG_DIR="$REPO_ROOT/logs/security"

  # Read and increment counter
  MCP_COUNT=0
  if [ -f "$MCP_COUNTER_FILE" ]; then
    MCP_COUNT=$(cat "$MCP_COUNTER_FILE" 2>/dev/null || echo "0")
  fi
  MCP_COUNT=$((MCP_COUNT + 1))
  echo "$MCP_COUNT" > "$MCP_COUNTER_FILE"

  # Extract MCP server name from tool name (mcp__<server>__<tool>)
  MCP_SERVER=$(echo "$TOOL_NAME" | cut -d'_' -f4- | cut -d'_' -f1 2>/dev/null || echo "unknown")

  if [ "$MCP_COUNT" -ge "$MCP_BLOCK_THRESHOLD" ]; then
    # BLOCK: too many MCP calls — potential cost amplification attack
    mkdir -p "$SECURITY_LOG_DIR"
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"BLOCK\",\"agent\":\"${CLAUDE_AGENT_NAME:-unknown}\",\"session\":\"$SESSION_ID\",\"mcp_server\":\"$MCP_SERVER\",\"tool\":\"$TOOL_NAME\",\"mcp_call_count\":$MCP_COUNT,\"threshold\":$MCP_BLOCK_THRESHOLD}" >> "$SECURITY_LOG_DIR/mcp_depth_alert.jsonl"
    echo "SECURITY BLOCK: MCP tool-call depth exceeded $MCP_BLOCK_THRESHOLD (count: $MCP_COUNT). Potential cost amplification attack. Tool: $TOOL_NAME" >&2
    exit 1
  elif [ "$MCP_COUNT" -ge "$MCP_ALERT_THRESHOLD" ]; then
    # ALERT: approaching limit
    mkdir -p "$SECURITY_LOG_DIR"
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"level\":\"ALERT\",\"agent\":\"${CLAUDE_AGENT_NAME:-unknown}\",\"session\":\"$SESSION_ID\",\"mcp_server\":\"$MCP_SERVER\",\"tool\":\"$TOOL_NAME\",\"mcp_call_count\":$MCP_COUNT,\"threshold\":$MCP_ALERT_THRESHOLD}" >> "$SECURITY_LOG_DIR/mcp_depth_alert.jsonl"
    echo "SECURITY ALERT: MCP tool-call depth at $MCP_COUNT (alert threshold: $MCP_ALERT_THRESHOLD, block at: $MCP_BLOCK_THRESHOLD). Tool: $TOOL_NAME" >&2
  fi
fi

# Only act on Write/Edit tools for lifecycle tracking
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  exit 0
fi

# Check if the file is a SKILL.md or agent definition
if [[ "$FILE_PATH" == *".claude/skills/"*"/SKILL.md" ]]; then
  skill_name=$(echo "$FILE_PATH" | grep -oP '(?<=skills/)[^/]+' || true)
  if [ -n "$skill_name" ]; then
    # Log lifecycle event
    if [ -f "$LIFECYCLE_TRACKER" ]; then
      python3 "$LIFECYCLE_TRACKER" --skill "$skill_name" --stage validated --source "post-tool-use" 2>/dev/null || true
    fi

    # Run permission check
    if [ -f "$PERM_CHECK" ] && [ -f "$FILE_PATH" ]; then
      if ! bash "$PERM_CHECK" "$FILE_PATH" 2>/dev/null; then
        echo "WARNING: Permission check failed for $skill_name" >&2
      fi
    fi
  fi
elif [[ "$FILE_PATH" == *"@lib/agents/"*".md" ]]; then
  role_name=$(basename "$FILE_PATH" .md)
  if [ -f "$LIFECYCLE_TRACKER" ]; then
    python3 "$LIFECYCLE_TRACKER" --skill "$role_name" --stage created --source "changeling-role" 2>/dev/null || true
  fi
fi

exit 0
