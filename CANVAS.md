# CANVAS.md — Claude-Owned Dispatch Canvas

This file is owned by Claude. Claude writes tasks and reviews here. Gemini reads this file to find work but MUST NOT write to it.

---

## 🏁 CHECKPOINT: ARCHITECTURE STABILIZED (2026-03-29)
The Async/Bayesian infrastructure is fully integrated. We are now in "Data Collection" mode.

---

## Results

| # | Owner | Task | Result | Files written |
|---|-------|------|--------|---------------|
| G9 | Claude | Async eval runner | ✅ S2 Integrated & Verified | `eval/run_eval_async.py` |
| G10| Gemini | Bayesian module | ✅ S1 Integrated & Verified | `eval/bayesian_eval.py` |
| G11| Gemini | Prompt cache | ✅ S3 Integrated & Verified | `eval/prompt_cache.py` |
| G12| Gemini | Bayesian Hook | ✅ Pre-deploy hook now enforces Bayesian gates | `.claude/hooks/pre-deploy.sh` |
| G7 | Gemini | Baseline | ❌ INVALID (Quota skips). Tool logic verified. | `GEMINI.md` |

---

## ⛔ QUOTA BLOCKER (G7/G8)
- **G7 (Baseline)** and **G8 (Optimizer)** are **PAUSED** until quota resets (9:00 PM).
- **Finding**: `meta-agent-factory` is currently reporting 0% trigger rate on positive tests.

## Dispatched to Gemini (Round 7 — Unblocked Logic & Prep)

| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G13| 🔲 | **Diagnostic: Trigger Pattern Audit** | Compare `run_eval_async.py` trigger regex against actual `meta-agent-factory` output. Ensure the runner isn't missing triggers due to string case or formatting. |
| G14| 🔲 | **Phase 5 Prep: TCI Logic** | Draft `eval/tci_compute.py`. Implement the 4-dimension scoring algorithm from AGENT_SKILL_AUTOMATION_DEV_PLAN.md §5.1. Use mock data for now. |
| G15| 🔲 | **Core Agent Level-1 Audit** | Audit descriptions for Validator, Optimizer, and Gate. Ensure they match the `[verb] + [object] + [context]` principle. Fix any that are too vague. |

## Open Items (Claude)

| # | Priority | Item |
|---|----------|------|
| C17| High | Prepare Phase 5 Topology Router specification. |
| C18| Medium | Refresh `splits.json` Training set if G13 finds routing overlaps. |
