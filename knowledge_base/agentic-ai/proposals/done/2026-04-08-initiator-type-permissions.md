# Skill Proposal: Initiator-Type Permission Context
**Date**: 2026-04-08
**Triggered by**: AWS MCP IAM context keys (`aws:ViaAWSMCPService`, `aws:CalledViaAWSMCP`) — first production-grade agent/human action differentiation
**Priority**: P1 (high)
**Target Phase**: Phase 4 (Security hardening)

## Rationale

AWS shipped IAM context keys that differentiate agent actions from human actions at the policy level. Our `post-tool-use.sh` currently treats all tool calls identically regardless of whether a human or an automated cron job initiated them. As our pipeline becomes more autonomous (Phase 4 closed loop), automated agents operating in unattended cron contexts have a different threat surface than human-interactive sessions. The CVE-2026-35020 exposure underscores this: cron environments are more vulnerable to env var injection.

## Proposed Specification
- **Name**: initiator-type-permissions
- **Type**: Hook enhancement (phased)
- **Description**: Add `CLAUDE_INITIATOR_TYPE` env var to distinguish action origins; enforce differentiated policies per initiator type
- **Key Capabilities**:
  - Phase 1 (this week): Export `CLAUDE_INITIATOR_TYPE=cron-automated` in all daily scripts; read and log in `post-tool-use.sh` — visibility only, no enforcement
  - Phase 2 (next week): Define restricted operation set for `cron-automated` (block `push --force`, `reset --hard`, `branch -D`); enforce in `post-tool-use.sh`
  - Phase 3 (Phase 5): Add `orchestrator-delegated` tier when subagent delegation exists
- **Tools Required**: Bash (script modifications)

## Implementation Notes

The discussion agreed to phase this: plumbing first (env var + logging), enforcement second, orchestrator tier deferred to Phase 5 (no subagent delegation exists yet). This avoids speculative complexity while getting the hardest part done now.

Three initiator types:
- `cron-automated` — from daily scripts (restricted: no destructive git ops)
- `human-interactive` — from live Claude Code sessions (current behavior, unrestricted)
- `orchestrator-delegated` — from subagent delegation (Phase 5, intermediate restrictions)

Estimated effort: 1 hour (Phase 1) + 1 hour (Phase 2).

## Estimated Impact

Enables differentiated security policies based on execution context. Directly mirrors the AWS IAM pattern now considered an enterprise table-stakes requirement. Foundation for Phase 7 AaaS permission model.
