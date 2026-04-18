# ROADMAP Update Recommendations — 2026-04-18 (Afternoon)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Afternoon analysis + afternoon discussion + full day's prior outputs
**Status**: **ADVISORY** — ROADMAP.md is not modified by the researcher per Action Safety rules.

---

## Context

This is the fourth Mode 2c output today. The morning and night roadmap-updates covered C1-C13 (13 proposed changes). The afternoon discussion added 5 new ADOPT items (A11-A15). This file covers only the NEW afternoon items that require ROADMAP entries. Items A11 (shadow eval sequencing) and A12 (weekend priority list) are operational instructions to factory-steward, not ROADMAP changes.

Per directive feedback: no standalone proposal files generated. All implementation detail is in the afternoon discussion transcript.

---

## PROPOSED CHANGE 14 — Phase 5.3.2a: Session Storage Alpha as Desirable Capability

**Context**: Afternoon discussion A13. Agent SDK TypeScript v0.2.113 shipped Session Storage Alpha (`SessionStore`, `InMemorySessionStore`, `importSessionToStore()`). Creates dual-observability alongside OTEL traces.

**Proposed addition to existing Phase 5.3.2a subsection** (append after OTEL entry):
```markdown
- [ ] **Session Storage integration (desirable)**: Agent SDK TS v0.2.113+ `SessionStore` provides full conversation replay alongside OTEL structured spans. Existing session logging (`logs/sessions/*.jsonl`) is a partial substitute. Evaluate SDK feature parity (Python vs TypeScript) at Phase 5 start. Only adopt if target SDK supports Session Storage — P2
```

**Priority**: P2 (desirable, not required)
**Owner**: factory-steward

---

## PROPOSED CHANGE 15 — Phase 5.3.3: TypeScript SDK Velocity Note

**Context**: Afternoon discussion A14. TypeScript SDK advanced 22 versions in 10 days (v0.2.92→v0.2.114) vs Python SDK 5 versions (v0.1.58→v0.1.63). TypeScript ships Session Storage, OTEL propagation first.

**Proposed addition to Phase 5.3.3** (append to existing task description):
```markdown
> **SDK choice note (2026-04-18)**: TypeScript SDK (v0.2.x) advancing significantly faster than Python (v0.1.x) — Session Storage Alpha, OTEL trace context propagation ship TypeScript-first. However, our pipeline tooling is Python/bash, making TypeScript integration higher-effort (Node.js runtime dependency). Re-evaluate SDK target at Phase 5 start.
```

**Priority**: P3 (informational note)
**Owner**: factory-steward

---

## PROPOSED CHANGE 16 — Phase 4: Shadow Eval Execution Sequencing

**Context**: Afternoon discussion A11. Shadow eval has been P0 since morning but hasn't been executed through two factory-steward cycles. L12 (Urgency Bias, inverted) — the gate-blocker keeps getting displaced by discussion-sourced ADOPT items.

**Proposed note in ROADMAP next-actions or factory-steward handoff**:

Not a ROADMAP structural change. Factory-steward's next session should execute shadow eval BEFORE processing ADOPT backlog items:
```
python3 eval/run_eval_async.py --model claude-opus-4-7 .claude/agents/meta-agent-factory.md
```
Manual execution is also viable and faster. Go/no-go criteria (A2) are defined in the night discussion.

**Priority**: P0 (operational sequencing, not a ROADMAP task)
**Owner**: factory-steward / Jonas (manual execution option)

---

## Summary Table (Full Day — All Cycles)

| ID | Change | Priority | Source | Status |
|----|--------|----------|--------|--------|
| C1 | Opus 4.7 breaking change audit task | P0 | Morning | **Applied by factory-steward** |
| C2 | Phase 5.3.2-3: OTEL + CLI-to-SDK migration | P1 | Morning | **Applied by factory-steward** |
| C3 | Phase 5.3 design note: Session rewind | P1 | Morning | **Applied by factory-steward** |
| C4 | mcp-sec-audit reclassified to Phase 5 planning | P2 | Morning | Pending |
| C5 | Risk table: delegation regression + MCP scale | P1 | Morning | Pending |
| C6 | Status line update | P1 | Morning | **Applied by factory-steward** |
| C7 | Status line supersedes C6 with night corrections | P1 | Night | **Applied** (verified in ROADMAP) |
| C8 | Shadow eval go/no-go criteria task | P0 | Night | Pending |
| C9 | Programmatic Tool Calling deny rule task | P1 | Night | Pending |
| C10 | --max-budget-usd on steward scripts task | P1 | Night | Pending |
| C11 | Phase 5.3.2a OTEL tracing requirements | P1 | Night | **Applied by factory-steward** |
| C12 | Haiku 3 retirement date correction (Apr 19→20) | P1 | Night | Pending |
| C13 | Risk table: Programmatic Tool Calling entry | P1 | Night | **Applied by factory-steward** |
| C14 | Phase 5.3.2a: Session Storage Alpha (desirable) | P2 | **Afternoon** | NEW |
| C15 | Phase 5.3.3: TS SDK velocity note | P3 | **Afternoon** | NEW |
| C16 | Shadow eval execution sequencing (operational) | P0 | **Afternoon** | NEW (not a ROADMAP change) |

**Applied count**: 7 of 16 (C1, C2, C3, C6, C7, C11, C13 — verified against ROADMAP status).
**Pending ROADMAP changes**: C4, C5, C8, C9, C10, C12, C14, C15 (8 items).
**Operational items**: C16 (sequencing instruction, not ROADMAP).

---

*Produced by agentic-ai-researcher in Mode 2c (afternoon). Not applied — advisory only.*
