# Phase 5 Design Input Index — Pre-I/O Checkpoint

**Created**: 2026-04-24 (factory-steward)
**Purpose**: Consolidated inventory of all Phase 5 (Topology-Aware Multi-Agent) design inputs accumulated during Phases 1–4. Serves as the pre-I/O checkpoint — after Google I/O (May 19-20), each entry gets a post-I/O disposition assessment.
**Source**: Discussion 2026-04-23 A2 (elevated from P3 to P2), Discussion 2026-04-24 A4 (I/O Sensitivity section)

---

## Design Inputs

| # | File | Topic | Strategic Priority | Created | Post-I/O Disposition |
|---|------|-------|-------------------|---------|---------------------|
| 1 | `proposals/2026-04-17-three-track-topology-dispatch-design.md` | Three canonical Anthropic patterns (Orchestrator-Worker, Advisor, Three-Agent Harness) mapped to TCI bands | S2 | Apr 17 | _pending_ |
| 2 | `proposals/done/2026-04-16-tci-calibration-anchors.md` | Empirical TCI thresholds from Anthropic production data (1 agent → 10+ subagents) | S2 | Apr 16 | _pending_ |
| 3 | `evaluations/adk-v2-tci-comparison.md` | ADK v2.0 vs Claude Agent SDK subagent routing comparison framework | S2/S3 | Apr 22 | _pending_ |
| 4 | `evaluations/workflow-state-convergence.md` | Five-way convergence analysis: ADK lazy scan, Vercel WDK replay, Managed Agents event log, our state machine | S2 | Apr 13 | _pending_ |
| 5 | `evaluations/credential-isolation-design.md` | Per-agent credential scoping for Phase 5.3 security | S1 | Apr 18 | _pending_ |
| 6 | `evaluations/permission-cache-design.md` | Session-scoped permission cache for HITL reduction in parallel multi-agent teams | S1 | Apr 18 | _pending_ |
| 7 | `proposals/2026-04-18-otel-tracing-phase5.md` | OTEL-native distributed tracing replacing file-based logging | S2 | Apr 18 | _pending_ |
| 8 | `proposals/2026-04-18-session-rewind-design-note.md` | Session-level checkpointing for optimizer failure recovery | S2 | Apr 18 | _pending_ |
| 9 | `proposals/2026-04-05-a2a-phase5-evaluation.md` | A2A v1.0.0 message bus vs custom schema for scrum-team-orchestrator | S2/S3 | Apr 5 | _pending_ |
| 10 | `proposals/2026-04-17-sprint-contract-manifest-v0.md` | Structured JSON handoff for Three-Agent Harness pipeline stages | S2 | Apr 17 | _pending_ |
| 11 | `proposals/2026-04-20-hooks-sanitization-phase5.md` | .claude/ directory scanning before agent execution on cloned repos | S1 | Apr 20 | _pending_ |
| 12 | `evaluations/post-io-response-playbook.md` | Google I/O response plan mapping announcements to pipeline actions | S2/S3 | Apr 20 | _pending_ |
| 13 | `proposals/2026-04-20-phase5-design-freeze.md` | Phase 5 design freeze consolidation plan (May 22-26) | Operational | Apr 20 | _pending_ |
| 14 | `papers/s2-multi-agent-orchestration/data/orchestration-taxonomy.md` | Agent-centric vs workflow-centric vs hybrid paradigm taxonomy | S2 | Apr 23 | _pending_ |
| 15 | `papers/s2-multi-agent-orchestration/data/topology-data.json` | Empirical orchestration topology execution metrics | S2 | Apr 18 | _pending_ |

All paths are relative to `knowledge_base/agentic-ai/`.

---

## I/O Sensitivity Assumptions

Items below document Phase 5 design assumptions that Google I/O (May 19-20) is most likely to invalidate. After I/O, check each assumption and update the disposition column above for affected design inputs.

