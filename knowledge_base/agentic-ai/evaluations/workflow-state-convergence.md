# Workflow State Management: Four-Way Convergence Pattern

**Date**: 2026-04-11 (updated 2026-04-13)
**Source**: Discussion 2026-04-11 ADOPT #5 + Discussion 2026-04-12 ADOPT #7 (Managed Agents session pattern)
**Status**: Design reference for Phase 5.3.2

## Pattern

Four independent agent/workflow frameworks have converged on the same approach to durable workflow state management: deterministic replay with step-level visibility. The convergence validates this as the canonical architecture for task-level state tracking in multi-agent systems.

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

### 4. Anthropic Managed Agents — Append-Only Session Event Log

- **Mechanism**: Stateless harness reads task state from an append-only event log via `getSession(id)` + `getEvents()`. On resume, the harness calls `wake(sessionId)` which replays the event log to reconstruct state — no in-process memory needed. Completed tasks are skipped by checking event history.
- **Visibility**: Event log provides structured `TASK_START`/`TASK_COMPLETE`/`ERROR` events. The harness (brain) is separated from execution (hands) — the brain reads events to decide what to do next, then invokes agents via `execute(name, input) → string`.
- **Key insight**: The harness itself is stateless and crash-safe. All state lives in the append-only log. Resume is trivial: read the log, find incomplete tasks, continue from there. No deterministic replay needed — events are facts, not replayed computations.

## Convergence Summary

| Aspect | ADK | WDK | Managed Agents | Our Pipeline |
|--------|-----|-----|----------------|-------------|
| State storage | Event log (DB) | Step log (JSON/Postgres/Redis) | Append-only event log | JSON file |
| Resume strategy | Lazy scan + dedup | Deterministic replay | Event log retrieval | State check + skip |
| Step granularity | Per-tool-call | Per `'use step'` | Per-task (brain-hands) | Per pipeline phase |
| Visualization | Web UI (graph) | Dashboard (list) | Event log query | CLI (JSON) |
| Idempotency | Automatic (dedup) | Automatic (replay) | Event-sourced (facts) | Manual (state check) |
| Crash safety | Yes (persistent log) | Yes (persistent store) | Yes (append-only log) | No (in-memory JSON) |
| Harness statefulness | Stateful (graph in memory) | Stateful (replay requires re-execution) | Stateless (reads log on start) | Stateful (JSON in process) |

## Implications for Phase 5.3.2

When implementing task-level workflow state tracking:

1. **Adopt the Managed Agents event-log pattern** — append-only JSONL with structured events (`TASK_START`, `TASK_COMPLETE`, `ERROR`). This is closest to our existing session_log.sh format and adds crash safety without requiring deterministic replay
2. **Make the router stateless** — on startup, read the event log to reconstruct task state. No in-process state that would be lost on crash. Our `session_log.sh` (Phase 4.3) already establishes the event log format
3. **Output JSON, not UI** — the data layer is the deliverable; visualization is Phase 7
4. **Match WDK's `'use step'` granularity** — each tool call or agent delegation is a tracked step, not just pipeline phases
5. **Separate brain from hands** — the topology-aware-router (brain) should be a stateless harness that reads events and invokes agents (hands) via tool calls. Agent failures are retryable tool errors, not fatal crashes
