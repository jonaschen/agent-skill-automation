# Skill Update Suggestions — 2026-04-21 (Afternoon)

**Source**: Afternoon analysis + afternoon discussion (freeze break findings)
**Authority**: Researcher recommendation — requires human review before applying
**Supplements**: `skill-updates-2026-04-21.md` (morning — noted "no updates needed" during freeze)

---

## Update 1: `agentic-ai-researcher.md` — Sweep Corrections Logging Instruction

**File**: `.claude/agents/agentic-ai-researcher.md`
**Priority**: P3
**Source**: Afternoon discussion A7

### Current State

The researcher agent has no instruction to log corrections when the evening consolidation sweep identifies and fixes errors from earlier sweeps.

### Proposed Change

Add to the "Research Integrity" constraints section:

```markdown
- **Log corrections** — when the evening consolidation sweep identifies and corrects
  an error from an earlier sweep (hallucinated version, wrong date, incorrect claim),
  append a structured entry to `logs/sweep_corrections.jsonl`:
  ```json
  {"date": "YYYY-MM-DD", "sweep": "<sweep-name>", "claim": "<what was wrong>", "correction": "<what is correct>", "verification_method": "<how verified>", "category": "<error type>"}
  ```
  This measures hallucination rate over time. The log is append-only with 30-day retention.
```

### Rationale

The two-sweep architecture (primary + evening consolidation) correctly catches hallucinations. Adding a log instruction provides measurement data for the correction rate. The researcher logs a VERIFIED fact (post-correction), not a claimed fact — this is safe.

---

## Update 2: `daily_shadow_eval.sh` — Per-Test Result Capture

**File**: `scripts/daily_shadow_eval.sh`
**Priority**: P1
**Source**: Afternoon analysis Finding 1, afternoon discussion A1

### Current State

The shadow eval script captures only aggregate results from `run_eval_async.py`. Per-test pass/fail detail is produced on stdout but discarded by the wrapper.

### Proposed Change

1. Capture `run_eval_async.py` stdout to a temp file
2. Parse per-test pass/fail lines (format: `test_N: PASS|FAIL|SKIP`)
3. Build a JSON array of per-test results
4. Include the array as `per_test_results` in the `experiment_log.json` entry
5. Clean up temp file

### Rationale

S1 critical path. The entire model migration posture depends on knowing WHICH tests fail, not just HOW MANY.

---

## Update 3: `workflow-state-convergence.md` — SessionStore as Fifth Pattern

**File**: `knowledge_base/agentic-ai/evaluations/workflow-state-convergence.md`
**Priority**: P2
**Source**: Afternoon analysis Finding 3, afternoon discussion A3

### Current State

Documents four convergent workflow state patterns.

### Proposed Change

Add a fifth pattern section documenting Agent SDK SessionStore v0.1.64 as a leading candidate for Phase 5.3.2. Mark as "leading candidate, decision at Design Freeze" — not decided. Include 5.3.3 coupling trade-off.

### Rationale

The industry shipped exactly the abstraction Phase 5.3.2 was planning to build. Recording this ensures the Design Freeze week has a pre-analyzed option.

---

## Update 4: `post-io-response-playbook.md` — Release Cadence Forecasting

**File**: `knowledge_base/agentic-ai/evaluations/post-io-response-playbook.md`
**Priority**: P3
**Source**: Afternoon analysis Finding 5, afternoon discussion A6

### Current State

The pre-I/O checklist section has no forecasting context about vendor release cadence patterns.

### Proposed Change

Add 2-3 sentence paragraph to pre-I/O checklist: Anthropic breaks synchronized, Google ADK breaks independently (security-driven), CLI is I/O-synchronized, A2A is stability-driven.

### Rationale

Minimal change, useful forecasting context for I/O week preparation.

---

## Update 5: `eval/model_migration_runbook.md` — Failure Analysis Template

**File**: `eval/model_migration_runbook.md`
**Priority**: P2
**Source**: Afternoon discussion A4

### Current State

Has "Shadow Eval Results Checklist" (fill-in-the-blank results + go/no-go gates) but no structured template for characterizing WHY a shadow eval failed.

### Proposed Change

Add "Shadow Eval Failure Analysis" section with:
- Three test categories with counts (positive/22, hallucination/17, cross-domain+near-miss+real-world/20)
- Per-category failure rate table (fill-in-the-blank)
- Decision tree: >66% concentration threshold → routing regression vs. fundamental vs. mixed
- S1 action mapping for each pattern

### Rationale

Makes next shadow eval result immediately actionable. Eliminates analysis delay between results and S1 decision.

---

## Status of Previously Identified Skill Updates (Morning List)

| Skill | Pending Update | Status | Change from Morning |
|-------|---------------|--------|-------------------|
| `meta-agent-factory` | Shadow eval for Opus 4.7 | Pending | Per-test logging needed first (this afternoon's P1) |
| `agentic-ai-researcher` | Sweep corrections logging | **NEW** | Add logging instruction (P3) |
| `agentic-cicd-gate` | No changes needed | Current | Unchanged |
| `autoresearch-optimizer` | No changes needed | Current | Unchanged |
| `changeling-router` | No changes needed | Current | Unchanged |

## Potential Future Updates (Updated)

1. ~~Post-freeze release burst~~ → **RESOLVED**: Freeze broke. CC v2.1.116 + ADK v1.31.1 shipped. No skill description changes needed from these releases.
2. **ADK v2.0 GA**: When shipped (expected I/O), evaluate `topology-aware-router` description. The A2 comparison framework (morning A2) will prepare for this.
3. **A2A v1.1**: When shipped, evaluate `scrum-team-orchestrator` description.
