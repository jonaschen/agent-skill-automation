# ROADMAP Update Recommendations — 2026-04-28

**Source**: Analysis 2026-04-28 + Discussion 2026-04-28 + 3 sweeps (Anthropic night/morning, Google morning, both-track afternoon)
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update ROADMAP Status Line

**Section**: Top-level status paragraph
**Priority**: P1
**Rationale**: Day counts updated. CC v2.1.119/.120 shipped (target now v2.1.119, avoid v2.1.120). Subagent resumability primitive documented (Apr 28). Dispatch-primitive comparison delivered. #49562 root cause closed by Apr 23 postmortem.

**Current** (excerpt):
> Status as of 2026-04-24 (afternoon factory session): ...Countdowns: 1M context beta sunset 6d (Apr 30), Google I/O 25d (May 19-20)...

**Proposed update** (next factory session):
> Status as of 2026-04-28: Phase 4 core complete. Eval suite at 64 tests (T=44, V=20). Shadow eval blocked on CC upgrade — target now **v2.1.119** (avoid v2.1.120: 8 community regressions, silent release, broken auto-update). #49562 root cause closed by Apr 23 postmortem (3 engineering missteps; Opus 4.7 model exonerated). Subagent resumability documented Apr 28 — Inspect-Resume pattern adopted as Phase 5.4 design section. Dispatch-primitive comparison delivered (verdict: transpiler feasible) — canonical skill schema queued. A2A v1.0.0 confirmed (media "v1.2" remains incorrect). 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Countdowns: 1M context beta sunset 2d (Apr 30), Phase 4 deadline 11d (May 9), Google I/O 21d (May 19-20).

---

## PROPOSED CHANGE 2: Phase 5.4 Watchdog — Inspect-Resume Pattern Section

**Section**: Phase 5.4 `watchdog-circuit-breaker`
**Priority**: P1
**Rationale**: Finding 2 — subagent resumability documented Apr 28. Discussion Adopt #1 (P1). Inverts watchdog recovery loop from kill+retry to pause+inspect+resume. **First long-running multi-agent pattern available without external state stores.** Citable in S2 paper.

**Proposed addition** to Phase 5.4 task list (replacing the current single bullet `- [ ] Write watchdog-circuit-breaker.md (Haiku model — no reasoning, monitoring only)`):

```
#### 5.4 watchdog-circuit-breaker (Inspect-Resume Pattern)
- [ ] Write `.claude/agents/watchdog-circuit-breaker.md` (Haiku — no reasoning, monitoring only)
- [ ] **Design note (2026-04-28)**: Adopt Inspect-Resume pattern (state machine: EXECUTING → PAUSED → HUMAN_INSPECT → RESUMED|ABORTED) instead of kill+retry. Composes Anthropic's resumability primitive (agentId + resume:sessionId, documented Apr 28) with our existing anomaly detectors (cost ceiling, command-chain monitor, MCP depth monitor). Design specification in Phase 5 design index §5.4. Citable as novel pattern in S2 paper recovery-pattern section.
- [ ] Wire automated PAUSE triggers from existing detectors
- [ ] Build minimal `scripts/inspect_resume.sh` for human-driven triage (read transcript, approve/reject)
- [ ] Token-burn detection: deferred until per-session token counter exposed by Anthropic API
```

Reference: proposal `2026-04-28-inspect-resume-phase5.md`.

---

## PROPOSED CHANGE 3: S3 Architectural Surface Commit (Canonical Schema)

**Section**: Strategic Research Themes / S3 — under Phase 5.3 or new sub-section
**Priority**: P2
**Rationale**: Finding 6 (transpiler feasibility verdict). Discussion Adopt #3 (P2). Schema-only commitment is reversible; transpiler implementations deferred until Gemini CLI install (D1).

**Proposed addition** to Strategic Research Themes / S3 section:

```
### S3 Architectural Surface (2026-04-28)

Following the 2026-04-28 dispatch-primitive comparison (verdict: transpiler feasible), S3
commits the architectural surface in two stages:

**Stage 1 (now, P2)**: Canonical Skill Schema at `tools/dispatch-transpiler/canonical-skill-schema.json`
- JSON Schema describing the portable subset (name, description, system_prompt, tools,
  mcpServers, model_alias)
- Round-trip test against existing 23 Claude agents (≥20/23 pass criterion)
- Reversible commitment; defines the contract that future transpilers reference

**Stage 2 (deferred, P2)**: Transpiler implementations (`transpile_to_claude.py`,
`transpile_to_gemini.py`)
- Blocked on Gemini CLI install (day 7+ blocker)
- Open question: does Gemini expose `invoke_subagent` as a callable tool name? Empirical
  validation post-install determines `transpile_to_gemini.py` design

**Stage 3 (deferred, P1 for next-but-one directive)**: Orchestration-protocol comparison
(A2A multi-hop vs SDK forked subagents) — sequenced after factory P2 backlog clearance.
```

Reference: proposals `2026-04-28-canonical-skill-schema.md`, `2026-04-28-deferred-items.md`.

---

## PROPOSED CHANGE 4: CC Upgrade Target Revision (v2.1.118 → v2.1.119, avoid v2.1.120)

**Section**: Phase 4 Tasks #4.4 (or wherever fleet version policy lives) + general operational notes
**Priority**: P1
**Rationale**: Finding 1. CC v2.1.119 = `PostToolUse.duration_ms` + parallel MCP-server reconfig + `--resume` 67% speedup. v2.1.120 = silent release, `--resume` TypeError crash, broken auto-update could strand fleet. Eight community regressions across both versions. v2.1.121 expected to land within 2-4 days as the natural fix point.

