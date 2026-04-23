# Implementation Spec: Session Rewind for AutoResearch Optimizer

**Date**: 2026-04-23
**Status**: DRAFT (P1 Strategic Research)
**Reference**: Hypothesis `2026-04-22-hypothesis.md`

## Objective
Migrate the `autoresearch-optimizer` from a stateless "Re-run from Scratch" model to a stateful "Checkpoint & Rewind" model using the `claude-agent-sdk` Session management features.

## Current Bottleneck
In the current Phase 3/4 loop, if the optimizer fails to find an improvement in Iteration N, it restarts the next attempt in a fresh session. While it can read the `experiment_log.json` to see past failures, it loses the immediate context of the "failed reasoning" that led to those failures. It effectively "forgets" the nuance of why a specific wording didn't work.

## Proposed Architecture

### 1. State Store (`SessionStore`)
Use a Redis or filesystem-based `SessionStore` (new in SDK v0.1.64) to persist the full conversation history of the optimization session.

### 2. Checkpoint Logic
At the start of every iteration (the "Known Good" state), the optimizer will create a **Checkpoint**:
```python
# Pseudo-code for optimizer logic
current_session = await sdk.get_session(session_id)
checkpoint_id = await current_session.checkpoint(name=f"iter-{iteration_count}-baseline")
```

### 3. Rewind on Failure
If an evaluation of a branch (A/B/C/D) fails the Bayesian non-overlap rule (`new_ci_lower <= old_ci_upper`), the optimizer will **Rewind** instead of exiting:
```python
if not improvement_found:
    print("[Optimizer] Branch failed. Rewinding to last good state...")
    await current_session.rewind(checkpoint_id)
    # The agent is now back at the state BEFORE the failed modification, 
    # but the SDK can optionally inject the "Failed Result" as a summary 
    # to prevent repeating the mistake.
```

### 4. Integration with `experiment_log.json`
The `experiment_log.json` will be extended to store `checkpoint_id` for every iteration. This allows the optimizer to resume from the best-known checkpoint even after a process crash.

## Benefits
- **Context Preservation**: The agent retains its internal chain-of-thought about the Skill's purpose while being able to backtrack from bad modifications.
- **Token Efficiency**: Re-using a stateful session with prompt caching is 40-60% cheaper than starting a new 5,000-token-history session every iteration.
- **Exploration Depth**: Enables the agent to perform deeper "lookahead" (e.g., trying a 3-step modification sequence and rewinding to step 1 if it fails).

## Implementation Path (Phase 5)
1.  **Task 5.3.3**: Migrate `autoresearch-optimizer` to programmatic Agent SDK.
2.  **Task 5.3.3a**: Implement the `Checkpoint/Rewind` loop in the Python wrapper.
3.  **Verification**: Run a 10-Skill pilot comparison against the Phase 4 baseline.
