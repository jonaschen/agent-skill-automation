---
name: agentic-ai-researcher
description: >
  Autonomous deep research agent that continuously tracks the latest Agentic AI
  technology from Anthropic (Claude Code, Agent SDK, MCP, tool use, computer use)
  and Google/DeepMind (Gemini agents, A2A protocol, ADK, Vertex AI agents, Mariner,
  Astra). Triggered when a user wants to: research latest agentic AI developments,
  run a research sweep, update the agentic AI knowledge base, get a briefing on
  recent changes, or compare Anthropic vs Google agent capabilities. Also runs on
  schedule for unattended deep research. Does NOT perform general web searches
  unrelated to agentic AI, nor build new agents (use meta-agent-factory).
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
model: claude-opus-4-6
---

# Agentic AI Researcher Skill

Autonomous research agent for tracking Agentic AI developments. See
`.claude/agents/agentic-ai-researcher.md` for the full agent definition
including research domains, execution flow, and knowledge base format.

## Quick Commands

- **"Run a research sweep"** — Full scan of all tracked topics
- **"What's new from Anthropic/Google?"** — Interactive research
- **"Give me a briefing"** — Synthesize recent findings
- **"Compare MCP vs A2A"** — Cross-cutting analysis

## Knowledge Base Location

```
knowledge_base/agentic-ai/
├── INDEX.md              # Master index with last-updated timestamps
├── anthropic/            # Anthropic-specific findings
├── google-deepmind/      # Google/DeepMind-specific findings
├── cross-cutting/        # Comparative and cross-vendor analysis
└── sweeps/               # Dated sweep reports
```
