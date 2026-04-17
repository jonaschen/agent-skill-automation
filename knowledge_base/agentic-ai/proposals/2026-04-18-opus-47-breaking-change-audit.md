# Skill Proposal: Opus 4.7 Breaking Change Audit + Cost Ceiling Reset

**Date**: 2026-04-18
**Triggered by**: Opus 4.7 day 2 — full breaking change surface now documented (5 breaking changes, 3 with non-zero pipeline exposure). Analysis §1.1; Discussion 1.1 (ADOPT P0).
**Priority**: **P0** (critical — must complete BEFORE shadow eval from proposal 2026-04-17)
**Target Phase**: Phase 4 (operational hygiene)

## Rationale

Yesterday's proposal (`2026-04-17-opus-4-7-shadow-eval-rollout.md`) established the shadow eval + graduated rollout sequence. Today's analysis crystallizes the PREREQUISITE: a grep audit for deprecated API patterns must complete BEFORE the shadow eval runs. A stray `budget_tokens` or non-default `temperature` parameter would produce 400 errors during eval, which look like routing regressions (L10 lesson) and waste the entire eval run.

Additionally, the new tokenizer (1.0-1.35x more tokens for same content) will silently inflate the 30-day rolling average in `cost_ceiling.sh`. The Engineer's resolution: reset the rolling average window to 7 days post-adoption, then expand back to 30 after the new baseline stabilizes. This is simpler than adding a schema field to perf JSONs.

## Proposed Specification

- **Name**: `opus-47-breaking-change-audit`
- **Type**: Pipeline Operation (no new Skill)
- **Owner**: factory-steward (pre-flight)

**Execution Sequence**:

| Step | Action | Duration | Gate |
|------|--------|----------|------|
| 1 | `grep -rn 'temperature\|top_p\|top_k\|budget_tokens' scripts/ eval/ .claude/` | 2 min | Fix any hits (remove non-default values) |
| 2 | Verify no agent config or daily script passes explicit `budget_tokens` to `claude -p` | 5 min | Zero hits = PASS |
| 3 | Verify no thinking config uses `{type: "enabled", budget_tokens: N}` (must be `{type: "adaptive"}`) | 5 min | Zero hits = PASS |
| 4 | After 4.7 fleet rollout: reset `cost_ceiling.sh` rolling average window from 30 days to 7 days | 5 min | Document the reset in commit message |
| 5 | After 30 days on 4.7: expand rolling average window back to 30 days | — | Scheduled reminder |

**Relationship to existing proposals**:
- This is a PREREQUISITE to `2026-04-17-opus-4-7-shadow-eval-rollout.md` Step 1
- Must complete before shadow eval runs

## Implementation Notes

- The grep audit is trivially fast. The risk is discovering a non-default parameter deeply embedded in a script that isn't obvious.
- The cost ceiling reset is a one-line change to `scripts/lib/cost_ceiling.sh` (change `ROLLING_WINDOW_DAYS=30` to `7`).
- After 30 days, the 4.7-era cost data will be the dominant signal in the rolling average, and the window can safely expand back.

## Estimated Impact

- Prevents wasted shadow eval runs from 400 errors
- Prevents false cost ceiling alerts during tokenizer transition
- Zero new infrastructure; all changes are parameter adjustments
