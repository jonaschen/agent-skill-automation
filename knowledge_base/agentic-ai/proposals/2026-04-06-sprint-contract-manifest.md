# Skill Proposal: Sprint Contract — Factory-Validator Manifest
**Date**: 2026-04-06
**Triggered by**: Anthropic three-agent harness blog (sprint contract pattern); analysis §1.2; discussion ADOPT #5
**Priority**: P2 (medium)
**Target Phase**: 4 (Closed Loop)

## Rationale

Anthropic's three-agent harness blog reveals that self-evaluation bias is the critical failure mode in multi-agent systems — agents confidently praise their own work. Our pipeline correctly separates generation (`meta-agent-factory`) from evaluation (`skill-quality-validator`).

However, we lack a **pre-evaluation contract**. The factory generates blindly, and the validator evaluates against fixed criteria. This causes false failures when the factory's intent doesn't match the validator's expectations (e.g., a review-only Skill being penalized for lacking Write permissions).

The Engineer consensus is a **simplified version**: manifest with `permission_model` and `target_domain` only (not trigger counts or negative patterns — those are the validator's job).

## Proposed Specification
- **Name**: sprint-contract-manifest (protocol between factory and validator)
- **Type**: Pipeline improvement (inter-agent protocol)
- **Description**: Factory outputs a lightweight manifest alongside generated SKILL.md; validator consumes it for structural checks
- **Key Capabilities**:
  - Factory generates `manifest.json` alongside SKILL.md:
    ```json
    {
      "permission_model": "review-only",
      "target_domain": "security-auditing",
      "mcp_servers": []
    }
    ```
  - Validator reads manifest for structural validation:
    - `permission_model: "review-only"` → verify Write/Edit/Bash absent
    - `permission_model: "execution"` → verify Task absent
    - `target_domain` → log for correlation with trigger results
    - `mcp_servers` → validate against MCP allowlist
  - Manifest is a build artifact, discarded after validation (not deployed)
  - Fixed eval framework (Bayesian scoring, T/V split) unchanged — manifest only affects structural checks
- **Tools Required**: N/A (agent definition updates only)

## Implementation Notes
- Files to change: `.claude/agents/meta-agent-factory.md` (add manifest generation), `.claude/agents/skill-quality-validator.md` (add manifest consumption)
- REJECTED alternative: dynamic test generation from manifests — breaks fixed-test-set assumption underlying entire measurement architecture
- REJECTED fields: `expected_trigger_count` and `expected_negative_patterns` — these are the validator's responsibility
- Low risk: the manifest is additive; if the factory fails to generate it, the validator falls back to current fixed-criteria behavior

## Estimated Impact
- Reduces false failures from mismatched factory-validator expectations
- Establishes inter-agent protocol pattern reusable for Phase 5 multi-agent orchestration
- 80% of the benefit of full sprint contracts at 20% of the complexity
