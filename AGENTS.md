# AGENTS.md — Collaboration Protocol

This file defines the strict rules of engagement between Claude and Gemini. These rules are non-negotiable and must be followed to prevent reasoning conflicts and state corruption.

---

## ⛔ Strict File Ownership

| File | Writer (Owner) | Reader | Purpose |
|------|----------------|--------|---------|
| `CANVAS.md` | **Claude only** | Gemini (read-only) | Task dispatch, guardian criteria, open items |
| `GEMINI.md` | **Gemini only** | Claude (read-only) | Gemini's status, results, findings, and memory |
| `AGENTS.md` | Human only | Both | This protocol document |
| `ROADMAP.md` | Both (coordinate) | Both | Phase status — update only when a task is confirmed done |
| `CHALLENGES.md` | Claude only | Both | Architectural decisions and strategic rationale |
| All code/scripts | Both | Both | Whoever is assigned the task owns the write |

**CRITICAL RULE**: 
- **Claude** MUST NOT write to `GEMINI.md`.
- **Gemini** MUST NOT write to `CANVAS.md`.

If an agent needs to "correct" or "update" a file it doesn't own, it must instead leave a note in its **own** file (e.g., Gemini leaves a note in `GEMINI.md` for Claude to see and update `CANVAS.md`).

---

## How Claude Uses These Files

1. **Dispatch**: Write tasks to `CANVAS.md` with clear specs and gate conditions.
2. **Monitor**: Read `GEMINI.md` to understand Gemini's current status and results.
3. **Review**: Check deliverables and update `CANVAS.md` to reflect accepted/rejected results (✅/❌).
4. **Correction**: If Gemini's memory in `GEMINI.md` is wrong, update `CANVAS.md` with a correction note.

---

## How Gemini Uses These Files

1. **Receive tasks**: Read `CANVAS.md` to find dispatched tasks (🔲 pending or 🔄 in progress). **Do not modify `CANVAS.md`.**
2. **Report results**: Write all task results, status updates, and findings into `GEMINI.md`.
3. **Update memory**: Keep `GEMINI.md` current — correct stale information and record what was built.
4. **Correction**: If Claude's task in `CANVAS.md` is unclear or wrong, write a blocker/note in `GEMINI.md`. **Do not edit `CANVAS.md` to fix it.**

---

## Task Lifecycle

```
Claude writes task → CANVAS.md (🔲 pending)
         ↓
Gemini reads CANVAS.md, starts work
         ↓
Gemini writes result → GEMINI.md
         ↓
Claude reads GEMINI.md, reviews result
         ↓
Claude updates CANVAS.md (✅ done / ❌ blocked / 🔄 needs rework)
```

---

## Gate Protocol

When a task has a gate condition (e.g., "run G8 only if G7 passed"), Gemini
must check the gate by reading `GEMINI.md` — specifically the result of the
prior task. If the gate condition is not met, Gemini writes
`BLOCKED: <reason>` to `GEMINI.md` and stops. Claude will then decide whether
to re-dispatch or change strategy.

---

## Conflict Resolution

If both agents are working simultaneously and produce conflicting changes to a
shared code file, the following precedence applies:

1. The version that passes `eval/check-permissions.sh` wins.
2. If both pass, the version with the higher Bayesian posterior mean
   (from `eval/bayesian_eval.py`) wins.
3. If neither resolves the conflict, Claude makes the final call.
