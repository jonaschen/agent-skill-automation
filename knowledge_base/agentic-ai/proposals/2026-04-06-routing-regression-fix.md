# Skill Proposal: Routing Regression Fix — Description Deconfliction
**Date**: 2026-04-06
**Triggered by**: Active routing regression T=0.895→0.658; analysis §3.4; discussion ADOPT #1
**Priority**: CRITICAL
**Target Phase**: 3-4 (blocks all eval-dependent work)

## Rationale

Adding 6 agents (stewards, factory-steward, reviewer) dropped `meta-agent-factory` trigger rate from T=0.895 to T=0.658. All positive CREATE prompts now route to competing agents. The root cause (L7 lesson): agent fleet expansion created description overlap — steward agents contain "implements", "generates", "creates" vocabulary that competes with meta-agent-factory's routing triggers.

The industry stabilization window (no new releases to chase) provides the ideal opportunity to focus on this fix. Anthropic's harness blog reinforces the solution: clear role boundaries via explicit contracts prevent routing competition.

## Proposed Specification
- **Name**: routing-regression-fix (description deconfliction across all agents)
- **Type**: Pipeline fix (CRITICAL)
- **Description**: Two-pronged approach: deconflict competing vocabulary in steward agents + reinforce meta-agent-factory routing anchor
- **Key Capabilities**:
  - **Prong 1 — Deconfliction**: Audit all 11 agent descriptions for vocabulary overlap with `meta-agent-factory`. Replace competing verbs:
    - "implements ADOPT items" → "acts on ADOPT items"
    - "generates sweep reports" → "produces sweep reports"
    - "creates steering notes" → "writes steering notes"
    - Similar changes across all steward, reviewer, and researcher agent descriptions
  - **Prong 2 — Routing anchor**: Strengthen `meta-agent-factory`'s description with an explicit routing rule:
    > "ROUTING RULE: Any request whose primary intent is to CREATE, BUILD, DEFINE, or ADD a new agent, Skill, persona, expert, or role MUST route here — even when an existing domain agent covers that topic."
  - **Validation**: Re-run full eval (T=36, V=18) to confirm:
    - meta-agent-factory trigger rate recovers to ≥ 0.895
    - Steward agent routing is not broken by vocabulary changes
    - Validation set still passes overfit threshold (V ≥ 0.85)
- **Tools Required**: Edit (agent descriptions), Bash (eval runner)

## Implementation Notes
- This is the #1 priority — block other P1/P2 items until resolved
- Low risk: changing steward descriptions from "implements" to "acts on" doesn't change their behavior — only routing semantics
- The routing anchor text already partially exists in the current description (added in G8 Iter 2) — this strengthens it further
- After fix, add to L7 lesson: "vocabulary deconfliction is a mandatory step when adding agents to the fleet"
- Files to change: all `.claude/agents/*.md` description fields

## Estimated Impact
- Recovers meta-agent-factory trigger rate from T=0.658 to ≥0.895
- Unblocks all eval-dependent Phase 4 work (stress test, regression test, cost analysis)
- Establishes vocabulary deconfliction as a standard practice for fleet expansion
- Validates that description-level fixes are sufficient (vs. needing structural routing changes)
