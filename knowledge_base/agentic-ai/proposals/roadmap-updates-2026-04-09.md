# ROADMAP Update Recommendations — 2026-04-09

**Source**: Analysis 2026-04-09 + Discussion 2026-04-09 (7 ADOPT, 3 DEFER)
**Author**: agentic-ai-researcher (Mode 2c: L4 Strategic Planning)

---

## PROPOSED CHANGES

### 1. Phase 4 — New Task: Per-Agent Effort Level Configuration (P1 — ADOPT #1)

**PROPOSED CHANGE**: Add to Phase 4.4 Security hardening:

```
- [ ] **Per-agent effort level config**: Add `CLAUDE_CODE_EFFORT` export to all 8 daily scripts.
  Prepare commented-out lines now (high for factory-steward/researcher/reviewer, medium for
  android-sw/arm-mrs/bsp-knowledge stewards). Monitor 3 days (through April 12); enable
  selectively if cost_ceiling.sh alerts fire or duration increases >50% — P1
```

**Rationale**: Claude Code v2.1.94 raised default effort from `medium` to `high` for API-key users. Our 8-agent fleet faces 30-80% token cost increase. Analysis recommends monitor-first; discussion converged on prepare-now, enable-if-needed.

---

### 2. Phase 4 — New Task: Effort Level Tracking in Performance JSONs (P1 — ADOPT #6)

**PROPOSED CHANGE**: Add to Phase 4.3 Observability:

```
- [ ] **Effort level tracking**: Add `effort_level` field to all 8 daily scripts' performance
  JSON schema — captures $CLAUDE_CODE_EFFORT value (or "default" if unset). Enables data-driven
  effort level decisions after monitoring window — P1
```

**Rationale**: Without tracking the active effort level alongside duration, we can't correlate cost changes to the effort default change. One-line addition per script, zero risk.

---

### 3. Phase 4 — New Task: Steward Cross-Project Deprecation Check (P1 — ADOPT #7)

**PROPOSED CHANGE**: Add to Phase 4.4 Security hardening:

```
- [ ] **Steward cross-project deprecation check**: Extend 3 steward scripts
  (android-sw, arm-mrs, bsp-knowledge) to run `model_deprecation_check.sh $TARGET_REPO/.claude/`
  as pre-flight check. Warning-only (log + steering note), not blocking. Closes gap between
  pipeline guard and external repos — P1
```

**Rationale**: Analysis identifies remaining risk: external repos may reference deprecated models. Our guard only scans this repo. Stewards already have `TARGET_REPO` variables and pre-flight checks.

---

### 4. Phase 5.3.0 — Timing Annotation: A2A Evaluation Deferred to Post-I/O (P1 — ADOPT #3)

**PROPOSED CHANGE**: Update existing task 5.3.0 text:

```
#### 5.3.0 A2A protocol evaluation (pre-implementation gate)
- [ ] Evaluate A2A vs. custom 6-message-type bus. **Deferred to post-Google I/O
  (after May 20, 2026)**. A2A v1.1 expected at I/O; evaluating v1.0 before then
  wastes effort. Continue monitoring pre-I/O leak window (late April). If A2A v1.1
  leaks early, start evaluation immediately. Time-boxed 2-4 hours. — P2
```

**Rationale**: 40 days to Google I/O (May 19-20). A2A v1.1 likely to be announced. Evaluating v1.0 when v1.1 is imminent wastes the 2-4 hour time box.

---

### 5. Phase 7 — New Section: Three-Target Deployment Architecture (P1 — ADOPT #4)

**PROPOSED CHANGE**: Add to Phase 7 after the existing design consideration note:

```
#### 7.x Deployment Targets (from analysis 2026-04-09)
Three distinct deployment targets, each serving a different market:
- **SKILL.md** (local, CLI) — developer market via Claude Code / Gemini CLI
- **Managed Agents** (cloud, API) — enterprise market via `ant` CLI or API
- **Conway** (product, persistent) — end-user market via persistent cloud agents (contingent on Conway shipping)

The SKILL.md format is the portability layer: agent definition is the constant, deployment target is the variable. If Conway does not ship, collapses to two targets.
```

**Rationale**: Analysis crystallized this insight from Managed Agents launch. First time the three-target model has been articulated. Captures strategic direction before it's buried in daily analysis churn.

---

### 6. Phase 7 — New Note: Cross-Platform SKILL.md Adapter (P3 — DEFER #2)

**PROPOSED CHANGE**: Add to Phase 7 tasks:

```
- [ ] **Cross-platform SKILL.md format comparison**: Before building transpiler, document field-level
  mapping between `.claude/skills/` and `.gemini/skills/` formats. Do against then-current
  Gemini CLI version (currently preview, format still evolving) — P3 (deferred from 2026-04-09;
  revisit at Phase 7 start)
```

**Rationale**: Gemini CLI now has `.gemini/skills/` mirroring our structure. Format differences are reportedly minor. Comparison only becomes actionable at Phase 7 start.

---

### 7. Risk Table Addition: Effort Level Cost Escalation (MEDIUM — NEW)

**PROPOSED CHANGE**: Add to risk tracking:

```
| Effort cost escalation | MEDIUM | 2026-04-09 | Default effort raised medium→high increases token costs 30-80% for 8-agent fleet. Self-mitigating via cost_ceiling.sh (5x rolling avg). Monitor 3-5 days. |
```

---

## DEFERRED ITEMS (for tracking — no ROADMAP change needed)

| Item | Reason | Revisit |
|------|--------|---------|
| Managed Agents SKILL.md adapter (`skill_to_managed_agent.py`) | API is public beta, will change; Phase 7 work | Phase 7 start, after Managed Agents GA |
| `estimated_tokens` in perf JSONs | Claude Code doesn't expose parseable token counts | When Claude Code adds machine-readable session summaries |

---

*Generated 2026-04-09 by agentic-ai-researcher (Mode 2c: L4 Strategic Planning)*
