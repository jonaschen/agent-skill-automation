# Model Migration Runbook

**Purpose**: Steps to re-baseline eval metrics when a new Claude model ships (e.g., Opus 4.7, Capybara/Mythos, Sonnet 4.8).
**Created**: 2026-04-05
**Triggered by**: Discussion ADOPT #4 (P1) — Capybara/Mythos contingency planning.

---

## CC Version Advisory

Single source of truth for the recommended Claude Code CLI version. The `agent_review.sh` dashboard reads this section via `grep -A 5 "## CC Version Advisory"` to surface the current advisory whenever Jonas runs the dashboard. Update on each new CC release (researcher action — one-line update in next sweep).

- **Recommended**: `2.1.119`
- **Avoid**: `2.1.120` (silent release, eight community-documented regressions, broken auto-update, `--resume` TypeError crash per #53041 / #53044)
- **Reason**: v2.1.119 is the natural upgrade target — it lands the documented bugfixes without the v2.1.120 regression cluster. v2.1.121 (next-fix point, ETA 2-4 days from 2026-04-28) may revise this once shipped.
- **Minimum**: `2.1.116` (prior post-#49562 stabilization point — Apr 20)
- **Expires**: When v2.1.121 (or later confirmed-stable release) ships and is verified by the researcher.
- **Last updated**: 2026-04-28 (factory-steward, ADOPT #4 from 2026-04-28 discussion)

---

## When to Execute

- A new Claude model is released that will replace the current default (Opus 4.6)
- Anthropic announces deprecation of the current model tier
- A new model becomes available in Claude Code and may affect routing behavior

## Pre-Migration Checklist

- [ ] Confirm the new model is available in Claude Code (`claude --model <new-model>`)
- [ ] Note the current baseline metrics for comparison:
  - Training posterior mean and CI (current: T=0.895 CI [0.781, 0.970])
  - Validation posterior mean and CI (current: V=0.900 CI [0.740, 0.987])
  - Agent fleet size at baseline time (current: 12 agents)

## Step 1: Full Eval on New Model (Positive + Negative Separately)

Run the complete eval suite (Training + Validation) on the new model:

```bash
cd /home/jonas/gemini-home/agent-skill-automation

# Run training set
python3 eval/run_eval_async.py --split train --inter-test-delay 15
python3 eval/bayesian_eval.py --split train

# Run validation set (assessment only — do NOT optimize against this)
python3 eval/run_eval_async.py --split validation --inter-test-delay 15
python3 eval/bayesian_eval.py --split validation
```

**Record separately**:
- Positive test pass rate (tests 1-22): measures correct triggering
- Negative test pass rate (tests 23-54): measures false positive resistance
- Overall posterior mean + 95% CI

## Step 2: Compare Against Opus 4.6 Baselines

| Metric | Opus 4.6 Baseline | New Model | Delta |
|--------|-------------------|-----------|-------|
| Training posterior mean | 0.895 | | |
| Training CI | [0.781, 0.970] | | |
| Validation posterior mean | 0.900 | | |
| Validation CI | [0.740, 0.987] | | |
| Positive tests (1-22) pass rate | | | |
| Negative tests (23-54) pass rate | | | |

## Quantitative Go/No-Go Gates (2026-04-18)

These gates apply to any model migration shadow eval, not just Opus 4.7. They are the formal acceptance criteria — no subjective "looks good enough" judgments.

### GO (all must pass)

| Gate | Metric | Threshold | Rationale |
|------|--------|-----------|-----------|
| G1 | Bayesian CI overlap | New model CI overlaps with baseline CI [0.702, 0.927] | Statistical indistinguishability at our sample size (N=39). Primary gate. |
| G2 | Model-returned errors | Zero 400 errors from model (rate-limit retries excluded) | Any 400 indicates an undiscovered breaking change. |
| G3 | Eval duration | Total duration within 2x baseline | Allows for tokenizer inflation + first-run effects. |

### NO-GO (any triggers hold)

| Gate | Metric | Threshold | Action |
|------|--------|-----------|--------|
| NG1 | Posterior mean | Drops below 0.75 | Significant quality regression — do not proceed. |
| NG2 | 400 errors | Any model-returned 400 (not rate-limit) | Undiscovered breaking change — fix and re-run. |
| NG3 | Duration | Exceeds 2x baseline | Extreme token inflation — investigate before proceeding. |

### Post-Migration Monitoring (if GO)

**G4 — Cost Observational Gate (graduated rollout)**:
Monitor actual session cost delta during Day 1 rollout (factory-steward only). Compare perf JSON durations and token consumption between Opus 4.6 and 4.7 sessions. If daily cost increase > 50%, pause rollout and adjust dollar ceiling before expanding to additional agents.

- **Days 1-4**: factory-steward only. Compare duration:commit ratio with 4.6 baseline.
- **Days 5-8**: Add researcher. Monitor for delegation pattern changes.
- **Days 9+**: Remaining agents. Full fleet on new model.
- **Rollback trigger**: Any agent shows >2x duration increase OR >30% delegation drop.

## Shadow Eval Results Checklist

Fill in this checklist when the shadow eval completes. This is the single source of truth for the migration GO/NO-GO decision.

**Migration target**: __________________ (e.g., claude-opus-4-7)
**Eval date**: __________________
**Evaluator**: __________________

### Raw Results

| Metric | Value |
|--------|-------|
| Training posterior mean | ______ |
| Training CI | [______, ______] |
| Pass count / Total | ______ / ______ |
| Eval duration (seconds) | ______ |
| Model-returned 400 errors | ______ |

### Go/No-Go Gate Assessment

| Gate | Criterion | Result | PASS/FAIL |
|------|-----------|--------|-----------|
| G1 — CI overlap | New CI overlaps baseline [0.702, 0.927] | ______ | ______ |
| G2 — No 400 errors | Zero model-returned 400s (rate-limit retries excluded) | ______ | ______ |
| G3 — Duration | Total duration ≤ 2x baseline | ______ | ______ |

### Verdict

- [ ] **GO** — All gates pass. Proceed to graduated rollout (Days 1-4: factory-steward only).
- [ ] **NO-GO** — One or more gates failed. Action: ______________________________

### Notes

_______________________________________________________________________

---

## Shadow Eval Failure Analysis (Per-Test Diagnostic)

**Purpose**: When a shadow eval returns NO-GO, determine whether the failure is recoverable
(description tuning) or fundamental (needs vendor patch). Requires per-test results in
`experiment_log.json` (added 2026-04-21 via `--verbose` logging in `daily_shadow_eval.sh`).

### Test Category Ranges

| Category | Test IDs | Count | What It Measures |
|----------|----------|-------|-----------------|
| Positive | 1–22 | 22 | Correct triggering (should route to meta-agent-factory) |
| Hallucination trap | 23–39 | 17 | False positive resistance (should NOT trigger) |
| Near-miss / cross-domain | 40–59 | 20 | Disambiguation accuracy (should NOT trigger) |

### Step 1: Compute Per-Category Failure Rate

From the `per_test_results` array in the experiment log entry:

```
positive_failures    = count(FAIL in tests 1-22)  / 22
hallucination_failures = count(FAIL in tests 23-39) / 17
nearmiss_failures    = count(FAIL in tests 40-59)  / 20
```

**Use rates, not raw counts** — denominators differ across categories.

### Step 2: Classify Failure Pattern

| Pattern | Criterion | Interpretation |
|---------|-----------|---------------|
| **Concentrated-positive** | positive_failures > 0.30 AND hallucination + nearmiss < 0.10 | New model routes differently but doesn't false-trigger. Routing regression. |
| **Concentrated-negative** | hallucination + nearmiss > 0.20 AND positive_failures < 0.10 | New model false-triggers on non-creation prompts. Behavior change. |
| **Mixed** | Both categories have failures > 0.10 | Multiple regression vectors. |
| **Sparse** | Total failures < 5 | Likely noise or edge cases. |

### Step 3: S1 Action Mapping

| Pattern | S1 Posture | Action |
|---------|-----------|--------|
| **Concentrated-positive** | Recoverable | Tune meta-agent-factory description for new model's routing. Run autoresearch-optimizer with `--model <new>`. Expected: 1-3 optimizer iterations. |
| **Concentrated-negative** | Recoverable | Strengthen exclusion patterns in description. Add failing prompts to training set if novel. Run optimizer. |
| **Mixed** | Likely blocked | Both routing and behavior changed. Wait for vendor patch or adaptive reasoning tuning. Re-evaluate after patch. |
| **Sparse** | Likely noise | Re-run shadow eval to confirm. If reproducible, treat as concentrated per dominant category. |

### Decision Tree Summary

```
per_test_results available?
├─ NO → Wait. Cannot characterize. Default: "wait for patch" (safe).
└─ YES → Compute per-category failure rates
    ├─ Total failures < 5 → Re-run to confirm (may be noise)
    ├─ Positive failures dominant → RECOVERABLE: tune description
    ├─ Negative failures dominant → RECOVERABLE: strengthen exclusions
    └─ Both categories failing → BLOCKED: wait for vendor patch
```

---

## Step 3: Decision Matrix

| Outcome | Action |
|---------|--------|
| New model posterior mean **within** old CI (no significant change) | Accept new model. Update CLAUDE.md model references. |
| New model **improves** (new_ci_lower > old_ci_upper) | Accept. Check if routing regression (L7) is resolved. |
| Regression **< 5%** (new mean slightly lower but CIs overlap) | Accept with monitoring. Re-run eval after 48h to confirm stability. |
| Regression **5-15%** | Trigger AutoResearch optimizer with new model to re-optimize descriptions. |
| Regression **> 15%** | HOLD — do not migrate. File issue. Investigate whether description patterns need fundamental restructuring for new model's routing behavior. |

## Step 4: Post-Migration (if accepted)

1. Update `CLAUDE.md` — model references in agent tables
2. Update `.claude/agents/*.md` — `model:` field in YAML frontmatter
3. Re-run full eval suite to confirm stability post-update
4. Update this runbook's baseline numbers
5. Commit: `migration: re-baseline eval for <new-model-name>`

## Step 5: Routing Regression Check

The new model may route differently, affecting the T=0.658 routing regression (Lesson L7). Specifically check:

1. Run positive tests (1-22) individually and note which agent receives the route
2. If positive tests now route correctly (to meta-agent-factory), the regression may be resolved
3. If routing is worse, the new model may need stronger disambiguation in agent descriptions

## Step 6: Stress-Test Harness Assumptions

Each pipeline agent encodes an assumption about what the model can't do. A new model may invalidate these assumptions, enabling pipeline simplification.

1. Open `eval/assumption_registry.md`
2. For each agent row, run the stress test described in column 3
3. Record results with new model name and date
4. If an assumption no longer holds, open a ROADMAP task for the simplification path
5. Update the "Last Tested" and "Result" columns

**Design principle**: The pipeline should simplify as models improve. If a new model makes an agent's assumption obsolete, that agent should be merged or removed — not kept for backwards compatibility.

---

## Notes

- Never optimize against the validation set during migration
- Always use `--inter-test-delay 15` to prevent quota burst during migration eval runs
- The prompt cache (`eval/prompt_cache.py`) includes model ID in the cache key — results from different models are stored separately and will not cross-contaminate. Use `--no-cache` if you need to force fresh evaluation regardless.
- If a model behavior patch ships during graduated rollout, re-run the shadow eval and compare CIs before proceeding with the next rollout stage.

---

## Appendix A: SDK Migration Checklist (Agent SDK v0.2.91+)

When migrating to or integrating with the Agent SDK (v0.2.91+), incorporate these items:

### terminal_reason Differentiated Retry Logic

Agent SDK v0.2.91 exposes a `terminal_reason` field. Design closed-loop retry logic based on reason:

| `terminal_reason` | Action |
|---|---|
| `completed` | Proceed to next state |
| `max_turns` | Retry with `--max-turns` doubled, up to 3 retries |
| `aborted_tools` | Log tool failure, skip to REPORT_FAILURE (do not retry blindly) |
| `blocking_limit` | Exponential backoff (30s, 60s, 120s), then REPORT_FAILURE |

**Routing diagnosis**: `max_turns` termination on positive prompts may indicate reasoning budget exhaustion rather than genuine misrouting. Cross-reference with positive/negative pass rates.

### Strict Sandbox Default

SDK v0.2.91 sets `failIfUnavailable: true` for sandboxing by default. For non-production environments (eval runs, optimizer iterations), explicitly set:

```json
{ "sandbox": { "failIfUnavailable": false } }
```

This prevents eval failures on machines without sandbox infrastructure.
