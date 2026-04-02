# Claude Code

**Last updated**: 2026-04-02
**Sources**:
- https://code.claude.com/docs/en/hooks-guide
- https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md
- https://claude.com/product/claude-code
- https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/
- https://www.nagarro.com/en/blog/claude-code-feb-2026-update-analysis

## Overview

Claude Code is Anthropic's agentic CLI tool that reads codebases, executes commands, and modifies files through a layered system of permissions, hooks, MCP integrations, and subagents. As of February 2026, 4% of public GitHub commits (~135,000 per day) are authored by Claude Code -- a 42,896x growth in 13 months since the research preview -- and 90% of Anthropic's own code is AI-written. The current version is in the 2.1.x series (latest: 2.1.90).

## Key Developments (reverse chronological)

### 2026-04-02 -- Claude Code v2.1.90 (latest observed)
- **What**: Latest release includes `/powerup` interactive lessons, environment variable support for offline deployments, `.husky` directory protection, and fixes for rate-limit dialog infinite loops, format-on-save hook conflicts, and PowerShell permission hardening.
- **Significance**: Continued maturation of enterprise deployment features and security hardening.
- **Source**: https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md

### 2026-03-01 -- v2.1.89: Defer hook decision, named subagents
- **What**: Added `"defer"` permission decision for PreToolUse hooks (headless sessions can pause at tool calls), named subagents in `@` mention typeahead, `MCP_CONNECTION_NONBLOCKING=true` for pipe mode, `CLAUDE_CODE_NO_FLICKER=1` for flicker-free rendering, and `PermissionDenied` hook with retry capability.
- **Significance**: Critical for CI/CD pipeline integration -- headless sessions can now pause and resume at tool permission boundaries.
- **Source**: https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md

### 2026-02-06 -- Agent Teams (Swarm Mode) shipped with Opus 4.6
- **What**: Claude Code agent teams officially enabled alongside Opus 4.6 release. Transforms Claude Code from single-agent to multi-agent orchestration: a lead agent plans and delegates to specialist agents (frontend, backend, testing, docs, architecture) working in parallel via independent Git worktrees.
- **Significance**: Multi-agent coding is now a first-class feature, not experimental. Each agent gets a fresh context window, shares a task board with dependencies, and coordinates via inter-agent @mentions.
- **Source**: https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/

### 2026-02-06 -- February 2026 Feature Bundle
- **What**: Remote control (access live Claude Code sessions from browser/mobile), scheduled tasks (automate recurring workflows), plugin ecosystem (standardized skills and MCP integrations), auto memory (persistent project knowledge).
- **Significance**: Moves Claude Code from a dev tool to a full autonomous engineering platform.
- **Source**: https://www.nagarro.com/en/blog/claude-code-feb-2026-update-analysis

### 2025-08-01 -- Claude for Chrome Extension
- **What**: Google Chrome extension allowing Claude Code to directly control the browser.
- **Significance**: Extends Claude Code's reach beyond terminal into browser-based workflows.
- **Source**: https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/

## Technical Details

### Hooks System
Hooks guarantee execution of shell commands regardless of model behavior. Available hook types:
- **PreToolUse**: Runs before any tool call; can block, allow, or defer
- **PostToolUse**: Runs after tool execution; useful for audit logging
- **Stop**: Fires when the agent completes
- **SessionStart/SessionEnd**: Lifecycle hooks
- **UserPromptSubmit**: Pre-processes user input
- **PermissionDenied**: Fires after auto mode classifier denials; supports `{retry: true}`

### MCP Integration
Over 300 MCP integrations available. Claude Code can query databases, create Jira tickets, review GitHub PRs, check Sentry errors, and interact with any API -- all from natural language. MCP connections support nonblocking mode for pipe/headless sessions.

### IDE Integration
- VS Code: inline diffs, context sharing, side-by-side conversations
- JetBrains: equivalent integration
- Browser: Chrome extension for web automation

### Version History Pattern
- v2.1.x series (current)
- Regular releases addressing bugs, security hardening, performance
- Key performance focus: prompt cache hit rate optimization for Bedrock/Vertex/Foundry

### Agent Teams Architecture
- Lead agent: plans, delegates, synthesizes (does not write code directly)
- Specialist agents: each gets fresh context window focused on task
- Git worktrees: each agent works in independent worktree (no edit collisions)
- Task board: shared dependency tracking with @mention coordination
- Sweet spot: 2-5 teammates with 5-6 tasks each (Anthropic's production-tested recommendation)

## Comparison Notes

Google's equivalent is the Agent Development Kit (ADK) combined with Gemini Code Assist. Key differences:
- Claude Code is CLI-first; Gemini Code Assist is IDE-first
- Claude Code's agent teams use Git worktrees for isolation; Google ADK uses a different orchestration model
- MCP integration is deeper in Claude Code's ecosystem vs Google's broader Vertex AI agent framework
- Claude Code's 4% GitHub commit share indicates significantly higher developer adoption than competitors as of early 2026
