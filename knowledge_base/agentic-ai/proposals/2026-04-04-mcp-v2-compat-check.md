# Skill Proposal: mcp-compat-validator
**Date**: 2026-04-04
**Triggered by**: MCP Python SDK frozen at v1.26.0 for 63 days while V2 is developed; V2 may break `mcp.server.auth` semantics
**Priority**: P1 (high)
**Target Phase**: Phase 4 (CI/CD Gate enhancement)

## Rationale

Our `meta-agent-factory` generates `.mcp.json` configs as part of Skill creation. The MCP SDK V2 rewrite is underway and may introduce breaking changes to auth semantics. If V2 drops and our generated configs become invalid, we won't detect it until a deployed Skill fails in production. This is a gap in our CI/CD gate — we validate SKILL.md format and trigger rates but not MCP config compatibility.

The 63-day freeze on the Python SDK is the longest gap in MCP SDK history, confirming a major rewrite is in progress. The risk is time-bounded: V2 will ship, and when it does, we need automated detection.

## Proposed Specification

- **Name**: mcp-compat-validator
- **Type**: Enhancement to existing `agentic-cicd-gate` agent (not a new Skill)
- **Description**: Add an MCP config validation step to the CI/CD gate that checks `.mcp.json` files against the installed MCP SDK version's schema
- **Key Capabilities**:
  - Parse `.mcp.json` and validate against MCP SDK schema
  - Detect deprecated auth patterns (`mcp.server.auth` v1 vs v2)
  - Pin MCP SDK version in pipeline requirements
  - Alert on MCP SDK version mismatch between generation and deployment
- **Tools Required**: Bash (for SDK version detection), Read, Grep

## Implementation Notes

- Add to `agentic-cicd-gate.md` as an additional validation step, not a separate agent
- Add `mcp` version pin to any requirements/package files in the pipeline
- Create a test fixture with known-good v1 and v2 MCP configs for regression
- Monitor MCP GitHub releases (https://github.com/modelcontextprotocol/python-sdk/releases) in researcher sweeps

## Estimated Impact

- Prevents silent deployment failures when MCP V2 ships
- Adds ~5s to CI/CD gate execution (negligible)
- Closes the last uncovered config validation gap in the deployment pipeline
