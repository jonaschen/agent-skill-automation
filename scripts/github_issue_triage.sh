#!/bin/bash
# github_issue_triage.sh — Reads open GitHub issues and delegates to specialist agents
#
# Workflow:
#   1. Fetch open issues that haven't been triaged yet
#   2. For each issue, classify via keyword rules + Claude LLM fallback
#   3. Assign the appropriate agent label
#   4. Optionally delegate execution to the specialist agent
#
# Modes:
#   --dry-run     Show what would happen without making changes
#   --delegate    Actually invoke the specialist agent for each issue
#   --triage-only Label and comment but don't invoke agents (default)
#
# Usage:
#   ./scripts/github_issue_triage.sh                    # Triage-only mode
#   ./scripts/github_issue_triage.sh --dry-run          # Preview without changes
#   ./scripts/github_issue_triage.sh --delegate         # Triage + invoke agents
#
# Schedule: Can be added to cron (e.g., every 30 min or on-demand)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PERF_DIR="$REPO_ROOT/logs/performance"
DATE=$(date +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/issue-triage-${DATE}.log"
PERF_FILE="$PERF_DIR/issue-triage-${DATE}.json"
ROUTING_FILE="$SCRIPT_DIR/issue_routing.json"
CLAUDE="/home/jonas/.nvm/versions/node/v24.14.0/bin/claude"

mkdir -p "$LOG_DIR" "$PERF_DIR"

# --- Parse arguments ---
MODE="triage-only"
for arg in "$@"; do
  case "$arg" in
    --dry-run)   MODE="dry-run" ;;
    --delegate)  MODE="delegate" ;;
    --triage-only) MODE="triage-only" ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

START_TIME=$(date +%s)
ISSUES_PROCESSED=0
ISSUES_DELEGATED=0
ISSUES_SKIPPED=0
ISSUES_NEED_HUMAN=0

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "=== GitHub Issue Triage — $DATE (mode: $MODE) ==="

# --- Ensure labels exist ---
ensure_labels() {
  log "Ensuring agent routing labels exist on GitHub..."
  local labels
  labels=$(gh label list --json name -q '.[].name' 2>/dev/null || echo "")

  # Agent labels: name|color|description (pipe-delimited to avoid colon conflicts)
  local agent_labels=(
    "agent:meta-factory|0e8a16|Delegate to meta-agent-factory"
    "agent:validator|1d76db|Delegate to skill-quality-validator"
    "agent:optimizer|5319e7|Delegate to autoresearch-optimizer"
    "agent:cicd-gate|b60205|Delegate to agentic-cicd-gate"
    "agent:changeling|fbca04|Delegate to changeling-router"
    "agent:researcher|0075ca|Delegate to agentic-ai-researcher"
    "agent:android-sw|c5def5|Delegate to android-sw-steward"
    "agent:arm-mrs|d4c5f9|Delegate to arm-mrs-steward"
    "agent:bsp-knowledge|bfdadc|Delegate to bsp-knowledge-steward"
    "agent:factory|f9d0c4|Delegate to factory-steward"
    "agent:reviewer|fef2c0|Delegate to project-reviewer"
    "agent:topology|e99695|Delegate to topology-aware-router"
  )

  # Control labels
  local control_labels=(
    "triaged|c2e0c6|Issue has been triaged by automation"
    "needs-human|d93f0b|Automation could not classify — human review needed"
    "agent-wip|0e8a16|Agent is actively working on this issue"
    "agent-done|1d76db|Agent has completed work on this issue"
  )

  for entry in "${agent_labels[@]}" "${control_labels[@]}"; do
    IFS='|' read -r name color desc <<< "$entry"
    if ! echo "$labels" | grep -qx "$name"; then
      if [ "$MODE" != "dry-run" ]; then
        gh label create "$name" --color "$color" --description "$desc" 2>/dev/null || true
        log "  Created label: $name"
      else
        log "  [dry-run] Would create label: $name"
      fi
    fi
  done
}

# --- Rule-based classification ---
classify_by_rules() {
  local title="$1"
  local body="$2"
  local combined
  combined=$(echo "$title $body" | tr '[:upper:]' '[:lower:]')

  # Read keyword rules from routing config
  local num_rules
  num_rules=$(jq '.keyword_rules | length' "$ROUTING_FILE")

  for ((i=0; i<num_rules; i++)); do
    local pattern agent label
    pattern=$(jq -r ".keyword_rules[$i].pattern" "$ROUTING_FILE")
    agent=$(jq -r ".keyword_rules[$i].agent" "$ROUTING_FILE")
    label=$(jq -r ".keyword_rules[$i].label" "$ROUTING_FILE")

    if echo "$combined" | grep -qEi "$pattern"; then
      echo "$agent|$label"
      return 0
    fi
  done

  return 1
}

