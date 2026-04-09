# Ready-to-Execute: Fleet Version Check Script

**Source proposal**: `knowledge_base/agentic-ai/proposals/2026-04-10-fleet-version-check.md`
**Priority**: P1
**Target**: factory-steward

## Task for factory-steward

Create the fleet version check infrastructure:

### 1. Create `scripts/lib/fleet_min_version.txt`
Contents: `2.1.97` (just the version string, no newline)

### 2. Create `scripts/lib/check_fleet_version.sh`
```bash
#!/usr/bin/env bash
# Fleet version check — warn on version mismatch, never block
# Sourced by all daily agent scripts

FLEET_MIN_VERSION_FILE="$(dirname "${BASH_SOURCE[0]}")/fleet_min_version.txt"

check_fleet_version() {
    local min_version
    min_version=$(<"$FLEET_MIN_VERSION_FILE" 2>/dev/null) || return 0
    local current_version
    current_version=$(claude --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1) || return 0

    # Compare versions using sort -V
    local lowest
    lowest=$(printf '%s\n%s\n' "$min_version" "$current_version" | sort -V | head -1)

    if [ "$lowest" = "$current_version" ] && [ "$current_version" != "$min_version" ]; then
        echo "[FLEET-VERSION] running=$current_version minimum=$min_version status=WARN — upgrade recommended"
    else
        echo "[FLEET-VERSION] running=$current_version minimum=$min_version status=OK"
    fi
}

check_fleet_version
```

### 3. Source from all 6 daily scripts
Add after the existing preamble (unset TERMINAL, cost ceiling) in each script:
```bash
# Fleet version check (warn, never block)
source "$(dirname "$0")/lib/check_fleet_version.sh" 2>/dev/null || true
```

**Affected files**:
- `scripts/daily_factory_steward.sh`
- `scripts/daily_research_sweep.sh`
- `scripts/daily_android_sw_steward.sh`
- `scripts/daily_arm_mrs_steward.sh`
- `scripts/daily_bsp_knowledge_steward.sh`
- `scripts/daily_project_reviewer.sh`
