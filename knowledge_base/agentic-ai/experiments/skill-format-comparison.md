# Experiment: Skill Format Comparison — Claude Code SKILL.md vs Gemini CLI SKILL.md

**Date**: 2026-04-18
**Strategic Priority**: S3 (Platform Generalization / Cross-Platform Agent Portability)
**Hypothesis**: The gap between Claude Code and Gemini CLI agent/skill definition formats is small enough that a transpiler approach (one canonical format, compiled to vendor-specific formats) is feasible without inventing a new shared runtime.
**Method**: Side-by-side comparison of documented formats, field-level mapping, gap analysis
**Metrics**: Number of incompatible fields, number of shared concepts, feasibility verdict
**Compute Budget**: 0 (research-only, no code execution)
**Status**: complete

---

## 1. SKILL.md Format Comparison

### Shared Structure

Both platforms use the **identical** core pattern: a directory containing a `SKILL.md` file with YAML frontmatter + Markdown body.

| Aspect | Claude Code | Gemini CLI |
|--------|------------|------------|
| File name | `SKILL.md` | `SKILL.md` |
| Format | YAML frontmatter + Markdown body | YAML frontmatter + Markdown body |
| Required fields | `name`, `description` | `name`, `description` |
| Body purpose | Agent instructions | Agent instructions |
| Resource dirs | scripts/, resources/, assets/ (convention) | scripts/, references/, assets/ (convention) |

### Frontmatter Field Mapping

| Field | Claude Code | Gemini CLI | Compatible? |
|-------|------------|------------|-------------|
| `name` | Required, kebab-case | Required, matches directory name | YES |
| `description` | Required, used for trigger routing (max 1,536 chars) | Required, used for trigger routing | YES |
| `tools` | YAML list of tool names (Read, Write, Bash, etc.) | NOT in SKILL.md frontmatter | NO — Gemini grants tools at activation via file path access |
| `model` | Optional model override (e.g., `claude-opus-4-6`) | NOT in SKILL.md frontmatter | NO — Gemini uses session model |

### Discovery Locations

| Tier | Claude Code | Gemini CLI |
|------|------------|------------|
| Workspace | `.claude/skills/<name>/SKILL.md` | `.gemini/skills/<name>/SKILL.md` or `.agents/skills/<name>/SKILL.md` |
| User | `~/.claude/skills/<name>/SKILL.md` | `~/.gemini/skills/<name>/SKILL.md` or `~/.agents/skills/<name>/SKILL.md` |
| Extensions | N/A (MCP servers instead) | Bundled within installed extensions |

### Activation Mechanism

| Aspect | Claude Code | Gemini CLI |
|--------|------------|------------|
| Trigger | Description-based matching → `Skill` tool call | Description-based matching → `activate_skill` tool call |
| User approval | Configurable (auto or prompt) | Prompt displays name + purpose + directory path |
| Context injection | Skill body loaded into conversation | SKILL.md body + folder structure added to conversation |
| File access | Governed by tool permissions in frontmatter | Skill's directory added to agent's allowed file paths |
| Deactivation | Session-scoped | Session-scoped (until task complete) |
| Slash command | `/<skill-name>` invokes directly | Not documented |

### Key Differences

1. **Tool permissions**: Claude Code declares allowed tools per-skill in YAML frontmatter (`tools: [Read, Write, Bash]`). Gemini CLI does NOT — tools are implicitly available or managed at the session/agent level. This is the **largest format gap**.

2. **Model override**: Claude Code allows per-skill model selection (`model: claude-opus-4-6`). Gemini CLI does not support this in SKILL.md (only in agent definitions).

3. **Vendor-specific tool names**: Claude Code tools (Read, Write, Edit, Bash, WebSearch, WebFetch, Agent, etc.) have no direct Gemini CLI equivalents by name. Gemini CLI uses different tool names (read_file, grep_search, glob, shell, etc.).

4. **Extension discovery**: Gemini CLI has a third discovery tier (extensions); Claude Code uses MCP servers instead.

---

## 2. Agent Definition Format Comparison

Beyond SKILL.md, both platforms have separate agent/subagent definitions:

| Aspect | Claude Code | Gemini CLI |
|--------|------------|------------|
| File location | `.claude/agents/<name>.md` | `.gemini/agents/<name>.md` |
| Format | Markdown + YAML frontmatter | Markdown + YAML frontmatter |
| `name` | Required | Required (lowercase, hyphens, underscores) |
| `description` | Required | Required |
| `tools` | YAML list of tool names | YAML list of tool names (supports wildcards: `*`, `mcp_*`) |
| `model` | Optional model override | Optional model override (e.g., `gemini-2.5-pro`) |
| `temperature` | Not in frontmatter | Optional, 0.0-2.0, default 1 |
| `max_turns` | Not in frontmatter | Optional, default 30 |
| `timeout_mins` | Not in frontmatter | Optional, default 10 |
| `kind` | Not applicable | `local` (default) or `remote` |
| `mcpServers` | Not in frontmatter (global config) | Inline MCP server configs per-agent |
| Body | System prompt + instructions | System prompt + instructions |
| Routing | Description-based matching → `Agent` tool | Description-based matching + `@agent-name` force-delegation |
| Recursion | Subagents can spawn subagents (with depth limits) | Subagents CANNOT invoke other subagents (no recursion) |

### Key Differences

1. **Agent-level configuration**: Gemini CLI exposes more runtime parameters in agent frontmatter (temperature, max_turns, timeout_mins, kind). Claude Code handles these at the platform/CLI level.

