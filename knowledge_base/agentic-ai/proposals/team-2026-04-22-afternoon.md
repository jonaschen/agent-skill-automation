# Strategic Planning Output — 2026-04-22 Afternoon

**Mode**: 2c (L4 Strategic Planning)
**Source**: Sweep 2026-04-22-afternoon + Analysis 2026-04-22-afternoon + Discussion 2026-04-22-afternoon
**Directive**: 2026-04-22 (single-cycle volume, shadow eval = factory concern, minimal sweep if no releases)

---

## Executive Summary

Both vendors broke their freezes on Apr 22 — the morning MODERATE burst forecast proved correct same-day. CC v2.1.117 is the headline: the Opus 4.7 context window fix (200K→1M) means the shadow eval NO-GO (0.683) was measured under broken conditions. This is the single most important S1 finding since per-test logging shipped. Additionally, a triple convergence on agent definitions carrying tool dependencies (CC mcpServers + ADK App/Plugin + Deep Research MCP) is the strongest S3 format evidence to date. Six afternoon ADOPTs, two DEFERs, zero REJECTs.

Factory queue: ~10 items remaining (3 cleared this cycle, commit 6e70617) + 6 afternoon ADOPTs = ~16 total. At 3 items/session, ~5-6 sessions to clear. Throughput healthy.

---

## Strategic Priority Assessment

### S1 — Automatic Agent/Skill Improvement

**Status**: CRITICAL FINDING — shadow eval baseline may be contaminated.

**CC v2.1.117 context window fix**: The shadow eval NO-GO (0.683, CI [0.535, 0.814]) was run on a CC version that computed Opus 4.7's context window against 200K instead of 1M. Premature autocompacting may have caused some of the 12/39 failures — meaning the true Opus 4.7 pass rate could be materially higher.

