# Skill Proposal: MCP Tool Description Content Validator
**Date**: 2026-04-05
**Triggered by**: Invariant Labs MCP tool poisoning attack (sweep 2026-04-05); discussion ADOPT #1
**Priority**: P0 (critical)
**Target Phase**: 4 (Security Hardening)

## Rationale

MCP tool poisoning is the first demonstrated attack vector targeting MCP. Malicious tool descriptions inject hidden instructions into the LLM's context, enabling data exfiltration or unintended actions. Our `mcp_config_validator.sh` (2026-04-04) validates JSON structure but NOT tool description content. A valid-looking `.mcp.json` pointing to a malicious server passes our gate.

This is P0 because:
- Our `meta-agent-factory` generates `.mcp.json` configs that could reference untrusted servers
- Our 6 nightly steward agents run with significant trust — if MCP is added, poisoning is a lateral movement vector
- The attack is publicly documented and reproducible

## Proposed Specification
- **Name**: mcp-content-validator (extension of existing `eval/mcp_config_validator.sh`)
- **Type**: CI/CD gate extension (not a standalone Skill)
- **Description**: Static content scanning of MCP tool descriptions in `.mcp.json` files for injection patterns
- **Key Capabilities**:
  - Regex scan for instruction injection phrases: `"ignore previous"`, `"you must"`, `"do not tell"`, `"send to"` + URL patterns
  - Flag descriptions exceeding 500 characters
  - Reject descriptions containing credential keywords (`password`, `token`, `secret`, `API_KEY`)
  - Allowlist bypass: servers in `eval/mcp_server_allowlist.json` skip content scanning
  - Allowlist check runs BEFORE content scanning (per Engineer feedback — avoids false positives on vault-type servers)
- **Tools Required**: Bash (script extension)

## Implementation Notes
- Extend existing `eval/mcp_config_validator.sh` — no new file needed
- Create `eval/mcp_server_allowlist.json` with known-good servers (modelcontextprotocol.io registry, Anthropic official servers)
- Static scanning only — do NOT fetch from live MCP servers (adds network failure mode to CI/CD gate). Dynamic fetching deferred to Phase 5.
- Wire into `closed_loop.sh` SECURITY_SCAN node (see proposal 2026-04-05-closed-loop-state-machine.md)

## Estimated Impact
- Blocks the primary demonstrated MCP attack vector before any poisoned Skill reaches deployment
- Low implementation cost (regex patterns in existing bash script)
- Establishes allowlist pattern that scales to Phase 5+ MCP hardening
