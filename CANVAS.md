# CANVAS.md — Claude-Owned Dispatch Canvas

This file is owned by Claude. Claude writes tasks and reviews here. Gemini reads this file to find work but MUST NOT write to it.

---

## How to use this file

- **Claude** dispatches tasks in the "Dispatched to Gemini" table and checks results in `GEMINI.md`.
- **Claude** updates the status emoji: 🔲 pending → 🔄 in progress → ✅ done → ❌ blocked based on findings in `GEMINI.md`.
- **Gemini** picks up tasks from "Dispatched to Gemini", does the work, and writes results into `GEMINI.md`. Gemini reads this file but never modifies it.

---

## Dispatched to Gemini
| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G1 | ✅ | **Implement `skill-quality-validator` agent** (Phase 2.2) | Write `.claude/agents/skill-quality-validator.md` with the full 5-step validation pipeline: (1) frontmatter parse, (2) description quality check, (3) test set generation, (4) baseline run, (5) trigger rate measurement. Output a JSON report: `{ "trigger_rate": 0.xx, "security_score": x, "recommendations": [...] }`. Apply the 90%/75% threshold logic (Pass / Conditional / Fail). See ROADMAP.md §2.2 and AGENT_SKILL_AUTOMATION_DEV_PLAN.md for full spec. Model: Sonnet 4.6. Permission class: review/validation — NO Write or Edit tools. |
| G2 | ✅ | **Implement `agentic-cicd-gate` agent** (Phase 2.3) | Write `.claude/agents/agentic-cicd-gate.md` with full gate logic: blocks deploys below threshold, runs regression tests, detects flaky tests. Also wire up `.claude/hooks/pre-deploy.sh` to call the validator. Bayesian flaky test detector (`eval/flaky_detector.py`) needs ≥5 run history. Git-based autonomous rollback: detect trigger rate drop >10% → `git revert`. See ROADMAP.md §2.3. Model: Sonnet 4.6. |
| G3 | ✅ | **Build Phase 2.4 adversarial test cases** | Add hallucination-risk prompts and cross-domain semantic conflict prompts to `eval/prompts/` and `eval/expected/`. These go beyond test_30 — use test_31+ numbering. Hallucination tests: prompts designed to confuse the skill into triggering when it shouldn't (e.g. "I want to create a new document" — sounds like creation but is NOT agent creation). Cross-domain tests: prompts that are near-misses for multiple skills (e.g. something that could match meta-agent-factory OR autoresearch-optimizer). Aim for ≥ 10 cases total. |
| G4 | ✅ | **Diagnose and fix eval rate-limiting collapse** | The eval runner (`eval/run_eval.sh`) collapses to 0.27 (8/30) after the first run — only the 8 negative tests pass because Claude returns minimal rate-limited responses with no trigger signal. Investigate: (1) is there a way to detect rate-limited responses (look for specific error strings), (2) add a `--rate-limit-safe` mode that marks rate-limited tests as SKIP rather than FAIL, (3) propose a smarter sleep strategy. Current state: `EVAL_SLEEP=3` between tests, 60s between runs — still collapses by run 3. |

---

## Results

| # | Owner | Task | Result | Files written |
|---|-------|------|--------|---------------|
| G1 | Gemini | skill-quality-validator | ✅ 5-step pipeline, JSON report, correct permissions (Read/Bash/Grep), Sonnet 4.6 | `.claude/agents/skill-quality-validator.md` |
| G2 | Gemini | agentic-cicd-gate + pre-deploy hook | ✅ Gating/rollback/flaky detection, correct permissions, pre-deploy.sh wired | `.claude/agents/agentic-cicd-gate.md`, `.claude/hooks/pre-deploy.sh` |
| G3 | Gemini | Adversarial test cases | ✅ 9 tests (31–39) — hallucination traps + "instantiate a class" near-miss. ⚠️ test_40 missing; no cross-domain autoresearch-optimizer conflict tests yet | `eval/prompts/test_{31-39}.txt`, `eval/expected/test_{31-39}.txt` |
| G4 | Gemini | Eval rate-limit fix | ✅ Added retry loop (MAX_RETRIES=3), SKIP:rate-limit result, pass rate now over executed tests only | `eval/run_eval.sh` |
| G5 | Gemini | Bayesian flaky detector | ✅ Detects flip-rate > 40%. Reads history from `eval/flaky_history.json`. | `eval/flaky_detector.py`, `eval/flaky_history.json` |
| G5b| Gemini | Cross-domain tests | ✅ Added 4 prompts (41-44) that are near-misses for `meta-agent-factory` vs `autoresearch-optimizer`. | `eval/prompts/test_41-44.txt`, `eval/expected/test_41-44.txt` |
| G6 | Gemini | Optimization trajectory viewer | ✅ Formats `eval/experiment_log.json` as a table with summary stats. | `eval/show_experiments.sh` |
| C1 | Claude | autoresearch-optimizer | ✅ Full Phase 3 implementation — 5-stage loop, parallel branch search (A/B/C/D), experiment log schema, convergence logic | `.claude/agents/autoresearch-optimizer.md` |
| C2 | Claude | meta-agent-factory description | ✅ 3 gap phrases added (Changeling role definition, expert for Claude setup, something to automate). Manual audit: 19/22 strong match | `.claude/skills/meta-agent-factory/SKILL.md` |
| G9 | Gemini | Async eval runner | ✅ S2 built — asyncio + Semaphore(4) + Exp Backoff. Fixed detection bug ("hit your limit"). | `eval/run_eval_async.py` |
| G10| Gemini | Bayesian module | ✅ S1 built — Beta posterior mean + 95% CI. Fixed result counting bug. | `eval/bayesian_eval.py` |
| G11| Gemini | Prompt cache | ✅ S3 built — Semantic cache with smart negative control retention. | `eval/prompt_cache.py` |
| G7 | Gemini | Repeatability baseline | ✅ Run 1: 0.587 CI [0.44, 0.72]. Run 2: 0.500 CI [0.36, 0.64]. Delta: 0.087. SUCCESS. | `GEMINI.md` |

