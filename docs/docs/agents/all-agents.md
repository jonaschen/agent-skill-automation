---
sidebar_position: 4
title: All Agents Reference
---

# Complete Agent Reference

All seventeen agents across the seven-phase architecture.

## Phases 1-4: Automation Foundation

| Agent | Role | Model | Tools |
|-------|------|-------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 | Read, Write, Glob, Grep, Task |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 | Read, Bash, Grep |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 | Read, Write, Bash, Task |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 | Read, Bash, Grep, Glob |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 | Read, Glob, Grep, Task |

## Autonomous Steward Agents

| Agent | Target Project | Schedule | Model |
|-------|---------------|----------|-------|
| `agentic-ai-researcher` | This repo — knowledge base | 2:00 AM daily | Opus 4.6 |
| `android-sw-steward` | Android-Software (AOSP skill set) | 3:00 AM daily | Opus 4.6 |
| `arm-mrs-steward` | ARM MRS (AArch64 agent skills) | 4:00 AM daily | Opus 4.6 |
| `bsp-knowledge-steward` | BSP Knowledge Skill Sets | 5:00 AM daily | Opus 4.6 |
| `factory-steward` | This repo (pipeline self-improvement) | 12:00 PM + 9:00 PM daily | Opus 4.6 |
| `project-reviewer` | Reviews all 3 project stewards | 7:00 AM daily | Opus 4.6 |

## Phase 5: Orchestration Layer

| Agent | Role | Model |
|-------|------|-------|
| `topology-aware-router` | Computes TCI score, routes to Track A or Track B | Sonnet 4.6 |
| `sprint-orchestrator` | Manages parallel PO/Dev/QA Scrum team via A2A bus | Sonnet 4.6 |
| `watchdog-circuit-breaker` | Monitors token velocity and loop counts; halts runaway tasks | Haiku 4.5 |

## Phases 6-7: Edge + Commercial

| Agent | Role | Model |
|-------|------|-------|
| `edge-talker-agent` | On-device System 1: zero-latency local inference | Distilled |
| `cloud-reasoner-agent` | Cloud System 2: async deep reasoning for escalated tasks | Opus 4.6 |
| `outcome-billing-engine` | Meters interactions, maps to billable outcome units | Sonnet 4.6 |

## Utility Agents

These agents serve specialized operational roles:

| Agent | Role | Model |
|-------|------|-------|
| `qa-log-reviewer` | Reads and analyzes log files for errors and anomalies | Read-only |
| `precommit-lint-executor` | Runs linting/formatting on staged files before commit | Sonnet 4.6 |
| `typescript-perf-reviewer` | Reviews TypeScript code for performance bottlenecks | Read-only |

## Permission Architecture

Agents are classified into permission classes that enforce the principle of least privilege:

**Orchestration class** (can delegate work):
- Has `Task` tool for spawning sub-agents
- Has `Write`/`Edit` for creating files
- Cannot run arbitrary commands without `Bash`

**Review/Validation class** (read-only assessment):
- Has `Read`, `Grep`, `Glob` for code inspection
- Has `Bash` for running eval scripts
- **No** `Write` or `Edit` (cannot modify code)

**Execution class** (performs work):
- Has `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`
- **No** `Task` (cannot delegate, preventing infinite loops)

These constraints are enforced statically by `eval/check-permissions.sh`.
