# Claude Agent SDK

**Last updated**: 2026-04-03
**Sources**:
- https://platform.claude.com/docs/en/agent-sdk/overview
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://claude.com/blog/building-agents-with-the-claude-agent-sdk
- https://github.com/anthropics/claude-agent-sdk-python
- https://github.com/anthropics/claude-agent-sdk-python/releases
- https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md
- https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk
- https://www.contextstudios.ai/glossary/anthropic-agent-sdk
- https://releasebot.io/updates/anthropic

## Overview

The Claude Agent SDK (formerly Claude Code SDK, renamed late 2025) is Anthropic's general-purpose agent runtime that gives developers the same tools, agent loop, and context management that power Claude Code as a programmable library. As of April 2, 2026, Python is at v0.1.54 and TypeScript is at v0.2.90. It supports built-in tools, hooks, subagents, MCP integration, permissions, session management, plugins, and skills.

## Key Developments (reverse chronological)

### 2026-04-03 — TypeScript SDK: Progress Summaries and Runtime Settings
- **What**: TypeScript SDK v0.2.90 added two notable features: (1) `agentProgressSummaries` option enables periodic AI-generated progress summaries for running subagents — useful for long-running tasks where the parent agent or user needs status updates without interrupting the subagent. (2) `getSettings()` method returns runtime-resolved model and effort values, enabling agents to introspect their own configuration.
- **Significance**: Progress summaries address a key UX gap in multi-agent systems — knowing what a subagent is doing during long operations. `getSettings()` enables self-aware agents that can adjust behavior based on their resolved configuration.
- **Source**: https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### 2026-04-03 — 1M Context Window Beta Retiring for Older Sonnet Models (April 30)
- **What**: The 1M token context window beta for Claude Sonnet 4.5 and Claude Sonnet 4 is being retired on April 30, 2026. Users must migrate to Claude Sonnet 4.6 or Claude Opus 4.6 for 1M context at standard pricing.
- **Significance**: Affects any SDK-based agents configured to use older Sonnet models with extended context. Migration to 4.6 models is required before April 30.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 — CLI v2.1.89: "Defer" Permission Hook and PermissionDenied Hook
- **What**: The bundled CLI introduced a "defer" permission option in PreToolUse hooks, allowing hooks to pass permission decisions to the next handler rather than accepting or rejecting. Also added a `PermissionDenied` hook that fires when auto mode denies a tool use. Fixed StructuredOutput schema cache failures (~50% failure rate for multi-schema sessions).
- **Significance**: The "defer" permission pattern enables layered permission policies. The `PermissionDenied` hook enables audit logging of denied operations. The schema cache fix resolves a severe reliability issue.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-02 — Deep dive: SDK release cadence and new primitives (Python v0.1.54, TS v0.2.90)
- **What**: Rapid release cadence continues. Since the last KB entry (v0.1.48 Python / v0.2.71 TS), both SDKs have shipped dozens of releases adding major new capabilities. Key new primitives and APIs are documented below.
- **Significance**: The SDK has matured from a basic query wrapper to a full agent runtime with session management, subagent introspection, token budgeting, plugin reload, and context usage analytics. Production readiness is confirmed by the pace of bugfixes targeting edge cases (deadlocks, race conditions, cancellation scopes).
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

#### New classes, methods, and options (Python SDK, v0.1.49 -- v0.1.54)

| Version | Feature | Details |
|---------|---------|---------|
| v0.1.54 | (latest) | Bugfix release, bundled CLI v2.1.88 |
| v0.1.53 | `--setting-sources` fix, deadlock fix | Fixed deadlock in `query()` with string prompt + hooks/MCP triggering many tool calls; spawns `wait_for_result_and_end_input()` as background task |
| v0.1.52 | `get_context_usage()` | Query context window usage by category |
| v0.1.52 | `typing.Annotated` support | Per-parameter descriptions in JSON Schema for tool definitions |
| v0.1.52 | `ToolPermissionContext` | Exposed `tool_use_id` and `agent_id` fields |
| v0.1.52 | `session_id` option | Added to `ClaudeAgentOptions` for explicit session targeting |
| v0.1.52 | `control_cancel_request` | Proper hook callback cancellation handling |
| v0.1.51 | `fork_session()` | Fork an existing session to explore alternative paths |
| v0.1.51 | `delete_session()` | Clean up session data |
| v0.1.51 | `task_budget` | Token budget management option |
| v0.1.51 | `SystemPromptFile` | Support for `--system-prompt-file` CLI flag |
| v0.1.51 | `AgentDefinition` expanded | Added `disallowedTools`, `maxTurns`, `initialPrompt` fields |
| v0.1.50 | `get_session_info()` | Retrieve session metadata (tag, created_at) |
| v0.1.49 | `AgentDefinition` expanded | Added `skills`, `memory`, `mcpServers` fields |
| v0.1.49 | `tag_session()` | Tag sessions with Unicode sanitization |
| v0.1.49 | `rename_session()` | Rename existing sessions |
| v0.1.49 | `RateLimitEvent` | Typed message class for rate limit events |
| v0.1.49 | Per-turn `usage` | Usage stats preserved on `AssistantMessage` |

