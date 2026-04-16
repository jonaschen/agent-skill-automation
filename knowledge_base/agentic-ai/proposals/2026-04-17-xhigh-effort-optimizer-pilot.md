# Skill Proposal: `xhigh` Effort Tier 3-Day Pilot on autoresearch-optimizer

**Date**: 2026-04-17
**Triggered by**: Claude Code v2.1.111 introduced `xhigh` effort tier between `high` and `max`, giving finer-grained reasoning budget control. Our optimizer handles the hardest prompts in the eval suite (hallucination traps test_23-39, cross-domain conflicts test_40-44, real-world negatives test_55-59). Analysis §1.3; Discussion A5 (ADOPT P1, contingent).
**Priority**: **P1** (high — pilot during pre-I/O stability window)
**Target Phase**: Phase 3 (measurement) / Phase 4 (operation)

## Rationale

The optimizer's hardest-prompt distribution is where extra reasoning budget has the highest marginal
value. Default effort was sufficient across all 6 agents per the 2026-04-11 effort-monitoring window
(ROADMAP §4.3), but that window didn't test the optimizer against marginal cross-domain cases. `xhigh`
sits between `high` and `max` — tests whether extra reasoning catches marginal cases without paying
full `max` cost.

**Scoping discipline (discussion)**:
- Optimizer-only, NOT fleet-wide (cost impact unquantified at fleet scale)
- 3-day window, monitored via existing `scripts/effort_impact_analysis.sh`
- Two-axis decision rule: (iterations-to-converge −20% **AND** cost increase ≤50%) → keep; else revert

**Engineer refinement (Round 2)**:
- **Verify invocation path first**. Analysis says "`/effort` interactive slider + new `xhigh` effort tier" — interactive-slider language suggests the tier may be exposed via in-session command, not environment variable.
- Step 0: `claude --help | grep -i effort` + v2.1.111 changelog to identify CLI invocation (env var vs `--effort` flag vs session-only)
- If CLI support is absent, defer pilot until CLI-native support lands

## Proposed Specification

- **Name**: Optimizer `xhigh` effort A/B pilot
- **Type**: Pipeline A/B Experiment
- **Owner**: factory-steward

**Execution Sequence**:

**Step 0 — Invocation path verification (today, 5 min)**:
1. `claude --help | grep -i effort`
2. Read v2.1.111 changelog for `--effort`, `CLAUDE_CODE_EFFORT`, or session-only references
3. Decision:
   - Env var supported → set in `scripts/daily_factory_steward.sh`
   - CLI flag supported → pass `--effort xhigh` to optimizer invocation
   - Session-only → **DEFER** pilot; file P2 follow-up to revisit when CLI support lands

**Step 1 — Instrument (Day 0, after Step 0 passes)**:
1. In `scripts/daily_factory_steward.sh`, wrap autoresearch-optimizer invocation only:
   ```bash
   CLAUDE_CODE_EFFORT=xhigh claude -p <optimizer prompt>
   # OR: claude -p --effort xhigh <optimizer prompt>
   ```
2. **Do NOT** apply to meta-agent-factory, researcher, or stewards
3. Commit with clear pilot scope: `fleet(pilot): xhigh effort on autoresearch-optimizer only, 3-day A/B, revert 2026-04-20`

**Step 2 — 3-day monitoring (Day 1-3)**:
1. `scripts/effort_impact_analysis.sh` runs nightly, captures:
   - `iterations_to_converge` per optimizer session
   - `session_duration_seconds` per session
   - API cost delta (if accessible via performance JSON)
2. Baseline: preceding 3-day window (default effort)

**Step 3 — Day 3 decision gate**:
- **KEEP** iff: `iterations_to_converge_xhigh < 0.80 × baseline_iterations` **AND** `cost_delta < 1.50 × baseline_cost`
- **REVERT** otherwise: remove env var / flag; commit revert with results in message

**Tools Required**: `scripts/effort_impact_analysis.sh` (already exists per ROADMAP §4.3)

## Implementation Notes

**Dependencies**:
- v2.1.111 installed on operator machine (gated by fleet-version-bump proposal A4)
- Invocation-path verification (Step 0) must pass before pilot starts
- `scripts/effort_impact_analysis.sh` updated if `experiment_log.json` lacks `iterations_to_converge` field (likely needs minor schema addition — see discussion R1 rejection note)

**Risk**:
- Cost blowout: `xhigh` between `high` and `max` — exact cost multiplier undocumented. 50% cost tolerance is generous but ceiling unknown. Mitigation: 3-day window keeps exposure bounded; REVERT rule enforces fast rollback.
- Measurement confound: if optimizer runs are sparse (some days 0 iterations, others many), 3-day window may have insufficient power. Mitigation: extend to 5 days if <10 optimizer sessions observed by Day 3.
- Invocation-path ambiguity: if `xhigh` is truly session-only, env-var-based pilot will silently use default effort (no-op). Mitigation: Step 0 verification is explicit gate.

**Do NOT**:
- Apply to any other agent (optimizer-only)
- Skip invocation-path verification
- Declare success on iterations drop alone (cost must also be bounded)

## Estimated Impact

- **Quality upside**: if validated, reduces G8-class skill convergence iterations by 20%+ — meaningful for skills currently hitting the 50-iteration ceiling
- **Cost visibility**: establishes measurement for `xhigh` economics ahead of any fleet-wide expansion
- **Forcing function**: requires `iterations_to_converge` as a tracked experiment-log field — data discipline we need anyway (Discussion R1 rejected the iteration-ceiling drop precisely because this data doesn't exist yet; this pilot forces it)
- **Pre-I/O timing**: cheap experiment during stability window; results inform ROADMAP Phase 3 acceptance-criteria revisions
