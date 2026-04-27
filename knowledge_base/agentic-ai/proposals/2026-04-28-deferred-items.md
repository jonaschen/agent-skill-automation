# Deferred Items — 2026-04-28

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Source**: Discussion 2026-04-28 — three explicit DEFERs, one explicit REJECT

---

## D1: Transpiler Implementations (`transpile_to_claude.py`, `transpile_to_gemini.py`)

**Original proposal**: Discussion Round 1 Proposal 2 (Innovator) — full transpiler scaffolding alongside the canonical schema.

**Reason for deferral** (Discussion Round 1 Engineer):
1. **Empirical validation gated on Gemini CLI install** — blocked day 7+. Writing code that targets a vendor format we cannot test against creates code-debt.
2. **Open question in dispatch comparison Section 8**: does Gemini expose `invoke_subagent` as a callable tool name, or is it purely internal? If "internal only," the entire `transpile_to_gemini.py` design changes.
3. **Reversibility argument**: Schema-only commitment (Adopt #3 in companion proposal `2026-04-28-canonical-skill-schema.md`) is reversible. Transpiler code is harder to roll back.

**Engineer's recommendation**: Commit the canonical schema today. When Gemini CLI install completes:
- Validate `invoke_subagent` exposure question empirically
- Then implement `transpile_to_claude.py` first (we can test this immediately against our 23 agents)
- Then implement `transpile_to_gemini.py` with empirical Gemini CLI feedback

**Revisit when**:
- Gemini CLI v0.39.0+ stable installed AND
- Empirical answer to `invoke_subagent` exposure question

**Priority if unblocked**: P2

---

## D2: `PostToolUse.duration_ms` Optimizer Wiring → Joint Trigger+Latency Optimization

**Original proposal**: Discussion Round 1 Proposal 3 (Innovator) — extend `eval/run_eval_async.py` to capture `duration_ms` from hook payload and store per-tool latency in `eval/experiment_log.json`. Pre-condition for the optimizer evolving from pure trigger-rate optimization to joint trigger+latency optimization (S1 advance).

**Reason for deferral** (Discussion Round 1 Engineer):
1. **CC upgrade blocker**: v2.1.119 ships `duration_ms` in hook payload; Jonas's CC upgrade is day 5+ with no fixed date. Worse, today shifted target from v2.1.118 → v2.1.119, with explicit "avoid v2.1.120" advice. Building hook-payload parsing logic now means writing code against an API surface that may shift again before we run it.
2. **`run_eval_async.py` doesn't currently use hooks** — it parses `claude -p` stdout. Wiring `duration_ms` requires either (a) a hook script that writes per-tool timing to a file the eval reads, or (b) parsing OTEL output. Both are real engineering, not "just add a field."
3. **Joint loss function design** — moving from trigger-rate optimization to joint trigger+latency optimization requires defining the joint loss function (weights, normalization, cost-of-latency). This is a non-trivial design decision.

**Engineer's recommendation**: Document the design as a roadmap note at `eval/optimizer-latency-roadmap.md`. Specify:
- Hook payload field (`PostToolUse.duration_ms`)
- Storage location in `experiment_log.json` (per-test, per-tool latency dict)
- Optimizer signal change ("joint trigger+latency optimization" — define joint loss)
- Implementation gated on CC upgrade

**Revisit when**: CC v2.1.119 (or v2.1.121+ if v2.1.120 is being avoided) installed.

**Priority if unblocked**: P3 (post-CC-upgrade work)

---

## D3: Orchestration-Protocol Comparison (A2A Multi-Hop vs SDK Forked Subagents)

**Original proposal**: Discussion Round 3 Proposal 1 (Innovator) — natural follow-up to today's dispatch-primitive comparison. The remaining open S3 architectural unknown.

**Reason for deferral** (Discussion Round 3 Engineer):
- Factory queue is at ~15 items, P2 backlog aging since Apr 22. Adding a research P0 while factory is behind on its own queue creates competing pressure (queue conflict).
- Better to **sequence**: factory clears P2 backlog this session (target ~12 items remaining), then the *next* research-lead directive promotes orchestration-protocol comparison to P0.
- The methodology is set (today's dispatch comparison establishes the pattern); the work is well-bounded (~300-500 lines, comparable to dispatch comparison).

**Revisit when**: Factory P2 backlog cleared (queue drops below 12). Then promote to P0 in the **next-but-one** research-lead directive (i.e., the directive after the factory's P2-clearance session).

**Priority if unblocked**: P1 for the next-but-one directive.

---

## R1: Standalone File `evaluations/inspect-resume-pattern.md`

**Original proposal**: Discussion Round 1 Proposal 1 (Innovator) — Phase 5 design as a standalone file at `knowledge_base/agentic-ai/evaluations/inspect-resume-pattern.md`.

**Reason for rejection** (Discussion Round 1 Engineer):
- Fragments the Phase 5 design surface. Phase 5 design index (factory P1 item #1) exists as the single entry point for Phase 5 design work. A standalone parallel file is exactly the pattern Round 1 of the 2026-04-24 discussion warned against.
- Same content, different location. Adopting as section "5.4 Recovery: Inspect-Resume Pattern" *within* the Phase 5 design index achieves the same outcome with no fragmentation.

**Replacement**: Companion proposal `2026-04-28-inspect-resume-phase5.md` adopts the section-within-index path. R1 is closed.

---

*These items are not abandoned — D1/D2/D3 are tracked with explicit unblock conditions. The factory-steward should check unblock conditions during planning sessions. R1 is permanently closed.*