| Assumption | Affected Inputs | Risk Level | What I/O Could Change |
|-----------|----------------|------------|----------------------|
| ADK v2.0.0b1 is the latest beta — graph-based orchestration API is preliminary | #3, #4, #9 | HIGH | ADK v2.0 GA could ship with breaking changes to `BaseNode`/`Workflow` APIs. All design notes comparing ADK v2.0 become stale if node type hierarchy changes. |
| A2A is at v1.0.0 — no new inter-agent protocol features since Cloud Next | #9, #10 | MODERATE | A2A v1.1+ could introduce streaming, session management, or new message types that affect our scrum-orchestrator design. Signed agent cards (Cloud Next) may become mandatory. |
| TCI routing is our novel contribution — no vendor equivalent exists | #1, #2, #3 | MODERATE | If Google announces a built-in orchestration routing mechanism in ADK v2.0 GA, our TCI framework needs to position against it (complement vs. compete). |
| MCP tool hooks are CC v2.1.118 feature — not yet in our pipeline | #6, #11 | LOW | I/O unlikely to affect CC-specific features. But if Google announces MCP hook equivalents, the S3 comparison surface expands. |
| Gemini CLI dispatch uses `invoke_subagent` (v0.39.0) | #3 | MODERATE | Gemini CLI v0.40.0+ could rename or restructure dispatch primitives, invalidating the S3 dispatch comparison. |
| OTEL is the right tracing standard for multi-agent observability | #7 | LOW | Both vendors already support OTEL. Risk is if I/O announces a competing agent-specific observability standard. |
| Subagent resumability API (`agentId` in Agent tool result, `resume: sessionId`, 30-day cleanup) remains as documented Apr 28 | §5.4 below | MODERATE | I/O could rename `agentId` → `subagentId`, change `resume:` parameter location, alter cleanup default, or restrict resume to same-parent sessions. Phase 5.4 Inspect-Resume design references the *contract* (handle + corrective prompt), not field names — rename absorbs cleanly; semantic changes (e.g., transcript-not-preserved-across-resume) require redesign. |
| Dispatch primitives (`subagent_type` in Anthropic Agent tool, `invoke_subagent` in Gemini CLI) remain as today | #3, canonical schema (planned `tools/dispatch-transpiler/canonical-skill-schema.json`) | MODERATE | ADK v2.0 GA could change the dispatch surface (rename, restructure parameters, expose `invoke_subagent` differently). Canonical schema's portable subset would need re-derivation; transpiler implementations (deferred D1) gated on this. |

---

## 5.4 Recovery: Inspect-Resume Pattern

**Source**: Discussion 2026-04-28 Round 1 Adopt #1 (P1). Composes Anthropic's Apr 28 subagent-resumability primitive with our planned topology-aware watchdog. **Novel pattern — not present in either vendor's published documentation.** Citable in the S2 paper recovery-pattern section.

**Status**: Design note only. Implementation deferred to Phase 5 (post-I/O); this section captures the architectural commitment so when Phase 5 begins, the watchdog (5.4) is built on resume semantics, not kill+retry.

### Why Inspect-Resume

The earlier Phase 5.4 watchdog assumption was kill+retry: a misbehaving subagent terminates and re-launches from scratch. That loses the in-session reasoning context, doubles token cost, and gives the operator no inspection point. Subagent resumability (Anthropic Agent SDK, documented Apr 28) inverts the loop:

```
DETECTED_ANOMALY → PAUSED → HUMAN_INSPECT → (RESUMED with corrective context | ABORTED)
```

Subagent transcripts persist in separate files, are unaffected by main-conversation compaction, and have a 30-day cleanup default — making "pause now, inspect later, resume with correction" architecturally feasible without an external state store.

### State Machine

```
┌──────────────┐
│ EXECUTING    │  (subagent running, parent monitoring)
└──────┬───────┘
       │ anomaly signal (cost / cmd-chain / MCP-depth / tool-sequence / operator-flag)
       ▼
┌──────────────┐
│ PAUSED       │  (parent persists sessionId + agentId + anomaly payload)
└──────┬───────┘
       │ human triage (or automated policy for known-fatal signals, e.g. cost ceiling)
       ▼
┌────────────────────────┐
│ HUMAN_INSPECT          │  (operator reads preserved subagent transcript, decides)
└──┬─────────────────┬───┘
   │ approve+context │ reject
   ▼                 ▼
┌──────────────────┐  ┌────────────────┐
│ RESUMED          │  │ ABORTED        │
│ Agent(           │  │ (transcript    │
│   subagent=X,    │  │  archived,     │
│   resume=sid,    │  │  task          │
│   prompt=fix)    │  │  re-routed)    │
└──────────────────┘  └────────────────┘
```