#### New classes, methods, and options (TypeScript SDK, v0.2.80 -- v0.2.90)

| Version | Feature | Details |
|---------|---------|---------|
| v0.2.90 | Parity with CLI v2.1.90 | Latest release |
| v0.2.89 | `startup()` | Pre-warm CLI subprocess before `query()` -- first query ~20x faster |
| v0.2.89 | `listSubagents()` | Retrieve subagent list from session history |
| v0.2.89 | `getSubagentMessages()` | Read subagent conversation history |
| v0.2.89 | `includeSystemMessages` option | Include system messages in `getSessionMessages()` |
| v0.2.89 | `includeHookEvents` option | Enable hook lifecycle messages (`hook_started`, `hook_progress`, `hook_response`) |
| v0.2.86 | `getContextUsage()` | Context window usage breakdown by category |
| v0.2.85 | `reloadPlugins()` | Reload plugins, receive refreshed commands/agents/MCP status |
| v0.2.84 | `taskBudget` | API-side token budget awareness |
| v0.2.84 | `enableChannel()` + `capabilities` | MCP server channel control and capability discovery |
| v0.2.84 | `EffortLevel` type | Exported type: `'low' | 'medium' | 'high' | 'max'` |
| v0.2.83 | `seed_read_state` | Seed `readFileState` with `{path, mtime}` for context priming |

#### Notable bugfixes (selection)
- Fixed MCP servers getting permanently stuck in failed state after connection race (TS v0.2.89)
- Fixed Zod v4 `.describe()` metadata being dropped from `createSdkMcpServer` tool schemas (TS v0.2.89)
- Fixed `getSessionMessages()` dropping parallel tool results (TS v0.2.80)
- Fixed deadlock with string prompt + many tool calls (Python v0.1.53)
- Fixed cross-task cancel scope `RuntimeError` on async generator cleanup (Python v0.1.51)
- Added `SIGKILL` fallback when `SIGTERM` handler blocks (Python v0.1.51)
- Fixed `include_partial_messages=True` not delivering `input_json_delta` events (Python v0.1.48)

#### Session management (v0.1.46+)
- `list_sessions()` -- enumerate all sessions
- `get_session_messages()` -- retrieve conversation history with pagination
- `add_mcp_server()` / `remove_mcp_server()` -- dynamic MCP server management
- Typed task messages: `TaskStarted`, `TaskProgress`, `TaskNotification`
- `ResultMessage.stop_reason` field
- Hook input enhancements: `agent_id` and `agent_type` in tool-lifecycle hooks

### 2026-04-02 — Agent Skills GA, SDK v0.2.89 (TypeScript)
- **What**: Agent Skills launched -- modular capability packages (instructions + metadata + resources) that Claude loads dynamically. Anthropic-managed Skills ship for Office docs (pptx, xlsx, docx) and PDF; custom Skills uploadable via Skills API. TypeScript SDK now at v0.2.89 with continuous releases. Claude Opus 4.6 launched as flagship agentic model. Web search and web fetch tools are now GA with dynamic domain filtering.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview, https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk

### 2026-03-01 -- SDK reaches v0.1.48 (Python) / v0.2.71 (TypeScript)
- **What**: Active development continues with regular releases. Python and TypeScript SDKs are feature-parallel.
- **Significance**: Production-ready maturity indicated by version cadence and enterprise adoption.
- **Source**: https://www.contextstudios.ai/glossary/anthropic-agent-sdk

### 2025-09-01 -- Rename from Claude Code SDK to Claude Agent SDK
- **What**: SDK renamed to reflect broader purpose beyond coding. Migration guide published.
- **Significance**: Signals Anthropic's positioning of the SDK as a general-purpose agent framework, not just a coding tool.
- **Source**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk

### 2025-03-01 -- Initial Claude Code SDK release
- **What**: Released with Tool Use, Orchestration Loops, Guardrails, and Tracing capabilities.
- **Significance**: First official SDK for building Claude-powered agents programmatically.
- **Source**: https://www.contextstudios.ai/glossary/anthropic-agent-sdk

## Technical Details

### Core API Surface

The primary entry point is the `query()` function (async generator):

