# Skill Proposal: Opus 4.7 Shadow Eval + Graduated Fleet Rollout

**Date**: 2026-04-17
**Triggered by**: Claude Opus 4.7 shipped 2026-04-16 at flat pricing ($5/$25 per MTok, identical to 4.6) with +6.8pp SWE-bench Verified (87.6), 69.4 Terminal-Bench 2.0, 78.0 OSWorld-Verified, and new `xhigh` effort tier. Analysis §1.1; Discussion A1 (ADOPT P0).
**Priority**: **P0** (critical — free capability dividend, shrinking pre-I/O stability window)
**Target Phase**: Phase 3 (measurement discipline) → Phase 4 (fleet operation)

## Rationale

Opus 4.7 is a flat-price step-change release. Every day the fleet stays on 4.6 is an uncompensated
+6.8pp SWE-bench Verified gain left on the table, plus a new `xhigh` effort tier and Programmatic
Tool Calling GA (`code_execution_20260120`).

**Risk that blocks immediate rollout**: An uncalibrated model upgrade can silently shift trigger-routing
decisions. L7 in Lessons Learned (ROADMAP) documents how adding agents dropped T from 0.895 → 0.658
before vocabulary deconfliction. Model upgrades are a similar perturbation class. We must verify no
regression against our G8 Iter 2 baseline (T=0.895 / V=0.900) before fleet cascade.

**Discussion consensus (2026-04-17 Round 1)**:
- Shadow eval first, then graduated 4-day rollout starting with factory-steward
- CI-overlap (not `ci_lower ≥ old_ci_upper − 0.05`) is the stricter, more defensible non-regression rule
- Do **NOT** upgrade review-class agents — Sonnet 4.7 does not yet exist; validator/cicd-gate/changeling-router/watchdog stay on Sonnet 4.6
- Pre-I/O stability window (32 days) is the right moment; move faster on infra work than the typical 3-day cascade

## Proposed Specification

- **Name**: `opus-4-7-shadow-eval-rollout`
- **Type**: Pipeline Operation (multi-step, no new Skill)
- **Owner**: factory-steward

**Execution Sequence**:

| Step | Action | Gate | Owner Day |
|------|--------|------|-----------|
| 0 | Verify `--model` flag in `eval/run_eval_async.py`; audit bayesian_eval/experiment_log for model-identity dependencies | Pass = flag works; Fail = 30min–3hr engineering task | Day 0 |
| 1 | `python eval/run_eval_async.py --model claude-opus-4-7 --skill .claude/agents/meta-agent-factory.md --split T` | ~15 min compute | Day 0 |
| 2 | `python eval/bayesian_eval.py --compare` new_4.7 vs. old_4.6 baseline (T=0.895) | CI-overlap = no regression → PROCEED; CI disjoint + new lower → REGRESSION, open L10 re-baseline task | Day 0 |
| 3 | Update `.claude/agents/factory-steward.md` frontmatter `model: claude-opus-4-7`; commit; run nightly factory-steward | Nightly run exit 0 + performance JSON within normal distribution | Day 1 |
| 4 | Cascade: meta-agent-factory + autoresearch-optimizer → opus-4-7 | Overnight pass on T + V held at ≥0.85 | Day 2 |
| 5 | Cascade: agentic-ai-researcher + remaining stewards (android-sw/arm-mrs/bsp-knowledge/ltc) | 3 clean nightly runs per agent | Day 3 |
| 6 | Review: project-reviewer validates steward commits pre/post-upgrade quality on retrospective T=7d window | Steward review report notes no regression | Day 4 |

**Explicitly Untouched**:
- `skill-quality-validator` (Sonnet 4.6)
- `agentic-cicd-gate` (Sonnet 4.6)
- `changeling-router` (Sonnet 4.6)
- `watchdog` (Sonnet 4.6)
- Eval runner classifier (Haiku 4.5)

**Non-Regression Gate** (canonical rule):
- PROCEED iff `new_95%_CI` ∩ `old_95%_CI` ≠ ∅ **AND** `new_posterior_mean ≥ 0.85`
- BLOCK otherwise — file Phase 3 L10 re-baseline task (eval patterns calibrated to 4.6 output conventions may need re-alignment to 4.7)

**Tools Required**: existing eval infrastructure (run_eval_async.py, bayesian_eval.py, experiment_log.json)

## Implementation Notes

**Dependencies**:
- `eval/run_eval_async.py --model` flag — VERIFY in Step 0 (ROADMAP §6.6 references it but status unconfirmed)
- `eval/bayesian_eval.py --compare` — already implemented per CLAUDE.md Measurement Infrastructure
- `.claude/agents/*.md` frontmatter `model:` field — pattern established

**Risk**:
- Eval pattern drift: 4.7 may format markdown bold/verb phrasing differently than 4.6, giving false regression signal (L10 playbook already documents this)
- Cost: orchestration-class Opus 4.7 pricing identical to 4.6; zero cost delta at current fleet volume
- Blast radius: 10 agents × 15 nightly runs; mitigated by graduated rollout + factory-steward-first sequencing

**Do NOT**:
- Touch Sonnet or Haiku agents (no 4.7 variant exists)
- Skip Step 0 verification (assumed `--model` flag may not exist)
- Bypass bayesian comparison in favor of raw pass-rate (measurement noise will mask small regressions)

## Estimated Impact

- **Capability gain**: +6.8pp SWE-bench Verified on all orchestration agents (10 of 15 fleet agents)
- **New tuning knob**: `xhigh` effort tier available on all upgraded agents (see separate proposal)
- **Free expected value**: Flat pricing means rollout is zero-cost at our scale; only risk is regression
- **Architectural forcing function**: Establishes `--model` flag discipline for future model upgrades (Mythos public API if it lands, Sonnet 4.7 when it ships)
- **Pre-I/O posture**: Locks fleet to current-best before Google I/O (May 19-20) introduces vendor-surface churn
