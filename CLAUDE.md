# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

---

## Collaboration Protocol (non-negotiable — see AGENTS.md for full rules)

| File | Claude | Gemini |
|------|--------|--------|
| `ROADMAP.md` | **Primary** — dispatch tasks, update status, mark ✅/❌ | Both coordinate |
| `AGENTS.md` | Read only | Read only |

**Task lifecycle**: Tasks are tracked in `ROADMAP.md` under the relevant Phase section. Mark ✅/❌ as tasks complete.

---

## Project Overview

Seven-phase pipeline for autonomously designing, validating, optimizing, and deploying Claude Code Agent Skills. Phases 1–4 build the core automation loop; Phases 5–7 extend to multi-agent topology, edge AI, and commercial AaaS.

**Current status (2026-04-17):** Phase 4 core complete. 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Four active daily agents (factory-steward, ltc-steward, agentic-ai-researcher, project-reviewer). Three project stewards suspended (android-sw, arm-mrs, bsp-knowledge) — resource reallocation.

**Key documents:**
- `ROADMAP.md` — Single source of truth: phases, tasks, measurement architecture, risks, lessons learned
- `AGENT_SKILL_AUTOMATION_DEV_PLAN.md` — Full blueprint v2.0 (Phases 1–7)
- `AGENTS.md` — Collaboration protocol

---

## Architecture

### Seven Phases

| Phase | Goal | Status |
|-------|------|--------|
| 0 — Bootstrap | Repo structure, stubs | ✅ Complete |
| 1 — Meta-Agent Factory | Generate format-compliant Skills from natural language | ✅ Complete |
| 2 — Validator + CI/CD Gate | Objective quality gating, eval runner, adversarial tests | ✅ Complete |
| 3 — AutoResearch Optimizer | Unattended trigger rate optimization, async eval, Bayesian scoring | ✅ Core complete |
| 4 — Changeling Router + Closed Loop | Fully unattended factory→validate→optimize→deploy | 🔄 Current |
| 5 — Topology-Aware Multi-Agent | TCI routing, Scrum team orchestration, watchdog circuit breaker | 🔲 Pending |
| 6 — Edge AI + Cloud-Edge Hybrid | Talker-Reasoner, ONNX/GGUF packaging, OTA | 🔲 Pending |
| 7 — AaaS Commercialization | Outcome billing, multi-tenancy, cross-regional HA, compliance | 🔲 Pending |

### Core Agents (Phases 1–4)

| Agent | Role | Model | Permission class |
|-------|------|-------|-----------------|
| `meta-agent-factory` | Generates SKILL.md, agent configs, MCP config from requirements | Opus 4.6 | Orchestration |
| `skill-quality-validator` | 5-step validation pipeline, JSON report, threshold verdict | Sonnet 4.6 | Review/Validation |
| `autoresearch-optimizer` | Binary eval loop, parallel branch search (A/B/C/D), convergence | Opus 4.6 | Orchestration |
| `agentic-cicd-gate` | Deployment gating, flaky detection, git rollback | Sonnet 4.6 | Review/Validation |
| `changeling-router` | Dynamic identity switching from role library | Sonnet 4.6 | Orchestration |

### Autonomous Steward Agents (Daily Nightly Runs)

