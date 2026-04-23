# OTEL Tracing Prototype (Multi-Agent)

**Date**: 2026-04-23
**Status**: DRAFT (P1 Strategic Research)

## Objective
Demonstrate distributed tracing across multiple agent sessions using the `claude-agent-sdk[otel]` integration. This provides observability into "Lead-to-Subagent" call chains, latency attribution, and token consumption spans.

## Prototype Implementation

### 1. Requirements
```bash
pip install claude-agent-sdk[otel] opentelemetry-exporter-otlp
```

### 2. Multi-Agent Lead Script (`otel_lead.py`)
This script acts as the "Lead" which spawns a "Researcher" sub-session.

```python
import os
from claude_agent_sdk import Agent, Session
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter

# 1. Setup OTEL SDK
provider = TracerProvider()
processor = BatchSpanProcessor(ConsoleSpanExporter()) # Outputs to stdout for prototype
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

async def run_multi_agent_research():
    with tracer.start_as_current_span("research-lead-workflow") as parent_span:
        # 2. Initialize Lead Session
        async with Session(agent=Agent("agentic-ai-research-lead")) as lead_session:
            parent_span.set_attribute("session.id", lead_session.id)
            
            # 3. Spawn Researcher Sub-session (automatically inherits trace context)
            print(f"[Lead] Delegating to Researcher...")
            async with lead_session.subagent("agentic-ai-researcher") as researcher:
                # This call creates a child span in the OTEL trace
                result = await researcher.run("Research the latest OTEL standards for agents.")
                
            print(f"[Lead] Received result. Synthesizing...")
            await lead_session.run(f"Summarize this research: {result}")

if __name__ == "__main__":
    import asyncio
    asyncio.run(run_multi_agent_research())
```

## Trace Structure Expectation

The ConsoleSpanExporter will output a tree-like structure:

1.  **Span: `research-lead-workflow`** (Root)
    - Attributes: `session.id`, `initiator=cron`
    - **Span: `subagent-call`** (Child)
        - Attributes: `subagent.name=agentic-ai-researcher`
        - **Span: `claude-api-call`** (Child of Subagent)
            - Attributes: `model=claude-opus-4-7`, `tokens.input=450`, `tokens.output=1200`
    - **Span: `claude-api-call`** (Child of Root)
        - Attributes: `model=claude-sonnet-4-6`, `tokens.input=1500`, `tokens.output=300`

## Strategic Alignment (S2)
This prototype addresses **S2 (Multi-Agent Orchestration)** by providing the mandatory foundation for:
- **Latency Attribution**: Identifying which subagent is causing the bottleneck.
- **Cost Tracking**: Summing tokens across the entire span tree for a single high-level task.
- **Error Propagation**: Seeing exactly where in a nested chain a tool call failed.

## Next Steps
- Implement in `scripts/lib/otel_logger.py` for use in all Phase 5 scripts.
- Evaluate `OTEL_EXPORTER_OTLP_ENDPOINT` for aggregation in a central Jaeger/Tempo instance.
