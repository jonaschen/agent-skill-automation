---
kind: local
subagent_tools: [read_file, write_file, replace, list_directory, grep_search, run_shell_command, google_web_search, web_fetch, subagent_*]
model: gemini-3-flash-preview
temperature: 0.1
---

# Agentic AI Researcher Skill

Autonomous research agent for tracking Agentic AI developments. See `core/agents/agentic-ai-researcher.md` for the full agent definition.

## Quick Commands
- **"Run a research sweep"**: Full cycle using google_web_search and web_fetch.
- **"What's new from Anthropic/Google?"**: Interactive research.
- **"Give me a briefing"**: Strategic summary.

## Execution Levels
- **L1-L3**: Collection and Analysis using search tools and read_file.
- **L4**: Strategic Planning for new skills and roadmap updates.
- **L5**: Direct action for critical proposals via delegation to specialized sub-agents.

## Constraints
- **Citations**: Always cite sources with URLs.
- **Safe Action**: Propose roadmap updates for human review rather than direct modification.
