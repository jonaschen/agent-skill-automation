# Skill Proposal: ZDR Policy Running Log (credential-isolation-design.md Extension)

**Date**: 2026-04-17
**Triggered by**: Opus 4.7 Computer Use is now ZDR-eligible (earlier versions were NOT); Programmatic Tool Calling has 30-day container retention and is NOT ZDR. No single document captures ZDR compliance per (tool × model) combination. Phase 7 regulatory compliance (Taiwan PDPA, Japan APPI) depends on this. Analysis §1.7; Discussion A8 (ADOPT P2 as running log).
**Priority**: **P2** (medium — prerequisite for Phase 7, but documentation maturity matters)
**Target Phase**: Phase 7 (AaaS commercialization, regulatory compliance)

## Rationale

ZDR (Zero Data Retention) eligibility varies by tool × model combination and changes over time. Current
situation:
- Computer Use on Opus 4.7: ZDR-eligible (screenshots client-side, 0 day retention) — NEW as of 4.7
- Programmatic Tool Calling on Opus 4.7: NOT ZDR, 30-day container retention
- Standard tool use: ZDR-eligible (existing)
- MCP tools: ZDR status depends on the specific MCP server (out-of-scope for matrix v1)

Without a running record of these decisions, Phase 7 regulatory compliance work (Taiwan PDPA, Japan
APPI, potentially EU GDPR for some tenants) will have to re-derive the matrix from scratch, possibly
after the product surface has shifted again.

**Discussion consensus (2026-04-17 Round 3)**:
- Agree on value; disagree on scope.
- Writing a **formal matrix today** when surface is still shifting (Computer Use only 3 weeks past ZDR-eligible, Mythos not public) risks stale documentation
- **Counter-adopted**: running log format. One paragraph per tool × ZDR decision, timestamped, as it lands. Phase 7 kickoff will assemble formal matrix from raw material.
- Cheaper to maintain, faster to write today

## Proposed Specification

- **Name**: ZDR Policy Running Log
- **Type**: Extension to existing `credential-isolation-design.md`
- **Location**: `knowledge_base/agentic-ai/evaluations/credential-isolation-design.md` (append section)
- **Owner**: factory-steward; updates by agentic-ai-researcher when new ZDR decisions are detected during sweeps

**Format**:

```markdown
## ZDR Policy Running Log

Append-only record of ZDR eligibility decisions per tool × model combination.
Formal matrix assembly deferred to Phase 7 kickoff.

### 2026-04-17 — Opus 4.7 Computer Use: ZDR-eligible
- **Tool**: `computer_20251124`
- **Model**: Opus 4.7 (first ZDR-eligible version)
- **Retention**: 0 days (screenshots client-side)
- **Regulatory**: PDPA OK, APPI OK, GDPR OK
- **Source**: Anthropic docs (link)
- **Note**: Earlier Opus 4.6 and below NOT ZDR for Computer Use

### 2026-04-17 — Programmatic Tool Calling: NOT ZDR
- **Tool**: `code_execution_20260120`
- **Model**: Opus 4.7, 4.6, 4.5, Sonnet 4.6, 4.5
- **Retention**: 30 days (container retention)
- **Regulatory**: Requires customer opt-in for PDPA/APPI tenants; GDPR consent flow required
- **Source**: Anthropic docs (link)

### 2026-04-17 — Standard Tool Use (Baseline): ZDR-eligible
- **Tool**: `tool_use` (standard function calling)
- **Model**: All current Claude models
- **Retention**: 0 days
- **Regulatory**: PDPA OK, APPI OK, GDPR OK
- **Source**: Existing (pre-April)
```

**Update Protocol**:
- agentic-ai-researcher appends new entries when ZDR status is detected in sweeps
- factory-steward appends when pilot decisions reveal new tool/model combinations
- Entries are append-only; corrections via a new dated entry ("Updating 2026-04-17 decision: ...")
- No retroactive edits (matches existing `eval/deprecated_models.json` discipline)

**Tools Required**: Edit (append to credential-isolation-design.md)

## Implementation Notes

**Dependencies**:
- `credential-isolation-design.md` exists (verify in Phase 7 design notes; may need creation if absent)
- Researcher sweep prompt includes ZDR status in tool-release findings (minor update to research template)

**Risk**:
- Stale entries: log entries may diverge from current Anthropic/Google policy if we don't refresh. Mitigation: quarterly sweep re-verification as part of normal sweep work.
- Scope creep: expanding to MCP tools (per-server ZDR dependent) is out-of-scope for v1. Add "MCP tool coverage" as separate future work if Phase 7 requires it.

**Do NOT**:
- Build formal matrix today (scope was explicitly reduced in Round 3)
- Include proprietary/confidential data in the log (public sources only)
- Retroactively edit entries (append-only)

## Estimated Impact

- **Phase 7 raw material**: formal matrix assembly in Phase 7 has 3-6 months of decisions to draw from
- **Regulatory readiness**: Taiwan PDPA and Japan APPI compliance can cite specific tool decisions
- **Cost**: minimal — one paragraph per ZDR-relevant announcement
- **Pre-I/O posture**: captures current-state snapshot before likely Google I/O 2026 ZDR announcements
- **Researcher integration**: systematizes ZDR status tracking as part of sweep workflow (not ad hoc)