# --- LLM-based classification (fallback) ---
classify_by_llm() {
  local issue_number="$1"
  local title="$2"
  local body="$3"

  local agent_list
  agent_list=$(jq -r '.label_to_agent | to_entries[] | "\(.value): label \(.key)"' "$ROUTING_FILE" | tr '\n' '; ')

  local result
  result=$("$CLAUDE" --output-format json -p "You are a GitHub issue triage classifier. Given the issue below, determine which specialist agent should handle it.

Available agents:
$agent_list

Issue #${issue_number}: ${title}
Body: ${body}

Respond with ONLY a JSON object: {\"agent\": \"agent-name\", \"label\": \"agent:label-suffix\", \"confidence\": 0.0-1.0, \"reason\": \"one line\"}
If no agent fits, use {\"agent\": \"none\", \"label\": \"needs-human\", \"confidence\": 0.0, \"reason\": \"why\"}" 2>/dev/null)

  # Extract from Claude's response
  local agent label confidence
  agent=$(echo "$result" | jq -r '.result // .agent // empty' 2>/dev/null | jq -r '.agent // empty' 2>/dev/null || echo "")

  # Try direct JSON parse if nested extraction fails
  if [ -z "$agent" ]; then
    agent=$(echo "$result" | jq -r '.agent // empty' 2>/dev/null || echo "")
  fi

  label=$(echo "$result" | jq -r '.label // empty' 2>/dev/null || echo "")
  confidence=$(echo "$result" | jq -r '.confidence // 0' 2>/dev/null || echo "0")

  if [ -n "$agent" ] && [ "$agent" != "none" ] && [ "$agent" != "null" ]; then
    echo "$agent|$label|$confidence"
    return 0
  fi

  return 1
}

# --- Comment on issue ---
comment_issue() {
  local issue_number="$1"
  local agent="$2"
  local method="$3"  # "rule" or "llm"

  local body
  body="## Automated Triage

**Assigned agent:** \`${agent}\`
**Classification method:** ${method}
**Mode:** ${MODE}

This issue has been automatically classified and will be handled by the \`${agent}\` specialist agent.

---
*Triaged by [github_issue_triage.sh](../scripts/github_issue_triage.sh) on ${DATE}*"

  if [ "$MODE" != "dry-run" ]; then
    gh issue comment "$issue_number" --body "$body" 2>/dev/null || true
  else
    log "  [dry-run] Would comment on #$issue_number"
  fi
}

# --- Delegate to specialist agent ---
delegate_to_agent() {
  local issue_number="$1"
  local agent="$2"
  local title="$3"
  local body="$4"

  log "  Delegating #$issue_number to agent: $agent"

  if [ "$MODE" = "dry-run" ]; then
    log "  [dry-run] Would invoke $agent for issue #$issue_number"
    return 0
  fi

  # Mark as work-in-progress
  gh issue edit "$issue_number" --add-label "agent-wip" 2>/dev/null || true

  local agent_def="$REPO_ROOT/.claude/agents/${agent}.md"
  if [ ! -f "$agent_def" ]; then
    log "  WARNING: Agent definition not found: $agent_def"
    gh issue comment "$issue_number" --body "Agent definition \`${agent}.md\` not found. Escalating to human." 2>/dev/null || true
    gh issue edit "$issue_number" --add-label "needs-human" --remove-label "agent-wip" 2>/dev/null || true
    return 1
  fi

  # Invoke Claude with the specialist agent
  local agent_output
  agent_output=$(cd "$REPO_ROOT" && "$CLAUDE" --dangerously-skip-permissions -p "You are the ${agent} agent. Read .claude/agents/${agent}.md for your full instructions.

A GitHub issue has been assigned to you for resolution.

Issue #${issue_number}: ${title}

${body}

Instructions:
1. Analyze this issue and determine what changes are needed
2. Make the necessary code changes in the repository
3. Commit your changes with a message referencing the issue: 'fix(#${issue_number}): <description>'
4. Summarize what you did

IMPORTANT: Only make changes within your area of expertise. If this issue is outside your scope, say so." 2>> "$LOG_FILE") || true

  # Post result as comment
  local result_comment
  result_comment="## Agent Work Complete

**Agent:** \`${agent}\`

### Summary
${agent_output:0:3000}

---
*Executed by \`${agent}\` via [github_issue_triage.sh](../scripts/github_issue_triage.sh)*"

  gh issue comment "$issue_number" --body "$result_comment" 2>/dev/null || true
  gh issue edit "$issue_number" --remove-label "agent-wip" --add-label "agent-done" 2>/dev/null || true

  ISSUES_DELEGATED=$((ISSUES_DELEGATED + 1))
  log "  Completed delegation for #$issue_number"
}

# --- Main triage loop ---
main() {
  ensure_labels

  log "Fetching open, untriaged issues..."

  # Get open issues that don't have the 'triaged' label
  local issues
  issues=$(gh issue list --state open --json number,title,body,labels --limit 50 2>/dev/null || echo "[]")

  local total
  total=$(echo "$issues" | jq 'length')
  log "Found $total open issues"

  if [ "$total" -eq 0 ]; then
    log "No open issues to triage."
    write_perf_record
    return 0
  fi

  # Process each issue (use process substitution to avoid subshell counter loss)
  while IFS= read -r issue; do
    local number title body labels
    number=$(echo "$issue" | jq -r '.number')
    title=$(echo "$issue" | jq -r '.title')
    body=$(echo "$issue" | jq -r '.body // ""')
    labels=$(echo "$issue" | jq -r '[.labels[].name] | join(",")')

    # Skip already-triaged issues
    if echo "$labels" | grep -q "triaged"; then
      log "  #$number: already triaged, skipping"
      ISSUES_SKIPPED=$((ISSUES_SKIPPED + 1))
      continue
    fi

    # Skip issues already assigned to an agent
    if echo "$labels" | grep -q "agent:"; then
      log "  #$number: already assigned to agent, skipping"
      ISSUES_SKIPPED=$((ISSUES_SKIPPED + 1))
      continue
    fi

    log "Processing #$number: $title"
    ISSUES_PROCESSED=$((ISSUES_PROCESSED + 1))

    # Try rule-based classification first
    local classification=""
    local method="rule"
    classification=$(classify_by_rules "$title" "$body") || true

    # Fall back to LLM classification
    if [ -z "$classification" ]; then
      method="llm"
      log "  Rule-based: no match. Trying LLM classification..."
      classification=$(classify_by_llm "$number" "$title" "$body") || true
    fi

    if [ -n "$classification" ]; then
      local agent label
      agent=$(echo "$classification" | cut -d'|' -f1)
      label=$(echo "$classification" | cut -d'|' -f2)

      log "  Classified → agent=$agent, label=$label (method=$method)"

      if [ "$MODE" != "dry-run" ]; then
        gh issue edit "$number" --add-label "$label" --add-label "triaged" 2>/dev/null || true
      fi

      comment_issue "$number" "$agent" "$method"

      # Delegate if in delegate mode
      if [ "$MODE" = "delegate" ]; then
        delegate_to_agent "$number" "$agent" "$title" "$body"
      fi
    else
      log "  Could not classify #$number — marking for human review"
      ISSUES_NEED_HUMAN=$((ISSUES_NEED_HUMAN + 1))

      if [ "$MODE" != "dry-run" ]; then
        gh issue edit "$number" --add-label "needs-human" --add-label "triaged" 2>/dev/null || true
        gh issue comment "$number" --body "## Needs Human Review

This issue could not be automatically classified to a specialist agent. Please review and assign manually.

Available agent labels: $(jq -r '.label_to_agent | keys | join(", ")' "$ROUTING_FILE")

---
*Triaged by [github_issue_triage.sh](../scripts/github_issue_triage.sh) on ${DATE}*" 2>/dev/null || true
      fi
    fi
  done < <(echo "$issues" | jq -c '.[]')

  write_perf_record
}

# --- Performance record ---
write_perf_record() {
  local END_TIME
  END_TIME=$(date +%s)
  local DURATION=$((END_TIME - START_TIME))

  cat > "$PERF_FILE" << EOF
{
  "agent": "github-issue-triage",
  "date": "$DATE",
  "mode": "$MODE",
  "duration_seconds": $DURATION,
  "issues_processed": $ISSUES_PROCESSED,
  "issues_delegated": $ISSUES_DELEGATED,
  "issues_skipped": $ISSUES_SKIPPED,
  "issues_need_human": $ISSUES_NEED_HUMAN,
  "exit_code": 0
}
EOF

  log "Performance record written to $PERF_FILE"
  log "=== Triage complete: processed=$ISSUES_PROCESSED delegated=$ISSUES_DELEGATED skipped=$ISSUES_SKIPPED need_human=$ISSUES_NEED_HUMAN ==="

  # 30-day log retention
  find "$LOG_DIR" -name "issue-triage-*.log" -mtime +30 -delete 2>/dev/null || true
  find "$PERF_DIR" -name "issue-triage-*.json" -mtime +30 -delete 2>/dev/null || true
}

main
