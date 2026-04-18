# AGENTS.md — Collaboration Protocol

This file defines the rules of engagement for multi-agent collaboration on this repository.

---

## File Ownership

| File | Owner | Purpose |
|------|-------|---------|
| `ROADMAP.md` | Gemini/Claude (coordinate) | Single source of truth: phases, tasks, measurement, risks, lessons |
| `AGENTS.md` | Human only | This protocol document |
| `GEMINI.md` | Gemini only | Gemini's operating mandates |
| `CLAUDE.md` | Claude only | Claude's operating mandates |
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

---

## Paper Collaboration Protocol

The S2 multi-agent orchestration paper is a joint Claude + Gemini project. Both
teams produce independent paper candidates, then cross-review and merge.

### Workspace Boundaries

| Path | Claude | Gemini |
|------|--------|--------|
| `papers/s2-multi-agent-orchestration/claude-candidate/` | Read/Write | Read only (Phase 2+ review) |
| `papers/s2-multi-agent-orchestration/gemini-candidate/` | Read only (Phase 2+ review) | Read/Write |
| `papers/s2-multi-agent-orchestration/literature/` | Read/Write | Read/Write |
| `papers/s2-multi-agent-orchestration/methodology/` | Read/Write | Read/Write |
| `papers/s2-multi-agent-orchestration/data/` | Read/Write | Read/Write |
| `papers/s2-multi-agent-orchestration/figures/` | Read/Write | Read/Write |
| `papers/s2-multi-agent-orchestration/reviews/` | Write own reviews only | Write own reviews only |
| `papers/s2-multi-agent-orchestration/merged/` | Human only | Human only |
| `knowledge_base/agentic-ai/experiments/` | Read/Write | Read/Write |

### Phase Rules

- **Phase 1 (Independent)**: Neither team reads the other's candidate directory.
- **Phase 2 (Cross-Review)**: Teams may read (not write) the other's candidate for review purposes.
- **Phase 3 (Revision)**: Teams revise their own candidate only, based on received reviews.
- **Phase 4 (Merge)**: Human selects base candidate, merges best sections.

### Paper Conflict Resolution

If candidates make conflicting empirical claims:
1. The version with stronger data evidence (cites specific log files, includes CIs) wins.
2. If both are equally supported, the human makes the final call.