**Implication**: Upgrading CC to v2.1.117 and re-running shadow eval is now the **single highest-priority action** for S1. The re-run will disambiguate: failures that disappear = CC bug victims; failures that persist = Opus 4.7 model behavior (#49562). The per-test logging (commit 79c98c7) and prefix match (commit 6e70617) are ready to capture granular results.

**Adopted actions**:
- A1: Shadow eval re-run protocol documentation (P1, 10 min)
- A4: OTEL effort integration plan as conditional next-diagnostic (P3, 5 min)

**Blocked on**: Jonas upgrading CC to v2.1.117 (P0 human action, elevated from P1).

### S2 — Multi-Agent Orchestration

**Status**: Event compaction convergence adds Phase 5 design input. Forked subagent isolation deferred.

**New findings**:
1. **Event compaction convergence** — ADK Java sliding window + CC autocompaction both solve long-session context exhaustion. Phase 5 sprint-orchestrator needs a context management strategy (hybrid: proactive for orchestrator state, reactive for sub-agent detail).
2. **Forked subagent isolation** — `CLAUDE_CODE_FORK_SUBAGENT=1` enables process isolation within sessions. Promising for factory-steward context pollution prevention. Deferred: methodology gaps (headless mode untested, no matched comparison).
3. **Unified subagent tool** — Gemini CLI `invoke_subagent` consolidation mirrors CC's single `Agent` tool. Validates Phase 5 single-dispatch architecture.

**Adopted actions**:
- A2: Phase 5 context management design section (P2, 15 min)

### S3 — Platform Generalization

**Status**: STRONGEST FORMAT EVIDENCE YET — triple convergence on self-contained agent definitions.

**Triple convergence** (within 72h):
1. CC v2.1.117: Declarative `mcpServers` in agent frontmatter
2. ADK Java 1.0: App/Plugin tool declarations
3. Deep Research: MCP server config baked into agent setup

All three solve the same problem: agents declare tool dependencies, runtime provisions them. The portable format's `tools`/`dependencies` section should map to vendor-specific provisioning. MCP is the protocol layer; the format question is how to declare MCP servers.

**Adopted actions**:
- A5: Agent definition format comparison matrix — first concrete S3 artifact (P2, 25 min)
- A3: Gemini CLI channel selection note for when Jonas installs (P3, 5 min)

**Blocked on**: Gemini CLI install (unchanged, longest-standing blocker since Apr 19).

---

## ADOPT Items → Factory Queue

| # | ID | Description | Priority | Effort | Strategic |
|---|-----|------------|----------|--------|-----------|
| 1 | A1 | Shadow eval re-run protocol — document comparison methodology, per-test before/after analysis | P1 | 10 min | S1 critical path |
| 2 | A2 | Phase 5 context management section — ADK event compaction vs. CC autocompaction, hybrid recommendation | P2 | 15 min | S2, Phase 5.6 |
| 3 | A5 | Agent definition format comparison matrix — 3-row scope (CC, ADK Java, Gemini CLI), mark unvalidated | P2 | 25 min | S3, Phase 5.6 |
| 4 | A6 | CC v2.1.117 upgrade impact checklist — 5-point verification, inline in discussion | P2 | 10 min | S1/operational |
| 5 | A3 | Gemini CLI channel selection note — stable baseline + preview for subagent features | P3 | 5 min | S3, operational |
| 6 | A4 | OTEL effort integration plan — conditional next-diagnostic in failure analysis template | P3 | 5 min | S1, Phase 5 |

---

## DEFER Items

| ID | Proposal | Reason | Re-entry Condition |
|----|----------|--------|--------------------|
| D1 | Forked subagent isolation test | n=1 with no matched comparison. Headless mode untested. Methodology gaps. | Phase 5 experiment backlog. Run when structured experiments exist. |
| D2 | Declarative mcpServers frontmatter migration | v2.1.117 mcpServers brand new. Adoption risk on 16-agent fleet. | 1-2 CC releases (~1 week). MCP usage audit proceeds in A5 format study. |

---

## REJECT Items

None this round. All proposals adopted or deferred with clear re-entry conditions.

---

## Risk Register Update

| Risk | Severity | Change | Notes |
|------|----------|--------|-------|
| Shadow eval baseline contaminated by CC context bug | HIGH | NEW | 0.683 NO-GO measured under 200K context (should be 1M). Re-run post v2.1.117 may produce materially different results. |
| Opus 4.7 #49562 unpatched | HIGH | Unchanged | Zero staff responses. 3 third-party repos affected. |
| CC v2.1.117 upgrade blast radius | MEDIUM | NEW | Default effort→high, native bfs/ugrep, MCP concurrent connections. Checklist (A6) addresses. |
| Gemini CLI not installed | MEDIUM | Unchanged | Blocks all S3 implementation. |
| Preview channel instability | LOW | NEW | Gemini CLI preview (v0.39.0-preview.2) shipping aggressively. Channel selection matters for S3 eval reliability. A3 addresses. |

---

## Factory Queue Clearance Tracking

Per directive: track factory queue clearance rate.

| Metric | Value |
|--------|-------|
| Queue entering today | 13 items |
| Cleared this cycle (commit 6e70617) | 3 items (prefix match, S3 decomposition, I/O playbook) |
| Remaining from morning | ~10 items |
| Afternoon additions | 6 items |
| Total queue | ~16 items |
| Throughput | 3 items/session (stable) |
| Sessions to clear | ~5-6 sessions |
| Throughput degradation | None observed |

---

## Directive Compliance Self-Assessment

1. **Single-cycle volume**: One consolidated sweep, one analysis, one discussion. Compliant.
2. **Shadow eval = factory concern**: One-sentence status only. Analysis focuses on CC context window implications, not re-analysis of shadow eval methodology. Compliant.
3. **No new research areas**: None proposed. Compliant.
4. **ADOPT volume**: 6 items + 2 defers. All proposals either adopted with scope adjustments or deferred with clear re-entry conditions. 0 rejections — indicates better calibration from morning's 3 rejections.
5. **Strategic alignment**: S1 (2 ADOPTs + 1 DEFER), S2 (1 ADOPT + 1 DEFER), S3 (2 ADOPTs + 1 DEFER). All three priorities advanced.
6. **Factory queue clearance**: Tracked per directive. 3 cleared this cycle, 16 total queue, throughput healthy.

---

## Recommendations for Next Directive

1. **P0 human action**: Upgrade CC to v2.1.117 (elevated from P1 — blocks clean shadow eval data).
2. **P0**: Continue post-freeze monitoring. Both vendors released today — watch for follow-up releases over next 48h.
3. **P1**: Re-run shadow eval immediately after CC upgrade. Compare per-test results to 0.683 baseline.
4. **P1**: Monitor #49562 — ecosystem pressure + potential CC context window confound changes the diagnostic picture.
5. **If no further releases by Apr 24**: Write minimal sweep (~300 words) per directive guidance. The factory queue provides sufficient work.
6. **Factory throughput note**: 16-item queue at ~3 items/session = ~5-6 sessions. If throughput drops below 2/session, flag in next analysis.
7. **Format matrix (A5)**: Should be created before next research cycle to establish a living S3 reference.
