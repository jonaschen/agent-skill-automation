# GEMINI.md - Gemini-Owned Working Memory

> **STRICT PROTOCOL**: Gemini owns this file. Claude reads it. Gemini MUST NOT write to `CANVAS.md`.

## Project Overview
Automated pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills. Shifting Skill development from manual artisan labor to a continuously self-improving system based on the **AutoResearch pattern**.

## ⚠️ PROTOCOL CORRECTION (2026-03-28)
- **False Success Acknowledgment**: Previously reported G7 success was invalid due to buggy tool logic (failed tests marked as not-triggered instead of skipped) and polluted cache.
- **Protocol Violation**: Incorrectly modified `CANVAS.md`. Gemini will strictly adhere to read-only access for `CANVAS.md` moving forward.
- **Working Memory Cleared**: All previous G7/G8 performance estimates for `meta-agent-factory` are discarded.

## Core Mandates & Principles

### 1. Three-Layer SKILL.md Architecture
- **Level 1 (YAML Frontmatter):** `name`, `description`, `tools`, `model`. The **sole routing signal**. Description must be ≤ 1024 characters.
- **Level 2 (Markdown Body):** Full operational instructions, output templates, error handling.
- **Level 3 (Scripts/References):** External validation scripts (`scripts/`) and reference docs (`references/`), loaded only when explicitly directed.

### 2. Mutually Exclusive Permissions
- **Review/Validation Agents:** No `Write` or `Edit` tools.
- **Execution Agents:** No `Task` tool (prevents infinite delegation chains).
- **Orchestration Agents (Factory, Router):** May have both `Write` and `Task`.
- *Enforcement:* Statically checked by `eval/check-permissions.sh`.

### 3. Scalar Metric Optimization (AutoResearch)
- **Mutable Asset:** `SKILL.md` (or agent `.md` file).
- **Scalar Metric:** Bayesian posterior mean trigger rate (see `eval/bayesian_eval.py`).
  Raw pass rate is a noisy point estimate subject to LLM non-determinism. Always use the posterior + 95% credible interval (CI).
- **Decision Rule**: A version change is only committed if the new CI lower bound > old CI upper bound (no overlap).
- **Fixed Budget:** 44 fixed test prompts in `eval/prompts/` (test_1–44).
  - Training set (T, 26 prompts): optimizer reads these failures and iterates against them.
  - Validation set (V, 18 prompts): held out — used only for final assessment. See `eval/splits.json`.

## Repository Structure
- `.claude/agents/`: Core agent definition files (e.g., `meta-agent-factory.md`).
- `.claude/skills/`: Per-skill directories containing `SKILL.md`, `scripts/`, and `references/`.
- `eval/`: Evaluation logic and data.
  - `run_eval_async.py`: **Primary runner (G9).** Asyncio + **Semaphore(1)** (sequential, updated from 4) + Exp Backoff. Correctly handles `_cleanup` of untracked files.
  - `bayesian_eval.py`: **Bayesian module (G10).** Correctly counts `FAIL:*` prefixes and models Beta distribution.
  - `prompt_cache.py`: **Semantic cache (G11).** Smart logic: description-sensitive for all positive cases and failing negative cases; description-invariant only for passing negative controls.
  - `splits.json`: Defines T/V split (26/18).

## Current Status (Phase 3)

| Task | Status | Notes |
|------|--------|-------|
| Phase 0–2 | ✅ Complete | Infrastructure, factory, validator, CI/CD gate |
| G9 Async runner | ✅ Verified | `CONCURRENCY_LIMIT` updated to 1 (sequential) |
| G10 Bayesian module | ✅ Verified | Beta posterior + CI non-overlap decision rule |
| G11 Prompt cache | ✅ Verified | Cache cleared, description-sensitivity confirmed |
| G7 Repeatability baseline | ❌ FAILED | Skips > 5; signal unstable due to quota |
| G8 First optimizer run | 🔲 Blocked | Blocked on G7 |
| G12 pre-deploy logic | ✅ Complete | Hook updated to use Bayesian thresholds |

## 🔍 Technical Observation (G7 Baseline)
- **Positive Trigger Failure**: In both runs, the Skill failed to trigger for *every single execute* positive test (Tests 1–22).
- **Negative Trigger Success**: The Skill correctly did NOT trigger for any executed negative control (Tests 23–44).
- **Root Cause Hypothesis**: The Level 1 description in `.claude/agents/meta-agent-factory.md` is too narrow or lacks sufficient action verbs to overcome the model's task-routing bias.

### Run 1 (concurrency=1, --no-cache) — ❌ INVALID

| Set | Posterior Mean | 95% CI | Non-Skipped | Skipped |
|-----|---------------|--------|-------------|---------|
| OVERALL | 0.207 | [0.083, 0.369] | 27/44 | 17 (28–44) |

**Notes:** Skips concentrated in negative set (28–44). All positive tests (1–22) failed. All negative tests (23–27) passed.

### Run 2 (concurrency=1, --no-cache) — ❌ INVALID

| Set | Posterior Mean | 95% CI | Non-Skipped | Skipped |
|-----|---------------|--------|-------------|---------|
| OVERALL | 0.622 | [0.462, 0.769] | 35/44 | 9 (1–9) |

**Notes:** Skips concentrated in positive set (1–9). All positive tests (10–22) failed. All negative tests (23–44) passed.

**G7 Status:** FAILED. Measurement unstable due to quota depletion. Posterior means differ by 0.415. Skips exceed limit of 5.
**Observation:** In both runs, the Skill failed to trigger for *every single* positive test that executed (1–22). It passed *every single* negative test that executed (23–44).
**Conclusion:** The `meta-agent-factory.md` description is currently non-functional for triggering.

## Operational Guidance
- **NEVER** write to `CANVAS.md`.
- **Baseline a skill**: run `python3 eval/run_eval_async.py <skill> --no-cache`, then check output for Bayesian posterior + CI.
- **Optimization decision**: use `bayesian_eval.py --compare old.json new.json`.
- **Cleanup**: `run_eval_async.py` automatically cleans untracked `.md` files and `.claude/skills/` subdirectories after each test.
- **Rate-limit rule**: CONCURRENCY_LIMIT=1 (sequential). Do not increase until quota headroom is confirmed over multiple full runs.
