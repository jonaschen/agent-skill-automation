# Agent Skill Automation

An automated pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills — shifting Skill development from manual artisan labor to a continuously self-improving system.

## What This Is

Managing a growing fleet of Claude Code agents means writing and maintaining many SKILL.md files by hand. Quality varies, trigger rates drift, and optimization is a linear, human-bottlenecked process.

This project builds a **meta-level system** that automates the entire Skill lifecycle:

```
Human requirement
    ↓
meta-agent-factory    →  generates SKILL.md + agent configs
    ↓
skill-quality-validator  →  measures trigger rate (binary eval)
    ↓
≥ 90%? ──→ agentic-cicd-gate  →  deploy
< 75%? ──→ autoresearch-optimizer  →  auto-repair overnight → re-validate
```

The optimization loop is a direct application of [Karpathy's AutoResearch pattern](https://github.com/karpathy/autoresearch): treat SKILL.md as the mutable asset, binary eval pass rate as the scalar metric, and a fixed test set as the evaluation budget. The agent reads, proposes changes, evaluates, and commits or reverts — unattended.

## Five Core Agents

| Agent | Role | Model |
|-------|------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 |

## Repository Structure

```
.claude/
├── agents/          # Agent definition files (YAML frontmatter + instructions)
├── skills/          # Skill definitions (SKILL.md + scripts/ + references/)
└── hooks/           # Lifecycle hooks: pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval.sh      # Binary eval runner — outputs a single float pass rate
├── check-permissions.sh  # Static validator for mutually exclusive permission rules
├── prompts/         # Fixed test prompts (test_1.txt … test_N.txt)
└── expected/        # Expected outputs for binary pass/fail evaluation
~/.claude/@lib/agents/   # Changeling role library (global, read-only)
```

## Key Concepts

**Three-layer SKILL.md architecture** — every Skill file uses progressive disclosure to minimize token consumption:
- Level 1 (YAML frontmatter): `name`, `description`, `tools`, `model` — the sole routing signal
- Level 2 (Markdown body): full operational instructions, output templates, error handling
- Level 3 (`scripts/`, `references/`): only loaded when Level 2 explicitly directs it

**Mutually exclusive permissions** — each agent holds only the tools its role requires:
- Review/validation agents: no `Write` or `Edit`
- Execution agents: no `Task` (prevents infinite delegation chains)
- Enforced statically by `eval/check-permissions.sh`

**Binary eval** — each test case is 1 (Skill triggered correctly AND output matches expected schema) or 0 (anything else). No partial credit. The fixed test set makes every version directly comparable.

## Current Status

Phase 0 complete, Phase 1 in progress. See [ROADMAP.md](ROADMAP.md) for current tasks and progress.

## Documentation

- [ROADMAP.md](ROADMAP.md) — Phased development plan with tasks and acceptance criteria
- [AGENT_SKILL_AUTOMATION_DEV_PLAN.md](AGENT_SKILL_AUTOMATION_DEV_PLAN.md) — Full architecture blueprint
- [README_AUTORESEARCH.md](README_AUTORESEARCH.md) — How Karpathy's AutoResearch pattern maps to this system
