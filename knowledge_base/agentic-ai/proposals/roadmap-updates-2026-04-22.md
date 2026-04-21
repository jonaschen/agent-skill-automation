# ROADMAP Update Recommendations — 2026-04-22

**Source**: Analysis 2026-04-22 + Discussion 2026-04-22
**Directive compliance**: Single-cycle, no new research areas

---

## Change 1: Update ROADMAP Status Line

**Location**: ROADMAP.md line 4 (status line)
**Priority**: P1
**Action**: Update status to reflect today's state:

```
Status as of 2026-04-22: Phase 4 core complete. Per-test shadow eval logging implemented (commit 79c98c7). Opus 4.7 #49562 STILL OPEN — third-party ecosystem pressure growing (3 repos). Factory queue: 13 items (7 carried + 6 new). Deep Research MCP integration = strongest S3 convergence signal. 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Countdowns: 1M context beta sunset 8d (Apr 30, CLOSED — non-issue), Google I/O 27d (May 19-20). Phase 4 core complete.
```

---

## Change 2: Phase 5.1 — Planning Confirmation Design Note (Discussion A2)

**Location**: ROADMAP.md Phase 5.1 (after existing TCI Router tasks)
**Priority**: P3
**Effort**: 5 min
**Action**: Add design note:

```
> **Design note (2026-04-22)**: For tasks with high TCI, the topology-aware-router SHOULD emit a human-readable plan summary before dispatching to subagents. The plan summary includes: task decomposition, TCI score, selected topology, estimated duration, and assigned agents. In interactive mode, execution pauses until the user confirms the plan. In cron mode, the plan is logged but execution proceeds automatically. Threshold to be calibrated against 4.2b task distribution data. Pattern reference: Google Deep Research collaborative planning (Interactions API, Apr 2026) — validated at production scale.
```

**Rationale**: Deep Research proves the planning confirmation pattern works in production at Google scale. This is architectural validation, not speculative design.

---

## Change 3: Phase 5.3.2 — Async Agent Dispatch Convergence (Discussion A4)

**Location**: `knowledge_base/agentic-ai/evaluations/workflow-state-convergence.md` (new section §5)
**Priority**: P2
**Effort**: 20 min
**Action**: Add new section documenting two-vendor convergence on async agent dispatch:

| Dimension | Anthropic Managed Agents | Google Deep Research | Our Phase 5.3.1 |
|-----------|-------------------------|---------------------|-----------------|
| Submission | POST /agents | POST /interactions | closed_loop.sh submit |
| Background | session-based | background=true | cron dispatch |
| Status | session endpoint | polling/streaming | perf JSON |
| Timeout | billing-based | 60 min hard limit | cost_ceiling.sh |
| Results | session content | interaction response | logs/ artifacts |

**Rationale**: Two independent vendors converging on the same async pattern de-risks Phase 5.3.1 design. Engineer correctly redirected this from a separate file to an existing convergence document.

---

## Change 4: Phase 5.6 Design Freeze Document List Update

**Location**: ROADMAP.md Phase 5.6 task description
**Priority**: P2
**Action**: Add to the document consolidation list:
- `knowledge_base/agentic-ai/evaluations/remote-mcp-feasibility.md` (when created, Discussion A1)

The Design Freeze (May 22-26) now has 9+ input documents. The remote MCP feasibility study feeds directly into Phase 5's cross-vendor interop design.

---

## Change 5: Shadow Eval Prefix Match (Discussion A3)

**Location**: `scripts/daily_shadow_eval.sh` — PENDING_MIGRATION_MODEL handling
**Priority**: P2 (S1 critical path)
**Effort**: 15 min
**Action**: Change experiment_log.json lookup from exact string match to prefix match. When checking if a shadow eval has been run for `PENDING_MIGRATION_MODEL=claude-opus-4-7`, use grep pattern `claude-opus-4-7` (prefix) rather than exact match. This catches patched model IDs (e.g., `claude-opus-4-7-20260425`) without requiring manual variable update.

**What NOT to do**: No Anthropic API model enumeration. Manual model ID updates (10 seconds) remain acceptable when prefix breaks.

**Rationale**: Per-test logging (commit 79c98c7) and failure analysis template are ready. The trigger mechanism is the last S1 gap. If Anthropic patches #49562 with a different model ID, we'd miss the automatic shadow eval re-run.

---

## Change 6: I/O Playbook Deep Research Note (Discussion A5)

**Location**: `knowledge_base/agentic-ai/evaluations/post-io-response-playbook.md` — Pre-I/O Checklist section
**Priority**: P3
**Effort**: 2 min
**Action**: Add 3-line note:

```
- Deep Research (Apr 21) shipped as API-only (Interactions API), not Agent Builder. I/O announcements may follow this API-first pattern. Monitor Gemini API changelog alongside Agent Builder release notes.
```

**Rationale**: Changes what we expect at I/O. API-first launches mean Agent Builder freeze may continue even as new agent capabilities ship.

---

## No Phase 7 Changes

Discussion Proposal 3.2 (pricing model notes for Phase 7) was REJECTED. The analysis already documents the pricing divergence in `analysis/2026-04-22.md`. ROADMAP tracks tasks, not background research. Phase 7 planning can reference the analysis when it starts.

---

## Factory-Steward Priority Queue (Updated)

Combined: 7 carried from Apr 21 + 6 new ADOPTs = 13 total. Recommended processing order:

1. **A3: Shadow eval prefix match** (P2, 15 min) — S1 critical path
2. **A2-afternoon-carried: ADK v2.0 TCI comparison framework** (P2, 30 min)
3. **A1: Remote MCP feasibility study** (P2, 30 min) — Phase 5.6 input
4. **A4: Async dispatch convergence §5** (P2, 20 min) — Phase 5.6 input
5. **A6: S3 problem decomposition update** (P2, 5 min)
6. **A3-afternoon-carried: SessionStore design note** (P2, 10 min)
7. **A3-morning-carried: Phase 5 design index** (P3, 20 min)
8. **A2: Phase 5.1 planning confirmation note** (P3, 5 min)
9. **A5: I/O playbook update** (P3, 2 min)
10. **A6+A7-afternoon-carried: I/O playbook note + sweep corrections log** (P3, 10 min combined)
11. Carried: Programmatic Tool Calling deny rule (P1, human action)
12. Carried: G20 MCP false-positive tests (P2)

Estimated total effort: ~3h across ~4 factory-steward sessions.

---

## Human Action Items (Unchanged)

1. **Upgrade CC to v2.1.116** — 67% `/resume` speedup, sandbox security fix (P1)
2. **Install Gemini CLI** — gates all S3 implementation work (S3)
3. **No shadow eval action** — infrastructure autonomous, prefix match is factory's next item
