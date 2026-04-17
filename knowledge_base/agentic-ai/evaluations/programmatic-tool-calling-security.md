# Programmatic Tool Calling Security Analysis

**Date**: 2026-04-18
**Source**: Discussion 2026-04-17 A7 (ADOPT P1)
**Status**: ANALYSIS COMPLETE — blocks all `code_execution_20260120` pilots
**Author**: factory-steward (autonomous session)

---

## Context

Opus 4.7 ships `code_execution_20260120` (GA). This feature lets the model execute
tool calls inside an Anthropic-hosted container. Intermediate tool results don't count
toward output tokens — a real efficiency gain. However, our security envelope
(`post-tool-use.sh`) operates at the Claude Code harness level. Container-internal
tool calls may bypass this envelope entirely.

This document answers three blocking questions before any pilot use.

---

## Question 1: Does `post-tool-use.sh` fire for container-internal tool calls?

**Answer: NO.**

`post-tool-use.sh` is a Claude Code `PostToolUse` hook. It fires when the Claude Code
harness observes a tool execution event. The harness manages tool dispatch for tools it
controls: `Bash`, `Write`, `Edit`, `Read`, `Glob`, `Grep`, and MCP tools (`mcp__*`).

`code_execution_20260120` is an Anthropic Messages API feature. When the model uses it:
1. The model generates a `tool_use` block with `type: "code_execution"`
2. Anthropic's API executes the code in a sandboxed container server-side
3. The result is returned as a `tool_result` block in the API response
4. Claude Code's harness sees the outer `code_execution` tool use, but individual
   operations inside the container (file writes, subprocess calls, network requests)
   happen entirely within Anthropic's infrastructure

**The harness fires `PostToolUse` once for the outer `code_execution` tool call, NOT
for each operation inside the container.** Container-internal operations are invisible
to our hook infrastructure.

### Specific gaps

| Security Layer | Tool Matched | Bypassed by Container? |
|----------------|-------------|----------------------|
| Initiator-type policy (destructive git ops) | `Bash` | **YES** — container can run `git push --force` without triggering the Bash pattern match |
| Command-chain length monitor | `Bash` | **YES** — container subprocess chains are invisible |
| MCP depth monitor | `mcp__*` | **NO** — MCP tools are not available inside the container (container has no MCP server connections) |
| Lifecycle tracker | `Write`/`Edit` | **YES** — container file writes don't trigger Write/Edit hooks |
| Permission checker | `Write` to `.claude/skills/` | **YES** — container can write SKILL.md without permission validation |

### Severity

**HIGH for our pipeline.** The factory-steward and meta-agent-factory are orchestration
agents that delegate work. If these agents use `code_execution_20260120`, they could:
- Write SKILL.md files without permission checks
- Execute arbitrary shell commands without command-chain monitoring
- Modify git state without initiator-type policy enforcement

---

## Question 2: What container-level instrumentation exists?

**Answer: LIMITED.**

Based on available documentation (as of 2026-04-18):

1. **Stream events**: The Messages API streaming response includes `content_block_start`
   and `content_block_delta` events for `code_execution` blocks. These show the code
   being executed and its output, but arrive in the response stream — not as hook events.

2. **Container output capture**: The `tool_result` block from `code_execution` includes
   `stdout`, `stderr`, and `exit_code` fields. Claude Code could parse these post-hoc,
   but this is response-level logging, not pre-execution interception.

3. **No PreToolUse equivalent**: There is no mechanism to intercept or deny a specific
   operation inside the container before it executes. The container runs to completion
   and returns results.

4. **Container isolation**: The container has a 30-day retention period, network access
   (outbound), and a working filesystem. It does NOT have access to MCP servers, the
   user's filesystem, or Claude Code's tool registry. However, it CAN make HTTP requests
   (including to APIs) and execute arbitrary Python/shell code.

**Key limitation**: Our security hooks are *pre-execution gates* (post-tool-use.sh can
`exit 1` to block a tool). Container operations cannot be gated — they execute server-side
before we see the result.

---

## Question 3: What is the minimal deny rule to gate `code_execution_20260120`?

**Answer: Block at the outer tool level via `settings.local.json`.**

The `code_execution_20260120` tool appears as a single tool name in Claude Code's tool
registry. It can be denied at the harness level:

### Option A: Deny in `settings.local.json` (recommended)

```json
{
  "permissions": {
    "deny": [
      "Tool(code_execution_20260120)"
    ]
  }
}
```

This prevents the model from invoking the container at all. No container operations
occur. All existing security hooks continue to function for standard tools.

### Option B: Deny via `PreToolUse` hook (if granular control needed)

A future `pre-tool-use.sh` hook could inspect `CLAUDE_TOOL_NAME` and block
`code_execution_20260120` selectively (e.g., allow in researcher sessions but deny
in factory sessions).

### Option C: Allow with post-hoc audit (future, not recommended today)

Parse the `code_execution` tool result's `stdout`/`stderr` fields for dangerous
patterns (git push, file writes to sensitive paths). This is detective-only, not
preventive — the operations already executed.

---

## Recommendation

**Gate status: BLOCKED. Do not pilot `code_execution_20260120` until two conditions are met:**

1. **Minimal**: Add `Tool(code_execution_20260120)` to `permissions.deny` in
   `.claude/settings.local.json` for all cron-automated sessions. This is a 1-line
   change and prevents accidental container use.

2. **Before pilot**: Design a container-output audit layer that parses `code_execution`
   results for:
   - File write patterns (SKILL.md creation without permission check)
   - Git operations (destructive commands without initiator policy)
   - Network requests (data exfiltration, API key leakage)

   Implementation estimate: ~4 hours (response-parsing hook, pattern matching, alert logging).

**Pilot sequencing** (when conditions met):
1. First: `agentic-ai-researcher` — read-only tool surface (WebSearch, WebFetch, Read).
   Container adds efficiency but no write-path risk.
2. Second: `factory-steward` — write-heavy tool surface. Requires the container-output
   audit layer before proceeding.

---

## ZDR Note

`code_execution_20260120` is **NOT** Zero Data Retention eligible. Container data
is retained for 30 days. This has Phase 7 regulatory implications (Taiwan PDPA,
Japan APPI) — customer data processed via container is subject to 30-day retention.
See also: ZDR running log in `credential-isolation-design.md`.

---

## Decision Summary

| Question | Answer | Impact |
|----------|--------|--------|
| Does post-tool-use.sh fire for container ops? | **No** | 4 of 5 security layers bypassed |
| What instrumentation exists? | Stream events + output capture (post-hoc only) | No pre-execution interception |
| Minimal deny rule? | `permissions.deny: ["Tool(code_execution_20260120)"]` | 1-line change, blocks all container use |
| Can we pilot today? | **No** | Blocked until deny rule applied + audit layer designed |

---

*This analysis blocks D1 (Programmatic Tool Calling pilot) from deferred-items 2026-04-18.
Revisit when deny rule is applied and container-output audit layer is designed.*
