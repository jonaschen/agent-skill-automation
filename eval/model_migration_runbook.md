# Model Migration Runbook

**Purpose**: Steps to re-baseline eval metrics when a new Claude model ships (e.g., Opus 4.7, Capybara/Mythos, Sonnet 4.8).
**Created**: 2026-04-05
**Triggered by**: Discussion ADOPT #4 (P1) — Capybara/Mythos contingency planning.

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
- The prompt cache (`eval/prompt_cache.py`) should be cleared before migration eval (descriptions unchanged, but model behavior differs):
  ```bash
  rm -f eval/.prompt_cache.json
  ```

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
