# Deferred Items — 2026-04-18 (Night Consolidation)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Source**: Consolidated evening + night discussions 2026-04-18

---

## D1: OTEL Trace Analyzer Agent Design (S1)

**Original proposal**: Night discussion 1.1 — Design an OTEL trace analyzer agent that reads spans from completed steward sessions and generates improvement suggestions (inefficient tool patterns, delegation anomalies, cost outliers, convergence failures).

**Reason for deferral**: The Engineer correctly identified that the design should be based on empirical span data, not assumptions about span structure. The OTEL pilot (A7) must produce data before the analyzer can be designed.

**What to build when unblocked**: Agent or analysis script that reads OTEL trace JSON and auto-generates:
- Steering notes for agents with anomalous tool call patterns
- Cost optimization recommendations based on token attribution per span
- Delegation regression alerts based on subagent invocation counts

**Revisit when**: OTEL pilot (A7) produces span structure data and confirms tool-level visibility.

**Priority if unblocked**: P1 (directly advances S1 strategic priority)

---

## D2: Cross-Platform Agent Experiment (S3)

**Original proposal**: Night discussion 2.2 — Run the same agent (e.g., tech-writing-style-enforcer) on both Claude Code and Gemini CLI, compare trigger accuracy, output quality, and tool usage patterns.

**Reason for deferral**: Two blockers:
1. **Blocked on format comparison (A8)**: If Gemini CLI has no comparable agent definition format, the experiment is premature.
2. **Gemini CLI access**: Requires Gemini API key and billing setup. Infrastructure not verified.

**Revisit when**: (a) A8 (format comparison) confirms a comparable format exists, AND (b) Gemini CLI access and billing verified.

**Priority if unblocked**: P2 (S3 experimental research)

---

## D3: Deploy OTEL Collector (Jaeger/Tempo)

**Original proposal**: Evening discussion — Deploy a full observability stack (Jaeger or Grafana Tempo) for trace visualization.

**Reason for deferral**: Ops overhead. The OTEL env vars (A6) + console exporter pilot (A7) provide sufficient data for initial S1 research without maintaining infrastructure.

**Revisit when**: Phase 5 observability sprint begins, or OTEL pilot demonstrates sufficient trace richness to justify collector deployment.

**Priority if unblocked**: P2

---

## D4: ADK Session Rewind Integration

**Original proposal**: Morning analysis §1.2 — Implement session-level checkpointing for optimizer rewind, inspired by ADK v1.31.0.

**Reason for deferral**: Requires Agent SDK migration (Phase 5.3.3). Our current `claude -p` CLI invocations don't support session persistence or checkpointing.

**What was done**: Design note added to ROADMAP §5.3 (morning proposals). Cross-pollination opportunity logged in analysis. `workflow-state-convergence.md` to be updated with ADK Session Rewind as fifth pattern.

**Revisit when**: Phase 5.3.3 CLI-to-SDK migration begins.

**Priority if unblocked**: P1

---

## D5: Task Budgets for Steward Cost Control

**Status**: Updated from morning D1. CLI availability question RESOLVED — Task Budgets are API-only. CLI uses `--max-budget-usd` instead.

**Resolution**: `--max-budget-usd 10.00` adopted as A4 (evening discussion). Task Budgets themselves deferred until Phase 5 Agent SDK migration, when the programmatic `query()` API becomes available.

**Revisit when**: Phase 5 Agent SDK migration (5.3.3)

---

*These items are tracked with explicit unblock conditions. The factory-steward should check unblock conditions during Phase 1.5 Gate-Priority Triage.*
