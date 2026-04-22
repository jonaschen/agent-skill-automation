# Technical Specification: Session Rewind for Autoresearch Optimizer

**Date**: 2026-04-23
**Status**: Draft
**Topic**: S1 (Automatic Agent/Skill Improvement) / S2 (Multi-Agent Orchestration)
**Reference**: [2026-04-22-hypothesis.md](../hypotheses/2026-04-22-hypothesis.md)

## 1. Objective
Enable the `autoresearch-optimizer` to utilize the Anthropic Agent SDK's **Session Rewind** capability to implement a backtracking search algorithm for skill optimization. This will allow the optimizer to revert both conversation state and filesystem changes to a known-good checkpoint when an optimization branch results in a performance regression.

## 2. Background
Currently, the `autoresearch-optimizer` operates in a linear, forward-only loop. If a proposed change to a skill (e.g., a new trigger description) results in a regression during evaluation, the optimizer either:
1.  Attempts to "fix" the failure in the next turn (adding context/token bloat).
2.  Aborts the session, losing all previous progress.

With **Session Rewind** (introduced in Agent SDK v0.1.64), we can restore the agent's environment to a specific `message.uuid`, effectively "undoing" the last failed iteration.

## 3. Technical Requirements
- **Runtime**: `claude-agent-sdk >= 0.1.64` (Python) or `v0.2.111` (TypeScript).
- **Model**: `claude-opus-4-7` or `claude-3-5-sonnet-20241022` (v4.7 preferred for better rewind consistency).
- **Storage**: Persistent `SessionStore` (Redis or S3 recommended for distributed runs).

## 4. Implementation Logic

### 4.1 Checkpoint Management
The optimizer will maintain a `checkpoint_stack` containing the `message.uuid` of the last successful (improvement-verified) iteration.

1.  **Phase Start**: Initialize session and capture initial `message.uuid` as `ROOT_CHECKPOINT`.
2.  **Iteration N**:
    - Perform optimization edit (e.g., `Edit SKILL.md`).
    - Capture `message.uuid` of the "Act" message as `CANDIDATE_CHECKPOINT`.
    - Execute `Bayesian Eval`.
3.  **Validation**:
    - **IF** `new_ci_lower > old_ci_upper` (Successful improvement):
        - Push `CANDIDATE_CHECKPOINT` to `checkpoint_stack`.
        - Update `baseline_performance` to `new_performance`.
    - **ELSE IF** regression detected or `new_pass_rate < threshold`:
        - Trigger **Rewind Procedure** (Section 4.2).

### 4.2 Rewind Procedure
When a regression is detected, the orchestrator issues a rewind command:

```python
# Conceptual Implementation
if evaluation.is_regression():
    last_good_uuid = checkpoint_stack.peek()
    session.rewind(
        target_uuid=last_good_uuid,
        restore_files=True,  # Revert filesystem changes
        truncate_conversation=True # Prune the failed branch from context
    )
    # Orchestrator now prompts with: "The previous branch failed. 
    # Try a different strategy from the last known-good state."
```

### 4.3 Chapter Summarization ("Chapters")
To prevent context window saturation during long backtracking sessions, the optimizer will use the **Chapters** pattern:
- After 3 successful improvements, consolidate the `checkpoint_stack` into a single "Chapter Summary" message.
- Use `session.compact()` to replace the detailed turn history with the summary, preserving the latest filesystem state and the `message.uuid` for future rewinds.

## 5. Benefits & Impact
- **Token Efficiency**: Estimated 40% reduction in input tokens by pruning failed reasoning branches.
- **Success Rate**: Enables deeper search for optimal triggers without the "drift" associated with correcting previous mistakes in-context.
- **Reliability**: Guarantees the `SKILL.md` file always reflects the last verified improvement.

## 6. Phase 5 Alignment
This spec serves as the foundational state-management pattern for the **TCI (Topology-aware Coordination Interface)**. It enables "Atomic Agent Transactions," where a complex multi-agent operation can be fully rolled back if the final evaluation fails.

## 7. Action Items
1.  [ ] Upgrade `autoresearch-optimizer` environment to `claude-agent-sdk v0.1.64`.
2.  [ ] Update `scripts/lib/optimizer_loop.py` (or equivalent) to track `message.uuid`.
3.  [ ] Prototype a 3-iteration "Rewind Test" using the `meta-agent-factory` on Opus 4.7.
