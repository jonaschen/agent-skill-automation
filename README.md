# Agent Skill Automation

An automated pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills — shifting Skill development from manual artisan labor to a continuously self-improving, commercially deployable system.

## What This Is

Managing a growing fleet of Claude Code agents means writing and maintaining many SKILL.md files by hand. Quality varies, trigger rates drift, and optimization is a linear, human-bottlenecked process.

This project builds a **meta-level system** that automates the entire Skill lifecycle across seven phases — from single-agent automation through multi-agent orchestration, edge deployment, and commercial AaaS infrastructure.

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

## Seven-Phase Architecture

```
Commercial Layer (Phase 7)
├── Multi-Tenant Billing Engine (Outcome-Based Pricing)
├── Cross-Regional High-Availability (Taiwan, Japan)
└── Compliance Audit Trail (ISO 27001 / APPI)
          ↑
Edge Integration Layer (Phase 6)
├── Edge Talker (System 1) — on-device, zero-latency
├── Cloud Reasoner (System 2) — async, deep reasoning
└── Cloud-Edge State Synchronization (MQTT/gRPC)
          ↑
Orchestration Layer (Phase 5)
├── Task Coupling Indexer (TCI) — routes tasks before execution
├── Track A: Multi-Agent Scrum (TCI < 0.35, parallelizable tasks)
├── Track B: Monolithic Flagship (TCI ≥ 0.35, coupled tasks)
└── Watchdog Circuit Breaker — loop detection + token budget enforcement
          ↑
Automation Foundation (Phases 1–4)
├── Meta-Agent Factory
├── Skill Quality Validator
├── AutoResearch Optimizer
├── Agentic CI/CD Gate
└── Changeling Router
```

## Eleven Core Agents

**Phases 1–4 (Automation Foundation)**

| Agent | Role | Model |
|-------|------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 |

**Phase 5 (Orchestration Layer)**

| Agent | Role | Model |
|-------|------|-------|
| `topology-aware-router` | Computes TCI score, routes to Track A or Track B | Sonnet 4.6 |
| `scrum-team-orchestrator` | Manages parallel PO/Dev/QA Scrum team via A2A bus | Sonnet 4.6 |
| `watchdog-circuit-breaker` | Monitors token velocity and loop counts; halts runaway tasks | Haiku 4.5 |

**Phases 6–7 (Edge + Commercial)**

| Agent | Role | Model |
|-------|------|-------|
| `edge-talker-agent` | On-device System 1: zero-latency local inference | Distilled |
| `cloud-reasoner-agent` | Cloud System 2: async deep reasoning for escalated tasks | Opus 4.6 |
| `outcome-billing-engine` | Meters interactions, maps to billable outcome units | Sonnet 4.6 |

## Repository Structure

```
.claude/
├── agents/          # Agent definition files (YAML frontmatter + instructions)
├── skills/          # Skill definitions (SKILL.md + scripts/ + references/)
└── hooks/           # Lifecycle hooks: pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval_async.py    # Primary eval runner (asyncio + semaphore + backoff)
├── bayesian_eval.py     # Bayesian posterior + 95% credible intervals
├── prompt_cache.py      # Semantic cache — reduces API calls ~40% per iteration
├── tci_compute.py       # Task Coupling Indexer for Phase 5 topology routing
├── flaky_detector.py    # Bayesian flaky test classifier
├── splits.json          # Train (36) / Validation (18) split definition
├── check-permissions.sh # Static validator for mutually exclusive permission rules
├── prompts/             # Fixed test prompts (test_1.txt … test_54.txt)
└── expected/            # Expected outputs for binary pass/fail evaluation
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

**Task Coupling Index (TCI)** — a 0.0–1.0 scalar computed before any multi-step task executes. Routes low-coupling tasks to a parallel Scrum team (Track A) and high-coupling tasks to a single flagship model (Track B), preventing the Sequential Penalty of naive multi-agent parallelism.

**Defensive architecture** — production-grade safeguards for multi-agent systems:
- Mandatory pre-execution reflection for all destructive tool calls
- Four-tier HITL gate (Tier 0: none → Tier 3: synchronous human approval)
- Watchdog circuit breaker halts Dev-QA infinite loops before budget exhaustion

## Current Status

**Phase 3 in progress.** Phases 0-2 complete. Measurement infrastructure built and verified (Bayesian eval, async runner, semantic cache, T/V split). First optimizer iteration achieved Training posterior mean **0.921** CI [0.818, 0.983] and Validation **0.800** CI [0.604, 0.940] — exceeds the 0.90 deployment gate on training.

See [ROADMAP.md](ROADMAP.md) for full task tracking, measurement architecture, and next actions.

## Documentation

- [ROADMAP.md](ROADMAP.md) — Single source of truth: phases, tasks, measurement architecture, risks, lessons learned
- [AGENT_SKILL_AUTOMATION_DEV_PLAN.md](AGENT_SKILL_AUTOMATION_DEV_PLAN.md) — Full architecture blueprint (Phases 1-7)
- [README_AUTORESEARCH.md](README_AUTORESEARCH.md) — How Karpathy's AutoResearch pattern maps to this system
