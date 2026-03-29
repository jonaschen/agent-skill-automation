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

**Current status (2026-03-29):** Phase 2 complete. Phase 3 in progress — async eval architecture built (G9/G10/G11 verified), first live optimization run (G7/G8) pending quota reset.

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
| 3 — AutoResearch Optimizer | Unattended trigger rate optimization, async eval, Bayesian scoring | 🔄 Current |
| 4 — Changeling Router + Closed Loop | Fully unattended factory→validate→optimize→deploy | 🔲 Pending |
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

### Measurement Decision Rules

- **Optimization commit**: Accept a description change ONLY when `new_ci_lower > old_ci_upper` (no CI overlap). Raw pass rate increase alone is insufficient — it may be measurement noise.
- **Deployment gate**: `posterior_mean ≥ 0.90 AND ci_lower ≥ 0.80`
- **Repeatability**: Two runs pass when their 95% CIs overlap (not when raw scores differ ≤ 5%)
- **Overfitting check**: Training posterior_mean ≥ 0.90 AND validation posterior_mean ≥ 0.85

### Test Set

- **44 prompts total**: `eval/prompts/test_1.txt` – `test_44.txt`
  - Tests 1–22: positive cases (should trigger `meta-agent-factory`)
  - Tests 23–39: hallucination/false-positive traps (should NOT trigger)
  - Tests 40–44: cross-domain conflict cases (near-misses with `autoresearch-optimizer`)
- **Training set** (T, 26 prompts): optimizer reads failures from these only
- **Validation set** (V, 18 prompts): held out — used only for final assessment

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
├── agents/          # Core agent .md files
├── skills/          # Per-skill subdirectories (SKILL.md + scripts/ + references/)
└── hooks/           # pre-deploy.sh, post-tool-use.sh, stop.sh
eval/
├── run_eval_async.py   # Primary async eval runner (Python)
├── run_eval.sh         # Legacy bash runner
├── bayesian_eval.py    # Bayesian posterior + CI module
├── prompt_cache.py     # Semantic prompt cache
├── flaky_detector.py   # Bayesian flaky test classifier
├── show_experiments.sh # Experiment log table viewer
├── check-permissions.sh
├── splits.json         # T/V split definition
├── experiment_log.json # Optimizer iteration history
├── prompts/            # test_1.txt … test_44.txt
└── expected/           # Expected trigger/content per test
~/.claude/@lib/agents/  # Changeling role library (global, read-only)
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
