# Skill Proposal: Optimizer State Persistence via Experiment Log
**Date**: 2026-04-06
**Triggered by**: Anthropic harness blog (context anxiety + structured handoff artifacts); analysis §2.3; discussion ADOPT #6
**Priority**: P2 (medium)
**Target Phase**: 3-4 (Optimizer Robustness)

## Rationale

Anthropic found that Sonnet 4.5 exhibited "context anxiety" near limits — quality degraded. Our optimizer accumulates iteration state in-context across potentially 50 iterations. If context compaction discards the best iteration result, or if the optimizer is interrupted (quota exhaustion, timeout, crash), all progress is lost.

The Engineer consensus: extend the existing `eval/experiment_log.json` rather than creating a parallel state directory. The experiment log already tracks iteration history — add `best_so_far` and `current_description` fields.

## Proposed Specification
- **Name**: optimizer-state-persistence (extension of existing experiment log)
- **Type**: Pipeline improvement (optimizer robustness)
- **Description**: Persistent best-so-far state in experiment log with resume-from-log capability
- **Key Capabilities**:
  - After each optimizer iteration, write to `eval/experiment_log.json`:
    - `best_so_far`: `{ "description": "...", "posterior_mean": 0.92, "ci_lower": 0.84, "iteration": 12 }`
    - `current_description`: the description currently being tested
  - On optimizer startup, check experiment log for existing state:
    - If `best_so_far` exists and is recent (< 24h), offer to resume from that point
    - Load best description as the starting point instead of the current SKILL.md description
  - Crash recovery: if interrupted at iteration 30, resume from iteration 30 with best-so-far, not from scratch
  - Integrates with existing `eval/show_experiments.sh` viewer
- **Tools Required**: N/A (agent definition update + experiment log schema extension)

## Implementation Notes
- Files to change: `.claude/agents/autoresearch-optimizer.md` (add state persistence + resume instructions), `eval/experiment_log.json` (schema extension)
- Do NOT create a new `eval/optimizer_state/` directory — extend the existing schema
- The `current_description` field prevents re-testing a description the optimizer already evaluated (dedup)
- Resume logic should be opt-in (the optimizer asks before resuming to avoid confusion with stale state)

## Estimated Impact
- Prevents loss of 30+ minutes and $10-20 API cost from interrupted optimization runs
- Enables crash recovery without human intervention (Phase 4 autonomy requirement)
- Makes optimizer state observable via existing experiment log tooling
