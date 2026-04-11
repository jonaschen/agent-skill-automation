# Skill Proposal: Fleet Version Check Enhancement + Bump to >=2.1.101

**Date**: 2026-04-12
**Triggered by**: Claude Code v2.1.101 fleet analysis (sweep 2026-04-12, Section 1.4); P0 upgrade escalated for 3 days
**Priority**: P1 (high — makes P0 upgrade urgency more visible)
**Target Phase**: Phase 4.4 (Security Hardening)

## Rationale

The fleet version gap has been escalated as P0 since April 10 (3 days) and remains
unresolved. v2.1.101 fixes:
- Memory leak for long sessions (historical message copies) — affects multi-hour stewards
- `permissions.deny` rules no longer overridden by PreToolUse hooks — security model integrity
- Subagent MCP tool inheritance from dynamically-injected servers — Phase 5 prerequisite
- Command injection fix in POSIX `which` fallback — security
- OS CA certificate store trust by default — enterprise compatibility

Current `fleet_min_version.txt` is `>=2.1.98`. Three additional security-relevant fixes
in v2.1.99-2.1.101 justify bumping. The discussion consensus: bump the version, add fleet
status to the agent review dashboard, write structured JSON alerts.

## Proposed Specification

- **Name**: fleet-version-enhancement (pipeline hardening, not a Skill)
- **Type**: Script enhancements
- **Components**:
  1. Update `scripts/lib/fleet_min_version.txt` from `>=2.1.98` to `>=2.1.101`
  2. Enhance `scripts/lib/check_fleet_version.sh`:
     - Write structured JSON alert to `logs/security/fleet_version.jsonl` on every mismatch
     - Include fields: `timestamp`, `current_version`, `min_required`, `gap_versions`, `days_since_escalation`
  3. Enhance `scripts/agent_review.sh` dashboard:
     - Add "Fleet Version" section showing current vs. required version
     - Show days since first escalation (track from `fleet_version.jsonl` first entry)
  4. No escalation automation (single-machine setup; Jonas sees dashboard directly)

## Implementation Notes

- `fleet_min_version.txt` is already sourced by all 7 daily scripts
- `check_fleet_version.sh` currently warns to stderr — add JSON append alongside
- Dashboard integration: read latest `fleet_version.jsonl` entry for version status
- Estimated effort: 30-60 minutes

## Estimated Impact

- **Visibility**: P0 upgrade urgency visible in every dashboard review
- **Tracking**: Structured history of version gap for trend analysis
- **Pressure**: "Days since escalation" counter makes inaction visible
- **Security**: v2.1.101 closes two independent leak vectors and one permission bypass
