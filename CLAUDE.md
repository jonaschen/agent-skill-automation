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

**Current status (2026-04-17):** Phase 4 core complete. 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Three-agent research pipeline runs twice daily: researcher → research-lead → factory-steward (night cycle 1-3am, morning cycle 12-2pm). LTC steward at 8am. Focus: agentic AI research, agent development, and applications.

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

### Research Agents

| Agent | Role | Model |
|-------|------|-------|
| `agentic-ai-researcher` | L1–L5 research sweep: Anthropic + Google developments, sweep reports, proposals | Opus 4.6 |
| `agentic-ai-research-lead` | Strategic director: reviews output, writes priority directives | Opus 4.6 |

### Paper Agents

| Agent | Role | Model |
|-------|------|-------|
| `paper-synthesizer` | Academic paper writing from KB + experiments + literature | Opus 4.6 |
| `experiment-designer` | Hypothesis-driven experiment design and statistical analysis | Opus 4.6 |
| `peer-reviewer` | Cross-team academic peer review of paper candidates | Sonnet 4.6 |

### Strategic Research Priorities

Owner-level priorities that shape all research cycles (full doc: `knowledge_base/agentic-ai/strategic-priorities.md`):

- **S1**: Automatic agent/skill improvement — self-improving systems
- **S2**: Multi-agent orchestration — novel patterns, experiments
- **S3**: Platform generalization — cross-platform portability (Claude + Gemini)

### Steward Skill (parameterized via YAML configs)

One `steward` skill (`.claude/skills/steward/SKILL.md`) + per-project configs in `.claude/skills/steward/configs/`:

| Config | Project | Status |
|--------|---------|--------|
| `factory.yaml` | This repo — pipeline improvement, ADOPT implementation | Active |
| `ltc.yaml` | long-term-care-expert — Hana LINE bot + Digital Surrogate | Active |
| `kings-hand.yaml` | The King's Hand — adversarial analysis system | Active |
| `android-sw.yaml` | Android-Software — AOSP skill set | Suspended |
| `arm-mrs.yaml` | ARM MRS — AArch64 agent skills | Suspended |
| `bsp-knowledge.yaml` | BSP Knowledge — Kuzu graph mentor | Suspended |

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

The Claude research pipeline runs **two cycles daily** (night + afternoon), each a three-agent chain: researcher → research-lead → factory-steward. The Gemini team runs one cycle (morning), offset to avoid API overlap. Each agent writes a performance JSON record to `logs/performance/`.

> **Note (2026-04-18):** Schedule consolidated from 17 to 11 sessions/day (~35% compute savings). Project stewards (`android-sw`, `arm-mrs`, `bsp-knowledge`) and `project-reviewer` remain **suspended**.

### Schedule (Asia/Taipei)

**Pre-Night Eval** (runs before night cycle — no Claude session needed)

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 11:30 PM | `shadow-eval` | `scripts/daily_shadow_eval.sh` | Model migration shadow eval (fires only when migration pending; direct Python, no Claude session) |

**Claude Night Cycle** (primary — catches Asia-afternoon + Europe releases)

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 1:00 AM | `agentic-ai-researcher` | `scripts/daily_research_sweep.sh` | L1–L5 research sweep (reads prior directive for priorities) |
| 2:00 AM | `agentic-ai-research-lead` | `scripts/daily_research_lead.sh` | Reviews researcher output, writes priority directive |
| 3:00 AM | `factory-steward` | `scripts/daily_factory_steward.sh` | Implements ADOPT items guided by research-lead directive |

**Gemini Morning Cycle** (offset from Claude to avoid API overlap)

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 5:00 AM | Gemini researcher | `daily_research_sweep_gemini.sh` | L1–L2 data collection |
| 6:00 AM | Gemini research-lead | `daily_research_lead_gemini.sh` | L3–L4 priorities + hypotheses |
| 7:00 AM | Gemini factory-steward | `daily_factory_steward_gemini.sh` | L5 ADOPT implementation |
| 9:00 AM | Gemini elite research | `daily_elite_research_gemini.sh` | Cross-vendor synthesis + paper generation |
| 10:00 AM | Gemini dashboard | `agent_review_gemini.sh 1` | Performance dashboard |

**Claude Afternoon Cycle** (catches US-morning announcements)

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 2:00 PM | `agentic-ai-researcher` | `scripts/daily_research_sweep.sh` | L1–L5 research sweep |
| 3:00 PM | `agentic-ai-research-lead` | `scripts/daily_research_lead.sh` | Reviews researcher output, writes priority directive |
| 6:00 PM | `factory-steward` | `scripts/daily_factory_steward.sh` | Implements ADOPT items |

**Independent Projects** (once daily each)

| Time | Agent | Script | What It Does |
|------|-------|--------|-------------|
| 8:00 AM | `ltc-steward` | `scripts/daily_ltc_steward.sh` | Phase work on long-term-care-expert project |
| 12:00 PM | `kings-hand-assessment` | `The-King-s-Hand/.../daily_kings_hand_assessment.sh` | Kings Hand assessment (separate repo) |
| 7:00 PM | `kings-hand-steward` | `scripts/daily_kings_hand_steward.sh` | Maintain The King's Hand project |

**On-Demand**

| Agent | Script | What It Does |
|-------|--------|-------------|
| `paper-pipeline` | `scripts/paper_pipeline.sh [phase]` | Experiment analysis + paper writing (Phase 1: independent, Phase 2: + peer review) |

### Research Direction Loop

```
researcher (L1-L5) → knowledge_base/ → research-lead → directives/ → researcher (next cycle)
                                                      ↘ directives/ → factory-steward (same cycle)
```

### Performance Tracking

- **JSON records**: `logs/performance/{factory,researcher,research-lead,ltc,paper}-YYYY-MM-DD.json`
- **Metrics tracked**: duration, exit code, commits made, files changed, test counts (agent-specific)
- **30-day retention**: auto-cleaned by each script
- **Review dashboard**: `./scripts/agent_review.sh [days]` — summarizes all agents' recent performance

### Manual Runs

```bash
./scripts/daily_research_sweep.sh       # Run researcher now
./scripts/daily_research_lead.sh        # Run research lead now
./scripts/daily_factory_steward.sh      # Run factory steward now
./scripts/daily_ltc_steward.sh          # Run LTC steward now
./scripts/daily_shadow_eval.sh         # Run shadow eval now (only fires if migration pending)
./scripts/paper_pipeline.sh            # Run paper pipeline (Phase 1)
./scripts/paper_pipeline.sh 2          # Run paper pipeline (Phase 2: + peer review)
./scripts/agent_review.sh              # Review last 7 days
./scripts/agent_review.sh 30           # Monthly review
```

### Logs

| Agent | Log file | Perf file |
|-------|----------|-----------|
| Researcher | `logs/sweep-YYYY-MM-DD.log` | `logs/performance/researcher-YYYY-MM-DD.json` |
| Research Lead | `logs/research-lead-YYYY-MM-DD.log` | `logs/performance/research-lead-YYYY-MM-DD.json` |
| Factory | `logs/factory-YYYY-MM-DD.log` | `logs/performance/factory-YYYY-MM-DD.json` |
| LTC | `logs/ltc-YYYY-MM-DD.log` | `logs/performance/ltc-YYYY-MM-DD.json` |
| Shadow Eval | `logs/shadow-eval-YYYY-MM-DD.log` | `logs/performance/shadow-eval-YYYY-MM-DD.json` |
| Paper Pipeline | `logs/paper-YYYY-MM-DD.log` | `logs/performance/paper-YYYY-MM-DD.json` |

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

