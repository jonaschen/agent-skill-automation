# Roadmap Proposal: Phase 5 TCI Calibration Anchors
**Date**: 2026-04-16
**Triggered by**: Anthropic engineering blog "How we built our multi-agent research system" (2026-04-16) — provides empirical effort-scaling heuristics from Anthropic's production multi-agent research system.
**Priority**: P1 (high)
**Target Phase**: Phase 5 (topology-aware-router design — pre-implementation)

## Rationale

Phase 5's `topology-aware-router` requires a Task Coupling Index (TCI) algorithm to route tasks
between Track A (parallel multi-agent) and Track B (single flagship agent). The current Phase 5
design uses a vague "high/low coupling" binary classification with no numeric thresholds.

Anthropic's engineering blog provides concrete empirical calibration data from their production system:
- **Simple tasks**: 1 agent + 3-10 tool calls → decomposable, parallelizable
- **Complex tasks**: 10+ subagents with divided responsibilities → tightly coupled, sequential

Adding these thresholds now — before Phase 5 design begins — costs one ROADMAP edit and prevents the
classic mistake of designing an algorithm and then retrofitting measurements to justify it.

**Engineer's constraint (Round 1 discussion)**: The thresholds should be labeled as *empirical starting
points from Anthropic's task distribution* (heavily weighted toward document synthesis and web search),
not derived constants. Our pipeline tasks (skill generation, eval, optimization, deployment) have a
different profile. Validation against our actual task distribution is required in Phase 4.2b or Phase 5
kickoff.

## Proposed ROADMAP Change

Update Phase 5 TCI algorithm design section with:

```markdown
### TCI Threshold Calibration (empirical starting points — validate in 4.2b)

Source: Anthropic multi-agent research system engineering blog, 2026-04-16.

| TCI Score | Agent Count | Tool Calls | Routing Decision |
|-----------|------------|------------|-----------------|
| ≤ 2 | 1 agent | 3-10 tool calls | Track A (parallel) |
| 3-6 | 2-9 agents | mixed | Evaluation required (TCI classifier) |
| ≥ 7 | 10+ agents | divided responsibilities | Track B (single flagship) |

**Important**: These thresholds are calibrated from Anthropic's research task distribution
(document synthesis, web search). Our pipeline tasks (skill generation, eval, optimization,
deployment) may require threshold adjustment. Validate these anchors against our actual task
distribution in Phase 4.2b stress test before finalizing Phase 5 TCI algorithm.

**Decision frame for Track A vs Track B**: Track A maximizes throughput when tasks are
independently decomposable. Track B maximizes quality when tasks have tight state dependencies
(e.g., optimizer must read eval results before choosing next branch). Use coupling, not volume,
as the primary routing signal.
```

## Additional Phase 5.3 Requirement: External Session State Store

Analysis finding: Anthropic's production system stores research plans and completed phases
externally (outside conversation context) for crash recovery. Our current Phase 5 router design
has no crash-recovery contract.

Add to Phase 5.3 requirements:
```markdown
#### 5.3 External Task State Store (crash recovery contract)

The Phase 5 topology-aware-router MUST store task state in a durable external log
(not in-conversation) before dispatching subagents. Required fields:
- Task ID, task description, TCI score, routing decision (Track A/B)
- Subagent assignment list with expected outputs
- Completed phase log (append-only)
- Resume point (last completed phase)

Implementation: append to `logs/phase5_task_state.jsonl` (one JSON object per task).
On crash or timeout: resume from last completed phase via `--resume-task-id` flag.

Source: Anthropic multi-agent blog (external memory for context survival) + Phase 5 design requirement.
```

## Implementation Notes

- ROADMAP.md changes should be proposed here; factory-steward applies to ROADMAP.md directly
- No code changes in this proposal — documentation only
- The external session state store may leverage `workflow-state-convergence.md` groundwork already
  laid (noted in discussion DEFER table as "groundwork laid")

## Estimated Impact

- Gives Phase 5 design a calibrated starting point rather than an undefined binary
- Prevents post-hoc threshold retrofitting
- Makes TCI algorithm testable before Phase 5 begins (can validate thresholds against 4.2b stress test data)
- External state store enables crash recovery for long-running Phase 5 task orchestration
- Estimated ROADMAP edit: 30 minutes
