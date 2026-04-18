---
name: Changeling Router
description: This skill routes incoming tasks to the correct expert role identity from the role library. See `core/agents/changeling-router.md` for the full agent definition including the two-phase classification system and context reset protocol.
kind: local
subagent_tools: [read_file, write_file, replace, list_directory, grep_search, run_shell_command, subagent_*]
model: gemini-3-flash-preview
temperature: 0.1
---

# Changeling Router Skill

This skill routes incoming tasks to the correct expert role identity from the role library. See `core/agents/changeling-router.md` for the full agent definition including the two-phase classification system and context reset protocol.

## Execution Flow

1. **Catalog Available Roles**: Read role definitions using search tools.
2. **Task Classification**: Scan task text against the routing table.
3. **Semantic Disambiguation**: Score alignment using read_file.
4. **Role Activation**: Adopt identity and execute task under persona.
5. **Context Reset**: Discard previous role context on switch.

## Constraints
- **Read-only**: Never create, modify, or delete role files.
- **One role at a time**: Never blend capabilities.
- **No role invention**: Only assume existing roles.
