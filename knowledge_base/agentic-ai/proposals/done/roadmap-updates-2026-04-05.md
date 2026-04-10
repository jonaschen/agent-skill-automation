# ROADMAP Update Recommendations — 2026-04-05

**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)
**Input**: Analysis 2026-04-05, Discussion 2026-04-05 (ADOPT/DEFER/REJECT verdicts), ROADMAP.md current state

---

## PROPOSED CHANGES

### 1. Phase 4 — New Tasks (Security Hardening)

**PROPOSED CHANGE: Add task 4.4.3 — MCP tool description content validation**
```
- [ ] Extend `eval/mcp_config_validator.sh` with static content scanning:
      injection phrase detection, length limits, credential keyword rejection,
      allowlist bypass (`eval/mcp_server_allowlist.json`) — P0
```
**Justification**: First demonstrated attack on MCP (Invariant Labs). Our gate validates structure but not content. Discussion verdict: ADOPT P0.

**PROPOSED CHANGE: Add task 4.4.4 — Dependency pinning and audit**
```
- [ ] Lock Python deps (`pip freeze > requirements.txt`, blocking)
      + `npm audit --audit-level=high` (warning) in pre-deploy.sh — P1
```
**Justification**: LiteLLM compromise + npm axios RAT demonstrate active supply chain attacks on agent frameworks. Discussion verdict: ADOPT P1.

**PROPOSED CHANGE: Add task 4.4.5 — Model migration runbook**
```
- [ ] Create `eval/model_migration_runbook.md` — re-baseline steps for new
      model releases (separate positive/negative analysis, CI comparison,
      optimizer trigger criteria, routing regression check) — P1
```
**Justification**: Capybara/Mythos threat upgraded to P1. Opus 4.7/Sonnet 4.8 references found. Runbook is cheap insurance. Discussion verdict: ADOPT P1.

---

### 2. Phase 4 — Closed-Loop Improvement

**PROPOSED CHANGE: Update task 4.2 — State machine refactor**
```
- [ ] Refactor `scripts/closed_loop.sh` into state machine: conditional skip
      (>=0.95), parallel SECURITY_SCAN node, OPTIMIZE->VALIDATE retry counter
      (max 3), explicit REPORT_FAILURE state — P2
```
**Justification**: Linear pipeline wastes cost on high-quality Skills and lacks explicit security gate node. Discussion verdict: ADOPT P2.

---

### 3. Phase 5 — New Evaluation Task

**PROPOSED CHANGE: Add task 5.3.0 — A2A v1.0.0 evaluation**
```
- [ ] Evaluate A2A v1.0.0 (Linux Foundation, gRPC, Agent Cards) vs. custom
      6-message-type bus for scrum-team-orchestrator. Decision required before
      Phase 5 implementation begins. — P2
```
**Justification**: A2A v1.0.0 is GA under Linux Foundation governance. Gemini CLI has native A2A support. Custom bus = maintenance burden; A2A = interoperability. Analysis section 4.1 identifies the three-layer protocol stack (A2A/MCP/payments).

---

### 4. Phase 7 — New Task + Architecture Note

**PROPOSED CHANGE: Add task 7.7 — Agent payment protocol evaluation**
```
- [ ] Survey agent payment protocols (AP2, Visa TAP, x402, PayPal Agent Ready)
      and design billing adapter layer supporting multiple settlement rails.
      Document three billing patterns: subscription (Stripe), micropayment (x402),
      commerce mandate (AP2). — P2
```
**Justification**: Four competing protocols launched in 90 days. $11.79B projected market. Our Stripe-only plan doesn't account for per-invocation micropayments or agent-to-agent commerce mandates. Discussion verdict: ADOPT P2 (documentation only, no implementation).

---

### 5. Risk Table Updates

**PROPOSED CHANGE: Add new risk — MCP tool poisoning**
```
| MCP tool poisoning via malicious descriptions | 2-4 | Static content scanning in mcp_config_validator.sh; allowlist bypass; dynamic fetching deferred to Phase 5 | New — P0 mitigation in progress |
```

**PROPOSED CHANGE: Add new risk — Agent payment protocol fragmentation**
```
| Phase 7 billing assumes Stripe-only; 4 competing agent payment protocols may require multi-rail support | 7 | Task 7.7 evaluation; defer implementation until protocol war settles | New — monitoring |
```

**PROPOSED CHANGE: Update existing risk — Capybara/Mythos**
```
| Capybara/Mythos model release invalidates eval baselines and routing behavior | 3-4 | Model migration runbook (eval/model_migration_runbook.md); nightly researcher monitors for release | UPGRADED P2→P1 |
```

**PROPOSED CHANGE: Add new risk — Supply chain attacks on agent frameworks**
```
| Supply chain compromise of Python/npm dependencies used by eval tools or Claude Code | 4 | pip freeze + require-hashes (blocking); npm audit (warning); cmd_chain_monitor for runtime | New — mitigation in progress |
```

---

### 6. Lessons Learned — New Entry

**PROPOSED CHANGE: Add L8**
```
| L8 | MCP config validation must cover content, not just structure | mcp_config_validator.sh (2026-04-04) validated JSON structure and auth patterns but missed tool description injection — the actual attack vector demonstrated by Invariant Labs |
```

---

### 7. Status Line Update

**PROPOSED CHANGE: Update ROADMAP status line**
```
**Status as of 2026-04-05: Phase 4 in progress. Security hardening expanded — MCP content validation (P0), dependency pinning (P1), model migration runbook (P1) proposed. Closed-loop state machine refactor (P2) planned. G8 Iter 2 metrics: T=0.895, V=0.900. Routing regression (T=0.658) remains active.**
```

---

## NOT PROPOSED (Discussion DEFERs)

These items were evaluated and explicitly deferred. They should NOT be added to the ROADMAP now:

| Item | Reason | Revisit Trigger |
|------|--------|----------------|
| Progressive disclosure for Skill loading | Vercel plugin hooks already implement this; real problem is routing regression | Skill library exceeds 50 Skills |
| Context usage monitoring (`get_context_usage()`) | Agent SDK Python feature, our agents are Claude Code sessions | Claude Code exposes context usage API |
| Event-driven agent activation (GitHub Actions) | Premature — Phase 4 stress test must pass first | Phase 4.2 stress test complete |
| Dynamic MCP server tool fetching | Adds network failure mode to CI/CD gate | Phase 5 MCP hardening |
| ADK v2.0 graph runtime adoption | Alpha software, different ecosystem | Never (bash state machine is sufficient) |
| Conway `.cnw.zip` packaging | Building toward leaked internal software | Conway enters public beta |
| Cross-CLI compatibility (Claude Code + Gemini CLI) | Gemini CLI lacks hooks and eval framework | Gemini CLI reaches feature parity |
