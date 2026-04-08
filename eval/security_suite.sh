#!/bin/bash
# eval/security_suite.sh — Unified security check aggregator
#
# Runs all security checks in sequence and produces a versioned JSON report.
# Replaces individual script invocations in pre-deploy.sh and closed_loop.sh.
#
# Checks included:
#   1. check-permissions.sh      — Agent permission validation (mutually exclusive tools)
#   2. mcp_config_validator.sh   — MCP config + content scanning + hash pinning
#   3. model_deprecation_check.sh — Deprecated model reference detection
#   4. npm audit (if package-lock.json exists) — Dependency vulnerability scan
#
# Usage:
#   bash eval/security_suite.sh [skill-path] [mcp-config-path]
#   Default skill-path: scans all agents in .claude/agents/
#   Default mcp-config: .mcp.json
#
# Output: JSON report to stdout + human-readable summary to stderr
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SKILL_PATH="${1:-}"
MCP_CONFIG="${2:-$REPO_ROOT/.mcp.json}"
REPORT_VERSION="1.0"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CHECKS=()
OVERALL="pass"
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
START_TIME=$(date +%s%N 2>/dev/null || date +%s)

# Helper: run a check and capture result
run_check() {
  local name="$1"
  local script="$2"
  shift 2
  local args=("$@")

  local status="pass"
  local details=""
  local check_start
  check_start=$(date +%s%N 2>/dev/null || date +%s)

  if [ ! -f "$script" ] && [ "$name" != "dependency_audit" ]; then
    status="skip"
    details="Script not found: $script"
    echo "  SKIP: $name — $details" >&2
  else
    local output=""
    local exit_code=0
    set +e
    output=$("${args[@]}" 2>&1)
    exit_code=$?
    set -e

    if [ $exit_code -ne 0 ]; then
      status="fail"
      OVERALL="fail"
      TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi

    # Count warnings in output
    local warn_count
    warn_count=$(echo "$output" | grep -ciE '(WARNING|WARN):' || true)
    if [ "$warn_count" -gt 0 ] && [ "$status" = "pass" ]; then
      status="warn"
      TOTAL_WARNINGS=$((TOTAL_WARNINGS + warn_count))
    fi

    # Capture last 5 lines as details (trim for JSON safety)
    details=$(echo "$output" | tail -5 | tr '\n' ' | ' | sed 's/ | $//' | sed 's/"/\\"/g' | head -c 500)
  fi

  local check_end
  check_end=$(date +%s%N 2>/dev/null || date +%s)
  local duration_ms=0
  if [[ "$check_start" =~ [0-9]{10,} ]] && [[ "$check_end" =~ [0-9]{10,} ]]; then
    duration_ms=$(( (check_end - check_start) / 1000000 ))
  fi

  CHECKS+=("{\"name\":\"$name\",\"script\":\"$(basename "$script" 2>/dev/null || echo "$name")\",\"status\":\"$status\",\"duration_ms\":$duration_ms,\"details\":\"$details\"}")
  echo "  $status: $name" >&2
}

echo "Security Suite v${REPORT_VERSION} — $(date -u +%Y-%m-%dT%H:%M:%SZ)" >&2
echo "─────────────────────────────────────────" >&2

# --- Check 1: Permission validation ---
# If a specific skill path is given, check that. Otherwise check all agents.
if [ -n "$SKILL_PATH" ] && [ -f "$SKILL_PATH" ]; then
  run_check "permissions" "$SCRIPT_DIR/check-permissions.sh" \
    bash "$SCRIPT_DIR/check-permissions.sh" "$SKILL_PATH"
