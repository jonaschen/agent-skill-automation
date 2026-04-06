# Deferred Proposals — 2026-04-07
**Date**: 2026-04-07
**Source**: Discussion 2026-04-07 DEFER verdicts
**Purpose**: Track deferred items with clear revisit triggers

---

## D1: CI/CD Gate MCP Call Pattern Rejection (P2)
**Original**: Discussion Round 1, Proposal 1.3
**Reason for deferral**: Runtime monitor (Proposal 1.1) provides immediate protection. Eval instrumentation for MCP calls is complex — requires either parsing Claude's verbose output (brittle, L10 taught us this) or coupling eval to hook infrastructure (option b preferred but non-trivial).
**Revisit when**: Proposals 1.1 (MCP depth monitor) and 1.2 (cost ceiling) are stable and producing baseline data.
**Target Phase**: 4
**Priority when revisited**: P1

## D2: `mcp-sec-audit` Integration (P2)
**Original**: Discussion Round 2, Proposal 2.1
**Reason for deferral**: Unknown installability (research prototype vs. stable CLI?), unknown marginal value over existing content scanner, dynamic analysis component poses security risk in CI/CD pipeline.
**Revisit when**: A standalone 2-4 hour evaluation confirms (a) installable as CLI tool, (b) catches vulnerabilities our regex scanner misses, (c) static-analysis mode available (no need to execute MCP servers).
**Target Phase**: 4
**Priority when revisited**: P1

## D3: Consolidated MCP Security Suite (P3)
**Original**: Discussion Round 2, Proposal 2.2
**Reason for deferral**: Premature abstraction. We have 2 MCP security components today. Consolidation earns its complexity cost after 4+ components exist. Refactoring now introduces coupling risk — a bug in the suite breaks ALL security checks simultaneously.
**Revisit when**: Proposals 1.1 (depth monitor) and D2 (mcp-sec-audit) are implemented, giving us 4+ MCP security components to consolidate.
**Target Phase**: 4
**Priority when revisited**: P2

## D4: Auto-Promotion for Skill Logger (P3)
**Original**: Discussion Round 2, Proposal 2.3
**Reason for deferral**: Insufficient usage data (<50 logged invocations since logger install). Embedding-based similarity is overengineered for v1. Simple verb+skill counting is the right first step but needs statistical significance.
**Revisit when**: >100 logged skill invocations exist AND Phase 4 is stable.
**Target Phase**: 5 (planning task, not implementation)
**Priority when revisited**: P2
**Design note**: Use simple skill-name + trigger-verb pair counting, not embeddings. Threshold: same skill triggered >5 times with same leading verb → promotion candidate.

## D5: MCP Tool Annotation Awareness (P3)
**Original**: Discussion Round 3, Proposal 3.2
**Reason for deferral**: Annotation spec at SEP stage (unstable). Zero servers implement `readOnlyHint`/`destructiveHint` today. Forward-compatible but would fire zero times on current inputs.
**Revisit when**: MCP SDK V2 drops (frozen 74 days at v1.26.0) or annotation adoption reaches >10% of surveyed servers.
**Target Phase**: 4
**Priority when revisited**: P2

---

## Rejected

### R1: Progressive Context Loading for Factory Agent
**Original**: Discussion Round 3, Proposal 3.3
**Reason**: Cost-benefit negative. Factory T=0.895 is adequate. The Google ADK 50% context reduction finding applies to interactive sessions, not single-shot generation. Risk of regression (L7) outweighs speculative improvement. Revisit only if factory quality degrades.