| Agent | Target Project | Role | Model | Status |
|-------|---------------|------|-------|--------|
| `agentic-ai-researcher` | This repo (`knowledge_base/`) | Tracks Anthropic + Google agentic AI developments, writes sweep reports, proposes skill/roadmap updates | Opus 4.6 | Active |
| `android-sw-steward` | `/home/jonas/gemini-home/Android-Software/` | Drives Phase 4 deliverables (dirty page detection, migration impact, L3 framework, skill lint, A15 validation), researches AOSP updates | Opus 4.6 | **Suspended** |
| `arm-mrs-steward` | `/home/jonas/arm-mrs-2025-03-aarchmrs/` | Drives H8 multi-agent orchestration, expands T32/A32 + GIC + CoreSight + PMU data, tracks ARM spec releases | Opus 4.6 | **Suspended** |
| `bsp-knowledge-steward` | `/home/jonas/ai-bsp-agent/github/ai-bsp-knowledge-skill-sets/` | Completes Phase 3 exit criteria, advances Phase 4 deliverables, expands Kuzu knowledge graph, researches ARM/Linux BSP updates | Opus 4.6 | **Suspended** |
| `ltc-steward` | `/home/jonas/gemini-home/long-term-care-expert/` | Advances Phases 2/7/8 (validation, Hana hardening, Digital Surrogate sprints), maintains SaMD compliance, runs eval suites, researches elderly care | Opus 4.6 | Active |
| `factory-steward` | This repo | Acts on ADOPT items from research discussions, tunes underperforming agents, refines eval/pipeline, advances ROADMAP | Opus 4.6 | Active |
| `project-reviewer` | All four project repos (read) | Reviews steward commits for correctness and alignment, writes steering notes, escalates stalled/regressing agents | Opus 4.6 | Active |

### Pipeline Flow

```
Human (requirements)
    ↓
meta-agent-factory → .claude/skills/<name>/SKILL.md
    ↓
skill-quality-validator → JSON report {trigger_rate, ci_lower, ci_upper}
    ├→ posterior_mean ≥ 0.90, ci_lower ≥ 0.80 → agentic-cicd-gate (deploy)
    └→ below threshold → autoresearch-optimizer (auto-repair, ≤ 50 iterations)
```

---

## Daily Agent Fleet

Active agent runs are scheduled daily via cron, staggered to avoid resource contention and quota limits. Each writes a performance JSON record to `logs/performance/` for tracking.

> **Note (2026-04-17):** `android-sw-steward`, `arm-mrs-steward`, and `bsp-knowledge-steward` are **suspended** (resource reallocation). Cron entries commented out. Scripts remain for manual use if needed.

### Schedule (Asia/Taipei) — Active Only

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 12:00 PM | `factory-steward` | `scripts/daily_factory_steward.sh` | Daytime session: advances ROADMAP, improves eval |
| 1:00 PM | `ltc-steward` | `scripts/daily_ltc_steward.sh` | Afternoon session: phase work + eval runs |
| 2:00 AM | `agentic-ai-researcher` | `scripts/daily_research_sweep.sh` | Anthropic + Google research sweep (L1–L5: collect → analyze → discuss → plan → act) |
| 7:00 AM | `project-reviewer` | `scripts/daily_project_reviewer.sh` | Reviews steward work, validates skills, writes steering notes, escalates issues |

### Performance Tracking

- **JSON records**: `logs/performance/{factory,researcher,android-sw,arm-mrs,bsp-knowledge,ltc,reviewer}-YYYY-MM-DD.json`
- **Metrics tracked**: duration, exit code, commits made, files changed, test counts (agent-specific)
- **30-day retention**: auto-cleaned by each script
- **Review dashboard**: `./scripts/agent_review.sh [days]` — summarizes all agents' recent performance

### Manual Runs

```bash
./scripts/daily_factory_steward.sh      # Run factory steward now
./scripts/daily_research_sweep.sh       # Run researcher now
./scripts/daily_ltc_steward.sh          # Run LTC steward now
./scripts/daily_project_reviewer.sh     # Run project reviewer now
./scripts/agent_review.sh              # Review last 7 days
./scripts/agent_review.sh 30           # Monthly review
```

### Logs

| Agent | Log file | Perf file |
|-------|----------|-----------|
| Factory | `logs/factory-YYYY-MM-DD.log` | `logs/performance/factory-YYYY-MM-DD.json` |
| Researcher | `logs/sweep-YYYY-MM-DD.log` | `logs/performance/researcher-YYYY-MM-DD.json` |
| LTC | `logs/ltc-YYYY-MM-DD.log` | `logs/performance/ltc-YYYY-MM-DD.json` |
| Reviewer | `logs/reviewer-YYYY-MM-DD.log` | `logs/performance/reviewer-YYYY-MM-DD.json` |

