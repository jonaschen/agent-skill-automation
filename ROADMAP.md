# ROADMAP.md

Agent Skill Automation — Development Roadmap
**Status as of 2026-04-12: Phase 4 in progress. Fleet version BLOCKER: running v2.1.87, minimum v2.1.101 — human upgrade pending. Session state logging (JSONL) integrated into all 7 daily scripts. Dependency pinning gate implemented in pre-deploy.sh. Security: PASS. Changeling: 8/8 PASS. Eval expansion: blocked (no skill usage logs found). Countdowns: Haiku 3 retirement 7d (Apr 19), 1M context beta sunset 18d (Apr 30), Google I/O 37d (May 19-20), Phase 4 deadline 27d (May 9).**

---

## Overview

Seven sequential phases over ~13 months. Each phase gates the next: Phase 2 requires a working
`meta-agent-factory`; Phase 3 requires a working eval runner from Phase 2; Phase 5 requires the
full Phases 1–4 automation foundation; Phase 6 requires distilled lightweight models from Phase 3.

```
Phase 0 ──► Phase 1 ──► Phase 2 ──► Phase 3 ──► Phase 4 ──► Phase 5 ──► Phase 6 ──► Phase 7
Repo        Factory     Validator   AutoResearch  Closed      Topology    Edge AI     AaaS
setup       (M1–2)      + CI/CD     + Distill     loop        + Multi-    + Cloud-    Billing
(done)                  (M3–4)      (M5–6)        (M7+)       Agent       Edge        + HA
                                                              (M8–9)      (M10–11)    (M12+)
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

- ✅ `find .claude/ -type f` shows the full directory tree matching the spec in Section 7.2 of the dev plan
- ✅ `eval/run_eval.sh` exists and exits non-zero (not yet implemented, but wired up)
- ✅ `~/.claude/@lib/agents/` exists with initial role definitions

---

## Phase 1: Meta-Agent Factory *(complete ✅)*

**Goal:** A working `meta-agent-factory` agent that can generate format-compliant, permission-correct
SKILL.md files from natural language requirements.

### Tasks

#### 1.1 SKILL.md authoring (the agent itself)
- [x] Write `.claude/agents/meta-agent-factory.md` using the full template from Section 14.3 of the dev plan
- [x] Validate the description field: ≤ 1024 characters, includes trigger verbs and exclusion contexts (550 chars ✅)
- [x] Manually test all four example trigger prompts from Section 4.1 and confirm correct routing

#### 1.2 Permission validation logic
- [x] Write a static shell script `eval/check-permissions.sh` that reads a SKILL.md and fails if:
  - A review/validation agent has `Write` or `Edit` in its tools list
  - An execution agent has `Task` in its tools list
  - The `description` field exceeds 1024 characters
- [x] Test with deliberately broken SKILL.md files to confirm 100% catch rate

#### 1.3 End-to-end generation tests
- [x] Test case 1: Generate a read-only architect Sub-agent → verify it lacks Write/Edit/Bash
- [x] Test case 2: Generate an execution agent with Bash → verify it lacks Task
- [x] Test case 3: Generate an agent requiring MCP → verify `.mcp.json` update is proposed
- [x] Test case 4: Generate a Changeling role definition → verify it writes to `~/.claude/@lib/agents/`

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Format-compliant SKILL.md on first attempt | ≥ 90% of test cases |
| Mutually exclusive permission violation interception | 100% |
| Generation pipeline wall-clock time | ≤ 60 seconds |

---

## Phase 2: Quality Validator + CI/CD Gate *(complete ✅)*

**Goal:** Objective, automated quality gating. No Skill deploys with trigger rate < 90% without human override.

### Tasks

#### 2.1 Eval runner (the most critical piece of Phase 2)
- [x] Implement `eval/run_eval.sh <skill-path>` — runs fixed test prompts, prints a single float pass rate
- [x] Build `eval/prompts/test_{1..30}.txt` and `eval/expected/test_{1..30}.txt` for `meta-agent-factory`
- [x] Add rate-limit resilience: retry logic (MAX_RETRIES=3), SKIP:rate-limit result, pass rate over executed tests only
- [ ] Formally confirm two runs differ by ≤ 5% (repeatability) — awaiting clean baseline run
- [x] Adversarial test cases: 9 hallucination/near-miss prompts (test_31–39); 4 cross-domain conflict tests (test_41–44)

#### 2.2 `skill-quality-validator` agent
- [x] Implement `.claude/agents/skill-quality-validator.md` with full 5-step pipeline
- [x] Output a JSON report: `{ "trigger_rate": 0.xx, "security_score": x, "recommendations": [...] }`
- [x] 90%/75% threshold logic (Pass / Conditional / Fail)

#### 2.3 `agentic-cicd-gate` agent
- [x] Implement `.claude/agents/agentic-cicd-gate.md` with full gate logic
- [x] Implement `.claude/hooks/pre-deploy.sh` — calls eval runner, blocks deploys below threshold
- [x] Implement `eval/flaky_detector.py` — Bayesian flaky test detector with ≥ 5 run history *(G5)*
- [x] Git-based rollback logic defined in agent; `post-tool-use.sh` and `stop.sh` hooks exist
- [x] Wire `post-tool-use.sh` and `stop.sh` hooks into deployment monitoring flow

#### 2.4 Benchmark dataset
- [x] Hallucination risk test cases (test_31–39): prompts that sound like agent creation but aren't
- [x] Cross-domain semantic conflict tests: 4 near-misses between meta-agent-factory and autoresearch-optimizer *(G5b)*
- [x] **G13**: Trigger pattern audit — case-insensitive matching + `write permission` pattern added to `run_eval_async.py`
- [x] **G18**: 10 near-miss negative controls (test_45–54) — prompts containing agent vocabulary but clearly direct tasks. Added to Training set T. `splits.json` updated (T=36, V=18).

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Measurement repeatability (two runs, same Skill) | Diff ≤ 5% |
| Static analyzer detection of known format violations | ≥ 95% |
| CI/CD gate blocks all sub-threshold deployments | 100% |
| Flaky test auto-quarantine accuracy | ≥ 80% |

---

## Phase 3: AutoResearch Optimizer + Async Architecture *(core complete ✅)*

**Goal:** Unattended overnight optimization and reliable, async evaluation. A failing Skill (< 75%) is automatically repaired to ≥ 90% without human intervention.

### Tasks

#### 3.1 Async Architecture (Mandatory Gate)
- [x] **S2 (G9)**: Implement `eval/run_eval_async.py` (asyncio + semaphore + backoff). **Status: ✅**
- [x] **S1 (G10)**: Implement `eval/bayesian_eval.py` (posterior + credible intervals). **Status: ✅**
- [x] **S3 (G11)**: Implement `eval/prompt_cache.py` (semantic cache). **Status: ✅**
- [x] **G12**: Update `pre-deploy.sh` to enforce Bayesian gates. **Status: ✅**

#### 3.2 `autoresearch-optimizer` agent
- [x] Write `.claude/agents/autoresearch-optimizer.md` — full 5-stage loop with parallel branch search (A/B/C/D)
- [x] Write `skill-optimizer-program.md` — defines target Skill, metric, budget, stop criteria
- [x] **G7b**: Repeatability baseline — Training: 0.895 CI [0.781, 0.970], 33/36 PASS, 0 skips. Validation: 0.600 CI [0.384, 0.797], 11/18 PASS. `--inter-test-delay 15` eliminated quota burst. ✅
- [x] **G8 Iter 1**: Description refined — added "I need a Skill for X", "workflow automation", "create an X expert" triggers; strengthened exclusions for fix/debug/analyze existing. Training: **0.921** CI [0.818, 0.983], 34/36. Validation: **0.800** CI [0.604, 0.940], 15/18. ✅
- [x] **G8 Iter 2**: Added ROUTING RULE (create/build intent always routes to meta-agent-factory even when domain agents exist), EXCLUSION RULE (existing agent/Skill modification routes elsewhere), explicit domain disambiguation (AOSP, Changeling examples). Training: **0.895** CI [0.781, 0.970], 33/36. Validation: **0.900** CI [0.740, 0.987], 17/18. Remaining failures: Test 11 (Changeling routing conflict), Test 41 (false positive on existing Skill improvement), stochastic noise on 1–2 positives. ✅
- [ ] Validate parallel branch search actually runs all 4 branches per iteration *(after G8)*
- [x] Implement optimizer state persistence: `best_so_far` + `current_description` fields in `eval/experiment_log.json` schema; resume-from-log logic in optimizer agent definition — P2 ✅ 2026-04-06

#### 3.3 Experiment tracking
- [x] `eval/experiment_log.json` schema defined
- [x] Experiment trajectory viewer: `eval/show_experiments.sh` — prints log as a human-readable table *(G6)*
- [ ] Convergence check: confirmed working after first live run

#### 3.4 MDP / PPO layer *(advanced — start only after base loop is stable)*
- [ ] Formalize experiment history as (state, action, reward) triples
- [ ] Implement PPO-guided modification direction as Branch D in the parallel search

#### 3.5 Heterogeneous model distillation
- [ ] Collect 100 successful Opus 4.6 output cases per Skill as baseline dataset
- [ ] Run distillation loop: Haiku 4.5 uses same SKILL.md → identify failure modes → add constraints/examples → re-eval
- [ ] Target: Haiku pass rate ≥ 90% of Opus baseline at ~15% of the token cost
- [ ] Evaluate Sonnet+Opus advisor as intermediate distillation tier (Opus → Sonnet+advisor → Haiku+advisor → Haiku standalone). Advisor tool is beta (`advisor_20260301`); verify API stability before detailed experiment design — P3

#### 3.6 SkyPilot parallelization *(optional scale-out)*
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

## Phase 4: Changeling Router + Full Closed Loop *(current)*

**Goal:** Fully unattended pipeline from natural language requirement to deployed Skill. Human role = experimental designer, not experimenter.

**Deadline (2026-04-08)**: All Phase 4 tasks must be complete or explicitly deferred by **May 9, 2026** (Friday before Google I/O week May 19-20). I/O will trigger a cascade of required updates — Phase 4 should be stress-tested before then.

### Tasks

#### 4.1 `changeling-router` agent
- [x] Write `.claude/agents/changeling-router.md` (stub — full implementation Phase 4)
- [x] Build `~/.claude/@lib/agents/` enterprise role library with ≥ 20 standard role definitions
  - [x] **G16**: Initial 8 roles built: security-auditor, perf-analyst, database-administrator, frontend-expert, devops-specialist, python-architect, qa-engineer, product-owner ✅
  - [x] **Phase 4**: Expanded to 23 roles — added api-designer, cloud-architect, data-engineer, ml-engineer, mobile-developer, network-engineer, technical-writer, compliance-officer, site-reliability-engineer, backend-architect, accessibility-specialist, cost-analyst, golang-expert, rust-expert, incident-commander ✅
  - [x] Fixed eval cleanup bug — snapshot-based cleanup protects pre-existing roles ✅
- [x] Implement task type auto-identification: two-phase routing (keyword match → semantic disambiguation) with 23-row routing table ✅
- [x] Validate role switching infrastructure: `eval/changeling_validation.sh` — 8-check static validator (library completeness, frontmatter validity, routing table coverage, keyword overlap detection, context reset instructions, router config). All 23 roles pass. Runtime latency validation deferred to 50-Skill stress test ✅ 2026-04-09

#### 4.2 End-to-end closed-loop stress test
- [x] Build closed-loop orchestrator (`scripts/closed_loop.sh`) — factory→validate→optimize→deploy pipeline ✅
- [x] **Stress test requirements**: Created `eval/stress_test_requirements.txt` — 50 diverse skill specifications across 8 categories (DevOps 10, Security 8, Data/ML 8, Frontend 6, Backend 6, Mobile 4, Infra 4, Specialized 4). Ready for `scripts/closed_loop.sh` execution ✅ 2026-04-09
- [ ] Stress test execution: run `scripts/closed_loop.sh eval/stress_test_requirements.txt` — generate, validate, optimize, and deploy all 50 Skills within 24 hours
- [ ] **10-Skill pilot kickoff prepared** (2026-04-12): `scripts/run_stress_pilot.sh` + `eval/stress_test/pilot_10.txt` (1 per category, 10 diverse requirements). Pilot handles cron pause/resume automatically. Expected wall-clock 8-12h. Gate rationale: if pilot succeeds with ≥8/10 DEPLOYED, Phase 4.2 gate is partially met and the 50-in-24h target becomes a parallelization question for Phase 5. Kickoff: `./scripts/run_stress_pilot.sh` (human-triggered only — multi-hour execution exceeds single steward session budget)
- [x] **Regression test script**: `scripts/regression_test.sh` — runs eval suite, computes Bayesian posterior, compares against stored baseline. Supports `--update-baseline`, `--check-only`, auto-comparison modes. Detects regression when CI lower drops >0.05 below baseline ✅ 2026-04-09
- [x] **Regression baseline established**: `eval/regression_baseline.json` — T=0.895, 33/36, CI [0.781, 0.970]. Fixed bayesian_eval.py to support `--passes`/`--total` args; removed scipy dependency from regression_test.sh fallback path ✅ 2026-04-10
- [ ] Regression test: run regression_test.sh after stress test to confirm no existing agent trigger rates degrade
- [x] Cost analysis infrastructure: `scripts/pipeline_cost_analysis.py` — reads stress_test_log.json for per-skill pipeline cost + fleet daily compute from perf JSONs. Fleet baseline: 3.3h/day across 6 agents ✅ 2026-04-09
- [ ] Cost analysis: run 50-skill stress test and report full pipeline token consumption and wall-clock time per Skill

#### 4.3 Observability
- [x] Build agent legion health dashboard (`scripts/health_dashboard.py`) ✅
- [x] Implement Skill lifecycle tracking (`eval/lifecycle_tracker.py`) ✅
- [x] Set up anomaly alerting (`scripts/anomaly_alerter.py`) — regression, stall, cost detection ✅
- [x] Implement hooks: `post-tool-use.sh` (lifecycle logging + permission check), `stop.sh` (graceful shutdown) ✅
- [x] **Effort impact analysis tool**: `scripts/effort_impact_analysis.sh` — compares agent durations before/after effort default change, checks cost ceiling alerts, recommends per-agent effort overrides. Supports 3-day monitoring window (Apr 9-12) ✅ 2026-04-09
- [x] **Thinking mode tracking**: Added `thinking_mode` field to all 7 daily script performance JSONs. Records `"default"` for current fleet config. Supports debugging future effort/duration anomalies if thinking configuration changes ✅ 2026-04-11
- [x] **Effort monitoring window closed**: 3-day analysis (Apr 9-12) complete. Results: 5/6 agents stable/improved (factory -16%, researcher -7%, arm-mrs -7%, bsp -35%, reviewer -26%), android-sw +23% (within normal day-to-day variance, not actionable), 0 cost ceiling alerts. No effort overrides needed — default thinking mode sufficient for all agents ✅ 2026-04-11
- [x] **Workflow convergence pattern note**: Created `knowledge_base/agentic-ai/evaluations/workflow-state-convergence.md` — three-way convergence analysis (ADK lazy scan dedup, Vercel WDK deterministic replay, our state machine skip). Design reference for Phase 5.3.2 task-level workflow state tracking ✅ 2026-04-11
- [x] **Session state logging**: Created `scripts/lib/session_log.sh` — shared library with `log_event(type, payload)` writing append-only JSONL to `logs/sessions/{agent}-{date}.jsonl`. Event types: SESSION_START, TASK_START, TASK_COMPLETE, TASK_SKIP, ERROR, CHECKPOINT, SESSION_END. Integrated into all 7 daily scripts (factory, researcher, android-sw, arm-mrs, bsp-knowledge, ltc, reviewer). 30-day retention. Foundation for Phase 5.3.2 task-level workflow state tracking. Crash-recovery logic deferred to Phase 5 ✅ 2026-04-12

#### 4.4 Security hardening for autonomous execution
- [x] Implement `scripts/cmd_chain_monitor.sh` — command-chain length monitor (alert >30, block >45 subcommands) ✅ 2026-04-04
- [x] Integrate `cmd_chain_monitor.sh` into `.claude/hooks/post-tool-use.sh` — Bash tool calls now checked for deny-rule bypass via long command chains (alert >30, block >45 subcommands) ✅ 2026-04-08
- [x] Add MCP config validation step to CI/CD gate (`eval/mcp_config_validator.sh` — validates JSON, required fields, deprecated auth patterns, placeholder env vars) ✅ 2026-04-04
- [x] Extend `eval/mcp_config_validator.sh` with static content scanning: injection phrase detection, length limits, credential keyword rejection, allowlist bypass (`eval/mcp_server_allowlist.json`) — P0 ✅ 2026-04-05
- [x] Lock Python deps (`requirements.txt`) + `npm audit --audit-level=high` (warning) in pre-deploy.sh — P1 ✅ 2026-04-05
- [x] Create `eval/model_migration_runbook.md` — re-baseline steps for new model releases (separate positive/negative analysis, CI comparison, optimizer trigger criteria, routing regression check) — P1 ✅ 2026-04-05
- [x] Add MCP server allowlist instruction to meta-agent-factory.md — P1 ✅ 2026-04-06
- [x] Add MCP hash-based tool definition pinning to `mcp_config_validator.sh` for rug pull detection (OWASP MCP03 variant 3) — P1 ✅ 2026-04-06
- [x] Create `eval/assumption_registry.md` — centralized model-assumption mapping for stress testing during model migration; cross-referenced from migration runbook Step 6 — P2 ✅ 2026-04-06
- [x] Fix eval trigger detection patterns — factory output format evolved (markdown bold `**Tools granted**:`, creation phrases `write to .claude/agents/`) but detection didn't track (L10) — CRITICAL ✅ 2026-04-06
- [x] Refactor `scripts/closed_loop.sh` into state machine: conditional skip (>=0.95), SECURITY_SCAN node, OPTIMIZE->VALIDATE retry counter (max 3), explicit REPORT_FAILURE state — P2 ✅ 2026-04-06
- [x] Add MCP tool-call depth monitor to `post-tool-use.sh` — pattern-matches `mcp__*` tool names, per-session counter, alert at 15 calls, block at 25 calls, structured JSON alerts to `logs/security/mcp_depth_alert.jsonl`. Defends against 658x MCP cost amplification attacks (Adversa AI finding) — P0 ✅ 2026-04-07
- [x] Implement duration-based cost ceiling (`scripts/lib/cost_ceiling.sh`) — 30-day rolling average × 5x multiplier, fallback 3600s for first run. Integrated into `daily_factory_steward.sh` as pilot; advisory post-run check with structured alerts to `logs/security/cost_alert.jsonl` — P0 ✅ 2026-04-07
- [x] Roll cost ceiling to remaining 5 steward scripts (`daily_research_sweep.sh`, `daily_android_sw_steward.sh`, `daily_arm_mrs_steward.sh`, `daily_bsp_knowledge_steward.sh`, `daily_project_reviewer.sh`) — P1 ✅ 2026-04-07
- [x] **CVE-2026-35020 mitigation**: `unset TERMINAL` preamble in all 6 daily scripts — defense-in-depth against CVSS 8.4 OS command injection via TERMINAL env var — P0 ✅ 2026-04-08
- [x] **Initiator-type env var + enforcement**: Export `CLAUDE_INITIATOR_TYPE=cron-automated` in all daily scripts; `post-tool-use.sh` blocks destructive git ops (`push --force`, `reset --hard`, `branch -D`, `checkout -- .`, `clean -f`) in cron context. Structured alerts to `logs/security/initiator_policy.jsonl`. AWS IAM context key pattern — P1 ✅ 2026-04-08
- [x] **Model deprecation guard**: `eval/model_deprecation_check.sh` + `eval/deprecated_models.json` (append-only, researcher-maintained). Greps agent configs for deprecated model IDs; fails pre-deploy gate when referenced model retires within 30 days — P1 ✅ 2026-04-08
- [x] **Security suite aggregator**: `eval/security_suite.sh` — runs permissions, MCP config, model deprecation, and dependency audit in sequence; versioned JSON report (v1.0). Wired into `pre-deploy.sh` and `closed_loop.sh` SECURITY_SCAN node. Also fixed `check-permissions.sh` false positive on orchestration agents with Task tool (project-reviewer) — P1 ✅ 2026-04-08
- [x] **Researcher agent: automated deprecation + I/O tracking**: Extended `agentic-ai-researcher.md` with (1) automated `eval/deprecated_models.json` maintenance (append-only, official sources only, feeds pre-deploy guard), (2) Google I/O-specific sweep queries (ADK v2.0, Gemini 4, A2A v1.1 tracking through May 2026) — P2 ✅ 2026-04-08
- [x] **Fix BSP `graph_nodes` perf metric**: Changed kuzu DB connection to `read_only=True` in `daily_bsp_knowledge_steward.sh` — prevents lock conflicts when EXIT trap fires while Claude session may still hold the database. Added diagnostic logging on failure. Bug persisted 4 days — P2 ✅ 2026-04-08
- [x] **Write steering notes for escalated stewards**: Created `.claude/steering-notes.md` in ARM MRS repo (P0: update arm-pmu.md, P1: define post-H8 milestones) and BSP Knowledge repo (P1: fix orphan graph nodes, P2: fix CLAUDE.md phase status) — acting on project-reviewer escalations — P1 ✅ 2026-04-08
- [x] **Effort level tracking + config**: Added `effort_level` field to all 6 performance JSONs; prepared commented-out `CLAUDE_CODE_EFFORT` exports in all daily scripts (high for reasoning-heavy agents, medium for routine). Monitor 3 days (through April 12), enable selectively if costs spike >50% — P1 ✅ 2026-04-09
- [x] **Steward cross-project deprecation check**: Added `scripts/lib/check_target_deprecations.sh` — shared helper runs `deprecated_models.json` check against target repo `.claude/` dirs. Integrated into android-sw, arm-mrs, bsp-knowledge steward scripts as pre-flight warning (never blocks). Logs to steering notes if deprecated models found — P1 ✅ 2026-04-09
- [x] **Deprecated models verification**: Confirmed `claude-3-haiku-20240307` entry in `deprecated_models.json` with correct retirement date (2026-04-19) and replacement model. Verified `model_deprecation_check.sh` grep pattern handles both old (date-suffix) and new (version-suffix) model ID formats — P0 ✅ 2026-04-09
- [x] **Permission cache design doc**: Created `knowledge_base/agentic-ai/evaluations/permission-cache-design.md` — policy-focused design for Phase 5.5 HITL session-scoped permission cache (auto-approve patterns, expiry model, initiator-type interaction, subagent inheritance rules). Informed by Gemini CLI v0.38.0 context-aware approvals — P2 ✅ 2026-04-09
- [x] **Agent review dashboard: effort monitoring**: Enhanced `scripts/agent_review.sh` with effort_level display from perf JSONs + duration trend lines (last 3 runs, oldest→newest). Directly supports 3-day effort monitoring window for cost impact assessment — P1 ✅ 2026-04-09
- [x] **Prototype collision audit**: Grepped `.claude/` configs for JS prototype property names (toString, valueOf, hasOwnProperty, constructor, __proto__). Clean — zero matches. Closes audit gap from v2.1.97 changelog — P0 ✅ 2026-04-10
- [x] **Fleet version check**: Created `scripts/lib/check_fleet_version.sh` + `scripts/lib/fleet_min_version.txt` (>=2.1.97). Sourced from all 6 daily scripts. Warns on version mismatch, never blocks. Picks up MCP memory leak fix, 429 retry fix, and permission hardening — P1 ✅ 2026-04-10
- [x] **Fleet minimum version bump to >=2.1.98**: Updated `fleet_min_version.txt`. v2.1.98 adds PID namespace isolation and compound command hardening. Human upgrade pending — P0 ✅ 2026-04-11
- [x] **Metacharacter pattern detection**: Added detect-only metacharacter pattern detection to `cmd_chain_monitor.sh`. Scope: Claude-generated Bash tool inputs. Binary-level allowlist (60+ safe binaries) — each command in a chain is checked; if ALL are safe, logged as "safe", otherwise "advisory". Logs structured JSON alerts to `logs/security/metachar_alert.jsonl`. METACHAR_MODE env var supports future "block" mode. 30-day baseline for Phase 5.5 PreToolUse allowlist calibration started ✅ 2026-04-11
- [x] **Fleet minimum version bump to >=2.1.101**: Updated `fleet_min_version.txt`. v2.1.99-101 add memory leak fix (long sessions), `permissions.deny` enforcement fix, subagent MCP tool inheritance, command injection fix in POSIX `which` fallback, OS CA cert store trust. Enhanced `check_fleet_version.sh` with structured JSON alerts to `logs/security/fleet_version.jsonl` (timestamp, versions, days-since-escalation). Added "Fleet Version Status" section to `agent_review.sh` dashboard ✅ 2026-04-12
- [x] **Post-I/O response playbook**: Created `knowledge_base/agentic-ai/evaluations/post-io-response-playbook.md` — 6-category announcement matrix (new model, agent framework, A2A protocol, platform rebrand, edge model, MCP changes) with per-category action tables, pre-I/O checklist, I/O day manual triggers, post-I/O stabilization steps ✅ 2026-04-12
- [ ] **`mcp-sec-audit` standalone evaluation**: Time-boxed 2-4 hour evaluation — confirm installability, marginal value over existing scanner, static-only analysis mode. Prerequisite for CI/CD gate integration — P2 (deferred from 2026-04-07 discussion)
- [ ] **MCP security suite consolidation**: When 4+ MCP security components exist, consolidate into unified `eval/mcp_security_suite.sh` — P3 (deferred from 2026-04-07 discussion; premature until components exist)

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| End-to-end pipeline: requirements → deployed Skill | ≤ 4 hours |
| Autonomous optimization completion (no human intervention) | ≥ 70% of tasks |
| Agent legion average trigger rate (monthly) | ≥ 90% |
| Quality regressions from new Skill deployments | 0 |

---

## Phase 5: Topology-Aware Routing + Multi-Agent Orchestration *(Months 8–9)*

**Goal:** Upgrade from dynamic identity switching to a parallel-collaborative AI Scrum Team with intelligent pre-execution routing. Prevent the Sequential Penalty on highly coupled tasks.

**Prerequisite:** Phases 1–4 complete and stable.

### Tasks

#### 5.1 Task Coupling Indexer (TCI)
- [x] **G14+G17**: Implement `eval/tci_compute.py` — four-dimension scoring using real git/filesystem state ✅
- [ ] Build 50-task human-labeled benchmark (25 low-coupling, 25 high-coupling), frozen at phase start
- [ ] Validate TCI computation completes in ≤ 5 seconds per task

#### 5.2 `topology-aware-router` agent
- [x] **C17**: Write `.claude/agents/topology-aware-router.md` — TCI computation, dual-track routing, Track B escalation, routing decision log ✅
- [ ] Implement routing decision log (stores TCI score, selected track, and task outcome for feedback loop)
- [ ] Test Track B conservative default for medium-coupling band (0.35–0.65)

> **Design note (2026-04-11)**: The Anthropic Advisor Tool (`advisor_20260301`, public beta) creates a fourth topology option for medium-coupling tasks (TCI 0.35-0.65): a Sonnet executor consults Opus at 2-3 key decision points (approach planning, stuck recovery, completion verification). Cost: -11.9% vs pure Opus; quality: +2.7pp SWE-bench. Re-evaluate when advisor reaches GA and Phase 5 implementation begins. Do not hardcode TCI routing ranges until then.

#### 5.3.0 A2A protocol evaluation (pre-implementation gate)
- [ ] Evaluate A2A v1.1 SDK integration patterns for scrum-team-orchestrator transport (Linux Foundation, gRPC, Agent Cards, **8-org TSC governance confirmed 2026-04-07**). **Expanded scope**: not just "can A2A express our 6 message types?" but "what SDK integration pattern gives us A2A-native transport?" Python A2A SDK is the expected implementation target. Write findings to `knowledge_base/agentic-ai/evaluations/a2a-sdk-eval.md` — P2 **Deferred to post-Google I/O (after May 20, 2026)**. A2A v1.1 expected at I/O; evaluating v1.0 before then wastes effort. Continue monitoring pre-I/O leaks.

**Design principle (2026-04-10)**: Implement the 6-message-type bus directly on the A2A Python SDK — not as a custom protocol with an A2A wrapper. A2A is now the de facto inter-agent standard (150+ orgs, triple hyperscaler integration). Our message types map to A2A Task metadata.

#### 5.3.2 Task-level workflow state tracking (JSON)
- [ ] Extend `health_dashboard.py` with per-step state tracking (pending/running/completed/failed) for multi-agent workflows. Reference: ADK v2.0.0-alpha.3 lazy scan dedup + Vercel WDK deterministic replay. Output: structured JSON, not web UI (web visualization is Phase 7 observability chrome) — P2

> **Design note (2026-04-11)**: When adopting Agent SDK for fleet execution, separate CLAUDE.md into static base (cacheable across agents) and dynamic session context (per-agent: git status, memory, date). Reference: Agent SDK `exclude_dynamic_sections` on `SystemPromptPreset`. Implementation consideration: current CLAUDE.md mixes static architecture descriptions with dynamic status — a structural split (`CLAUDE_BASE.md` + `CLAUDE_STATUS.md`) would be needed.

#### 5.3 `scrum-team-orchestrator` agent + A2A bus
- [ ] Write `.claude/agents/scrum-team-orchestrator.md` — PO/Dev/QA context forking, typed A2A message schema
- [ ] Implement A2A message bus with six valid message types only (TASK_ASSIGNMENT, PARTIAL_OUTPUT, REVIEW_REQUEST, REVIEW_RESULT, ESCALATION, WATCHDOG_HALT)
- [ ] Enforce message schema validation — untyped agent-to-agent chat is prohibited
- [ ] Test Track A: parallel frontend/backend Skill generation, confirm zero message loss

#### 5.3.1 Skill lifecycle automation (planning)
- [x] **Eval expansion audit mode**: Added `promote_cases.py --audit` — auto-discovers skill_usage_log.jsonl from instrumented projects (including nested directory structures), reports volume vs. 50-invocation threshold, analyzes novel prompts vs. existing eval suite, identifies promotion candidates. Currently: 38 entries across 2 projects, 9 novel cases (approaching 50 threshold). ✅ 2026-04-10
- [ ] **Auto-promotion design**: Extend `promote_cases.py` with `--auto-detect` mode — count skill-name + trigger-verb pairs, surface promotion candidates when threshold exceeded (>5 same-verb triggers). Requires >100 logged invocations. Minimal viable version of Gemini CLI's passive skill extraction — P2 (2026-04-07 analysis)

#### 5.4 `watchdog-circuit-breaker` agent
- [ ] Write `.claude/agents/watchdog-circuit-breaker.md` (Haiku model — no reasoning, monitoring only)
- [ ] Implement loop detection: halt when any agent pair exceeds 8 messages
- [ ] Implement token velocity monitor: halt when >5,000 tokens/min (Track A) or >15,000 tokens/min (Track B)
- [ ] Test WATCHDOG_HALT broadcast reaches all active agents and freezes task thread
- [ ] Monitor process RSS alongside token velocity — alert on sustained >200MB/hr growth. Thresholds TBD from real Phase 5 session profiles

#### 5.5 Defensive architecture (Pre-Execution Reflection + HITL)
- [ ] Implement `PreToolUse` hook: mandatory reflection gate for DESTRUCTIVE tools (Write, Edit, Bash, MCP write/delete)
- [ ] Define HITL tier classifications in YAML Frontmatter for all Phase 1–4 Skills
- [ ] Test Tier 3 gate: confirm architectural changes require synchronous human approval before proceeding

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| TCI computation speed | ≤ 5 seconds per task |
| TCI routing accuracy | ≥ 95% on 50-task benchmark |
| Track B token savings vs. Track A on high-coupling tasks | ≥ 40% fewer tokens |
| Track B compilation success rate vs. Track A | ≥ 25% higher |
| A2A message loss rate in Track A | 0% |
| Watchdog loop detection rate | ≥ 99% (< 1% miss rate) |
| Watchdog false positive rate | < 2% |

---

## Phase 6: Edge AI Integration + Cloud-Edge Hybrid *(Months 10–11)*

**Goal:** Deploy distilled Skills to resource-constrained edge devices. Implement the Talker-Reasoner dual-track architecture. Zero-latency local interaction; async cloud escalation.

**Prerequisite:** Phase 3 distillation pipeline complete; at least one distilled Haiku-class Skill exists.

### Tasks

#### 6.1 Edge Readiness Assessment gate
- [ ] Implement `eval/edge_readiness.py` — five-criterion pass/fail gate (model size ≤ ~1.5GB for Gemma 4 E2B/E4B, tool dependencies, latency, data classification, state management)
- [ ] Apply assessment to all existing Phase 1–4 Skills; document which are edge-eligible

#### 6.2 `edge-talker-agent`
- [ ] Write `.claude/agents/edge-talker-agent.md` — on-device System 1 definition
- [ ] Implement local belief state schema (compressed snapshot of agent world model)
- [ ] Define all five escalation triggers (complexity, knowledge gap, state conflict, security boundary, model confidence)
- [ ] Implement async task queue: stages complex tasks without blocking local responses

#### 6.3 `cloud-reasoner-agent`
- [ ] Write `.claude/agents/cloud-reasoner-agent.md` — async System 2 definition
- [ ] Integrate with Track B topology for edge-escalated tasks
- [ ] Implement model weight push: Cloud Reasoner pushes updated Haiku weights to Edge Talker on OTA schedule

#### 6.4 Model packaging pipeline (target: Gemma 4 E2B/E4B)
- [ ] Implement `eval/edge_package.sh` — exports SKILL.md + model weights to `.edge-skill` bundle
- [ ] Support ONNX export for CPU/NPU and GGUF for ARM/Apple Silicon (Gemma 4 supported by llama.cpp, Ollama, vLLM)
- [x] Evaluate Gemma 4 E2B zero-shot function calling (86.4% tool use) — eliminates fine-tuning step ✅ 2026-04-04 (confirmed: native function calling, <1.5GB, standard runtimes)
- [ ] Optional: Evaluate EAGLE3 speculative decoding for Gemma 4 — 1.72x speedup with 277MB draft head. Note: verify serving framework compatibility with Gemma 4 hybrid attention

> **Inference SLA note (2026-04-11)**: Gemma 4 MTP heads are stripped from public HuggingFace weights; MTP only available via Google's proprietary LiteRT. Plan inference latency targets accordingly: AICore/LiteRT deployments get 1.8x MTP speedup; self-hosted (vLLM/Ollama/llama.cpp) gets 1.0x baseline without EAGLE3, ~1.72x with EAGLE3 draft head (277MB additional). Qwen 3.5 at 35 tok/s vs Gemma 4 at 11 tok/s on same hardware provides an alternative if latency dominates over open-weight control.

- [ ] Implement secure OTA: SHA-256 verification + code signing + atomic apply + rollback on failed post-update eval

#### 6.5 Cloud-edge state synchronization
- [ ] Implement MQTT QoS 1 push (60s periodic sync) and gRPC streaming delta pull (on connect)
- [ ] Conflict resolution: cloud wins on shared fields; edge wins on device-local fields
- [ ] Test: 30-minute network isolation → reconnect → confirm zero mutation data loss

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Edge Talker offline functionality | Basic interaction maintained during 30-min disconnection test |
| End-to-end latency reduction (edge vs. cloud-only) | ≥ 40% |
| Edge task success rate vs. cloud flagship | ≥ 85% on 100-task benchmark |
| State synchronization consistency | Zero data loss across reconnection cycle |
| OTA update rollback success rate | 100% on failed post-update eval |

---

## Phase 7: AaaS Commercialization + Cross-Regional Operations *(Month 12+)*

**Goal:** Turn the agent platform into a commercial Agent-as-a-Service product: Outcome-Based Pricing, multi-tenancy, cross-regional HA, and regulatory compliance.

**Prerequisite:** Phases 1–6 complete; production traffic available for billing instrumentation.

**Design consideration (2026-04-07)**: Two deployment models are emerging — CLI-native (SKILL.md files for Claude Code/Gemini CLI) and cloud-native (persistent services via Conway/A2A/Gemini Enterprise). Phase 7 AaaS should support both: local SKILL.md for developer consumption + distributable packages for cloud platforms. Conway's `.cnw.zip` and A2A agent registration are candidate bridge mechanisms.

**Deployment targets (2026-04-09)**: Three distinct deployment targets, each serving a different market:
1. **SKILL.md** (local, CLI) — developer consumption via Claude Code / Gemini CLI
2. **Managed Agents** (cloud, API) — enterprise consumption via `ant` CLI or Anthropic API (contingent on Managed Agents GA)
3. **Conway** (product, persistent) — end-user consumption via persistent cloud agents (contingent on Conway shipping)

Cross-platform SKILL.md format comparison required before transpiler work begins.

### Tasks

#### 7.1 `outcome-billing-engine` agent + OpenTelemetry instrumentation
- [ ] Write `.claude/agents/outcome-billing-engine.md`
- [ ] Reference Anthropic's `usage.iterations[]` billing decomposition (from advisor tool responses) for per-component cost attribution design. Schema: separate token counts and costs for each inference iteration within a single API call. Mark as beta — verify schema stability at Phase 7 start — P3
- [ ] Instrument all Skill invocations, task events, and tool calls with OpenTelemetry spans
- [ ] Implement event classifier: maps spans to five billable outcome unit types
- [ ] Implement tenant attribution and deduplication (idempotent span processing)
- [ ] Build real-time token cost / outcome / margin dashboard per tenant
- [ ] Integrate Stripe API for invoice generation and payment processing

#### 7.2 Multi-tenant namespace isolation
- [ ] Implement per-tenant namespace: isolated `.claude/agents/`, `.claude/skills/`, `eval/`, `audit-logs/`, `billing-events/`
- [ ] Penetration test: confirm zero cross-tenant data access events

#### 7.3 Cross-regional high-availability deployment
- [ ] Deploy Kubernetes clusters in Taiwan (PDPA compliance) and Japan (APPI compliance) with 3-zone AZ
- [ ] Configure GeoDNS: ≤ 50ms latency for regional customers
- [ ] Enforce data residency: customer data never leaves regional cluster; cross-border = metadata + billing aggregates only
- [ ] Target: 99.99% uptime (≤ 52.6 min/year downtime)

#### 7.4 Compliance audit trail infrastructure
- [ ] Implement WORM (append-only) immutable audit log for all TIER_2 and TIER_3 tool calls
- [ ] Audit event schema: agent ID, tool name, args hash (not plaintext), outcome, tokens consumed, HITL status, region, data classification
- [ ] Third-party compliance audit: ISO 27001 and APPI baseline

#### 7.5 SSO integration and agent permission management
- [ ] Integrate OIDC/SAML (Azure AD, Okta) via Agent Permission Manager
- [ ] Implement Skill authorization matrix: which agents can use which Skills per tenant
- [ ] Test: all agent permission changes propagated within 60 seconds of IdP update

#### 7.6 Locale-aware Skill routing
- [ ] Build locale extension Skills for ja-JP and zh-TW (business protocol norms + regulatory constraints)
- [ ] Extend `topology-aware-router` with locale context dimension
- [ ] Test: locale-aware Skill extension loads in ≤ 500ms P99; fallback to base Skill on load failure

#### 7.7 Agent payment protocol evaluation
- [ ] Survey agent payment protocols (AP2, Visa TAP, x402, PayPal Agent Ready) and design billing adapter layer supporting multiple settlement rails
- [ ] Document three billing patterns: subscription (Stripe), micropayment (x402), commerce mandate (AP2)

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Billing accuracy | 100% of successful interactions billed |
| Cross-regional availability | 99.99% uptime |
| Regional data residency | Zero cross-border customer data transfers |
| Audit compliance | Meets ISO 27001 and APPI baseline (third-party audit) |
| SSO permission propagation | ≤ 60 seconds |
| Tenant namespace isolation | Zero cross-tenant access events (pen test) |

---

## Overall KPI Dashboard

| Category | Metric | Target | Phase |
|----------|--------|--------|-------|
| Generation | First-attempt format compliance | ≥ 90% | 1 |
| Generation | Permission design error rate | 0% | 1 |
| Trigger accuracy | Average trigger rate, deployed Skills | ≥ 90% | 2 |
| Trigger accuracy | Over-trigger rate | ≤ 5% | 2 |
| Optimization | AutoResearch success rate (< 75% → ≥ 90%) | ≥ 80% | 3 |
| Optimization | Convergence iterations | ≤ 50 | 3 |
| Cost | Distilled Haiku vs. Opus performance | ≥ 90% | 3 |
| Stability | Regression events from new deployments | 0 | 4 |
| Automation | Tasks completed without human intervention | ≥ 70% | 4 |
| Efficiency | End-to-end pipeline time | ≤ 4 hours | 4 |
| Routing | TCI track selection accuracy | ≥ 95% | 5 |
| Multi-agent | Token savings on high-coupling tasks (Track B vs. Track A) | ≥ 40% | 5 |
| Defensive | Loop-triggered Watchdog halts auto-resolved | ≥ 85% | 5 |
| Edge | Edge task success rate vs. cloud | ≥ 85% | 6 |
| Edge | State sync data loss across reconnection | 0 | 6 |
| Commercial | Billing accuracy | 100% | 7 |
| Commercial | Cross-regional availability | 99.99% | 7 |

---

## Measurement Architecture

**Accuracy is the only currency.** If the measurement tools are flawed, optimization results are meaningless. This section documents the fundamental challenges and the four solutions that address them.

### The Core Challenge

Skill routing in Claude Code is probabilistic. The model reads the `description` field and decides — non-deterministically — whether a skill applies to a prompt. There is no rule that says "if prompt contains X, trigger Y". The routing decision depends on model state, sampling, other loaded skill descriptions, and rate-limit degradation.

This creates a measurement problem: the tool we use to measure quality (Claude CLI) is subject to the same non-determinism as the system under test. A single eval run gives one sample from a distribution, not a definitive answer. A description achieving 0.77 on one run may achieve 0.50 on the next — not because the description changed, but because the routing decision is noisy.

### The Bootstrap Problem

The optimizer and the eval runner compete for the same API quota. Running the optimizer consumes quota, which makes rate-limiting more likely during eval runs, which corrupts the measurement the optimizer depends on. We cannot reliably measure the skill until the measurement tool is proven stable, and proving stability requires running it many times.

### Four Solutions (all implemented)

| # | Solution | Artifact | What it solves |
|---|----------|----------|----------------|
| S1 | Bayesian Evaluation | `eval/bayesian_eval.py` | Replaces noisy point estimates with `Beta(K+1, N-K+1)` posterior + 95% CI. Accept changes only when `new_ci_lower > old_ci_upper` (no overlap). |
| S2 | Async + Backoff + Delay | `eval/run_eval_async.py` | `asyncio.Semaphore(1)` + exponential backoff + `--inter-test-delay` flag. Prevents quota burst that corrupts results. |
| S3 | Semantic Cache | `eval/prompt_cache.py` | Caches routing decisions keyed on `(prompt_hash, description_hash)`. Negative tests cached description-invariantly (~40% savings per iteration). |
| S4 | Train/Validation Split | `eval/splits.json` | T=36 prompts (optimizer iterates on these) / V=18 prompts (held-out honesty check). ≥30% negative controls in each set. Prevents overfitting. |

### Decision Rules

| Decision | Rule |
|----------|------|
| Optimization commit | `new_ci_lower > old_ci_upper` (no CI overlap) |
| Deployment gate | `posterior_mean ≥ 0.90 AND ci_lower ≥ 0.80` |
| Repeatability | Two runs' 95% CIs overlap |
| Overfit detection | Train posterior ≥ 0.90 AND Validation posterior ≥ 0.85 |

### Test Set (54 prompts)

| Range | Type | Count |
|-------|------|-------|
| test_1–22 | Positive (should trigger `meta-agent-factory`) | 22 |
| test_23–39 | Hallucination traps (should NOT trigger) | 17 |
| test_40–44 | Cross-domain conflicts (near-misses with `autoresearch-optimizer`) | 5 |
| test_45–54 | Near-miss negatives (agent vocabulary, but direct tasks) | 10 |

---

## Key Risks to Watch

| Risk | Phase | Mitigation | Status |
|------|-------|-----------|--------|
| Eval measurement instability (LLM non-determinism) | 2 | S1: Bayesian CI replaces raw scores; S2: async backoff + inter-test-delay | ✅ Mitigated |
| Overfitting to eval prompts | 3 | S4: T/V split (36/18); refresh test cases quarterly | ✅ Mitigated |
| Rate-limit collapse mid-eval | 3 | S2: `--inter-test-delay 15`; S3: cache reduces calls ~40% | ✅ Mitigated |
| AutoResearch API costs spiral | 3 | S3: semantic cache; token budget ceiling per task; Haiku for screening | Partially mitigated |
| Changeling context pollution | 4 | Force full context reset; explicit forget boundaries in role defs | Pending |
| meta-agent-factory generates overly permissive tool access | 1 | `check-permissions.sh` static check; 100% catch rate | ✅ Active |
| TCI misclassification routes high-coupling to Track A | 5 | Conservative medium-coupling band defaults to Track B; logged | Spec written |
| Dev-QA infinite loop exhausts token budget | 5 | Watchdog halts on message pair > 8 and token velocity > threshold | Pending |
| Cascade hallucination via destructive MCP tool | 5+ | Pre-Execution Reflection hook blocks DESTRUCTIVE tools | Pending |
| Edge device OOM on complex Skill | 6 | Edge Readiness Assessment gate; dynamic downgrade to Cloud Reasoner | Pending |
| Cross-regional data residency violation | 7 | Tenant data never leaves regional cluster; quarterly egress audit | Pending |
| Outcome-based billing dispute | 7 | Immutable OpenTelemetry spans; customer-visible reconciliation dashboard | Pending |
| Agent fleet expansion causes routing regression | 3-4 | T=0.658 was a measurement regression (L10): eval patterns didn't match factory's markdown-bold output format, not actual misrouting. Vocabulary deconfliction applied as defense-in-depth. Eval patterns updated 2026-04-06. | ✅ Mitigated — eval fix applied |
| MCP SDK V2 breaking changes (auth semantics) | 4 | Pin MCP SDK version; add config validation to CI/CD gate; monitor V2 alpha releases | New — active threat |
| Claude Code deny-rule bypass (50+ subcommands) | 4 | Command-chain length monitor in post-tool-use hook; avoid auto-accept on untrusted projects | Mitigated — monitor implemented |
| MCP tool poisoning via malicious descriptions | 2-4 | Static content scanning in mcp_config_validator.sh; allowlist bypass; dynamic fetching deferred to Phase 5 | New — P0 mitigation implemented 2026-04-05 |
| Supply chain compromise of Python/npm dependencies used by eval tools or Claude Code | 4 | pip freeze + require-hashes (blocking); npm audit (warning); cmd_chain_monitor for runtime | New — mitigation implemented 2026-04-05 |
| Fleet running outdated Claude Code (11+ versions behind, missing PID namespace, MCP memory leak fix, permission hardening) | 4 | `check_fleet_version.sh` warns; `fleet_min_version.txt` updated to >=2.1.98; human must upgrade; post-upgrade validation via `agent_review.sh` | ⚠️ P0 — upgrade pending |
| Capybara/Mythos model release invalidates eval baselines and routing behavior | 3-4 | Model migration runbook (eval/model_migration_runbook.md); nightly researcher monitors for release | UPGRADED P2->P1 — runbook created 2026-04-05 |
| Phase 7 billing assumes Stripe-only; 4 competing agent payment protocols may require multi-rail support | 7 | Task 7.7 evaluation; defer implementation until protocol war settles | New — monitoring |
| MCP cost amplification via prolonged tool-calling chains (658x demonstrated) | 4 | MCP tool-call depth monitor in post-tool-use.sh (alert >15, block >25); per-run duration ceiling (5x 30-day avg); future: CI/CD gate MCP pattern rejection | New — P0, mitigated 2026-04-07 |
| A2A v1.0→v1.1 migration risk | 5 | Defer Phase 5 implementation to post-I/O; evaluate v1.1 SDK before committing to integration pattern | New — deferred pending I/O |
| Fleet Claude Code version skew | 4 | Fleet version check script (>=minimum); warn on mismatch in all daily scripts | New — mitigation implemented 2026-04-10 |

---

## Lessons Learned

| # | Lesson | Context |
|---|--------|---------|
| L1 | SKILL.md descriptions must use imperative trigger language | G15 changed to declarative "Generates new..." → 0/22 positive triggers. Must start with "Triggered when..." |
| L2 | Quota burst kills eval runs — use `--inter-test-delay` | Semaphore(1) serializes but still sends rapid-fire calls. 15–30s delay prevents quota exhaustion. |
| L3 | Never trust self-reported eval results without guardian review | G7 reported as passing but 0 positives triggered. Quota-skipped tests inflated the score. |
| L4 | Bayesian CI is the only reliable decision criterion | Raw pass rate difference can be noise. Commit only when `new_ci_lower > old_ci_upper`. |
| L5 | The bootstrap problem is real | Optimizer and eval runner compete for the same quota. S2+S3 mitigate but don't eliminate. |
| L6 | Edge model assumptions become stale — re-evaluate when new open models ship | Phase 6 was designed around FunctionGemma; Gemma 4 E2B obsoleted it with better accuracy (86.4% tool use zero-shot) and no fine-tuning |
| L7 | Adding agents causes routing regression — trigger rates must be re-evaluated after fleet expansion | G8 Iter 2 achieved T=0.895 with 5 agents. Adding 6 more agents (stewards, factory, reviewer) dropped meta-agent-factory to T=0.658. All negatives still pass — the issue is routing competition, not description quality. Eval must be re-run after any agent addition. |
| L8 | MCP config validation must cover content, not just structure | mcp_config_validator.sh (2026-04-04) validated JSON structure and auth patterns but missed tool description injection — the actual attack vector demonstrated by Invariant Labs |
| L9 | Every pipeline component encodes a model limitation assumption — stress-test and simplify as models improve | Anthropic harness engineering blog (2026-04-06). Validator assumes factory can't self-evaluate; optimizer assumes descriptions need iteration; router assumes models can't auto-identify roles. Track assumptions in eval/assumption_registry.md. |
| L10 | Eval infrastructure has THREE failure modes that masquerade as routing regressions | The T=0.658 "regression" had three independent root causes: (1) subprocess couldn't find `claude` binary (not in PATH for subprocesses — `~/.local/bin` not inherited); (2) TIMEOUT=150s too short for factory tool-use calls (factory takes 2-3 min); (3) trigger detection patterns didn't handle markdown bold (`**Tools granted**:`) in output. All three caused FAIL:not-triggered on positives while negatives correctly passed. Always run a manual `claude -p` test to verify a routing regression before touching descriptions. |
| L11 | Security layers respond to attacker capabilities, not model capabilities — they are cumulative, not simplifiable | L9 states "stress-test and simplify as models improve." But security components encode attacker assumptions, not model assumptions. Attackers don't get weaker when models improve. Consolidate security layers for maintainability, but don't remove them. (2026-04-07 analysis §2.3) |
| L12 | Agent fleets develop Urgency Bias — gate-blocking tasks lose to news-driven ADOPT items forever | Researcher-sourced items (CVE, new API, deprecation) carry novelty heat that makes them feel urgent. Gate-blocking tasks (stress test execution, cost analysis) have no "news," so they get deferred every session. Result: 20+ commits of observability/security hardening but zero execution of the 50-Skill stress test. This is classic firefighting culture — daily fires prevent the house from ever being built. **Mitigation:** factory-steward Phase 1.5 Gate-Priority Triage (2026-04-12) — if any Phase gate-blocker is SCAFFOLDED-ONLY or UNTOUCHED, that session skips ADOPT/Proposals entirely. Gate-deferral patterns are logged to `gate_priority_audit.log` for weekly human review. |

---

## Immediate Next Actions

1. ~~G7b~~ ✅ Baseline confirmed: T=0.895, V=0.600
2. ~~G8 Iter 1~~ ✅ Description optimized: T=0.921, V=0.800. Exceeds deployment gate (T ≥ 0.90).
3. ~~G8 Iter 2~~ ✅ V pushed to 0.900 (above 0.85 overfit threshold). T=0.895.
4. ~~CRITICAL: Routing regression~~ ✅ Root cause identified as MEASUREMENT regression (L10), not routing regression. Eval trigger detection patterns updated to match factory's markdown-bold output format. Vocabulary deconfliction also applied. **Eval re-run in progress — expect T recovery to ≥ 0.85.**
5. **Phase 3**: Convergence check — confirm optimizer loop terminates correctly
6. **Phase 4**: Stress test — 50 Skills generated/validated/deployed in 24 hours
7. **Phase 4**: Changeling latency validation (≤ 2s role switching)
8. **Phase 5 prep**: Build 50-task TCI benchmark dataset
9. ~~P2: Implement optimizer state persistence~~ ✅ Completed 2026-04-06
10. **P2**: Implement sprint contract manifest — factory outputs `manifest.json` for validator
11. **P1**: Roll cost ceiling to remaining 5 steward scripts
