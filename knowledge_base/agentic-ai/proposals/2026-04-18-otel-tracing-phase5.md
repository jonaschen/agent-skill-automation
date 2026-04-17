# Skill Proposal: OTEL Tracing as Phase 5 Observability Foundation

**Date**: 2026-04-18
**Triggered by**: Agent SDK v0.1.60 shipped W3C distributed tracing via `claude-agent-sdk[otel]`. Analysis §1.3; Discussion 2.1 (ADOPT P1).
**Priority**: **P1** (high — architecture decision that shapes Phase 5 design)
**Target Phase**: Phase 5 (topology-aware multi-agent)

## Rationale

Phase 5 introduces parallel multi-agent execution (topology-aware-router dispatching to specialist cohorts). Our current observability stack is file-based (perf JSONs, session JSONL, health dashboard) — designed for Phase 4's sequential single-agent execution. Interleaved parallel traces cannot be correlated with file-based logging.

Agent SDK v0.1.60's OTEL integration propagates `TRACEPARENT`/`TRACESTATE` to CLI subprocesses, connecting SDK and CLI traces end-to-end. This is the natural observability layer for Phase 5.

The alternative — building another custom logging layer — violates L9's principle (don't encode unnecessary assumptions). OTEL is industry-standard, and the SDK already ships the integration.

**Discussion consensus (2026-04-18 Round 2)**:
- ADOPT as ROADMAP design note + requirements addition
- Pin stdout-JSON as the initial collector (not Jaeger/Tempo — that's Phase 5.1+)
- Note CLI-to-SDK migration as an implicit prerequisite

## Proposed Specification

- **Name**: `otel-tracing-phase5`
- **Type**: Architecture Decision + Requirements (no new Skill)
- **Description**: OTEL-native distributed tracing for Phase 5 multi-agent pipeline

**Key Requirements**:
1. Add `claude-agent-sdk[otel]` to ROADMAP §5.3.2 requirements
2. New Phase 5 task: "Implement OTEL collector for multi-agent pipeline traces"
3. Initial collector: stdout JSON format (`OTEL_EXPORTER_OTLP_ENDPOINT=stdout`)
4. Jaeger/Tempo deployment explicitly deferred to Phase 5.1+
5. Design principle: OTEL-native (not vendor-specific) — works with both Agent SDK traces and future ADK OTEL support

**Implicit prerequisite**: CLI-to-Agent SDK migration. Our current `claude -p` CLI invocations don't support OTEL context propagation. Phase 5 must include a "CLI → Agent SDK migration" task.

## Implementation Notes

- Zero implementation cost now — this is a design note + ROADMAP requirement addition
- The CLI-to-SDK migration is the real heavy lift; OTEL piggybacks on that work
- Cross-pollination opportunity: design our OTEL layer to be vendor-agnostic, supporting future ADK traces if Phase 5 evaluates hybrid Anthropic+Google execution

## Estimated Impact

- Enables end-to-end distributed tracing for Phase 5 multi-agent workflows
- Prevents building a bespoke logging layer that would be replaced by OTEL later
- Aligns with Anthropic's recommended observability approach ("comprehensive observability without conversation content monitoring")
