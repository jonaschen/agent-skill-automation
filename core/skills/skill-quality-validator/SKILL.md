---
name: Skill Quality Validator
description: Audits the technical quality and trigger accuracy of agent Skill definitions. See `core/agents/skill-quality-validator.md` for the full agent definition.
kind: local
subagent_tools: [read_file, write_file, replace, list_directory, grep_search, run_shell_command, subagent_*]
model: gemini-3-flash-preview
temperature: 0.1
---

# Skill Quality Validator Skill

Audits the technical quality and trigger accuracy of agent Skill definitions. See `core/agents/skill-quality-validator.md` for the full agent definition.
