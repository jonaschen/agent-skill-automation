# Skill Proposal: Prototype Collision Audit
**Date**: 2026-04-10
**Triggered by**: Claude Code v2.1.97 fixes for JS prototype collision permission bypasses — `toString`, `valueOf`, `hasOwnProperty`, `constructor`, `__proto__` keys in settings.json were silently ignored
**Priority**: P0 (critical — zero-cost verification)
**Target Phase**: Phase 4 (Security hardening)

## Rationale
Pre-v2.1.97, if any permission rule key in `settings.json` matched a JavaScript prototype property name, the rule was silently discarded. This means an agent config using such keys would have had no permission enforcement. Our fleet likely doesn't use these keys, but confirmation is a 30-second grep with immediate security assurance.

## Proposed Specification
- **Name**: prototype-collision-audit (one-time security verification, not a recurring Skill)
- **Type**: Security verification task
- **Description**: Grep `.claude/` configs for JS prototype property names
- **Action**:
  ```bash
  grep -rn 'toString\|valueOf\|hasOwnProperty\|constructor\|__proto__' .claude/settings.json .claude/agents/*.md
  ```
- **Expected outcome**: No matches (clean) → log result and close
- **If matches found**: Escalate immediately — affected permission rules were not enforced pre-v2.1.97

## Implementation Notes
- One-time task, not an ongoing Skill
- Factory-steward should execute this in next session
- Result logged to daily performance JSON or commit message

## Estimated Impact
- Zero cost, immediate security assurance
- Closes the audit gap from the v2.1.97 changelog
