# Skill Proposal: Eval Suite Expansion from Real-World Logs
**Date**: 2026-04-10
**Triggered by**: Eval suite (54 prompts) is still entirely synthetic; `promote_cases.py` and skill logger are deployed but unused at scale; real-world usage data is the highest-quality source of eval test cases
**Priority**: P1 (high — directly improves measurement quality, the "only currency" per CLAUDE.md)
**Target Phase**: Phase 3-4 (Measurement infrastructure)

## Rationale
Our measurement infrastructure is only as good as our test prompts. The eval suite was hand-crafted during Phase 2. Real-world skill invocations capture patterns we didn't anticipate — edge cases in phrasing, unexpected trigger contexts, false positive traps from actual user workflows. The skill logger hook (`scripts/skill_logger_hook.sh`) is installed in `long-term-care-expert` and `The-King-s-Hand` projects. `scripts/promote_cases.py` exists and is ready to run. The gap is: nobody has run the audit at scale.

## Proposed Specification
- **Name**: eval-suite-expansion (one-time audit task with periodic repeats)
- **Type**: Measurement improvement task
- **Description**: Audit accumulated skill usage logs and promote informative cases to eval suite
- **Key Steps**:
  1. **Prerequisite check**: Count logged invocations across all instrumented projects. Threshold: >50 invocations to proceed (if <20, defer until more data accumulates)
  2. **Run audit**: `python scripts/promote_cases.py --audit` — identify top 10 most informative real-world triggers not already represented in eval
  3. **Promote cases**: Add selected cases as `eval/prompts/test_55.txt` through `test_64.txt` (or fewer if <10 qualify)
  4. **Update splits**: Modify `eval/splits.json` to assign new cases to Training or Validation sets (maintain ≥30% negative controls per set)
  5. **Re-baseline**: Run `scripts/regression_test.sh --update-baseline` after adding cases

## Implementation Notes
- Conditional on log volume — check first, act second
- New test cases must include both positive (should trigger) and negative (should not trigger) real-world examples
- Maintain the T/V split invariant: ≥30% negative controls in each set
- After expansion, run a full eval to establish new baseline before any optimization

## Estimated Impact
- Improves measurement representativeness — test prompts match actual usage patterns
- Catches false positive/negative patterns invisible in synthetic tests
- Directly supports Phase 3 KPI: "Accuracy is the only currency"