else
  # Check all agent definitions
  PERM_STATUS="pass"
  PERM_OUTPUT=""
  AGENT_DIR="$REPO_ROOT/.claude/agents"
  if [ -d "$AGENT_DIR" ]; then
    PERM_FAIL=0
    for agent_file in "$AGENT_DIR"/*.md; do
      [ -f "$agent_file" ] || continue
      set +e
      result=$(bash "$SCRIPT_DIR/check-permissions.sh" "$agent_file" 2>&1)
      rc=$?
      set -e
      if [ $rc -ne 0 ]; then
        PERM_FAIL=$((PERM_FAIL + 1))
        PERM_OUTPUT="$PERM_OUTPUT$(basename "$agent_file"): FAIL; "
      fi
    done
    if [ $PERM_FAIL -gt 0 ]; then
      PERM_STATUS="fail"
      OVERALL="fail"
      TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    fi
    agent_count=$(find "$AGENT_DIR" -name '*.md' | wc -l)
    details_text="Checked $agent_count agents, $PERM_FAIL failures. $PERM_OUTPUT"
    details_text=$(echo "$details_text" | sed 's/"/\\"/g' | head -c 500)
    CHECKS+=("{\"name\":\"permissions\",\"script\":\"check-permissions.sh\",\"status\":\"$PERM_STATUS\",\"duration_ms\":0,\"details\":\"$details_text\"}")
    echo "  $PERM_STATUS: permissions ($agent_count agents checked)" >&2
  else
    CHECKS+=("{\"name\":\"permissions\",\"script\":\"check-permissions.sh\",\"status\":\"skip\",\"duration_ms\":0,\"details\":\"No .claude/agents/ directory found\"}")
    echo "  skip: permissions (no agents directory)" >&2
  fi
fi

# --- Check 2: MCP config validation ---
if [ -f "$MCP_CONFIG" ]; then
  run_check "mcp_config" "$SCRIPT_DIR/mcp_config_validator.sh" \
    bash "$SCRIPT_DIR/mcp_config_validator.sh" "$MCP_CONFIG"
else
  CHECKS+=("{\"name\":\"mcp_config\",\"script\":\"mcp_config_validator.sh\",\"status\":\"skip\",\"duration_ms\":0,\"details\":\"No .mcp.json found\"}")
  echo "  skip: mcp_config (no .mcp.json)" >&2
fi

# --- Check 3: Model deprecation ---
run_check "model_deprecation" "$SCRIPT_DIR/model_deprecation_check.sh" \
  bash "$SCRIPT_DIR/model_deprecation_check.sh"

# --- Check 4: Dependency audit ---
if [ -f "$REPO_ROOT/package-lock.json" ]; then
  run_check "dependency_audit" "npm" \
    npm audit --audit-level=high --prefix "$REPO_ROOT"
else
  CHECKS+=("{\"name\":\"dependency_audit\",\"script\":\"npm audit\",\"status\":\"skip\",\"duration_ms\":0,\"details\":\"No package-lock.json found\"}")
  echo "  skip: dependency_audit (no package-lock.json)" >&2
fi

# --- Build JSON report ---
END_TIME=$(date +%s%N 2>/dev/null || date +%s)
TOTAL_DURATION_MS=0
if [[ "$START_TIME" =~ [0-9]{10,} ]] && [[ "$END_TIME" =~ [0-9]{10,} ]]; then
  TOTAL_DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))
fi

# Join checks array
CHECKS_JSON=""
for i in "${!CHECKS[@]}"; do
  if [ "$i" -gt 0 ]; then
    CHECKS_JSON="$CHECKS_JSON,"
  fi
  CHECKS_JSON="$CHECKS_JSON${CHECKS[$i]}"
done

cat << EOF
{
  "version": "$REPORT_VERSION",
  "timestamp": "$TIMESTAMP",
  "checks": [$CHECKS_JSON],
  "overall": "$OVERALL",
  "total_errors": $TOTAL_ERRORS,
  "total_warnings": $TOTAL_WARNINGS,
  "duration_ms": $TOTAL_DURATION_MS
}
EOF

echo "─────────────────────────────────────────" >&2
echo "Overall: $OVERALL ($TOTAL_ERRORS errors, $TOTAL_WARNINGS warnings)" >&2

if [ "$OVERALL" = "fail" ]; then
  exit 1
fi

exit 0
