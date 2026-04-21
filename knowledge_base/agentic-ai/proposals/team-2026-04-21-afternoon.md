# Skill Proposals — 2026-04-21 (Afternoon)

**Source**: Afternoon sweep findings + afternoon Innovator/Engineer discussion
**Strategic alignment**: S1 (3 items), S2 (2 items), Operational (2 items)

---

## Proposal 1: Shadow Eval Per-Test Result Logging

**Date**: 2026-04-21
**Triggered by**: Afternoon analysis Finding 1 — shadow eval produced Opus 4.7 NO-GO verdict (0.683, 27/39 pass) but logged only aggregate results. Zero per-test pass/fail data exists. Blocks S1 failure characterization.
**Priority**: P1 (S1 critical path)
**Target Phase**: Phase 4 (security hardening / shadow eval infrastructure)
**Discussion reference**: Afternoon A1

### Rationale

The entire S1 posture for the next month depends on a binary determination: are the 12 Opus 4.7 failures concentrated in positive tests (routing regression, recoverable via description tuning) or negative tests (fundamental behavior change, needs Anthropic patch)? Without per-test data, the default is "wait for patch" — safe but potentially wasteful.

`run_eval_async.py` already produces per-test output to stdout. The change is purely in `daily_shadow_eval.sh`: capture that stdout, parse per-test pass/fail lines, and include them in the `experiment_log.json` entry as a `per_test_results` array.

### Proposed Specification

- **Name**: Not a new skill — modification to existing `daily_shadow_eval.sh`
- **Type**: Infrastructure enhancement
- **Deliverable**: `per_test_results` array in `experiment_log.json` shadow eval entries
- **Format**:
  ```json
  {
    "per_test_results": [
      {"test_id": 1, "result": "PASS", "duration_s": 12.3},
      {"test_id": 2, "result": "FAIL", "duration_s": 8.7}
    ]
  }
  ```

### Implementation Notes

- Parse `run_eval_async.py` stdout for per-test lines (format: `test_N: PASS|FAIL`)
- Append parsed results to the experiment_log.json entry using `jq`
- Must be in place BEFORE next Opus 4.7 patch triggers cron re-run
- Estimated effort: 30 min, ~30 lines of bash + jq

### Estimated Impact

- Enables S1 failure pattern characterization on next shadow eval run
- Turns aggregate NO-GO into actionable diagnosis (recoverable vs. fundamental)
- Prevents wasting an eval cycle if 4.7 patch ships without this instrumentation

---

## Proposal 2: CC v2.1.116 Fleet Version Bump

**Date**: 2026-04-21
**Triggered by**: Afternoon analysis Finding 2 — CC v2.1.116 shipped with 67% `/resume` speedup, sandbox security fix, MCP startup optimization. Fleet on v2.1.114, two versions behind. Fleet version check (>=2.1.111) will NOT trigger.
**Priority**: P1 (operational)
**Target Phase**: Phase 4 (fleet management)
**Discussion reference**: Afternoon A2

### Rationale

Fleet is two versions behind after the freeze break. The `/resume` 67% speedup directly benefits all steward sessions (factory-steward averages 44 min). The sandbox rm/rmdir safety fix closes a sandbox escape vector relevant to autonomous execution. The fleet version check threshold (>=2.1.111) is stale and won't warn Jonas.

### Proposed Specification

- **Name**: Not a new skill — one-line file update + human upgrade action
- **Type**: Operational
- **Deliverable**: `fleet_min_version.txt` updated to >=2.1.116

### Implementation Notes

- Factory: update `scripts/lib/fleet_min_version.txt` to `>=2.1.116`
- Jonas: run CC upgrade (`npm i -g @anthropic-ai/claude-code` or equivalent)
- Two-part action: factory (1 min) + Jonas (5 min)

### Estimated Impact

- Dashboard warns Jonas on every review until upgrade completes
- `/resume` speedup reduces context-loading time for all steward sessions
- Security fix closes sandbox escape vector

---

## Proposal 3: SessionStore v0.1.64 Design Note

**Date**: 2026-04-21
**Triggered by**: Afternoon sweep — Agent SDK v0.1.64 ships production SessionStore with S3, Redis, Postgres adapters and conformance tests. Directly impacts Phase 5.3.2 external session state store design.
**Priority**: P2 (S2 — Phase 5 design prep)
**Target Phase**: Phase 5 (5.3.2 task-level workflow state tracking)
**Discussion reference**: Afternoon A3

### Rationale

Phase 5.3.2 currently specifies custom append-only `logs/phase5_task_state.jsonl` for crash recovery. SessionStore offers a higher-abstraction alternative: SDK-native session persistence with pluggable backends. Simplifies crash recovery from "parse JSONL, find last checkpoint, rebuild context" to "call `getSession(id)` + `resume()`."

Trade-off: SessionStore couples Phase 5.3.2 to the Agent SDK migration (5.3.3). Custom JSONL works with current `claude -p` invocations and can be replaced later.

### Proposed Specification

- **Name**: Not a new skill — design note addition to `workflow-state-convergence.md`
- **Type**: Design documentation
- **Deliverable**: "Leading candidate: SessionStore v0.1.64" section with coupling trade-off

### Implementation Notes

- Add as candidate, NOT decided architecture — decision deferred to Design Freeze (May 22-26)
- Document three adapters (S3/Redis/Postgres), conformance test availability
- Note 5.3.3 coupling trade-off explicitly
- 10-minute annotation

### Estimated Impact

- Records that the industry shipped exactly the abstraction we planned to build custom
- Provides Design Freeze week with pre-analyzed option
- Fifth convergent pattern for `workflow-state-convergence.md` analysis

