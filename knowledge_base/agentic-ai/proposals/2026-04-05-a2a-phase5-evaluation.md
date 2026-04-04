# Skill Proposal: A2A v1.0.0 Evaluation for Phase 5 Message Bus
**Date**: 2026-04-05
**Triggered by**: A2A v1.0.0 GA under Linux Foundation governance; three-layer protocol stack analysis
**Priority**: P2 (medium)
**Target Phase**: 5 (Multi-Agent Orchestration)

## Rationale

The agent protocol stack has solidified into three layers:
- Layer 1 (Agents): A2A (agent-to-agent, v1.0.0, Linux Foundation)
- Layer 2 (Tools): MCP (model-to-tool, 6,400+ servers, Linux Foundation)
- Layer 3 (Payments): AP2/TAP/x402/PayPal (competing)

Our Phase 5 plans a custom 6-message-type schema for the `scrum-team-orchestrator`. A2A v1.0.0 provides:
- Signed Agent Cards (identity verification)
- gRPC transport (high-performance)
- Task lifecycle management (tasks/list, filtering, pagination)
- Linux Foundation governance (stability guarantee)

The cost of a custom bus is maintenance burden. The cost of A2A is additional complexity. But A2A gives Layer 1 interoperability for free — our agents become discoverable by external A2A systems.

Gemini CLI already has native A2A subagent support. Claude Code does not (yet). This is a gap worth evaluating before Phase 5 design is finalized.

## Proposed Specification
- **Name**: a2a-evaluation (evaluation task, not a Skill)
- **Type**: Architecture evaluation
- **Description**: Compare custom 6-message-type bus vs. A2A v1.0.0 for Phase 5 scrum-team-orchestrator
- **Key Capabilities**:
  - Evaluate A2A v1.0.0 spec against our 6 message types (TASK_ASSIGNMENT, PARTIAL_OUTPUT, REVIEW_REQUEST, REVIEW_RESULT, ESCALATION, WATCHDOG_HALT)
  - Assess integration complexity with Claude Code's agent architecture
  - Benchmark gRPC transport latency vs. file-based message passing
  - Evaluate Agent Card identity system for steward agent authentication
- **Tools Required**: N/A (evaluation/research)

## Implementation Notes
- This is a PRE-Phase-5 evaluation task, not an implementation task
- Key question: can A2A's Task type express our 6 message types without losing semantics?
- If yes: adopt A2A, gain interoperability
- If no: keep custom schema, document the gaps A2A doesn't cover
- Gemini CLI's A2A native support means our Skills could eventually delegate to Gemini-based agents

## Estimated Impact
- Avoids building a custom message bus that becomes a maintenance burden
- Positions our pipeline for cross-platform agent interoperability
- Decision must be made before Phase 5 implementation begins
