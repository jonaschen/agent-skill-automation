# Permission Cache Design for Phase 5 HITL

**Date**: 2026-04-09
**Source**: Discussion 2026-04-09, ADOPT #5 (P2)
**Triggered by**: Gemini CLI v0.38.0-preview.0 context-aware persistent policy approvals
**Target Phase**: Phase 5.5 (Defensive architecture — HITL tier classifications)
**Status**: Design document — policy questions only, no implementation

---

## Rationale

Gemini CLI introduced context-aware persistent policy approvals — agents remember previously approved actions based on context, reducing repeated approval prompts. Our current permission system in `post-tool-use.sh` is stateless: every tool call is evaluated from scratch.

For Phase 5 multi-agent teams, this becomes a bottleneck. A scrum-team-orchestrator delegating to 3 parallel agents, each making 10+ tool calls, could generate 3+ approval interruptions per parallel batch — destroying concurrency benefits.

This document captures the **policy design** (not implementation) for a session-scoped permission cache, informed by Gemini CLI's approach as prior art.

---

## Policy Questions

### 1. What patterns are safe to auto-approve?

**Read-only operations**: All Read, Glob, Grep, WebSearch, WebFetch calls can be auto-approved after first approval in a session. These have no side effects.

**Repeated writes to the same directory**: If a human approves `Write` to `/path/to/dir/file1.md`, subsequent `Write` calls to `/path/to/dir/` can be auto-approved. The directory scope acts as the approval boundary.

**Never auto-approve**: Bash commands with destructive patterns (`rm`, `git push`, `git reset`), Write/Edit to system directories, MCP tool calls to untrusted servers. These always require fresh approval.

### 2. What is the expiry model?

**Session-scoped only**: Cache expires when the Claude Code session ends. Never persists across sessions. This is a hard safety invariant — no "I approved this last week" auto-approvals.

**Why not persistent**: Gemini CLI's persistent approvals violate our safety model. Between sessions, project state changes, permissions change, and the context that justified the original approval may no longer hold.

### 3. How does this interact with `CLAUDE_INITIATOR_TYPE`?

**Cron-automated**: Permission cache is **disabled** in `cron-automated` context. Cron agents already run with restricted permissions via `post-tool-use.sh` deny rules. Adding a cache would weaken the deny-by-default posture.

**Interactive**: Permission cache is **enabled** only in interactive context. This is where the UX friction of repeated approvals actually occurs.

### 4. Does the cache inherit across subagent delegation?

**No inheritance**: Each subagent starts with an empty permission cache. The parent agent's approvals do not propagate to children. This prevents privilege escalation via delegation chains.

**Rationale**: A parent agent approved to write to `/src/` should not automatically grant its subagents the same access. The human's approval was contextual to the parent's task.

### 5. Cache key design (conceptual)

```
Key: (tool_name, parameter_pattern_class, initiator_type)
Value: {decision: allow|deny, approved_at: timestamp, context_summary: string}
```

Where `parameter_pattern_class` is a normalized abstraction:
- Read/Glob/Grep → `(path_prefix)` — e.g., "reads within /src/"
- Write/Edit → `(directory)` — e.g., "writes to /src/components/"
- Bash → NOT CACHED (every Bash command is unique enough to require evaluation)

---

## Implementation Notes (deferred to Phase 5)

- Storage: temp file at `/tmp/claude-permission-cache-${SESSION_ID}.json` (cleaned on session end)
- Lookup: O(1) hash-based — must add zero perceptible latency to tool calls
- Integration: `post-tool-use.sh` checks cache before prompting; writes to cache after human decision
- Monitoring: cache hit/miss ratio logged for tuning

## Estimated Impact

- **Phase 5 HITL usability**: Reduces approval prompts by ~60-80% in multi-agent sessions
- **Safety**: Maintained by session-scoped expiry, no-inheritance rule, and Bash exclusion
- **Effort**: ~2-4 hours implementation when Phase 5 starts; design work done now

---

*Evaluation document created 2026-04-09 by factory-steward, from discussion ADOPT #5 (P2)*
*Prior art: Gemini CLI v0.38.0-preview.0 context-aware persistent policy approvals*
