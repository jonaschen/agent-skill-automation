# Claude Agent SDK

**Last updated**: 2026-04-02
**Sources**:
- https://platform.claude.com/docs/en/agent-sdk/overview
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://claude.com/blog/building-agents-with-the-claude-agent-sdk
- https://github.com/anthropics/claude-agent-sdk-python
- https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk
- https://www.contextstudios.ai/glossary/anthropic-agent-sdk

## Overview

The Claude Agent SDK (formerly Claude Code SDK, renamed late 2025) is Anthropic's general-purpose agent runtime that gives developers the same tools, agent loop, and context management that power Claude Code as a programmable library. Available in Python (v0.1.48 on PyPI) and TypeScript (v0.2.71 on npm) as of March 2026, it supports built-in tools, hooks, subagents, MCP integration, permissions, and session management.

## Key Developments (reverse chronological)

### 2026-04-02 — Agent Skills GA, SDK v0.2.89 (TypeScript)
- **What**: Agent Skills launched — modular capability packages (instructions + metadata + resources) that Claude loads dynamically. Anthropic-managed Skills ship for Office docs (pptx, xlsx, docx) and PDF; custom Skills uploadable via Skills API. TypeScript SDK now at v0.2.89 with continuous releases. Claude Opus 4.6 launched as flagship agentic model. Web search and web fetch tools are now GA with dynamic domain filtering.
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
        )
    },
)
```

Key properties:
- Each subagent gets its own isolated context window
- Only relevant results sent back to orchestrator
- Messages include `parent_tool_use_id` for tracking
- Prevents context bloat when processing large volumes

### Hooks System
SDK hooks use callback functions (not shell commands like CLI hooks):
- **PreToolUse**: Validate, block, or transform tool calls
- **PostToolUse**: Audit logging, side effects
- **Stop, SessionStart, SessionEnd**: Lifecycle events
- **UserPromptSubmit**: Pre-process user input

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

### Session Management
Sessions maintain context across multiple exchanges with resume capability:
- Capture `session_id` from init message
- Resume with `options=ClaudeAgentOptions(resume=session_id)`
- Fork sessions to explore different approaches

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
