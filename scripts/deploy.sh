#!/bin/bash
# scripts/deploy.sh
#
# Deploy a validated Skill through the full pipeline:
#   1. Run pre-deploy quality gate (Bayesian threshold check)
#   2. Copy Skill artifacts to the target location
#   3. Report deployment status
#
# Usage: ./scripts/deploy.sh <skill-name>
# Example: ./scripts/deploy.sh meta-agent-factory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PRE_DEPLOY="$REPO_ROOT/.claude/hooks/pre-deploy.sh"
SKILLS_DIR="$REPO_ROOT/.claude/skills"

SKILL_NAME="${1:-}"

if [ -z "$SKILL_NAME" ]; then
  echo "Usage: $0 <skill-name>" >&2
  echo "Available skills:" >&2
  ls "$SKILLS_DIR" 2>/dev/null | sed 's/^/  /' >&2
  exit 1
fi

SKILL_PATH="$SKILLS_DIR/$SKILL_NAME"

if [ ! -d "$SKILL_PATH" ]; then
  echo "Error: Skill '$SKILL_NAME' not found at $SKILL_PATH" >&2
  echo "Available skills:" >&2
  ls "$SKILLS_DIR" 2>/dev/null | sed 's/^/  /' >&2
  exit 1
fi

SKILL_MD="$SKILL_PATH/SKILL.md"
if [ ! -f "$SKILL_MD" ]; then
  echo "Error: No SKILL.md found in $SKILL_PATH" >&2
  exit 1
fi

echo "=== Deploying Skill: $SKILL_NAME ==="
echo ""

# Step 1: Run pre-deploy quality gate
echo "[1/3] Running pre-deploy quality gate..."
if ! bash "$PRE_DEPLOY" "$SKILL_PATH"; then
  echo ""
  echo "Deployment aborted: quality gate failed."
  echo "Run the autoresearch-optimizer to improve trigger accuracy before retrying."
  exit 1
fi

echo ""

# Step 2: Run permission check
echo "[2/3] Running permission validation..."
PERM_CHECK="$REPO_ROOT/eval/check-permissions.sh"
if [ -f "$PERM_CHECK" ]; then
  if ! bash "$PERM_CHECK" "$SKILL_MD"; then
    echo "Deployment aborted: permission check failed."
    exit 1
  fi
  echo "Permission check passed."
else
  echo "Warning: check-permissions.sh not found, skipping permission validation."
fi

echo ""

# Step 3: Record deployment
echo "[3/3] Recording deployment..."
DEPLOY_LOG="$REPO_ROOT/eval/deploy_log.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_SHA=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Append entry to deploy log
if [ ! -f "$DEPLOY_LOG" ]; then
  echo "[]" > "$DEPLOY_LOG"
fi

python3 -c "
import json, sys
log_path = '$DEPLOY_LOG'
with open(log_path) as f:
    log = json.load(f)
log.append({
    'skill': '$SKILL_NAME',
    'timestamp': '$TIMESTAMP',
    'git_sha': '$GIT_SHA',
    'status': 'deployed'
})
with open(log_path, 'w') as f:
    json.dump(log, f, indent=2)
"

echo ""
echo "=== Deployment complete ==="
echo "  Skill:     $SKILL_NAME"
echo "  Timestamp: $TIMESTAMP"
echo "  Git SHA:   $GIT_SHA"
