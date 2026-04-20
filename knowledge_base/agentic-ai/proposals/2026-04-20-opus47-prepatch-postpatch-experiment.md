# Skill Proposal: Opus 4.7 Pre-Patch vs. Post-Patch Behavioral Baseline Experiment

**Date**: 2026-04-20
**Triggered by**: Night discussion A4 — Opus 4.7 adaptive reasoning tuning patch expected (#49562)
**Priority**: P3 (nice-to-have — zero marginal cost if pre-patch eval already running)
**Target Phase**: Phase 4 (S1 research output)
**Strategic Priority**: S1 — Automatic Agent/Skill Improvement

## Rationale

Opus 4.7's adaptive reasoning is the ONLY supported thinking mode — `budget_tokens` no longer accepted. Anthropic PM is "sprinting on tuning" (Apr 19). If a patch lands, it will change token consumption and potentially routing behavior. Running the shadow eval before and after the patch provides a natural experiment: same eval suite, same description, different model behavior.

This produces empirical data directly relevant to S1: "How does a model tuning patch affect agent routing accuracy?" The data also feeds the S2 paper as evidence of model-agent coupling dynamics.

## Proposed Specification

- **Name**: Not a new skill — this is an experiment design
- **Type**: Experiment (knowledge_base/agentic-ai/experiments/)
- **Key deliverable**: Quantitative comparison of Opus 4.7 routing accuracy pre-patch vs. post-patch

## Experiment Design

```markdown
# Experiment: Opus 4.7 Pre-Patch vs. Post-Patch Behavioral Baseline
**Date**: 2026-04-20
**Strategic Priority**: S1
**Hypothesis**: A model tuning patch that reduces token consumption will not significantly affect routing accuracy (CI overlap maintained)
**Method**:
  1. Pre-patch: Run shadow eval (already planned for migration — A1 manual run)
  2. Post-patch: When researcher detects Opus 4.7 patch (via #49562 monitoring), trigger another eval run
  3. Compare: Bayesian CI overlap, duration delta, token consumption delta
**Metrics**:
  - Posterior mean and 95% CI for both runs
  - Total duration (seconds)
  - Pass/fail count per test category (positive, negative, cross-domain)
  - If available: token count from eval runner output
**Compute Budget**: 2 eval runs (~88 min each, ~$2-3 API cost per run). Pre-patch run is the migration eval (zero marginal cost). Post-patch run: 1 additional invocation.
**Status**: design
**Trigger for post-patch run**: Researcher detects Opus 4.7 patch in sweep → notes in sweep report → shadow_eval.sh fires at 11:30 PM (if PENDING_MIGRATION_MODEL still set, results from pre-patch don't block re-run if model version changes)
```

## Implementation Notes

- Pre-patch data point = the shadow eval Jonas runs manually (A1) or that `daily_shadow_eval.sh` runs at 11:30 PM. Zero additional cost.
- Post-patch trigger: researcher monitors #49562. If Anthropic patches, note prominently in sweep report. Factory-steward or shadow eval script can re-run eval.
- Risk: patch may never come (#49562 has zero staff responses). Design costs nothing; pre-patch data is useful independently.
- If results show significant routing accuracy change from a tuning patch, this is a publishable finding about model-agent coupling.

## Estimated Impact

- **S1**: Empirical evidence about how model changes propagate to agent behavior — directly informs the "capability diff" research question
- **S2 paper**: Data point about model-agent coupling in heterogeneous fleet
- **Operational**: If post-patch routing changes significantly, we'll know to re-evaluate go/no-go criteria after model patches, not just after model releases
