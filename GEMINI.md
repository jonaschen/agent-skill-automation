# GEMINI.md - Agent Skill Automation Memory

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
- **Scalar Metric:** Binary eval pass rate (0 or 1 per test case).
- **Fixed Budget:** 30 fixed test prompts in `eval/prompts/`.
- **Target:** ≥ 90% trigger rate for deployment.

## Repository Structure
- `.claude/agents/`: Core agent definition files (e.g., `meta-agent-factory.md`).
- `.claude/skills/`: Per-skill directories containing `SKILL.md`, `scripts/`, and `references/`.
- `.claude/hooks/`: Lifecycle hooks (`pre-deploy.sh`, `post-tool-use.sh`, `stop.sh`).
- `eval/`: Evaluation logic and data.
  - `run_eval.sh <skill-path>`: Runs binary eval loop and prints pass rate.
  - `check-permissions.sh <file>`: Validates permission rules.
  - `prompts/`: 30 fixed test prompts (`test_1.txt` to `test_30.txt`).
  - `expected/`: Expected trigger/content for evaluation.
- `~/.claude/@lib/agents/`: Changeling role library (global, read-only).

## Current Status (Phase 2)
- **Phase 0 & 1 Complete:** Infrastructure setup and `meta-agent-factory` implemented.
- **Phase 2 In Progress:** Building `skill-quality-validator` and `agentic-cicd-gate`.
- **Current Task:** Strengthening the eval runner (`eval/run_eval.sh`) and building test sets for existing skills.

## Key Agents & Skills
- `meta-agent-factory`: Generates new skills/agents from requirements.
- `skill-quality-validator`: Measures trigger rate and audits security.
- `autoresearch-optimizer`: Auto-repairs skills with < 75% pass rate.
- `agentic-cicd-gate`: Manages deployment, rollback, and flaky test detection.
- `changeling-router`: Handles dynamic identity switching.

## Operational Guidance
- Always run `eval/check-permissions.sh` after modifying any agent or skill file.
- When adding a new Skill, ensure Level 1 description includes: `[action verb] + [specific task object] + [trigger context] + [exclusion context]`.
- Use `eval/run_eval.sh` to baseline any skill before optimization.
- Deployment gating is strictly enforced via `pre-deploy.sh` (requires ≥ 90% pass rate).
