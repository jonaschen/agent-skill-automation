# Skill Proposal: MCP-Scan Hash-Based Tool Pinning
**Date**: 2026-04-06
**Triggered by**: OWASP MCP Top 10 (84.2% attack success rate); analysis §1.1 rug pull variant 3; discussion ADOPT #2
**Priority**: P1 (high)
**Target Phase**: 4 (Security Hardening)

## Rationale

Our `eval/mcp_config_validator.sh` (shipped 2026-04-05) performs static content scanning — injection phrase detection, length limits, credential keyword rejection. This addresses ~30% of the OWASP MCP Top 10 attack surface, primarily MCP03 (tool poisoning) at validation time.

However, it cannot detect **rug pulls** (variant 3): MCP servers that alter tool definitions after initial approval. The `mcp-scan` tool (`uvx mcp-scan@latest`) solves this with hash-based pinning — it computes SHA-256 hashes of tool definitions and detects when they change.

This is a low-effort, high-impact addition that closes the rug pull vector without architectural changes.

## Proposed Specification
- **Name**: mcp-hash-pinning (extension of existing `mcp_config_validator.sh`)
- **Type**: Pipeline improvement (CI/CD gate enhancement)
- **Description**: Hash-based MCP tool definition pinning for rug pull detection
- **Key Capabilities**:
  - Compatibility spike: test `mcp-scan` against our `.mcp.json` format
  - If compatible: integrate `mcp-scan` into `mcp_config_validator.sh`
  - If incompatible: implement SHA-256 hash computation via `jq` + `sha256sum` (10 lines)
  - On first validation: store tool definition hashes in `eval/mcp_tool_hashes/<skill-name>.json`
  - On subsequent validations: compare current hashes against stored baseline
  - Hash mismatch → flag as rug pull attempt → block deployment
  - Sidecar hash file committed alongside SKILL.md as part of security manifest
- **Tools Required**: Bash

## Implementation Notes
- Gate on a 15-minute compatibility spike before committing to `mcp-scan` vs. native implementation
- The sidecar hash file is version-controlled, auditable, and adds no runtime infrastructure
- Blast radius is small: only affects Skills that use MCP servers; additive gate (doesn't change existing validation)
- Files to change: `eval/mcp_config_validator.sh` (add hash validation function), new directory `eval/mcp_tool_hashes/`

## Estimated Impact
- Closes the rug pull attack vector (OWASP MCP03 variant 3) — currently unmitigated
- Moves our OWASP MCP Top 10 coverage from ~30% to ~40%
- Positions us for Phase 7 enterprise security claims ("hash-pinned MCP tool verification")
- Zero runtime overhead — validation-time only
