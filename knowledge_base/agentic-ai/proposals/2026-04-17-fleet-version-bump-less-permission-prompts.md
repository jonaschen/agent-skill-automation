# Skill Proposal: Fleet Version Bump + `/less-permission-prompts` Pilot

**Date**: 2026-04-17
**Triggered by**: Claude Code v2.1.111 shipped `/less-permission-prompts` command (auto-generates permission allowlist from session transcript), `/effort` interactive slider, `xhigh` effort tier, `/ultrareview` command, `/tui` fullscreen, push notifications. Fleet minimum is >=2.1.101 (10 versions behind). Analysis §1.3; Discussion A4 (ADOPT P1).
**Priority**: **P1** (high — addresses recurring Pilot Run failure class)
**Target Phase**: Phase 4 (operational productivity)

## Rationale

Pilot Runs 3 and 4 (ROADMAP §Phase 4.2a) both blocked on mid-task permission prompts, requiring
hand-edited `.claude/settings.local.json` with wildcard Write/Edit allows. `/less-permission-prompts`
mechanizes exactly this operator workflow: analyzes session transcript, proposes an allowlist
minimizing mid-task interruptions.

**Discussion consensus (2026-04-17 Round 2)**:
- Version bump is mechanical; pilot has clear decision rule (compare output against existing allowlist)
- Watchout: `/less-permission-prompts` calibrates to the **specific session transcript** — a 10-skill pilot run exercises broader surface than a nightly steward run. That's correct (stress-test is upper bound) but note in commit message so future changes don't shrink the allowlist mistakenly
- Pair with `xhigh` effort tier (separate proposal) — both land in v2.1.111

## Proposed Specification

- **Name**: Fleet version bump + permission allowlist regeneration
- **Type**: Pipeline Configuration + Operator Tooling
- **Owner**: factory-steward

**Execution Sequence**:

**Step A — Version bump (today, 2026-04-17)**:
1. Edit `scripts/lib/fleet_min_version.txt` from `2.1.101` to `2.1.111`
2. Commit: `fleet: bump Claude Code minimum to 2.1.111 for /less-permission-prompts + xhigh effort tier`
3. Version-check script surfaces a fleet alert until the human upgrades the local Claude Code install
4. No other fleet action until human confirms upgrade

**Step B — Permission allowlist regeneration (after next successful 10-Skill pilot)**:
1. In the pilot session, run `/less-permission-prompts`
2. Save the proposed allowlist to `.claude/settings.local.json.less-permission-prompts-YYYY-MM-DD`
3. Diff against `.claude/settings.local.json.backup-pre-pilot5`:
   - **Narrower** (fewer / more-scoped allows) → replace as new baseline
   - **Broader** (more allows) → investigate why; possibly legitimate surface expansion; human review before replace
   - **Equivalent** → replace as documentation (cleaner provenance)
4. Commit the resulting `settings.local.json` with context in message:
   > `fleet: regenerate settings.local.json via /less-permission-prompts against 10-skill pilot run — broader-than-typical surface by design, do not shrink without re-running the pilot`
5. Archive the previous `settings.local.json.backup-pre-pilot5` to `.claude/settings.local.json.history/`

**Tools Required**: `/less-permission-prompts` (v2.1.111+, interactive); Bash for diff + commit

## Implementation Notes

**Dependencies**:
- Human-operator upgrade of local Claude Code install to ≥2.1.111 (no fleet auto-upgrade path)
- Step B gated on completion of next 10-Skill pilot (ROADMAP §Phase 4.2a Pilot Run 5 if not yet green, or 4.2a retrospective re-run)

**Risk**:
- Allowlist shrinkage: if a future developer regenerates allowlist against a narrow nightly session and replaces the pilot-calibrated baseline, we silently re-introduce the failure class from Pilot Runs 3/4. Mitigation: commit message discipline + `README.md` note in `.claude/` documenting the calibration source.
- False security: auto-generated allowlist is only as safe as the pilot session's legitimate tool use. Mitigation: human review before commit; keep `pre-pilot5` backup for rollback.

**Do NOT**:
- Use `/less-permission-prompts` output from a steward-only session as fleet baseline (narrow calibration)
- Shrink allowlist without re-running pilot
- Skip the diff step — always compare against current baseline

## Estimated Impact

- **Closes Pilot Run 3/4 failure class**: mid-task permission prompts should drop to near-zero on pilot-calibrated allowlist
- **Reproducible permission baseline**: operator-generated instead of hand-curated; documentable provenance
- **Fleet version modernization**: unlocks `xhigh` effort tier, `/effort` slider, `/ultrareview`, `/tui`, push notifications
- **Cost**: zero; v2.1.111 is free; `/less-permission-prompts` is interactive, no API cost
