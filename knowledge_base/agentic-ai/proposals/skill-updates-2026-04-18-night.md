# Skill Update Suggestions — 2026-04-18 (Night Consolidation)

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Full day's analysis + evening/night discussions
**Status**: **ADVISORY** — no skill files are modified by the researcher.

---

## Update 5: `agentic-ai-researcher` Agent — Add OTEL Span Analysis to Research Domains

**Skill**: `.claude/agents/agentic-ai-researcher.md`
**Trigger**: OTEL tracing confirmed CLI-native (evening analysis §2). If OTEL pilot (A7) succeeds, the researcher should track OTEL span schema evolution.
**Priority**: P2 (add after OTEL pilot confirms span structure)
**Condition**: Only if pilot (A7) produces actionable span data

**Proposed change**: Add to Cross-Cutting Topics:
```markdown
- OTEL trace analysis for agent behavior optimization (span schemas, trace tree patterns, token attribution)
```

**Rationale**: After OTEL traces are captured, the researcher needs to track changes in Claude Code's span schema across versions. A schema change could break automated analysis.

---

## Update 6: `steward` Skill — Add `--max-budget-usd` Documentation

**Skill**: `.claude/skills/steward/SKILL.md`
**Trigger**: Evening discussion A4 — `--max-budget-usd 10.00` being added to all steward scripts
**Priority**: P1 (documentation alignment after implementation)

**Proposed change**: Add to the steward skill's operational context:
```markdown
> **Cost control (2026-04-18)**: All steward sessions run with `--max-budget-usd 10.00` hard cap. If a session hits the budget limit, it terminates gracefully. The steward should prioritize high-value work early in the session to maximize impact within the budget.
```

**Rationale**: The steward agent needs to know about the budget constraint to optimize its work ordering. Without this context, it may start with low-priority items and get cut off before reaching high-priority work.

---

## Update 7: `agentic-ai-researcher` Agent — Directive Compliance Section

**Skill**: `.claude/agents/agentic-ai-researcher.md`
**Trigger**: Night analysis §7 directive compliance report. The directive compliance check is useful but ad-hoc. Formalizing it in the agent definition ensures every sweep includes it.
**Priority**: P3 (process improvement, not urgent)

**Proposed change**: Add to Mode 2b (Deep Analysis) template:
```markdown
## Directive Compliance Report
| Directive Guidance | Compliance |
|-------------------|-----------|
| P0 topics: depth achieved? | Met/Partial/Not met |
| P1 topics: normal depth? | Met/Partial/Not met |
| P2/Watch-only: compressed? | Met/Partial/Not met |
| Proposal volume limit (4-5)? | Met/Exceeded |
| Frozen-topic compression? | Met/Partial/Not met |
```

**Rationale**: The research-lead's directive feedback noted "output throttling needed" and "frozen-topic compression." A formal compliance section makes self-monitoring automatic.

---

## Update 8: Daily Scripts — OTEL Env Var Sourcing

**Files**: All `scripts/daily_*.sh` files
**Trigger**: Evening discussion A6 — add OTEL env vars to steward scripts
**Priority**: P1 (near-term operational change)

**Proposed change**: Create `scripts/lib/otel_config.sh` and source it from all daily scripts:
```bash
# scripts/lib/otel_config.sh
# OTEL tracing configuration for agent fleet
# Env vars are no-op without a running collector endpoint
export CLAUDE_CODE_ENABLE_TELEMETRY="${CLAUDE_CODE_ENABLE_TELEMETRY:-1}"
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA="${CLAUDE_CODE_ENHANCED_TELEMETRY_BETA:-1}"
export OTEL_TRACES_EXPORTER="${OTEL_TRACES_EXPORTER:-otlp}"
export OTEL_METRICS_EXPORTER="${OTEL_METRICS_EXPORTER:-otlp}"
export OTEL_LOGS_EXPORTER="${OTEL_LOGS_EXPORTER:-otlp}"
export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
```

**Rationale**: Shared library pattern (following existing `scripts/lib/` convention — session_log.sh, cost_ceiling.sh, check_fleet_version.sh). Configurable endpoint defaults to localhost (silently fails without collector). All values overridable via environment.

---

## Summary (Morning + Night Combined)

| # | Skill/File | Change | Priority | Condition |
|---|-----------|--------|----------|-----------|
| 1 | steward | Harden delegation prompting | P2 | Only if delegation regression detected |
| 2 | agentic-ai-researcher | Add Task Budgets to research topics | P2 | Next sweep cycle |
| 3 | factory-steward config | Cost ceiling window reset | P2 | After 4.7 rollout completes |
| 4 | topology-aware-router | Four-topology reference note | P3 | Reference only |
| 5 | agentic-ai-researcher | Add OTEL span analysis topic | P2 | After OTEL pilot succeeds |
| 6 | steward | Add --max-budget-usd documentation | P1 | After A4 implementation |
| 7 | agentic-ai-researcher | Directive compliance template | P3 | Process improvement |
| 8 | daily scripts | OTEL env var shared library | P1 | Evening discussion A6 |

---

*No immediate action required on updates 1-5, 7. Updates 6 and 8 should be implemented alongside their corresponding ADOPT items (A4 and A6).*
