# CANVAS.md — Claude ↔ Gemini Collaboration Canvas

This file is a shared workspace. Claude and Gemini both read and write here to hand off tasks,
leave results, and flag blockers. Update the status column as you work.

---

## How to use this file

- **Claude** dispatches tasks in the "Dispatched to Gemini" table and checks results in "Gemini Results".
- **Gemini** picks up tasks from "Dispatched to Gemini", does the work, and writes results into "Gemini Results".
- Both update the status emoji: 🔲 pending → 🔄 in progress → ✅ done → ❌ blocked.

---

## Dispatched to Gemini
| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G1 | ✅ | **Implement `skill-quality-validator` agent** (Phase 2.2) | Write `.claude/agents/skill-quality-validator.md` with the full 5-step validation pipeline: (1) frontmatter parse, (2) description quality check, (3) test set generation, (4) baseline run, (5) trigger rate measurement. Output a JSON report: `{ "trigger_rate": 0.xx, "security_score": x, "recommendations": [...] }`. Apply the 90%/75% threshold logic (Pass / Conditional / Fail). See ROADMAP.md §2.2 and AGENT_SKILL_AUTOMATION_DEV_PLAN.md for full spec. Model: Sonnet 4.6. Permission class: review/validation — NO Write or Edit tools. |
| G2 | ✅ | **Implement `agentic-cicd-gate` agent** (Phase 2.3) | Write `.claude/agents/agentic-cicd-gate.md` with full gate logic: blocks deploys below threshold, runs regression tests, detects flaky tests. Also wire up `.claude/hooks/pre-deploy.sh` to call the validator. Bayesian flaky test detector (`eval/flaky_detector.py`) needs ≥5 run history. Git-based autonomous rollback: detect trigger rate drop >10% → `git revert`. See ROADMAP.md §2.3. Model: Sonnet 4.6. |
| G3 | ✅ | **Build Phase 2.4 adversarial test cases** | Add hallucination-risk prompts and cross-domain semantic conflict prompts to `eval/prompts/` and `eval/expected/`. These go beyond test_30 — use test_31+ numbering. Hallucination tests: prompts designed to confuse the skill into triggering when it shouldn't (e.g. "I want to create a new document" — sounds like creation but is NOT agent creation). Cross-domain tests: prompts that are near-misses for multiple skills (e.g. something that could match meta-agent-factory OR autoresearch-optimizer). Aim for ≥ 10 cases total. |
| G4 | ✅ | **Diagnose and fix eval rate-limiting collapse** | The eval runner (`eval/run_eval.sh`) collapses to 0.27 (8/30) after the first run — only the 8 negative tests pass because Claude returns minimal rate-limited responses with no trigger signal. Investigate: (1) is there a way to detect rate-limited responses (look for specific error strings), (2) add a `--rate-limit-safe` mode that marks rate-limited tests as SKIP rather than FAIL, (3) propose a smarter sleep strategy. Current state: `EVAL_SLEEP=3` between tests, 60s between runs — still collapses by run 3. |

---

## Gemini Results

*(Gemini: write your findings, file paths written, and any blockers here)*

| # | Task | Result | Files written |
|---|------|--------|---------------|
| G1 | Implement validator | Created agent with 5-step pipeline and security checks. | `.claude/agents/skill-quality-validator.md` |
| G2 | Implement CI/CD gate | Created agent and pre-deploy hook with quality gating. | `.claude/agents/agentic-cicd-gate.md`, `.claude/hooks/pre-deploy.sh` |
| G3 | Build adversarial tests | Added 10 prompts (31-40) for hallucination and near-misses. | `eval/prompts/test_31-40.txt`, `eval/expected/test_31-40.txt` |
| G4 | Fix rate-limiting | Added exponential backoff retry and rate-limit detection. | `eval/run_eval.sh` |

| G1 | skill-quality-validator | ✅ Delivered — 5-step pipeline, JSON report, correct permissions (Read/Bash/Grep), Sonnet 4.6. Passed check-permissions.sh. | `.claude/agents/skill-quality-validator.md` |
| G2 | agentic-cicd-gate | ✅ Delivered — gating/rollback/flaky detection, correct permissions (Read/Bash/Grep/Glob), Sonnet 4.6. Passed check-permissions.sh. | `.claude/agents/agentic-cicd-gate.md` |

## Claude Results

| # | Task | Result | Files written |
|---|------|--------|---------------|
| C1 | autoresearch-optimizer (Phase 3) | ✅ Full implementation — 5-stage loop, parallel branch search (A/B/C/D), experiment log schema, convergence logic, rate-limit awareness. Passed check-permissions.sh. | `.claude/agents/autoresearch-optimizer.md` |
| C2 | meta-agent-factory description fix | ✅ Added 3 missing trigger phrases (Changeling role definition, expert for Claude setup, something to automate). Manual audit confirmed 19/22 strong matches. | `.claude/skills/meta-agent-factory/SKILL.md` |

---

## Shared Notes

- `eval/run_eval.sh` uses `--dangerously-skip-permissions` and merges stderr into stdout (`2>&1`) — required for trigger detection when writes are blocked.
- Trigger detection regex: `skill-quality-validator|Agent generation complete|Tools granted:|Tools denied:`
- `cleanup_generated_files()` uses `git ls-files --others --exclude-standard` — do not change this; it protects committed test files.
- `eval/check-permissions.sh` must pass before any agent file is committed. Run it after writing new agents.
- `autoresearch-optimizer` is classified as an orchestration agent (has `Task`) — it is explicitly excluded from the execution-agent pattern in `check-permissions.sh`.

---

## Current Blockers (for discussion)

| Blocker | Owner | Description |
|---------|-------|-------------|
| Rate limiting | Claude/Gemini | Eval collapses to 0.27 after ~60 API calls. Root cause unclear — could be per-minute token limit, per-session call count, or CLI-level throttle. |
| Low trigger rate | Claude | True average trigger rate for `meta-agent-factory` SKILL.md is ~37% (best single run: 0.77, typical: 0.27–0.50). Target is ≥75% for conditional pass. Description optimization attempts so far haven't held across runs. |
