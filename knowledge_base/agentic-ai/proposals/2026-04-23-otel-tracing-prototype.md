# Prototype: Multi-Agent OTEL Tracing with Claude Agent SDK

**Date**: 2026-04-23
**Status**: Draft
**Topic**: S2 (Multi-Agent Orchestration) / Observability
**Reference**: [2026-04-22-directive.md](../directives/2026-04-22-directive.md)

## 1. Overview
This prototype demonstrates how to implement distributed tracing across a multi-agent system using the Claude Agent SDK's native OpenTelemetry (OTEL) support. By leveraging `claude-agent-sdk[otel]`, we can visualize the relationship between a "Lead Agent" and its "Researcher" sub-agents as a nested trace waterfall.

## 2. Implementation Script (`otel_multi_agent_prototype.py`)

```python
import asyncio
import os
from typing import List
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor, ConsoleSpanExporter
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.claude_agent_sdk import ClaudeAgentSdkInstrumentor
from claude_agent_sdk import query, ClaudeAgentOptions

# 1. Setup OTEL Provider
resource = Resource.create({"service.name": "agent-skill-pipeline"})
provider = TracerProvider(resource=resource)
# Console exporter for prototype verification
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# 2. Instrument the SDK
instrumentor = ClaudeAgentSdkInstrumentor()
instrumentor.instrument(tracer_provider=provider)

tracer = trace.get_tracer(__name__)

async def run_agent(name: str, prompt: str, model: str = "claude-3-5-sonnet-20241022"):
    """Execution wrapper with automatic span nesting."""
    print(f"[{name}] Starting...")
    async for message in query(
        prompt=prompt,
        options=ClaudeAgentOptions(model=model)
    ):
        pass # Handle tool calls/messages
    print(f"[{name}] Completed.")

async def main():
    # 3. Root Span: Multi-Agent Session
    with tracer.start_as_current_span("skill-optimization-run") as root_span:
        root_span.set_attribute("pipeline.phase", "Phase 4 - Closed Loop")
        
        # Phase A: Lead Agent (Orchestration)
        with tracer.start_as_current_span("lead-orchestrator-phase"):
            print("Lead: Analyzing skill gaps...")
            await run_agent("Lead", "Analyze the trigger failures in meta-agent-factory.md and propose a research plan.")

        # Phase B: Researcher Agent (Parallel Investigation)
        with tracer.start_as_current_span("researcher-sub-session") as sub_span:
            sub_span.set_attribute("agent.role", "specialist-researcher")
            print("Researcher: Investigating platform changes...")
            await run_agent("Researcher", "Find the latest benchmarks for Claude Opus 4.7 literal instruction following.")

if __name__ == "__main__":
    # Ensure ANTHROPIC_API_KEY is set
    asyncio.run(main())
```

## 3. Trace Topology
When executed, the OTEL collector (or console) will show a trace hierarchy:
- `skill-optimization-run` (Root)
    - `lead-orchestrator-phase` (Span)
        - `invoke_agent` (SDK Internal Span)
            - `execute_tool: Bash` (SDK Internal Span)
    - `researcher-sub-session` (Span)
        - `invoke_agent` (SDK Internal Span)
            - `execute_tool: WebSearch` (SDK Internal Span)

## 4. Key Takeaways for Phase 5
1.  **Context Propagation**: By using `tracer.start_as_current_span()`, the `query()` function automatically detects the active span and attaches its internal operations as children. No manual ID passing is required.
2.  **Observability Parity**: This allows us to measure "Orchestration Overhead" vs "Execution Time" by comparing the duration of the parent spans against the `invoke_agent` child spans.
3.  **Cost Attribution**: Spans include token usage metadata (`gen_ai.usage.input_tokens`), allowing us to calculate the exact cost of a multi-agent sub-workflow.

## 5. Next Steps
- [ ] Integrate `OTLPSpanExporter` to send traces to the pipeline's Honeycomb/Jaeger instance.
- [ ] Add `trace_id` to the `performance.json` output for cross-referencing logs with traces.
