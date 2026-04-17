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

## Core Agents

**Phases 1–4 (Automation Foundation)**

| Agent | Role | Model |
|-------|------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 |

**Active Daily Agents (Two Research Cycles + LTC)**

| Agent | Role | Schedule | Model |
|-------|------|----------|-------|
| `agentic-ai-researcher` | L1–L5 research sweep (Anthropic + Google) | 2am + 10am | Opus 4.6 |
| `agentic-ai-research-lead` | Reviews research output, writes priority directives | 3am + 11am | Opus 4.6 |
| `factory-steward` | Implements ADOPT items guided by directives, tunes pipeline | 4am + 12pm | Opus 4.6 |
| `ltc-steward` | Phase work on long-term-care-expert project | 8am | Opus 4.6 |

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
├── agents/              # Agent definition files (YAML frontmatter + instructions)
│   ├── (5 core pipeline agents)
│   ├── agentic-ai-researcher.md     # 2x/day: AI research sweep
│   ├── agentic-ai-research-lead.md  # 2x/day: Strategic research director
│   ├── factory-steward.md           # 2x/day: Pipeline self-improvement
│   ├── ltc-steward.md              # Daily: Long-term-care-expert steward
│   └── (suspended agent definitions preserved for reactivation)
├── skills/              # Skill definitions (SKILL.md + scripts/ + references/)
└── hooks/               # Lifecycle hooks: pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval_async.py    # Primary eval runner (asyncio + semaphore + backoff)
├── bayesian_eval.py     # Bayesian posterior + 95% credible intervals
├── prompt_cache.py      # Semantic cache — reduces API calls ~40% per iteration
├── flaky_detector.py    # Bayesian flaky test classifier
├── splits.json          # Train (39) / Validation (20) split definition
├── check-permissions.sh # Static validator for mutually exclusive permission rules
├── prompts/             # Fixed test prompts (test_1.txt … test_59.txt)
└── expected/            # Expected outputs for binary pass/fail evaluation
scripts/
├── daily_research_sweep.sh       # Cron: 2am+10am — AI research sweep
├── daily_research_lead.sh        # Cron: 3am+11am — Research direction
├── daily_factory_steward.sh      # Cron: 4am+12pm — Pipeline improvement
├── daily_ltc_steward.sh          # Cron: 8am — LTC steward
├── agent_review.sh               # Performance review dashboard
└── (suspended scripts preserved for manual use)
logs/
├── *.log                         # Daily agent run logs (30-day retention)
└── performance/                  # JSON performance records per agent per day
knowledge_base/
└── agentic-ai/                   # Research knowledge base
    ├── directives/               # Research-lead priority directives
    ├── sweeps/                   # Daily sweep reports
    ├── analysis/                 # Deep analysis
    ├── discussions/              # Innovator-Engineer debates
    └── proposals/                # Strategic proposals
~/.claude/@lib/agents/            # Changeling role library (global, read-only)
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

**Research direction loop** — a three-agent cycle runs twice daily:
- `agentic-ai-researcher` produces L1–L5 findings (sweeps, analysis, discussions, proposals)
- `agentic-ai-research-lead` reviews output quality, sets P0/P1/P2 priorities via directives
- `factory-steward` implements ADOPT items, guided by the research-lead's directives
- Directives feed back into the researcher's next sweep, closing the loop

## Daily Agent Fleet

Two research cycles run daily, plus an independent LTC steward session:

```
Night Cycle:
 2:00 AM ─── researcher ──────── L1-L5 sweep (reads prior directive)
 3:00 AM ─── research-lead ───── Reviews output, writes priority directive
 4:00 AM ─── factory-steward ─── Implements ADOPT items guided by directive

Morning Cycle:
10:00 AM ─── researcher ──────── L1-L5 sweep (reads prior directive)
11:00 AM ─── research-lead ───── Reviews output, writes priority directive
12:00 PM ─── factory-steward ─── Implements ADOPT items guided by directive

Independent:
 8:00 AM ─── ltc-steward ─────── Phase work on long-term-care-expert
```

Each run writes a performance JSON record to `logs/performance/`. Review all agents:

```bash
./scripts/agent_review.sh        # Last 7 days
./scripts/agent_review.sh 30     # Monthly view
```

## Current Status

**Phase 4 core complete.** 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Focus: agentic AI research, agent development, and applications.

See [ROADMAP.md](ROADMAP.md) for full task tracking, measurement architecture, and next actions.

## Documentation

- [ROADMAP.md](ROADMAP.md) — Single source of truth: phases, tasks, measurement architecture, risks, lessons learned
- [AGENT_SKILL_AUTOMATION_DEV_PLAN.md](AGENT_SKILL_AUTOMATION_DEV_PLAN.md) — Full architecture blueprint (Phases 1-7)
- [README_AUTORESEARCH.md](README_AUTORESEARCH.md) — How Karpathy's AutoResearch pattern maps to this system
