# Skill Proposal: Model Migration Runbook
**Date**: 2026-04-05
**Triggered by**: Capybara/Mythos government briefing ("large-scale cyberattacks more likely"), Opus 4.7/Sonnet 4.8 internal config references; discussion ADOPT #4
**Priority**: P1 (high)
**Target Phase**: 3-4

## Rationale

Anthropic warned officials that Mythos is "far ahead of any other AI model in cyber capabilities." Internal references to Opus 4.7 and Sonnet 4.8 suggest new models within months. When a new model ships:
- Our SKILL.md descriptions optimized for Opus 4.6 may exhibit different routing behavior
- Eval baselines are invalidated (CIs computed against current model)
- The T=0.658 routing regression could worsen OR resolve depending on new model's routing semantics
- The Capybara tier sits ABOVE Opus — if it becomes the Claude Code default, all assumptions change

A runbook costs nothing to create now and saves significant scramble time.

## Proposed Specification
- **Name**: model-migration-runbook (operational document, not a Skill)
- **Type**: Runbook (`eval/model_migration_runbook.md`)
- **Description**: Step-by-step procedure for re-baselining when a new Claude model ships
- **Key Capabilities**:
  1. Run full eval suite (T+V) on new model with CURRENT descriptions (no changes)
  2. Analyze positive and negative test sets SEPARATELY (per Engineer feedback)
  3. Compare posterior means and CIs against Opus 4.6 baselines from `eval/experiment_log.json`
  4. If positive test regression > 5%: trigger AutoResearch optimizer with new model
  5. If negative test regression (false positives increase): audit agent descriptions for overlap
  6. Update CLAUDE.md model references and agent definition `model:` fields
  7. Re-run routing regression check (all agents loaded simultaneously)
- **Tools Required**: N/A (documentation)

## Implementation Notes
- File location: `eval/model_migration_runbook.md`
- Reference existing artifacts: `eval/experiment_log.json` (baseline history), `eval/splits.json` (T/V definition), `eval/bayesian_eval.py` (CI comparison)
- Include a "routing regression specific" section addressing Lesson L7
- Template the `bayesian_eval.py --compare` command lines for copy-paste execution

## Estimated Impact
- Reduces model migration from "figure it out under pressure" to "follow the checklist"
- Explicitly addresses the highest-risk scenario (new model tier above Opus 4.6)
- Zero implementation cost, high insurance value
