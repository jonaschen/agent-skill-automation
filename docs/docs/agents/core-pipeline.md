---
sidebar_position: 1
title: Core Pipeline Agents
---

# Core Pipeline Agents (Phases 1-4)

These five agents form the automation foundation that powers the Skill lifecycle from generation through deployment.

## Overview

| Agent | Role | Model | Permission Class |
|-------|------|-------|-----------------|
| `meta-agent-factory` | Generates SKILL.md, agent configs, MCP config from requirements | Opus 4.6 | Orchestration |
| `skill-quality-validator` | 5-step validation pipeline, JSON report, threshold verdict | Sonnet 4.6 | Review/Validation |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, convergence | Opus 4.6 | Orchestration |
| `agentic-cicd-gate` | Deployment gating, flaky detection, git rollback | Sonnet 4.6 | Review/Validation |
| `changeling-router` | Dynamic identity switching from role library | Sonnet 4.6 | Orchestration |

## meta-agent-factory

**Purpose**: Generates new Skill/Sub-agent/Changeling role definitions from natural language requirements.

**Trigger conditions**: Any request whose primary intent is to CREATE, BUILD, DEFINE, GENERATE, or ADD a new agent, Skill, persona, expert, or role.

**Pipeline stages**:
1. Requirements analysis
2. Architecture classification (Skill vs Sub-agent vs Role)
3. Permission design (mutually exclusive tool sets)
4. SKILL.md file generation with three-layer architecture
5. Validation handoff

**Outputs**: `.claude/skills/<name>/SKILL.md` or `.claude/agents/<name>.md`

## skill-quality-validator

**Purpose**: Objective quality measurement for Skill definitions.

**Pipeline**:
1. Static format validation (YAML frontmatter, required fields)
2. Permission compliance check (mutually exclusive rules)
3. Binary eval execution (trigger rate measurement)
4. Bayesian posterior computation (mean + 95% CI)
5. Threshold verdict: Pass / Conditional / Fail

**Output**: JSON report
```json
{
  "trigger_rate": 0.92,
  "ci_lower": 0.84,
  "ci_upper": 0.97,
  "security_score": 5,
  "verdict": "pass",
  "recommendations": []
}
```

**Thresholds**:
- **Pass**: posterior mean `>= 0.90`, ci_lower `>= 0.80`
- **Conditional**: posterior mean `>= 0.75`
- **Fail**: below 0.75

## autoresearch-optimizer

**Purpose**: Unattended Skill improvement using the AutoResearch pattern.

**How it works**:
1. Reads failing test cases from the Training split only
2. Analyzes failure patterns (false positives, false negatives, boundary misses)
3. Proposes description/instruction modifications
4. Runs evaluation against Training set
5. Applies Bayesian commit rule: `new_ci_lower > old_ci_upper`
6. Commits improvements or reverts and tries a different strategy
7. Repeats up to 50 iterations or until target reached

**Key constraints**:
- Only modifies the `description` field and Markdown body
- Never touches `tools:`, `model:`, or permission settings
- Only reads Training split failures (Validation is held out)
- Convergence verified with Bayesian CI non-overlap test

## agentic-cicd-gate

**Purpose**: Deployment quality enforcement.

**Gate conditions**:
- Bayesian posterior mean `>= 0.90`
- CI lower bound `>= 0.80`
- No flaky tests detected (via `eval/flaky_detector.py`)
- Permission compliance passes

**Capabilities**:
- Autonomous rollback on regression detection
- Flaky test isolation and flagging
- Change impact analysis

## changeling-router

**Purpose**: Dynamic identity switching for multi-persona workflows.

Loads role definitions from the Changeling role library (`~/.claude/@lib/agents/`) and switches the agent's behavior to match the required persona. Used when a task requires a specialized expert identity (security auditor, performance analyst, code reviewer, etc.).
