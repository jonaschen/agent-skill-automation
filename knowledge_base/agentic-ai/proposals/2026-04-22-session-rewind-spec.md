# Technical Specification: Session Rewind for AutoResearch Optimizer

**Date**: 2026-04-22
**Triggered by**: Hypothesis `2026-04-22-hypothesis.md` & ADK v1.31.0 "Session Rewind" release
**Strategic Priority**: S1 (Automatic Improvement), S2 (Orchestration)
**Status**: DRAFT

## 1. Overview
This specification defines the integration of **Session Rewind** (state checkpointing and rollback) into the `autoresearch-optimizer` (Phase 4). By leveraging the Claude Agent SDK's session persistence and subagent introspection, we will move from a "linear retry" model to a "branching search" model with memory.

## 2. Problem Statement
The current optimizer (Phase 3) treats each optimization attempt as an isolated session. When a trial description fails the evaluation gate, the next attempt starts with a clean context. This causes "forgetting": the agent loses the chain of reasoning that led to the failure and often repeats similar mistakes (e.g., oscillating between two slightly different descriptions).

## 3. Proposed Architecture

### 3.1. Session-Based "Memory of Failure"
Instead of separate sessions, the optimizer will maintain a single **Long-Running Session** via the Agent SDK.
- **Checkpointing**: Before a file modification (e.g., updating a `SKILL.md` description), the agent emits a `Checkpoint` event.
- **Rollback**: If the subsequent `bayesian_eval.py` run shows `new_ci_lower < old_ci_upper` (no improvement), the agent calls the `Rewind` tool.

### 3.2. Technical Primitives (Claude Agent SDK)
- **`fork_session()`**: When the agent wants to explore multiple description variants in parallel (A/B testing), it will fork the current session into sibling branches.
- **`list_subagents()` / `get_subagent_messages()`**: The lead optimizer agent will use these to read the "failure logs" of the evaluation subagents to understand *exactly* which test cases failed and why.
- **`session_id` Persistence**: The optimizer's state will be resumable via `session_id`, allowing multi-hour optimization runs across pipeline restarts.

### 3.3. The `SessionRewind` Tool (Proposed)
A new tool for the optimizer's skill:
- **`checkpoint(tag: string)`**: Saves the current message sequence and file system state (via a git-based worktree or temporary directory).
- **`rewind(tag: string)`**: Restores the message sequence to the checkpoint and reverts file system changes.

## 4. Workflow (Phase 4)
1. **Analyze**: Lead agent reads failing eval results.
2. **Checkpoint**: Create `checkpoint-baseline`.
3. **Branch**: Fork session into `variant-A` and `variant-B`.
4. **Execute (Subagent)**: `variant-A` and `variant-B` each propose and apply a change.
5. **Evaluate**: Run `bayesian_eval.py` on both.
6. **Compare**: Lead agent reads subagent messages to analyze results.
7. **Select or Rewind**:
    - If A improves: Adopt A.
    - If B improves: Adopt B.
    - If neither improves: **Rewind** to `checkpoint-baseline` and reason about WHY both failed before trying `variant-C`.

## 5. Implementation Plan (Phase 4)
- **Task 1**: Update `autoresearch-optimizer` skill to include `Agent` tool for subagent spawning.
- **Task 2**: Implement the `SessionRewind` wrapper around `git worktree` and SDK session IDs.
- **Task 3**: Update `closed_loop.sh` to support persistent session IDs across turns.

## 6. Expected Impact
- **Convergence**: Reduce iterations by 20% (Hypothesis 2026-04-22).
- **Reasoning**: Higher-quality descriptions that avoid known "dead ends" in the description space.
- **Observability**: Full "search tree" visible in the session transcript.
