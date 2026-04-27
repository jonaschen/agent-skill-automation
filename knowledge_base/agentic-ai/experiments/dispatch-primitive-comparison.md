# Experiment: Subagent Dispatch-Primitive Comparison — Claude Code `Agent` vs Gemini CLI `invoke_subagent`

**Date**: 2026-04-28
**Strategic Priority**: S3 (Platform Generalization / Cross-Platform Agent Portability)
**Hypothesis**: Claude Code's `Agent(subagent_type, prompt)` dispatcher and Gemini CLI's `invoke_subagent` (released as the unified mechanism in v0.39.0 stable, Apr 23) describe semantically equivalent operations, such that a vendor-neutral `dispatch(type, prompt, options) → result` abstraction can target both without per-vendor branching for the dispatch path itself.
**Method**: Documentation-based side-by-side comparison from official sources only — no CLI install required (S3 day-7 work-around per 2026-04-24 directive).
**Metrics**: Per-axis verdict (portable / partially portable / not portable); overall feasibility verdict.
**Compute Budget**: 0 (research-only).
**Status**: complete

---

## 1. Why Documentation-Based

The 2026-04-24 directive activated the S3 day-7 work-around: Gemini CLI install has been blocked on the human action queue for >7 days, but v0.39.0 stable shipped Apr 23 with a unified `invoke_subagent` mechanism. Per A5 from the 2026-04-24 discussion, the researcher should produce a documentation-only comparison so S3 architectural feasibility can be assessed independently of the install bottleneck. If the dispatch primitives are portable, S3 reduces to a transpiler problem on the agent-definition format. If not, S3 needs a different architecture.

## 2. Sources Consulted

| Source | URL | Date fetched |
|--------|-----|--------------|
| Claude Code Agent SDK — Subagents | https://code.claude.com/docs/en/agent-sdk/subagents | 2026-04-28 |
| Gemini CLI — Subagents core docs | https://github.com/google-gemini/gemini-cli/blob/main/docs/core/subagents.md | 2026-04-28 |
| Gemini CLI — Subagents (geminicli.com mirror) | https://geminicli.com/docs/core/subagents/ | 2026-04-28 |
| Google Developers Blog — Subagents have arrived | https://developers.googleblog.com/subagents-have-arrived-in-gemini-cli/ | 2026-04-28 |
| Gemini CLI v0.39.0 release notes | https://github.com/google-gemini/gemini-cli/releases | 2026-04-24 (prior sweep) |
| Claude Code v2.1.119 release notes | https://github.com/anthropics/claude-code/releases/tag/v2.1.119 | 2026-04-28 |
| Claude Code v2.1.63 (Task→Agent rename) | KB note from agent-sdk.md / SDK docs | 2026-04-28 |

## 3. Side-by-Side Dispatch Comparison

### 3.1 Tool Surface (the dispatch primitive)

| Aspect | Claude Code `Agent` | Gemini CLI subagents | Portable? |
|--------|---------------------|----------------------|-----------|
| Tool name (current) | `Agent` (renamed from `Task` in v2.1.63) | **Each subagent is exposed as its own tool, named after the subagent**. The internal dispatcher name (referenced as `invoke_subagent` in v0.39.0 release notes) is **not part of the public tool surface**. | **NO — structural divergence** |
| Number of tool entries | One single tool (`Agent`) — selects via `subagent_type` parameter | N tools, where N = number of registered subagents (one tool per subagent definition) | NO |
| Discovery mechanism | Subagent definitions registered via `agents` parameter or `.claude/agents/` files; Claude reads `description` to choose | Subagent definitions in `.gemini/agents/` or `.agents/` markdown files; main agent reads `description` to choose | YES — discovery mechanism is portable |

**Critical structural finding**: Claude Code uses **one dispatcher with a discriminator parameter**; Gemini CLI uses **per-subagent tools**. This is the largest portability gap. A vendor-neutral `dispatch(type, prompt)` abstraction can compile down to `Agent(subagent_type=type, prompt=prompt)` for Claude, but for Gemini it must compile to `<type>(prompt=prompt)` — the type is the tool name, not a parameter. The transpiler must therefore handle name-binding at compile time.

