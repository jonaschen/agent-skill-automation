# Skill Proposal: Gemini CLI Agent Format vs. SKILL.md Comparative Analysis
**Date**: 2026-04-18
**Triggered by**: Night discussion 2026-04-18 (A8) + night analysis §2 S3 gap: "No concrete analysis of Gemini CLI's agent definition format vs. SKILL.md — the single most important S3 research task and hasn't been attempted yet"
**Priority**: P2 (medium) — strategic research, not operational
**Target Phase**: Phase 5 planning input + S3 strategic priority

## Rationale

Strategic priority S3 (Platform Generalization) asks: "What is the minimal portable agent definition format that both Claude Code and Gemini CLI can consume?"

After 17 days of tracking Gemini CLI releases (v0.36.0 through v0.38.2), we have extensive knowledge of the platform's capabilities but zero analysis of its agent definition mechanism. The pre-I/O freeze (Gemini CLI stable at v0.38.2, no changes expected until May 19-20) creates an ideal research window — analyze the stable format before I/O potentially changes it.

Key unknown: **Does Gemini CLI even have a declarative agent definition file equivalent to SKILL.md?** If yes, this is a comparison task. If no, S3 requires *inventing* a portable format, not adapting an existing one. Either answer is strategically important.

## Proposed Specification

- **Name**: gemini-cli-format-comparison
- **Type**: Research deliverable (not a skill/agent)
- **Description**: Comparative analysis of agent definition formats across Claude Code and Gemini CLI
- **Deliverable**: `knowledge_base/agentic-ai/experiments/skill-format-comparison.md`
- **Time-box**: 3 hours (per Engineer recommendation — answer the structural question, not exhaustive spec)

## Research Questions

| # | Question | Why It Matters |
|---|----------|---------------|
| 1 | Does Gemini CLI have a declarative agent definition file? | Determines if S3 is "adapt" or "invent" |
| 2 | What is `GEMINI.md`'s role? | Equivalent to CLAUDE.md? Serves as agent config? |
| 3 | How does Gemini CLI route to agents/skills? | Description-based (like SKILL.md) or rule-based? |
| 4 | What tool permission model does Gemini CLI use? | Determines portability of our mutually exclusive permission design |
| 5 | Does A2A Agent Card provide enough metadata for cross-platform identity? | Agent Card as bridge layer evaluation |

## Research Method

1. **Read Gemini CLI documentation** — search for agent/skill definition format, GEMINI.md structure, tool permissions
2. **Analyze v0.38.x features** — context-aware approvals, passive skill extraction/lifecycle, memory inbox (these suggest an implicit skill format)
3. **Compare format dimensions**:

   | Dimension | SKILL.md (Claude Code) | Gemini CLI Equivalent |
   |-----------|----------------------|----------------------|
   | File format | YAML frontmatter + markdown body | ? |
   | Routing mechanism | `description` field → model routing | ? |
   | Tool permissions | `tools` list in frontmatter | ? |
   | Model specification | `model` field | ? |
   | Instructions | Markdown body | ? |
   | Trigger patterns | Implicit in description | ? |

4. **Assess transpiler feasibility**: Could `SKILL.md → Gemini format` be automated? What information is lost?
5. **Evaluate A2A Agent Card as bridge**: Map SKILL.md fields to Agent Card schema

## Implementation Notes

- This is **research only** — no code, no agent changes
- Should be executed by the researcher agent during a sweep cycle (or dedicated session)
- The pre-I/O stable window (now through ~May 2) is the ideal timing
- If Gemini CLI lacks a comparable format, the finding shapes S3 from "comparison" to "cross-platform format design" — equally valuable
- Gemini CLI access verification is a prerequisite for any future experiments (D3 from night discussion)

## Estimated Impact

- **S3 strategic direction**: Determines whether S3 is a format adaptation problem or a format invention problem
- **Phase 5 architecture**: If formats are comparable, Phase 5 can design for dual-platform execution
- **I/O preparation**: Baseline understanding before Google potentially changes the format at I/O
