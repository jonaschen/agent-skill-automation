# Enterprise-Grade Agent Skill Set Automation Development & Evolution Pipeline
## Meta-Agent Factory × AutoResearch Optimization Engine — Development Plan & Blueprint (Phases 1–7)

> **Document Version:** v2.0
> **Created:** 2026-03-23
> **Last Updated:** 2026-03-29 (merged AGENT_SKILL_AUTOMATION_UPGRADE_PLAN.md v1.1)
> **Reference:** Enterprise AI Agent Legion Architecture & Automation Pipeline: A Deep Research Report on Meta-Agent Ecosystems Based on Claude Code Skills and AutoResearch
> **Audience:** AI Agent Platform Development Team, System Architects, DevOps Engineers, Edge AI Engineers, Platform Ops

---

## Table of Contents

1. [Strategic Background & Development Intent](#1-strategic-background--development-intent)
2. [Complete System Architecture (Phases 1–7)](#2-complete-system-architecture-phases-17)
3. [Skill Set Overall Architecture](#3-skill-set-overall-architecture)
4. [Core Skill Specifications — Phases 1–4](#4-core-skill-specifications--phases-14)
5. [Extended Skill Specifications — Phases 5–7](#5-extended-skill-specifications--phases-57)
6. [Seven-Phase Development Blueprint](#6-seven-phase-development-blueprint)
7. [Technology Stack & Toolchain](#7-technology-stack--toolchain)
8. [Meta-Agent Factory Five-Stage Pipeline Design](#8-meta-agent-factory-five-stage-pipeline-design)
9. [AutoResearch Optimization Engine Design](#9-autoresearch-optimization-engine-design)
10. [Agentic CI/CD Validation Pipeline](#10-agentic-cicd-validation-pipeline)
11. [Defensive Architecture: Cascade Hallucination Prevention & Infinite Loop Containment](#11-defensive-architecture-cascade-hallucination-prevention--infinite-loop-containment)
12. [Milestones & Acceptance Criteria](#12-milestones--acceptance-criteria)
13. [Risk Management Matrix](#13-risk-management-matrix)
14. [Appendix A: SKILL.md Authoring Standards & Templates](#14-appendix-a-skillmd-authoring-standards--templates)
15. [Appendix B: TCI Algorithm Specification & Topology Decision Tree](#15-appendix-b-tci-algorithm-specification--topology-decision-tree)

---

## 1. Strategic Background & Development Intent

### 1.1 Problem Statement

When enterprises deploy AI Agent ecosystems, they face a fundamental scaling bottleneck: **every new Skill or Sub-agent still depends heavily on manual design, hand configuration, and trial-and-error iteration**. Specific pain points include:

- **Knowledge engineering as artisan labor**: Skill developers must manually write YAML Frontmatter, tune system prompts, configure tool permissions, and test trigger rates — a full Skill development cycle routinely takes days
- **Quality consistency gap**: SKILL.md files authored by different engineers vary enormously in semantic trigger precision, security boundaries on tool restrictions, and output format standardization — making the overall agent legion's behavior unpredictable
- **Manual optimization bottleneck**: Continuous improvement of existing Skills depends entirely on engineers proactively discovering problems, editing manually, and re-testing — a linear workflow that cannot scale
- **Missing cross-agent coordination**: As the agent legion grows to dozens of agents, no one is managing task routing, context isolation, and model cost allocation at the system level

### 1.2 Development Intent

This plan aims to build a **meta-level system capable of autonomously designing, deploying, validating, and continuously optimizing other Agent Skills**, achieving the paradigm shift from labor-intensive to fully automated:

```
Target Architecture: A Three-in-One Automated Closed Loop

Layer 3: AutoResearch Evolution Engine
         ↑ Unattended Skill quality optimization, model distillation, parallel experiments
Layer 2: Meta-Agent Factory
         ↑ Skill design, Sub-agent generation, MCP configuration, file writing
Layer 1: Agentic CI/CD Validation Pipeline
         ↑ Trigger rate testing, hallucination detection, Bayesian flakiness analysis, deployment gating
```

### 1.3 Strategic Evolution: Beyond Phase 4

By the end of Phase 4, the system is capable of autonomously designing, deploying, validating, and continuously optimizing individual Agent Skills. The Meta-Agent Factory generates format-compliant Skills from natural language requirements. The AutoResearch loop improves trigger rates overnight without human intervention. The CI/CD gate enforces quality thresholds before deployment. The Changeling Router enables a single agent instance to assume multiple personas on demand.

This is a highly capable single-soldier system. Every Skill is sharp. Every agent operates with precision within its defined boundary. The automation pipeline from requirements input to deployment runs in under four hours.

What it cannot yet do is operate as a coordinated team at scale, make intelligent decisions about when team coordination helps versus hurts, survive disconnected from cloud infrastructure, or sustain a commercial service relationship with enterprise customers across multiple regions and regulatory jurisdictions. Three problems remain:

**Problem 1 — From Solo Agent to Coordinated Team, With Topology Intelligence**

Naive multi-agent systems create a new failure mode: the Sequential Penalty. When a task has deep cross-module dependencies, routing it to a Scrum team of parallel agents generates massive inter-agent communication overhead, context fragmentation, and state synchronization errors. The agents spend more time coordinating than executing. The correct architecture is not always multi-agent — sometimes a single flagship model with a long context window is faster, cheaper, and more accurate. The system must develop the intelligence to know which topology to use before committing to either.

**Problem 2 — From Cloud-Only to Cloud-Edge Hybrid**

The distillation work in Phase 3 produces lightweight models capable of running on constrained hardware. But producing a distilled model and deploying it to an edge device are two entirely different engineering problems. Edge devices have no reliable network, limited memory, no GPU, and security requirements that prevent cloud API calls for sensitive data. A production system that cannot operate at the edge cannot serve industrial IoT, medical device, on-premises enterprise, or consumer hardware markets.

**Problem 3 — From Technical Platform to Commercial Service**

A technically excellent system that cannot bill customers, maintain service agreements, produce compliance audit trails, or scale across jurisdictions is not a commercial product. It is a proof of concept. Phase 7 exists to close this gap: to build the billing engine, the multi-tenancy layer, the compliance infrastructure, and the regional deployment architecture that turns the agent platform into an Agent-as-a-Service business.

### 1.4 Core Design Principles

| Principle | Description |
|-----------|-------------|
| **Skills define agent boundaries** | An agent's capability boundary is strictly defined by its Skill set, not by vague general LLM reasoning |
| **Progressive disclosure first** | Three-layer architecture minimizes token consumption; core descriptions stay statically fixed, maximizing cache hit rate |
| **Deterministic scripts + non-deterministic reasoning hybrid** | Lifecycle Hooks enforce quality thresholds — behavior is not constrained by natural language prompts alone |
| **Mutually exclusive permissions principle** | Each Skill holds only the minimum tool set required for its responsibility; generation agents do not hold review agent permissions |
| **Scalar metric-driven optimization** | The AutoResearch engine uses binary test pass rate as the sole objective reward function, eliminating subjective judgment |
| **Sandbox isolation guarantees comparability** | Every Skill version evaluation runs in a fresh isolated context, ensuring absolute fairness across version comparisons |
| **Topology before execution** | No multi-agent task is dispatched before the Task Coupling Indexer has computed a TCI score and selected a topology track. Execution never precedes routing. |
| **Defensive architecture is not optional** | Every agent interaction that can modify state, consume budget, or call external services must pass through a deterministic guard — a Watchdog, a circuit breaker, or a mandatory pre-execution reflection step. Optimism is a liability in production. |
| **Edge-first privacy by default** | Any data that can be processed locally must be processed locally. Cloud escalation is the exception, not the baseline. Sensitive data never crosses a regional boundary without explicit architectural justification. |

---

## 2. Complete System Architecture (Phases 1–7)

```
Commercial Layer (Phase 7)
├── Multi-Tenant Billing Engine (Outcome-Based Pricing)
├── Cross-Regional High-Availability Deployment
├── SSO / Enterprise Permission Management
└── Compliance Audit Trail (ISO 27001 / APPI)
          ↑
Edge Integration Layer (Phase 6)
├── Edge Talker (System 1) — on-device, zero-latency
├── Cloud Reasoner (System 2) — async, deep reasoning
├── Cloud-Edge State Synchronization (MQTT/gRPC)
└── BSP Integration for Hardware-Accelerated Inference
          ↑
Orchestration Layer (Phase 5)
├── Task Coupling Indexer (TCI)
├── Topology Router — Track A (Multi-Agent) / Track B (Monolithic Flagship)
├── A2A Communication Bus
└── Watchdog Process + Token Budget Circuit Breaker
          ↑
Automation Foundation (Phases 1–4)
├── Meta-Agent Factory
├── Skill Quality Validator
├── AutoResearch Optimizer
├── Agentic CI/CD Gate
└── Changeling Router
```

---

## 3. Skill Set Overall Architecture

### 3.1 Complete Skill Inventory (Phases 1–7)

```
Agent Skill Automation Skill Set
│
├── [Phases 1–4 — Automation Foundation]
│   ├── 🏭 [ORCHESTRATOR] meta-agent-factory
│   │   └── Requirements analysis, architecture design, Skill/Sub-agent generation, MCP config, directory writes
│   │
│   ├── 🧪 [VALIDATOR] skill-quality-validator
│   │   └── SKILL.md static analysis, trigger rate evaluation, boundary condition testing, hallucination detection
│   │
│   ├── 🔄 [OPTIMIZER] autoresearch-optimizer
│   │   └── Binary eval loop, parallel version search, instruction distillation, model adaptation tuning
│   │
│   ├── 🚦 [CICD] agentic-cicd-gate
│   │   └── Change impact prediction, flaky test isolation, deployment gating, autonomous rollback
│   │
│   └── 🎭 [UTILITY] changeling-router
│       └── Dynamic identity switching, single-agent multi-persona routing, context window efficiency optimization
│
├── [Phase 5 — Orchestration Layer]
│   ├── 🔀 [ROUTER] topology-aware-router
│   │   └── TCI computation, Dual-Track routing, monolithic flagship escalation
│   │
│   ├── 🤝 [ORCHESTRATOR] scrum-team-orchestrator
│   │   └── A2A communication bus, PO/Dev/QA agent coordination, sprint execution
│   │
│   └── 🐕 [GUARDIAN] watchdog-circuit-breaker
│       └── Loop detection, token budget monitoring, forced thread termination, HITL escalation
│
├── [Phase 6 — Edge Integration Layer]
│   ├── 📡 [EDGE] edge-talker-agent
│   │   └── On-device NLU, sensor data filtering, local state management, async cloud escalation
│   │
│   └── ☁️  [EDGE] cloud-reasoner-agent
│       └── Deep reasoning for escalated tasks, knowledge retrieval, Track B processing for edge
│
└── [Phase 7 — Commercial Layer]
    └── 💰 [OPS] outcome-billing-engine
        └── Interaction metering, outcome-based billing, token cost/margin dashboard
```

### 3.2 Skill Interaction Diagram (Phases 1–4 Core Pipeline)

```
Human Developer (natural language requirement)
    │
    ▼
meta-agent-factory (entry, design, generation)
    │
    ├──(generate new Skill)──→ .claude/skills/<skill-name>/SKILL.md
    │                                   │
    │                                   ▼
    ├──(generate new Sub-agent)──→ .claude/agents/<agent-name>.md
    │                                   │
    │                                   ▼
    └──(configure MCP)──→ .mcp.json (external data pipeline linkage)
                                   │
                                   ▼
                   skill-quality-validator (trigger rate test, static analysis)
                                   │
                             ┌─────┴──────┐
                             │            │
                           PASS          FAIL
                             │            │
                             ▼            ▼
                   agentic-cicd-gate   autoresearch-optimizer
                   (deployment gate)   (auto-repair loop)
                             │            │
                             │            └──→ (re-enters validation after revision)
                             ▼
                   Deploy to agent legion
```

---

## 4. Core Skill Specifications — Phases 1–4

### 4.1 Skill: `meta-agent-factory` (Meta-Agent Factory)

**Role:** System entry point, agent designer, Skill generator, MCP configurator

**YAML Frontmatter Design:**

```yaml
---
name: meta-agent-factory
description: >
  Designs and generates new Claude Agent Skills or Sub-agent definition files.
  Triggered when a user describes a need for a new AI agent capability, wants to
  build workflow automation, needs to configure a domain-specific expert agent,
  or wants to instantiate an existing role as an agent.
  Covers: requirements analysis → architecture classification → permission design
  → SKILL.md generation → MCP configuration.
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Task
model: claude-opus-4-6
---
```

**Core Capabilities:**

- Determine whether a requirement calls for a Sub-agent (independent context and identity) or a Skill (knowledge augmentation attached to the conversation)
- Design semantically precise trigger descriptions for each task type, ensuring high future routing accuracy
- Enforce the mutually exclusive permissions principle: review agents denied Write; architect agents granted Task; execution agents denied Task
- Automatically detect required external data connections for new agents and update `.mcp.json` to register services
- Support Changeling mode: write role definitions to the read-only `~/.claude/@lib/agents/` repository

**Five-Stage Generation Flow (see Section 8 for detail):**

```
① Analyze (requirements analysis) → ② Design (architecture classification) → ③ Configure (permission setup)
→ ④ Generate (file write) → ⑤ Register (MCP integration)
```

**Example Trigger Prompts:**

```
"I need an agent specifically for reviewing TypeScript performance"
"Build me a Skill for an AOSP integration expert"
"Create a QA agent that can only read logs"
"I want a coordinating agent in the Scrum Master role"
```

**Tool Usage Rules:**

| Tool | Purpose | Constraints |
|------|---------|-------------|
| `Read` | Read existing Skills/Agents as reference templates | None |
| `Write` | Write new SKILL.md to the appropriate directory | Restricted to `.claude/` directory tree |
| `Glob` | Scan existing agent list to prevent naming conflicts | None |
| `Grep` | Search existing Skill descriptions to avoid semantic overlap | None |
| `Task` | Delegate validation work to skill-quality-validator | Only after generation is complete |

---

### 4.2 Skill: `skill-quality-validator` (Skill Quality Validator)

**Role:** Static quality review, trigger rate testing, boundary condition evaluation, hallucination risk detection

**YAML Frontmatter Design:**

```yaml
---
name: skill-quality-validator
description: >
  Validates the quality of a SKILL.md file, including semantic precision of the
  trigger description, tool permission security review, and output format consistency.
  Triggered after a new Skill is generated, after a Skill is modified, or when
  an existing Skill's health needs to be assessed. Executes trigger rate tests
  and boundary condition evaluation.
tools:
  - Read
  - Bash
  - Grep
model: claude-sonnet-4-6
---
```

**Core Capabilities:**

- **Static analysis**: Parse the YAML Frontmatter `description` field to evaluate semantic trigger precision (over-triggering vs. under-triggering)
- **Dynamic trigger rate testing**: Generate boundary condition test sets (including spelling variants, ambiguous semantics, cross-domain semantics) and measure LLM routing accuracy
- **Security audit**: Automatically detect mutually exclusive permission violations (e.g., a review agent holding Write, an execution agent holding Task)
- **Hallucination risk scoring**: Based on the Skill's tool configuration and operational instructions, identify high-risk non-deterministic output patterns

**Validation Pipeline:**

```
Input: Target SKILL.md file path
    │
    ├── Step 1: Frontmatter parse (format compliance, field completeness, token budget)
    │
    ├── Step 2: Description quality evaluation (trigger keyword density, action verb coverage, example sufficiency)
    │
    ├── Step 3: Generate test prompt set (60% training / 40% validation, including boundary conditions)
    │
    ├── Step 4: Baseline measurement (run without Skill loaded; record token consumption and failure rate)
    │
    ├── Step 5: Trigger rate measurement (mount Skill and run validation set; calculate hit rate)
    │
    └── Output: JSON validation report (trigger rate, security score, improvement recommendations)
```

**Trigger Rate Judgment Criteria:**

| Trigger Rate | Verdict | Next Action |
|--------------|---------|-------------|
| ≥ 90% | ✅ Pass | Forward to agentic-cicd-gate for deployment |
| 75% – 89% | ⚠️ Conditional pass | Log warning; recommend optimization but allow deployment |
| < 75% | ❌ Fail | Trigger autoresearch-optimizer for automatic repair |

---

### 4.3 Skill: `autoresearch-optimizer` (AutoResearch Optimization Engine)

**Role:** Unattended Skill quality optimization loop, automated prompt engineering, heterogeneous model distillation

**YAML Frontmatter Design:**

```yaml
---
name: autoresearch-optimizer
description: >
  Runs automatic optimization on SKILL.md files that have not met quality thresholds.
  Receives under-performing Skills and their failing test cases, runs parallel version
  experiments in an isolated sandbox, and uses a binary eval loop to find the
  highest-pass-rate version. Can also perform lightweight model distillation to
  produce optimal instructions for lower-cost models.
tools:
  - Read
  - Write
  - Bash
  - Task
model: claude-opus-4-6
---
```

**Core Optimization Strategies (see Section 9 for detail):**

- **Greedy hill-climbing**: Iteratively modify Skill descriptions, comparing eval pass rate of each new version against the previous
- **Parallel version search**: Simultaneously generate multiple modification branches (exhaustive boundary conditions version, minimal + external validation script version, few-shot reinforced version) and select the best
- **Markov Decision Process (MDP)**: Use past experiment trajectories as training data; apply PPO algorithm to guide future modification directions
- **Heterogeneous model distillation**: Use flagship model output as a baseline; automatically rewrite SKILL.md so that a lightweight model (Haiku) reaches equivalent performance

**Optimization Loop Pseudocode:**

```python
def autoresearch_loop(skill_path: str, test_set: list, target_model: str):
    baseline_score = evaluate(skill_path, test_set, target_model)
    experiment_log = []

    for iteration in range(max_iterations):
        # Generate modification proposals (analyze failures → propose instruction changes)
        proposals = generate_proposals(skill_path, experiment_log)

        # Evaluate all proposals in parallel (isolated sandbox)
        results = parallel_evaluate(proposals, test_set, target_model)

        best = max(results, key=lambda r: r.pass_rate)
        experiment_log.append(results)

        if best.pass_rate > baseline_score:
            commit(best.skill_path)      # Commit the improved version
            baseline_score = best.pass_rate

        if baseline_score >= TARGET_PASS_RATE:
            break  # Target reached, stop optimizing

    return baseline_score
```

---

### 4.4 Skill: `agentic-cicd-gate` (Agentic CI/CD Gate)

**Role:** Deployment gating, change impact prediction, flaky test isolation, autonomous rollback

**YAML Frontmatter Design:**

```yaml
---
name: agentic-cicd-gate
description: >
  Manages the deployment pipeline for Skills and Sub-agents. Evaluates the impact
  scope of a new Skill version on the existing agent legion, runs the complete test
  suite before final deployment, monitors post-deployment behavior anomalies, and
  autonomously triggers rollback when quality degradation is detected.
tools:
  - Read
  - Bash
  - Grep
  - Glob
model: claude-sonnet-4-6
---
```

**Core Capabilities:**

- **Graph-based change impact prediction**: Analyze the new Skill's dependency graph; predict which downstream agents may be affected; selectively run only relevant test suites rather than full regression
- **Bayesian flaky test detection**: Track historical failure probability distributions of tests; identify instability caused by environmental non-determinism (or LLM hallucination) and auto-quarantine those tests
- **Post-deployment behavior monitoring**: Track trigger rate and output quality of newly deployed Skills; compare against pre-deployment baseline
- **Autonomous rollback**: When post-deployment quality degradation is detected (trigger rate drop > 10% or hallucination rate increase), automatically roll back to the last stable version

**Lifecycle Hook Integration:**

```bash
# .claude/hooks/pre-deploy.sh
#!/bin/bash
# Enforce quality threshold before deployment
SKILL_PATH="$1"
VALIDATION_RESULT=$(claude run skill-quality-validator --skill "$SKILL_PATH")
PASS_RATE=$(echo "$VALIDATION_RESULT" | jq '.trigger_rate')

if (( $(echo "$PASS_RATE < 0.90" | bc -l) )); then
  echo "❌ Deployment blocked: trigger rate $PASS_RATE is below threshold 0.90"
  exit 1  # Hard block on the deploy operation
fi

echo "✅ Quality threshold passed. Deployment allowed."
```

---

### 4.5 Skill: `changeling-router` (Changeling Router)

**Role:** Dynamic identity switching, single-agent multi-persona routing, context window efficiency optimization

**YAML Frontmatter Design:**

```yaml
---
name: changeling-router
description: >
  Acts as a central router for the agent legion, dynamically loading the appropriate
  expert role definition based on task requirements. Triggered when multiple different
  professional identities need to be assumed within the same conversation flow, or
  when the entire agent legion needs to operate within a single memory space.
  Supports the Changeling dynamic identity switching pattern.
tools:
  - Read
  - Task
model: claude-sonnet-4-6
---
```

**Changeling Dynamic Identity Switching Mechanism:**

```
Task request arrives
    │
    ▼
changeling-router analyzes task type
    │
    ├──(security audit needed)──→ Read ~/.claude/@lib/agents/security-auditor.md
    │                              → Load role definition, replace system prompt
    │                              → Execute task, unload identity when done
    │
    ├──(performance analysis needed)──→ Read ~/.claude/@lib/agents/perf-analyst.md
    │                                   → Dynamically become performance analyst
    │
    └──(code review needed)──→ Read ~/.claude/@lib/agents/code-reviewer.md
                               → Dynamically become reviewer (Write ops auto-denied)
```

**Benefits Achieved:**

- Maintain N role definitions with only 1 active agent instance
- Context window fully resets after each switch, ensuring cognitive isolation
- Role definitions stored centrally in a read-only repository, safe from task workflow pollution

---

## 5. Extended Skill Specifications — Phases 5–7

### 5.1 Skill: `topology-aware-router` (Phase 5)

**Role:** Pre-execution routing decision engine; computes TCI score and selects execution topology

```yaml
---
name: topology-aware-router
description: >
  Computes the Task Coupling Index (TCI) for an incoming task and routes it
  to the appropriate execution topology: Track A (multi-agent parallel Scrum team)
  or Track B (monolithic flagship model). Triggered before any multi-step
  development task is executed. Not triggered for single-agent informational
  queries, simple read-only tasks, or tasks already assigned a topology by
  an upstream orchestrator.
tools:
  - Read
  - Grep
  - Glob
  - Task
model: claude-sonnet-4-6
---
```

### 5.2 Skill: `scrum-team-orchestrator` (Phase 5)

**Role:** Manages the lifecycle of a parallel AI Scrum team execution

```yaml
---
name: scrum-team-orchestrator
description: >
  Manages the lifecycle of a parallel AI Scrum team execution. Receives a
  Track A routing decision from topology-aware-router and orchestrates
  Product Owner, Developer, and QA sub-agents via the A2A communication bus.
  Handles task decomposition, context slicing, inter-agent message routing,
  output aggregation, and sprint closure. Does not execute code directly.
tools:
  - Read
  - Task
  - Write
model: claude-sonnet-4-6
---
```

### 5.3 Skill: `watchdog-circuit-breaker` (Phase 5 / Cross-Cutting)

**Role:** Monitors agent task threads for infinite loop patterns and token budget violations

```yaml
---
name: watchdog-circuit-breaker
description: >
  Monitors all active agent task threads for infinite loop patterns and
  token budget violations. Runs as a background process alongside all
  multi-agent Track A executions and high-cost Track B flagship invocations.
  Triggered automatically by the topology-aware-router at task initiation.
  Emits WATCHDOG_HALT messages to the A2A bus when thresholds are exceeded.
  Does not participate in task execution. Observes only.
tools:
  - Read
  - Bash
model: claude-haiku-4-5
---
```

The Watchdog intentionally runs on Claude Haiku — the cheapest, fastest model. It does no reasoning about task content. It monitors two numbers and compares them against thresholds.

### 5.4 Skills: `edge-talker-agent` and `cloud-reasoner-agent` (Phase 6)

The Edge Talker is the on-device System 1; the Cloud Reasoner is the async System 2. Their architecture is described in full in the Phase 6 section of the development blueprint (Section 6.6).

### 5.5 Skill: `outcome-billing-engine` (Phase 7)

The billing engine instruments all agent activity via OpenTelemetry spans and maps outcomes to billable units. Its architecture is described in full in the Phase 7 section of the development blueprint (Section 6.7).

---

## 6. Seven-Phase Development Blueprint

### Phase 1: Infrastructure Setup & Meta-Agent Factory Core Development
**Duration: Months 1–2**

```
Goal: Establish Skill directory standards, complete meta-agent factory core functionality,
      validate the five-stage generation pipeline
```

**Action Items:**

- [ ] **Skill directory structure standardization**
  - Define standard directory structure for `.claude/skills/` and `.claude/agents/`
  - Establish YAML Frontmatter field standards (required fields, character limits, semantic requirements)
  - Design standard templates for three-layer progressive disclosure (Level 1 YAML / Level 2 Markdown / Level 3 scripts/)

- [ ] **`meta-agent-factory` core development**
  - Implement requirements analysis logic: Sub-agent vs. Skill classification decision tree
  - Implement mutually exclusive permission configuration engine (auto-assign tool sets by role type)
  - Develop MCP connection configuration generator (auto-update `.mcp.json`)
  - Build initial Changeling role library structure (`~/.claude/@lib/agents/`)

- [ ] **End-to-end pipeline integration tests**
  - Test case 1: Generate a read-only architect Sub-agent
  - Test case 2: Generate an execution agent with Bash tools
  - Test case 3: Generate an agent requiring MCP connection to an external service
  - Test case 4: Generate and validate a Changeling-mode role definition

**Phase 1 Acceptance Criteria:**
- Meta-agent factory generates format-compliant SKILL.md from natural language requirements with accuracy ≥ 90%
- Mutually exclusive permission violation auto-interception rate: 100% (zero cases of a review agent receiving Write)
- Five-stage generation pipeline full execution time ≤ 60 seconds

---

### Phase 2: Quality Validation System & CI/CD Gate Development
**Duration: Months 3–4**

```
Goal: Build an objective, automated Skill quality evaluation system; enforce strict
      quality gating before deployment
```

**Action Items:**

- [ ] **`skill-quality-validator` development**
  - Build YAML Frontmatter static analyzer (token budget calculation, field compliance)
  - Develop automatic test set generation engine (boundary conditions, semantic ambiguity, spelling variants)
  - Implement 60/40 training/validation split mechanism
  - Build trigger rate measurement framework (baseline vs. mounted comparison)

- [ ] **`agentic-cicd-gate` development**
  - Implement graph-based Skill dependency analysis (identify which existing agents depend on the modified Skill)
  - Develop Bayesian flaky test detection module (historical failure rate tracking and probability distribution analysis)
  - Build Lifecycle Hook integration (PreToolUse / PostToolUse / Stop event triggers)
  - Implement autonomous rollback mechanism (Git version revert + notification)

- [ ] **Evaluation benchmark dataset construction**
  - Build gold-standard test sets for each deployed Skill (≥ 20 test cases each)
  - Build hallucination risk test cases (including deliberately misleading inputs)
  - Design cross-domain semantic conflict tests (ensure Skills do not over-trigger)

**Phase 2 Acceptance Criteria:**
- Trigger rate measurement system consistency: two measurements of the same Skill differ by ≤ 5%
- Static analyzer detection rate for known format violations ≥ 95%
- CI/CD gate correctly blocks all under-threshold Skill deployments: 100%
- Flaky test auto-quarantine accuracy ≥ 80% (minimizing false quarantines)

---

### Phase 3: AutoResearch Optimization Engine & Heterogeneous Model Distillation
**Duration: Months 5–6**

```
Goal: Achieve unattended automatic optimization of Skill quality, plus instruction
      distillation targeting lightweight models
```

**Action Items:**

- [ ] **`autoresearch-optimizer` core development**
  - Implement base optimization loop (failure case analysis → description modification proposals → isolated evaluation → commit or discard)
  - Develop parallel version search engine (evaluate multiple modification branches simultaneously)
  - Build experiment trajectory database (log all version modification history and corresponding scores)
  - Implement MDP formalization framework (PPO algorithm guides modification directions)

- [ ] **Heterogeneous model distillation feature**
  - Build flagship model (Opus) successful output baseline dataset
  - Develop lightweight model (Haiku) instruction optimizer
  - Automatically evaluate distillation effectiveness (lightweight model performance vs. flagship model baseline gap)
  - Build model cost-efficiency analysis report generator

- [ ] **SkyPilot parallelization integration (advanced)**
  - Design task distribution interface (spread experiment branches across Kubernetes cluster)
  - Implement result aggregation and convergence algorithm
  - Build overnight batch execution scheduler

**Phase 3 Acceptance Criteria:**
- AutoResearch successfully raises trigger rate from < 75% to ≥ 90% with success rate ≥ 80%
- Optimization loop converges within ≤ 50 iterations (single run ≤ 8 hours)
- Distilled lightweight model performance on target task within ≤ 10% of flagship model
- Parallel search saves ≥ 60% of time compared to sequential search

---

### Phase 4: Changeling Integration, Full Ecosystem Closed Loop & Scale Validation
**Duration: Month 7 onward, continuous iteration**

```
Goal: Complete closed-loop integration of the entire ecosystem; achieve fully unattended
      pipeline from requirements input to automated deployment
```

**Action Items:**

- [ ] **`changeling-router` full implementation**
  - Build enterprise-grade role library (≥ 20 standard role definitions)
  - Implement task type auto-identification engine
  - Develop role switching performance benchmark (switching latency ≤ 2 seconds)

- [ ] **End-to-end closed-loop validation**
  - Stress test: automatically generate, validate, optimize, and deploy 50 new Skills within 24 hours
  - Regression test: verify new Skills do not affect existing agent behavior
  - Cost analysis: measure full pipeline API token consumption and time cost

- [ ] **Enterprise observability build-out**
  - Agent legion health dashboard (trigger rate trends, hallucination rate statistics, model cost distribution)
  - Skill lifecycle tracking (creation, modification, optimization, deprecation — full history)
  - Anomalous behavior alerting system

**Phase 4 Acceptance Criteria:**
- End-to-end pipeline (requirements input → deployment complete) time ≤ 4 hours
- Proportion of Skill optimization tasks completed autonomously (no human intervention) ≥ 70%
- Agent legion overall trigger rate maintained at ≥ 90% (monthly average)
- Quality regression events caused by deploying new Skills: 0

---

### Phase 5: AI Craft — Multi-Agent Orchestration & Topology-Aware Routing
**Duration: Months 8–9**

```
Goal: Upgrade from dynamic identity switching to a parallel-collaborative AI Scrum Team.
      Implement the Topology-Aware Router to dynamically select between multi-agent
      collaboration and monolithic flagship execution, preventing the Sequential Penalty
      in highly coupled tasks.
```

#### 5.1 Task Coupling Indexer (TCI)

The TCI is the decision engine that routes every task before execution begins. It computes a scalar coupling score between 0.0 (perfectly parallelizable) and 1.0 (completely sequential) by evaluating four dimensions of the incoming task.

**TCI Scoring Dimensions:**

| Dimension | Weight | What It Measures | Signals |
|-----------|--------|-----------------|---------|
| **Cross-module dependency depth** | 35% | How many separate modules does the task touch, and how deeply are they coupled? | Imports, shared state, API contracts, database schemas |
| **State rollback probability** | 25% | If this task fails partway through, how expensive is rollback? | Irreversible writes, migrations, compiled artifacts |
| **Context coherence requirement** | 25% | Does correct execution require holding the entire context simultaneously, or can subtasks run in isolation? | Global refactors, architectural changes, security audits |
| **Historical parallel failure rate** | 15% | Have similar tasks failed previously when routed to multi-agent execution? | AutoResearch trajectory database |

**TCI Score Interpretation:**

```
TCI = 0.0 – 0.35  →  Low coupling  →  Route to Track A (Multi-Agent Scrum)
TCI = 0.35 – 0.65 →  Medium coupling  →  Conservative default: Track B with confidence warning logged
TCI = 0.65 – 1.0  →  High coupling  →  Route to Track B (Monolithic Flagship)
```

The medium-coupling band defaults to Track B conservatively. The cost of a wrong Track A assignment on a high-coupling task (fragmented context, synchronization errors, wasted tokens) is significantly higher than the cost of a wrong Track B assignment on a parallelizable task. Err toward Track B when uncertain.

**TCI Computation Pipeline:**

```python
def compute_tci(task: UserStory, codebase_graph: DependencyGraph,
                history: ExperimentDB) -> float:

    # Dimension 1: Cross-module dependency depth
    affected_modules = codebase_graph.trace_impact(task.touch_points)
    dep_score = min(len(affected_modules) / MAX_MODULE_DEPTH, 1.0)

    # Dimension 2: State rollback probability
    rollback_score = estimate_rollback_cost(task.operations) / MAX_ROLLBACK_COST

    # Dimension 3: Context coherence requirement
    coherence_score = assess_context_atomicity(task.description)

    # Dimension 4: Historical parallel failure rate
    similar = history.find_similar_tasks(task)
    failure_rate = similar.parallel_failure_rate if similar else 0.5  # neutral prior

    tci = (
        0.35 * dep_score +
        0.25 * rollback_score +
        0.25 * coherence_score +
        0.15 * failure_rate
    )

    return round(tci, 4)
```

#### 5.2 Dual-Track Topology Routing

**Track A: Distributed Collaboration Mode (Multi-Agent Scrum)**

- **Trigger condition:** TCI score < 0.35 — task is highly parallelizable
- **Activation sequence:** `topology-aware-router` activates `scrum-team-orchestrator`, which instantiates the appropriate sub-agents (Product Owner, Developer, QA Reviewer) via the A2A communication bus
- **Agent instantiation:** Sub-agents are spawned with context-forked, isolated 200K token windows. Each receives only the slice of context relevant to its role. No agent can see another agent's full working context.
- **Communication protocol:** All inter-agent messages pass through a typed message schema (task assignment, partial output, review request, approval/rejection). Unstructured agent-to-agent chat is prohibited.
- **Use cases:** Frontend UI and backend API developed in parallel; independent microservice implementations; parallel test suite generation; documentation written concurrently with code

**Track B: Monolithic Flagship Mode (Topology Downgrade)**

- **Trigger condition:** TCI score ≥ 0.35 — task has coupling risk
- **Activation sequence:** `topology-aware-router` freezes all lateral A2A communication channels. The complete task context is packaged and routed to a single flagship-class model (Claude Opus 4.6) with a long context window as its sole execution environment.
- **Why this is faster:** For high-coupling tasks, the overhead of inter-agent message passing, partial context reconstruction at each node, and state synchronization between agents can consume more tokens than simply giving the full context to one model.
- **Token budget enforcement:** Track B invocations are subject to a hard token ceiling enforced by the Watchdog.
- **Use cases:** Global dependency refactoring across a large codebase; security audit requiring full code comprehension; architectural redesign touching shared infrastructure; complex debugging where the bug spans multiple abstraction layers

#### 5.3 A2A Communication Bus

All communication between agents in Track A mode is mediated through a typed message bus. Direct agent-to-agent calls are prohibited.

```json
{
  "message_id": "uuid-xxxx",
  "timestamp": "2026-03-28T10:30:00Z",
  "from_agent": "dev-agent-typescript",
  "to_agent": "qa-agent-reviewer",
  "message_type": "REVIEW_REQUEST",
  "payload": {
    "artifact_path": ".claude/skills/new-skill/SKILL.md",
    "description": "Requesting review of generated SKILL.md trigger description",
    "context_ref": "task-id-0042"
  },
  "reply_deadline_ms": 30000,
  "token_budget_remaining": 12400
}
```

**Message types (exhaustive — no other types are valid):**

| Type | Direction | Description |
|------|-----------|-------------|
| `TASK_ASSIGNMENT` | Orchestrator → Agent | Assigns a subtask with scoped context |
| `PARTIAL_OUTPUT` | Agent → Orchestrator | Returns a completed subtask artifact |
| `REVIEW_REQUEST` | Agent A → Agent B | Requests peer review of an artifact |
| `REVIEW_RESULT` | Agent B → Agent A | Returns approved / rejected with rationale |
| `ESCALATION` | Any → Orchestrator | Signals that a subtask exceeds the agent's capability |
| `WATCHDOG_HALT` | Watchdog → All | Immediate unconditional stop — budget or loop threshold hit |

**Phase 5 Acceptance Criteria:**

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| TCI computation speed | ≤ 5 seconds per task | End-to-end timestamp |
| TCI routing accuracy | ≥ 95% correct track selection | Benchmark test set (50 labeled tasks: 25 low-coupling, 25 high-coupling) |
| Track B token savings vs. Track A on high-coupling tasks | ≥ 40% fewer tokens | Controlled A/B benchmark on 10 high-coupling reference tasks |
| Track B compilation success rate vs. Track A | ≥ 25% higher | Same benchmark: compile-and-test pass rate |
| A2A message loss rate in Track A | 0% | Message log completeness audit |
| A2A infinite loop occurrence rate | < 1% | Watchdog trigger event log |
| Watchdog false positive rate (halting valid tasks) | < 2% | Human review of Watchdog halt events |

---

### Phase 6: Edge AI Integration & Cloud-Edge Hybrid Deployment
**Duration: Months 10–11**

```
Goal: Deploy distilled lightweight agent Skills to resource-constrained Edge AI devices.
      Implement the Talker-Reasoner dual-track architecture for zero-latency local
      interaction and async cloud escalation. Establish cloud-edge state synchronization.
```

#### 6.1 Talker-Reasoner Dual-Track Architecture

The cloud-edge architecture is modeled on the dual-process theory of cognition: a fast, automatic System 1 (the Edge Talker) and a slow, deliberate System 2 (the Cloud Reasoner). The two systems operate asynchronously. The Edge Talker never blocks waiting for the Cloud Reasoner.

```
User / Device
    │
    ▼
Edge Talker (System 1) — runs on-device
├── Zero-latency NLU and intent classification
├── Real-time sensor data filtering and local event detection
├── Local state management (belief state cache)
├── Immediate response for high-confidence, low-complexity interactions
├── Async task queue: stages complex tasks for Cloud Reasoner
└── Handles disconnected operation indefinitely for in-scope local tasks
    │
    │ (async, when network available, for complex tasks or TCI escalation)
    ▼
Cloud Reasoner (System 2) — runs in cloud
├── Deep logical reasoning and multi-step planning
├── Large knowledge base retrieval (RAG, GraphDB)
├── Track B topology processing for tasks escalated from edge
├── Model weight updates pushed back to Edge Talker
└── Aggregated insight synthesis across multiple edge nodes
```

**Escalation Triggers (Edge Talker → Cloud Reasoner):**

| Trigger | Condition | Action |
|---------|-----------|--------|
| Complexity threshold | Task TCI > 0.35 (computed locally) | Queue for async Cloud Reasoner processing |
| Knowledge gap | Local knowledge base confidence < 70% | Async retrieval request to cloud RAG |
| State conflict | Local belief state contradicts last known cloud state | Sync request with conflict resolution |
| Security boundary | Task requires credential, external API, or privileged operation | Mandatory cloud escalation (never execute locally) |
| Model confidence | Local model output probability < configured threshold | Escalate with partial output for cloud correction |

#### 6.2 Edge-Ready Skill Packaging & BSP Integration

**Edge Readiness Criteria:**

| Criterion | Requirement | Disqualifier |
|-----------|-------------|--------------|
| Model size | Inference model ≤ hardware memory budget (typically ≤ 4GB) | Any model requiring cloud API at inference time |
| Tool dependencies | All required tools must have local equivalents | Any Skill with a mandatory MCP cloud service call |
| Latency requirement | P99 inference latency ≤ 200ms on target hardware | Any Skill requiring multi-step chained API calls |
| Data classification | Input data must be classifiable as non-sensitive locally | Any Skill that processes PII without local encryption |
| State management | Skill must operate correctly from a local belief state snapshot | Any Skill requiring real-time global state |

**Skill Packaging Pipeline (Cloud → Edge):**

```
Phase 3 distilled SKILL.md + lightweight model
    │
    ├── Step 1: Edge Readiness Assessment (pass/fail gate)
    │
    ├── Step 2: Model export to hardware-optimized format
    │   ├── ONNX for CPU/NPU acceleration
    │   ├── TensorRT for NVIDIA-class edge GPUs
    │   └── llama.cpp / GGUF for ARM/Apple Silicon
    │
    ├── Step 3: BSP integration layer
    │   ├── Map Skill's Bash tools to local hardware resource APIs
    │   ├── Define hardware capability manifest (available NPU ops, memory limits)
    │   └── Security sandbox: constrain Skill to declared hardware access scope
    │
    ├── Step 4: Local SKILL.md adaptation
    │   ├── Replace cloud MCP calls with local tool equivalents
    │   ├── Add offline fallback behavior for each network-dependent operation
    │   └── Define escalation conditions in YAML Frontmatter
    │
    └── Step 5: Edge deployment package (.edge-skill bundle)
        ├── Optimized model weights
        ├── Local SKILL.md (edge-adapted)
        ├── BSP hardware manifest
        └── Sync state schema (for cloud reconciliation)
```

#### 6.3 Cloud-Edge State Synchronization

```
Edge Talker local belief state
    │
    ├── ON CONNECT: Pull delta since last sync timestamp
    │   Protocol: gRPC streaming (compressed JSON delta)
    │   Conflict resolution: Cloud state wins for shared fields;
    │                        Edge state wins for device-local fields
    │
    ├── ON DISCONNECT: Continue operating from local snapshot
    │   Log all state mutations with UTC timestamps
    │   Queue mutations for upload on reconnect
    │
    ├── PERIODIC SYNC (when connected): Push local mutations every 60s
    │   Use MQTT QoS 1 for guaranteed at-least-once delivery
    │   Deduplicate on cloud side using message_id
    │
    └── ON MODEL UPDATE: Pull new edge model weights via secure OTA
        Verify integrity (SHA-256 + code signing)
        Apply atomically (swap, not in-place patch)
        Roll back to previous version if post-update eval fails
```

**Phase 6 Acceptance Criteria:**

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Edge Talker offline functionality | Maintains basic interaction and local task execution with no network | Network isolation test (30-minute disconnection) |
| End-to-end Edge-to-Cloud decision latency reduction | ≥ 40% vs. cloud-only baseline | Controlled latency benchmark |
| Edge task success rate vs. cloud flagship | ≥ 85% | Parallel execution comparison on 100-task benchmark set |
| Edge model package size | ≤ target hardware memory budget | Hardware constraint test |
| State synchronization consistency | Zero data loss across reconnection cycle | Mutation log audit |
| OTA update rollback success rate | 100% on failed post-update eval | Automated update regression test |

---

### Phase 7: AaaS Commercialization Infrastructure & Cross-Regional Operations Readiness
**Duration: Month 12 onward**

```
Goal: Build multi-tenant, high-availability commercial platform infrastructure.
      Implement Outcome-Based Pricing. Achieve cross-regional operational resilience
      and regulatory compliance for Taiwan, Japan, and equivalent jurisdictions.
```

#### 7.1 Outcome-Based Billing Engine

**Billable Outcome Units:**

| Outcome Type | Billing Unit | Measurement Signal |
|-------------|-------------|-------------------|
| Skill successfully deployed | Per deployment event | `agentic-cicd-gate` deployment confirmation |
| Agent task completed | Per task (weighted by TCI complexity) | Task closure event in A2A bus or Track B completion signal |
| Skill quality improvement | Per trigger rate improvement point above baseline | AutoResearch eval log: before/after pass rate delta |
| Edge task processed locally | Per successful edge execution (discounted vs. cloud) | Edge Talker task completion event |
| Human escalation avoided | Per HITL event that was resolved without human intervention | Watchdog log: auto-resolved vs. human-escalated |

**Billing Engine Architecture:**

```
All agent activity events
    │
    ▼
OpenTelemetry instrumentation layer
(every Skill invocation, task event, and tool call emits a structured span)
    │
    ▼
outcome-billing-engine Skill
├── Event classifier: maps spans to billable outcome units
├── Tenant attribution: assigns events to customer accounts
├── Deduplication: idempotent processing of duplicate spans
├── Rate engine: applies pricing tiers based on volume and SLA
├── Real-time dashboard: token cost / outcome / margin per tenant
└── Invoice generation: monthly reconciliation export
    │
    ▼
Stripe API (payment processing) + customer portal
```

#### 7.2 Cross-Regional High-Availability Architecture

```
Global Load Balancer (GeoDNS)
    │
    ├── Region: Taiwan (Primary)
    │   ├── Kubernetes cluster: 3-zone AZ deployment
    │   ├── Data residency: All Taiwan customer data stays in Taiwan
    │   ├── Compliance scope: PDPA (Personal Data Protection Act)
    │   └── Latency target: ≤ 50ms for Taiwan customers
    │
    ├── Region: Japan
    │   ├── Kubernetes cluster: 3-zone AZ deployment
    │   ├── Data residency: All Japan customer data stays in Japan
    │   ├── Compliance scope: APPI (Act on Protection of Personal Information)
    │   └── Latency target: ≤ 50ms for Japan customers
    │
    └── Region: Global Fallback
        ├── Read-only replica for non-sensitive metadata
        └── Cross-regional traffic: metadata and billing only (never customer data)
```

**Multi-Tenant Isolation Architecture:**

Each enterprise customer receives a fully isolated tenant namespace:

```
Tenant namespace: <customer-id>
├── .claude/agents/        → tenant-specific sub-agent definitions
├── .claude/skills/        → tenant-specific Skill library
├── .mcp.json              → tenant-specific MCP service connections
├── eval/                  → tenant-specific test sets and baselines
├── audit-logs/            → encrypted, tamper-evident event log
└── billing-events/        → OpenTelemetry spans for billing attribution
```

#### 7.3 Enterprise Compliance & Audit Trail Infrastructure

**Audit Event Schema:**

```json
{
  "audit_id": "uuid-xxxx",
  "timestamp": "2026-03-28T10:30:00.000Z",
  "tenant_id": "acme-corp",
  "agent_id": "meta-agent-factory",
  "skill_invoked": "meta-agent-factory",
  "action_type": "TOOL_CALL",
  "tool_name": "Write",
  "tool_args_hash": "sha256:aabbcc...",
  "target_resource": ".claude/agents/new-agent.md",
  "outcome": "SUCCESS",
  "tokens_consumed": 1240,
  "human_approval_required": false,
  "human_approval_received": null,
  "region": "tw",
  "data_classification": "INTERNAL",
  "compliance_flags": []
}
```

**SSO Integration & Agent Permission Management:**

```
Enterprise Identity Provider (e.g., Azure AD, Okta)
    │
    ↓ SAML/OIDC
Agent Permission Manager
├── Agent identity registry (agent ID ↔ permission profile)
├── Skill authorization matrix (which agents can use which Skills)
├── MCP service access control (which agents can call which external services)
├── Human approval routing (which agents require HITL for which operation classes)
└── Offboarding workflow (revoke all agent permissions on project closure)
```

**Phase 7 Acceptance Criteria:**

| Metric | Target | Measurement Method |
|--------|--------|--------------------|
| Billing accuracy | 100% of successful agent interactions billed | Reconciliation audit: billing events vs. task logs |
| Cross-regional availability | 99.99% uptime (≤ 52.6 min/year downtime) | External uptime monitor (30-second check interval) |
| Regional data residency | Zero cross-border customer data transfer | Network egress audit log |
| Audit report compliance | Meets ISO 27001 and APPI baseline requirements | Third-party compliance audit |
| SSO integration | All agent permission changes propagated within 60 seconds | Permission sync latency test |
| Localized Skill load time | ≤ 500ms for locale-aware Skill extension loading | P99 latency measurement |
| Tenant namespace isolation | Zero cross-tenant data access events | Penetration test + access log audit |

---

## 7. Technology Stack & Toolchain

### 7.1 Core Technology Stack (All Phases)

| Layer | Technology | Purpose | Phase Introduced |
|-------|-----------|---------|-----------------|
| **LLM inference (design layer)** | Claude Opus 4.6 | Meta-agent factory, AutoResearch optimization, Track B flagship | 1 |
| **LLM inference (execution layer)** | Claude Sonnet 4.6 | Validator, CI/CD gate, Changeling router, TCI router | 1 |
| **LLM inference (tool layer)** | Claude Haiku 4.5 | Fast queries, data extraction, distillation target, Watchdog | 1 |
| **Version control** | Git | Skill history tracking, rollback mechanism | 1 |
| **MCP tool integration** | Model Context Protocol | External service connections (Jira, GitHub, Slack) | 1 |
| **Testing framework** | Custom Eval Runner | Trigger rate measurement, binary eval loop | 1 |
| **CI/CD** | Lifecycle Hooks + Shell | Deployment gating enforcement | 2 |
| **Observability** | Prometheus + Grafana | Agent legion health monitoring dashboard | 2 |
| **Data format** | JSON / TOON | Structured evaluation reports, experiment trajectory records | 2 |
| **Parallelization** | SkyPilot + Kubernetes | AutoResearch parallel experiment branches | 3 |
| **Routing / Logic** | Python + NetworkX | Task Coupling Indexer, static dependency graph analysis | 5 |
| **Multi-Agent** | LangGraph / AutoGen | A2A communication bus, Track A coordination topology | 5 |
| **Edge AI inference** | ONNX / TensorRT / llama.cpp | Lightweight model inference acceleration on target hardware | 6 |
| **Edge sync** | MQTT (QoS 1) + gRPC streaming | Low-bandwidth cloud-edge state synchronization | 6 |
| **OTA delivery** | Secure OTA (SHA-256 + code signing) | Edge model weight updates | 6 |
| **Billing** | Stripe API + custom outcome engine | Outcome-Based Pricing, invoice generation, tenant metering | 7 |
| **Multi-region infra** | Kubernetes (multi-region) + GeoDNS | Cross-regional high availability, data residency enforcement | 7 |
| **Identity & Access** | OIDC / SAML (Azure AD, Okta) | SSO integration for agent permission management | 7 |
| **Compliance logging** | Immutable append-only log (WORM storage) | Tamper-evident audit trail for ISO 27001 / APPI | 7 |
| **Billing instrumentation** | OpenTelemetry (spans + metrics) | Universal instrumentation for billing attribution and debugging | 7 |

### 7.2 Directory Structure Standard

```
<project-root>/
├── .claude/
│   ├── agents/                          # Sub-agent definition directory
│   │   ├── meta-agent-factory.md
│   │   ├── skill-quality-validator.md
│   │   ├── autoresearch-optimizer.md
│   │   ├── agentic-cicd-gate.md
│   │   ├── changeling-router.md
│   │   ├── topology-aware-router.md     # Phase 5
│   │   ├── scrum-team-orchestrator.md   # Phase 5
│   │   ├── watchdog-circuit-breaker.md  # Phase 5
│   │   ├── edge-talker-agent.md         # Phase 6
│   │   ├── cloud-reasoner-agent.md      # Phase 6
│   │   └── outcome-billing-engine.md    # Phase 7
│   ├── skills/                          # Skill definition directory
│   │   └── <skill-name>/
│   │       ├── SKILL.md                 # Level 1 + Level 2 definition
│   │       ├── scripts/                 # Level 3 execution scripts
│   │       │   └── *.sh / *.py
│   │       └── references/              # Level 3 reference documents
│   │           └── *.md
│   └── hooks/                           # Lifecycle Hook scripts
│       ├── pre-deploy.sh
│       ├── post-tool-use.sh
│       └── stop.sh
├── .mcp.json                            # MCP server configuration
└── ~/.claude/@lib/
    └── agents/                          # Changeling role library (read-only)
        ├── security-auditor.md
        ├── perf-analyst.md
        └── *.md
```

---

## 8. Meta-Agent Factory Five-Stage Pipeline Design

### 8.1 Stage 1: Requirements Analysis & Clarification (Analyze & Define)

**Goal:** Extract structured design specifications from natural language requirements

**Decision Tree: Sub-agent vs. Skill**

```
Requirements input
    │
    ├── Needs independent context window, independent identity, delegatable via Task tool?
    │   ├── YES → Create Sub-agent (.claude/agents/<n>.md)
    │   └── NO  → Continue evaluation
    │
    ├── Primarily augments the main agent's knowledge domain and operational guidance
    │   without needing independent execution?
    │   ├── YES → Create Skill (.claude/skills/<n>/SKILL.md)
    │   └── NO  → Ask user to clarify requirements
    │
    └── Needs to dynamically replace the current agent's identity (Changeling mode)?
        └── YES → Create role definition (~/.claude/@lib/agents/<n>.md)
```

### 8.2 Stage 2: Architecture Design & Semantic Naming (Design & Classify)

**Naming Conventions:**

| Agent Type | Naming Format | Example |
|-----------|---------------|---------|
| Domain expert | `<domain>-expert` | `typescript-perf-expert` |
| Tool executor | `<tool>-executor` | `git-ops-executor` |
| Review/validator | `<domain>-reviewer` | `security-code-reviewer` |
| Coordinator/manager | `<scope>-orchestrator` | `sprint-orchestrator` |
| Knowledge extractor | `<source>-extractor` | `jira-insight-extractor` |

**Principles for High-Hit-Rate Description Design:**

```
✅ Good description template:
"[action verb] + [specific task object] + [trigger context] + [exclusion context (optional)]"

Example:
"Analyzes TypeScript code for performance bottlenecks. Triggered when identifying
React over-rendering, memory leaks, async race conditions, or bundle size issues.
Does not handle JavaScript runtime errors or Node.js backend performance problems."

❌ Poor description template:
"TypeScript performance related work"  ← Too vague; low and imprecise trigger rate
```

### 8.3 Stage 3: Mutually Exclusive Permission Configuration Matrix (Configure)

| Agent Role Type | Allowed Tools | Explicitly Denied Tools | Design Rationale |
|----------------|---------------|------------------------|-----------------|
| Explore/planning (PO) | Read, Grep, Glob, WebSearch | Write, Edit, Bash, Task | Prevent planning agent from directly modifying code |
| Coordination/orchestration (SM) | Read, Write, Task, Skill | — | Needs delegation capability |
| Execution/development (Dev) | Read, Write, Edit, Bash, MCP | Task | Prevent dev agent from self-decomposing tasks |
| Review/validation (QA) | Read, Bash (restricted) | Write, Edit, Task | Preserve review objectivity |
| Tool/extraction | Read, Grep, WebFetch | Write, Task | Minimum attack surface |

### 8.4 Stage 4: SKILL.md Auto-Generation (Generate & Save)

**Standard SKILL.md Generation Template:**

```markdown
---
name: <kebab-case-name>
description: >
  <Semantically precise description ≤ 1024 characters>
  <Must include: trigger context, action verbs, exclusion context>
tools:
  <Configured per Stage 3 matrix>
model: <Selected based on task complexity>
---

# <Skill Full Name>

## Role & Mission

<2–3 sentences defining core responsibilities>

## Trigger Contexts

<Specific trigger context list, including boundary cases>

## Operating Procedure

### Step 1: <Step Name>
<Detailed operational instructions>

### Step 2: <Step Name>
...

## Output Format Specification

<Strictly defined output structure>

## Prohibited Behaviors

<Explicitly list prohibited actions, especially high-risk operations>

## Error Handling

<Common failure modes and corresponding handling strategies>
```

### 8.5 Stage 5: MCP Integration & Service Registration (Register)

**`.mcp.json` Auto-Update Logic:**

```json
{
  "mcpServers": {
    "<service-name>": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-<service>"],
      "env": {
        "<ENV_VAR>": "<value>"
      },
      "allowedTools": ["<tool1>", "<tool2>"]
    }
  }
}
```

---

## 9. AutoResearch Optimization Engine Design

### 9.1 Mapping from Machine Learning to Agent Skill Optimization

| AutoResearch Original Architecture (ML) | Agent Skill Optimization Architecture | Mechanism |
|-----------------------------------------|---------------------------------------|-----------|
| Editable asset: `train.py` | Target asset: `SKILL.md` | Each modification produces a reviewable git diff |
| Loss function: `val_bpb` (bits per byte) | Eval metric: binary test pass rate | Objective scalar; no subjective human judgment needed |
| Time budget: 5-minute GPU training cycle | Execution cycle: fixed test set inference count | Ensures cross-version evaluation consistency |
| Gradient descent updates model weights | Language-driven updates to Skill instruction text | LLM acts as the optimizer |
| Validation set `val_loss` | Validation set trigger rate + task completion rate | Composite evaluation metric |

### 9.2 Evaluation Metric Definitions

**Primary Metric: Binary Eval Pass Rate**

```python
def calculate_pass_rate(skill_path: str, eval_set: list) -> float:
    """
    Binary evaluation for each test case:
    - 1: Skill is correctly triggered AND output matches expected structure
    - 0: Skill not triggered, or triggered but output does not match expectation
    """
    results = []
    for test_case in eval_set:
        # Execute in isolated sandbox (ensures no memory contamination)
        output = execute_in_sandbox(skill_path, test_case.prompt)

        # Binary judgment
        passed = (
            output.skill_triggered == test_case.expected_trigger and
            validate_output_structure(output.content, test_case.expected_schema)
        )
        results.append(int(passed))

    return sum(results) / len(results)
```

**Secondary Metrics:**
- **Trigger precision**: `correct triggers / total triggers` (prevents over-triggering)
- **Trigger recall**: `correct triggers / expected triggers` (prevents under-triggering)
- **Token efficiency**: `average tokens required to complete a task` (lower is better)

### 9.3 Parallel Search Strategy

```
Baseline SKILL.md (trigger rate = 62%)
    │
    ├── Branch A: Reinforced boundary conditions version
    │   → Add 10 negative exclusion examples
    │   → Eval result: 67%
    │
    ├── Branch B: Minimal core + external validation version
    │   → Remove redundant descriptions, add Bash validation script
    │   → Eval result: 78% ← Best
    │
    ├── Branch C: Few-shot reinforced version
    │   → Add 3 trigger examples in Markdown body
    │   → Eval result: 71%
    │
    └── Branch D: MDP-guided version (based on past experiment trajectories)
        → Apply PPO-recommended modification patterns
        → Eval result: 74%

Select Branch B, commit as new version (trigger rate +26%)
Enter next iteration...
```

### 9.4 Heterogeneous Model Distillation Process

```
Phase 1: Establish flagship model baseline
    Opus 4.6 runs Skill → Record 100 successful output cases

Phase 2: Initial lightweight model evaluation
    Haiku 4.5 uses same SKILL.md → Pass rate typically 55–70%

Phase 3: Distillation optimization loop
    AutoResearch analyzes Haiku failure modes
    → Add more explicit constraints
    → Add output format examples
    → Add error handling guidance
    → Target: Haiku pass rate ≥ 90% of Opus baseline

Phase 4: Cost-efficiency validation
    Measure: Haiku token cost / Opus token cost = ~15%
    Measure: Haiku latency / Opus latency = ~20%
    Conclusion: 90% performance at 15% cost → route routine tasks to Haiku
```

---

## 10. Agentic CI/CD Validation Pipeline

### 10.1 Complete Deployment Pipeline Diagram

```
Developer submits new/modified SKILL.md
    │
    ▼
[Hook: PreToolUse] ──→ Static format validation
    │ Format error → Block; return error report
    │ Format OK    ↓
    ▼
skill-quality-validator ──→ Trigger rate test
    │ < 75%  → Trigger autoresearch-optimizer (auto-repair)
    │ 75–90% → Continue with warning flag
    │ ≥ 90%  ↓
    ▼
agentic-cicd-gate ──→ Impact scope analysis
    │ High impact (≥ 5 downstream agents) → Full regression test
    │ Low impact  (< 5 agents)            → Selective test only
    │ Tests pass  ↓
    ▼
[Hook: PostToolUse] ──→ Deploy to .claude/ directory
    │
    ▼
Post-deployment monitoring (24 hours)
    │ Trigger rate drops > 10% → Auto-rollback + alert
    │ Behavior normal           → Mark as Stable version
```

### 10.2 Bayesian Flaky Test Detection

```python
class BayesianFlakyDetector:
    def __init__(self):
        self.failure_history = {}  # {test_id: [True/False, ...]}

    def record_result(self, test_id: str, passed: bool):
        if test_id not in self.failure_history:
            self.failure_history[test_id] = []
        self.failure_history[test_id].append(passed)

    def is_flaky(self, test_id: str, threshold: float = 0.3) -> bool:
        """
        If historical failure rate is between 10% and 90%, classify as flaky.
        (> 90% failure is a real bug; < 10% occasional failure is acceptable.)
        """
        history = self.failure_history.get(test_id, [])
        if len(history) < 5:  # Insufficient history; defer judgment
            return False

        failure_rate = 1 - (sum(history) / len(history))
        return threshold <= failure_rate <= (1 - threshold)

    def quarantine(self, test_id: str):
        """Quarantine flaky test to prevent blocking the deployment pipeline."""
        # Remove from main test suite; add to observation queue
        pass
```

---

## 11. Defensive Architecture: Cascade Hallucination Prevention & Infinite Loop Containment

In single-agent systems, a hallucination produces wrong text. In multi-agent production systems with MCP tool access, a hallucination produces wrong actions — and wrong actions at the edge, in billing systems, or in customer data pipelines produce consequences that cannot be fully rolled back. These defensive mechanisms are prerequisites for production deployment.

### 11.1 Cascade Hallucination Prevention

**The Problem**

When an agent with tool permissions hallucinates a plan and then executes it through a destructive MCP tool (database write, file overwrite, external API call), the error has left the system. Standard rollback mechanisms (git revert, context reset) cannot undo a destructive external action.

In multi-agent systems, this risk compounds: Agent A hallucinates a specification, passes it to Agent B as a TASK_ASSIGNMENT, Agent B executes it faithfully, passes the (hallucinated) result to Agent C for QA. By the time the hallucination is detected, three agents have processed the bad state and multiple external tool calls may have been made.

**Mitigation 1: Mandatory Pre-Execution Reflection for Destructive Operations**

Any Skill that includes a tool call classified as `DESTRUCTIVE` (Write, Edit, database mutations, external API POST/PUT/DELETE) must include a mandatory pre-execution reflection step enforced at the Lifecycle Hook level (`PreToolUse`).

```python
# PreToolUse hook: mandatory reflection gate for DESTRUCTIVE tools
def pre_tool_use_hook(tool_name: str, tool_args: dict, agent_context: dict) -> HookResult:
    DESTRUCTIVE_TOOLS = {"Write", "Edit", "Bash", "mcp_*_write", "mcp_*_delete", "mcp_*_update"}

    if tool_name not in DESTRUCTIVE_TOOLS:
        return HookResult.ALLOW

    # Force a read-only dry-run or simulation before executing
    simulation_result = execute_simulation(tool_name, tool_args)

    # Agent must explicitly confirm the simulation matches intent
    confirmation = agent_reflect(
        prompt=f"You are about to execute: {tool_name} with args: {tool_args}. "
               f"Simulation result: {simulation_result}. "
               f"Does this match your intent? State explicitly what will change and why. "
               f"If anything is uncertain, respond HALT.",
        context=agent_context
    )

    if "HALT" in confirmation or confidence_score(confirmation) < 0.85:
        return HookResult.BLOCK(reason=confirmation)

    return HookResult.ALLOW
```

**Mitigation 2: Tiered Human-in-the-Loop (HITL) Gates**

| Tier | Operation Class | HITL Requirement | Example |
|------|----------------|-----------------|---------|
| **Tier 0** | Read-only, informational | None | Skill trigger rate query, log read |
| **Tier 1** | Reversible state change | Auto-approve + audit log | SKILL.md update, test run |
| **Tier 2** | Consequential but recoverable | Async notification (auto-proceeds after 10 min no response) | New Sub-agent deployment, MCP service registration |
| **Tier 3** | Irreversible or high-blast-radius | Synchronous human approval required | Core architecture change, billing schema migration, external service credential update, production data write |

The operation class of every tool call is defined statically in the Skill's YAML Frontmatter:

```yaml
# In any Skill's YAML Frontmatter
operation_classifications:
  Write: TIER_1        # Reversible — git revert available
  mcp_jira_create: TIER_2    # Consequential — creates external record
  mcp_database_write: TIER_3  # Irreversible — requires human approval
```

### 11.2 Infinite Loop Containment: Watchdog & Budget Circuit Breaker

**The Problem**

In a multi-agent Scrum team, the most common runaway scenario is the Dev-QA loop: Dev generates code with a logic flaw; QA rejects it with an error report; Dev revises with a different logic flaw; QA rejects again. This loop can run indefinitely — each iteration consumes tokens, produces no usable output, and accelerates toward budget exhaustion.

**Watchdog Monitoring Logic:**

```python
class WatchdogCircuitBreaker:

    def __init__(self, task_id: str, config: WatchdogConfig):
        self.task_id = task_id
        self.message_counts = {}        # {agent_pair: count}
        self.token_velocity_window = [] # rolling 60s window of token consumption events
        self.config = config

    def on_message(self, msg: A2AMessage):
        pair_key = f"{msg.from_agent}→{msg.to_agent}"
        self.message_counts[pair_key] = self.message_counts.get(pair_key, 0) + 1

        if self.message_counts[pair_key] > self.config.MAX_MESSAGES_PER_PAIR:
            self._trigger_halt(
                reason=f"Loop detected: {pair_key} exchanged "
                       f"{self.message_counts[pair_key]} messages (limit: {self.config.MAX_MESSAGES_PER_PAIR})",
                severity="LOOP"
            )

    def on_token_event(self, tokens_consumed: int):
        now = time.time()
        self.token_velocity_window = [
            (t, c) for t, c in self.token_velocity_window if now - t < 60
        ]
        self.token_velocity_window.append((now, tokens_consumed))

        velocity = sum(c for _, c in self.token_velocity_window)

        if velocity > self.config.MAX_TOKENS_PER_MINUTE:
            self._trigger_halt(
                reason=f"Token velocity {velocity}/min exceeds limit "
                       f"{self.config.MAX_TOKENS_PER_MINUTE}/min",
                severity="BUDGET"
            )

    def _trigger_halt(self, reason: str, severity: str):
        broadcast_halt(self.task_id, reason)
        freeze_task_thread(self.task_id)
        snapshot = capture_belief_state(self.task_id)
        escalate_to_human(self.task_id, reason, severity, snapshot)
```

**Default Watchdog Thresholds:**

| Parameter | Default Value | Rationale |
|-----------|---------------|-----------|
| `MAX_MESSAGES_PER_PAIR` | 8 messages between any two agents | A legitimate review cycle should resolve in ≤ 3 rounds; 8 is a generous ceiling |
| `MAX_TOKENS_PER_MINUTE` | 5,000 tokens/min (Track A), 15,000 tokens/min (Track B) | Track B is more expensive by design but has a higher ceiling due to flagship model context load |
| `MAX_TOTAL_TASK_BUDGET` | Set per task at routing time, based on TCI score and task classification | Prevents individual tasks from consuming disproportionate share of monthly budget |
| `HALT_ESCALATION_TIMEOUT` | 15 minutes for human response | After 15 minutes without human resolution, Watchdog logs the task as failed and releases the frozen agent contexts |

---

## 12. Milestones & Acceptance Criteria

### 12.1 Full Development Milestone Timeline (Months 1–13+)

```
Month 1    Month 2    Month 3    Month 4    Month 5    Month 6    Month 7
   │          │          │          │          │          │          │
   ├──────────┤          │          │          │          │          │
   │ Phase 1  │          │          │          │          │          │
   │ Meta-Agent          │          │          │          │          │
   │ Factory  │          │          │          │          │          │
   │ Core     │          │          │          │          │          │
   │          ├──────────┴──────────┤          │          │          │
   │          │      Phase 2        │          │          │          │
   │          │  Quality Validator  │          │          │          │
   │          │  + CI/CD Gate Dev   │          │          │          │
   │          │                     ├──────────┴──────────┤          │
   │          │                     │       Phase 3        │          │
   │          │                     │  AutoResearch Engine │          │
   │          │                     │  + Model Distillation│          │
   │          │                     │                      ├──────────►
   │          │                     │                      │  Phase 4
   │          │                     │                      │  Closed Loop

Month 8    Month 9    Month 10   Month 11   Month 12   Month 13+
   │          │          │          │          │          │
   ├──────────┤          │          │          │          │
   │ Phase 5  │          │          │          │          │
   │ TCI +    │          │          │          │          │
   │ Topology │          │          │          │          │
   │ Routing  │          │          │          │          │
   │ + Scrum  │          │          │          │          │
   │ Team     │          │          │          │          │
   │          ├──────────┤          │          │          │
   │          │ Phase 5  │          │          │          │
   │          │ Watchdog │          │          │          │
   │          │ + Def.   │          │          │          │
   │          │ Arch.    │          │          │          │
   │          │          ├──────────┤          │          │
   │          │          │ Phase 6  │          │          │
   │          │          │ Edge AI  │          │          │
   │          │          │ + Cloud- │          │          │
   │          │          │ Edge     │          │          │
   │          │          │ Hybrid   │          │          │
   │          │          │          ├──────────►          │
   │          │          │          │ Phase 7  │          │
   │          │          │          │ AaaS     │          │
   │          │          │          │ Infra +  ├──────────►
   │          │          │          │ Launch   │ Continuous
   │          │          │          │          │ Commercial
   │          │          │          │          │ Operations
```

### 12.2 Cumulative KPI Summary (Phases 1–7)

| Category | Metric | Phase 1–4 Target | Phase 5–7 Added Target |
|----------|--------|-----------------|----------------------|
| **Agent generation** | First-attempt format compliance | ≥ 90% | Maintained |
| **Generation quality** | Mutually exclusive permission design error rate | 0% | Maintained |
| **Trigger accuracy** | Average deployed Skill trigger rate | ≥ 90% | Maintained across all tenants |
| **Trigger accuracy** | Over-trigger rate | ≤ 5% | Maintained |
| **Optimization** | AutoResearch convergence success rate | ≥ 80% | Extended to edge-deployed Skills |
| **Optimization** | Average optimization convergence iterations | ≤ 50 | Maintained |
| **Cost efficiency** | Distilled lightweight model performance vs. flagship | ≥ 90% | Maintained |
| **Routing intelligence** | TCI track selection accuracy | N/A | ≥ 95% |
| **Multi-agent efficiency** | Token savings on high-coupling tasks (Track B vs. Track A) | N/A | ≥ 40% |
| **Defensive reliability** | Loop-triggered Watchdog halts auto-resolved (no human needed) | N/A | ≥ 85% |
| **Edge performance** | Edge task success rate vs. cloud | N/A | ≥ 85% |
| **Commercial** | Billing accuracy | N/A | 100% |
| **Commercial** | Cross-regional availability | N/A | 99.99% |
| **System stability** | Quality regression events caused by new Skill deployment | 0 | 0 |
| **Automation degree** | Skill optimization tasks without human intervention | ≥ 70% | ≥ 80% (Phase 7+) |
| **End-to-end efficiency** | Pipeline time: requirements input → deployment complete | ≤ 4 hours | ≤ 4 hours |

---

## 13. Risk Management Matrix

| Risk Item | Probability | Impact | Mitigation Strategy |
|-----------|-------------|--------|---------------------|
| Meta-agent factory generates Skill with overly permissive tool access (e.g., review agent accidentally granted Write) | Medium | High | Enforce mutually exclusive permission matrix via static check; include complete security test suite in Phase 1 design |
| AutoResearch optimization loop produces overfitting (high score on training set but poor performance on real tasks) | Medium | High | Strict 60/40 training/validation split; add new test cases monthly to refresh evaluation set |
| Trigger rate measurement itself is unstable (two measurements differ significantly due to LLM non-determinism) | High | Medium | Run ≥ 5 evaluations per assessment and average results; use Bayesian flakiness detector to identify tests that are themselves problematic |
| Context pollution after Changeling mode switching (memory from previous role bleeds into subsequent tasks) | Medium | Medium | Force full context reset after each identity switch; explicitly declare forget boundaries in role definitions |
| AutoResearch parallel experiment API costs spiral out of control | Medium | Medium | Set token budget ceiling per optimization task; use lightweight model for initial screening; submit only candidates to flagship model for final evaluation |
| MCP service misconfiguration causes agent to unexpectedly access unauthorized external systems | Low | High | Meta-agent factory requires human confirmation before writing `.mcp.json` (high-risk services require explicit human approval) |
| Single point of failure for the entire ecosystem (meta-agent factory itself crashes) | Low | Critical | Design meta-agent factory conservatively (minimum tools, strictest output format); maintain manual fallback process documentation |
| Engineer resistance to fully automated Skill deployment (concern about quality loss of control) | Medium | Medium | Maintain human review steps during Phases 1–2; gradually increase automation ratio after building trust through acceptance KPIs |
| **A2A communication deadlock**: agents mutually waiting for responses, halting task progress | Medium | High | TCI routes high-risk tasks to Track B before deadlock is possible; strict `reply_deadline_ms` on all A2A messages; Watchdog halts and escalates on timeout |
| **TCI misclassification** — high-coupling task routed to Track A: context fragmentation, sync failures, wasted tokens | Medium | High | Conservative medium-coupling band defaults to Track B; TCI confidence score logged; AutoResearch continuously improves TCI using execution outcome data |
| **Edge device OOM on complex Skill**: lightweight model exceeds device memory budget | High | Medium | Edge Readiness Assessment gates deployment; Skill complexity strictly bounded per device profile; dynamic downgrade to Cloud Reasoner on OOM event |
| **Cascade hallucination via destructive MCP tool**: hallucinated plan executed as external action | Medium | Critical | Mandatory Pre-Execution Reflection hook for all DESTRUCTIVE tools; TIER_3 HITL gate for irreversible operations; simulation-before-execution enforced at Lifecycle Hook level |
| **Dev-QA infinite loop** — token budget exhaustion: multi-agent loop burns entire monthly budget | High | High | Watchdog monitors message pair counts and token velocity in real time; loop threshold triggers WATCHDOG_HALT in ≤ 1 minute of threshold breach |
| **Cross-regional data residency violation**: customer data crosses regional boundary | Low | Critical | Architectural enforcement: tenant data never leaves regional cluster; cross-border traffic restricted to non-sensitive metadata and billing aggregates only; quarterly network egress audit |
| **Outcome-based billing dispute**: customer contests billed outcome count | Medium | Medium | All billing events sourced from immutable OpenTelemetry spans; full audit trail available for dispute resolution; reconciliation dashboard visible to customer in portal |
| **Watchdog false positive halting valid task**: aggressive threshold triggers on legitimate high-volume task | Medium | Medium | Watchdog thresholds configurable per task class; initial deployment uses conservative (high) thresholds; thresholds tightened gradually based on production data |

---

## 14. Appendix A: SKILL.md Authoring Standards & Templates

### 14.1 Three-Layer Architecture Token Budget Standards

| Layer | Component | Character/Token Limit | Key Constraint |
|-------|-----------|----------------------|----------------|
| Level 1 | YAML Frontmatter `description` | ≤ 1024 characters | This is the sole LLM routing signal; must contain trigger verbs and exclusion contexts |
| Level 2 | Markdown body (SKILL.md) | ≤ 500 lines / 5000 tokens | Contains complete operational instructions, output templates, error handling |
| Level 3 | `scripts/` and `references/` | Unlimited | Accessed by the agent only when Level 2 instructions explicitly direct it |

### 14.2 Description Field Required Elements Checklist

After authoring, confirm all of the following elements are present:

- [ ] **Core action verbs** (≥ 2): generate, analyze, validate, extract, configure…
- [ ] **Specific task objects** (≥ 1): TypeScript code, SKILL.md file, MCP configuration…
- [ ] **Positive trigger contexts** (≥ 2): "when X needs to…", "when the user describes…"
- [ ] **Exclusion contexts** (≥ 1, strongly recommended): "does not handle…", "not applicable to…"
- [ ] **Avoid overly broad statements**: Never use "all AI-related tasks", "any code problem", etc.

### 14.3 Complete SKILL.md Template (using `meta-agent-factory` as example)

```markdown
---
name: meta-agent-factory
description: >
  Designs and generates new Claude Agent Skill or Sub-agent definition files.
  Triggered when a user needs to create a new AI agent capability, instantiate
  a specific role as an agent, configure MCP external service connections, or
  automate a workflow. Covers the full flow from requirements analysis and
  architecture classification through permission design to SKILL.md file write.
  Does not handle quality optimization of existing Skills (handled by
  autoresearch-optimizer), nor post-deployment monitoring tasks (handled by
  agentic-cicd-gate).
tools:
  - Read
  - Write
  - Glob
  - Grep
  - Task
model: claude-opus-4-6
---

# Meta-Agent Factory

## Role & Mission

You are the designer of the enterprise agent legion. Your responsibility is to
translate human natural language requirements into agent definition files that
are format-rigorous, permission-secure, and semantically precise.
Every agent you design must comply with the principle of least privilege,
ensuring the agent holds only the tool access rights necessary within its
scope of responsibility.

## Five-Stage Execution Flow

### Stage 1: Requirements Analysis
1. Fully restate the user's requirements to confirm correct understanding
2. Determine whether to create a Sub-agent or a Skill (follow the decision tree)
3. If requirements are ambiguous, ask these key clarifying questions:
   - Is this agent primarily executing tasks or providing knowledge?
   - Does this agent need to be delegated tasks by other agents?
   - Which external services does this agent need to connect to?

### Stage 2: Architecture Classification & Naming
- Determine the kebab-case name per naming conventions
- Design a high-hit-rate description (include trigger verbs, exclusion contexts)

### Stage 3: Permission Matrix Configuration
- Apply the mutually exclusive permission matrix based on role type
- Any exceptions must be explicitly justified

### Stage 4: Generate & Write
- Generate the complete SKILL.md from the standard template
- Use the Write tool to write to the correct directory path

### Stage 5: MCP Integration (if applicable)
- Analyze whether the new agent requires external service connections
- If so, generate the corresponding .mcp.json update content
- Update .mcp.json when needed (high-risk services must require user confirmation)

## Output Format Specification

After generation is complete, output the following confirmation summary:

```
✅ Agent generation complete
─────────────────────────────
Name:          <agent-name>
Type:          Sub-agent / Skill / Changeling role
Path:          <file-path>
Tools granted: <list all granted tools>
Tools denied:  <list explicitly denied tools>
MCP:           <yes/no; if yes, list service names>
─────────────────────────────
Expected trigger rate: <high/medium/low — with rationale>
Recommended next step: Delegate to skill-quality-validator for trigger rate testing
```

## Prohibited Behaviors

- Never grant Write or Edit tools to review/validation agents
- Never grant the Task tool to execution agents (prevents infinite delegation chains)
- Never allow the description field to exceed 1024 characters
- Never modify an existing .mcp.json without informing the user

## Error Handling

- If requirements contain a clear mutual contradiction (e.g., "needs to review but also directly modify code")
  → Explain the architectural conflict; recommend splitting into two separate agents
- If a Skill with the same name already exists in the directory
  → Ask the user whether to overwrite or create a new version (append version suffix)
```

---

## 15. Appendix B: TCI Algorithm Specification & Topology Decision Tree

### 15.1 TCI Labeling Benchmark (50-Task Reference Set)

For Phase 5 acceptance validation, the TCI routing accuracy target (≥ 95%) is measured against a human-labeled 50-task benchmark:

- **25 low-coupling tasks (TCI ground truth < 0.35):** Independent API endpoint implementations; isolated UI component creation; new Skill authoring with no existing Skill dependencies; standalone documentation tasks; independent test suite generation
- **25 high-coupling tasks (TCI ground truth ≥ 0.65):** Global refactoring of a shared authentication module; migration of a database schema with downstream API contract changes; security audit requiring full codebase comprehension; architectural redesign of the A2A message bus; AutoResearch optimizer rewrite touching eval framework and scoring algorithm simultaneously

Each task in the benchmark is labeled by two independent senior engineers. Disagreements are resolved by a third reviewer. The benchmark is frozen at Phase 5 initiation and never modified during evaluation.

### 15.2 Full Topology Decision Tree

```
New task arrives
    │
    ▼
Is this task a single-agent read-only query?
    ├── YES → Execute directly, no TCI needed
    └── NO  ↓
    │
    ▼
Compute TCI score (target: ≤ 5 seconds)
    │
    ├── TCI < 0.35 (low coupling)
    │   └── Track A: Activate scrum-team-orchestrator
    │           │
    │           ├── Activate Watchdog (Track A thresholds)
    │           ├── Fork context → assign to PO / Dev / QA
    │           ├── Open A2A bus (typed schema only)
    │           └── Execute in parallel → aggregate → close bus
    │
    ├── 0.35 ≤ TCI < 0.65 (medium coupling — conservative default)
    │   └── Track B: Log confidence warning + route to flagship
    │           (same flow as TCI ≥ 0.65)
    │
    └── TCI ≥ 0.65 (high coupling)
        └── Track B: Freeze A2A bus → package full context
                │
                ├── Activate Watchdog (Track B thresholds)
                ├── Apply token ceiling (based on TCI × task class budget)
                ├── Route to flagship model (claude-opus-4-6)
                └── Execute → validate output → return result

Throughout all tracks:
    ├── Pre-Execution Reflection gate active for all DESTRUCTIVE tool calls
    ├── HITL tier classification enforced per tool via YAML Frontmatter
    ├── All events emitted as OpenTelemetry spans (billing + audit)
    └── Watchdog has WATCHDOG_HALT authority over all active threads
```

---

## Revision History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| v1.0 | 2026-03-23 | AI Agent Platform Development Team | Initial version. Based on enterprise AI agent legion deep research report. Covers five Skill specifications, four-phase development blueprint, AutoResearch optimization engine design, and Agentic CI/CD pipeline architecture. |
| v2.0 | 2026-03-29 | AI Agent Platform Development Team | Merged AGENT_SKILL_AUTOMATION_UPGRADE_PLAN.md (v1.1). Added Phases 5–7: multi-agent orchestration with TCI topology routing (Phase 5), cloud-edge hybrid deployment with Talker-Reasoner architecture (Phase 6), AaaS commercialization with Outcome-Based Pricing and cross-regional HA (Phase 7). Added six new Skill specifications, Defensive Architecture section (Pre-Execution Reflection, HITL tiers, Watchdog circuit breaker), updated tech stack, extended milestones to Month 13+, and merged risk matrices. |

---

*This document covers the complete seven-phase development lifecycle of the Enterprise-Grade Agent Skill Set Automation Pipeline. All architectural designs are grounded in the core principles of progressive disclosure, mutually exclusive permissions, scalar metric-driven optimization, topology-aware routing, edge-first privacy, and defensive architecture.*
