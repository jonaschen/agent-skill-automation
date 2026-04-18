# Skill Update Suggestions — 2026-04-18 (Afternoon)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Afternoon analysis + afternoon discussion
**Status**: **ADVISORY** — no skill files are modified by the researcher.

---

## Context

The morning and night skill-updates covered Updates 1-8 (8 proposed changes). The afternoon analysis identified one new finding relevant to skill updates: the Agent SDK `skills` option in v0.1.62. No other new skill-update-worthy findings emerged.

Per directive: minimal output. One new update plus status tracking.

---

## Update 9: `steward` Skill — Note SDK `skills` Option for Phase 5 Migration

**Skill**: `.claude/skills/steward/SKILL.md`
**Trigger**: Agent SDK v0.1.62 added top-level `skills` option (`"all"`, named list, or `[]`). This simplifies Phase 5.3.3 SDK migration — `skills: ["steward"]` replaces manual configuration.
**Priority**: P3 (informational, deferred to Phase 5)

**Proposed change**: No immediate change to skill file. Add a note to the Phase 5.3.3 ROADMAP task:
```markdown
> Agent SDK v0.1.62+ supports `skills` option in session config — `skills: ["steward"]` for targeted skill loading, `skills: []` for clean eval sessions. Simplifies SDK migration.
```

**Rationale**: When the CLI-to-SDK migration happens, this option determines how skills are loaded. The `skills: []` variant is particularly useful for eval sessions that should not trigger any skills.

---

## Cumulative Status (Full Day — All Cycles)

| # | Skill/File | Change | Priority | Status |
|---|-----------|--------|----------|--------|
| 1 | steward | Harden delegation prompting | P2 | Pending — conditional on delegation regression |
| 2 | agentic-ai-researcher | Add Task Budgets to research topics | P2 | Pending |
| 3 | factory-steward config | Cost ceiling window reset | P2 | Blocked on 4.7 rollout |
| 4 | topology-aware-router | Four-topology reference note | P3 | Pending |
| 5 | agentic-ai-researcher | Add OTEL span analysis topic | P2 | Blocked on OTEL pilot (A7) |
| 6 | steward | Add --max-budget-usd documentation | P1 | Blocked on A4 implementation |
| 7 | agentic-ai-researcher | Directive compliance template | P3 | Pending |
| 8 | daily scripts | OTEL env var shared library | P1 | Blocked on A6 implementation |
| 9 | steward / ROADMAP 5.3.3 | SDK `skills` option note | P3 | **NEW** — afternoon |

**No immediate action required.** Updates 6 and 8 execute alongside their ADOPT items (A4 and A6). All others are conditional, blocked, or informational.

---

*Produced by agentic-ai-researcher in Mode 2c (afternoon). No standalone proposal files generated — all ADOPT items have sufficient implementation detail in discussion transcripts.*
