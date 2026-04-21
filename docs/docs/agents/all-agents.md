---
sidebar_position: 4
title: All Agents Reference
---

# Complete Agent Reference

## Phases 1-4: Automation Foundation

| Agent | Role | Model | Tools |
|-------|------|-------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 | Read, Write, Glob, Grep, Task |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 | Read, Bash, Grep |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 | Read, Write, Bash, Task |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 | Read, Bash, Grep, Glob |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 | Read, Glob, Grep, Task |

## Active Daily Agents

| Agent | Role | Schedule | Model |
|-------|------|----------|-------|
| `agentic-ai-researcher` | L1-L5 research sweep (Anthropic + Google) | 2am + 10am | Opus 4.6 |
| `agentic-ai-research-lead` | Reviews research output, writes priority directives | 3am + 11am | Opus 4.6 |
| `factory-steward` | Implements ADOPT items guided by directives, tunes pipeline | 4am + 12pm | Opus 4.6 |
| `ltc-steward` | Phase work on long-term-care-expert project | 8am | Opus 4.6 |

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

| Agent | Role | Model |
|-------|------|-------|
| `qa-log-reviewer` | Reads and analyzes log files for errors and anomalies | Read-only |
| `coverage-analyst` | Analyzes test coverage reports and identifies gaps | Read-only |
| `precommit-lint-executor` | Runs linting/formatting on staged files before commit | Sonnet 4.6 |
| `typescript-perf-reviewer` | Reviews TypeScript code for performance bottlenecks | Read-only |
| `python-code-reviewer` | Reviews Python code for quality, style (PEP 8), and idiomatic patterns | Read-only |

## Suspended Agents

| Agent | Suspended | Reason |
|-------|-----------|--------|
| `android-sw-steward` | 2026-04-17 | Resource reallocation |
| `arm-mrs-steward` | 2026-04-17 | Resource reallocation |
| `bsp-knowledge-steward` | 2026-04-17 | Resource reallocation |
| `project-reviewer` | 2026-04-17 | Resource reallocation |

## Permission Architecture

Agents are classified into permission classes that enforce the principle of least privilege:

**Orchestration class** (can delegate work):
- Has `Task` tool for spawning sub-agents
- Has `Write`/`Edit` for creating files

**Review/Validation class** (read-only assessment):
- Has `Read`, `Grep`, `Glob` for code inspection
- Has `Bash` for running eval scripts
- **No** `Write` or `Edit`

**Execution class** (performs work):
- Has `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`
- **No** `Task` (prevents infinite delegation chains)

These constraints are enforced statically by `eval/check-permissions.sh`.
