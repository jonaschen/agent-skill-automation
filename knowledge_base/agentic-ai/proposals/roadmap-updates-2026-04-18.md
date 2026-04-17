# ROADMAP Update Recommendations — 2026-04-18

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Deep Analysis 2026-04-18 + Discussion 2026-04-18 + 2026-04-18 proposal set
**Status**: **ADVISORY** — ROADMAP.md is not modified by the researcher per Action Safety rules.
Human (or factory-steward with explicit user delegation) must apply changes.

---

## PROPOSED CHANGE 1 — Phase 4 Section: Opus 4.7 Breaking Change Audit (PREREQUISITE to Shadow Eval)

**Context**: Yesterday's C1 established Opus 4.7 shadow eval + rollout. Today's analysis identifies a PREREQUISITE: grep audit for deprecated API patterns (`temperature`, `top_p`, `top_k`, `budget_tokens`) must complete before shadow eval runs. A 400 error from a stray parameter would corrupt eval results (L10 pattern).

**Current state** (ROADMAP §Phase 4): Shadow eval infrastructure ready (`--model` flag added 2026-04-17). No audit step documented.

**Proposed addition under Phase 4 — Security/Operational Hygiene**:
```markdown
### Phase 4.4.q — Opus 4.7 Breaking Change Audit (2026-04-18, PREREQUISITE to shadow eval)
- Grep scripts/, eval/, .claude/ for `temperature`, `top_p`, `top_k`, `budget_tokens`
- Fix any non-default values (4.7 returns 400 on non-default sampling params)
- Verify no thinking config uses `{type: "enabled", budget_tokens: N}` (must be `{type: "adaptive"}`)
- After 4.7 fleet rollout: reset `cost_ceiling.sh` rolling average window to 7 days for first month
- After 30 days: expand rolling average window back to 30 days
```

**Priority**: P0 (blocks shadow eval)
**Owner**: factory-steward (pre-flight)

---

## PROPOSED CHANGE 2 — Phase 5 Section: Add OTEL Tracing + CLI-to-SDK Migration Requirements

**Context**: Agent SDK v0.1.60 shipped W3C distributed tracing (`claude-agent-sdk[otel]`). Phase 5's parallel multi-agent topology needs distributed tracing — file-based logging can't correlate interleaved parallel traces.

**Current state** (ROADMAP §Phase 5): Observability mentioned but no specific tracing standard specified. No explicit CLI-to-SDK migration task exists.

**Proposed additions under Phase 5.3.2**:
```markdown
### Phase 5.3.2 Observability Requirements (2026-04-18)
- **OTEL tracing**: Add `claude-agent-sdk[otel]` as Phase 5 dependency
- **Initial collector**: stdout JSON format (`OTEL_EXPORTER_OTLP_ENDPOINT=stdout`)
- **Jaeger/Tempo**: explicitly deferred to Phase 5.1+
- **Design principle**: OTEL-native (not vendor-specific) — supports both Agent SDK traces and future ADK OTEL integration
- **Prerequisite**: CLI → Agent SDK migration (new task below)

### Phase 5.3.3 — CLI to Agent SDK Migration
- Migrate fleet execution from `claude -p` CLI invocations to Agent SDK programmatic calls
- Enables: OTEL tracing, subagent transcript inspection, session checkpointing
- Migration order: factory-steward first (most tested), then researcher, then remaining agents
- Preserve existing perf JSON output format for backward compatibility with `agent_review.sh`
```

**Priority**: P1 (architecture decision, not immediate implementation)
**Owner**: factory-steward (for ROADMAP update); Phase 5 design sprint for implementation

---

## PROPOSED CHANGE 3 — Phase 5.3 Design Note: Session Rewind Checkpointing

**Context**: ADK v1.31.0 Session Rewind addresses our optimizer's gap — loss of in-session failure analysis when starting fresh `claude -p` invocations. Agent SDK's session management could provide equivalent semantics.

**Current state**: `workflow-state-convergence.md` covers 4 patterns (ADK lazy scan, WDK replay, Managed Agents event log, our state machine).

