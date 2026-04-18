# Skill Proposal: Shadow Eval Go/No-Go Criteria for Model Migration
**Date**: 2026-04-18
**Triggered by**: Night discussion 2026-04-18 (A2) — Opus 4.7 shadow eval needs quantitative acceptance criteria to prevent post-hoc rationalization
**Priority**: P0 (critical) — gates fleet-wide model migration
**Target Phase**: Phase 4 (operational hardening) + permanent addition to model migration runbook

## Rationale

The Opus 4.7 shadow eval is UNBLOCKED (breaking change audit CLEAN, `--model` flag ready). But prior discussions left the acceptance criteria vague ("compare CI against baseline"). Without explicit numeric gates, there's risk of:

1. **Post-hoc rationalization**: "the score dropped but the model is better overall"
2. **Inconsistent standards**: different humans applying different thresholds
3. **Silent regression**: a model change that passes human eyeballing but fails statistical tests

The night discussion converged on three quantitative gates. These should be documented in `eval/model_migration_runbook.md` as the permanent standard for any model migration, not just Opus 4.7.

## Proposed Specification

- **Name**: shadow-eval-go-nogo-criteria
- **Type**: Operational procedure (documented in migration runbook)
- **Description**: Quantitative go/no-go gates for model migration shadow eval
- **Location**: `eval/model_migration_runbook.md` — new section "Quantitative Go/No-Go Gates"

## Go/No-Go Gates

### GO (all must pass)

| Gate | Metric | Threshold | Rationale |
|------|--------|-----------|-----------|
| G1 | Bayesian CI overlap | New model CI overlaps with baseline CI [0.702, 0.927] | Statistical indistinguishability at our sample size (N=39). This is the primary gate — the Bayesian framework was designed for exactly this comparison. |
| G2 | Model-returned errors | Zero 400 errors from model (rate-limit retries excluded) | Any model-returned 400 indicates an undiscovered breaking change. Distinguish from infrastructure errors (network, rate limit) which are retry conditions. |
| G3 | Eval duration | Total duration within 2x baseline | Tokenizer inflation (1.35x expected) plus variance headroom. 2x allows for first-run effects. |

### NO-GO (any triggers hold)

| Gate | Metric | Threshold | Action |
|------|--------|-----------|--------|
| NG1 | Posterior mean | Drops below 0.75 | Significant quality regression — do not proceed. Investigate root cause before retrying. |
| NG2 | 400 errors | Any model-returned 400 (not rate-limit) | Undiscovered breaking change — grep for the triggering parameter, fix, re-run. |
| NG3 | Duration | Exceeds 2x baseline | Extreme token inflation — investigate tokenizer impact before proceeding. |

### Post-Migration Monitoring (if GO)

After passing go/no-go and beginning graduated rollout:
- **Days 1-4**: factory-steward only. Compare duration:commit ratio with 4.6 baseline.
- **Days 5-8**: Add researcher. Monitor for delegation pattern changes.
- **Days 9+**: Remaining agents. Full fleet on new model.
- **Rollback trigger**: Any agent shows >2x duration increase OR >30% delegation drop.

## Implementation Notes

- Add these gates as a new section in `eval/model_migration_runbook.md`
- The migration runbook already has steps 1-6 (positive/negative analysis, CI comparison, routing regression check). These gates formalize what was previously informal judgment.
- The CI overlap test (G1) is the **primary gate** per the Engineer's recommendation — drop the 0.05 point-estimate tolerance originally proposed. CI overlap already captures statistical significance.
- These gates are model-agnostic — they apply to Opus 4.7, Mythos, or any future model migration.

## Estimated Impact

- **Immediate**: Unblocks Opus 4.7 fleet rollout with clear pass/fail criteria
- **Permanent**: Every future model migration has a documented, repeatable, quantitative gate
- **Risk reduction**: Eliminates subjective "looks good enough" judgments from model migration decisions