---

## Measurement Infrastructure (Phase 3 — critical)

**Accuracy is the only currency. If the measurement tools are flawed, optimization results are meaningless.**

| Tool | Purpose | Status |
|------|---------|--------|
| `eval/run_eval_async.py` | Primary eval runner — asyncio + Semaphore(1) + exp backoff | ✅ Verified |
| `eval/bayesian_eval.py` | Bayesian posterior + 95% CI; `--compare` for CI non-overlap test | ✅ Verified |
| `eval/prompt_cache.py` | Semantic cache — reduces API calls ~40% per optimizer iteration | ✅ Verified |
| `eval/splits.json` | Train (26) / Validation (18) split — prevents optimizer overfitting | ✅ Verified |
| `eval/run_eval.sh` | Legacy bash runner — still functional but not rate-limit safe at scale | ⚠️ Legacy |
| `eval/check-permissions.sh` | Static YAML validator — enforces mutually exclusive permission rules | ✅ Active |
| `eval/flaky_detector.py` | Bayesian flaky test classifier — reads `eval/flaky_history.json` | ✅ Active |
| `.claude/hooks/pre-deploy.sh` | Deployment gate — enforces Bayesian posterior mean ≥ 0.90 | ✅ Active |
| `eval/changeling_validation.sh` | Static validator — 8-check suite for Changeling routing infrastructure | ✅ Active |

### Measurement Decision Rules

- **Optimization commit**: Accept a description change ONLY when `new_ci_lower > old_ci_upper` (no CI overlap). Raw pass rate increase alone is insufficient — it may be measurement noise.
- **Deployment gate**: `posterior_mean ≥ 0.90 AND ci_lower ≥ 0.80`
- **Repeatability**: Two runs pass when their 95% CIs overlap (not when raw scores differ ≤ 5%)
- **Overfitting check**: Training posterior_mean ≥ 0.90 AND validation posterior_mean ≥ 0.85

### Test Set

- **59 prompts total**: `eval/prompts/test_1.txt` – `test_59.txt`
  - Tests 1–22: positive cases (should trigger `meta-agent-factory`)
  - Tests 23–39: hallucination/false-positive traps (should NOT trigger)
  - Tests 40–44: cross-domain conflict cases (near-misses with `autoresearch-optimizer`)
  - Tests 45–54: near-miss negative controls (agent vocabulary but direct tasks)
  - Tests 55–59: real-world negative controls (promoted from skill usage logs)
- **Training set** (T, 39 prompts): optimizer reads failures from these only
- **Validation set** (V, 20 prompts): held out — used only for final assessment

---

## Key Design Principles

- **Mutually exclusive permissions**: Review/validation agents denied Write/Edit; execution agents denied Task; enforced by `check-permissions.sh`
- **Bayesian scoring over raw pass rate**: True trigger rate is a distribution, not a point estimate — always use posterior mean + credible interval
- **Train/validation split**: Optimizer iterates on T only; V is the held-out honesty check
- **Prompt cache**: Negative tests cached description-invariantly; positive tests invalidated on description change
- **Guardian review**: Claude verifies all Gemini deliverables against explicit criteria before marking ✅

---

## Directory Structure

