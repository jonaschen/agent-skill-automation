# Skill Update Suggestions — 2026-04-22

**Source**: Analysis 2026-04-22 + Discussion 2026-04-22 (6 ADOPTs, 3 REJECTs)
**Directive compliance**: Single-cycle volume, shadow eval is factory-only

---

## No New Skill Proposals

Today's findings (Deep Research MCP integration, agent-as-API pricing divergence, post-freeze quiet, Opus 4.7 ecosystem pressure) do not warrant new skills. They produce **design inputs** for Phase 5/7 and **infrastructure improvements** for the existing pipeline.

The factory queue has 13 items (7 carried from Apr 21 + 6 new ADOPTs). No skill creation, modification, or deprecation is needed.

---

## Existing Skill Updates

### 1. `agentic-ai-researcher` — No Changes Needed

The researcher's sweep coverage correctly identified Deep Research as a new Google product category. The existing research domain table in `agentic-ai-researcher.md` covers "Gemini Agents / API" which subsumes Deep Research. No routing table or description updates needed.

The directive's guidance on ecosystem breakage monitoring (Proposal 3.3, REJECTED) is correct — the researcher already naturally correlates third-party issue reports with our findings. No formalization needed.

### 2. `meta-agent-factory` — No Changes Needed

No new skill generation patterns emerged. The factory description and trigger logic remain well-calibrated at 0.95 uniform trigger rate.

### 3. `daily_shadow_eval.sh` — Prefix Match Update (Discussion A3)

**Priority**: P2 (S1 critical path)
**Effort**: 15 min
**What**: Change `PENDING_MIGRATION_MODEL` lookup in `daily_shadow_eval.sh` from exact string match to prefix match (`claude-opus-4-7*`). This ensures patched model IDs (e.g., `claude-opus-4-7-20260425`) are automatically detected without manual variable update.
**What NOT to do**: No API model enumeration (Engineer correctly rejected this — adds API dependency to save 10 seconds of human action).
**Why now**: Per-test logging is in place (commit 79c98c7). The failure analysis template is ready. The trigger mechanism is the remaining gap on the S1 critical path.

### 4. Steward/Factory Scripts — No Changes Needed

All daily scripts are current with `--max-budget-usd 10.00`, cost ceilings, fleet version >=2.1.116. No operational updates from today's findings.

---

## Researcher Agent Definition — Monitoring Priorities Update

No definition changes, but the next directive should note:
- **Deep Research** is now a monitored Google product (via existing "Gemini Agents / API" domain)
- **Interactions API** is a new Google API surface to track for async agent dispatch patterns
- **MCP convergence** moves from "active research" to "track convergence" for tool portability (S3 narrowing)
