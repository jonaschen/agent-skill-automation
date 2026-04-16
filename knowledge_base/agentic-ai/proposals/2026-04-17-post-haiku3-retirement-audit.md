# Skill Proposal: Post-Haiku-3 Retirement Audit (Apr 19)

**Date**: 2026-04-17
**Triggered by**: `claude-3-haiku-20240307` retires 2026-04-19 (2 days). `scripts/model_audit.sh` passed clean on 2026-04-16, but nothing is currently scheduled to re-run it post-retirement. Analysis §1.9; Discussion A2 (ADOPT P0).
**Priority**: **P0** (operational hygiene — single-moment verification window)
**Target Phase**: Phase 4 (security / deprecation detection closed loop)

## Rationale

Retirement day is the single moment when the deprecation guard can reveal a newly-broken reference
— e.g., a cron script silently starting to fail API calls because a docstring or prompt template
referenced the retired model ID. Pre-retirement audits pass trivially; the signal comes from actually
calling the deprecated model on or after retirement date.

**Discussion consensus (2026-04-17 Round 3)**:
- Integrate into Apr 19 factory-steward morning run, not a standalone cron entry (avoids cron sprawl)
- Structured JSONL alert (`logs/security/deprecation_audit.jsonl`), surfaced via `scripts/agent_review.sh` — consistent with existing alert patterns (fleet version, cost alert, mcp depth)
- Same ritual for `gemini-robotics-er-1.5-preview` (Apr 30) and Sonnet 4 / Opus 4 (Jun 15)

## Proposed Specification

- **Name**: Post-retirement audit ritual (runbook + tooling)
- **Type**: Pipeline Operation + Cron Integration
- **Owner**: factory-steward

**Execution Sequence (Apr 19)**:

1. factory-steward morning run (12:00 PM Asia/Taipei) includes pre-flight step:
   ```bash
   scripts/model_audit.sh --retired-on 2026-04-19 --log logs/security/deprecation_audit.jsonl
   eval/security_suite.sh --retired-models --log logs/security/deprecation_audit.jsonl
   ```
2. Non-zero exit → factory-steward halts ROADMAP work, creates an escalation issue, flags to `scripts/agent_review.sh` dashboard
3. Clean exit → append one entry to `eval/deprecated_models.json` extending the original record with `"verified_clean_post_retirement": "2026-04-19"` (append-only; preserves original entry integrity)
4. Update `logs/security/deprecation_audit.jsonl` with structured result (timestamp, model_id, files_scanned, references_found, exit_code)

**JSONL Entry Schema**:
```json
{
  "timestamp": "2026-04-19T04:00:00Z",
  "model_id": "claude-3-haiku-20240307",
  "retirement_date": "2026-04-19",
  "audit_tool": "model_audit.sh",
  "files_scanned": 147,
  "references_found": 0,
  "exit_code": 0,
  "verification": "clean"
}
```

**Recurrence (Future Retirements)**:

| Date | Model | Integration Point |
|------|-------|-------------------|
| 2026-04-30 | `gemini-robotics-er-1.5-preview` | Next factory-steward run post-retirement |
| 2026-05-11 | `claude-3.5-sonnet-20241022` + `claude-3-5-sonnet-20241022` | Next factory-steward run post-retirement |
| 2026-06-15 | `claude-sonnet-4-20250514` + `claude-opus-4-20250514` | Next factory-steward run post-retirement |
| 2026-06-30 | `gpt-4o` (tracking only, not deployed) | Skip — no deployed reference |
| 2026-07-05 | `claude-3.5-haiku-20241022` + `claude-3-5-haiku-20241022` | Next factory-steward run post-retirement |

**Tools Required**: `scripts/model_audit.sh` (exists), `eval/security_suite.sh` (exists)

## Implementation Notes

**Dependencies**:
- `scripts/model_audit.sh` must support `--retired-on DATE` and `--log PATH` flags (verify; may need 10-line patch)
- `eval/security_suite.sh` already logs results; extend to route to `logs/security/deprecation_audit.jsonl` if not already
- `scripts/agent_review.sh` dashboard must surface `deprecation_audit.jsonl` alongside existing alert sources (fleet version, cost, mcp depth)
- factory-steward session prompt adjustment: add one-line pre-flight for Apr 19 run

**Risk**:
- Missed run: if factory-steward fails to start on Apr 19, retirement verification slips. Mitigation: schedule verification across all three Apr 19 factory-steward slots (12 PM, 5 PM, 9 PM) — idempotent, cheap.
- False clean: if `model_audit.sh` only scans a subset of paths, a reference in an overlooked location (docstrings, prompts/, eval expected/) could slip through. Mitigation: audit tool path coverage as part of Step 0.

**Do NOT**:
- Add a dedicated cron entry for Apr 19 (cron sprawl)
- Rely on email alerts (no verified mail daemon in cron environment)
- Modify existing `eval/deprecated_models.json` entries (append-only integrity preserved)

## Estimated Impact

- **Closes the detection loop**: researcher detects announcement → `deprecated_models.json` updated → pre-deploy/cron guard active → post-retirement verification confirms clean (full 4-step closed loop)
- **Reusable ritual**: Same pattern applies to 5+ upcoming retirements over next 90 days
- **Zero incremental cost**: Integrated into existing factory-steward run; no new cron, no new infrastructure
- **Historical integrity**: Each retirement leaves a `verified_clean_post_retirement` record for audit trail
