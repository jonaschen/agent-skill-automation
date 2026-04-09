# Deferred Items — 2026-04-10

Items from today's discussion with clear rationale for deferral.

## D1: A2A-Native Bus Design (Phase 5.3)
**Priority**: P2 (deferred)
**Rationale**: A2A v1.1 expected at Google I/O (May 19-20). Designing on v1.0 risks rework. The design principle — "build A2A-native, not custom-then-migrate" — is recorded in ROADMAP update recommendations.
**Revisit**: Post-I/O (after May 20, 2026)

## D2: AgentCard-Based Dynamic Discovery
**Priority**: P3 (deferred)
**Rationale**: Fleet has 6 agents. Dynamic capability-based discovery (via A2A AgentCards) pays off at 20+ agents or when external agents join. Static routing table is sufficient at current scale.
**Revisit**: Phase 5 implementation, when multi-agent teams are active

## D3: Watchdog RSS Memory Monitoring
**Priority**: P2 (deferred)
**Rationale**: Phase 5.4 watchdog-circuit-breaker agent doesn't exist yet. Thresholds need real Phase 5 session data to calibrate. The requirement is: "RSS monitoring alongside token velocity as watchdog signals."
**Revisit**: Phase 5.4 design time, when the agent definition is being written

## D4: Enterprise Stack Pricing Comparison Framework
**Priority**: P2 (deferred)
**Rationale**: Managed Agents pricing ($0.08/session-hr) is now known; Google Agent Engine pricing for ADK v2.0 not yet public. Comparison impossible until both sides have published pricing.
**Revisit**: Post-I/O or when Google Agent Engine pricing is announced

## D5: EAGLE3 Speculative Decoding for Phase 6.4
**Priority**: P2 (deferred)
**Rationale**: Base inference path (Gemma 4 E2B at ~86.4% tool use) is sufficient. EAGLE3 provides optional 1.72x speedup recipe for latency-sensitive edge deployments. Not blocking for Phase 6 design.
**Revisit**: Phase 6.4 (model packaging pipeline) implementation time
