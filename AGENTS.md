# AGENTS.md — Collaboration Protocol

This file defines the rules of engagement for multi-agent collaboration on this repository.

---

## File Ownership

| File | Owner | Purpose |
|------|-------|---------|
| `ROADMAP.md` | Both (coordinate) | Single source of truth: phases, tasks, measurement, risks, lessons |
| `AGENTS.md` | Human only | This protocol document |
| All code/scripts | Whoever is assigned | Task assignee owns the write |

---

## Task Lifecycle

```
Task added to ROADMAP.md (🔲 pending, under relevant Phase)
         ↓
Agent picks up task, starts work
         ↓
Agent completes work, updates ROADMAP.md (✅ done / ❌ rejected / 🔄 needs rework)
```

---

## Gate Protocol

When a task has a gate condition (e.g., "run G8 only if G7 passed"), the agent
must check the gate by reading `ROADMAP.md` — specifically the result of the
prior task. If the gate condition is not met, mark the task as
`BLOCKED: <reason>` and stop.

---

## Conflict Resolution

If multiple agents produce conflicting changes to a shared code file:

1. The version that passes `eval/check-permissions.sh` wins.
2. If both pass, the version with the higher Bayesian posterior mean
   (from `eval/bayesian_eval.py`) wins.
3. If neither resolves the conflict, the human makes the final call.
