# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains the design specification and development plan for an **Agent Skill Automation Pipeline** — a three-layer system for autonomously building, validating, optimizing, and deploying Claude Code Agent Skills.

**Current status:** Specification phase complete. Phase 0 (repository bootstrap) is the immediate next step — see `ROADMAP.md`.

## Key Documents

- `ROADMAP.md` — Actionable development roadmap with phased tasks, acceptance criteria, and immediate next actions
- `AGENT_SKILL_AUTOMATION_DEV_PLAN.md` — Full development blueprint (1057 lines): skill specs, detailed architecture, acceptance KPIs
- `README_AUTORESEARCH.md` — Explains how the AutoResearch pattern (from Karpathy) maps onto Skill optimization

## Architecture

### Three Layers

1. **Agentic CI/CD Validation Pipeline** — Trigger rate testing, hallucination detection, deployment gating
2. **Meta-Agent Factory** — Skill design, sub-agent generation, MCP configuration, file generation
3. **AutoResearch Evolution Engine** — Unattended Skill quality optimization via binary eval loops

### Five Planned Skill Roles

| Skill | Role | Model |
|-------|------|-------|
| `meta-agent-factory` | Entry point; generates SKILL.md, agent configs, MCP config | Opus 4.6 |
| `skill-quality-validator` | Static review, trigger rate testing, boundary evaluation | Sonnet 4.6 |
| `autoresearch-optimizer` | Binary eval loop, parallel version search, distillation | Opus 4.6 |
| `agentic-cicd-gate` | Deployment gating, change impact prediction, rollback | Sonnet 4.6 |
| `changeling-router` | Dynamic identity switching, multi-persona routing | Sonnet 4.6 |

### Skill File Structure (Three-Layer Architecture)

Every `SKILL.md` follows a progressive disclosure pattern to minimize token consumption:

- **Level 1 (YAML Frontmatter)**: `name`, `description`, `tools`, `model` — the sole LLM routing signal
- **Level 2 (Markdown body)**: Complete operational instructions, output templates, error handling
- **Level 3 (Scripts/References)**: External validation scripts and reference docs (accessed only when explicitly directed)

### Pipeline Flow

```
Human Developer (requirements)
    ↓
meta-agent-factory (design & generation)
    ├→ .claude/skills/<skill-name>/SKILL.md
    ├→ .claude/agents/<agent-name>.md
    └→ .mcp.json (MCP config)
    ↓
skill-quality-validator (trigger rate test)
    ├→ PASS (≥90%) → agentic-cicd-gate (deploy)
    └→ FAIL (<75%) → autoresearch-optimizer (auto-repair)
```

## Key Design Principles

- **Mutually exclusive permissions**: Each Skill holds minimum required tools — review agents are denied Write; execution agents are denied Task
- **Scalar metric-driven optimization**: Binary test pass rate (0/1 per test case) is the sole optimization objective
- **Deterministic scripts + non-deterministic reasoning hybrid**: Lifecycle Hooks enforce quality thresholds
- **Sandbox isolation**: Fresh isolated context per evaluation ensures comparability across Skill versions

## Core Terminology

| Term | Definition |
|------|------------|
| **Skill** | A standalone capability definition (SKILL.md) that augments an agent without independent context |
| **Sub-agent** | An independent agent with its own context window, delegatable via the Task tool |
| **Trigger rate** | % of test cases where the correct Skill is triggered AND output matches expected structure |
| **Binary eval** | Each test case returns 1 (pass) or 0 (fail) — no partial credit |
| **Changeling mode** | A single agent dynamically loading different role definitions for different tasks |
| **AutoResearch loop** | Iterative cycle: read → hypothesize → modify → evaluate → commit/revert |

## Directory Structure (target, after Phase 0)

```
.claude/
├── agents/          # Five core agent definition files
├── skills/          # Per-skill subdirectories (SKILL.md + scripts/ + references/)
└── hooks/           # pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval.sh      # Eval runner — prints a single float pass rate (critical Phase 2 artifact)
├── prompts/         # Fixed test prompts (test_1.txt … test_N.txt)
└── expected/        # Expected outputs for binary eval
~/.claude/@lib/agents/  # Changeling role library (read-only, global)
```

## Acceptance KPIs

- Trigger rate ≥ 90% for deployed Skills
- Optimization success rate ≥ 80% (raising failing Skills from <75% to ≥90%)
- End-to-end pipeline time ≤ 4 hours
- Zero mutually exclusive permission errors
- Autonomous optimization completion rate ≥ 70%
