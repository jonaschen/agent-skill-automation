# Skill Proposal: Managed Agents Architecture Evaluation

**Date**: 2026-04-09
**Triggered by**: Claude Managed Agents public beta launch (April 8, 2026)
**Priority**: P1 (high — strategic architecture decision for Phase 5/7)
**Target Phase**: Phase 5 (design note) + Phase 7 (deployment target)

## Rationale

Anthropic launched Claude Managed Agents with secure cloud containers, built-in tools, SSE streaming, stateful sessions, and a multiagent research preview. This creates a three-layer impact on our pipeline:

1. **Phase 4 (no change)**: Local cron approach provides filesystem access and zero container overhead that Managed Agents can't match for our use case.
2. **Phase 5 (monitor)**: Multiagent preview could provide an alternative to our custom A2A message bus. When documentation is released, a 2-hour compatibility assessment is needed.
3. **Phase 7 (deploy target)**: Managed Agents is a viable third deployment target alongside SKILL.md (local) and Conway (product).

## Proposed Specification

- **Name**: managed-agents-compat-assessment (not a skill — a time-boxed evaluation task)
- **Type**: Architecture evaluation document
- **Key Deliverable**: `knowledge_base/agentic-ai/evaluations/managed-agents-multiagent-compat.md`
- **Trigger**: When Anthropic publishes multiagent preview documentation
- **Time box**: 2 hours maximum

## Assessment Criteria

1. Can Managed Agents' multiagent primitives express our 6 message types? (TASK_ASSIGNMENT, PARTIAL_OUTPUT, REVIEW_REQUEST, REVIEW_RESULT, ESCALATION, WATCHDOG_HALT)
2. What is the container startup latency? (our agents need <5s start)
3. Does the session persistence model support our daily-run pattern?
4. What are the rate limits for a 6-8 agent fleet?
5. Cost comparison: Managed Agents hosting vs. local cron execution

## Implementation Notes

- Do NOT build a `skill_to_managed_agent.py` adapter yet — API is beta, will change
- A 30-minute design mapping document (SKILL.md fields → Managed Agents concepts) is acceptable as interim
- Full adapter implementation deferred to Phase 7 after Managed Agents GA

## Estimated Impact

- Validates "SKILL.md as portability layer" thesis
- Informs Phase 5 multiagent architecture choices
- Provides Phase 7 with a concrete cloud deployment path for enterprise customers

---

*Proposal generated 2026-04-09 by agentic-ai-researcher (Mode 2c: L4 Strategic Planning)*
