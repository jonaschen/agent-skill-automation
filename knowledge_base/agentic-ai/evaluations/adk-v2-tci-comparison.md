# ADK v2.0 ↔ Phase 5 TCI Comparison Framework

**Date**: 2026-04-22
**Source**: Discussion 2026-04-21 A2 (P2, S2), carried from Apr 21 directive
**Status**: Our design pre-filled; ADK v2.0 GA columns blank (fill post-I/O)
**Feeds**: Phase 5.6 Design Freeze (May 22-26)
**Purpose**: Pre-build the comparison so post-I/O evaluation is structured fill-in,
not open-ended research. Decompresses the I/O → Design Freeze crunch (2-6 days).

---

## Decision Frame

From ROADMAP: "Adopt A2A/ADK only if mixing Anthropic + Google agents provides concrete
cost or capability benefit." This comparison tests that hypothesis.

**Null hypothesis**: ADK v2.0 adds complexity with no benefit for our use case. We stay
on native Claude Agent SDK subagent calls.

**Rejection criteria**: ADK v2.0 must demonstrate at least ONE of:
1. A concrete orchestration primitive we lack (not just a different name for the same thing)
2. >20% cost reduction on a measurable subset of tasks (e.g., cheap Gemini models for eval)
3. Access to a capability Claude SDK cannot provide (e.g., cross-vendor agent dispatch)

If none of these are met, ADK is tracked but not adopted.

---

## Dimension 1: Task Routing Architecture

| Aspect | Our Phase 5 TCI Design | ADK v2.0 (alpha.3 known) | ADK v2.0 GA (post-I/O) |
|--------|----------------------|--------------------------|------------------------|
| **Routing mechanism** | TCI score → Track A (parallel) or Track B (flagship) | Graph-based `BaseNode` with edges/conditions | _TBD_ |
| **Coupling metric** | 4-dimension TCI index: file overlap, sequential deps, shared state, communication needs | No explicit coupling metric — routing is structural (graph edges) | _TBD_ |
| **Thresholds** | TCI ≤2 → parallel, TCI 3-6 → evaluate, TCI ≥7 → flagship. Calibrate against 4.2b data | Not threshold-based — developer defines graph | _TBD_ |
| **Medium-band handling** | Conservative: default to Track B (flagship). Advisor Tool for Sonnet+Opus hybrid. | Unknown | _TBD_ |
| **Dynamic re-routing** | Not planned in v1 — fixed at dispatch time | Conditional edges support dynamic branching | _TBD_ |

**Assessment column** (fill post-I/O): Does ADK's graph routing solve problems our TCI threshold model cannot?

## Dimension 2: State Management & Crash Recovery

| Aspect | Our Phase 5 Design | ADK v2.0 (alpha.3 known) | ADK v2.0 GA (post-I/O) |
|--------|-------------------|--------------------------|------------------------|
| **State persistence** | Append-only JSONL (Managed Agents event-log pattern). `logs/phase5_task_state.jsonl` | Event-based with lazy scan dedup on resume | _TBD_ |
| **Crash recovery** | Resume from last completed phase via `--resume-task-id` | Lazy scan skips completed steps, re-executes pending | _TBD_ |
| **State visibility** | Structured JSON (not web UI — UI is Phase 7) | Web UI with active node highlighting | _TBD_ |
| **Checkpoint pattern** | Session-level (session_log.sh + trace_id) | Session Rewind (ADK v1.31.0, get_subagent_messages()) | _TBD_ |
| **Convergence ref** | `workflow-state-convergence.md` — five-way pattern | Part of same convergence pattern | _TBD_ |

**Assessment column**: Does ADK's lazy-scan dedup offer advantages over our append-only JSONL?

## Dimension 3: Agent Execution Model

| Aspect | Our Phase 5 Design | ADK v2.0 (alpha.3 known) | ADK v2.0 GA (post-I/O) |
|--------|-------------------|--------------------------|------------------------|
| **Agent dispatch** | `claude -p` → Agent SDK migration (5.3.3). Subagent calls via SDK | Python/Java BaseNode invocations within graph | _TBD_ |
| **Isolation** | `env -i` + explicit credential passthrough (credential-isolation-design.md) | Plugin isolation model (tools scoped per agent/plugin) | _TBD_ |
| **Async execution** | Cron dispatch → Agent SDK sessions. Polling via perf JSON | `background=true`, polling/streaming via Interactions API | _TBD_ |
| **Model heterogeneity** | 8 Opus + 8 Sonnet in fleet, per-agent model assignment | Per-node model selection in graph | _TBD_ |
| **Sub-agent communication** | 6-message typed bus (A2A transport) | Internal graph state passing | _TBD_ |

