# Shadow Eval Re-Run Protocol — Post CC v2.1.117 Upgrade

**Date**: 2026-04-22
**Source**: Discussion 2026-04-22-afternoon A1 (P1, S1 critical path)
**Status**: Waiting on Jonas CC upgrade to v2.1.117
**Feeds**: S1 shadow eval pipeline, model migration go/no-go decision

## Background

The shadow eval for Opus 4.7 returned **NO-GO at 0.683** (CI [0.535, 0.814]), with 12/39
training tests failing. However, CC v2.1.117 (released Apr 22) reveals that CC was computing
Opus 4.7's context window against **200K instead of 1M**, causing premature autocompacting.
This means the 0.683 baseline is **contaminated by a CC bug** — some or all failures may
have been caused by context truncation, not Opus 4.7 model behavior.

A clean re-run after upgrading CC is required to disambiguate CC-bug failures from genuine
Opus 4.7 regressions.

## Pre-Requisites

- [ ] Jonas upgrades CC to v2.1.117+ (blocks everything below)
- [ ] Verify upgrade: `claude --version` shows >=2.1.117
- [ ] Existing infrastructure ready:
  - Per-test result logging: ✅ (commit 79c98c7, `--verbose` flag)
  - Prefix match trigger: ✅ (commit 6e70617, `claude-opus-4-7*` pattern)
  - Prompt cache model isolation: ✅ (commit from 2026-04-19, model ID in cache key)

## Re-Run Procedure

### Step 1: Reset for Clean Run

Clear the existing Opus 4.7 entry from `experiment_log.json` so the shadow eval cron
re-fires, OR run manually:

```bash
# Option A: Manual run (recommended for immediate results)
cd /home/jonas/gemini-home/agent-skill-automation
python3 eval/run_eval_async.py \
  --verbose \
  --model claude-opus-4-7 \
  --split train \
  --inter-test-delay 15 \
  .claude/agents/meta-agent-factory.md

python3 eval/bayesian_eval.py --split train

# Option B: Let cron handle it
# Remove or reset the opus-4-7 entry in experiment_log.json
# Cron fires at 11:30 PM — results appear by midnight
```

### Step 2: Per-Test Before/After Comparison

The per-test results from the 0.683 run are stored in `experiment_log.json` (if the
`per_test_results` array was captured — added commit 79c98c7). Compare each test:

| Test ID | Category | 0.683 Run (CC bug) | v2.1.117 Re-Run | Attribution |
|---------|----------|-------------------|-----------------|-------------|
| 1-22 | Positive | Record PASS/FAIL | Record PASS/FAIL | |
| 23-39 | Hallucination | Record PASS/FAIL | Record PASS/FAIL | |
| 40-59 | Near-miss | Record PASS/FAIL | Record PASS/FAIL | |

**Attribution logic** (per test):
- FAIL → PASS: **CC bug caused this failure** (context truncation victim)
- FAIL → FAIL: **Opus 4.7 model behavior** (genuine regression, persists after fix)
- PASS → PASS: No change (unaffected by either issue)
- PASS → FAIL: **New regression** (unexpected — investigate immediately)

### Step 3: Aggregate Assessment

| Outcome | Interpretation | Action |
|---------|---------------|--------|
| Re-run score ≥ 0.85, most FAIL→PASS flips | CC bug was dominant. Model is viable. | Proceed to standard go/no-go gates (G1-G3 in runbook). |
| Re-run score 0.75-0.85, mixed flips | Both factors present. | Apply failure analysis template (runbook §Failure Analysis) to remaining failures. |
| Re-run score < 0.75, few FAIL→PASS flips | Opus 4.7 has genuine regressions beyond CC bug. | Wait for #49562 patch. No further action until model fix. |
| Re-run score < 0.683 | Worse than contaminated baseline. | Investigate — possible new CC regression or environmental issue. |

### Step 4: If GO — Continue Standard Runbook

If the re-run passes go/no-go gates (G1: CI overlaps baseline [0.702, 0.927], G2: zero
400 errors, G3: duration within 2x), proceed to the graduated rollout documented in
`eval/model_migration_runbook.md`:
- Days 1-4: factory-steward only
- Days 5-8: add researcher
- Days 9+: full fleet

### Next Diagnostic Step (Conditional)

If failures persist after the clean re-run, the next diagnostic is OTEL effort attribute
correlation. CC v2.1.117 adds an `effort` attribute to OTEL cost/token events. Track
effort level per test and correlate with pass/fail — this narrows failure attribution
to adaptive thinking (`supportsAdaptiveThinking()` from #49562) vs. other Opus 4.7
behavioral changes. Only pursue this if the aggregate score remains below 0.85 after
the clean re-run.

---

## Key Data Points

- **Contaminated baseline**: 0.683, CI [0.535, 0.814], 12/39 failures
- **Clean Opus 4.6 baseline**: T=0.829, CI [0.702, 0.927] (39 tests, re-baselined 2026-04-15)
- **CC bug**: v2.1.116 and earlier computed Opus 4.7 context against 200K not 1M
- **Opus 4.7 #49562**: OPEN, `supportsAdaptiveThinking()` breakage confirmed by 3 third-party repos
- **Per-test logging**: Available via `--verbose` flag in `daily_shadow_eval.sh` (commit 79c98c7)

---

*This protocol supplements `eval/model_migration_runbook.md`. It is specific to the CC v2.1.117
context window fix and the contaminated 0.683 baseline. For general migration procedures, use
the runbook.*
