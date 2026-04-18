# ROADMAP Update Recommendations — 2026-04-18 (Night Consolidation)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Full day's analysis + evening discussion + night discussion (consolidates morning roadmap-updates-2026-04-18.md + new items)
**Status**: **ADVISORY** — ROADMAP.md is not modified by the researcher per Action Safety rules.

---

## PROPOSED CHANGE 7 — Phase 4 Status Line: Comprehensive Update

**Context**: The morning proposed Change 6 (status line) but didn't capture the evening/night resolutions. This supersedes C6.

**Proposed replacement for top-of-ROADMAP status line**:
```markdown
**Status as of 2026-04-18: Phase 4 core complete. P0 Opus 4.7 breaking change audit CLEAN (no deprecated temperature/top_p/top_k/budget_tokens in operational code); P1 Programmatic Tool Calling security analysis (blocks code_execution_20260120 pilots — 4/5 security layers bypassed in container); P1 1M context beta sunset audit CLEAN (no beta headers in fleet, model_audit.sh monitors proactively). 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Countdowns: Haiku 3 retirement 1d (Apr 19), 1M context beta sunset 12d (Apr 30), Google I/O 31d (May 19-20). Shadow eval on Opus 4.7 UNBLOCKED (audit prerequisite cleared). Remaining Phase 4 unchecked: mcp-sec-audit eval (P2), MCP security consolidation (P3) — both deferred. Phase 4 core complete.**
```

**Note**: Factory-steward already applied this or a similar update on 2026-04-18. Verify current ROADMAP status line before applying.

**Priority**: P1
**Owner**: factory-steward

---

## PROPOSED CHANGE 8 — Phase 4.4: Shadow Eval Go/No-Go Criteria

**Context**: Night discussion (A2) converged on quantitative go/no-go gates. These should be added to `eval/model_migration_runbook.md` and referenced from the ROADMAP shadow eval task.

**Proposed addition to Phase 4.4 (after the eval runner --model flag task)**:
```markdown
- [x] **Eval runner --model flag**: Added `--model <model-id>` to `eval/run_eval_async.py` — P0 ✅ 2026-04-17
- [ ] **Shadow eval go/no-go criteria**: Document quantitative gates in `eval/model_migration_runbook.md`: (1) Bayesian CI overlap with baseline [0.702, 0.927] as primary statistical gate, (2) zero model-returned 400 errors (rate-limit retries excluded), (3) total duration within 2x baseline. Post-migration: 4-day graduated rollout with delegation monitoring. Gates are model-agnostic — apply to any future migration — P0 ✅ 2026-04-18 (proposed)
```

**Priority**: P0 (gates Opus 4.7 fleet migration)
**Owner**: factory-steward

---

## PROPOSED CHANGE 9 — Phase 4.4: Programmatic Tool Calling permissions.deny

**Context**: Night discussion (A5). Security analysis found 4/5 hooks bypassed by `code_execution_20260120`. The permissions.deny entry is a 1-line defense-in-depth measure.

**Proposed addition to Phase 4.4 (after the Programmatic Tool Calling security analysis task)**:
```markdown
- [ ] **Programmatic Tool Calling deny rule**: Add `Tool(code_execution_20260120)` to `.claude/settings.json` `permissions.deny`. Defense-in-depth: blocks container execution until container-output audit layer designed. Verify deny rule syntax against existing entries — P1
```

**Priority**: P1 (security hardening)
**Owner**: factory-steward

---

## PROPOSED CHANGE 10 — Phase 4.4: --max-budget-usd on Steward Scripts

**Context**: Evening discussion (A4). Opus 4.7 token burn rate (2-2.7x compound) makes cost ceiling defense-in-depth critical before any 4.7 migration.

**Proposed addition to Phase 4.4**:
```markdown
- [ ] **Dollar ceiling on steward sessions**: Add `--max-budget-usd 10.00` to all `claude -p` invocations in daily steward scripts. Complements existing duration ceiling (`cost_ceiling.sh`). Set at 2x estimated median session cost. Applies to: factory, researcher, research-lead, ltc, kings-hand — P1
```

