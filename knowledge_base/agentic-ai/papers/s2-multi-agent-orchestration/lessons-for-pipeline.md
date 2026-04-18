# Lessons from the Paper Competition: Improvements for the Research Pipeline

**Date**: 2026-04-18
**Source**: S2 paper project + Reviewer 1 & 2 feedback + Gemini team comparison

---

## What This Exercise Revealed

The paper competition exposed five concrete gaps in our research capability.
These aren't theoretical — they showed up as weaknesses in our paper and as
advantages Gemini exploited.

---

## Gap 1: We Can Collect Data But Can't Analyze It Programmatically

**Evidence**: The experiment-designer had to write one-off Python scripts in Bash
to extract statistics from performance JSONs and discussion transcripts. There's
no reusable analysis toolkit.

**Fix**: Build `scripts/research_analysis.py` — a CLI tool that:
- Extracts performance data: `./research_analysis.py perf --agent researcher --since 2026-04-04`
- Parses discussion metrics: `./research_analysis.py debates --compute-ratios`
- Runs statistical tests: `./research_analysis.py compare --agent1 researcher --agent2 factory`
- Outputs both human-readable tables and JSON for paper figures

**Priority**: P1 — this makes every future paper and research review faster.

---

## Gap 2: No Formal Experiment Infrastructure

**Evidence**: The `experiments/` directory was empty until today. Experiment
protocols had to be written from scratch. No standard way to register, run, and
track experiments.

**Fix**: Establish experiment conventions:
- Protocol template already exists (created today) — standardize it
- Add `experiments/registry.md` tracking all experiments with status
- Ensure experiment-designer agent runs as part of research cycles when
  experiments are in "data-collection" or "analysis" status

**Priority**: P2 — foundations laid today, needs hardening.

---

## Gap 3: Gemini Identified a Real Failure Mode We Missed (Freezer Effect)

**Evidence**: Our BSG deployment gate (`new_ci_lower > old_ci_upper`) can stall
exploration when the baseline is strong (posterior_mean >= 0.95). At that level,
even genuine improvements may not produce non-overlapping CIs with small sample
sizes. This is the Freezer Effect.

**Fix**: Research and prototype Hybrid Elastic Gating:
- Define Structural Novelty Score concretely (what measurable properties of a
  SKILL.md change qualify as "structurally novel"?)
- Implement threshold relaxation in `bayesian_eval.py` for novel changes
- Test with the autoresearch-optimizer on a skill near the 0.95 ceiling

**Priority**: P1 — this is a genuine improvement to our core measurement infrastructure.

---

## Gap 4: Paper Writing Needs Iteration, Not One-Shot

**Evidence**: The paper-synthesizer produced a solid first draft but:
- Abstract was deferred (reviewer flagged as hard blocker)
- Experiment 3 was listed as active RQ but incomplete (reviewer caught this)
- Literature review could be deeper on specific subcategories

**Fix**: The paper pipeline should support iterative revision:
- Add a `--revise` mode to `paper_pipeline.sh` that reads reviewer feedback
  from `reviews/` and applies targeted fixes
- Paper-synthesizer should have a "revision checklist" mode that reads reviews
  and addresses each point systematically

**Priority**: P3 — nice to have for future papers, not urgent.

---

## Gap 5: Cross-Team Competition Produces Better Research Than Solo Work

**Evidence**: This entire exercise forced us to:
- Build experiment infrastructure we'd been deferring
- Write with academic rigor (CIs, effect sizes, threats to validity)
- Confront gaps we'd been ignoring (Freezer Effect, N=1 research-lead)
- Produce a 523-line paper in a single afternoon

The competitive pressure from Gemini — even though their paper had integrity
issues — pushed our quality higher than any internal review would have.

**Fix**: Make cross-team research a recurring pattern:
- Schedule periodic "research sprints" where both teams tackle the same question
- Use peer-reviewer agent for cross-team review
- Track which team surfaces more unique insights over time (Experiment 3 data)

**Priority**: P2 — strategic capability, not immediate.

---

## Implementation Roadmap

| # | Gap | Fix | Priority | Owner |
|---|-----|-----|----------|-------|
| 1 | No analysis toolkit | `scripts/research_analysis.py` | P1 | factory-steward |
| 2 | No experiment infrastructure | Harden protocols + registry | P2 | factory-steward |
| 3 | Freezer Effect unaddressed | Research + prototype HEG | P1 | researcher + factory |
| 4 | Paper needs iteration support | `--revise` mode for pipeline | P3 | factory-steward |
| 5 | Competition improves quality | Recurring cross-team sprints | P2 | research-lead |
