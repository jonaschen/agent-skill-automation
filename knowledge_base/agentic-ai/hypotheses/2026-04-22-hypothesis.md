# Academic Hypothesis — 2026-04-22

## Hypothesis
**"Integrating session-level checkpointing and rollback (inspired by ADK v1.31.0 Session Rewind) into the Phase 4 AutoResearch Optimizer will reduce the average number of iterations required for convergence to the 0.90 trigger rate threshold by ≥ 20% compared to the current state-loss retry model."**

## Background
The current `autoresearch-optimizer` (Phase 3) follows a linear state-loss retry pattern. When a parallel branch (A/B/C/D) fails to improve the metric, the agent begins a new iteration. While `eval/experiment_log.json` records historical attempts, the agent's internal "thinking" and "reasoning" about specific failures are lost between sessions. 

ADK v1.31.0 introduced **Session Rewind**, allowing agents to undo actions and retry with context preservation. By enabling the optimizer to "rewind" to a known good state without losing the session's conversation history about *why* a particular modification failed, we expect a significantly more efficient search of the description space.

## Testable Metrics
1. **Convergence Rate**: Mean number of iterations to reach `posterior_mean ≥ 0.90`.
2. **Token Efficiency**: Total tokens consumed per successful optimization.
3. **Success Rate**: Percentage of optimization tasks that reach the threshold within the 50-iteration budget.

## Experimental Design
- **Control**: Current `closed_loop.sh` + `autoresearch-optimizer` (linear retry).
- **Treatment**: Modified optimizer using Agent SDK sessions with a "Checkpoint/Rewind" tool.
- **Population**: 10 failing Skills (trigger rate < 0.75) promoted from stress test logs.
- **Verification**: Bayesian comparison of iterations-to-convergence.

## Strategic Relevance
- **S1 (Auto-improvement)**: Directly improves the efficiency of the self-correction loop.
- **S2 (Multi-agent orchestration)**: Tests a sophisticated state-management pattern essential for Track B (flagship agent) workflows.
