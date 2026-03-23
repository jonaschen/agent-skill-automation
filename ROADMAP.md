# ROADMAP.md

Agent Skill Automation — Development Roadmap
**Status as of 2026-03-23: Phase 0 complete. Phase 1 in progress.**

---

## Overview

Four sequential phases over ~7 months. Each phase gates the next: Phase 2 requires a working
`meta-agent-factory`; Phase 3 requires a working eval runner from Phase 2.

```
Phase 0 ──► Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4
Repo setup  Factory     Validator   AutoResearch  Closed loop
(now)       (M1–2)      + CI/CD     + Distill     + Scale
                        (M3–4)      (M5–6)        (M7+)
```

---

## Phase 0: Repository Bootstrap *(complete ✅)*

**Goal:** Establish the directory structure and skeleton files so Phase 1 can begin immediately.

### Tasks

- [x] Create `.claude/agents/` directory with empty placeholder files for all five agents
- [x] Create `.claude/skills/` directory structure (one subdirectory per Skill)
- [x] Create `.claude/hooks/` directory with stub `pre-deploy.sh`, `post-tool-use.sh`, `stop.sh`
- [x] Create `eval/` directory with stub `run_eval.sh` and empty `prompts/` and `expected/` subdirs
- [x] Create `~/.claude/@lib/agents/` as the Changeling role library (read-only, global)
- [x] Write a bare-minimum `.mcp.json` template file

### Done When

- ✅ `find .claude/ -type f` shows the full directory tree matching the spec in Section 5.2 of the dev plan
- ✅ `eval/run_eval.sh` exists and exits non-zero (not yet implemented, but wired up)
- ✅ `~/.claude/@lib/agents/` exists with initial role definitions

---

## Phase 1: Meta-Agent Factory *(in progress)*

**Goal:** A working `meta-agent-factory` agent that can generate format-compliant, permission-correct
SKILL.md files from natural language requirements.

### Tasks

#### 1.1 SKILL.md authoring (the agent itself)
- [x] Write `.claude/agents/meta-agent-factory.md` using the full template from Section 11.3 of the dev plan
- [x] Validate the description field: ≤ 1024 characters, includes trigger verbs and exclusion contexts (550 chars ✅)
- [ ] Manually test all four example trigger prompts from Section 3.1 and confirm correct routing

#### 1.2 Permission validation logic
- [x] Write a static shell script `eval/check-permissions.sh` that reads a SKILL.md and fails if:
  - A review/validation agent has `Write` or `Edit` in its tools list
  - An execution agent has `Task` in its tools list
  - The `description` field exceeds 1024 characters
- [x] Test with deliberately broken SKILL.md files to confirm 100% catch rate

#### 1.3 End-to-end generation tests
- [ ] Test case 1: Generate a read-only architect Sub-agent → verify it lacks Write/Edit/Bash
- [ ] Test case 2: Generate an execution agent with Bash → verify it lacks Task
- [ ] Test case 3: Generate an agent requiring MCP → verify `.mcp.json` update is proposed
- [ ] Test case 4: Generate a Changeling role definition → verify it writes to `~/.claude/@lib/agents/`

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Format-compliant SKILL.md on first attempt | ≥ 90% of test cases |
| Mutually exclusive permission violation interception | 100% |
| Generation pipeline wall-clock time | ≤ 60 seconds |

---

## Phase 2: Quality Validator + CI/CD Gate *(Months 3–4)*

**Goal:** Objective, automated quality gating. No Skill deploys with trigger rate < 90% without human override.

### Tasks

#### 2.1 Eval runner (the most critical piece of Phase 2)
- [ ] Implement `eval/run_eval.sh <skill-path>` — runs 30 fixed test prompts, prints a single float pass rate
- [ ] Build `eval/prompts/test_{1..30}.txt` and `eval/expected/test_{1..30}.txt` for `meta-agent-factory`
- [ ] Confirm two runs on the same Skill differ by ≤ 5% (repeatability requirement)
- [ ] Build equivalent test sets (≥ 20 cases each) for each Skill as they are deployed

#### 2.2 `skill-quality-validator` agent
- [ ] Implement `.claude/agents/skill-quality-validator.md` (stub exists — complete with full 5-step pipeline)
- [ ] Implement the 5-step validation pipeline (frontmatter parse → description quality → test set generation → baseline → trigger rate measure)
- [ ] Output a JSON report: `{ "trigger_rate": 0.xx, "security_score": x, "recommendations": [...] }`
- [ ] Implement the 90%/75% threshold logic (Pass / Conditional / Fail)

#### 2.3 `agentic-cicd-gate` agent
- [ ] Implement `.claude/agents/agentic-cicd-gate.md` (stub exists — complete with full gate logic)
- [ ] Implement `.claude/hooks/pre-deploy.sh` that calls the validator and blocks deploys below threshold
- [ ] Implement Bayesian flaky test detector (`eval/flaky_detector.py`) with ≥ 5 run history requirement
- [ ] Implement git-based autonomous rollback: detect trigger rate drop > 10% → `git revert`
- [ ] Wire `post-tool-use.sh` and `stop.sh` hooks into the deployment monitoring flow

#### 2.4 Benchmark dataset
- [ ] Build hallucination risk test cases (deliberately misleading inputs) for each Skill
- [ ] Build cross-domain semantic conflict tests (ensure Skills do not over-trigger each other)

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Measurement repeatability (two runs, same Skill) | Diff ≤ 5% |
| Static analyzer detection of known format violations | ≥ 95% |
| CI/CD gate blocks all sub-threshold deployments | 100% |
| Flaky test auto-quarantine accuracy | ≥ 80% |

