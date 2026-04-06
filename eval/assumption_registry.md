# Assumption Registry — Pipeline Model Limitation Assumptions

**Purpose**: Maps each pipeline agent to its encoded model limitation assumption. When a new model ships, systematically stress-test each assumption to determine if the pipeline can be simplified.

**Principle**: Our pipeline should be designed to simplify as models improve, not to accumulate complexity.

**Cross-reference**: `eval/model_migration_runbook.md` Step 6 (Stress-Test Harness Assumptions)

---

## Agent Assumption Table

| Agent | Assumption | Stress Test | Simplification Path | Last Tested | Result |
|---|---|---|---|---|---|
| `skill-quality-validator` | Factory can't self-evaluate accurately | Run factory with self-eval prompt ("generate and evaluate this Skill"); compare to validator score | Merge validator into factory (single-pass generate+validate) | 2026-04-06 | Opus 4.6 — holds (factory self-eval inconsistent with validator) |
| `autoresearch-optimizer` | Descriptions can't be optimized in single pass | Give factory explicit optimization goal + eval failures; measure first-attempt vs. iterated | Reduce iteration cap to 5-10, potentially single-pass | 2026-04-06 | Opus 4.6 — holds (first-attempt descriptions need 2-5 iterations) |
| `changeling-router` | Model can't auto-identify expert role from task description alone | Test zero-shot role selection on 50-task benchmark without routing table | Remove routing table, rely on semantic disambiguation | 2026-04-06 | Opus 4.6 — partially holds (simple tasks auto-identify; ambiguous tasks need routing) |
| `agentic-cicd-gate` | Deployed Skills can regress unpredictably | N/A — always needed (trust-but-verify, model-independent) | No simplification — this is a safety net | Permanent | Model-independent |
| `meta-agent-factory` | Requirements can't be converted to SKILL.md in one pass with correct permissions | N/A — complexity is in the format spec, not model capability | Simplify SKILL.md format → simplify factory | Format-dependent | Depends on SKILL.md spec evolution |

## How to Use This Registry

### During Model Migration

1. Read `eval/model_migration_runbook.md` and complete Steps 1-5
2. For each row in the table above where Result is not "Permanent" or "Model-independent":
   - Run the stress test described in column 3
   - Record the result with the new model name and date
   - If the assumption no longer holds, open a task in ROADMAP.md to implement the simplification path

### When Adding New Agents

When adding a new agent to the fleet, ask: "What model limitation does this agent compensate for?" Add a row to this table. If you can't articulate the assumption, the agent may be unnecessary.

### Quarterly Review

Even without a new model release, revisit this table quarterly. Model capabilities can drift with API updates, system prompt changes, and infrastructure improvements.

---

## Change Log

| Date | Change |
|---|---|
| 2026-04-06 | Initial registry created with 5 core agents (Opus 4.6 baseline) |
