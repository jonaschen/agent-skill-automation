# Skill Proposal: Experiment Log Validator
**Date**: 2026-04-20
**Triggered by**: Analysis Finding 1 — experiment_log.json parse error concern; A1 gate-first depends on this file's integrity
**Priority**: P2 (medium) — S1 strategic priority alignment (data integrity for self-improvement loop)
**Target Phase**: Phase 4.4 (Security hardening)
**Discussion ID**: A3

## Rationale

The experiment log (`eval/experiment_log.json`) is the state file for the entire S1 self-improvement loop. The gate-first contract (A1) reads it to determine whether a shadow eval has been run. If the file is malformed — corrupted JSON, missing fields, duplicate entries — the gate-first check could silently fail (no entries found because parsing fails, not because entries don't exist).

Today's analysis noted a potential parse error in the file. While this may be benign, the risk is real: a corrupted experiment log silently breaks the autonomous model migration loop with no error signal.

## Proposed Specification

- **Name**: `eval/validate_experiment_log.py`
- **Type**: Standalone Python script (not a Skill — validation utility)
- **Description**: Validates experiment_log.json schema and data integrity
- **Key Capabilities**:
  - Valid JSON parse test
  - Required fields present in each entry (model, timestamp, results, split)
  - No duplicate experiment IDs
  - Timestamps in chronological order
  - Results arrays have expected structure (pass/fail/skip per test)
  - Exit code 0 (valid) or 1 (invalid) with structured error output
- **Tools Required**: None (standalone Python)

## Implementation Notes

- ~10-15 lines of Python. Load JSON, iterate entries, check schema, exit.
- **Integration points**: 
  - Called from `pre-deploy.sh` (adds <1s to deploy gate)
  - Called from `daily_shadow_eval.sh` (A2) as pre-flight before writing results
  - Prevents compounding corruption: refuses to write new results to a malformed file
- **Separation of concerns**: This is NOT a flag on `show_experiments.sh` (display tool). Standalone script with clear exit code for automation.

## Estimated Impact

- **S1**: Prevents silent failure of the self-improvement loop's state file
- **Reliability**: Catches corruption early, before it compounds across sessions
- **Cost**: Trivial — 30 minutes to implement, <1s runtime
