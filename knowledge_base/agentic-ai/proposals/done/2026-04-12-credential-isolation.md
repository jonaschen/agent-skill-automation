# Skill Proposal: Credential Isolation Design Document

**Date**: 2026-04-12
**Triggered by**: Managed Agents vault-based MCP proxy and resource-bundled auth patterns (sweep 2026-04-12); analysis Section 1.3
**Priority**: P2 (medium — design doc only, no implementation until Phase 5)
**Target Phase**: Phase 5.3 (Security Requirements Input)

## Rationale

Our entire agent fleet runs with Jonas's full environment variables — `ANTHROPIC_API_KEY`,
`GITHUB_TOKEN`, and any other secrets are accessible to every agent session. Managed Agents
demonstrates two isolation patterns:
1. **Resource-bundled auth**: credentials initialize resources during setup, then sandbox
   operates without direct credential access
2. **Vault-based MCP proxy**: OAuth tokens in secure vaults, accessed only via proxy servers

Current threat model (single-user, single-machine) makes this low urgency. But Phase 5
(multi-agent with generated skill testing) and Phase 7 (multi-tenant AaaS) require
credential isolation as a first-class requirement. Writing the design document now while
the Managed Agents architecture is fresh captures the reference patterns.

## Proposed Specification

- **Name**: credential-isolation-design (design document, not a Skill)
- **Type**: Design document
- **Output**: `knowledge_base/agentic-ai/evaluations/credential-isolation-design.md`
- **Contents**:
  1. Current credential surface mapping: which env vars each agent actually needs
  2. Credential flow diagram: `crontab → bash script → env vars → Claude session → tool calls`
  3. Isolation boundary candidates at each hop
  4. Managed Agents reference patterns (resource-bundled auth, vault-based proxy)
  5. Agent SDK `exclude_dynamic_sections` implications for credential references in system prompts
  6. Minimal isolation model for Phase 5: per-agent env var subsets
  7. Full isolation model for Phase 7: MCP proxy for shared credentials

## Implementation Notes

- Pure design document — no code changes
- Include the concrete env var audit: most agents need only `ANTHROPIC_API_KEY`; some need
  `GITHUB_TOKEN` for steering notes; none currently need cloud provider credentials
- Reference CVE-2026-35020 and `permissions.deny` override fix as examples of env var attack surface
- Estimated effort: 1-2 hours (documentation only)

## Estimated Impact

- **Phase 5 readiness**: Security requirements documented before implementation begins
- **Knowledge capture**: Managed Agents patterns recorded while fresh
- **Risk reduction**: Design-time thinking about credential isolation prevents bolt-on security later
