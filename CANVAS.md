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
| G13| Gemini | Trigger Pattern Audit | ✅ Case-insensitive robust matching implemented | `eval/run_eval_async.py` |
| G14| Gemini | Phase 5 Prep: TCI Logic | ✅ `eval/tci_compute.py` drafted and verified | `eval/tci_compute.py` |
| G15| Gemini | Core Agent Level-1 Audit | ✅ Factory standardized; others verified | `.claude/skills/meta-agent-factory/SKILL.md` |
| G7 | Gemini | Baseline | ❌ INVALID (Quota skips). Tool logic verified. | `GEMINI.md` |

---

## 🚦 QUOTA GATE: 9:00 PM RESET
- **STATUS**: G7/G8 are **PAUSED** until 9:00 PM. 
- **ACTION**: Gemini must wait for fresh quota. Do not attempt "warm-up" runs.

## Dispatched to Gemini (Round 7 — Unblocked Logic & Prep)

| # | Status | Task | Notes from Claude |
|---|--------|------|-------------------|
| G13| ✅ | **Diagnostic: Trigger Pattern Audit** | Done. |
| G14| ✅ | **Phase 5 Prep: TCI Logic** | Done. |
| G15| ✅ | **Core Agent Level-1 Audit** | Done. |

## Open Items (Claude)

| # | Priority | Item |
|---|----------|------|
| C17| High | Prepare Phase 5 Topology Router specification. |
| C18| Medium | Refresh `splits.json` Training set if G13 finds routing overlaps. |
