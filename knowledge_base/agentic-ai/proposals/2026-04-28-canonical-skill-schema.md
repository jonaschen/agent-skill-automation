# Skill Proposal: Canonical Skill Schema for S3 Transpiler Foundation

**Date**: 2026-04-28
**Triggered by**: Finding 6 (analysis 2026-04-28) + dispatch-primitive comparison verdict — partially portable / transpiler feasible. 5/12 axes fully portable (parameter schema, fresh-context isolation, recursion ban, allowlist concept, basic return contract); 5/12 not portable but compile-time-resolvable. Discussion 2026-04-28 Round 1 Adopt #3 (P2), with explicit DEFER on transpiler implementations (D1).
**Priority**: **P2** (commit the architectural surface; defer implementation until Gemini CLI install)
**Target Phase**: Phase 5 / S3 (cross-platform agent portability)

## Rationale

Today's dispatch-primitive comparison delivered the day-7 work-around for S3: a documentation-based verdict that the Anthropic ↔ Google dispatch primitives **converge on the semantics that matter most** and **diverge on details that a transpiler can absorb at compile time**.

The architectural surface is now mapped well enough to begin a stub. **But empirical validation requires Gemini CLI install** (still blocked, day 7+). The prudent commit is the **canonical schema only** — the JSON Schema describing the portable subset of agent definitions. This is testable today against our existing 23 Claude agents (round-trip test). Transpiler implementations (`transpile_to_claude.py`, `transpile_to_gemini.py`) wait for Gemini CLI install.

Engineer's reasoning (discussion Round 1): writing transpiler code that targets a vendor format we cannot test against means maintaining it for an unknown number of weeks, then likely rewriting on first install when assumptions about Gemini's frontmatter parsing turn out wrong. Schema-only commitment is reversible.

## Proposed Specification

- **Name**: Canonical Skill Schema
- **Type**: JSON Schema artifact + round-trip test against existing Claude agents
- **Owner**: factory-steward
- **Location**: `tools/dispatch-transpiler/canonical-skill-schema.json`

**Schema fields** (the portable subset, derived from dispatch-primitive comparison Section 4):

```jsonc
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CanonicalSkill",
  "type": "object",
  "required": ["name", "description", "system_prompt"],
  "properties": {
    "name": {
      "type": "string",
      "pattern": "^[a-z][a-z0-9-]*$",
      "description": "Subagent identifier; must be valid as both Claude subagent_type and Gemini tool name suffix"
    },
    "description": {
      "type": "string",
      "maxLength": 1024,
      "description": "Trigger description; portable to both vendors as the discovery channel"
    },
    "system_prompt": {
      "type": "string",
      "description": "System prompt body (portable; both vendors carry verbatim)"
    },
    "tools": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Tool allowlist. Wildcards permitted in canonical form; transpiler expands for Claude (no wildcard support)."
    },
    "mcpServers": {
      "type": "object",
      "description": "MCP server config; both vendors converge on MCP transport"
    },
    "model_alias": {
      "type": "string",
      "enum": ["flagship", "balanced", "fast"],
      "description": "Vendor-neutral model tier; transpiler resolves to opus/sonnet/haiku (Claude) or pro/flash (Gemini)"
    }
  },
  "additionalProperties": false
}
```

**Excluded fields (Claude-only, transpiler will warn or strip on Gemini emit)**:
- `maxTurns`, `effort`, `permissionMode`, `background`, `disallowedTools`, `memory`

**Excluded fields (Gemini-only, transpiler will warn or strip on Claude emit)**:
- Wildcard tool grants (Gemini-only feature)

**Round-trip test** (`tools/dispatch-transpiler/test_round_trip.sh`):
- For each of our 23 Claude agents in `.claude/agents/`:
  1. Parse Claude format → canonical (lossy on Claude-only fields, log warnings)
  2. Validate canonical against schema
  3. Re-emit Claude format
  4. Diff against original (only Claude-only fields should differ; rest must round-trip cleanly)
- Pass criterion: ≥20/23 agents round-trip without semantic loss

**Tools Required**: Read, Write (for schema + test script)

## Implementation Notes

**Dependencies**:
- Dispatch-primitive comparison (`experiments/dispatch-primitive-comparison.md`, delivered today) — provides the field-by-field portability map
- Skill format comparison (`experiments/skill-format-comparison.md`, 2026-04-18) — supplements with frontmatter mappings
- A2A Agent Card v1.0.0 — referenced for `name` + `description` field semantics (already integrated in `fleet_manifest.json`)

**Risk**:
- Open question on Gemini's `invoke_subagent` exposure (dispatch-comparison Section 8) — does Gemini expose subagent tools as callable tool names, or is it purely an internal dispatcher? If "internal only", any future `transpile_to_gemini.py` design changes — but this risk is borne by the transpiler implementation (deferred), not the schema. Schema captures the portable contract, not the emit strategy.
- Schema may need extension when I/O lands ADK v2.0 / Gemini CLI v0.40 stable. Mitigation: schema is a deliberately minimal portable subset; extensions live in vendor-specific overlays in the deferred transpiler.
- 23 agents may include some that are deeply Claude-specific (e.g., changeling-router uses identity switching). Mitigation: round-trip test reports lossy fields; ≥20/23 threshold tolerates legitimate Claude-only specializations.

**Do NOT**:
- Implement `transpile_to_claude.py` or `transpile_to_gemini.py` (DEFERRED per D1 — wait for Gemini CLI install)
- Add Gemini-only or Claude-only fields to the canonical schema (defeats the purpose; those go in vendor overlays)
- Treat the schema as final — it's a v0 commit; expect v1 after empirical validation post-install

## Estimated Impact

- **S3 architectural**: Locks in the most architecturally consequential S3 progress in the project's history. The schema becomes the contract that future transpilers, A2A Agent Cards, and cross-platform fleet manifests reference.
- **Reversibility**: Schema-only commitment is reversible (we can edit the JSON Schema). Transpiler code is harder to roll back. This is the right trade.
- **Cost**: ~1-2 hours factory-steward time (schema definition + round-trip test).
- **Unblocks**: When Gemini CLI install completes, transpiler implementation has a concrete target. No re-architecting needed.
