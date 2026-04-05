# Skill Proposal: Centralized Assumption Registry for Model Migration
**Date**: 2026-04-06
**Triggered by**: Anthropic harness engineering blog ("every component encodes an assumption"); analysis §2.1 + §4.1; discussion ADOPT #7
**Priority**: P2 (medium)
**Target Phase**: 4+ (Long-term pipeline evolution)

## Rationale

Anthropic's key insight: "Every component in a harness encodes an assumption about what the model can't do — stress test those assumptions as models improve." Our pipeline has 5 core agents, each encoding a model limitation assumption. When Capybara/Mythos or Opus 5.x ships, we need a structured checklist for which components to stress-test.

The Engineer consensus: a single centralized file (`eval/assumption_registry.md`) rather than scattered annotations across 5 agent definitions. One file to check during model migration, cross-referenced from the model migration runbook.

## Proposed Specification
- **Name**: assumption-registry (centralized model-assumption mapping)
- **Type**: Documentation artifact (eval infrastructure)
- **Description**: Maps each pipeline agent to its encoded model limitation assumption, stress test procedure, and simplification path
- **Key Capabilities**:
  - Registry table format:

  | Agent | Assumption | Stress Test | Simplification Path | Last Tested |
  |---|---|---|---|---|
  | `skill-quality-validator` | Factory can't self-evaluate accurately | Run factory with self-eval prompt; compare to validator score | Merge validator into factory | 2026-04-06 (Opus 4.6 — holds) |
  | `autoresearch-optimizer` | Descriptions can't be optimized in single pass | Give factory explicit optimization goal; measure first-attempt vs. iterated | Reduce iteration cap to 5-10, potentially single-pass | 2026-04-06 (Opus 4.6 — holds) |
  | `changeling-router` | Model can't auto-identify expert role | Test zero-shot role selection on 50-task benchmark | Remove routing table, rely on semantic disambiguation | 2026-04-06 (Opus 4.6 — partially holds) |
  | `agentic-cicd-gate` | Deployed Skills can regress | N/A — always needed (trust-but-verify, model-independent) | No simplification — this is a safety net | Permanent |
  | `meta-agent-factory` | Requirements can't be converted to SKILL.md in one pass | N/A — complexity is in the format, not model capability | Simplify SKILL.md format → simplify factory | Format-dependent |

  - Cross-referenced from `eval/model_migration_runbook.md` step list
  - Updated when new model releases are evaluated
- **Tools Required**: Write (one-time file creation)

## Implementation Notes
- Create `eval/assumption_registry.md` with the table above
- Add a reference to it in `eval/model_migration_runbook.md` under a new "Step 5: Stress-Test Harness Assumptions" section
- REJECTED alternative: scattering `## Encoded Assumption` sections across 5 agent files — creates maintenance burden with no operational benefit
- Design principle: "our pipeline should be designed to simplify as models improve, not to accumulate complexity"

## Estimated Impact
- Provides a structured checklist for model migration (currently ad-hoc)
- Prevents the "complexity ratchet" — components accumulate but never get removed
- Codifies the harness simplification principle as a repeatable practice
- ~30 minutes to create, saves hours of analysis per major model release
