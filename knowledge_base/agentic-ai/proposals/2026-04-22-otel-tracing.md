# Technical Proposal: OTEL Tracing for Multi-Agent Topology

**Date**: 2026-04-22
**Triggered by**: Agent SDK v0.1.60 OTEL support
**Priority**: P1 (Strategic)
**Target Phase**: Phase 5 (Orchestration)

## Rationale
As we move to Phase 5 (Scrum orchestration, TCI routing), we will have multiple agents (Lead, Researcher, Validator, Factory) working on a single task. Without distributed tracing, it is impossible to:
1. Identify the root cause of a failure in a deeply nested subagent call.
2. Measure latency bottlenecks across the agent fleet.
3. Visualize the "thought graph" of the multi-agent team.

## Proposed Specification
Use OpenTelemetry (OTEL) with the `claude-agent-sdk[otel]` package to propagate trace context across the fleet.

### Code Example (Conceptual)

```python
# lead_agent.py
from claude_agent_sdk import query, ClaudeAgentOptions
from opentelemetry import trace

tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("parent-research-task") as span:
    async for msg in query(
        prompt="Synthesize research for topic X",
        options=ClaudeAgentOptions(
            agents={
                "researcher": AgentDefinition(
                    description="Expert researcher",
                    # Context propagation is handled automatically by SDK [otel]
                )
            }
        )
    ):
        pass
```

### Trace Propagation Pattern
- **Lead Agent** starts the `Root Span`.
- **Subagent (SDK)** starts a `Child Span`.
- **CLI Subprocess** (called by SDK) starts a `Sub-child Span` via `TRACEPARENT`.
- **Collector**: Spans are exported to a local Tempo or Jaeger instance for visualization.

## Implementation Notes
- Requires `pip install opentelemetry-api opentelemetry-sdk`.
- We will need a `docker-compose.yml` for a local OTEL collector in Phase 5.

## Estimated Impact
Provides 100% observability into the "internal reasoning" of the multi-agent swarm. Enables "Phase 5 Observability" goal.
