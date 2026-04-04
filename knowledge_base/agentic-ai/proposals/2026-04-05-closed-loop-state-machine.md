# Skill Proposal: Closed-Loop State Machine Refactor
**Date**: 2026-04-05
**Triggered by**: ADK v2.0 graph-based workflow runtime analysis; discussion ADOPT #5
**Priority**: P2 (medium)
**Target Phase**: 4 (Closed Loop)

## Rationale

Our `scripts/closed_loop.sh` is a linear pipeline (factory -> validate -> optimize -> deploy). This wastes API cost when a Skill already passes at >= 0.95 (optimization is unnecessary) and lacks an explicit security scan node before deployment.

The ADK v2.0 alpha introduced a graph-based workflow runtime, but per Engineer consensus, we should NOT adopt their runtime. Instead, refactor the existing script into a proper state machine — same benefits, zero new dependencies.

## Proposed Specification
- **Name**: closed-loop-state-machine (refactor of existing script)
- **Type**: Pipeline improvement
- **Description**: State machine with conditional skip, parallel security scan, and retry limits
- **Key Capabilities**:
  - State transitions:
    ```
    START -> GENERATE -> VALIDATE -+- pass(>=0.95) -> SECURITY_SCAN -> DEPLOY
                                   +- pass(>=0.90) -> SECURITY_SCAN -> DEPLOY
                                   +- conditional(>=0.75) -> OPTIMIZE -> VALIDATE (loop)
                                   +- fail(<0.75) -> REPORT_FAILURE
    ```
  - SECURITY_SCAN node runs MCP content validator + permission checker in parallel
  - Retry counter on OPTIMIZE -> VALIDATE loop (max 3 re-optimizations before failing)
  - Skip optimization entirely when trigger rate >= 0.95 (saves ~$5-10 per Skill)
- **Tools Required**: Bash

## Implementation Notes
- Rewrite `scripts/closed_loop.sh` as a bash case statement with explicit state variable
- The SECURITY_SCAN node integrates the P0 MCP content validator (proposal 2026-04-05-mcp-content-validator.md)
- Retry counter prevents infinite optimize->validate loops (current 50-iteration optimizer budget is per-optimization, not per-pipeline)
- This is a rewrite of an existing script, NOT a new system

## Estimated Impact
- Saves 15-30 minutes and $5-10 API cost per high-quality Skill (skip optimization)
- Adds security scanning as an explicit pipeline gate (currently only in pre-deploy hook)
- Retry limits prevent runaway pipeline costs on intractable Skills
