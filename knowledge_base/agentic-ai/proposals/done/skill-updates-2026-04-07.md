# Skill Update Suggestions — 2026-04-07
**Source**: Analysis 2026-04-07 + Discussion 2026-04-07
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## 1. `agentic-cicd-gate` — Add MCP Cost Pattern Awareness (P1, Deferred)

**Current state**: The CI/CD gate evaluates trigger rate, security scans (content scanning, hash pinning), and Bayesian deployment threshold.

**Proposed update**: When MCP depth monitor (Proposal 1.1) is producing baseline data, extend the gate to reject Skills that produce abnormal MCP interaction patterns during eval. Gate criterion: `max_mcp_calls_per_test <= 20`.

**Why deferred**: Requires hook infrastructure integration with eval runner. The runtime monitor provides immediate protection. Implement after depth monitor is stable.

**Files**: `.claude/agents/agentic-cicd-gate.md` — add MCP call pattern criterion to gate logic section.

---

## 2. `factory-steward` — Add Cost Ceiling Action Items (P0)

**Current state**: Factory steward drives ROADMAP tasks, fixes regressions, acts on ADOPT items from research discussions.

**Proposed update**: Add to the steward's action items for next run:
1. Implement MCP tool-call depth monitor in `post-tool-use.sh` (ADOPT #1)
2. Implement duration-based cost ceiling in `scripts/lib/cost_ceiling.sh` (ADOPT #2)
3. Add `mcp-sec-audit` standalone evaluation to ROADMAP Phase 4 tracking (DEFER #2)
4. Add auto-promotion concept to ROADMAP Phase 5 planning (DEFER #4)

**Mechanism**: These action items should be picked up by factory-steward via its normal ADOPT-item consumption from `knowledge_base/agentic-ai/discussions/`.

**Files**: No skill definition change needed — the steward reads discussions directly.

---

## 3. `agentic-ai-researcher` — Add Adversa AI TOP 25 to Tracking (P1)

**Current state**: Researcher tracks MCP security developments but the Adversa AI TOP 25 framework is not in the explicit tracking list.

**Proposed update**: Add to Research Domains > Cross-Cutting Topics:
- "MCP security frameworks (OWASP Top 10, Adversa AI TOP 25, CoSAI)"
- Add `mcp-sec-audit` and Golf Scanner to practical tooling tracking

**Rationale**: Three independent MCP security frameworks now exist. The researcher should systematically track coverage across all three, not just OWASP.

**Files**: `.claude/agents/agentic-ai-researcher.md` — add to Cross-Cutting Topics section.

---

## 4. All Steward Agent Definitions — Add Cost Ceiling Reference (P0, after implementation)

**Current state**: Steward agent definitions don't reference cost guardrails.

**Proposed update**: After `scripts/lib/cost_ceiling.sh` is implemented, add a note to each steward's operational context:
- "Cost ceiling: duration-based, 5x 30-day rolling average. Alerts logged to `logs/security/cost_alert.jsonl`."

**Why after implementation**: Don't update agent definitions for features that don't exist yet.

**Files**: All `.claude/agents/*-steward.md` files — add to operational context/constraints section.

---

## 5. `post-tool-use.sh` Hook — MCP Depth Tracking (P0)

**Current state**: Hook performs lifecycle logging and permission checks. Does not monitor MCP tool-call depth.

**Proposed update**: Add `mcp__*` prefix detection, per-session counter, alert at >15, block at >25. Follow `cmd_chain_monitor.sh` pattern (temp file per session).

**This is not a Skill update** — it's a hook enhancement. Listed here because it's the highest-priority action item from today's discussion.

**Files**: `.claude/hooks/post-tool-use.sh` — add MCP depth tracking section.

---

## 6. Knowledge Base INDEX.md — Add Security Framework Tracking (P2)

**Current state**: INDEX.md tracks topics by vendor (Anthropic/Google). MCP security is covered under Anthropic > MCP.

**Proposed update**: Add a dedicated "MCP Security Landscape" entry under Cross-Cutting that tracks:
- OWASP MCP Top 10 (our coverage: 4/10 good, 3/10 partial, 3/10 none)
- Adversa AI TOP 25 (coverage: not yet assessed)
- CoSAI white paper (risk analysis framework)
- Practical tools: mcp-scan (integrated), mcp-sec-audit (pending eval), Golf Scanner (not evaluated)

**Rationale**: MCP security is evolving rapidly with multiple frameworks. Centralizing tracking prevents coverage gaps.

**Files**: `knowledge_base/agentic-ai/INDEX.md` — add MCP Security section.

---

## Summary

| # | Target | Change | Priority | Status |
|---|--------|--------|----------|--------|
| 1 | agentic-cicd-gate | Add MCP cost pattern criterion | P1 | Deferred (needs baseline data) |
| 2 | factory-steward | Pick up ADOPT items from discussion | P0 | Via normal discussion consumption |
| 3 | agentic-ai-researcher | Track Adversa AI TOP 25 + tooling | P1 | Ready to implement |
| 4 | All steward agents | Add cost ceiling reference | P0 | After cost_ceiling.sh exists |
| 5 | post-tool-use.sh | MCP depth tracking | P0 | Ready to implement |
| 6 | INDEX.md | MCP Security Landscape section | P2 | Ready to implement |
