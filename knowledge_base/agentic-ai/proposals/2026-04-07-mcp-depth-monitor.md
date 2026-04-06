# Skill Proposal: MCP Tool-Call Depth Monitor
**Date**: 2026-04-07
**Triggered by**: Adversa AI demonstrates 658x MCP cost amplification with <3% detection rate (sweep 2026-04-07)
**Priority**: P0 (critical)
**Target Phase**: 4 (Security Hardening)
**Status**: ADOPT (discussion consensus — Round 1, Proposal 1.1)

## Rationale

A malicious MCP server can steer agents into prolonged tool-calling chains, inflating per-query costs by 658x with <3% detection rate. Our existing `cmd_chain_monitor.sh` monitors shell command-chain length but NOT MCP tool-call depth — these are orthogonal attack surfaces.

Applied to our nightly fleet (8 agent runs, ~$5-15 each), a compromised MCP server could turn a $40-120/night bill into $26,000-$79,000. Nightly steward runs are automated and unattended, making this a high-impact financial DoS vector.

## Proposed Implementation

**Not a new Skill/Agent** — this is a hook enhancement to the existing security infrastructure.

- **Target file**: `.claude/hooks/post-tool-use.sh`
- **Mechanism**: Pattern-match `mcp__*` tool name prefix to identify MCP tool calls. Increment a per-session counter stored at `/tmp/mcp_depth_${SESSION_ID}`.
- **Alert threshold**: >15 MCP calls per agent step (widened from analysis's 10 per Engineer feedback — reduce false positives during rollout)
- **Block threshold**: >25 MCP calls per agent step
- **On block**: Emit structured JSON alert to `logs/security/mcp_depth_alert.jsonl` with agent name, MCP server, tool-call count, and estimated cost.

## Implementation Notes

- Follows the same temp-file-per-session pattern as `cmd_chain_monitor.sh` — proven pattern.
- ~30 lines of shell code. Low implementation cost.
- Alert-only at first threshold provides observability without false-positive risk.
- New directory `logs/security/` needed for structured security alerts.
- Must verify that Claude Code's `post-tool-use.sh` hook receives MCP tool names with the `mcp__<server>__<tool>` prefix — this naming convention is the detection mechanism.

## Estimated Impact

- **Immediate**: Blocks the most financially dangerous MCP attack vector documented to date.
- **Operational**: Provides visibility into MCP tool-call patterns across the nightly fleet — useful for baseline analysis even without attacks.
- **Prerequisite for**: Future CI/CD gate MCP call pattern rejection (deferred Proposal 1.3).
