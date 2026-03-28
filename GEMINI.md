# GEMINI.md - Gemini-Owned Working Memory

This file is owned by Gemini. Gemini writes status, results, and findings here. Claude reads this file to monitor progress but MUST NOT write to it.

## Project Overview
Automated pipeline for designing, validating, optimizing, and deploying Claude Code Agent Skills. Shifting Skill development from manual artisan labor to a continuously self-improving system based on the **AutoResearch pattern**.

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
- **Fixed Budget:** 44 fixed test prompts in `eval/prompts/` (test_1–44).
  - Training set (T, ~26 prompts): optimizer reads these failures and iterates against them.
  - Validation set (V, ~18 prompts): held out — used only for final assessment. See `eval/splits.json`.
  - Negative Controls: ~48% of the total set (EXPECT_TRIGGER=no) to prevent description widening.
- **Rate-Limit Floor (0.27):** A pass rate of exactly 0.27 (12/44 or 8/30) usually indicates a rate-limit collapse where only negative tests pass. Detected by `eval/run_eval_async.py` and marked as `SKIP:rate-limit`.
- **Target:** Posterior mean ≥ 0.90 AND lower CI bound ≥ 0.80 for deployment.
- **Optimizer commit rule:** Accept a description change ONLY when the new version's 95%
  credible interval does NOT overlap with the old version's CI. Raw pass rate increase alone
  is not sufficient — it may be measurement noise.

## Repository Structure
- `.claude/agents/`: Core agent definition files (e.g., `meta-agent-factory.md`).
- `.claude/skills/`: Per-skill directories containing `SKILL.md`, `scripts/`, and `references/`.
- `.claude/hooks/`: Lifecycle hooks (`pre-deploy.sh`, `post-tool-use.sh`, `stop.sh`).
- `eval/`: Evaluation logic and data.
  - `run_eval_async.py <skill-path>`: **Primary runner (G9).** Uses `asyncio.Semaphore` (limit 4) and exponential backoff with jitter to adapt to API quota.
  - `run_eval.sh <skill-path>`: Legacy bash runner — high risk of rate-limit collapse.
  - `bayesian_eval.py`: **Bayesian posterior + credible interval calculator (G10).** Models true trigger rate as `Beta(K+1, N-K+1)`.
  - `prompt_cache.py`: Semantic cache (G11). Keyed on `(prompt_hash, description_hash)`. Reduces API calls by ~40% (caches all negative controls).
  - `flaky_detector.py`: Bayesian flaky test classifier. Reads `eval/flaky_history.json`.
  - `show_experiments.sh`: Prints `experiment_log.json` as a human-readable table.
  - `check-permissions.sh <file>`: Validates permission rules.
  - `splits.json`: Defines T/V split (60/40) to prevent overfitting.
  - `prompts/`: 44 fixed test prompts (`test_1.txt` to `test_44.txt`).
  - `expected/`: Expected trigger/content for evaluation.
- `~/.claude/@lib/agents/`: Changeling role library (global, read-only).

## Current Status (Phase 3)
- **Phase 0, 1, & 2 Complete:** Infrastructure setup, `meta-agent-factory`, `skill-quality-validator`, and `agentic-cicd-gate` implemented.
- **Phase 3 In Progress:** `autoresearch-optimizer`, `skill-optimizer-program.md`, `experiment_log.json`, and `show_experiments.sh` implemented.
- **Round 4 Architecture Built:**
    - `eval/run_eval_async.py`: Async Python runner with 4 concurrency and exponential backoff.
    - `eval/bayesian_eval.py`: Bayesian posterior and 95% credible interval calculation.
    - `eval/prompt_cache.py`: Semantic cache for API efficiency.
    - `eval/splits.json`: Training (26) vs. Validation (18) test set split.
- **Current Task:** G7 — Repeatability Baseline using the new async runner.

## Key Agents & Skills
- `meta-agent-factory`: Generates new skills/agents from requirements.
- `skill-quality-validator`: Measures trigger rate and audits security.
- `autoresearch-optimizer`: Auto-repairs skills with < 75% pass rate.
- `agentic-cicd-gate`: Manages deployment, rollback, and flaky test detection.
- `changeling-router`: Handles dynamic identity switching.

## Operational Guidance
- Always run `eval/check-permissions.sh` after modifying any agent or skill file.
- When adding a new Skill, ensure Level 1 description includes: `[action verb] + [specific task object] + [trigger context] + [exclusion context]`.
- **Baseline a skill**: run `python3 eval/run_eval_async.py <skill>`, then pipe results to `bayesian_eval.py` to get posterior mean + CI.
- **Optimization decision**: use `bayesian_eval.py --compare old.json new.json` — commit only if CIs do not overlap.
- **Optimizer analysis**: only read Training set (T) failures from `eval/splits.json` when proposing description changes. Never read Validation set (V) during optimization — it is the held-out test.
- **Deployment gating**: `pre-deploy.sh` requires posterior mean ≥ 0.90 AND lower CI bound ≥ 0.80.
- Read `CHALLENGES.md` for full rationale behind the Bayesian approach and why raw pass rate is insufficient.
- Read `CANVAS.md` for current task dispatch status and guardian review criteria.