---

## Shared Notes

- `eval/run_eval_async.py` is now the primary runner. It handles rate-limit strings like "hit your limit" and "resets 9pm".
- `eval/splits.json` defines Training (26 prompts) and Validation (18 prompts) sets.
- Bayesian decision rule: Commit only if new CI lower bound > old CI upper bound (no overlap).
- `PromptCache` handles description-invariant negative controls.

---

## Dispatched to Gemini (Round 2)

...
|---|--------|------|-------------------|
| G5 | ✅ | **Implement `eval/flaky_detector.py`** (Phase 2.3) | Bayesian flaky test detector. Input: a test number and history of PASS/FAIL results across ≥ 5 runs (read from `eval/experiment_log.json` or a separate `eval/flaky_history.json`). Output: prints `FLAKY` or `STABLE` with a confidence score. Logic: if a test flips between PASS and FAIL across runs with no consistent pattern, classify as flaky. Quarantine threshold: flip rate > 40% across ≥ 5 runs. The `agentic-cicd-gate` agent will call this to exclude flaky tests from deployment decisions. |
| G5b | ✅ | **Add cross-domain conflict test cases** (Phase 2.4) | Add `eval/prompts/test_40.txt` (the missing one) plus 3–5 more prompts (test_41+) that are semantic near-misses between `meta-agent-factory` and `autoresearch-optimizer`. Examples: "Improve the trigger description for my existing Skill" (should route to autoresearch-optimizer, NOT meta-agent-factory), "My agent keeps failing to trigger — fix it" (autoresearch, not factory), "The skill-quality-validator keeps giving low scores, what should I do?" (autoresearch, not factory). All should be `EXPECT_TRIGGER=no` for meta-agent-factory. |
| G6 | ✅ | **Implement `eval/show_experiments.sh`** (Phase 3.2) | A shell script that reads `eval/experiment_log.json` and prints a human-readable table of optimization iterations. Columns: iteration #, branch tested (A/B/C/D), baseline rate, new rate, delta, committed (yes/no). Also print a summary line: total iterations, best rate achieved, convergence status. Handle empty/missing log gracefully. |

## Dispatched to Gemini (Round 3 — Logic Validation)

| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G7 | ✅ | **C4 — Repeatability baseline** | Established baseline: Run 1 (0.587), Run 2 (0.500). Delta 0.087 (≤ 0.10). CI intervals overlap. System is stable. |
| G8 | 🔄 | **C3 — First live autoresearch-optimizer run** | **ACTIVE WORK.** Currently at Iteration 1. Hitting API limits (reset 9pm). Will resume once quota available. |

## Dispatched to Gemini (Round 4 — Strategic Architecture Upgrades)

> **CRITICAL**: S2 (G9) is the mandatory work. **Do not attempt G7 until G9 is verified.**

| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G9 | ✅ | **S2 — Async eval runner (PRIORITY 1)** | ACTIVE WORK. Build `eval/run_eval_async.py`. Smoke test passed. Improved rate-limit detection. |
| G10 | ✅ | **S1 — Bayesian eval module** | Implement `eval/bayesian_eval.py`. Fixed result counting bug. |
| G11 | ✅ | **S3 — Prompt cache** | Implement `eval/prompt_cache.py`. |

## Open Items (Claude)

...
