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
