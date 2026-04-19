#!/bin/bash
# session_log.sh — Structured session event logging for steward agents
#
# Provides append-only JSONL event logging to logs/sessions/{agent}-{date}.jsonl
# Event types: SESSION_START, TASK_START, TASK_COMPLETE, TASK_SKIP, ERROR, CHECKPOINT, SESSION_END
#
# Usage:
#   source scripts/lib/session_log.sh
#   init_session_log "factory" "$REPO_ROOT"
#   log_event "SESSION_START" '{"prompt":"ADOPT items"}'
#   log_event "TASK_START" '{"task":"implement session logging"}'
#   log_event "TASK_COMPLETE" '{"task":"implement session logging","result":"success"}'
#   log_event "SESSION_END" '{"exit_code":0}'
#
# Foundation for Phase 5.3.2 task-level workflow state tracking.
# Crash-recovery logic is deferred to Phase 5.

_SESSION_LOG_AGENT=""
_SESSION_LOG_DIR=""
_SESSION_LOG_FILE=""
_SESSION_LOG_DATE=""
_SESSION_LOG_TRACE_ID=""

# Initialize session logging for an agent
# Args: agent_name repo_root
init_session_log() {
  _SESSION_LOG_AGENT="${1:?init_session_log requires agent name}"
  local repo_root="${2:?init_session_log requires repo root}"
  _SESSION_LOG_DIR="$repo_root/logs/sessions"
  _SESSION_LOG_DATE=$(date +"%Y-%m-%d")
  _SESSION_LOG_FILE="$_SESSION_LOG_DIR/${_SESSION_LOG_AGENT}-${_SESSION_LOG_DATE}.jsonl"
  # Generate a trace_id for correlating events within a single session
  # Format: agent-YYYYMMDD-HHMMSS-random (human-readable, unique per session)
  _SESSION_LOG_TRACE_ID="${_SESSION_LOG_AGENT}-$(date +%Y%m%d-%H%M%S)-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' ')"
  mkdir -p "$_SESSION_LOG_DIR"

  # 30-day retention
  find "$_SESSION_LOG_DIR" -name "*.jsonl" -mtime +30 -delete 2>/dev/null || true
}

# Log a structured event
# Args: event_type [payload_json]
# payload_json defaults to "{}" if omitted
log_event() {
  local event_type="${1:?log_event requires event_type}"
  local payload='{}'
  [ $# -ge 2 ] && payload="$2"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  if [ -z "$_SESSION_LOG_FILE" ]; then
    echo "[session_log] WARNING: init_session_log not called, skipping event $event_type" >&2
    return 0
  fi

  # Build JSON line — use printf to avoid echo interpretation issues
  printf '{"timestamp":"%s","agent":"%s","trace_id":"%s","type":"%s","payload":%s}\n' \
    "$timestamp" "$_SESSION_LOG_AGENT" "$_SESSION_LOG_TRACE_ID" "$event_type" "$payload" \
    >> "$_SESSION_LOG_FILE" 2>/dev/null || true
}

# Convenience: log session start with metadata
log_session_start() {
  local session_type="${1:-main}"
  log_event "SESSION_START" "{\"session_type\":\"$session_type\",\"date\":\"$_SESSION_LOG_DATE\"}"
}

# Convenience: log session end with exit code
log_session_end() {
  local exit_code="${1:-0}"
  local duration="${2:-0}"
  log_event "SESSION_END" "{\"exit_code\":$exit_code,\"duration_seconds\":$duration}"
}

# Convenience: log a task lifecycle
log_task_start() {
  local task="${1:?log_task_start requires task name}"
  log_event "TASK_START" "{\"task\":\"$task\"}"
}

log_task_complete() {
  local task="${1:?log_task_complete requires task name}"
  local result="${2:-success}"
  log_event "TASK_COMPLETE" "{\"task\":\"$task\",\"result\":\"$result\"}"
}

log_task_skip() {
  local task="${1:?log_task_skip requires task name}"
  local reason="${2:-no work}"
  log_event "TASK_SKIP" "{\"task\":\"$task\",\"reason\":\"$reason\"}"
}

log_error() {
  local message="${1:?log_error requires message}"
  log_event "ERROR" "{\"message\":\"$message\"}"
}

log_checkpoint() {
  local label="${1:?log_checkpoint requires label}"
  log_event "CHECKPOINT" "{\"label\":\"$label\"}"
}