**Proposed update** (search-and-replace in ROADMAP):

- Where ROADMAP currently says "shadow eval awaiting CC upgrade to v2.1.118" → change to **"v2.1.119"**
- Where `eval/fleet_min_version.txt` says `>=2.1.116` → consider bump to `>=2.1.119` once Jonas upgrades (no change to file content yet — bump is a downstream factory action)
- Add explicit advisory: "**Avoid CC v2.1.120**: silent release, eight community regressions, broken auto-update. Target v2.1.119 until v2.1.121 ships."

Reference: operational-hygiene proposal Item 2 (CC version advisory section in `eval/model_migration_runbook.md`).

---

## PROPOSED CHANGE 5: Phase 5 I/O Sensitivity Registry — Two New Rows

**Section**: Phase 5 design index I/O Sensitivity table (factory P1 item #1)
**Priority**: P2
**Rationale**: Discussion Adopt #6. Today's two new architectural primitives are now load-bearing assumptions for Phase 5 design.

**Proposed addition** (2 rows to existing I/O Sensitivity table):

```markdown
| Subagent resumability | agentId in Agent tool result, resume:sessionId, default 30-day cleanup | Phase 5.4 Inspect-Resume section | If I/O changes resume API, Phase 5.4 design needs revision |
| Dispatch primitive surface | Claude Agent(subagent_type, prompt) + Gemini invoke_subagent(agent, prompt) | Canonical skill schema (S3 Stage 1) | If ADK v2.0 changes dispatch surface, schema needs review |
```

Effort: ~5 minutes during normal factory work.

---

## PROPOSED CHANGE 6: Phase 4.4 — Task↔Agent Dual-Name Validator Pass

**Section**: Phase 4.4 Security hardening (or general operational hygiene)
**Priority**: P1
**Rationale**: Finding 5. CC v2.1.63 renamed dispatch tool from `Task` to `Agent`, but SDK still emits `"Task"` in `system:init` payloads. Latent defect in any pattern-matching code that checks only one name. Discussion Adopt #2 (P1).

**Proposed addition** to Phase 4.4 task list:

```
- [ ] **Task↔Agent dual-name validator pass**: Grep `eval/`, `scripts/lib/`, `scripts/`, `.claude/hooks/`, `.claude/agents/` for hardcoded `"Task"` or `"Agent"` string literals matching the dispatch tool name pattern. Update each match to accept both names (`tool_name in ("Task", "Agent")` semantics). ~10 min of work, low blast radius — P1
```

Reference: operational-hygiene proposal Item 1.

---

## PROPOSED CHANGE 7: S2 Paper Trigger — Anchor Surfacing in Dashboard

**Section**: General research-pipeline notes / S2 paper status
**Priority**: P3
**Rationale**: Discussion Adopt #7. S2 paper has accumulated 5 empirical anchors (SPIFFE, Memory Profiles, dispatch convergence, Inspect-Resume, subagent resumability). Paper-pipeline trigger gate is "factory queue < 10 items." Informational dashboard surfacing makes the trigger discoverable without flicker.

**Proposed addition** to research-pipeline notes:

```
### S2 Paper Pipeline Trigger (2026-04-28)

The S2 multi-agent orchestration paper accumulates empirical anchors as research findings
land. Anchors are tracked in `papers/s2-multi-agent-orchestration/anchors.md`. Current
count: 5 pending (SPIFFE, Memory Profiles, dispatch convergence, Inspect-Resume composition,
subagent resumability primitive).

**Trigger condition**: Factory queue < 10 items AND ≥ 4 unincorporated anchors. Both
conditions surface as informational message in `agent_review.sh` (no threshold flicker).
Jonas decides when to run `scripts/paper_pipeline.sh`.
```

Reference: operational-hygiene proposal Item 5.

---

## No New Risks Identified

Existing risks accurately calibrated. Key updates this cycle:
- **#49562**: CLOSED by Apr 23 postmortem. Three engineering missteps named, all reverted by Apr 20. Opus 4.7 model exonerated. Remove from active risk tracking; one-sentence status only.
- **CC version pin**: v2.1.119 confirmed; v2.1.120 contraindicated. v2.1.121 expected as fix point within 2-4 days.
- **A2A version**: v1.0.0 stable. Misreport propagation continues (3 channels) — rebuttal note proposed in operational-hygiene Item 3.
- **Subagent resumability**: NEW primitive, Phase 5 design impact (positive — strictly better recovery loop).
- **Dispatch portability**: ARCHITECTURAL UNKNOWN RESOLVED — transpiler feasible. Schema-only commit queued.
- **Factory queue**: ~15 items, P2 backlog aging since Apr 22. Discussion adopted 0 net-new queue items today.

---

## Day Counts (for next status update)

| Item | Days | Date |
|------|------|------|
| CC v2.1.119 release | 5 | Apr 23 |
| CC v2.1.120 silent release | 4 | Apr 24 |
| Subagent resumability documented | 0 | Apr 28 |
| Dispatch comparison delivered | 0 | Apr 28 |
| CC upgrade blocker | 9+ | human action |
| Gemini CLI install blocker | 11+ | human action |
| #49562 (root cause closed by postmortem) | CLOSED | Apr 23 postmortem |
| 1M context beta sunset | 2 | Apr 30 |
| Phase 4 deadline | 11 | May 9 |
| Google I/O | 21 | May 19-20 |
| Opus 4/Sonnet 4 retirement | 48 | Jun 15 |
