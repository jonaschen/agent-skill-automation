---
kind: local
subagent_tools: [read_file, write_file, replace, list_directory, grep_search, run_shell_command, subagent_*]
model: gemini-3-flash-preview
temperature: 0.1
---

# AutoResearch Optimizer Skill

Autonomously optimizes failing agent Skills using the AutoResearch binary evaluation loop. See `core/agents/autoresearch-optimizer.md` for the full agent definition.
