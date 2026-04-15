# Roadmap Proposal: Post-I/O ADK/A2A Decision Gate
**Date**: 2026-04-16
**Triggered by**: Google I/O 2026 (May 19-20, 33 days) — ADK v2.0 and A2A v1.1 announcements expected. Integrating before I/O creates rewrite risk.
**Priority**: P1 (high)
**Target Phase**: Phase 5 (topology-aware-router architecture)

## Rationale

The analysis and discussion (2026-04-16) recommend no new ADK/A2A integrations until after Google I/O
(May 19-20). Expected I/O announcements include ADK v2.0 beta/GA and A2A v1.1 protocol update — both
of which could introduce breaking changes to any A2A wire format or ADK tool APIs integrated before I/O.

Currently, this recommendation lives only in the 2026-04-16 research discussion. An informal recommendation
in a discussion file is archaeology context. A HOLD block at the top of the Phase 5 ROADMAP section is
a *live constraint* that any agent or collaborator reading the roadmap will see.

Engineer's Round 3 response: "I'd push to make the gate explicit about what triggers its removal."

## Proposed ROADMAP Change

Add the following HOLD block to the top of the Phase 5 section in ROADMAP.md:

```markdown
> **HOLD — No ADK/A2A Integration Until Post-I/O**
>
> Do NOT begin any A2A protocol or ADK framework integration work until after 2026-05-20.
>
> **Reason**: Google I/O 2026 (May 19-20) is expected to announce ADK v2.0 and A2A v1.1.
> Both may introduce breaking changes to wire formats and tool APIs. Work begun before I/O
> may require full rewrite after announcements.
>
> **Gate removal criteria** (ALL three must be met):
> 1. Google I/O 2026 passes (after 2026-05-20)
> 2. Post-I/O research sweep confirms A2A v1.1 wire format is stable (no breaking changes
>    vs. v1.0 documented in our KB)
> 3. ADK v2.0 public release notes reviewed and integrated into KB
>
> **Decision frame for adoption**:
> - Stay on native Claude Agent SDK subagent calls UNLESS A2A provides a concrete benefit
> - Concrete benefits: (a) mixing Claude and Gemma 4 agents for cost efficiency,
>   (b) inter-repo orchestration across independently-hosted agent services
> - Do NOT adopt A2A for protocol purity or future-proofing alone — complexity cost
>   must be justified by measurable capability or cost reduction
>
> **Owner**: factory-steward to evaluate after 2026-05-21 post-I/O sweep.
```

## Implementation Notes

- This is a ROADMAP.md documentation change — does not modify code or agent definitions
- The `daily_research_sweep.sh` event-driven queries already include I/O tracking queries
  (per researcher agent spec) — no script changes needed
- After I/O, the factory-steward's post-I/O sweep will trigger the decision point automatically
- The "concrete benefit" framing prevents premature complexity adoption

## Estimated Impact

- Converts informal research recommendation into a durable architectural gate
- Prevents any agent or collaborator from starting A2A work that needs rewrite in 34 days
- Provides clear gate-removal criteria so the hold doesn't persist past its useful life
- Estimated ROADMAP edit: 15-20 minutes
