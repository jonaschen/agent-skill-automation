# Skill Proposal: Phase 5 Design Freeze (May 22-26)

**Date**: 2026-04-20
**Triggered by**: Night discussion A3 — scattered Phase 5 design documents need consolidation
**Priority**: P2 (calendar commitment, not code change)
**Target Phase**: Phase 5 planning
**Strategic Priority**: S2 (multi-agent orchestration), S3 (platform generalization)

## Rationale

Phase 5 has accumulated ~8 design documents over 3 weeks with no consolidation:

| Document | Topic |
|----------|-------|
| `workflow-state-convergence.md` | Four-way convergence analysis |
| `credential-isolation-design.md` | Credential isolation for multi-agent execution |
| `post-io-response-playbook.md` | Google I/O response plan |
| `permission-cache-design.md` | HITL session-scoped permission cache |
| `programmatic-tool-calling-security.md` | Container execution security analysis |
| ROADMAP Phase 5 design notes | Scattered across 5.1-5.5 |
| MCP STDIO argument validation data | `metachar_alert.jsonl` baseline |
| A2A SDK evaluation notes | Deferred post-I/O |

Google I/O (May 19-20) will bring ADK v2.0, potentially A2A v1.1, and possibly Gemini 4 — all of which affect Phase 5 design decisions. A dedicated design week post-I/O prevents these from being processed piecemeal.

## Proposed Specification

- **Name**: phase-5-design-freeze
- **Type**: Calendar commitment + ROADMAP entry (not a skill)
- **Deliverable**: Single `PHASE_5_DESIGN.md` consolidating all design inputs

## Schedule

- **May 19-20**: Google I/O — researcher processes all announcements
- **May 20-21**: Post-I/O response playbook executes (A2A v1.1, ADK v2.0 evaluation)
- **May 22-26**: Design Freeze week
  - Researcher synthesizes I/O findings + existing design docs
  - Factory-steward implements Phase 5 prerequisites (SDK updates, A2A v1.1 eval)
  - Jonas reviews and approves PHASE_5_DESIGN.md
- **May 27+**: Phase 5 implementation begins

## Implementation Notes

- This is a calendar commitment written into ROADMAP for durability
- "Design Freeze" (not "Sprint") — the output is a decision document, not iterative exploration
- The freeze document should have a clear structure: architecture decisions, security requirements, I/O-informed changes, implementation order, acceptance criteria
- Prerequisites that emerged from I/O should be handled during the freeze week, not deferred

## Estimated Impact

- Prevents Phase 5 from starting with scattered, potentially contradictory design assumptions
- Ensures I/O announcements (which may change A2A, ADK, or model capabilities) are absorbed before implementation commitments
- Gives Jonas a single document to review rather than 8 separate design notes
