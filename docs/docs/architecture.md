---
sidebar_position: 2
title: Architecture
---

# System Architecture

## Seven-Phase Design

The system is built across seven sequential phases, each gating the next. Phases 1-4 build the core automation foundation; Phases 5-7 extend to multi-agent orchestration, edge deployment, and commercial AaaS.

```
Phase 0 --> Phase 1 --> Phase 2 --> Phase 3 --> Phase 4 --> Phase 5 --> Phase 6 --> Phase 7
Repo        Factory     Validator   AutoResearch  Closed      Topology    Edge AI     AaaS
setup       (M1-2)      + CI/CD     + Distill     loop        + Multi-    + Cloud-    Billing
(done)                  (M3-4)      (M5-6)        (M7+)       Agent       Edge        + HA
                                                              (M8-9)      (M10-11)    (M12+)
```

### Phase Status

| Phase | Goal | Status |
|-------|------|--------|
| 0 — Bootstrap | Repo structure, stubs | Complete |
| 1 — Meta-Agent Factory | Generate format-compliant Skills from natural language | Complete |
| 2 — Validator + CI/CD Gate | Objective quality gating, eval runner, adversarial tests | Complete |
| 3 — AutoResearch Optimizer | Unattended trigger rate optimization, async eval, Bayesian scoring | Core complete |
| 4 — Changeling Router + Closed Loop | Fully unattended factory-validate-optimize-deploy | Current |
| 5 — Topology-Aware Multi-Agent | TCI routing, Scrum team orchestration, watchdog circuit breaker | Pending |
| 6 — Edge AI + Cloud-Edge Hybrid | Talker-Reasoner, ONNX/GGUF packaging, OTA | Pending |
| 7 — AaaS Commercialization | Outcome billing, multi-tenancy, cross-regional HA, compliance | Pending |

## Full Stack Diagram

```
Commercial Layer (Phase 7)
+-- Multi-Tenant Billing Engine (Outcome-Based Pricing)
+-- Cross-Regional High-Availability (Taiwan, Japan)
+-- Compliance Audit Trail (ISO 27001 / APPI)
          |
Edge Integration Layer (Phase 6)
+-- Edge Talker (System 1) -- on-device, zero-latency
+-- Cloud Reasoner (System 2) -- async, deep reasoning
+-- Cloud-Edge State Synchronization (MQTT/gRPC)
          |
Orchestration Layer (Phase 5)
+-- Task Coupling Indexer (TCI) -- routes tasks before execution
+-- Track A: Multi-Agent Scrum (TCI < 0.35, parallelizable tasks)
+-- Track B: Monolithic Flagship (TCI >= 0.35, coupled tasks)
+-- Watchdog Circuit Breaker -- loop detection + token budget enforcement
          |
Automation Foundation (Phases 1-4)
+-- Meta-Agent Factory
+-- Skill Quality Validator
+-- AutoResearch Optimizer
+-- Agentic CI/CD Gate
+-- Changeling Router
```

## Pipeline Flow

The core pipeline (Phases 1-4) operates as a closed loop:

```
Human (requirements)
    |
    v
meta-agent-factory --> .claude/skills/<name>/SKILL.md
    |
    v
skill-quality-validator --> JSON report {trigger_rate, ci_lower, ci_upper}
    |-- posterior_mean >= 0.90, ci_lower >= 0.80 --> agentic-cicd-gate (deploy)
    +-- below threshold --> autoresearch-optimizer (auto-repair, <= 50 iterations)
```

## Task Coupling Index (TCI)

A 0.0-1.0 scalar computed **before** any multi-step task executes. Routes low-coupling tasks to a parallel Scrum team (Track A) and high-coupling tasks to a single flagship model (Track B), preventing the Sequential Penalty of naive multi-agent parallelism.

## Defensive Architecture

Production-grade safeguards for multi-agent systems:

- **Mandatory pre-execution reflection** for all destructive tool calls
- **Four-tier HITL gate** (Tier 0: none to Tier 3: synchronous human approval)
- **Watchdog circuit breaker** halts Dev-QA infinite loops before budget exhaustion
- **Mutually exclusive permissions** enforced by static analysis

## Directory Structure

```
.claude/
+-- agents/              # Agent definition .md files (16 agents)
+-- skills/              # Skill definitions (SKILL.md + scripts/ + references/)
+-- hooks/               # Lifecycle hooks: pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
+-- run_eval_async.py    # Primary eval runner (asyncio + semaphore + backoff)
+-- bayesian_eval.py     # Bayesian posterior + 95% credible intervals
+-- prompt_cache.py      # Semantic cache -- reduces API calls ~40%
+-- tci_compute.py       # Task Coupling Indexer for Phase 5
+-- flaky_detector.py    # Bayesian flaky test classifier
+-- splits.json          # Train (36) / Validation (18) split
+-- prompts/             # Fixed test prompts (test_1.txt ... test_54.txt)
+-- expected/            # Expected outputs for binary pass/fail
scripts/
+-- daily_*.sh           # Cron scripts for nightly agent fleet
+-- agent_review.sh      # Performance review dashboard
logs/
+-- *.log                # Daily agent run logs (30-day retention)
+-- performance/         # JSON performance records per agent per day
knowledge_base/
+-- agentic-ai/          # Researcher knowledge base
+-- steward-reviews/     # Project reviewer assessments
```