```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

### Built-in Tools
| Tool | Purpose |
|------|---------|
| Read | Read any file in working directory |
| Write | Create new files |
| Edit | Make precise edits to existing files |
| Bash | Run terminal commands, scripts, git operations |
| Glob | Find files by pattern |
| Grep | Search file contents with regex |
| WebSearch | Search the web |
| WebFetch | Fetch and parse web pages |
| AskUserQuestion | Ask user clarifying questions |
| Agent | Spawn subagents |

### Subagent Architecture
Subagents enable parallelization and context isolation:

```python
options=ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Expert code reviewer",
            prompt="Analyze code quality and suggest improvements.",
            tools=["Read", "Glob", "Grep"],
            # New in v0.1.51:
            disallowed_tools=["Bash"],
            max_turns=20,
            initial_prompt="Start by reading the project structure.",
            # New in v0.1.49:
            skills=[],
            memory="Review all code for security vulnerabilities.",
            mcp_servers={},
        )
    },
)
```

Key properties:
- Each subagent gets its own isolated context window
- Only relevant results sent back to orchestrator
- Messages include `parent_tool_use_id` for tracking
- Prevents context bloat when processing large volumes
- Subagent introspection: `listSubagents()` and `getSubagentMessages()` (TS v0.2.89)

### Hooks System
SDK hooks use callback functions (not shell commands like CLI hooks):
- **PreToolUse**: Validate, block, or transform tool calls
- **PostToolUse**: Audit logging, side effects
- **Stop, SessionStart, SessionEnd**: Lifecycle events
- **UserPromptSubmit**: Pre-process user input
- Hook inputs now include `agent_id` and `agent_type` (v0.1.46+)
- Hook lifecycle messages available via `includeHookEvents` option (TS v0.2.89)

### Authentication
- Direct API key: `ANTHROPIC_API_KEY`
- Amazon Bedrock: `CLAUDE_CODE_USE_BEDROCK=1`
- Google Vertex AI: `CLAUDE_CODE_USE_VERTEX=1`
- Microsoft Azure: `CLAUDE_CODE_USE_FOUNDRY=1`

### MCP Integration
```python
options=ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    }
)
```

Dynamic MCP management (v0.1.46+):
- `add_mcp_server()` -- add MCP server at runtime
- `remove_mcp_server()` -- remove MCP server at runtime
- `McpServerStatus` typed response with `capabilities` field (TS v0.2.84)
- `enableChannel()` for MCP server channel control (TS v0.2.84)

### Session Management
Sessions maintain context across multiple exchanges with resume capability:
- Capture `session_id` from init message
- Resume with `options=ClaudeAgentOptions(resume=session_id)`
- `fork_session()` -- fork to explore different approaches (v0.1.51)
- `delete_session()` -- clean up session data (v0.1.51)
- `list_sessions()` -- enumerate all sessions (v0.1.46)
- `get_session_messages()` -- retrieve history with pagination (v0.1.46)
- `get_session_info()` -- metadata including tag and created_at (v0.1.50)
- `tag_session()` -- tag sessions with Unicode sanitization (v0.1.49)
- `rename_session()` -- rename sessions (v0.1.49)

### Token Budget Management
- `task_budget` option in `ClaudeAgentOptions` (Python v0.1.51, TS v0.2.84)
- `get_context_usage()` / `getContextUsage()` -- breakdown of context window usage by category (Python v0.1.52, TS v0.2.86)
- `EffortLevel` type: `'low' | 'medium' | 'high' | 'max'` (TS v0.2.84)

### Performance Optimization
- `startup()` -- pre-warm CLI subprocess before first `query()`, making first query ~20x faster (TS v0.2.89)
- `seed_read_state` -- seed file read state with `{path, mtime}` for context priming (TS v0.2.83)

### Plugin System
- `reloadPlugins()` -- hot-reload plugins and receive refreshed commands, agents, MCP server status (TS v0.2.85)

### Claude Code Feature Integration
When `setting_sources=["project"]` is set, SDK agents can use:
- Skills (`.claude/skills/*/SKILL.md`)
- Slash commands (`.claude/commands/*.md`)
- Memory (`CLAUDE.md`)
- Plugins (programmatic via `plugins` option)

### Design Principles (from Anthropic engineering blog)
1. **Gather context** - Search files, semantic retrieval, deploy subagents
2. **Take action** - Execute via tools, bash, code generation, MCPs
3. **Verify work** - Rules-based checks, visual feedback, LLM judgments
4. Start with agentic search (grep, tail) before semantic search
5. Use the file system as structured context engineering
6. Prioritize rules-based feedback for precise evaluation

### Branding Rules
- Allowed: "Claude Agent", "{YourName} Powered by Claude"
- Not allowed: "Claude Code" or Claude Code-branded elements

## Comparison Notes

Google's equivalent is the Agent Development Kit (ADK). Key differences:
- Claude Agent SDK builds on Claude Code's tool ecosystem; Google ADK is a standalone framework
- Claude Agent SDK has built-in tool execution; Google ADK requires more manual tool implementation
- Claude Agent SDK is tightly coupled to Claude models; Google ADK supports multiple model backends
- Both support multi-agent orchestration with subagent patterns
- Claude Agent SDK offers session management with resume/fork; ADK has its own session primitives
- Claude Agent SDK now has dynamic MCP server management (add/remove at runtime); ADK uses static tool configuration
- Claude Agent SDK introduced token budgeting and context usage analytics; ADK does not yet have equivalents
