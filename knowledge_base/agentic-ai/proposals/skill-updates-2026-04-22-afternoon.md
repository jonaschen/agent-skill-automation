# Skill Update Suggestions — 2026-04-22 Afternoon

**Source**: Analysis 2026-04-22-afternoon + Discussion 2026-04-22-afternoon (6 ADOPTs, 2 DEFERs, 0 REJECTs)
**Directive compliance**: Single-cycle volume, shadow eval is factory-only

---

## No New Skill Proposals

Today's afternoon findings (CC v2.1.117 context window fix, triple agent definition convergence, event compaction convergence, Gemini CLI preview unification) do not warrant new skills. They produce **design inputs** for Phase 5/6 and **S1 diagnostic improvements** for existing infrastructure.

The combined factory queue has ~16 items. No skill creation, modification, or deprecation is needed.

---

## Existing Skill/Script Updates

### 1. `eval/model_migration_runbook.md` — Re-Run Protocol Addition (Discussion A1)

**Priority**: P1 (S1 critical path)
**Effort**: 10 min
**What**: Add "CC v2.1.117 Re-Run Protocol" section documenting the comparison methodology for post-upgrade shadow eval. Includes per-test attribution logic (FAIL→PASS = CC bug, FAIL→FAIL = model behavior) and aggregate decision thresholds.
**Why now**: Shadow eval 0.683 NO-GO was measured under broken CC conditions (200K context instead of 1M). The re-run needs a documented protocol to ensure clean attribution.

### 2. `eval/model_migration_runbook.md` — OTEL Effort Diagnostic (Discussion A4)

**Priority**: P3
**Effort**: 5 min
**What**: Append "Next Diagnostic Step: OTEL Effort Correlation" to the failure analysis section. Conditional on re-run results — only pursue if failures persist after v2.1.117 upgrade.
**Why**: v2.1.117 adds `effort` attribute to OTEL events. If re-run failures persist, effort-per-test correlation narrows the issue to adaptive thinking subsystem specifically.

### 3. `agentic-ai-researcher` — No Definition Changes Needed

The researcher's sweep coverage correctly identified:
- CC v2.1.117 as a major release (within existing "Claude Code" domain)
- ADK Java 1.0 (within existing "Agent Development Kit" domain)
- Gemini CLI preview (within existing "Gemini Agents" domain)

No routing table, description, or capability updates needed. Deep Research continues to be tracked under "Gemini Agents / API" as noted in the morning cycle.

### 4. `meta-agent-factory` — No Changes Needed

No new skill generation patterns emerged. Factory description and trigger logic remain well-calibrated at 0.95 uniform trigger rate.

### 5. `daily_shadow_eval.sh` — Already Updated (Prefix Match)

Morning factory session (commit 6e70617) already implemented the prefix match fix. No further changes to this script from the afternoon cycle.

### 6. Steward/Factory Scripts — No Changes Needed

All daily scripts current with `--max-budget-usd 10.00`, cost ceilings, fleet version >=2.1.116. The CC v2.1.117 upgrade is a human action (Jonas), not a script change. Post-upgrade verification is documented in the upgrade checklist (roadmap-updates A6).

---

## Deferred Skill-Adjacent Items

### D1: Declarative mcpServers Frontmatter Migration

**Re-entry**: 1-2 CC releases (~1 week post v2.1.117)
**What it would be**: Audit which agents use MCP servers, move declarations from global `.mcp.json` to per-agent frontmatter `mcpServers` field.
**Why deferred**: v2.1.117 just shipped. The feature hasn't been validated in production. Adopting on 16-agent fleet risks undocumented edge cases. MCP usage audit proceeds as part of format comparison matrix (A5) instead.
**S3 impact**: When adopted, makes agents more self-contained — advancing S3 portability. ADK Java's App/Plugin pattern validates this direction.

### D2: Forked Subagent Isolation Experiment

**Re-entry**: Phase 5 experiment backlog
**What it would be**: Test `CLAUDE_CODE_FORK_SUBAGENT=1` on factory-steward sessions to measure context pollution reduction.
**Why deferred**: n=1 experiment with no matched comparison. `CLAUDE_CODE_FORK_SUBAGENT=1` untested in headless (`claude -p`) mode. Methodology gaps need addressing before spending factory cycles.
**S2 impact**: When run properly, provides original data on multi-agent isolation patterns within our pipeline.

---

## Researcher Agent — Monitoring Priorities Update

No definition changes, but the next directive should note:
- **CC v2.1.117 follow-up**: Monitor for v2.1.118+ (bug fixes on new features, especially `mcpServers` and native bfs/ugrep)
- **ADK Java 1.0**: Monitor for adoption patterns and community feedback on event compaction
- **Gemini CLI preview**: Track v0.39.0 progression toward stable (affects S3 timeline)
- **Shadow eval re-run results**: When Jonas upgrades and re-run fires, the results should be headline material in the next sweep
