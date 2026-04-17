# Skill Proposal: Delegation Regression Monitor for Opus 4.7 Rollout

**Date**: 2026-04-18
**Triggered by**: Opus 4.7 behavioral documentation confirms "fewer subagents spawned by default." Analysis §1.5; Discussion 1.3 (ADOPT P2 — simplified form).
**Priority**: **P2** (medium — monitoring, not blocking)
**Target Phase**: Phase 4 (operational, during 4.7 rollout)

## Rationale

Opus 4.7 prefers reasoning through problems rather than delegating to specialists. Our steward agents (factory-steward, researcher) rely on subagent delegation for core work:
- Factory-steward delegates to meta-agent-factory, skill-quality-validator, autoresearch-optimizer
- Researcher delegates to specialized search/fetch subtasks

If 4.7 reduces delegation, stewards might attempt factory/validation/optimization work themselves — resulting in longer durations, lower quality output, and no explicit error signal.

**Partial mitigation already in place**: L13 in ROADMAP mandates explicit agent naming ("Use the meta-agent-factory agent to..."), which should override the model's default preference. But this hasn't been tested on 4.7.

**Discussion consensus (2026-04-18 Round 1)**:
- ADOPT in simplified form — use existing perf JSON fields (duration, commits) as delegation proxy
- Do NOT build new log parsing infrastructure or add new fields
- If proxy signals a problem (duration 2x+ longer with same commit count), escalate to explicit delegation counting

## Proposed Specification

- **Name**: `delegation-regression-monitor`
- **Type**: Monitoring Protocol (no new Skill, no new infrastructure)
- **Description**: Monitor delegation patterns during Opus 4.7 rollout using existing metrics

**Monitoring Protocol**:

| Signal | Source | Alert Threshold | Action |
|--------|--------|----------------|--------|
| Duration increase | `logs/performance/factory-*.json` | >2x average of last 5 runs on 4.6 | Investigate session logs for missing delegation |
| Commit count decrease | Same perf JSONs | <50% of 4.6 average | May indicate steward doing work inline instead of delegating |
| Duration:commit ratio | Derived | >2x 4.6 baseline | Strong proxy for "doing work itself instead of delegating" |

**Escalation path** (only if proxy signals a problem):
1. Parse session JSONL for `TASK_START` events containing agent names
2. Compare delegation count vs. 4.6 baseline
3. If delegation drops >30%: add stronger delegation prompting to steward skill description

## Implementation Notes

- Zero new code or infrastructure — uses `agent_review.sh` which already shows duration trends
- The human reviewing the 4.7 rollout (per proposal 2026-04-17-opus-4-7-shadow-eval-rollout.md Step 6) should check these signals during the 4-day cascade
- If 4.7's behavior with our explicit naming pattern (L13) shows no degradation, this monitor can be retired after the rollout stabilizes

## Estimated Impact

- Catches silent quality degradation from reduced delegation without building monitoring infrastructure
- Minimal effort: 5 minutes of manual review per rollout day, using existing dashboards
