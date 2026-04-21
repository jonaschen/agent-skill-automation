# Skill Proposal: token-sanitizer
**Date**: 2026-04-22
**Triggered by**: ChatInject (arXiv:2509.22830) vulnerability report
**Priority**: P0 (critical security)
**Target Phase**: Phase 4/5 (Safety & Orchestration)

## Rationale
The `ChatInject` vulnerability allows for role-escalation (system/user privilege escalation) by injecting chat template control tokens (e.g., `<|system|>`, `[INST]`) into tool outputs. This is particularly dangerous for `web_fetch` or `bash` tool results.

## Proposed Specification
- **Name**: `token-sanitizer`
- **Type**: Skill (Pre-processor / Post-Tool-Use)
- **Description**: Sanitizes all tool output strings by identifying and stripping known chat template role tokens and control characters.
- **Key Capabilities**:
    - Multi-provider token list (Anthropic, Google, OpenAI, Meta, Mistral).
    - RegEx-based stripping of role markers.
    - Zero-trust default: treat all tool output as untrusted.

## Implementation Notes
This should be implemented as a mandatory step in the `PostToolUse` hook (or equivalent) in our pipeline. It must intercept the raw tool response before it is appended to the agent's context.

## Estimated Impact
Eliminates a critical class of privilege escalation attacks in autonomous agentic loops.
