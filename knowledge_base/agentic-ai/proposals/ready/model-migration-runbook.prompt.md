# Ready-to-Execute: Model Migration Runbook

**Source proposal**: `proposals/2026-04-05-model-migration-runbook.md`
**Priority**: P1 (high)
**Type**: Operational document at `eval/model_migration_runbook.md`
**Generated**: 2026-04-05 by agentic-ai-researcher (L5: Action)

---

## Prompt for Implementation

Create a step-by-step runbook for re-baselining the eval pipeline when a new Claude model ships (Opus 4.7, Sonnet 4.8, or Capybara/Mythos tier).

### Requirements

Create `eval/model_migration_runbook.md` with the following sections:

1. **Pre-Migration Checklist**:
   - Record current baselines from `eval/experiment_log.json` (posterior mean, CI lower/upper for both T and V sets)
   - Note current model IDs from `.claude/agents/*.md` `model:` fields
   - Ensure `eval/splits.json` is current (26 T + 18 V prompts)
   - Ensure no in-progress optimization runs (`eval/experiment_log.json` last entry is complete)

2. **Step 1: Baseline Eval on New Model (no description changes)**:
   ```bash
   # Run full eval suite (T+V) with current descriptions on new model
   python eval/run_eval_async.py --all
   python eval/bayesian_eval.py --split training
   python eval/bayesian_eval.py --split validation
   ```
   - Record results as `new_model_baseline` in experiment log

3. **Step 2: Analyze Results — Positive and Negative Tests SEPARATELY**:
   - **Positive tests (1-22)**: What is the pass rate? Compare posterior mean vs Opus 4.6 baseline.
   - **Negative tests (23-39)**: What is the false-positive rate? Any new false triggers?
   - **Cross-domain tests (40-44)**: Any new conflicts between agents?
   - Use `bayesian_eval.py --compare` to check CI overlap:
     ```bash
     python eval/bayesian_eval.py --compare old_baseline new_model_baseline
     ```

4. **Step 3: Decision Matrix**:
   | Positive regression | Negative regression | Action |
   |---|---|---|
   | < 5% drop | No change | Update model refs, no re-optimization needed |
   | 5-15% drop | No change | Trigger AutoResearch optimizer on new model |
   | > 15% drop | Any | HALT — investigate model behavioral changes before proceeding |
   | No change | False positives increase | Audit agent descriptions for overlap, check routing regression |
   | Improvement | Any | Accept improvement, update baselines |

5. **Step 4: Update References** (after validation passes):
   - Update `model:` fields in all `.claude/agents/*.md` files
   - Update CLAUDE.md model references
   - Update any hardcoded model strings in scripts

6. **Step 5: Routing Regression Check**:
   - Run eval with ALL agents loaded simultaneously (not isolated)
   - Compare routing accuracy against the T=0.658 regression baseline (Lesson L7)
   - If routing worsens: prioritize description disambiguation before deploying

7. **Step 6: Post-Migration Validation**:
   - Run full T+V eval suite one final time
   - Verify `posterior_mean >= 0.90` and `ci_lower >= 0.80` (deployment gate)
   - Commit updated baselines to `eval/experiment_log.json`

8. **Capybara/Mythos Specific Section**:
   - Capybara sits ABOVE Opus in Anthropic's hierarchy — may become Claude Code default
   - If Capybara becomes default: ALL agent definitions need `model:` field review
   - Expected access: defender-first rollout, initial access may be restricted
   - Check: does Capybara change routing behavior for the same descriptions?
   - Check: do existing permission boundaries still hold?

### Context

- Current baselines: G8 Iter 2, T=0.895, V=0.900
- Routing regression: T=0.658 when all agents loaded (Lesson L7)
- Opus 4.7 and Sonnet 4.8 references found in internal Anthropic configs
- Capybara/Mythos government briefing indicates heightened cyber capabilities

### Files to Create

- `eval/model_migration_runbook.md` — the runbook itself

### Files NOT to Modify

- `eval/experiment_log.json` — only modified during actual migration execution
- `.claude/agents/` — only modified during Step 4 of actual migration
- `ROADMAP.md` — not modified by researcher (human review required)
