---
sidebar_position: 1
slug: /intro
title: Introduction
---

# Agent Skill Automation

An automated pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills — shifting Skill development from manual artisan labor to a continuously self-improving, commercially deployable system.

## The Problem

Managing a growing fleet of Claude Code agents means writing and maintaining many `SKILL.md` files by hand. Quality varies, trigger rates drift, and optimization is a linear, human-bottlenecked process. Specific pain points include:

- **Knowledge engineering as artisan labor**: Skill developers must manually write YAML frontmatter, tune system prompts, configure tool permissions, and test trigger rates — a full Skill development cycle routinely takes days
- **Quality consistency gap**: `SKILL.md` files authored by different engineers vary enormously in semantic trigger precision, security boundaries, and output format standardization
- **Manual optimization bottleneck**: Continuous improvement depends entirely on engineers proactively discovering problems, editing manually, and re-testing
- **Missing cross-agent coordination**: As the agent legion grows, no one manages task routing, context isolation, and model cost allocation at the system level

## The Solution

This project builds a **meta-level system** that automates the entire Skill lifecycle across seven phases:

```
Human requirement
    |
meta-agent-factory    ->  generates SKILL.md + agent configs
    |
skill-quality-validator  ->  measures trigger rate (binary eval)
    |
>= 90%? --> agentic-cicd-gate  ->  deploy
< 75%? --> autoresearch-optimizer  ->  auto-repair overnight -> re-validate
```

The optimization loop is a direct application of [Karpathy's AutoResearch pattern](https://github.com/karpathy/autoresearch): treat `SKILL.md` as the mutable asset, binary eval pass rate as the scalar metric, and a fixed test set as the evaluation budget. The agent reads, proposes changes, evaluates, and commits or reverts — unattended.

## Quick Start

```bash
# Review the current pipeline status
cat ROADMAP.md

# Run the eval suite against a skill
python eval/run_eval_async.py

# Check agent performance over the last 7 days
./scripts/agent_review.sh

# Run a full month review
./scripts/agent_review.sh 30
```

## Key Concepts

### Three-layer SKILL.md architecture

Every Skill file uses progressive disclosure to minimize token consumption:

| Layer | Contents | When loaded |
|-------|----------|-------------|
| Level 1 (YAML frontmatter) | `name`, `description`, `tools`, `model` | Always — this is the sole routing signal |
| Level 2 (Markdown body) | Full operational instructions, output templates, error handling | When the skill is triggered |
| Level 3 (`scripts/`, `references/`) | External data, helper scripts | Only when Level 2 explicitly directs it |

### Binary eval

Each test case is **1** (Skill triggered correctly AND output matches expected schema) or **0** (anything else). No partial credit. The fixed test set makes every version directly comparable.

### Bayesian scoring

True trigger rate is a distribution, not a point estimate. The system always uses posterior mean + 95% credible interval rather than raw pass rates.

### Mutually exclusive permissions

Each agent holds only the tools its role requires:
- Review/validation agents: no `Write` or `Edit`
- Execution agents: no `Task` (prevents infinite delegation chains)
- Enforced statically by `eval/check-permissions.sh`
