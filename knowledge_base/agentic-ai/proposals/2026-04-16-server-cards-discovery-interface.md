# Architecture Proposal: Phase 5 Router Discovery Interface Abstraction
**Date**: 2026-04-16
**Triggered by**: MCP 2026 roadmap Priority 1 (Transport Evolution) — Server Cards (.well-known agent capability metadata) positioned as future of service discovery. No implementation timeline; Transports WG scope.
**Priority**: P2 (medium)
**Target Phase**: Phase 5 (topology-aware-router design)

## Rationale

MCP Server Cards (structured `.well-known` metadata URLs for agent capability auto-discovery) are in
the Transports Working Group scope but have no published spec draft or implementation timeline. The
analysis recommends documenting a forward-compatibility hook rather than implementing anything.

Discussion Round 3 resolved the mechanism:
- **Innovator's proposal**: Create `agents_registry.json` as a second canonical source mirroring Server Cards schema
- **Engineer's rejection**: Creates a second source of truth that diverges from `.md` files; maintenance tax for zero current benefit
- **Adopted resolution**: Keep `.md` files as single canonical source; make Phase 5 router's **discovery layer** an explicit abstraction boundary

**Key insight from Engineer**: "Keep `.md` files as the canonical source, but make Phase 5 router
configuration *plug-in based* at the discovery layer only. The router core reads from `.md` files
(current), but the discovery interface is abstract. When Server Cards exist, replace the implementation
behind that interface — the router logic doesn't change, the discovery mechanism does."

## Proposed Design Note for Phase 5

Add to Phase 5 architecture documentation:

```markdown
### 5.x Discovery Interface Abstraction

The Phase 5 topology-aware-router MUST separate the agent discovery mechanism from the
routing logic. This is the **single forward-compatibility hook** for MCP Server Cards.

**Current implementation** (Phase 5 baseline):
- Agent discovery reads from `.claude/agents/*.md` frontmatter (name, description, tools, model)
- `.md` files remain the single canonical source of truth for agent capabilities
- No second registry file is created

**Abstraction boundary**:
The router exposes an `AgentDiscovery` interface with a single method:
```
list_agents() → List[AgentCapabilities]
```
where `AgentCapabilities = {name, description, tools, model, health_endpoint (optional)}`

**Phase 5 implementation** reads from `.md` files behind this interface.

**Server Cards upgrade path** (when Transports WG publishes spec):
Replace the `list_agents()` implementation with a `.well-known` query — zero changes to
routing logic. The router doesn't know or care how agents are discovered.

**When to trigger upgrade**:
- Transports WG publishes Server Cards working draft
- Our agent fleet grows beyond 20 agents (manual `.md` maintenance becomes error-prone)
- Cross-repo agent discovery becomes a Phase 5+ requirement (e.g., discovering android-sw-steward
  from this repo's router)

**Do NOT create** `agents_registry.json` or any secondary capability manifest until:
1. Server Cards spec is published AND
2. We have concrete cross-repo discovery requirements
```

## Implementation Notes

- This is a Phase 5 design documentation change — no code today
- The `AgentDiscovery` interface can be expressed as a Python abstract base class or just a
  documented function contract; the exact mechanism depends on Phase 5's language choice
- The `.md` files stay canonical — this doesn't change Phase 1-4 infrastructure at all
- If Phase 5 is implemented in Python (likely, given our eval infrastructure), the interface is
  trivially expressible as a class with a single method

## Estimated Impact

- Zero cost today (documentation only)
- Prevents Phase 5 router from being architecturally coupled to static `.md` parsing
- When Server Cards are published, upgrade is isolated to one class/function rather than refactoring
  router core logic
- Preserves `.md` files as single canonical source — no divergence risk
- Estimated design documentation: 30 minutes in Phase 5 planning session
