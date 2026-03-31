#!/bin/bash
# skill_logger_hook.sh — Portable skill usage logger
#
# Captures user prompts and skill/agent routing decisions in any project.
# Install via: scripts/install_logger.sh <target-project-path>
#
# Logs to: <target-project>/.claude/skill_usage_log.jsonl
# Format: one JSON object per line (prompt + triggered skill + timestamp)
#
# This script handles BOTH UserPromptSubmit and SubagentStop events.
# It determines which event fired by reading hook_event_name from stdin JSON.

set -euo pipefail

INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."')
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Log file location — inside the project's .claude/ directory
LOG_DIR="${CWD}/.claude"
LOG_FILE="${LOG_DIR}/skill_usage_log.jsonl"
PROMPT_CACHE="${LOG_DIR}/.last_prompt_${SESSION_ID}"

mkdir -p "$LOG_DIR"

case "$EVENT" in
  UserPromptSubmit)
    # Cache the user's prompt for correlation with the next skill trigger
    PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')
    if [ -n "$PROMPT" ]; then
      echo "$PROMPT" > "$PROMPT_CACHE"
    fi
    ;;

  SubagentStop)
    # A subagent (skill/agent) just finished — log the routing decision
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // "unknown"')

    # Retrieve the cached user prompt
    LAST_PROMPT=""
    if [ -f "$PROMPT_CACHE" ]; then
      LAST_PROMPT=$(cat "$PROMPT_CACHE")
    fi

    # Only log if we have a meaningful agent type (not "main")
    if [ "$AGENT_TYPE" != "unknown" ] && [ "$AGENT_TYPE" != "main" ]; then
      jq -n \
        --arg ts "$TIMESTAMP" \
        --arg session "$SESSION_ID" \
        --arg prompt "$LAST_PROMPT" \
        --arg skill "$AGENT_TYPE" \
        --arg event "$EVENT" \
        '{timestamp: $ts, session: $session, prompt: $prompt, skill_triggered: $skill, event: $event}' \
        >> "$LOG_FILE"
    fi
    ;;

  PostToolUse)
    # Fallback: capture Agent/Skill tool usage
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

    if [ "$TOOL_NAME" = "Skill" ] || [ "$TOOL_NAME" = "Agent" ]; then
      SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // .tool_input.subagent_type // .tool_input.name // "unknown"')

      LAST_PROMPT=""
      if [ -f "$PROMPT_CACHE" ]; then
        LAST_PROMPT=$(cat "$PROMPT_CACHE")
      fi

      if [ "$SKILL_NAME" != "unknown" ] && [ "$SKILL_NAME" != "null" ]; then
        jq -n \
          --arg ts "$TIMESTAMP" \
          --arg session "$SESSION_ID" \
          --arg prompt "$LAST_PROMPT" \
          --arg skill "$SKILL_NAME" \
          --arg event "$EVENT" \
          --arg tool "$TOOL_NAME" \
          '{timestamp: $ts, session: $session, prompt: $prompt, skill_triggered: $skill, event: $event, tool: $tool}' \
          >> "$LOG_FILE"
      fi
    fi
    ;;
esac

exit 0