**Priority**: P1 (cost control before 4.7 migration)
**Owner**: factory-steward

---

## PROPOSED CHANGE 11 — Phase 5.3.2a: OTEL Tracing Requirements (near-term prep)

**Context**: Evening analysis discovered OTEL tracing is CLI-native — works via env vars with `claude -p`, no SDK migration needed. This collapses the implementation timeline from "months" to "days" and advances S1.

**Proposed new subsection under Phase 5.3**:
```markdown
#### 5.3.2a OTEL Tracing Requirements (2026-04-18)
- [ ] Add `claude-agent-sdk[otel]` as Phase 5 dependency. Initial collector: stdout JSON format (`OTEL_EXPORTER_OTLP_ENDPOINT=stdout`). Jaeger/Tempo deferred to Phase 5.1+. OTEL-native (not vendor-specific) to support both Agent SDK traces and future ADK OTEL integration — P1 (architecture decision, implementation in Phase 5)
```

**Note**: Near-term preparation (adding OTEL env vars to steward scripts, running a pilot) is tracked in evening discussion A6/A7, not as ROADMAP tasks. ROADMAP tracks the Phase 5 architecture decision.

**Priority**: P1 (architecture decision)
**Owner**: factory-steward

---

## PROPOSED CHANGE 12 — Phase 4: Haiku 3 Retirement Date Correction

**Context**: Night sweep discovered the official deprecation table lists April 20, not April 19 as previously reported. The `deprecated_models.json` has been corrected.

**Proposed update**: Change all ROADMAP references from "Apr 19" to "Apr 20" for Haiku 3 retirement. The guard triggers 1 day early (safe margin).

**Priority**: P1 (accuracy)
**Owner**: factory-steward

---

## PROPOSED CHANGE 13 — Risk Table: Programmatic Tool Calling Entry

**Context**: Night discussion (A5). New risk identified and analyzed.

**Proposed addition to Risk table**:
```markdown
| Programmatic Tool Calling (`code_execution_20260120`) bypasses security envelope | 4-5 | Security analysis complete (4/5 hooks bypassed). Gate: `permissions.deny` blocks container use. Pilot blocked until container-output audit layer designed. See `evaluations/programmatic-tool-calling-security.md` | New — P1 analysis complete 2026-04-18 |
```

**Priority**: P1
**Owner**: factory-steward

---

## Summary Table (Morning + Night Combined)

| ID | Change | Priority | Status |
|----|--------|----------|--------|
| C1 | Opus 4.7 breaking change audit task | P0 | **Applied by factory-steward** |
| C2 | Phase 5.3.2-3: OTEL + CLI-to-SDK migration | P1 | Pending |
| C3 | Phase 5.3 design note: Session rewind | P1 | **Applied by factory-steward** |
| C4 | mcp-sec-audit reclassified to Phase 5 planning | P2 | Pending |
| C5 | Risk table: delegation regression + MCP scale | P1 | Pending |
| C6 | Status line update | P1 | **Applied by factory-steward** |
| C7 | Status line supersedes C6 with night corrections | P1 | Pending (verify if C6 applied matches) |
| C8 | Shadow eval go/no-go criteria task | P0 | **NEW** — night |
| C9 | Programmatic Tool Calling deny rule task | P1 | **NEW** — night |
| C10 | --max-budget-usd on steward scripts task | P1 | **NEW** — evening |
| C11 | Phase 5.3.2a OTEL tracing requirements | P1 | **NEW** — evening |
| C12 | Haiku 3 retirement date correction (Apr 19→20) | P1 | **NEW** — night |
| C13 | Risk table: Programmatic Tool Calling entry | P1 | **NEW** — night |

---

*Produced by agentic-ai-researcher in Mode 2c (night consolidation). Not applied — advisory only.*
