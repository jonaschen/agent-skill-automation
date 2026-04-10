# Skill Proposal: terminal_reason Differentiated Retry Logic
**Date**: 2026-04-06
**Triggered by**: Agent SDK v0.2.91 `terminal_reason` field; analysis §1.3; discussion ADOPT #3
**Priority**: P1 (high)
**Target Phase**: 4 (Closed Loop)

## Rationale

Agent SDK v0.2.91 added a `terminal_reason` field exposing why the query loop terminated: `completed`, `aborted_tools`, `max_turns`, `blocking_limit`. Our `closed_loop.sh` currently treats agent termination as binary (exit code 0 vs non-zero), losing valuable diagnostic signal.

When we refactor the closed loop into a state machine (P2 from 2026-04-05), differentiated retry logic based on `terminal_reason` should be designed into the spec from the start — even though we're currently CLI-based and won't consume this field until SDK migration.

## Proposed Specification
- **Name**: terminal-reason-retry (spec addition to closed-loop state machine)
- **Type**: Pipeline improvement (spec, not immediate code)
- **Description**: Differentiated retry logic in closed-loop state machine based on Agent SDK `terminal_reason`
- **Key Capabilities**:
  - Retry logic table for state machine transitions:

  | `terminal_reason` | Action |
  |---|---|
  | `completed` | Proceed to next state |
  | `max_turns` | Retry with `--max-turns` doubled, up to 3 retries |
  | `aborted_tools` | Log tool failure, skip to REPORT_FAILURE (don't retry blindly) |
  | `blocking_limit` | Exponential backoff (30s, 60s, 120s), then REPORT_FAILURE |

  - Cross-reference with routing regression diagnosis: `max_turns` termination on positive prompts may indicate reasoning budget exhaustion vs. genuine misrouting
- **Tools Required**: Bash (future: Agent SDK)

## Implementation Notes
- This is a **spec addition**, not immediate code — zero blast radius
- Add to `eval/model_migration_runbook.md` as SDK migration checklist item
- Dependency: SDK migration (currently CLI-based). Do not block Phase 4 progress.
- When implementing the state machine refactor (proposal 2026-04-05-closed-loop-state-machine.md), design the OPTIMIZE→VALIDATE retry counter to accommodate `terminal_reason` differentiation
- Also add SDK v0.2.91 strict sandbox default (`failIfUnavailable: true`) to the migration runbook: explicitly set `failIfUnavailable: false` in non-production environments

## Estimated Impact
- Prevents blind retries on unrecoverable failures (saves API cost and time)
- Enables root-cause diagnosis for routing failures (max_turns vs. completed misrouting)
- Prepares the state machine for SDK migration without rework