### 3.2 Parameter Schema

| Field | Claude Code `Agent` tool | Gemini CLI subagent tool | Portable? |
|-------|--------------------------|---------------------------|-----------|
| Required parameters | `subagent_type: string`, `prompt: string` (per `block.input.subagent_type` / `block.input.prompt` in SDK detection example) | `prompt: string` (subagent's identity is encoded in the tool name itself, so no `subagent_type` is needed) | Partially — `prompt` is universal, `subagent_type` is Claude-only |
| Optional parameters | None documented at the dispatch site (all customization lives in the `AgentDefinition` registered ahead of time) | None documented at the dispatch site | YES — neither vendor accepts ad-hoc dispatch options |
| Description field at definition time | Required string, drives matching | Required string, drives matching | YES |

**Verdict**: `(prompt: string)` is portable. The `subagent_type` field is Claude-specific but can be absorbed by the transpiler at compile time.

### 3.3 Specialization Mechanism (defining the subagent)

| Field | Claude Code `AgentDefinition` | Gemini CLI subagent frontmatter | Portable? |
|-------|-------------------------------|----------------------------------|-----------|
| `description` | Required | Required (`description`) | YES |
| `prompt` (system prompt) | Required string | The Markdown body of the SKILL.md file is the system prompt | YES — concept matches |
| `tools` | Optional `string[]` (allowlist) | Optional `string[]` with **wildcard support** (`*`, `mcp_*`, `mcp_<server>_*`) | Partially — wildcards are Gemini-only |
| `disallowedTools` | Optional `string[]` (denylist) | NOT documented as an explicit field | NO — Gemini lacks an explicit denylist field; must invert via allowlist |
| `model` | Optional alias (`sonnet`/`opus`/`haiku`/`inherit`) or full model ID | Optional model name; `inherit` is the implicit default | YES (semantic match) |
| `skills` | Optional `string[]` of named skills available to this agent | Implicit (skills attached via folder layout, not frontmatter) | NO |
| `memory` | `'user' \| 'project' \| 'local'` | Not documented at frontmatter level | NO |
| `mcpServers` | Per-agent MCP servers via name or inline config | Inline `mcpServers` object — agent-specific isolation | YES |
| `maxTurns` | Optional `number` | Not documented | NO |
| `background` | Optional `boolean` (non-blocking dispatch) | Not documented (no async dispatch primitive in public docs) | NO |
| `effort` | Optional reasoning effort level | Not documented | NO |
| `permissionMode` | Optional `PermissionMode` per-agent | Not documented at agent level (CLI-global instead) | NO |

**Verdict**: ~3 fields portable cleanly (`description`, system prompt, `mcpServers`). ~6 fields are Claude-only and need explicit fallback semantics in the transpiler. The Gemini side's wildcard tool grants are useful but Claude has no equivalent — these must be expanded at compile time on the Gemini target.

### 3.4 Context-Passing Behavior

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Initial context | Fresh — subagent receives only its own system prompt + dispatch-time `prompt` argument + project CLAUDE.md (if `settingSources` includes it) + tool definitions | Fresh — "Interactions with a subagent happen in a separate context loop"; "Independent history: subagent's conversation history does not bloat the main agent's context" | **YES** — both vendors converge on fresh-context semantics |
| Parent conversation history | Explicitly NOT inherited | Explicitly NOT inherited | YES |
| Parent system prompt | NOT inherited | Not documented either way (assumed isolated) | YES (probable) |
| Skills / extras | Only inherited if listed in `AgentDefinition.skills` | Implicit isolation | YES (semantic match) |
| Pass-through channel | The `prompt` string is the only channel from parent to subagent — must include any file paths, error messages, decisions inline | Same model — the dispatch prompt is the only data channel | **YES — strong convergence** |

**Verdict**: Context isolation is the strongest portability axis. Both vendors independently arrived at the same fresh-context-with-prompt-as-only-channel model. This is a major positive signal for portability.

### 3.5 Return Contract

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Return value | Subagent's final message returned **verbatim** as the Agent tool result | "Subagent reports back to the main agent with its findings" — no format specified | Partially — Claude is precise, Gemini is unspecified |
| Multi-message return | Only the final message is returned; intermediate tool calls and results stay in subagent | Implied same (separate context loop, only findings returned) | YES (probable) |
| Structured output | String only (the final message); structured output requires the subagent to produce JSON in its message | Not specified | Partially |
| Verbatim preservation by parent | Parent may summarize the verbatim result in its own response unless instructed otherwise | Not specified | Partially |
| Resume capability | **YES — `agentId` returned in tool result; parent can `resume: sessionId` and reference `agentId` to continue** (documented Apr 28) | NOT documented in current public docs | **NO — Claude-only feature** |

**Verdict**: The return contract is portable for the basic case (string final message). Resume is Claude-specific and is the largest functional gap on this axis.

### 3.6 Tool Permission Model for the Subagent

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Allowlist | `tools: string[]` | `tools: string[]` with wildcards | Partially |
| Denylist | `disallowedTools: string[]` | Not documented | NO |
| Wildcard expansion | Not supported | `*`, `mcp_*`, `mcp_<server>_*` | Partially |
| Inherits from parent if omitted | YES — "If omitted, inherits all tools" | Not explicitly documented (assumed similar) | YES (probable) |
| Inline MCP grant | Per-agent `mcpServers` | Per-agent `mcpServers` | YES |

**Verdict**: Allowlist is portable. Denylist is Claude-only (transpiler can convert to inverted allowlist on Gemini side). Wildcards are Gemini-only (transpiler must enumerate at compile time on Claude side).

### 3.7 Recursion / Sub-Sub-Agent Behavior

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Can a subagent dispatch another subagent? | **NO** — "Subagents cannot spawn their own subagents. Don't include `Agent` in a subagent's `tools` array." | **NO** — "Subagents cannot call other subagents." | **YES — both vendors enforce identical recursion ban** |

**Verdict**: Strong convergence. Both vendors independently chose to ban recursion at the dispatch layer.

### 3.8 Error Handling and Timeouts

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Timeout | Not documented (presumed enforced via `maxTurns`) | Not documented | Neither — gap on both sides |
| Failure propagation | Not explicitly documented (presumed surfaced as Agent tool error) | Not documented | Neither |
| Partial result on failure | Not documented | Not documented | Neither |

**Verdict**: Both vendors leave error/timeout semantics unspecified. This is a portability tax — the transpiler cannot rely on either vendor for clean failure handling and may need to wrap dispatches in its own watchdog logic.

### 3.9 Async / Background Dispatch

| Aspect | Claude Code | Gemini CLI | Portable? |
|--------|-------------|-------------|-----------|
| Non-blocking dispatch | **YES** — `AgentDefinition.background: true` | NOT documented | NO |
| Parallelism | Multiple subagents can run concurrently when invoked together | "Parallel orchestration" tutorials exist (Mastering Gemini CLI Subagents Part 3, Apr 2026) but the formal mechanism is not in the core subagents.md doc | Partially |

**Verdict**: Background/async is Claude-only at the documented dispatch primitive level. Parallel concurrent dispatch is documented for Claude and informally tutorialized for Gemini.

## 4. Aggregate Verdict per Axis

| Axis | Portability |
|------|-------------|
| Tool surface (dispatcher vs N tools) | **NOT portable** — structural divergence |
| Parameter schema (prompt) | **Portable** |
| Specialization frontmatter | **Partially portable** (3/12 fields clean, 6/12 Claude-only) |
| Context passing | **Fully portable** — strong convergence |
| Return contract (basic) | **Portable** |
| Return contract (resume) | **NOT portable** — Claude-only |
| Permission allowlist | **Portable** |
| Permission denylist | **NOT portable** — Claude-only |
| Wildcards | **NOT portable** — Gemini-only |
| Recursion ban | **Fully portable** — convergent |
| Error/timeout | **Portable by absence** (neither defines) |
| Background/async | **NOT portable** — Claude-only |

**Summary**: 5 axes fully portable, 2 partially, 5 not portable.

## 5. Overall Feasibility Verdict: **PARTIALLY PORTABLE — TRANSPILER FEASIBLE WITH NAME-BINDING + FEATURE-DEGRADATION RULES**

A vendor-neutral `dispatch(type, prompt) → result` abstraction is **feasible** because:

1. **Both vendors agree on fresh-context semantics** with prompt as the only data channel.
2. **Both vendors ban subagent recursion** identically.
3. **Both vendors support the same basic permission allowlist concept**.
4. **The dispatcher-vs-named-tools divergence is solvable at compile time**: the transpiler emits `Agent(subagent_type=X, prompt=...)` for Claude and `X(prompt=...)` for Gemini — neither user nor agent author needs to know.

But the abstraction has clear limits:

1. **Resume is not portable** — any pipeline relying on subagent resumability (relevant to our Phase 5 watchdog circuit-breaker) is Claude-only until Gemini ships an equivalent.
2. **Background/async dispatch is not portable** — must serialize on Gemini.
3. **Six AgentDefinition fields are Claude-only** (`maxTurns`, `effort`, `permissionMode`, `background`, `disallowedTools`, `memory`). The transpiler must either drop them on the Gemini target with a warning, or implement a runtime polyfill (e.g., enforce `maxTurns` via a parent-side counter).
4. **Wildcards in tool permissions** must be expanded at transpile time when targeting Claude.

## 6. Recommended Abstraction Surface (vendor-neutral)

```
dispatch(
  type: string,        // subagent identifier — compiled to subagent_type (Claude) or tool name (Gemini)
  prompt: string,      // sole data channel — both vendors enforce this
  options?: {
    timeout_ms?: number,    // transpiler implements parent-side watchdog if vendor lacks
    background?: boolean,   // honored on Claude, sequenced on Gemini with warning
  }
) → Promise<string>    // the verbatim final message
```

```
defineAgent(
  name: string,
  description: string,
  systemPrompt: string,
  tools?: string[],        // resolved against vendor wildcard rules
  mcpServers?: MCPSpec[],
  model?: 'sonnet'|'opus'|'haiku'|'inherit'|string,
)
```

Claude-only escape hatch: `defineAgent({..., claude: { maxTurns, effort, permissionMode, disallowedTools, background, memory }})`.

## 7. What This Tells Us About S3 Architecture

- **Tool portability via MCP**: already converged (both vendors production MCP) — confirmed by 2026-04-24 directive.
- **Dispatch primitive**: **partially portable** (this analysis) — feasible with transpiler.
- **Agent definition format**: **partially portable** per the prior `skill-format-comparison.md` (2026-04-18) — feasible with transpiler.
- **Orchestration protocol** (multi-agent coordination beyond single dispatch): out of scope for this comparison; would require a separate analysis of A2A vs SDK subagents at the multi-hop level.

**S3 architectural verdict**: A canonical-format → transpiler approach is the right architecture. A shared runtime is NOT required. The transpiler must handle name-binding (dispatcher vs named tools), wildcard expansion, and feature-degradation warnings for Claude-only fields.

**Implementation gating**: This analysis closes the documentation-based portion of S3 feasibility. Empirical validation (transpile a real SKILL.md and run it on both vendors) still requires Gemini CLI install. That is the next gate.

## 8. Continuity Notes

- Closes day-7 S3 pivot per 2026-04-24 directive (P0).
- Builds on `skill-format-comparison.md` (2026-04-18) — that analyzed format frontmatter, this analyzes runtime dispatch. Together they cover both halves of S3 feasibility.
- Cites: Gemini CLI v0.39.0 unified `invoke_subagent` (referenced in release notes; not yet a public tool name); Claude Code v2.1.63 Task→Agent rename (still partial — SDK emits `Task` in `system:init` and `permission_denials`).
- Open questions for empirical follow-up (post-Gemini-CLI-install): (a) does Gemini actually expose `invoke_subagent` as a callable tool name, or is it purely an internal dispatcher name? (b) what is the actual error format on Gemini subagent failure? (c) does Gemini support concurrent dispatch from a single parent message?
