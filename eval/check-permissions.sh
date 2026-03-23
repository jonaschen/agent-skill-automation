#!/bin/bash
# check-permissions.sh — Static permission validator for SKILL.md files
#
# Usage: check-permissions.sh <skill-md-path>
#
# Validates that a SKILL.md file follows the mutually exclusive permission rules:
#   1. Review/validation agents must NOT have Write or Edit in their tools list
#   2. Execution agents must NOT have Task in their tools list
#   3. The description field must NOT exceed 1024 characters
#
# Exit codes:
#   0 = all checks passed
#   1 = one or more violations found

set -euo pipefail

SKILL_PATH="${1:-}"
ERRORS=0

if [ -z "$SKILL_PATH" ]; then
  echo "❌ Usage: check-permissions.sh <skill-md-path>"
  exit 1
fi

if [ ! -f "$SKILL_PATH" ]; then
  echo "❌ File not found: $SKILL_PATH"
  exit 1
fi

SKILL_NAME=$(basename "$(dirname "$SKILL_PATH")" 2>/dev/null || basename "$SKILL_PATH" .md)
echo "🔍 Checking permissions for: $SKILL_PATH"
echo ""

# --- Extract YAML frontmatter ---
# Frontmatter is between the first and second '---' lines
FRONTMATTER=$(awk '/^---$/{n++; next} n==1{print} n==2{exit}' "$SKILL_PATH")

if [ -z "$FRONTMATTER" ]; then
  echo "❌ ERROR: No YAML frontmatter found (expected --- delimiters)"
  exit 1
fi

# --- Extract fields from frontmatter ---
# Write frontmatter to a temp file for reliable awk processing
TMPFM=$(mktemp)
echo "$FRONTMATTER" > "$TMPFM"

# Extract tools list (lines after 'tools:' that start with '  - ')
TOOLS=$(awk 'BEGIN{found=0} /^tools:/{found=1; next} found==1 && /^  - /{sub(/^  - /,""); print} found==1 && /^[a-z]/{exit}' "$TMPFM")

# Extract description (multiline, between 'description:' and next top-level field)
DESCRIPTION=$(awk 'BEGIN{found=0} /^description:/{found=1; sub(/^description:[> ]*/, ""); if (length($0) > 0) print; next} found==1 && /^  /{sub(/^  +/, ""); print} found==1 && /^[a-z]/{exit}' "$TMPFM")

# Extract name
NAME=$(grep '^name:' "$TMPFM" | sed 's/^name:[[:space:]]*//')

rm -f "$TMPFM"

echo "  Name: ${NAME:-<not found>}"
echo "  Tools: $(echo $TOOLS | tr '\n' ', ' | sed 's/,$//')"
echo ""

# --- Check 1: Description length ---
DESC_LENGTH=$(echo -n "$DESCRIPTION" | wc -c)
if [ "$DESC_LENGTH" -gt 1024 ]; then
  echo "❌ VIOLATION: Description exceeds 1024 characters ($DESC_LENGTH chars)"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Description length: $DESC_LENGTH chars (≤ 1024)"
fi

# --- Determine agent type from name/description ---
#
# Agent type classification:
#   Review/Validation: agents that assess/inspect without modifying
#     → must NOT have Write or Edit tools
#   Execution: agents that directly modify code/files/state
#     → must NOT have Task tool (prevents infinite delegation chains)
#   Orchestration: agents that design, route, or delegate (factory, router)
#     → MAY have both Write and Task (by design)
#
# Note: Orchestration agents like meta-agent-factory intentionally hold
# both Write and Task — they are system entry points, not execution endpoints.

IS_REVIEW_AGENT=0
IS_EXECUTION_AGENT=0

LOWER_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]')
LOWER_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]')

# Check if review/validation agent (read-only assessment role)
if echo "$LOWER_NAME" | grep -qE '(validat|review|audit|quality|check|inspect|analyz)'; then
  IS_REVIEW_AGENT=1
fi

# Check if execution agent (directly modifies code/files/state, NOT orchestration)
# Orchestration agents (factory, router, autoresearch-optimizer) are excluded —
# they design and delegate. autoresearch-optimizer needs Task for Phase 3
# parallel branch evaluations via sub-agents (per dev plan Section 3.3).
if echo "$LOWER_NAME" | grep -qE '(executor|builder|deploy)'; then
  IS_EXECUTION_AGENT=1
fi

# --- Check 2: Review/validation agents must NOT have Write or Edit ---
if [ "$IS_REVIEW_AGENT" -eq 1 ]; then
  echo "  Agent type: Review/Validation"

  if echo "$TOOLS" | grep -qiE '^(Write|Edit)$'; then
    VIOLATING_TOOLS=$(echo "$TOOLS" | grep -iE '^(Write|Edit)$' | tr '\n' ', ' | sed 's/,$//')
    echo "❌ VIOLATION: Review/validation agent has prohibited tools: $VIOLATING_TOOLS"
    echo "   Review agents must not have Write or Edit permissions"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ No Write/Edit tools found (correct for review agent)"
  fi
fi

# --- Check 3: Execution agents must NOT have Task ---
if [ "$IS_EXECUTION_AGENT" -eq 1 ]; then
  echo "  Agent type: Execution"

  if echo "$TOOLS" | grep -qiE '^Task$'; then
    echo "❌ VIOLATION: Execution agent has prohibited tool: Task"
    echo "   Execution agents must not have Task (prevents infinite delegation chains)"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ No Task tool found (correct for execution agent)"
  fi
fi

# --- Check 4: Validate frontmatter has required fields ---
if [ -z "$NAME" ]; then
  echo "❌ VIOLATION: Missing required field: name"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Required field 'name' present"
fi

if [ -z "$DESCRIPTION" ]; then
  echo "❌ VIOLATION: Missing required field: description"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Required field 'description' present"
fi

if [ -z "$TOOLS" ]; then
  echo "⚠️  WARNING: No tools defined in frontmatter"
fi

# Check model field
MODEL=$(echo "$FRONTMATTER" | grep -m1 '^model:' | sed 's/^model:[[:space:]]*//')
if [ -z "$MODEL" ]; then
  echo "⚠️  WARNING: No model specified in frontmatter"
else
  echo "✅ Model specified: $MODEL"
fi

# --- Summary ---
echo ""
echo "─────────────────────────────"
if [ "$ERRORS" -gt 0 ]; then
  echo "❌ FAILED: $ERRORS violation(s) found"
  exit 1
else
  echo "✅ PASSED: All permission checks passed"
  exit 0
fi
