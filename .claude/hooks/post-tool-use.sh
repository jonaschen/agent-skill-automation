#!/bin/bash
# post-tool-use.sh — Post-deployment hook
#
# This hook runs after a tool execution (PostToolUse event).
# It deploys validated SKILL.md files to the .claude/ directory tree
# and logs deployment events for monitoring.
#
# Usage: post-tool-use.sh <skill-name> <source-path>
#
# Exit code 0 = success
# Exit code 1 = error

set -euo pipefail

SKILL_NAME="${1:-}"
SOURCE_PATH="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.claude/skills"
EVAL_DIR="$REPO_ROOT/eval"

if [ -z "$SKILL_NAME" ] || [ -z "$SOURCE_PATH" ]; then
  echo "ℹ️  post-tool-use.sh: No deployment action (no skill specified)"
  exit 0
fi

if [ ! -f "$SOURCE_PATH" ]; then
  echo "❌ Source file not found: $SOURCE_PATH"
  exit 1
fi

echo "📦 Post-tool-use: Deploying $SKILL_NAME"

# --- Step 1: Create target directory if needed ---
TARGET_DIR="$SKILLS_DIR/$SKILL_NAME"
mkdir -p "$TARGET_DIR/scripts" "$TARGET_DIR/references"

# --- Step 2: Copy SKILL.md to target ---
cp "$SOURCE_PATH" "$TARGET_DIR/SKILL.md"
echo "  ✅ Copied SKILL.md to $TARGET_DIR/"

# --- Step 3: Copy agent definition if it exists alongside the source ---
AGENT_SOURCE_DIR=$(dirname "$SOURCE_PATH")
AGENT_MD="$AGENT_SOURCE_DIR/../agents/$SKILL_NAME.md"
if [ -f "$AGENT_MD" ]; then
  cp "$AGENT_MD" "$REPO_ROOT/.claude/agents/$SKILL_NAME.md"
  echo "  ✅ Copied agent definition to .claude/agents/"
fi

# --- Step 4: Update .mcp.json if MCP config exists ---
MCP_CONFIG="$AGENT_SOURCE_DIR/mcp-config.json"
if [ -f "$MCP_CONFIG" ]; then
  echo "  ℹ️  MCP configuration detected — manual review required"
  echo "     Source: $MCP_CONFIG"
  echo "     Target: $REPO_ROOT/.mcp.json"
fi

# --- Step 5: Log deployment event ---
DEPLOY_LOG="$EVAL_DIR/deploy_history.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_SHA=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

if command -v python3 &>/dev/null; then
  python3 -c "
import json, os
deploy_log = '$DEPLOY_LOG'
entry = {
    'skill_name': '$SKILL_NAME',
    'timestamp': '$TIMESTAMP',
    'commit_sha': '$GIT_SHA',
    'action': 'post_deploy_copy',
    'source': '$SOURCE_PATH',
    'target': '$TARGET_DIR/SKILL.md'
}
if os.path.exists(deploy_log):
    with open(deploy_log, 'r') as f:
        data = json.load(f)
else:
    data = {'deployments': []}
data['deployments'].append(entry)
with open(deploy_log, 'w') as f:
    json.dump(data, f, indent=2)
" 2>/dev/null || echo "  ⚠️  Could not update deploy history"
fi

echo "  ✅ Deployment event logged"
echo ""
echo "📦 Deployment of $SKILL_NAME complete"
exit 0
