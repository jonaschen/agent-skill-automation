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

## Capability Diff — Worked Example

**Purpose**: S1 proof-of-concept demonstrating how a "capability diff" would connect the researcher's release tracking to assumption stress-testing. This worked example uses CC v2.1.117 as the input event.

### Input Event

**Release**: Claude Code v2.1.117 (2026-04-22)
**Changelog summary**: Context window computation fix — resolved bug where `mcpServers` configuration in agent frontmatter was incorrectly counted against the context window, reducing effective context from ~195K to ~180K tokens for agents with MCP server configs.

### Step 1: Extract Capability Changes

From the researcher's sweep report (2026-04-22), extract structured change entries:

| Change ID | Type | Affected Subsystem | Description |
|-----------|------|-------------------|-------------|
| CW-1 | Bug fix | Context window | MCP config no longer counted against context budget |
| CW-2 | Behavior change | Agent frontmatter | `mcpServers` field processing changed |

### Step 2: Match Against Assumption Registry

For each change, scan the assumption table for rows whose "Stress Test" or "Simplification Path" would be affected:

| Change ID | Matched Agent | Matched Assumption | Impact |
|-----------|--------------|-------------------|--------|
| CW-1 | `autoresearch-optimizer` | "Descriptions can't be optimized in single pass" | INDIRECT — more context budget means optimizer could potentially process longer description histories per iteration. Current 2-5 iteration count may decrease. |
| CW-1 | `skill-quality-validator` | "Factory can't self-evaluate accurately" | INDIRECT — more context for self-eval could improve factory self-evaluation accuracy. Worth re-running stress test. |
| CW-2 | `meta-agent-factory` | "Requirements can't be converted to SKILL.md in one pass with correct permissions" | NO IMPACT — MCP config processing is runtime behavior, not generation quality. |

### Step 3: Generate Actions

| Priority | Action | Gated On |
|----------|--------|----------|
| P2 | Re-run `skill-quality-validator` stress test (factory self-eval vs. validator score) under v2.1.117 to check if expanded context changes the result | CC upgrade to v2.1.117+ |
| P3 | Monitor optimizer iteration counts over next 5 runs post-upgrade for natural reduction | CC upgrade to v2.1.117+ |
| — | No action needed for `meta-agent-factory` | — |

### Step 4: Update Registry

After stress tests complete, update the "Last Tested" and "Result" columns in the agent assumption table above.

### Observations for S1 Architecture

This worked example reveals the manual steps a capability diff system would automate:

1. **Structured changelog parsing**: The researcher's sweep is prose — extracting `(change_type, subsystem, description)` tuples requires either structured output from the researcher or a post-processing step.
2. **Assumption category matching**: The current registry has 5 rows with free-text assumptions. Matching a context window change to "descriptions can't be optimized in single pass" requires semantic understanding, not keyword matching. A production system would need either (a) an LLM matching step, or (b) a structured category ontology (e.g., `context_budget`, `tool_permissions`, `output_format`).
3. **Action generation**: The actions are straightforward once matches are identified — re-run the stress test with the new version. This step is automatable.
4. **Gating**: Most actions are gated on the CC upgrade actually being installed. The capability diff system should produce a "pending actions" queue that triggers when the gate opens.

**Conclusion**: The core matching logic (Step 2) is the hardest part to automate and the highest-value S1 contribution. Steps 1, 3, and 4 are mechanical. A minimal viable capability diff would focus exclusively on Step 2 — given a structured changelog entry and the assumption table, output matched rows with impact assessment.

---

## Change Log

| Date | Change |
|---|---|
| 2026-04-24 | Added Capability Diff worked example (CC v2.1.117) — S1 proof-of-concept per discussion 2026-04-23 A3 |
| 2026-04-06 | Initial registry created with 5 core agents (Opus 4.6 baseline) |
