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
  - `run_eval_async.py`: **Primary runner (G9).** Asyncio + Semaphore(1). Robust case-insensitive trigger detection.
  - `bayesian_eval.py`: **Bayesian module (G10).** Correctly counts `FAIL:*` prefixes and models Beta distribution.
  - `prompt_cache.py`: **Semantic cache (G11).** Smart logic: description-sensitive for all positive cases and failing negative cases.
  - `tci_compute.py`: **Task Coupling Indexer (G14).** 4-dimension scoring for topology routing.
  - `splits.json`: Defines T/V split (26/18).

## Current Status (Phase 3)

| Task | Status | Notes |
|------|--------|-------|
| Phase 0–2 | ✅ Complete | Infrastructure, factory, validator, CI/CD gate |
| G9 Async runner | ✅ Verified | Robust trigger regex added (G13) |
| G10 Bayesian module | ✅ Verified | Beta posterior + CI non-overlap decision rule |
| G11 Prompt cache | ✅ Verified | Description-sensitivity confirmed |
| G12 pre-deploy logic| ✅ Complete | Bayesian hook implemented |
| G13 Trigger Audit | ✅ Complete | Case-insensitive robust matching implemented |
| G14 TCI Logic | ✅ Complete | `eval/tci_compute.py` drafted |
| G15 Agent Audit | ✅ Complete | Descriptions audited and refined for authority |
| G7 Baseline Run | ⏳ Pending | Quota reset in ~1h; runner upgraded with --split |
| G8 First optimizer | 🔲 Blocked | Blocked on G7 |

## G7 Eval History (Recent)

### Run 1 (concurrency=1, --no-cache) — ❌ INVALID
- **Mean**: 0.207 | **CI**: [0.083, 0.369]
- **Skips**: 17 (quota hit)
- **Key Observation**: 0/22 positive triggers detected.

### Run 2 (concurrency=1, --no-cache) — ❌ INVALID
- **Mean**: 0.622 | **CI**: [0.462, 0.769]
- **Skips**: 9 (quota hit)
- **Key Observation**: 0/13 positive triggers detected.

**Baseline Conclusion**: Signal is stable enough to show total trigger failure. Meta-Agent Factory is NOT triggering on any positive cases.

## Operational Guidance
- **NEVER** write to `CANVAS.md`.
- **Baseline a skill**: run `python3 eval/run_eval_async.py <skill> --no-cache`.
- **Optimization decision**: use `bayesian_eval.py --compare old.json new.json`.
- **TCI**: Use `python3 eval/tci_compute.py` to assess task coupling.
