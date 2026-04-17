# Deferred Items — 2026-04-18

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Source**: Discussion 2026-04-18

---

## D1: Task Budgets for Steward Cost Control

**Original proposal**: Discussion §1.2 — Add `--task-budget <tokens>` flag to daily steward scripts for model-level token ceiling enforcement (Opus 4.7 public beta feature).

**Reason for deferral**: Two blockers:
1. **CLI availability unknown** — Task Budgets may be API-only, not available via `claude -p`. Must verify before implementation planning.
2. **Depends on 4.7 fleet rollout** — Task Budgets are Opus 4.7-only. Cannot deploy until proposal `2026-04-18-opus-47-breaking-change-audit.md` and `2026-04-17-opus-4-7-shadow-eval-rollout.md` complete.

**Engineer's recommendation**: When unblocked, start with observational mode — set budget high enough to never trigger (e.g., 1M tokens), capture actual token consumption in perf JSONs, THEN set a meaningful ceiling after 2 weeks of data.

**Revisit when**: (a) CLI availability confirmed via `claude -p --help` or documentation, AND (b) Opus 4.7 fleet rollout complete (all Opus-class agents on 4.7).

**Priority if unblocked**: P1

---

## D2: Four-Topology TCI Dispatch

**Original proposal**: Discussion §2.2 — Expand Phase 5 TCI router from 2 tracks (A/B) to 4 dispatch targets matching Anthropic's official taxonomy (Subagents, Teams, Three-Agent Harness, Orchestrator-Worker).

**Reason for deferral**: Premature vocabulary alignment. The four-topology model is Anthropic's taxonomy for their research system (document synthesis, web search, coding tasks). Our pipeline has a narrower task distribution (skill generation, evaluation, optimization, deployment). We don't know whether our tasks distribute across 4 TCI bands or cluster in 2.

**Engineer's objection**: The Subagents pattern (TCI <= 2, single agent with no delegation) is particularly questionable for our pipeline — even our simplest task (single skill validation) requires factory + validator coordination.

**Yesterday's context**: The 2026-04-17 discussion already proposed a three-track model (A/B/C with Advisor). Today's four-track proposal was rejected as further complexity without validated benefit.

**Revisit when**: Phase 5 §5.1 50-task TCI benchmark is built and analyzed. If actual task distribution shows 4 distinct bands, revisit. If tasks cluster in 2-3 bands, the current model is sufficient.

**Priority if revisited**: P1 (design, not implementation)

---

*These items are not abandoned — they are explicitly tracked with unblock conditions. The factory-steward should check unblock conditions during planning sessions.*
