# Enterprise-Grade Agent Skill Set Automation Development & Evolution Pipeline
## Meta-Agent Factory × AutoResearch Optimization Engine — Development Plan & Blueprint

> **Document Version:** v1.0
> **Created:** 2026-03-23
> **Reference:** Enterprise AI Agent Legion Architecture & Automation Pipeline: A Deep Research Report on Meta-Agent Ecosystems Based on Claude Code Skills and AutoResearch
> **Audience:** AI Agent Platform Development Team, System Architects, DevOps Engineers, Skill Developers

---

## Table of Contents

1. [Strategic Background & Development Intent](#1-strategic-background--development-intent)
2. [Skill Set Overall Architecture](#2-skill-set-overall-architecture)
3. [Core Skill Specifications](#3-core-skill-specifications)
4. [Four-Phase Development Blueprint](#4-four-phase-development-blueprint)
5. [Technology Stack & Toolchain](#5-technology-stack--toolchain)
6. [Meta-Agent Factory Five-Stage Pipeline Design](#6-meta-agent-factory-five-stage-pipeline-design)
7. [AutoResearch Optimization Engine Design](#7-autoresearch-optimization-engine-design)
8. [Agentic CI/CD Validation Pipeline](#8-agentic-cicd-validation-pipeline)
9. [Milestones & Acceptance Criteria](#9-milestones--acceptance-criteria)
10. [Risk Management Matrix](#10-risk-management-matrix)
11. [Appendix: SKILL.md Authoring Standards & Templates](#11-appendix-skillmd-authoring-standards--templates)

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

### 1.3 Core Design Principles

| Principle | Description |
|-----------|-------------|
| **Skills define agent boundaries** | An agent's capability boundary is strictly defined by its Skill set, not by vague general LLM reasoning |
| **Progressive disclosure first** | Three-layer architecture minimizes token consumption; core descriptions stay statically fixed, maximizing cache hit rate |
| **Deterministic scripts + non-deterministic reasoning hybrid** | Lifecycle Hooks enforce quality thresholds — behavior is not constrained by natural language prompts alone |
| **Mutually exclusive permissions principle** | Each Skill holds only the minimum tool set required for its responsibility; generation agents do not hold review agent permissions |
| **Scalar metric-driven optimization** | The AutoResearch engine uses binary test pass rate as the sole objective reward function, eliminating subjective judgment |
| **Sandbox isolation guarantees comparability** | Every Skill version evaluation runs in a fresh isolated context, ensuring absolute fairness across version comparisons |

---

## 2. Skill Set Overall Architecture

### 2.1 Skill Classification Overview

```
Agent Skill Automation Skill Set
│
├── 🏭 [ORCHESTRATOR] meta-agent-factory
│   └── Requirements analysis, architecture design, Skill/Sub-agent generation, MCP config, directory writes
│
├── 🧪 [VALIDATOR] skill-quality-validator
│   └── SKILL.md static analysis, trigger rate evaluation, boundary condition testing, hallucination detection
│
├── 🔄 [OPTIMIZER] autoresearch-optimizer
│   └── Binary eval loop, parallel version search, instruction distillation, model adaptation tuning
│
├── 🚦 [CICD] agentic-cicd-gate
│   └── Change impact prediction, flaky test isolation, deployment gating, autonomous rollback
│
└── 🎭 [UTILITY] changeling-router
    └── Dynamic identity switching, single-agent multi-persona routing, context window efficiency optimization
```

### 2.2 Skill Interaction Diagram

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

## 3. Core Skill Specifications

### 3.1 Skill: `meta-agent-factory` (Meta-Agent Factory)

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

**Five-Stage Generation Flow (see Section 6 for detail):**

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

### 3.2 Skill: `skill-quality-validator` (Skill Quality Validator)

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

### 3.3 Skill: `autoresearch-optimizer` (AutoResearch Optimization Engine)

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

**Core Optimization Strategies (see Section 7 for detail):**

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

### 3.4 Skill: `agentic-cicd-gate` (Agentic CI/CD Gate)

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

### 3.5 Skill: `changeling-router` (Changeling Router)

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

## 4. Four-Phase Development Blueprint

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

## 5. Technology Stack & Toolchain

### 5.1 Core Technology Stack

| Layer | Technology | Purpose | Alternative |
|-------|-----------|---------|-------------|
| **LLM inference (design layer)** | Claude Opus 4.6 | Meta-agent factory, AutoResearch optimization | — |
| **LLM inference (execution layer)** | Claude Sonnet 4.6 | Validator, CI/CD gate, Changeling router | — |
| **LLM inference (tool layer)** | Claude Haiku 4.5 | Fast queries, data extraction, distillation target model | GPT-5.4 nano |
| **Version control** | Git | Skill history tracking, rollback mechanism | — |
| **MCP tool integration** | Model Context Protocol | External service connections (Jira, GitHub, Slack) | LangChain Tools |
| **Parallelization** | SkyPilot + Kubernetes | AutoResearch parallel experiment branches | Local multi-process |
| **Testing framework** | Custom Eval Runner | Trigger rate measurement, binary eval loop | — |
| **CI/CD** | Lifecycle Hooks + Shell | Deployment gating enforcement | GitHub Actions |
| **Observability** | Prometheus + Grafana | Agent legion health monitoring dashboard | — |
| **Data format** | JSON / TOON | Structured evaluation reports, experiment trajectory records | — |

### 5.2 Directory Structure Standard

```
<project-root>/
├── .claude/
│   ├── agents/                          # Sub-agent definition directory
│   │   ├── meta-agent-factory.md        # Meta-agent factory (system entry)
│   │   ├── skill-quality-validator.md
│   │   ├── autoresearch-optimizer.md
│   │   ├── agentic-cicd-gate.md
│   │   └── changeling-router.md
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

## 6. Meta-Agent Factory Five-Stage Pipeline Design

### 6.1 Stage 1: Requirements Analysis & Clarification (Analyze & Define)

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

### 6.2 Stage 2: Architecture Design & Semantic Naming (Design & Classify)

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

### 6.3 Stage 3: Mutually Exclusive Permission Configuration Matrix (Configure)

| Agent Role Type | Allowed Tools | Explicitly Denied Tools | Design Rationale |
|----------------|---------------|------------------------|-----------------|
| Explore/planning (PO) | Read, Grep, Glob, WebSearch | Write, Edit, Bash, Task | Prevent planning agent from directly modifying code |
| Coordination/orchestration (SM) | Read, Write, Task, Skill | — | Needs delegation capability |
| Execution/development (Dev) | Read, Write, Edit, Bash, MCP | Task | Prevent dev agent from self-decomposing tasks |
| Review/validation (QA) | Read, Bash (restricted) | Write, Edit, Task | Preserve review objectivity |
| Tool/extraction | Read, Grep, WebFetch | Write, Task | Minimum attack surface |

### 6.4 Stage 4: SKILL.md Auto-Generation (Generate & Save)

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

### 6.5 Stage 5: MCP Integration & Service Registration (Register)

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

## 7. AutoResearch Optimization Engine Design

### 7.1 Mapping from Machine Learning to Agent Skill Optimization

| AutoResearch Original Architecture (ML) | Agent Skill Optimization Architecture | Mechanism |
|-----------------------------------------|---------------------------------------|-----------|
| Editable asset: `train.py` | Target asset: `SKILL.md` | Each modification produces a reviewable git diff |
| Loss function: `val_bpb` (bits per byte) | Eval metric: binary test pass rate | Objective scalar; no subjective human judgment needed |
| Time budget: 5-minute GPU training cycle | Execution cycle: fixed test set inference count | Ensures cross-version evaluation consistency |
| Gradient descent updates model weights | Language-driven updates to Skill instruction text | LLM acts as the optimizer |
| Validation set `val_loss` | Validation set trigger rate + task completion rate | Composite evaluation metric |

### 7.2 Evaluation Metric Definitions

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

### 7.3 Parallel Search Strategy

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

### 7.4 Heterogeneous Model Distillation Process

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

## 8. Agentic CI/CD Validation Pipeline

### 8.1 Complete Deployment Pipeline Diagram

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

### 8.2 Bayesian Flaky Test Detection

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

## 9. Milestones & Acceptance Criteria

### 9.1 Development Milestone Timeline

```
Month 1    Month 2    Month 3    Month 4    Month 5    Month 6    Month 7+
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
   │          │                     │                      │  + Scale
```

### 9.2 Overall Acceptance KPIs

| Category | Metric | Target | Measurement Method |
|----------|--------|--------|--------------------|
| **Generation quality** | First-attempt format compliance rate from meta-agent factory | ≥ 90% | Static analyzer auto-scoring |
| **Generation quality** | Mutually exclusive permission design error rate | 0% | Security audit auto-scan |
| **Trigger accuracy** | Average trigger rate of deployed Skills | ≥ 90% | Weekly automated evaluation |
| **Trigger accuracy** | Over-trigger rate (Skill fires when it should not) | ≤ 5% | Negative test set evaluation |
| **Optimization performance** | AutoResearch success rate: raising < 75% to ≥ 90% | ≥ 80% | Optimization case tracking |
| **Optimization performance** | Average optimization convergence iteration count | ≤ 50 | Experiment trajectory statistics |
| **Cost efficiency** | Distilled lightweight model performance vs. flagship | ≥ 90% | Controlled evaluation |
| **System stability** | Quality regression events caused by new Skill deployment | 0 | Regression test monitoring |
| **Automation degree** | Proportion of Skill optimization tasks completed autonomously | ≥ 70% | Operations log statistics |
| **End-to-end efficiency** | Pipeline time: requirements input → deployment complete | ≤ 4 hours | End-to-end timestamps |

---

## 10. Risk Management Matrix

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

---

## 11. Appendix: SKILL.md Authoring Standards & Templates

### 11.1 Three-Layer Architecture Token Budget Standards

| Layer | Component | Character/Token Limit | Key Constraint |
|-------|-----------|----------------------|----------------|
| Level 1 | YAML Frontmatter `description` | ≤ 1024 characters | This is the sole LLM routing signal; must contain trigger verbs and exclusion contexts |
| Level 2 | Markdown body (SKILL.md) | ≤ 500 lines / 5000 tokens | Contains complete operational instructions, output templates, error handling |
| Level 3 | `scripts/` and `references/` | Unlimited | Accessed by the agent only when Level 2 instructions explicitly direct it |

### 11.2 Description Field Required Elements Checklist

After authoring, confirm all of the following elements are present:

- [ ] **Core action verbs** (≥ 2): generate, analyze, validate, extract, configure…
- [ ] **Specific task objects** (≥ 1): TypeScript code, SKILL.md file, MCP configuration…
- [ ] **Positive trigger contexts** (≥ 2): "when X needs to…", "when the user describes…"
- [ ] **Exclusion contexts** (≥ 1, strongly recommended): "does not handle…", "not applicable to…"
- [ ] **Avoid overly broad statements**: Never use "all AI-related tasks", "any code problem", etc.

### 11.3 Complete SKILL.md Template (using `meta-agent-factory` as example)

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

## Revision History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| v1.0 | 2026-03-23 | AI Agent Platform Development Team | Initial version. Based on enterprise AI agent legion deep research report. Covers five Skill specifications, four-phase development blueprint, AutoResearch optimization engine design, and Agentic CI/CD pipeline architecture. |

---

*This document is based on the "Enterprise-Grade AI Agent Legion Architecture & Automation Pipeline: A Deep Research Report on Meta-Agent Ecosystems Based on Claude Code Skills and AutoResearch." All architectural designs are grounded in the core principles of progressive disclosure, mutually exclusive permissions, and scalar metric-driven optimization.*
