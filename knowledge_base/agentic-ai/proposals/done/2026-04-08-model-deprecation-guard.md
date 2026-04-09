# Skill Proposal: Model Deprecation Guard
**Date**: 2026-04-08
**Triggered by**: Four model deprecation deadlines converging within 95 days (Haiku 3: Apr 19, Sonnet 3.7: May 11, Haiku 3.5: Jul 5, 1M context beta: Apr 30)
**Priority**: P1 (high)
**Target Phase**: Phase 4 (Security hardening / pre-deploy gate)

## Rationale

While our agents use Opus 4.6 and Sonnet 4.6 (no direct dependency on retiring models), we have no automated check that agent configurations don't reference deprecated model IDs. The existing `eval/model_migration_runbook.md` covers re-baseline procedures but hasn't been tested against a real deprecation event. Steward agents for external projects may reference legacy models in their target repos.

## Proposed Specification
- **Name**: model-deprecation-guard
- **Type**: Script + data file (new tooling)
- **Description**: Automated pre-deploy check that alerts when any agent configuration references a model with a known retirement date within 30 days
- **Key Capabilities**:
  - `eval/model_deprecation_check.sh` — greps all agent definitions and eval configs for known deprecated model IDs
  - `eval/deprecated_models.json` — append-only JSON file with model IDs and confirmed retirement dates
  - Fails the pre-deploy gate if any referenced model retires within 30 days
  - Researcher agent auto-updates the JSON file during nightly sweeps (see ADOPT #7)
- **Tools Required**: Bash, Grep

## Implementation Notes

JSON schema (append-only, researcher-maintained):
```json
[
  {"model_id": "claude-3-haiku-20240307", "retirement_date": "2026-04-19", "replacement": "claude-haiku-4-5", "source": "anthropic.com/docs/deprecations"},
  {"model_id": "claude-3.7-sonnet", "retirement_date": "2026-05-11", "replacement": "claude-sonnet-4-6", "source": "anthropic.com/docs/deprecations"}
]
```

Search paths: `.claude/agents/*.md`, `scripts/daily_*.sh`, `eval/*.py`, `eval/*.sh`.
Discussion agreed: JSON file updated by researcher (confirmed sources only), not hardcoded in script.

Estimated effort: 2 hours (script + JSON + pre-deploy wiring).

## Estimated Impact

Prevents silent breakage when deprecated models are retired. Automated via researcher sweep → zero ongoing human maintenance. Low effort, high safety value.
