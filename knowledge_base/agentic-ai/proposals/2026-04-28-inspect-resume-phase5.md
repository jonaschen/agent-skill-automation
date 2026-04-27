# Skill Proposal: Inspect-Resume Pattern as Phase 5.4 Design Section

**Date**: 2026-04-28
**Triggered by**: Finding 2 (analysis 2026-04-28) — subagent resumability documented in Agent SDK between Apr 24 and Apr 28: parent receives `agentId` in Agent tool result and can `resume: sessionId` to continue an interrupted subagent. Subagent transcripts persist in separate files, are unaffected by main-conversation compaction, default 30-day cleanup. **First long-running multi-agent pattern available without external state stores.** Discussion 2026-04-28 Round 1 Adopt #1 (P1).
**Priority**: **P1** (highest architectural leverage from this cycle's findings)
**Target Phase**: Phase 5 (topology-aware multi-agent), specifically §5.4 watchdog-circuit-breaker

## Rationale

Our prior Phase 5 watchdog design (in the design index) assumed kill+retry as the recovery loop: a misbehaving subagent gets terminated and re-launched from scratch. This is expensive (LLM API tokens, lost in-session state) and brittle (no operator inspection of *why* it misbehaved).

Subagent resumability inverts the recovery loop:

```
DETECTED_ANOMALY → PAUSED → HUMAN_INSPECT → (RESUMED with corrective context | ABORTED)
```

Neither vendor publishes this pattern explicitly. It's the natural composition of:
1. Anthropic's resumability primitive (Apr 28 docs)
2. Topology-aware routing (our planned TCI router)
3. Existing anomaly detectors (cost ceiling, command-chain monitor, MCP depth monitor)

This is **publishable material for the S2 paper's recovery-pattern section** — the cross-pollination opportunity CP1 in today's analysis.

## Proposed Specification

- **Name**: Inspect-Resume Pattern (Phase 5.4 design section)
- **Type**: Design artifact (section within existing Phase 5 design index)
- **Owner**: factory-steward
- **Location**: New section "5.4 Recovery: Inspect-Resume Pattern" inside the Phase 5 design index (NOT a standalone file — see REJECT R1 in discussion 2026-04-28)

**Section contents**:

### State Machine

```
┌──────────────┐
│ EXECUTING    │  (subagent running, parent monitoring)
└──────┬───────┘
       │ anomaly signal
       ▼
┌──────────────┐
│ PAUSED       │  (parent records sessionId + agentId; subagent transcript preserved)
└──────┬───────┘
       │ human triage (or automated policy if available)
       ▼
┌────────────────────────┐
│ HUMAN_INSPECT          │  (operator reads subagent transcript, decides)
└──┬─────────────────┬───┘
   │ approve+context │ reject
   ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ RESUMED      │  │ ABORTED      │
│ (resume:     │  │ (transcript  │
│  sessionId,  │  │  archived,   │
│  prompt:     │  │  task        │
│  corrective) │  │  re-routed)  │
└──────────────┘  └──────────────┘
```

### Anomaly Signals (with detectability today)

| Signal | Detectable Today? | Source |
|--------|------------------|--------|
| Cost ceiling breach | YES | `scripts/lib/cost_ceiling.sh` (already deployed) |
| Command-chain anomaly (>30 subcommands) | YES | `scripts/cmd_chain_monitor.sh` + `post-tool-use.sh` |
| MCP depth attack (>15 calls) | YES | `post-tool-use.sh` MCP depth monitor |
| Tool-sequence pattern (e.g., 5 consecutive Bash to deny-rule-adjacent binary) | YES (post-tool-use hook can detect) | hook |
| Token-burn anomaly | NO | no per-session token counter exposed today; design must be honest about this gap |
| Operator-flagged behavior | YES | manual signal via dashboard |

### Resume Contract

- Parent stores `(sessionId, agentId, anomaly_payload)` in `logs/phase5_task_state.jsonl` (already proposed — Phase 5.3.2 task)
- Resume invocation: `Agent(subagent_type=X, resume=sessionId, prompt=corrective_context)`
- Corrective `prompt` carries operator's observation + what to do differently
- Subagent transcript is intact — fresh-context model preserved within the subagent's own session

## Implementation Notes

**Dependencies**:
- Phase 5 design index (factory P1 item #1) — exists, this becomes a new section
- Subagent resumability documented at https://code.claude.com/docs/en/agent-sdk/subagents (Apr 28)
- Phase 5.3.2 external session state log (`logs/phase5_task_state.jsonl`) — must store `sessionId` + `agentId`
- Anomaly detectors: cost ceiling + command-chain monitor + MCP depth monitor (deployed)

**Implementation order** (when Phase 5 starts, post-I/O):
1. Integrate `agentId` capture into router's task state log
2. Add PAUSE state to topology-aware-router (today: dispatch-only; pause = synthetic operator-injected halt)
3. Build minimal `scripts/inspect_resume.sh` for human-driven triage (read transcript, approve/reject)
4. Wire automated PAUSE triggers from existing detectors

**Risk**:
- Resumability API may shift at I/O — Apr 28 documentation is brand new. Mitigation: design references the contract (agentId + resume:sessionId), not specific field names; if I/O renames, the design absorbs the rename.
- Human-in-the-loop bottleneck — Inspect-Resume requires human judgment. Mitigation: design includes "automated policy" fallback for simple cases (e.g., cost ceiling = always abort).
- Token-burn detection gap — no API support today. Mitigation: design notes this as a known limitation; can be added when Anthropic exposes per-session token counter.

**Do NOT**:
- Create standalone file `evaluations/inspect-resume-pattern.md` (rejected in discussion R1 — fragments Phase 5 design surface)
- Implement before Phase 5 begins (this is a design note, not an implementation task)
- Cite as a vendor-published pattern (it's our composition)

## Estimated Impact

- **Architectural**: Inverts recovery loop from kill+retry to pause+inspect+resume. Strictly better cost profile; better operator visibility.
- **S2 paper**: Citable as a novel proposed pattern in the recovery-patterns section. **Empirical anchor #5 for the S2 paper** (joins SPIFFE, Memory Profiles, dispatch convergence, ... and now Inspect-Resume composition).
- **I/O readiness**: Adds 1 row to Phase 5 design index I/O Sensitivity table (resumability API stability).
- **Cost**: ~30 min factory-steward time to write the section.
