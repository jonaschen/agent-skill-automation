# Skill Proposal: Dedicated Shadow Eval Cron Job
**Date**: 2026-04-20
**Triggered by**: Analysis Finding 1 — shadow eval time budget mismatch (88-min eval exceeds 44-min factory session)
**Priority**: P1 (high) — S1 strategic priority boost (+1 from P2)
**Target Phase**: Phase 4.4 (Security hardening / operational infrastructure)
**Discussion ID**: A2

## Rationale

The gate-first contract A1 works end-to-end: the factory script detects pending model migrations via `experiment_log.json`, prepends the shadow eval to the session prompt, and the LLM correctly launches the eval. However, the eval (~88 minutes for T=39) cannot complete within the factory session's ~44-minute cron budget. This is a scheduling problem, not an architecture problem.

A dedicated cron job running the eval as a direct Python script (no Claude session) at 11:30 PM — before the night cycle starts at 1:00 AM — eliminates the time budget conflict. The job is idempotent: it checks `experiment_log.json` for results before running, fires only when `PENDING_MIGRATION_MODEL` is set with zero matching entries, and writes results that the factory session reads at 3:00 AM.

This completes the S1 self-improvement loop: researcher detects model -> deprecation registry tracks -> migration runbook defines criteria -> **shadow eval runs automatically** -> factory reads go/no-go -> graduated rollout begins. Zero human intervention for future model migrations.

## Proposed Specification

- **Name**: `scripts/daily_shadow_eval.sh`
- **Type**: Cron script (not a Skill or agent — direct Python invocation)
- **Schedule**: 11:30 PM Asia/Taipei (before night cycle)
- **Key Capabilities**:
  - Reads `PENDING_MIGRATION_MODEL` from `daily_factory_steward.sh` config
  - Checks `experiment_log.json` for existing results (skip if present)
  - Runs `python3 eval/run_eval_async.py --model $MODEL --split train --inter-test-delay 15 .claude/agents/meta-agent-factory.md`
  - Writes performance JSON to `logs/performance/shadow-eval-YYYY-MM-DD.json`
  - Sources `session_log.sh` for event logging
  - Sources `cost_ceiling.sh` for duration guardrails
- **Tools Required**: None (Python script, not Claude session)

## Implementation Notes

- **No Claude session cost**: This is a direct `python3` invocation. API costs come only from the eval's internal `claude -p` calls per test case.
- **Firing frequency**: Only when a pending migration exists with zero results. Most days: instant skip. When it fires: once per model release, ~90 minutes, amortized over months.
- **API overlap**: Running at 11:30 PM avoids all existing cron slots. The `--inter-test-delay 15` parameter spaces out API calls.
- **Pre-flight**: Should run `eval/validate_experiment_log.py` (A3) before writing results, once that validator exists.
- **Prerequisite**: Jonas must still do the manual run NOW for the current Opus 4.7 migration. This cron job prevents the same problem for the next model release.

## Estimated Impact

- **S1**: Closes the last gap in the autonomous model migration loop. Future model releases (Sonnet 4 retirement Jun 15, Opus 4 retirement Jun 15) will be evaluated automatically.
- **Operational**: Eliminates factory session time competition. Factory sessions can focus on ADOPT work.
- **Cost**: Negligible — one 90-min eval per model release (~4-6 per year).
