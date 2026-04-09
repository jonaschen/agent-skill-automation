#!/usr/bin/env bash
# changeling_validation.sh — Static validation of Changeling router infrastructure
#
# Validates:
# 1. All expected roles exist in the library
# 2. Each role .md has valid YAML frontmatter (name + description)
# 3. Routing table in changeling-router.md covers all library roles
# 4. No routing table keyword overlaps that would cause ambiguous routing
# 5. Context reset instructions are present in agent definition
#
# Exit codes: 0 = all pass, 1 = failures found

set -euo pipefail

ROLE_DIR="${HOME}/.claude/@lib/agents"
ROUTER_DEF="$(cd "$(dirname "$0")/.." && pwd)/.claude/agents/changeling-router.md"
PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS + 1)); echo "  [PASS] $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  [FAIL] $1"; }
warn() { WARN=$((WARN + 1)); echo "  [WARN] $1"; }

echo "========================================="
echo "  Changeling Router Validation"
echo "========================================="
echo ""

# --- Check 1: Role library exists and has roles ---
echo "--- Check 1: Role Library Completeness ---"

if [ ! -d "$ROLE_DIR" ]; then
    fail "Role library directory not found: $ROLE_DIR"
else
    role_count=$(ls "$ROLE_DIR"/*.md 2>/dev/null | wc -l)
    if [ "$role_count" -ge 20 ]; then
        pass "Role library has $role_count roles (target: >= 20)"
    else
        fail "Role library has $role_count roles (target: >= 20)"
    fi
fi

# --- Check 2: Each role has valid YAML frontmatter ---
echo ""
echo "--- Check 2: Role Frontmatter Validation ---"

roles_with_name=0
roles_without_name=0
roles_without_description=0

for role_file in "$ROLE_DIR"/*.md; do
    basename_file=$(basename "$role_file" .md)

    # Check for name field in frontmatter
    if grep -q "^name:" "$role_file" 2>/dev/null; then
        roles_with_name=$((roles_with_name + 1))
    else
        fail "Role '$basename_file' missing 'name:' in frontmatter"
        roles_without_name=$((roles_without_name + 1))
    fi

    # Check for description field
    if grep -q "^description:" "$role_file" 2>/dev/null; then
        : # ok
    else
        fail "Role '$basename_file' missing 'description:' in frontmatter"
        roles_without_description=$((roles_without_description + 1))
    fi
done

if [ "$roles_without_name" -eq 0 ] && [ "$roles_without_description" -eq 0 ]; then
    pass "All $roles_with_name roles have valid frontmatter (name + description)"
fi

# --- Check 3: Routing table covers all library roles ---
echo ""
echo "--- Check 3: Routing Table Coverage ---"

if [ ! -f "$ROUTER_DEF" ]; then
    fail "Router definition not found: $ROUTER_DEF"
else
    uncovered_roles=()
    covered_roles=()

    for role_file in "$ROLE_DIR"/*.md; do
        role_name=$(basename "$role_file" .md)
        # Check if role appears in routing table (backtick-quoted role name)
        if grep -q "\`$role_name\`" "$ROUTER_DEF" 2>/dev/null; then
            covered_roles+=("$role_name")
        else
            uncovered_roles+=("$role_name")
        fi
    done

    if [ ${#uncovered_roles[@]} -eq 0 ]; then
        pass "Routing table covers all ${#covered_roles[@]} library roles"
    else
        for role in "${uncovered_roles[@]}"; do
            fail "Role '$role' exists in library but missing from routing table"
        done
        pass "Routing table covers ${#covered_roles[@]}/${role_count} roles"
    fi
fi

# --- Check 4: Keyword overlap detection ---
echo ""
echo "--- Check 4: Routing Table Keyword Overlap ---"

if [ -f "$ROUTER_DEF" ]; then
    # Extract routing table rows: "| keywords | `role` |" pattern
    # Each row's keywords are comma-separated in the first column
    declare -A keyword_to_roles

    while IFS='|' read -r _ keywords role _; do
        # Clean up
        role=$(echo "$role" | sed 's/[^a-z-]//g' | xargs)
        [ -z "$role" ] && continue

        # Split keywords by comma
        IFS=',' read -ra kw_array <<< "$keywords"
        for kw in "${kw_array[@]}"; do
            kw=$(echo "$kw" | xargs | tr '[:upper:]' '[:lower:]')
            [ -z "$kw" ] && continue

            if [ -n "${keyword_to_roles[$kw]+x}" ]; then
                existing="${keyword_to_roles[$kw]}"
                if [ "$existing" != "$role" ]; then
                    warn "Keyword '$kw' shared between roles: $existing and $role"
                fi
            else
                keyword_to_roles[$kw]="$role"
            fi
        done
    done < <(grep '^\s*|.*|.*`' "$ROUTER_DEF" | grep -v '^|.*Domain Signals')

    total_keywords=${#keyword_to_roles[@]}
    if [ "$WARN" -eq 0 ]; then
        pass "No ambiguous keyword overlaps across $total_keywords keywords"
    else
        echo "  ($WARN overlaps found — may cause Phase B semantic disambiguation)"
    fi
fi

# --- Check 5: Context reset mechanism ---
echo ""
echo "--- Check 5: Context Reset Instructions ---"

if [ -f "$ROUTER_DEF" ]; then
    has_reset=0
    has_isolation=0

    grep -qi "context reset\|role switch\|context discarded" "$ROUTER_DEF" && has_reset=1
    grep -qi "context isolation\|never blend\|never reference" "$ROUTER_DEF" && has_isolation=1

    if [ "$has_reset" -eq 1 ]; then
        pass "Context reset instructions present in router definition"
    else
        fail "Missing context reset instructions in router definition"
    fi

    if [ "$has_isolation" -eq 1 ]; then
        pass "Context isolation constraints present in router definition"
    else
        fail "Missing context isolation constraints in router definition"
    fi
fi

# --- Check 6: Router model and tools ---
echo ""
echo "--- Check 6: Router Configuration ---"

if [ -f "$ROUTER_DEF" ]; then
    # Verify model assignment
    if grep -q "^model:" "$ROUTER_DEF"; then
        model=$(grep "^model:" "$ROUTER_DEF" | awk '{print $2}')
        pass "Router model configured: $model"
    else
        fail "No model configured for router"
    fi

    # Verify tools include Read, Glob, Grep (needed for role loading)
    for tool in Read Glob Grep; do
        if grep -q "  - $tool" "$ROUTER_DEF"; then
            : # ok
        else
            fail "Router missing required tool: $tool"
        fi
    done

    # Check Task tool for delegation
    if grep -q "  - Task" "$ROUTER_DEF"; then
        pass "Router has Task tool for delegation"
    else
        warn "Router missing Task tool — cannot delegate to loaded roles"
    fi
fi

# --- Summary ---
echo ""
echo "========================================="
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    echo "  VERDICT: FAIL — $FAIL issues must be resolved"
    exit 1
else
    echo "  VERDICT: PASS"
    exit 0
fi
