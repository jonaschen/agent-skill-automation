# Skill Proposal: Per-Run Duration-Based Cost Ceiling
**Date**: 2026-04-07
**Triggered by**: MCP 658x cost amplification threat + lack of any per-run cost guardrail in nightly fleet (analysis 2026-04-07)
**Priority**: P0 (critical)
**Target Phase**: 4 (Security Hardening)
**Status**: ADOPT (discussion consensus — Round 1, Proposal 1.2)

## Rationale

Even without MCP attacks, our nightly fleet has no cost guardrail. A bug, infinite loop, or model behavior change could cause runaway spending. The 658x cost amplification finding makes this urgent, but the underlying gap (no ceiling) is dangerous regardless of attack vector.

Current steward scripts record `duration` and `exit_code` in performance JSON but lack cost estimation. Using duration as a cost proxy is pragmatic: duration correlates well with cost for the same model, and it avoids the complexity of parsing token usage output.

## Proposed Implementation

**Not a new Skill/Agent** — this is a shared library for steward scripts.

- **New file**: `scripts/lib/cost_ceiling.sh` — shared function sourced by all 6 `daily_*.sh` scripts.
- **Mechanism**:
  1. Read last 30 days of duration from `logs/performance/<agent>-*.json`.
  2. Compute 30-day rolling average duration.
  3. Set ceiling at `MAX_DURATION_MULTIPLIER=5` times the average.
  4. For first run (no history): hardcoded fallback ceiling of 3600 seconds (1 hour).
  5. After run completes: check actual duration against ceiling.
  6. If exceeded: write warning to `logs/security/cost_alert.jsonl` with agent name, actual duration, ceiling, and multiplier.
- **Rollout**: Test on `daily_factory_steward.sh` first (runs 3x/day, fastest feedback loop), then roll to all 6 scripts.

## Implementation Notes

- Duration-based proxy is v1. Future v2 could parse actual token counts from Claude output for precise cost tracking.
- The 5x multiplier is generous — normal variance is <2x. The 5x ceiling catches catastrophic runaways, not normal fluctuation.
- This is a reactive check (post-run), not a preventive one (mid-run abort). The MCP depth monitor (Proposal 1.1) provides mid-run prevention. Together they form a defense-in-depth pair.
- Requires `jq` for JSON parsing — already available on the system.

## Estimated Impact

- **Financial safety**: Caps worst-case nightly fleet cost to 5x the historical average, preventing >$10,000 runaways.
- **Operational**: Creates a duration baseline that enables future anomaly detection.
- **Data foundation**: The duration history enables trend analysis and capacity planning.