2. **MCP scoping**: Gemini CLI allows per-agent MCP server configs inline. Claude Code configures MCP globally.

3. **Recursion**: Claude Code allows multi-level subagent delegation. Gemini CLI prevents it entirely.

4. **Force delegation**: Gemini CLI has `@agent-name` syntax. Claude Code uses the `Agent` tool with `subagent_type` parameter.

---

## 3. Passive Skill Lifecycle (Gemini CLI v0.39.0-preview.0)

Gemini CLI v0.39.0-preview.0 introduced a **passive skill lifecycle** that Claude Code does not have:

1. **Extract**: Gemini observes user patterns and extracts potential skill definitions
2. **Inbox**: Extracted skills go to `/memory inbox` for review
3. **Approve**: User reviews and approves/rejects skill candidates
4. **Activate**: Approved skills become available for future sessions

This is a **fundamentally different approach** — Gemini CLI can auto-generate skills from usage patterns, while Claude Code requires manual skill creation. This has implications for S3: any portable format would need to support both explicit creation (Claude) and passive extraction (Gemini).

---

## 4. Feasibility Assessment

### Gap Size: MODERATE

- **Core format**: Nearly identical (SKILL.md + YAML frontmatter + Markdown body)
- **Required fields**: Identical (name, description)
- **Discovery pattern**: Same tiered model (workspace → user), different directory prefixes
- **Activation**: Same pattern (description-based routing, approval, context injection)
- **Major gaps**: Tool permissions (Claude-specific), runtime params (Gemini-specific), tool name mapping, passive extraction (Gemini-only)

### Recommended Approach: TRANSPILER

A transpiler approach is feasible:

1. **Canonical format**: Use SKILL.md as the canonical format (already shared)
2. **Shared fields**: `name`, `description`, body content — pass through unchanged
3. **Vendor-specific frontmatter**: Generate vendor-specific fields:
   - Claude: Add `tools:` list mapping to Claude tool names
   - Gemini: Omit `tools:` (handled at session level), add runtime params if needed
4. **Directory placement**: Copy to `.claude/skills/` or `.gemini/skills/` based on target
5. **Tool name mapping**: Maintain a mapping table (Read↔read_file, Bash↔shell, etc.)

### What WON'T Port

- Claude Code's mutually exclusive permission model (Review agents denied Write/Edit) — Gemini CLI has no equivalent
- Gemini CLI's passive skill extraction — no Claude Code equivalent
- Gemini CLI's `@agent-name` force-delegation syntax
- Claude Code's `Agent` tool with `subagent_type` parameter
- Platform-specific tools (WebSearch, WebFetch, Agent, Monitor vs. Gemini equivalents)

### Verdict

**The gap is "adapt existing formats" — NOT "invent something new."** The core SKILL.md format is already cross-platform by coincidence (both teams converged on the same pattern independently). A lightweight transpiler + tool name mapping table would handle 80% of cases. The remaining 20% (permission models, passive extraction, runtime config) are vendor-specific features that should remain as optional extensions rather than being forced into a shared format.

---

## 5. A2A Agent Card as Cross-Platform Identity Layer

The A2A protocol's Agent Card offers a third angle on cross-platform identity:

| Aspect | SKILL.md (both) | A2A Agent Card |
|--------|-----------------|----------------|
| Purpose | Internal agent definition | External agent discovery/interop |
| Format | YAML + Markdown | JSON (`.well-known/agent.json`) |
| Identity | name + description | name + description + URL + capabilities |
| Auth | Platform-managed | Signed cards (cryptographic) |
| Discovery | File system scan | HTTP `.well-known/` endpoint |

Agent Cards solve a **different problem** — inter-agent discovery across networks, not agent definition within a project. However, for Phase 7 AaaS, Agent Cards could serve as the **public-facing identity** for agents defined by SKILL.md internally. The transpiler could generate both vendor-specific SKILL.md files AND an A2A Agent Card for external exposure.

---

## Conclusions

1. **SKILL.md format convergence is real** — both platforms independently arrived at the same core pattern. This is the strongest S3 signal to date.
2. **A transpiler is feasible and recommended** over a shared runtime — the differences are in frontmatter fields and tool naming, not in fundamental architecture.
3. **Tool name mapping is the key deliverable** — a JSON mapping between Claude Code tool names and Gemini CLI tool names would unlock 80% of portability.
4. **Permission models are the hardest gap** — Claude Code's frontmatter-based tool restrictions have no Gemini CLI equivalent. Portable skills would need to accept the "least restrictive" permission model.
5. **Passive skill extraction is Gemini-only and can be ignored** for the canonical format — it's a feature of the Gemini CLI runtime, not of the skill definition format.
6. **Agent definitions are more divergent than skills** — the `.claude/agents/` and `.gemini/agents/` formats share structure but differ in runtime parameters. A separate agent-definition transpiler would be needed.
7. **Timeline recommendation**: Build the SKILL.md transpiler as a Phase 4/5 experiment before I/O (May 19). If Gemini CLI format changes at I/O, the transpiler is cheap to update. If it doesn't, we have a working cross-platform tool.

**Sources**:
- https://geminicli.com/docs/cli/skills/
- https://geminicli.com/docs/core/subagents/
- https://geminicli.com/docs/cli/creating-skills/
- https://geminicli.com/docs/tools/activate-skill/
- https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/skills.md
- https://github.com/google-gemini/gemini-cli/issues/15327
- https://medium.com/google-cloud/beyond-prompt-engineering-using-agent-skills-in-gemini-cli-04d9af3cda21
