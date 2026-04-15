# Skill Update Proposal: Tool Description Priority Ordering in Factory-Steward Instructions
**Date**: 2026-04-16
**Triggered by**: Anthropic engineering blog "How we built our multi-agent research system" (2026-04-16) — measured 40% task completion time reduction from improved tool descriptions in Anthropic's own production system.
**Priority**: P1 (high)
**Target Phase**: Phase 3 / Phase 4 (optimizer calibration — applies now and forward)

## Rationale

Anthropic's engineering blog on their multi-agent research system discloses a controlled measurement:
improving tool/skill descriptions reduced task completion time by **40%** in their production system.
This is the same optimization axis our `autoresearch-optimizer` iterates on.

Currently, `.claude/agents/factory-steward.md` has no explicit instruction about *intervention priority
ordering*. The steward chooses between: (a) refining the SKILL.md description, (b) expanding the eval
set, and (c) adjusting thresholds — without a documented hierarchy of which lever to pull first.

Discussion consensus (2026-04-16 Round 1): Adopt the priority ordering, but **omit the 40% figure
from the agent instruction** (Engineer's note: the measurement is of task completion time in
Anthropic's research system, not trigger accuracy in our classifier — citing "40%" without context
causes engineers to misinterpret it as expected trigger rate gain). The *direction* is correct and
well-evidenced; the specific number should stay in research documentation.

## Proposed Change

Add the following section to `.claude/agents/factory-steward.md` (and optionally
`skill-quality-validator.md`) under a new `## Optimization Priority` heading:

```markdown
## Optimization Priority

When a Skill is below threshold (posterior mean < 0.90) or flagged for review,
intervene in this order:

1. **Description precision** (primary): Is the trigger description semantically precise?
   Does it correctly include all true-positive patterns and exclude all false-positive
   scenarios? Description quality is the highest-leverage optimization lever in
   multi-agent systems — empirically confirmed by production benchmarks.

2. **Eval set expansion** (secondary): Are there real-world prompts not represented
   in the test set? Add novel cases from `pending_cases/` or `logs/skill_usage.jsonl`
   before attributing low pass rate to description weakness.

3. **Threshold calibration** (tertiary): Only after confirming the description and
   eval set are sound. Threshold changes without description improvement treat the
   symptom, not the cause.

Never jump to eval set expansion or threshold tuning without first auditing whether
the description is semantically precise. A description that is imprecise cannot be
fixed by adding more tests.
```

## Implementation Notes

- Target file: `.claude/agents/factory-steward.md` (primary)
- Optional secondary target: `.claude/agents/skill-quality-validator.md`
- This is a documentation-only change to agent instructions — no code changes
- The 40% figure belongs in research KB and discussion files, NOT in agent instructions
- Source reference for research files: Anthropic engineering blog, April 2026 (URL in KB)

## Estimated Impact

- Permanently calibrates factory-steward intervention priority
- Prevents steward sessions from expanding eval set when description quality is the root cause
- Aligns our optimization approach with Anthropic's confirmed production findings
- Estimated implementation: 15-30 minutes (one paragraph addition to agent .md file)
