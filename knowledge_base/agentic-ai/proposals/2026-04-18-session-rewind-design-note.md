# Skill Proposal: ADK Session Rewind as Phase 5.3 Optimizer Design Input

**Date**: 2026-04-18
**Triggered by**: ADK v1.31.0 shipped Session Rewind (undo agent actions, retry with different parameters). Analysis §1.2; Discussion 3.2 (ADOPT P1).
**Priority**: **P1** (high — zero implementation cost, high design value)
**Target Phase**: Phase 5.3 (workflow state tracking)

## Rationale

Our autoresearch-optimizer has a known gap: when all 4 parallel branches (A/B/C/D) fail in an iteration, the optimizer starts fresh via a new `claude -p` invocation. The in-context understanding of WHY branches failed is lost. `eval/experiment_log.json` partially compensates by recording what was tried, but the optimizer's in-session failure analysis (pattern recognition across failed approaches) is discarded.

ADK v1.31.0's Session Rewind addresses the same problem: undo agent actions within a session, retry with different parameters, while preserving session context. The concept translates to our pipeline:

- **Current**: optimizer branch fails → git rollback → fresh `claude -p` → session context lost
- **With rewind**: optimizer branch fails → rewind to checkpoint → retry with different strategy → session context (including failure analysis) preserved

The cross-pollination is conceptual — we can't use ADK code directly. The novel contribution is agent-specific rewind semantics: preserving session context across the rewind, not just file-level rollback.

**Discussion consensus (2026-04-18 Round 3)**:
- ADOPT as a design note in `workflow-state-convergence.md`
- Emphasize session-context-preservation as the novel contribution (database savepoints and git stash are prior art for file-level rollback)
- Evaluate Agent SDK's `get_subagent_messages()` + session persistence as the implementation path

## Proposed Specification

- **Name**: `session-rewind-design-note`
- **Type**: Design Document Update (no new Skill, no code changes)
- **Description**: Session-level checkpointing for optimizer rewind

**Deliverable**: Append the following design note to `knowledge_base/agentic-ai/evaluations/workflow-state-convergence.md`:

> **Pattern 5: Session Rewind (ADK v1.31.0, 2026-04-17)**
>
> Undo agent actions within a session, retry with different parameters while preserving session context. Distinguished from file-level rollback (git stash, database savepoints) by preserving the agent's in-session understanding of failure patterns.
>
> **Applicability to our pipeline**: When migrating from CLI (`claude -p`) to Agent SDK sessions (Phase 5), evaluate whether `get_subagent_messages()` + session persistence enables rewind-to-checkpoint behavior for the optimizer's parallel branch search. The key requirement is that the rewound session retains knowledge of what was tried and why it failed.
>
> **Implementation path**: Agent SDK session management → session checkpointing → rewind API (if available) or manual checkpoint/restore via transcript inspection.

## Implementation Notes

- Zero implementation effort now
- Document only — ensures Phase 5 design sprint doesn't overlook this pattern
- The `workflow-state-convergence.md` document already covers 4 patterns; this adds a 5th reference point

## Estimated Impact

- If implemented in Phase 5, optimizer convergence speed could improve significantly (no "cold start" after failed iterations)
- Reduces wasted tokens on re-discovering failure modes that were already analyzed in a prior session
