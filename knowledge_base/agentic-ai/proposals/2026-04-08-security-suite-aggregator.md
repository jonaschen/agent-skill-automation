# Skill Proposal: Security Suite Aggregator
**Date**: 2026-04-08
**Triggered by**: Google CodeMender multi-agent security pattern (72 upstream fixes) + our growing 7-script security stack
**Priority**: P1 (high)
**Target Phase**: Phase 4 (Security hardening)

## Rationale

Our security stack has grown to 7+ discrete scripts (`check-permissions.sh`, `mcp_config_validator.sh`, `cmd_chain_monitor.sh`, `cost_ceiling.sh`, MCP depth monitor in `post-tool-use.sh`, dependency audit in `pre-deploy.sh`, content scanning). Each outputs in a different format. The pre-deploy gate calls them individually. A unified aggregator script produces a single structured JSON report, making security check results machine-parseable for the reviewer agent.

The discussion REJECTED a full security orchestrator agent (premature — 7 scripts don't need LLM orchestration). The aggregator script provides 90% of the orchestration benefit at 10% of the cost.

## Proposed Specification
- **Name**: security-suite-aggregator
- **Type**: Script (new tooling)
- **Description**: Unified security check runner with structured JSON output
- **Key Capabilities**:
  - `eval/security_suite.sh` — runs all security checks in sequence
  - Outputs versioned JSON report with per-check pass/fail/warn status
  - Wired into `pre-deploy.sh` as a single call replacing individual script invocations
  - Machine-parseable for reviewer agent consumption
- **Tools Required**: Bash

## Implementation Notes

Output format:
```json
{
  "version": 1,
  "timestamp": "2026-04-08T12:00:00Z",
  "checks": [
    {"name": "permissions", "script": "check-permissions.sh", "status": "pass"},
    {"name": "mcp_config", "script": "mcp_config_validator.sh", "status": "pass"},
    {"name": "dependencies", "script": "npm audit", "status": "warn", "details": "..."}
  ],
  "overall": "pass",
  "duration_seconds": 12.4
}
```

The `version` field enables schema evolution without breaking consumers.

Estimated effort: 2 hours (script + pre-deploy.sh rewiring).

## Estimated Impact

Simplifies pre-deploy gate, enables structured security reporting, and provides a foundation for the Phase 5 security orchestrator agent (DEFERRED). The reviewer agent can parse a single JSON instead of 7 different output formats.
