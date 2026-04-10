# Skill Proposal: Fleet Version Check
**Date**: 2026-04-10
**Triggered by**: MCP memory leak fix (50 MB/hr), 429 retry burn fix, and permission bypass fixes in Claude Code v2.1.97 — fleet has no version verification mechanism
**Priority**: P1 (high)
**Target Phase**: Phase 4 (Security hardening)

## Rationale
Our 8 daily agent runs have no mechanism to verify which Claude Code version is executing. The v2.1.97 release fixes three operationally significant issues: MCP HTTP/SSE memory leak (50 MB/hr), 429 retry exhaustion (burning all retries in ~13s), and multiple permission bypasses (prototype collision, bash env hardening). An OS-level auto-update or missed manual update could silently regress the fleet. The 429 fix is particularly impactful since our eval scripts hit rate limits regularly.

## Proposed Specification
- **Name**: fleet-version-check (not a Skill — infrastructure script)
- **Type**: Shared library script
- **Description**: Pre-flight version check sourced by all daily agent scripts
- **Key Capabilities**:
  - Reads `claude --version` output at script start
  - Compares against minimum version in `scripts/lib/fleet_min_version.txt`
  - Warns (never blocks) on version mismatch — logged to script output
  - ~1s latency per check (negligible for 8 daily runs)
- **Files**:
  - `scripts/lib/check_fleet_version.sh` — the check function
  - `scripts/lib/fleet_min_version.txt` — contains `2.1.97` (minimum, not exact)

## Implementation Notes
- Use `>=` comparison, not `==`. Exact pinning requires manual updates on every patch release.
- Source from all 6 daily scripts after the existing preamble (unset TERMINAL, cost ceiling).
- Version parsing: `claude --version | grep -oP '\d+\.\d+\.\d+'` or equivalent.
- Log format: `[FLEET-VERSION] running=X.Y.Z minimum=A.B.C status=OK|WARN`

## Estimated Impact
- Prevents silent fleet degradation from version skew
- Single file (`fleet_min_version.txt`) to update when intentionally upgrading
- Warning logs provide audit trail of actual runtime versions
