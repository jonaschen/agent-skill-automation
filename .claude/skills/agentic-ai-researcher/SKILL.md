---
name: agentic-ai-researcher
description: >
  Autonomous deep research agent that continuously tracks the latest Agentic AI
  technology from Anthropic (Claude Code, Agent SDK, MCP, tool use, computer use)
  and Google/DeepMind (Gemini agents, A2A protocol, ADK, Vertex AI agents, Mariner,
  Astra). Triggered when a user wants to: research latest agentic AI developments,
  run a research sweep, update the agentic AI knowledge base, get a briefing on
  recent changes, compare Anthropic vs Google agent capabilities, or generate
  strategic plans for new skills and pipeline improvements based on findings.
  Also runs on schedule for unattended deep research with gap analysis, skill
  proposals, and auto-creation of Changeling roles. Does NOT perform general
  web searches unrelated to agentic AI.
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

- **"Run a research sweep"** — Full L1-L5 cycle (collect → analyze → plan → act)
- **"What's new from Anthropic/Google?"** — Interactive research with analysis
- **"Give me a briefing"** — Strategic summary with pending proposals
- **"Compare MCP vs A2A"** — Cross-cutting analysis
- **"What skills should we build next?"** — Review proposals from latest sweep
- **"Show me pending proposals"** — List all unreviewed skill/roadmap proposals

## Research Levels

| Level | Capability | Output |
|-------|-----------|--------|
| L1: Collect | Web search + fetch | KB topic files |
| L2: Analyze | Pattern recognition | analysis/ reports |
| L3: Synthesize | Original insights | Cross-domain connections |
| L4: Plan | Strategic proposals | proposals/ with priority |
| L5: Act | Auto-create roles, ready-to-execute prompts | actions/ log |

## Knowledge Base Location

```
knowledge_base/agentic-ai/
├── INDEX.md              # Master index with last-updated timestamps
├── anthropic/            # Anthropic-specific findings
├── google-deepmind/      # Google/DeepMind-specific findings
├── cross-cutting/        # Comparative and cross-vendor analysis
├── sweeps/               # Dated sweep reports
├── analysis/             # Deep analysis (L2-L3) — gap analysis, threats, opportunities
├── proposals/            # Skill & roadmap proposals (L4) — awaiting human review
│   └── ready/            # Ready-to-execute meta-agent-factory prompts
└── actions/              # Action log (L5) — what was auto-created
```
