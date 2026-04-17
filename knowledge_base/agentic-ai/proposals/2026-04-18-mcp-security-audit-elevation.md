# Skill Proposal: Elevate MCP Security Audit to Phase 5 Planning Period

**Date**: 2026-04-18
**Triggered by**: MCP ecosystem crossed 10,000+ active public servers (doubled from ~5,800 in early April). Analysis §1.6; Discussion 2.3 (ADOPT P2).
**Priority**: **P2** (medium — security posture improvement, not blocking)
**Target Phase**: Phase 4 → Phase 5 transition

## Rationale

The `mcp-sec-audit` standalone evaluation has been deferred since 2026-04-07 (ROADMAP §4.4, P2). The MCP ecosystem doubling in ~2 weeks changes the urgency calculus:
- More servers = larger attack surface for tool poisoning (OWASP MCP03)
- Phase 5's multi-agent topology will likely need to discover and validate MCP servers dynamically
- Our current `mcp_config_validator.sh` does static pinning — adequate for Phase 4's known-server set, insufficient for dynamic discovery

**Discussion consensus (2026-04-18 Round 2)**:
- ADOPT as "complete during Phase 5 planning period" (NOT as a gate)
- Distinction: a gate blocks Phase 5 start; a planning-period task runs in parallel with Phase 5 design work
- Our pipeline currently uses a fixed set of known tools — the 10K ecosystem growth is a general threat, not an immediate pipeline threat

## Proposed Specification

- **Name**: `mcp-security-audit-elevation`
- **Type**: Task Priority Change (no new Skill)
- **Description**: Move `mcp-sec-audit` from "deferred P2" to "Phase 5 planning period"

**Change in ROADMAP §4.4**:
- Current: `mcp-sec-audit standalone evaluation — P2 (deferred from 2026-04-07 discussion)`
- Proposed: `mcp-sec-audit standalone evaluation — P2 (complete during Phase 5 planning period, parallel with design sprint)`

**Evaluation scope** (unchanged):
- Time-boxed 2-4 hour evaluation
- Confirm installability
- Assess marginal value over existing `mcp_config_validator.sh`
- Verify static-only analysis mode
- Prerequisite for CI/CD gate integration

## Implementation Notes

- No code changes now
- The evaluation itself is the same 2-4 hour task — only the scheduling changes
- If the evaluation shows high marginal value, the output feeds into Phase 5's dynamic MCP server validation design

## Estimated Impact

- Ensures MCP security posture is current before Phase 5 introduces dynamic server discovery
- Prevents the evaluation from being deferred indefinitely (it's been deferred for 11 days already)
- Explicitly non-blocking: Phase 5 design can start without this completing
