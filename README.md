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

## Sixteen Core Agents

**Phases 1–4 (Automation Foundation)**

| Agent | Role | Model |
|-------|------|-------|
| `meta-agent-factory` | Generates new Skill/Sub-agent definitions from natural language | Opus 4.6 |
| `skill-quality-validator` | Static analysis + trigger rate measurement | Sonnet 4.6 |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search, model distillation | Opus 4.6 |
| `agentic-cicd-gate` | Deployment gating, flaky test detection, autonomous rollback | Sonnet 4.6 |
| `changeling-router` | Dynamic identity switching for multi-persona workflows | Sonnet 4.6 |

**Autonomous Steward Agents (Nightly Cron)**

| Agent | Target Project | Schedule | Model |
|-------|---------------|----------|-------|
| `agentic-ai-researcher` | This repo — knowledge base | 2:00 AM daily | Opus 4.6 |
| `android-sw-steward` | Android-Software (AOSP skill set) | 3:00 AM daily | Opus 4.6 |
| `arm-mrs-steward` | ARM MRS (AArch64 agent skills) | 4:00 AM daily | Opus 4.6 |
| `bsp-knowledge-steward` | BSP Knowledge Skill Sets | 5:00 AM daily | Opus 4.6 |
| `factory-steward` | This repo (pipeline self-improvement) | 9:00 PM daily | Opus 4.6 |

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
│   ├── agentic-ai-researcher.md     # Nightly: AI research sweep
│   ├── android-sw-steward.md        # Nightly: Android-Software steward
│   ├── arm-mrs-steward.md           # Nightly: ARM MRS steward
│   ├── bsp-knowledge-steward.md     # Nightly: BSP Knowledge steward
│   └── factory-steward.md           # Nightly: Factory self-improvement
├── skills/              # Skill definitions (SKILL.md + scripts/ + references/)
└── hooks/               # Lifecycle hooks: pre-deploy.sh, post-tool-use.sh, stop.sh
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
scripts/
├── daily_research_sweep.sh       # Cron: 2am — AI research sweep
├── daily_android_sw_steward.sh   # Cron: 3am — Android-Software steward
├── daily_arm_mrs_steward.sh      # Cron: 4am — ARM MRS steward
├── daily_bsp_knowledge_steward.sh # Cron: 5am — BSP Knowledge steward
├── daily_factory_steward.sh       # Cron: 9pm — Factory self-improvement
├── agent_review.sh               # Performance review dashboard (all 3 agents)
└── (other utility scripts)
logs/
├── *.log                         # Daily agent run logs (30-day retention)
└── performance/                  # JSON performance records per agent per day
knowledge_base/
└── agentic-ai/                   # Researcher knowledge base (sweeps, analysis, proposals)
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

## Nightly Agent Fleet

Five autonomous agents run every night via cron, each advancing a different project:

```
 9:00 PM ─── factory-steward ────────── Improves THIS repo: implements ADOPT items, tunes agents
                                         → /home/jonas/gemini-home/agent-skill-automation/
 2:00 AM ─── agentic-ai-researcher ──── Scans Anthropic + Google AI developments
                                         → knowledge_base/agentic-ai/
 3:00 AM ─── android-sw-steward ─────── Advances AOSP skill set (Phase 4 work)
                                         → /home/jonas/gemini-home/Android-Software/
 4:00 AM ─── arm-mrs-steward ────────── Advances AArch64 skill set (H8 orchestration)
                                         → /home/jonas/arm-mrs-2025-03-aarchmrs/
 5:00 AM ─── bsp-knowledge-steward ──── Advances BSP mentor skill sets (Phase 3/4)
                                         → /home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets/
```

Each run writes a performance JSON record to `logs/performance/`. Review all agents at once:

```bash
./scripts/agent_review.sh        # Last 7 days — success rate, duration, commits, test counts
./scripts/agent_review.sh 30     # Monthly view
```

**What the steward agents do autonomously:**

- **android-sw-steward**: Reads project docs, works on the next Phase 4 deliverable (`detect_dirty_pages.py`, `migration_impact.py`, `skill_lint.py`, L3 extension framework, A15 validation), researches AOSP updates, creates hindsight notes, expands the 100-case routing test suite
- **arm-mrs-steward**: Reads project docs, designs H8 multi-agent orchestration (Developer/Critic/Judge/Executor), expands T32/A32 instruction coverage, adds GIC/CoreSight/PMU data, grows the 292-test eval suite, tracks ARM spec releases
- **bsp-knowledge-steward**: Reads project docs, completes Phase 3 exit criteria (Blackboard eval, Socratic templates, learner-level detection), starts Phase 4 deliverables (knowledge sedimentation, CI/CD, base graph maintenance), expands the 501-node Kuzu knowledge graph with new ARM/Linux BSP specs
- **factory-steward**: Owns this repo. Implements ADOPT items from the researcher's Innovator-vs-Engineer discussions, tunes underperforming agents based on `agent_review.sh` data, improves eval infrastructure, advances the ROADMAP
- **agentic-ai-researcher**: Runs L1–L5 pipeline (collect → analyze → discuss → plan → act), writes sweep reports, proposes skill/roadmap updates

## Current Status

**Phase 3 in progress.** Phases 0-2 complete. Measurement infrastructure built and verified (Bayesian eval, async runner, semantic cache, T/V split). First optimizer iteration achieved Training posterior mean **0.921** CI [0.818, 0.983] and Validation **0.800** CI [0.604, 0.940] — exceeds the 0.90 deployment gate on training.

See [ROADMAP.md](ROADMAP.md) for full task tracking, measurement architecture, and next actions.

## Documentation

- [ROADMAP.md](ROADMAP.md) — Single source of truth: phases, tasks, measurement architecture, risks, lessons learned
- [AGENT_SKILL_AUTOMATION_DEV_PLAN.md](AGENT_SKILL_AUTOMATION_DEV_PLAN.md) — Full architecture blueprint (Phases 1-7)
- [README_AUTORESEARCH.md](README_AUTORESEARCH.md) — How Karpathy's AutoResearch pattern maps to this system

## Managed Projects

This repo's steward agents autonomously maintain three external projects:

| Project | Repo | Agent | Current Focus |
|---------|------|-------|--------------|
| Android-Software | `/home/jonas/gemini-home/Android-Software/` | `android-sw-steward` | Phase 4: dirty page detection, migration impact, A15 validation |
| ARM MRS | `/home/jonas/arm-mrs-2025-03-aarchmrs/` | `arm-mrs-steward` | H8: multi-agent orchestration, data expansion (T32/A32, GIC, PMU) |
| BSP Knowledge | `/home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets/` | `bsp-knowledge-steward` | Phase 3 exit + Phase 4: knowledge graph expansion, ITS mentor validation |
