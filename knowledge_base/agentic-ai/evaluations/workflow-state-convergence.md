# Workflow State Management: Three-Way Convergence Pattern

**Date**: 2026-04-11
**Source**: Discussion 2026-04-11, ADOPT #5 (Task-level workflow state tracking)
**Status**: Design reference for Phase 5.3.2

## Pattern

Three independent agent/workflow frameworks have converged on the same approach to durable workflow state management: deterministic replay with step-level visibility. The convergence validates this as the canonical architecture for task-level state tracking in multi-agent systems.

## Implementations

### 1. Google ADK v2.0.0-alpha.3 — Lazy Scan Dedup on Resume

- **Mechanism**: On workflow resume, ADK scans the event log lazily (streaming, not full load) and deduplicates completed steps. Steps already in the log are skipped; only pending/failed steps re-execute.
- **Visibility**: Web UI renders a graph with active node highlighting — each step has a visual state (pending/running/completed/failed).
- **Key insight**: Lazy scanning avoids O(n) memory on resume for long workflows. Only the frontier of incomplete steps is held in memory.

### 2. Vercel Workflow DevKit (WDK) — Deterministic Replay

- **Mechanism**: `'use step'` directive creates idempotent, retryable steps. On crash recovery, the runtime replays the step log and skips completed steps (result cached). New steps execute normally.
- **Visibility**: Step-level observability is built-in — each step has status, duration, and result visible in the Vercel dashboard.
- **Key insight**: Deterministic replay means the workflow function re-executes from the top, but completed steps return cached results instantly. No explicit state machine needed — the step log IS the state machine.

### 3. Our Pipeline — State Machine Skip (closed_loop.sh)

- **Mechanism**: `scripts/closed_loop.sh` implements a linear state machine (GENERATE → VALIDATE → OPTIMIZE → DEPLOY) with explicit state tracking in a JSON log. On resume/retry, completed states are skipped.
- **Visibility**: `health_dashboard.py` shows agent-level health; `lifecycle_tracker.py` tracks per-skill lifecycle state.
- **Key insight**: Our approach is the simplest (linear state machine vs. DAG), but serves the same purpose: idempotent step execution with skip-on-complete.

## Convergence Summary

| Aspect | ADK | WDK | Our Pipeline |
|--------|-----|-----|-------------|
| State storage | Event log (DB) | Step log (JSON/Postgres/Redis) | JSON file |
| Resume strategy | Lazy scan + dedup | Deterministic replay | State check + skip |
| Step granularity | Per-tool-call | Per `'use step'` | Per pipeline phase |
| Visualization | Web UI (graph) | Dashboard (list) | CLI (JSON) |
| Idempotency | Automatic (dedup) | Automatic (replay) | Manual (state check) |

## Implications for Phase 5.3.2

When implementing task-level workflow state tracking:

1. **Adopt the step-log pattern** — store step results in structured JSON (not just pass/fail, but inputs, outputs, duration, retry count)
2. **Use deterministic replay semantics** — on resume, replay from start, return cached results for completed steps
3. **Output JSON, not UI** — the data layer is the deliverable; visualization is Phase 7
4. **Match WDK's `'use step'` granularity** — each tool call or agent delegation is a tracked step, not just pipeline phases
