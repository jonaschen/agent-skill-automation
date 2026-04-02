# Multi-Agent Patterns

**Last updated**: 2026-04-02
**Sources**:
- https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf
- https://zenvanriel.com/ai-engineer-blog/claude-code-swarms-multi-agent-orchestration/
- https://blog.imseankim.com/claude-code-team-mode-multi-agent-orchestration-march-2026/
- https://www.atcyrus.com/stories/what-is-claude-code-swarm-feature
- https://claude.com/blog/building-agents-with-the-claude-agent-sdk

## Overview

Anthropic has developed multi-agent orchestration patterns both in Claude Code (agent teams/swarm mode) and the Claude Agent SDK (subagents). The core architecture follows a lead-agent/specialist pattern where an orchestrator decomposes problems, delegates to specialized agents working in parallel with isolated context windows, and synthesizes results. As of March 2026, multi-agent orchestration is no longer experimental -- it shipped as a first-class Claude Code feature on February 6, 2026 alongside Opus 4.6.

## Key Developments (reverse chronological)

### 2026-03-01 -- 2026 Agentic Coding Trends Report
- **What**: Anthropic published a comprehensive report on agentic coding trends. Key finding: developers use AI in ~60% of work but can fully delegate only 0-20% of tasks. Multi-agent systems amplify the cost of ambiguity -- they multiply the need for clarity rather than reduce it.
- **Significance**: Establishes that multi-agent is production-real but the "delegation gap" remains the primary bottleneck.
- **Source**: https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf

### 2026-02-06 -- Claude Code Agent Teams Official Launch
- **What**: Multi-agent system officially enabled in Claude Code alongside Opus 4.6 release. Architecture: lead agent plans and delegates; specialist agents (frontend, backend, testing, docs, architecture) work in parallel via independent Git worktrees; task board with dependencies; inter-agent @mention coordination.
- **Significance**: Multi-agent coding transitions from hidden/experimental to default workflow. Production-tested sweet spot: 2-5 teammates with 5-6 tasks each.
- **Source**: https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/

### 2026-01-01 -- Hidden Multi-Agent System Discovered
- **What**: Security researchers found a fully-implemented multi-agent orchestration system inside Claude Code binary, feature-flagged off. Included TeammateTool and Delegate Mode for spawning background agents. Discovered via `claude-sneakpeek` binary inspection tool.
- **Significance**: Revealed Anthropic had been developing multi-agent capabilities for some time before official release.
- **Source**: https://paddo.dev/blog/claude-code-hidden-swarm/

### 2025-09-01 -- Agent SDK Subagent Pattern
- **What**: Claude Agent SDK formalized the subagent pattern: orchestrator spawns specialized agents via `AgentDefinition`, each with their own tools, prompt, and context window. Results reported back to parent.
- **Significance**: Provides the programmatic API for multi-agent patterns, complementing Claude Code's interactive approach.
- **Source**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk

## Technical Details

### Claude Code Agent Teams Architecture

**Lead Agent (Orchestrator)**:
- Does not write code directly
- Creates plan from user requirements
- Enters "delegation mode" when plan approved
- Creates specialist agents for specific roles
- Synthesizes results from all agents

**Specialist Agents**:
- Each gets a fresh, focused context window
- Works in independent Git worktree (no edit collisions)
- Shares task board with dependency tracking
- Communicates via inter-agent @mentions
- Worktrees with no changes automatically cleaned up

**Key Demo**: 16 agents collaborated to build a 100,000-line C compiler across 2,000 sessions.

### Agent SDK Subagent Pattern

```python
agents={
    "code-reviewer": AgentDefinition(
        description="Expert code reviewer",
        prompt="Analyze code quality.",
        tools=["Read", "Glob", "Grep"],
    ),
    "test-writer": AgentDefinition(
        description="Test generation specialist",
        prompt="Write comprehensive tests.",
        tools=["Read", "Write", "Bash"],
    )
}
```

Properties:
- Parallelization: multiple subagents run simultaneously
- Context isolation: each subagent has own context window
- Result aggregation: only relevant info returned to orchestrator
- Tracking: `parent_tool_use_id` links messages to parent

### Production Guidelines (from Anthropic)
- **Team size**: 2-5 teammates (>5 hits coordination overhead)
- **Task granularity**: 5-6 tasks per teammate
- **Scope clarity**: Each agent needs clear scope, success criteria, boundaries
- **Delegation gap**: Full delegation possible for only 0-20% of tasks; clarity is critical

### Orchestration Patterns

1. **Fan-out/Fan-in**: Orchestrator decomposes task, fans out to specialists, collects results
2. **Pipeline**: Sequential handoff between specialized agents (e.g., write -> review -> test)
3. **Collaborative**: Agents share a task board and coordinate through messaging
4. **Hierarchical**: Multi-level delegation (orchestrator -> sub-orchestrator -> workers)

### Cost Considerations
- Multiple agents = multiple model calls = higher API costs
- Productivity gains may offset cost increase for complex tasks
- Simple tasks remain more efficient with single-agent approaches

## Comparison Notes

Anthropic Multi-Agent vs Google ADK Multi-Agent:
- **Anthropic**: Tight integration with Claude Code (Git worktrees, task boards); SDK offers programmatic subagents
- **Google ADK**: Supports multi-agent via agent composition with routing agents, sequential agents, and parallel agents
- **Both**: Support orchestrator/specialist patterns and parallel execution
- **Key difference**: Anthropic's agent teams are deeply integrated into the coding workflow (worktrees, file ownership); Google's approach is more general-purpose

Anthropic vs A2A Protocol:
- Anthropic's multi-agent patterns are intra-ecosystem (Claude agents talking to Claude agents)
- A2A protocol (Google-originated) focuses on cross-vendor agent interoperability
- MCP focuses on model-to-tool; A2A focuses on agent-to-agent
- No current Anthropic-native A2A support, though MCP and A2A are designed to be complementary
