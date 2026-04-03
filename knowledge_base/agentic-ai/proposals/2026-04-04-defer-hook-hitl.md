# Skill Proposal: defer-hook-hitl-integration
**Date**: 2026-04-04
**Triggered by**: Claude Code v2.1.89 added "defer" permission decision for PreToolUse hooks — enables pause/resume for headless sessions
**Priority**: P2 (medium)
**Target Phase**: Phase 5 (HITL Tiers, Task 5.5)

## Rationale

Our Phase 5 task 5.5 specifies implementing HITL tier classifications for destructive tool calls. The current plan envisions building custom pause/resume infrastructure. Claude Code's new `defer` hook eliminates the need for custom infrastructure — it provides exactly the primitive we need: pause at a tool call, allow external review, resume with `-p --resume`.

This maps cleanly to our planned tiers:
- **Tier 1 (auto-approve)**: No defer — standard tool execution
- **Tier 2 (async review)**: Defer + A2A-style task lifecycle — agent pauses, another agent or async process reviews, resumes later
- **Tier 3 (synchronous human approval)**: Defer + human review in terminal — agent pauses, human evaluates, resumes or rejects

## Proposed Specification

- **Name**: defer-hook-hitl-integration
- **Type**: Implementation pattern for Phase 5 task 5.5 (not a new Skill)
- **Description**: Use Claude Code's native defer hook as the implementation mechanism for HITL tiers instead of building custom pause/resume
- **Key Capabilities**:
  - PreToolUse hook returns `{"decision": "defer"}` for Tier 2/3 tool calls
  - Deferred sessions can be resumed with `claude -p --resume <session>` after review
  - Review can be human (Tier 3) or automated (Tier 2 — e.g., validator agent reviews the proposed write)
  - Integrates with our existing `post-tool-use.sh` hook framework
- **Tools Required**: None new — uses existing Claude Code hook system

## Implementation Notes

- Requires Claude Code v2.1.89+ (already available)
- The defer mechanism works in headless (`-p`) mode — perfect for our autonomous pipeline
- Cross-pollination with A2A task lifecycle: defer for synchronous gates, A2A status updates for async flows
- Risk: if Anthropic changes the defer API, our HITL gates break. Mitigate by pinning Claude Code version.

## Estimated Impact

- Eliminates ~1 week of custom pause/resume development in Phase 5
- Leverages battle-tested Claude Code infrastructure instead of building our own
- Natural fit for both human and agent review patterns
- Reduces Phase 5 task 5.5 scope and risk
