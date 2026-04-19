# ROADMAP Update Recommendations — 2026-04-19 (Evening)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Evening analysis + evening discussion + morning discussion + all sweeps (morning, afternoon, evening Anthropic, evening Google, night consolidation)
**Status**: **ADVISORY** — ROADMAP.md is not modified by the researcher per Action Safety rules.

---

## Context

Saturday evening Mode 2c output. Morning discussion produced 6 ADOPT items (A1-A6), of which A1 (gate-first session contract) and A2 (shadow eval checklist) were **IMPLEMENTED** by the factory-steward during the day. Evening discussion produced 6 additional ADOPT items (A1-A6 evening). No P0 items remain — all pending items are P2-P3. The pipeline is in steady state heading into the 3 AM gate-first test.

Per directive: no standalone proposal files generated for quiet weekend items.

---

## PROPOSED CHANGE 1 — Phase 5.5: cmd_chain_monitor Argument-Blind Gap Design Note

**Context**: Evening discussion A2. CVE-2026-40933 (Flowise MCP STDIO RCE) demonstrates that binary-name-only allowlists are insufficient — argument injection (`npx -c`, `node -e`, `python3 -c`) bypasses the allowlist while executing arbitrary code. Our `cmd_chain_monitor.sh` uses a 60+ binary allowlist that checks command names only.

**Proposed addition to Phase 5.5 section** (append as design note):

```markdown
> **Design note (2026-04-19)**: CVE-2026-40933 demonstrates that binary-name-only allowlists are insufficient — argument injection (`npx -c`, `node -e`, `python3 -c`) bypasses the allowlist while executing arbitrary code. Phase 5.5 `PreToolUse` blocking mode MUST include argument-pattern validation alongside binary allowlisting. High-risk patterns: inline code execution (`-c`, `-e`), download-and-execute chains (`curl | bash`). Cross-reference 30-day baseline data in `logs/security/metachar_alert.jsonl` for false-positive calibration. Reference: Flowise bypass of `validateCommandInjection` (CVE-2026-40933, 12K+ instances, active exploitation confirmed).
```

**Priority**: P2
**Owner**: factory-steward

---

## PROPOSED CHANGE 2 — Risk Table: MCP Active Exploitation Escalation

**Context**: Evening discussion A3. The MCP STDIO vulnerability family has escalated from theoretical to empirically confirmed active exploitation. 3-day disclosure-to-exploitation window (April 16 disclosure → April 19 active exploitation). Total CVE count: 11+.

**Proposed update to existing risk table entry** — replace:
```
| MCP ecosystem scale (10K+ servers) changes security posture | 4-5 | Static validation adequate for Phase 4; mcp-sec-audit scheduled for Phase 5 planning period; dynamic discovery validation designed in Phase 5 | New — posture shift acknowledged 2026-04-18 |
```
with:
```
| MCP ecosystem scale (10K+ servers) changes security posture | 4-5 | Static validation adequate for Phase 4 (exposure LOW — no external MCP servers); mcp-sec-audit scheduled for Phase 5 planning period; dynamic discovery validation designed in Phase 5. **Active exploitation confirmed**: CVE-2026-40933 (Flowise, 12K+ instances, 3-day weaponization window). Phase 5 MCP connections face active attacks from day one — STDIO-only-for-dev policy is a critical security requirement | ESCALATED — active exploitation confirmed 2026-04-19 |
```

**Priority**: P3
**Owner**: factory-steward

---

## PROPOSED CHANGE 3 — Phase 6.4: EAGLE3 Status Update (WIP → Merged)

**Context**: Evening discussion A4. EAGLE3 for Gemma 4 was merged in vLLM on April 10 (PR #39450), not still WIP. Measured performance: 2.95 mean acceptance length, 38.45 tok/s accepted throughput, 64.9% draft acceptance rate, ~1.7x speedup.

**Proposed update to Phase 6.4 task** — replace:
```
- [ ] Optional: Evaluate EAGLE3 speculative decoding for Gemma 4 — 1.72x speedup with 277MB draft head. Note: verify serving framework compatibility with Gemma 4 hybrid attention
```
with:
```
- [ ] Optional: Evaluate EAGLE3 speculative decoding for Gemma 4 — **merged in vLLM** (PR #39450, Apr 10 2026). Measured: 2.95 mean acceptance length, 38.45 tok/s, ~1.7x speedup with 277MB draft head. Nearly matches Google AICore's proprietary 1.8x MTP advantage. Note: verify serving framework compatibility with Gemma 4 hybrid attention
```

**Also update inference SLA note** — the note says "~1.72x with EAGLE3 draft head" which was a projection; measured data shows ~1.7x. Minor correction.

**Priority**: P3
**Owner**: factory-steward

---

## PROPOSED CHANGE 4 — Phase 4.4: Adaptive Reasoning Caveat in Migration Runbook

**Context**: Evening discussion A6. One-sentence addition to `eval/model_migration_runbook.md` Special Considerations section.

**Proposed addition** (append to Special Considerations):
```
If a model behavior patch ships during graduated rollout, re-run shadow eval and compare CIs before proceeding.
```

Not a ROADMAP structural change — this is a runbook update. Noted here for completeness.

**Priority**: P3
**Owner**: factory-steward

---

## PROPOSED CHANGE 5 — Pending Changes from Prior Cycles (Carry-Forward)

The following changes from `roadmap-updates-2026-04-18-afternoon.md` remain pending:

| ID | Change | Priority | Status |
|----|--------|----------|--------|
| C4 | mcp-sec-audit reclassified to Phase 5 planning | P2 | Pending |
| C5 | Risk table: delegation regression + MCP scale | P1 | Pending (C5b superseded by Change 2 above) |
| C8 | Shadow eval go/no-go criteria task | P0 | **Applied** (verified in ROADMAP line 275) |
| C9 | Programmatic Tool Calling deny rule task | P1 | **Applied** (verified in ROADMAP line 282) |
| C10 | --max-budget-usd on steward scripts task | P1 | **Applied** (verified in ROADMAP line 281) |
| C12 | Haiku 3 retirement date correction (Apr 19→20) | P1 | Pending — verify post-retirement tomorrow |
| C14 | Phase 5.3.2a: Session Storage Alpha (desirable) | P2 | **Applied** (verified in ROADMAP line 362) |
| C15 | Phase 5.3.3: TS SDK velocity note | P3 | **Applied** (verified in ROADMAP line 367) |

**Remaining pending from all prior cycles**: C4 (mcp-sec-audit reclassification), C5a (delegation regression risk entry), C12 (Haiku 3 date correction — verify tomorrow).

---

## Summary Table (Evening Only — New Changes)

| ID | Change | Priority | Source |
|----|--------|----------|--------|
| C1 | Phase 5.5 cmd_chain_monitor argument-blind gap design note | P2 | Evening discussion A2 |
| C2 | Risk table MCP active exploitation escalation | P3 | Evening discussion A3 |
| C3 | Phase 6.4 EAGLE3 merged status + measured data | P3 | Evening discussion A4 |
| C4 | Migration runbook adaptive reasoning caveat | P3 | Evening discussion A6 |

No P0/P1 changes this evening. All are documentation/accuracy updates appropriate for quiet weekend processing.

---

*Produced by agentic-ai-researcher in Mode 2c (evening). Not applied — advisory only.*