### Anomaly Signals (today's detectability)

| Signal | Detectable Today? | Source |
|--------|------------------|--------|
| Cost ceiling breach | YES | `scripts/lib/cost_ceiling.sh` (deployed) |
| Command-chain anomaly (>30 subcommands) | YES | `scripts/cmd_chain_monitor.sh` + `post-tool-use.sh` |
| MCP depth attack (>15 calls) | YES | `post-tool-use.sh` MCP depth monitor |
| Tool-sequence pattern (e.g., 5 consecutive Bash to deny-adjacent binary) | YES | `post-tool-use.sh` (extension hook point) |
| Operator-flagged behavior | YES | manual signal via dashboard |
| Token-burn anomaly | **NO** | No per-session token counter exposed today. Design must remain honest about this gap; reachable when Anthropic exposes per-session token telemetry. |

### Resume Contract

- Parent stores `(sessionId, agentId, anomaly_payload)` in `logs/phase5_task_state.jsonl` (Phase 5.3.2 external session state store).
- Resume invocation: `Agent(subagent_type=X, resume=sessionId, prompt=corrective_context)`.
- The corrective `prompt` carries the operator's observation + what to do differently. Subagent transcript is intact; fresh-context isolation within the subagent's own session is preserved.
- Automated-policy fallback (no human required) for unambiguous fatal signals: cost ceiling = always ABORT; MCP depth ≥ block threshold = always ABORT; cmd-chain anomaly = PAUSE then auto-ABORT after operator timeout.

### Implementation Order (Phase 5, post-I/O)

1. Capture `agentId` from Agent tool result into router task state log.
2. Add PAUSE state to `topology-aware-router` (today: dispatch-only; pause = synthetic operator-injected halt).
3. Minimal `scripts/inspect_resume.sh` for human-driven triage (display preserved transcript, prompt for approval + corrective context, emit resume invocation).
4. Wire automated PAUSE triggers from existing detectors (cost ceiling, cmd-chain, MCP depth).

### Boundaries (DO NOT)

- Create a standalone file `evaluations/inspect-resume-pattern.md` (REJECT R1 in discussion 2026-04-28 — fragments the Phase 5 design surface).
- Implement before Phase 5 begins (this is a design note, not implementation work).
- Cite as a vendor-published pattern (it's our composition).

### S2 Paper Anchor

This section is empirical anchor #5 for the S2 multi-agent-orchestration paper (joining SPIFFE, Memory Profiles, dispatch convergence, agent definition format portability). The composition of resumability + topology-aware watchdog is the novel contribution.

---

## Post-I/O Review Process

1. **During I/O (May 19-20)**: The researcher captures all announcements per the post-I/O response playbook (#12)
2. **May 21 (T+1)**: Research-lead issues post-I/O directive with specific design input impacts
3. **May 22-26 (Design Freeze week)**: Factory-steward updates each row's "Post-I/O Disposition" column:
   - **Still valid** — design input unchanged, proceed to Phase 5 implementation
   - **Needs update** — core insight holds but details changed (e.g., API renamed)
   - **Superseded** — vendor shipped equivalent, design input needs fundamental rethink
   - **Strengthened** — I/O data confirms/deepens the design input

---

## Change Log

| Date | Change |
|------|--------|
| 2026-04-24 | Initial index created from 15 scattered design inputs. I/O Sensitivity section added per discussion A4. |
| 2026-04-28 | Added §5.4 Recovery: Inspect-Resume Pattern (Adopt #1 from 2026-04-28 discussion, P1) — composes Apr 28 subagent-resumability primitive with topology-aware watchdog; novel pattern, S2 paper anchor #5. Added 2 rows to I/O Sensitivity table (Adopt #6, P2): subagent resumability API + dispatch primitives. |
