# Skill Proposal: Capybara/Mythos Model Contingency Tracking
**Date**: 2026-04-05
**Triggered by**: Anthropic government briefing on Mythos cyber capabilities; Opus 4.7/Sonnet 4.8 config references; threat assessment upgrade P2->P1
**Priority**: P1 (high)
**Target Phase**: 3-4

## Rationale

Capybara (Mythos) sits ABOVE Opus 4.6 in Anthropic's model hierarchy. If it becomes the default for Claude Code or Agent SDK:
1. Our eval baselines (T=0.895, V=0.900) are invalidated
2. SKILL.md descriptions optimized for Opus 4.6 may route differently
3. The T=0.658 routing regression could worsen or resolve unpredictably
4. Defender-first rollout means initial access may be restricted

Additionally, Opus 4.7 and Sonnet 4.8 references in internal configs suggest incremental model updates even before Capybara ships.

## Proposed Specification
- **Name**: capybara-contingency (operational readiness, not a Skill)
- **Type**: Risk mitigation + monitoring
- **Description**: Proactive tracking and response plan for new Anthropic model releases
- **Key Capabilities**:
  - Continuous monitoring for Capybara/Mythos beta access announcements
  - Model migration runbook (see companion proposal 2026-04-05-model-migration-runbook.md)
  - Risk table entry in ROADMAP.md
  - Researcher agent adds Capybara tracking to nightly sweep focus
- **Tools Required**: WebSearch (researcher sweep)

## Implementation Notes
- The runbook (separate proposal) covers the mechanical response
- This proposal covers the MONITORING aspect — ensuring we detect the model release quickly
- Add "Capybara/Mythos broader access" to agentic-ai-researcher's priority watch list
- When detected: immediately run baseline eval (T+V) on new model before any description changes

## Estimated Impact
- Reduces response time from "scramble when noticed" to "execute runbook within 24 hours"
- Protects our deployment gate integrity during model transitions
- Low ongoing cost (one search query per sweep cycle)