**Assessment column**: Does ADK's per-node model selection provide benefits beyond our per-agent assignment?

## Dimension 4: Security & Permissions

| Aspect | Our Phase 5 Design | ADK v2.0 (alpha.3 known) | ADK v2.0 GA (post-I/O) |
|--------|-------------------|--------------------------|------------------------|
| **Permission model** | Mutually exclusive (review agents ≠ execution agents). `check-permissions.sh` | Plugin-scoped tool declarations (mcpServers in App/Plugin) | _TBD_ |
| **Destructive op gates** | `CLAUDE_INITIATOR_TYPE` + `post-tool-use.sh` blocks force-push etc. in cron | Unknown — no published cron-mode hardening | _TBD_ |
| **MCP transport policy** | STDIO dev-only, Streamable HTTP for prod (Phase 5.5) | Native MCP in ADK Java 1.0 (transport unspecified) | _TBD_ |
| **PreToolUse reflection** | Phase 5.5 — mandatory reflection gate for destructive tools | Unknown | _TBD_ |

**Assessment column**: Does ADK's plugin isolation model offer security advantages for multi-agent?

## Dimension 5: Observability & Cost

| Aspect | Our Phase 5 Design | ADK v2.0 (alpha.3 known) | ADK v2.0 GA (post-I/O) |
|--------|-------------------|--------------------------|------------------------|
| **Tracing** | OTEL (stdout JSON, Phase 5.3.2a). Jaeger/Tempo deferred. | ADK Events/Trace View (ADK v1.31+) | _TBD_ |
| **Cost tracking** | duration-based ceiling (cost_ceiling.sh) + dollar budget (--max-budget-usd) | Unknown per-node cost tracking | _TBD_ |
| **Session replay** | session_log.sh JSONL → Agent SDK Session Storage (Phase 5) | Session Rewind (get_subagent_messages) | _TBD_ |
| **Fleet monitoring** | agent_review.sh dashboard, fleet_manifest.json | Unknown fleet-level tooling | _TBD_ |

**Assessment column**: Does ADK provide native observability that saves us building our own?

---

## Existing Phase 5 Design Documents (reference for consolidation)

These documents encode decisions already made. The comparison should reference these,
not re-derive our positions.

| Document | Core Decision | Status |
|----------|--------------|--------|
| `workflow-state-convergence.md` | Adopt Managed Agents event-log pattern for state | Decided |
| `credential-isolation-design.md` | `env -i` + explicit passthrough for Phase 5 | Decided |
| `permission-cache-design.md` | Session-scoped auto-approve patterns | Decided |
| `programmatic-tool-calling-security.md` | Block until audit layer designed | Decided |
| `post-io-response-playbook.md` | 6-category I/O announcement matrix | Decided |
| ROADMAP Phase 5 design notes (inline) | Various (8+ notes) | Mixed |
| `metachar_alert.jsonl` baseline | 30-day profile for PreToolUse tuning | Data collection ongoing |
| A2A SDK evaluation | Integration pattern selection | **Deferred to post-I/O** |

---

## Post-I/O Filling Protocol

When ADK v2.0 GA ships at I/O (expected May 19-20):

1. Researcher fills in all `_TBD_` cells from ADK v2.0 GA docs/changelog
2. Researcher writes each "Assessment column" answer (1-2 sentences)
3. Factory-steward evaluates null hypothesis rejection criteria (3 conditions above)
4. Result feeds Phase 5.6 Design Freeze (May 22-26) as input document

**Timeline**: I/O (May 19-20) → researcher fills (May 20-21) → factory evaluates (May 21-22) → Design Freeze starts (May 22)

---

*This framework pre-fills our design dimensions from existing Phase 5 documents and ROADMAP.
ADK columns are intentionally blank — filling them from pre-GA alpha documentation would
create false precision. The value is in the structure, not premature content.*
