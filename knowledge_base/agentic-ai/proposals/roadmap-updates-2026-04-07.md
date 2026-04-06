# ROADMAP Update Recommendations — 2026-04-07
**Source**: Analysis 2026-04-07 + Discussion 2026-04-07
**Author**: agentic-ai-researcher (Mode 2c: Strategic Planning)

---

## PROPOSED CHANGES

### 1. Phase 4 — New Security Tasks (P0)

**PROPOSED CHANGE**: Add two new tasks to Phase 4.4 (Security hardening):

```markdown
#### 4.4 Security hardening for autonomous execution (continued)
- [ ] **MCP tool-call depth monitor**: Add `mcp__*` pattern matching to `post-tool-use.sh` — per-session counter, alert at >15, block at >25 MCP calls per step. Emit structured alerts to `logs/security/mcp_depth_alert.jsonl` — P0 (2026-04-07 analysis: 658x cost amplification threat)
- [ ] **Per-run duration-based cost ceiling**: Create `scripts/lib/cost_ceiling.sh` — 30-day rolling average duration, 5x multiplier ceiling. Test on factory-steward first, then roll to all 6 steward scripts — P0 (2026-04-07 analysis: no existing per-run cost guardrail)
```

**Rationale**: The 658x MCP cost amplification attack with <3% detection rate is the most financially dangerous MCP vector documented. Our nightly fleet is automated and unattended with zero cost guardrails. These two tasks form a defense-in-depth pair: depth monitor prevents mid-run, cost ceiling catches post-run.

---

### 2. Phase 4 — New Risk Entry (P0)

**PROPOSED CHANGE**: Add to Key Risks table:

```markdown
| MCP cost amplification via prolonged tool-calling chains (658x demonstrated) | 4 | MCP tool-call depth monitor in post-tool-use.sh (alert >15, block >25); per-run duration ceiling (5x 30-day avg); future: CI/CD gate MCP pattern rejection | New — P0, mitigation proposed 2026-04-07 |
```

**Rationale**: This is a distinct threat category from tool poisoning (data exfiltration). Cost amplification is financial DoS, not data theft. Existing risks table covers poisoning but not cost amplification.

---

### 3. Phase 4 — Tracking Tasks for Deferred Items (P2)

**PROPOSED CHANGE**: Add tracking entries to Phase 4.4:

```markdown
- [ ] **`mcp-sec-audit` standalone evaluation**: Time-boxed 2-4 hour evaluation — confirm installability, marginal value over existing scanner, static-only analysis mode. Prerequisite for CI/CD gate integration — P2 (deferred from 2026-04-07 discussion; revisit after depth monitor is stable)
- [ ] **MCP security suite consolidation**: When 4+ MCP security components exist, consolidate into unified `eval/mcp_security_suite.sh` — P3 (deferred from 2026-04-07 discussion; premature until components exist)
```

---

### 4. Phase 5 — New Planning Tasks (P2)

**PROPOSED CHANGE**: Add to Phase 5 tasks:

```markdown
#### 5.6 Skill lifecycle automation (planning)
- [ ] **Auto-promotion design**: Extend `promote_cases.py` with `--auto-detect` mode — count skill-name + trigger-verb pairs, surface promotion candidates when threshold exceeded (>5 same-verb triggers). Requires >100 logged invocations. Minimal viable version of Gemini CLI's passive skill extraction — P2 (2026-04-07 analysis: cross-pollination from Gemini CLI background memory service)
```

**Rationale**: Gemini CLI's passive skill extraction closes the loop from "observed behavior" to "reusable capability" automatically. Our pipeline requires human intervention. This design task bridges the gap without implementation commitment.

---

### 5. Phase 5.3.0 — Update with Governance Signal (P2)

**PROPOSED CHANGE**: Update existing task 5.3.0 description:

```markdown
#### 5.3.0 A2A protocol evaluation (pre-implementation gate)
- [ ] Evaluate A2A v1.0.0 (Linux Foundation, gRPC, Agent Cards, **8-org TSC governance confirmed 2026-04-07**) vs. custom 6-message-type bus for scrum-team-orchestrator. **Critical test: can A2A message format express all 6 message types natively?** Decision required before Phase 5 implementation begins. Time-boxed 2-4 hour research task. Write findings to `knowledge_base/agentic-ai/evaluations/a2a-sdk-eval.md` — P2
```

**Rationale**: TSC governance with 8 organizations (including competitors Google, AWS, Microsoft) means A2A won't be abandoned. This changes the risk calculus and should be reflected in the task description.

---

### 6. Phase 7 — Dual Deployment Model Note (P3)

**PROPOSED CHANGE**: Add strategic note to Phase 7 overview:

```markdown
**Design consideration (2026-04-07)**: Two deployment models are emerging — CLI-native (SKILL.md files for Claude Code/Gemini CLI) and cloud-native (persistent services via Conway/A2A/Gemini Enterprise). Phase 7 AaaS should support both: local SKILL.md for developer consumption + distributable packages for cloud platforms. Conway's `.cnw.zip` and A2A agent registration are candidate bridge mechanisms.
```

**Rationale**: The agent platform landscape is bifurcating. Designing for dual deployment now avoids expensive Phase 7 refactoring later.

---

### 7. Update ROADMAP Status Line

**PROPOSED CHANGE**: Update the status line at top of ROADMAP.md:

```markdown
**Status as of 2026-04-07: Phase 4 in progress. Eval infra bugs (L10) confirmed fixed 2026-04-06 — awaiting full eval re-run for T/V recovery confirmation. Two P0 security proposals: MCP tool-call depth monitor + per-run cost ceiling (response to 658x cost amplification threat). MCP hash-pinning (P1) and assumption registry (P2) shipped 2026-04-06.**
```

---

### 8. New Lesson Learned (L11)

**PROPOSED CHANGE**: Add to Lessons Learned:

```markdown
| L11 | Security layers respond to attacker capabilities, not model capabilities — they are cumulative, not simplifiable | L9 states "stress-test and simplify as models improve." But security components encode attacker assumptions, not model assumptions. Attackers don't get weaker. Consolidate security layers for maintainability, but don't remove them. (2026-04-07 analysis §2.3) |
```

**Rationale**: Important nuance to L9's simplification principle. Without this distinction, someone applying L9 might incorrectly simplify security checks.

---

## Summary

| # | Change | Priority | Phase |
|---|--------|----------|-------|
| 1 | Add MCP depth monitor + cost ceiling tasks | P0 | 4 |
| 2 | Add MCP cost amplification risk entry | P0 | 4 |
| 3 | Add mcp-sec-audit eval + security suite consolidation tracking | P2-P3 | 4 |
| 4 | Add auto-promotion design task | P2 | 5 |
| 5 | Update A2A evaluation task with governance signal | P2 | 5 |
| 6 | Add dual-deployment model design note | P3 | 7 |
| 7 | Update ROADMAP status line | — | Top |
| 8 | Add L11 (security layers are cumulative) | — | Lessons |
