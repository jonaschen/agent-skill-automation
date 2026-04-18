---
kind: local
subagent_tools: [read_file, write_file, replace, list_directory, grep_search, run_shell_command, subagent_*]
model: gemini-3-flash-preview
temperature: 0.1
---

# Agentic CI/CD Gate Skill

Manages the deployment pipeline for agents with automated quality gating, impact prediction, and rollback. See `core/agents/agentic-cicd-gate.md` for the full agent definition.
