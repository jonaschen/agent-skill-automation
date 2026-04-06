# Skill Proposal: A2A SDK Evaluation (Time-Boxed Research)
**Date**: 2026-04-07
**Triggered by**: A2A v1.0 TSC confirmed with 8-org governance (Google, AWS, Microsoft, IBM, Cisco, Salesforce, SAP, ServiceNow) + 5-language SDK coverage (sweep 2026-04-07)
**Priority**: P2 (medium)
**Target Phase**: 5 (pre-implementation research for task 5.3.0)
**Status**: ADOPT (discussion consensus — Round 3, Proposal 3.1)

## Rationale

ROADMAP task 5.3.0 requires evaluating A2A v1.0.0 vs. custom 6-message-type bus for the scrum-team-orchestrator. The 8-org TSC governance announcement significantly de-risks A2A adoption — governed protocols at the Linux Foundation don't die.

This is a 2-4 hour time-boxed research task, not an implementation commitment. It produces the data needed for the 5.3.0 decision gate before Phase 5 implementation begins.

## Proposed Specification

- **Name**: a2a-sdk-evaluation
- **Type**: Research task (not a Skill/Agent)
- **Output**: `knowledge_base/agentic-ai/evaluations/a2a-sdk-eval.md`
- **Key Evaluation Points**:
  1. Install the Python A2A SDK
  2. Register a minimal test agent with an AgentCard
  3. Send a test message and verify round-trip interop
  4. **Critical test**: Can A2A's message format express our 6 message types? (TASK_ASSIGNMENT, PARTIAL_OUTPUT, REVIEW_REQUEST, REVIEW_RESULT, ESCALATION, WATCHDOG_HALT)
  5. Document: install experience, API ergonomics, message format compatibility, overhead vs. direct function calls
- **Time box**: 2-4 hours maximum. If installation alone takes >1 hour, document blockers and abort.

## Implementation Notes

- The format compatibility test (point 4) is the key decision input. If A2A can express all 6 message types natively, it provides interop for free. If it can't, custom extensions erode the benefit.
- The hybrid option (A2A for external interop + lightweight internal bus) is the likely outcome — document the boundary clearly.
- Phase 7 distribution benefit: A2A-compatible agents can be registered in enterprise platforms without building a custom marketplace.

## Estimated Impact

- **Decision quality**: Provides concrete data for the 5.3.0 decision gate instead of speculation.
- **Risk reduction**: A 2-4 hour investment that prevents expensive wrong decisions in Phase 5.
- **Phase 7 option value**: If A2A fits, it opens enterprise distribution channels for AaaS.