```
.claude/
├── agents/              # Agent definition .md files
│   ├── meta-agent-factory.md
│   ├── skill-quality-validator.md
│   ├── autoresearch-optimizer.md
│   ├── agentic-cicd-gate.md
│   ├── changeling-router.md
│   ├── agentic-ai-researcher.md     # Nightly: Anthropic + Google AI research
│   ├── android-sw-steward.md        # SUSPENDED: Android-Software project steward
│   ├── arm-mrs-steward.md           # SUSPENDED: ARM MRS project steward
│   ├── bsp-knowledge-steward.md     # SUSPENDED: BSP Knowledge skill sets steward
│   ├── ltc-steward.md              # 5x/day: Long-term-care-expert project steward
│   ├── factory-steward.md           # Nightly: Factory self-improvement steward
│   └── project-reviewer.md          # Nightly: Reviews steward work, writes steering notes
├── skills/              # Per-skill subdirectories (SKILL.md + scripts/ + references/)
└── hooks/               # pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval_async.py    # Primary async eval runner (Python)
├── run_eval.sh          # Legacy bash runner
├── bayesian_eval.py     # Bayesian posterior + CI module
├── prompt_cache.py      # Semantic prompt cache
├── flaky_detector.py    # Bayesian flaky test classifier
├── show_experiments.sh  # Experiment log table viewer
├── check-permissions.sh
├── splits.json          # T/V split definition
├── experiment_log.json  # Optimizer iteration history
├── prompts/             # test_1.txt … test_44.txt
└── expected/            # Expected trigger/content per test
scripts/
├── daily_research_sweep.sh       # Cron: 2am — agentic-ai-researcher
├── daily_android_sw_steward.sh   # SUSPENDED — android-sw-steward
├── daily_arm_mrs_steward.sh      # SUSPENDED — arm-mrs-steward
├── daily_bsp_knowledge_steward.sh # SUSPENDED — bsp-knowledge-steward
├── daily_ltc_steward.sh           # Cron: 5x wkday, 3x weekend — ltc-steward
├── daily_factory_steward.sh       # Cron: 9pm — factory-steward
├── daily_project_reviewer.sh      # Cron: 6am — project-reviewer
├── agent_review.sh               # Performance review dashboard
├── promote_cases.py              # Promote real-world skill usage to eval set
├── health_dashboard.py           # Pipeline health dashboard
└── skill_logger_hook.sh          # Skill usage logger hook
logs/
├── sweep-YYYY-MM-DD.log          # Researcher daily logs
├── android-sw-YYYY-MM-DD.log     # Android-SW steward (suspended)
├── arm-mrs-YYYY-MM-DD.log        # ARM MRS steward (suspended)
├── ltc-YYYY-MM-DD.log            # LTC steward daily logs
└── performance/                  # Agent performance JSON records
    ├── researcher-YYYY-MM-DD.json
    ├── android-sw-YYYY-MM-DD.json    # suspended
    ├── arm-mrs-YYYY-MM-DD.json       # suspended
    ├── bsp-knowledge-YYYY-MM-DD.json # suspended
    ├── ltc-YYYY-MM-DD.json
    ├── factory-YYYY-MM-DD.json
    └── reviewer-YYYY-MM-DD.json
knowledge_base/
└── agentic-ai/                   # Researcher knowledge base
    ├── INDEX.md
    ├── anthropic/                # Anthropic track findings
    ├── google-deepmind/          # Google/DeepMind track findings
    ├── sweeps/                   # Daily sweep reports
    ├── analysis/                 # L2-L3 deep analysis
    ├── proposals/                # L4 strategic proposals
    └── actions/                  # L5 action logs
~/.claude/@lib/agents/            # Changeling role library (global, read-only)
```

---

## Acceptance KPIs

| Metric | Target | Phase |
|--------|--------|-------|
| Deployment gate | Posterior mean ≥ 0.90, lower CI ≥ 0.80 | 2–3 |
| Optimization success rate | < 75% Skills raised to ≥ 90% in ≤ 50 iterations | 3 |
| Repeatability | Two runs' 95% CIs overlap | 3 |
| Overfit protection | Train ≥ 0.90 AND Validation ≥ 0.85 | 3 |
| End-to-end pipeline time | ≤ 4 hours requirements → deployed Skill | 4 |
| TCI routing accuracy | ≥ 95% on 50-task benchmark | 5 |
| Edge task success rate | ≥ 85% vs cloud baseline | 6 |
| Billing accuracy | 100% of successful interactions billed | 7 |
