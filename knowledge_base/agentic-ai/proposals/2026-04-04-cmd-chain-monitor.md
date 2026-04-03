# Skill Proposal: command-chain-length-monitor
**Date**: 2026-04-04
**Triggered by**: Adversa disclosure — Claude Code deny rules bypassed with command chains exceeding 50 subcommands (MAX_SUBCOMMANDS_FOR_SECURITY_CHECK = 50)
**Priority**: P1 (high)
**Target Phase**: Phase 4 (Hooks enhancement)

## Rationale

Adversa disclosed that Claude Code deny rules can be bypassed by constructing Bash commands with >50 subcommands, causing the security check to skip. Our autonomous agents (especially in auto-accept mode during closed-loop execution) are vulnerable. Our `check-permissions.sh` validates SKILL.md tool lists but does not monitor runtime Bash command complexity. A malicious CLAUDE.md or project file could instruct an agent to build long command pipelines that bypass deny rules.

This is defense-in-depth. Even if Anthropic patches the bypass, monitoring command complexity is a sound security practice for autonomous agent pipelines.

## Proposed Specification

- **Name**: command-chain-length-monitor
- **Type**: Enhancement to existing `post-tool-use.sh` hook
- **Description**: Runtime monitor that counts subcommands in Bash tool calls and alerts when chains exceed a safe threshold (30)
- **Key Capabilities**:
  - Count pipe-separated (`|`), semicolon-separated (`;`), and `&&`/`||` chained subcommands
  - Alert (log + stderr warning) when chain length exceeds 30 subcommands
  - Hard block at 45 subcommands (below the 50-subcommand bypass threshold)
  - Log all flagged commands to `logs/security/cmd-chain-alerts.log`
- **Tools Required**: Bash (the hook itself runs as shell)

## Implementation Notes

- Modify `post-tool-use.sh` to add a command-chain counter function
- Use simple shell parsing: `echo "$cmd" | tr '|;&' '\n' | wc -l` (conservative count)
- Alert threshold: 30 (warning), Block threshold: 45 (hard stop)
- Do NOT block legitimate long pipelines (e.g., data processing) — the alert lets Jonas review
- Consider: should the block be configurable via env var? Probably yes: `CMD_CHAIN_BLOCK_THRESHOLD=45`

## Estimated Impact

- Closes the disclosed deny-rule bypass vector for our pipeline
- Minimal false-positive risk (legitimate commands rarely exceed 10 subcommands)
- Adds negligible latency to Bash tool calls (~1ms string parsing)