**Proposed addition as design note under Phase 5.3**:
```markdown
> **Design note (2026-04-18)**: Session-level checkpointing for optimizer rewind — inspired by ADK v1.31.0 Session Rewind. When migrating to Agent SDK sessions (Phase 5.3.3), evaluate whether `get_subagent_messages()` + session persistence enables rewind-to-checkpoint behavior for the optimizer's parallel branch search. The key value is preserving the agent's in-session understanding of failure patterns across rewind, not just file-level rollback. Reference: fifth pattern in `workflow-state-convergence.md`.
```

**Priority**: P1 (design note, zero implementation cost)
**Owner**: factory-steward (for ROADMAP update)

---

## PROPOSED CHANGE 4 — Phase 4 Section: Reclassify MCP Security Audit Timing

**Context**: MCP ecosystem doubled to 10K+ servers. The `mcp-sec-audit` evaluation has been deferred for 11 days.

**Current state** (ROADMAP §4.4): `mcp-sec-audit standalone evaluation — P2 (deferred from 2026-04-07 discussion)`

**Proposed change**:
```markdown
- [ ] **`mcp-sec-audit` standalone evaluation**: Time-boxed 2-4 hour evaluation — confirm installability, marginal value over existing scanner, static-only analysis mode. Prerequisite for CI/CD gate integration — P2 (complete during Phase 5 planning period, parallel with design sprint — elevated from indefinite deferral per 2026-04-18 analysis §1.6)
```

**Priority**: P2 (scheduling change, not urgency change)
**Owner**: factory-steward

---

## PROPOSED CHANGE 5 — Risk Table: Two Updated Entries

**Proposed updates to existing risk entries**:

```markdown
| Risk | Phase | Mitigation | Status |
|------|-------|-----------|--------|
| Opus 4.7 "fewer subagents" behavioral change degrades steward delegation | 4 | L13 explicit naming pattern; monitor duration:commit ratio during rollout; escalate if delegation drops >30% | New — monitoring during rollout |
| MCP ecosystem scale (10K+ servers) changes security posture | 4-5 | Static validation adequate for Phase 4; elevate mcp-sec-audit to Phase 5 planning period; dynamic discovery validation designed in Phase 5 | New — posture shift acknowledged |
```

**Priority**: P1 (risks should be tracked before the corresponding work)
**Owner**: factory-steward

---

## PROPOSED CHANGE 6 — Status Line Update

**Proposed replacement for top-of-ROADMAP status line**:
```markdown
**Status as of 2026-04-18: Phase 4 core complete. Opus 4.7 day 2: breaking change audit (P0 prerequisite) + shadow eval + graduated rollout pending. 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Haiku 3 retires TOMORROW (Apr 19) — post-retirement audit ritual ready. Countdowns: 1M context beta sunset 12d (Apr 30), Google I/O 31d (May 19-20). Phase 5 OTEL tracing adopted as design requirement. Remaining Phase 4 unchecked: mcp-sec-audit (elevated to Phase 5 planning period), MCP security consolidation (P3 deferred).**
```

**Priority**: P1 (reflects current state accurately)
**Owner**: factory-steward

---

## Summary Table

| ID | Change | Priority | Owner |
|----|--------|----------|-------|
| C1 | Phase 4.4.q: Opus 4.7 breaking change audit (prerequisite to shadow eval) | P0 | factory-steward |
| C2 | Phase 5.3.2-3: OTEL tracing requirements + CLI-to-SDK migration task | P1 | factory-steward |
| C3 | Phase 5.3 design note: Session rewind checkpointing | P1 | factory-steward |
| C4 | Phase 4.4: Reclassify mcp-sec-audit to Phase 5 planning period | P2 | factory-steward |
| C5 | Risk table: 2 new entries (delegation regression, MCP scale) | P1 | factory-steward |
| C6 | Top-of-file status line update | P1 | factory-steward |

---

*Produced by agentic-ai-researcher in Mode 2c. Not applied — advisory only. factory-steward or human operator should apply after review.*
