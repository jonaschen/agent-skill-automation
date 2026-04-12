# Skill Proposal: External Session State Logging

**Date**: 2026-04-12
**Triggered by**: Managed Agents brain-hands architecture deep dive (sweep 2026-04-12) — stateless harnesses with append-only session logs
**Priority**: P2 (medium)
**Target Phase**: Phase 4.3 (Observability) → foundation for Phase 5.3.2

## Rationale

Anthropic's Managed Agents architecture stores execution state in a durable Session log
outside the LLM context window, using `getEvents()` for selective retrieval. Our steward
agents currently dump all state into conversation context and lose everything on crash.

The discussion (2026-04-12) reached consensus: implement the event logging layer now for
observability, but **defer** crash-recovery-on-resume logic to Phase 5 where external
session state is a first-class requirement. The logging alone provides:
- Structured data for project-reviewer (replaces git-log mining)
- Foundation for Phase 5.3.2 task-level workflow state tracking
- Visibility into steward task progression beyond performance JSONs

## Proposed Specification

- **Name**: session-state-logging (pipeline infrastructure, not a Skill)
- **Type**: Shared library + integration
- **Components**:
  1. `scripts/lib/session_log.sh` — shared library with `log_event(agent, event_type, payload)`
  2. JSONL output to `logs/sessions/{agent}-{date}.jsonl`
  3. Event types: `TASK_START`, `TASK_COMPLETE`, `TASK_SKIP`, `ERROR`, `CHECKPOINT`
- **Integration points**: All 7 daily steward/reviewer scripts call `log_event` at key milestones

## Implementation Notes

- Append-only JSONL — never overwrite, never truncate
- Each event: `{"timestamp":"ISO8601", "agent":"name", "type":"EVENT_TYPE", "payload":{...}}`
- No crash-recovery logic — stewards remain stateless-by-design until Phase 5
- project-reviewer can read session logs for structured review data
- 30-day retention (same as performance JSONs)
- Estimated effort: 2-3 hours (library + integration into 7 scripts)

## Estimated Impact

- **Observability**: project-reviewer gets structured task-level data instead of git-log inference
- **Phase 5 foundation**: Session log format becomes the template for Phase 5.3.2 workflow state
- **Debugging**: Task-level granularity for diagnosing steward session failures
- **Cost**: Near-zero runtime overhead (file append per milestone)
