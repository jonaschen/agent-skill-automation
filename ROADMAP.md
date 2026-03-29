# ROADMAP.md

Agent Skill Automation — Development Roadmap
**Status as of 2026-03-29: Phase 2 complete. Phase 3 in progress (agent written; base loop not yet running code). Phases 5–7 planned.**

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

### Acceptance Criteria
| Metric | Target |
|--------|--------|
| Measurement repeatability (two runs, same Skill) | Diff ≤ 5% |
| Static analyzer detection of known format violations | ≥ 95% |
| CI/CD gate blocks all sub-threshold deployments | 100% |
| Flaky test auto-quarantine accuracy | ≥ 80% |

---

## Phase 3: AutoResearch Optimizer + Async Architecture *(current)*

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
- [ ] First live run: execute the optimizer against `meta-agent-factory` SKILL.md *(Claude, C3)* **Status: 🔲 (BLOCKED — Pending G7)**
- [ ] Validate parallel branch search actually runs all 4 branches per iteration *(after C3)*

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

## Phase 4: Changeling Router + Full Closed Loop *(Month 7+, continuous)*

**Goal:** Fully unattended pipeline from natural language requirement to deployed Skill. Human role = experimental designer, not experimenter.

### Tasks

#### 4.1 `changeling-router` agent
- [x] Write `.claude/agents/changeling-router.md` (stub — full implementation Phase 4)
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

## Phase 5: Topology-Aware Routing + Multi-Agent Orchestration *(Months 8–9)*

**Goal:** Upgrade from dynamic identity switching to a parallel-collaborative AI Scrum Team with intelligent pre-execution routing. Prevent the Sequential Penalty on highly coupled tasks.

**Prerequisite:** Phases 1–4 complete and stable.

### Tasks

#### 5.1 Task Coupling Indexer (TCI)
- [ ] Implement `eval/tci_compute.py` — four-dimension scoring (dependency depth 35%, rollback probability 25%, context coherence 25%, historical parallel failure rate 15%)
- [ ] Build 50-task human-labeled benchmark (25 low-coupling, 25 high-coupling), frozen at phase start
- [ ] Validate TCI computation completes in ≤ 5 seconds per task

#### 5.2 `topology-aware-router` agent
- [ ] Write `.claude/agents/topology-aware-router.md` — TCI computation, dual-track routing logic, Track B escalation
- [ ] Implement routing decision log (stores TCI score, selected track, and task outcome for feedback loop)
- [ ] Test Track B conservative default for medium-coupling band (0.35–0.65)

#### 5.3 `scrum-team-orchestrator` agent + A2A bus
- [ ] Write `.claude/agents/scrum-team-orchestrator.md` — PO/Dev/QA context forking, typed A2A message schema
- [ ] Implement A2A message bus with six valid message types only (TASK_ASSIGNMENT, PARTIAL_OUTPUT, REVIEW_REQUEST, REVIEW_RESULT, ESCALATION, WATCHDOG_HALT)
- [ ] Enforce message schema validation — untyped agent-to-agent chat is prohibited
- [ ] Test Track A: parallel frontend/backend Skill generation, confirm zero message loss

#### 5.4 `watchdog-circuit-breaker` agent
- [ ] Write `.claude/agents/watchdog-circuit-breaker.md` (Haiku model — no reasoning, monitoring only)
- [ ] Implement loop detection: halt when any agent pair exceeds 8 messages
- [ ] Implement token velocity monitor: halt when >5,000 tokens/min (Track A) or >15,000 tokens/min (Track B)
- [ ] Test WATCHDOG_HALT broadcast reaches all active agents and freezes task thread

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
- [ ] Implement `eval/edge_readiness.py` — five-criterion pass/fail gate (model size, tool dependencies, latency, data classification, state management)
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

#### 6.4 Model packaging pipeline
- [ ] Implement `eval/edge_package.sh` — exports distilled SKILL.md + weights to `.edge-skill` bundle
- [ ] Support ONNX export for CPU/NPU and GGUF for ARM/Apple Silicon
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

### Tasks

#### 7.1 `outcome-billing-engine` agent + OpenTelemetry instrumentation
- [ ] Write `.claude/agents/outcome-billing-engine.md`
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

## Key Risks to Watch

| Risk | Phase | Mitigation |
|------|-------|-----------|
| Overfitting: optimizer achieves high eval score but fails in production | 3 | Strict 60/40 split; refresh test cases monthly |
| Eval measurement instability (LLM non-determinism) | 2 | Average ≥ 5 runs per assessment |
| AutoResearch API costs spiral | 3 | Token budget ceiling per task; Haiku for initial screening |
| Changeling context pollution (prior role bleeds into next) | 4 | Force full context reset; explicit forget boundaries in role defs |
| meta-agent-factory generates overly permissive tool access | 1 | `check-permissions.sh` static check; 100% catch rate required |
| TCI misclassification routes high-coupling task to Track A | 5 | Conservative medium-coupling band defaults to Track B; confidence score logged |
| Dev-QA infinite loop exhausts monthly token budget | 5 | Watchdog halts on message pair count > 8 and token velocity > threshold |
| Cascade hallucination via destructive MCP tool | 5+ | Pre-Execution Reflection hook blocks DESTRUCTIVE tools without simulation confirmation |
| Edge device OOM on complex Skill | 6 | Edge Readiness Assessment gates deployment; dynamic downgrade to Cloud Reasoner on OOM |
| Cross-regional data residency violation | 7 | Architectural enforcement: tenant data never leaves regional cluster; quarterly egress audit |
| Outcome-based billing dispute | 7 | Immutable OpenTelemetry spans as billing source of truth; customer-visible reconciliation dashboard |

---

## Immediate Next Actions

1. **Now (Gemini — G9)**: Implement `eval/run_eval_async.py` (Async Architecture mandatory gate)
2. **Next (Gemini — G10/G11)**: Build Bayesian and Cache modules
3. **Next (Claude — S4)**: Create `eval/splits.json` and update optimizer logic ✅
4. **Next (Gemini — G7)**: Run repeatability baseline using the new Async Runner
5. **After G7**: Run the autoresearch-optimizer (G8/C3) for the first live session
