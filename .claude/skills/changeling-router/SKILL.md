---
name: changeling-router
description: >
  Dynamically switches between expert role identities from the Changeling
  role library. See .claude/agents/changeling-router.md for the full agent
  definition.
tools:
  - Read
  - Glob
  - Grep
  - Task
model: claude-sonnet-4-6
---

# Changeling Router Skill

This skill routes incoming tasks to the correct expert role from the Changeling
role library at `~/.claude/@lib/agents/`. See `.claude/agents/changeling-router.md`
for the full routing logic including the two-phase classification system
(keyword match → semantic disambiguation) and context reset protocol.

## Available Roles (23)

accessibility-specialist, api-designer, backend-architect, cloud-architect,
compliance-officer, cost-analyst, database-administrator, data-engineer,
devops-specialist, frontend-expert, golang-expert, incident-commander,
ml-engineer, mobile-developer, network-engineer, perf-analyst, product-owner,
python-architect, qa-engineer, rust-expert, security-auditor,
site-reliability-engineer, technical-writer
