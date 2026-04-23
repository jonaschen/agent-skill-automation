# Team Recommendations — 2026-04-23 (Night)

**Source**: Analysis 2026-04-23-night + Discussion 2026-04-23-night + Sweep 2026-04-23-night
**Author**: agentic-ai-researcher (Mode 2c)

---

## Factory-Steward Priority Queue Update (~17 items)

### New Items from Tonight (2 net-new ADOPTs, within ≤2 cap)

| # | Item | Priority | Effort | Strategic | Source |
|---|------|----------|--------|-----------|--------|
| NEW-1 | MCP tool hooks → S1 design note | P3 | 10 min | S1 | Discussion 2026-04-23-night A1 |
| NEW-2 | Cloud Next → Phase 5 governance mapping + SPIFFE reference | P2 | 20 min | S2/Phase 5 | Discussion 2026-04-23-night A2 |

### Updated Priority Queue (ordered)

**Priority 1 — Highest impact, execute first**:

| # | Item | Priority | Effort | Strategic | Source | Status |
|---|------|----------|--------|-----------|--------|--------|
| 1 | ~~G20 MCP false-positive tests (test_60-64)~~ | ~~P2~~ | ~~30 min~~ | ~~Phase 2~~ | ~~Discussion 2026-04-23 A4~~ | **DONE** (afternoon factory) |
| 2 | ~~Orchestration taxonomy note~~ | ~~P2~~ | ~~20 min~~ | ~~S2/Paper~~ | ~~Discussion 2026-04-23 A1~~ | **DONE** (afternoon factory) |
| 3 | Phase 5 design index | P2 | 15 min | Phase 5/I/O prep | Discussion 2026-04-23 A2 |
| 4 | Capability diff worked example | P2 | 15 min | S1 | Discussion 2026-04-23 A3 |

**Priority 2 — Important, execute after Priority 1**:

| # | Item | Priority | Effort | Strategic | Source |
|---|------|----------|--------|-----------|--------|
| 5 | Cloud Next → Phase 5 governance mapping + SPIFFE | P2 | 20 min | S2/Phase 5 | **NEW** Discussion 2026-04-23-night A2 |
| 6 | Remote MCP feasibility study | P2 | 30 min | Phase 5.6 | Carried from Apr 22 |
| 7 | Async dispatch convergence §5 | P2 | 20 min | Phase 5.6 | Carried from Apr 22 |
| 8 | Agent format comparison matrix | P2 | 25 min | S3 | Carried from Apr 22 |
| 9 | Phase 5 context management section | P2 | 15 min | Phase 5.6 | Carried from Apr 22 |
| 10 | SessionStore design note | P2 | 10 min | Phase 5 | Carried from Apr 21 |

**Priority 3 — Batch together in one session**:

| # | Item | Priority | Effort | Notes |
|---|------|----------|--------|-------|
| 11 | Hybrid routing design note | P3 | 10 min | Carried |
| 12 | Phase 5.1 planning confirmation note | P3 | 5 min | Carried |
| 13 | I/O playbook note + sweep corrections log | P3 | 10 min | Carried |
| 14 | Gemini CLI channel selection note | P3 | 5 min | Carried |
| 15 | OTEL effort integration plan note | P3 | 5 min | Carried |
| 16 | MCP tool hooks → S1 design note | P3 | 10 min | **NEW** Discussion 2026-04-23-night A1 |

**Queue math**: 2 items completed (G20 + taxonomy note) in afternoon factory. +2 new items tonight. Net queue: ~17 items (was ~15, +2 completed, +2 new, net ~15 active). ~5 sessions to clear at 3 items/session average. Below 20 alert threshold. HEALTHY.

---

## Human Action Items for Jonas (Updated)

| # | Item | Priority | Status | Notes |
|---|------|----------|--------|-------|
| 1 | **Upgrade CC to v2.1.118** | P0 | BLOCKED | Was v2.1.117 — version updated per correction C1. Blocks S1 shadow eval re-run. Now also gets MCP tool hooks + SendMessage cwd fix. |
| 2 | **Install Gemini CLI** | S3 | BLOCKED | Day 5 of this blocker. Gates all S3 implementation work. |
| 3 | **Programmatic Tool Calling deny rule** | P1 | PENDING | Add `Tool(code_execution_20260120)` to settings.json permissions.deny. |

---

## Directive Recommendations for Research-Lead

| ID | Recommendation | Rationale |
|----|---------------|-----------|
| DR1 | Downgrade S3 tool portability to "one-sentence monitoring" | Both vendors confirmed MCP convergence within 24h (CC v2.1.118 MCP tool hooks + Cloud Next managed MCP servers). Tool access is solved. |
| DR2 | Update "Vertex AI" references to "Gemini Enterprise Agent Platform" | Cloud Next rebrand. Factory steward should batch-update KB/design docs. |
| DR3 | Cancel quiet-day auto-compression for next cycle | Cloud Next follow-up announcements expected Apr 23-24. Full sweep needed. |
| DR4 | Track A2A version divergence (spec v1.2 per press, GitHub v1.0.0) | Phase 5 gate-removal criteria references A2A version. Need tagged release. |
| DR5 | Tighten P0 human action to "v2.1.118" (was v2.1.117) | Correction from discussion C1. |

---

## Deferred Items (from Discussion)

| ID | Item | Reason | Revisit When |
|----|------|--------|-------------|
| D1 | SDK-based eval runner with ThinkingConfig.display | Phase 5 refactor; current eval uses CLI | Phase 5 design freeze |
| D2 | MCP tool hook prototype for cron pipeline | Requires SDK migration or dedicated MCP server | Phase 5.6 (Remote MCP) |
| D3 | Mariner "Teach and Repeat" S1 experiment | Needs Phase 5 SessionStore for persistent session state | Phase 5 SessionStore design active |

---

## No Structural Team Changes

The three-agent pipeline performed well tonight. Sweep quality: 9 findings across both vendors (4 Anthropic + 5 Google Cloud Next), all data-anchored with source URLs. Analysis produced actionable cross-references (MCP convergence, vendor philosophy divergence, governance gap). Discussion stayed within ≤2 net-new ADOPT cap.

| Metric | Value | Assessment |
|--------|-------|------------|
| Sweep scope | 2 vendor tracks, 13 KB files updated | Comprehensive |
| Analysis findings | 9 (4 Anthropic, 5 Cloud Next) | Strong — Cloud Next was a major event |
| Discussion ADOPTs | 2 net-new (within ≤2 cap) | Compliant |
| Discussion REJECTs | 2 (ServerToolUseBlock audit, Phase 7 pricing) | Appropriate scope discipline |
| Factory queue | ~17 items (~5 sessions, 2 completed today) | Healthy |
| Strategic alignment | S1: 1 finding + 1 ADOPT, S2: 2 findings + 1 ADOPT, S3: 1 finding + 1 DR | Balanced |