---

## Phase 3: AutoResearch Optimizer + Model Distillation *(Months 5–6)*

**Goal:** Unattended overnight optimization. A failing Skill (< 75%) is automatically repaired to ≥ 90% without human intervention.

### Tasks

#### 3.1 `autoresearch-optimizer` agent
- [ ] Write `.claude/agents/autoresearch-optimizer.md`
- [ ] Write `skill-optimizer-program.md` (the `program.md` equivalent — defines target, metric, budget, stop criteria)
- [ ] Implement base optimization loop: analyze failures → propose description edits → run eval → commit or revert via git
- [ ] Implement parallel branch search: Branch A (boundary conditions), B (minimal + script), C (few-shot), D (MDP-guided)

#### 3.2 Experiment tracking
- [ ] Build `eval/experiment_log.json` schema: records each iteration's branch, proposed change, pass rate, outcome
- [ ] Implement convergence check: stop when pass rate ≥ 0.90 or iterations = 50
- [ ] Add experiment trajectory viewer (simple shell script that prints the log as a table)

#### 3.3 MDP / PPO layer *(advanced — start only after base loop is stable)*
- [ ] Formalize experiment history as (state, action, reward) triples
- [ ] Implement PPO-guided modification direction as Branch D in the parallel search

#### 3.4 Heterogeneous model distillation
- [ ] Collect 100 successful Opus 4.6 output cases per Skill as baseline dataset
- [ ] Run distillation loop: Haiku 4.5 uses same SKILL.md → identify failure modes → add constraints/examples → re-eval
- [ ] Target: Haiku pass rate ≥ 90% of Opus baseline at ~15% of the token cost

#### 3.5 SkyPilot parallelization *(optional scale-out)*
- [ ] Design task distribution interface for spreading experiment branches across Kubernetes
- [ ] Implement result aggregation and convergence algorithm
- [ ] Build overnight batch scheduler

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| AutoResearch raises < 75% Skills to ≥ 90% | ≥ 80% success rate |
| Optimization convergence | ≤ 50 iterations / ≤ 8 hours |
| Distilled Haiku vs. Opus baseline performance | ≥ 90% |
| Parallel search vs. sequential time saving | ≥ 60% |

---

## Phase 4: Changeling Router + Full Closed Loop *(Month 7+, continuous)*

**Goal:** Fully unattended pipeline from natural language requirement to deployed Skill. Human role = experimental designer, not experimenter.

### Tasks

#### 4.1 `changeling-router` agent
- [ ] Write `.claude/agents/changeling-router.md`
- [ ] Build `~/.claude/@lib/agents/` enterprise role library with ≥ 20 standard role definitions
- [ ] Implement task type auto-identification: maps incoming task → correct role definition to load
- [ ] Validate role switching latency ≤ 2 seconds and full context reset between switches

#### 4.2 End-to-end closed-loop stress test
- [ ] Stress test: generate, validate, optimize, and deploy 50 new Skills within 24 hours
- [ ] Regression test: confirm no existing agent trigger rates degrade after new Skill deploy
- [ ] Cost analysis: measure full pipeline token consumption and wall-clock time per Skill

#### 4.3 Observability
- [ ] Build agent legion health dashboard (trigger rate trends, hallucination rates, cost by model)
- [ ] Implement Skill lifecycle tracking (created → validated → optimized → deployed → deprecated)
- [ ] Set up anomaly alerting (trigger rate drops, unexpected tool use patterns)

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| End-to-end pipeline: requirements → deployed Skill | ≤ 4 hours |
| Autonomous optimization completion (no human intervention) | ≥ 70% of tasks |
| Agent legion average trigger rate (monthly) | ≥ 90% |
| Quality regressions from new Skill deployments | 0 |

---

## Overall KPI Dashboard

| Category | Metric | Target |
|----------|--------|--------|
| Generation | First-attempt format compliance | ≥ 90% |
| Generation | Permission design error rate | 0% |
| Trigger accuracy | Average trigger rate, deployed Skills | ≥ 90% |
| Trigger accuracy | Over-trigger rate | ≤ 5% |
| Optimization | AutoResearch success rate (< 75% → ≥ 90%) | ≥ 80% |
| Optimization | Convergence iterations | ≤ 50 |
| Cost | Distilled Haiku vs. Opus performance | ≥ 90% |
| Stability | Regression events from new deployments | 0 |
| Automation | Tasks completed without human intervention | ≥ 70% |
| Efficiency | End-to-end pipeline time | ≤ 4 hours |

---

## Key Risks to Watch

| Risk | Phase | Mitigation |
|------|-------|-----------|
| Overfitting: optimizer achieves high eval score but fails in production | 3 | Strict 60/40 split; refresh test cases monthly |
| Eval measurement instability (LLM non-determinism) | 2 | Average ≥ 5 runs per assessment |
| AutoResearch API costs spiral | 3 | Token budget ceiling per task; Haiku for initial screening |
| Changeling context pollution (prior role bleeds into next) | 4 | Force full context reset; explicit forget boundaries in role defs |
| meta-agent-factory generates overly permissive tool access | 1 | `check-permissions.sh` static check in Phase 1; 100% catch rate required |

---

## Immediate Next Actions

1. ~~**Today**: Complete Phase 0 — create the directory skeleton~~ ✅ Done
2. **This week**: ~~Write `meta-agent-factory.md`~~ ✅ Done — manually test all four trigger prompts
3. **Before Phase 2**: Build `eval/run_eval.sh` — the eval runner is the foundation everything else depends on
