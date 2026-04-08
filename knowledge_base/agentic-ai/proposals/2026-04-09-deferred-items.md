# Deferred Items — 2026-04-09

**Source**: Discussion 2026-04-09 (Round 1-3 DEFER verdicts)
**Author**: agentic-ai-researcher (Mode 2c)

---

## DEFER #1: Managed Agents SKILL.md Adapter (`skill_to_managed_agent.py`)

**Original proposal**: Write a Python adapter that converts SKILL.md into a Managed Agents resource definition for the `ant` CLI.

**Why deferred**: Managed Agents API is public beta — surface will change. This is Phase 7 work during Phase 4. The 4-6 hours of implementation competes with Phase 4 remaining tasks (role switching validation, 50-Skill stress test, cost analysis). Building against an unstable API means maintaining through breaking changes.

**Accepted alternative**: 30-minute design mapping document (SKILL.md fields to Managed Agents concepts) — captures the insight without throwaway code.

**Revisit when**: Phase 7 start, after Managed Agents reaches GA.

---

## DEFER #2: Cross-Platform SKILL.md Format Comparison Document

**Original proposal**: 1-2 hour research task documenting field-level mapping between `.claude/skills/` and `.gemini/skills/` formats.

**Why deferred**: Gemini CLI v0.38.0 is a *preview* release — the `.gemini/skills/` format is likely still evolving. Writing a comparison against a preview release means it'll be outdated within weeks. This is Phase 7 work (cross-platform transpiler).

**Accepted alternative**: One-line ROADMAP note in Phase 7: "Cross-platform SKILL.md format comparison required before transpiler work."

**Revisit when**: Phase 7 start, against then-current stable Gemini CLI version.

---

## DEFER #3: `estimated_tokens` Field in Performance JSONs

**Original proposal**: Add `estimated_tokens` field to performance JSON schema by parsing Claude Code's session summary or estimating from duration.

**Why deferred**: Claude Code's session output doesn't reliably expose token counts in a parseable format. Attempting to parse it is fragile and would break with CLI updates. `duration_seconds` is an adequate cost proxy for the 3-day monitoring window.

**Accepted alternative**: Adopt `effort_level` field only (zero-risk, one-line addition). Use duration as proxy.

**Revisit when**: Claude Code adds machine-readable session summary or token usage output.

---

*Generated 2026-04-09 by agentic-ai-researcher (Mode 2c: L4 Strategic Planning)*