---

## Proposal 4: Shadow Eval Failure Analysis Template

**Date**: 2026-04-21
**Triggered by**: Afternoon discussion — without a pre-built analysis template, the next shadow eval result requires ad-hoc interpretation. Pre-writing the template makes results immediately actionable.
**Priority**: P2 (S1 — analysis readiness)
**Target Phase**: Phase 4 (model migration infrastructure)
**Discussion reference**: Afternoon A4

### Rationale

When the next Opus 4.7 patch triggers a shadow eval re-run (with per-test logging from Proposal 1), someone needs to interpret the results. A pre-written decision tree with explicit thresholds turns qualitative judgment into quantitative classification.

### Proposed Specification

- **Name**: Not a new skill — addition to `eval/model_migration_runbook.md`
- **Type**: Analysis template
- **Deliverable**: "Shadow Eval Failure Analysis" section with:
  1. Three failure categories: positive (1-22), hallucination (23-39), near-miss (40-59)
  2. Per-category failure RATE (not raw count — denominators matter: 22 positive, 17 hallucination, 20 near-miss)
  3. Decision tree: >66% failure rate in one category → concentrated; otherwise → mixed
  4. S1 action mapping: concentrated-positive → description tuning; concentrated-negative → wait for patch; mixed → both

### Implementation Notes

- Add to existing `eval/model_migration_runbook.md` after the Shadow Eval Results Checklist section
- 15-minute addition
- Engineer refinement: use per-category failure RATE, not raw count

### Estimated Impact

- Eliminates analysis delay between "shadow eval results available" and "S1 decision made"
- Makes the S1 go/no-go determination mechanistic rather than subjective

---

## Proposal 5: ADK YAML RCE as A2 Security Dimension

**Date**: 2026-04-21
**Triggered by**: Afternoon sweep — ADK v1.31.1 patches critical RCE via nested YAML unsafe deserialization. Our pipeline avoids this class architecturally (LLM parsing, not YAML library).
**Priority**: P3 (S2 — comparison framework enrichment)
**Target Phase**: Phase 5 (A2 comparison framework from morning discussion)
**Discussion reference**: Afternoon A5

### Rationale

The ADK YAML RCE provides a concrete security comparison point for the A2 ADOPT item. Including security posture as a comparison dimension costs 5 minutes and provides evidence for the S2 paper's security analysis section.

### Proposed Specification

- **Name**: Not a separate deliverable — line item in A2 comparison framework
- **Type**: Framework dimension
- **Dimensions**: Config parsing (YAML library vs. LLM), auth surface, minimum safe version (v1.31.1+), MCP tool auth

### Implementation Notes

- Note both vulnerability AND response time (patched within same release cycle)
- Sets minimum ADK version (v1.31.1+) for any future Phase 5 integration evaluation
- 5-minute addition when A2 is built — no separate task

### Estimated Impact

- S2 paper gains concrete security comparison case study
- Phase 5 integration evaluation has documented minimum version floor

---

## Proposal 6: Release Cadence Note in I/O Playbook

**Date**: 2026-04-21
**Triggered by**: Afternoon analysis Finding 5 — first observed selective freeze break on Google side. ADK independent of CLI/A2A/Vertex. Security patches override freeze coordination.
**Priority**: P3 (operational — I/O preparation)
**Target Phase**: Phase 4 (I/O readiness)
**Discussion reference**: Afternoon A6

### Rationale

Today's selective freeze break reveals release cadence intelligence useful for I/O week forecasting: Anthropic breaks synchronized, Google ADK breaks independently, Google CLI is I/O-synchronized, A2A is stability-driven.

### Proposed Specification

- **Name**: Not a new skill — 2-3 sentence addition to `post-io-response-playbook.md`
- **Type**: Playbook annotation
- **Location**: Pre-I/O checklist section, as "forecasting context" paragraph

### Implementation Notes

- References afternoon analysis Finding 5
- Minimal change, useful context for I/O week
- 5 minutes

---

## Proposal 7: Sweep Corrections Log

**Date**: 2026-04-21
**Triggered by**: Evening sweep caught hallucinated ADK v1.32.0 from afternoon Google sweep. Second version hallucination caught by evening consolidation. Need measurement data for hallucination rate.
**Priority**: P3 (process quality)
**Target Phase**: Phase 4 (research quality)
**Discussion reference**: Afternoon A7

### Rationale

The evening consolidation sweep is the defense against sweep hallucinations (correctly rejected formalizing LLM verification — R1). But we should MEASURE the correction rate. A JSONL log of corrections provides data for future decisions: if hallucination rate increases, justify automated post-sweep verification; if it stays low, confirm two-sweep architecture is sufficient.

### Proposed Specification

- **Name**: Not a new skill — log file + researcher instruction
- **Type**: Measurement infrastructure
- **Deliverable**: `logs/sweep_corrections.jsonl` + instruction addition to `agentic-ai-researcher.md`
- **Format**:
  ```json
  {"date": "2026-04-21", "sweep": "afternoon-google", "claim": "ADK v1.32.0", "correction": "only v1.31.1 exists", "verification_method": "gh api + PyPI", "category": "version_hallucination"}
  ```

### Implementation Notes

- Researcher appends entry whenever evening consolidation issues a correction
- This logs a VERIFIED fact (post-correction), not a claimed fact (pre-verification)
- 5-minute instruction addition + log file creation

### Estimated Impact

- Provides measurement data for hallucination rate tracking
- Enables data-driven decision about whether to add automated post-sweep verification
