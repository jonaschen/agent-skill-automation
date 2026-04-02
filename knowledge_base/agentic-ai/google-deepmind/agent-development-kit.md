# Agent Development Kit (ADK)

**Last updated**: 2026-04-02
**Sources**:
- https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/
- https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/
- https://developers.googleblog.com/adk-go-10-arrives/
- https://developers.googleblog.com/introducing-agent-development-kit-for-typescript-build-ai-agents-with-the-power-of-a-code-first-approach/
- https://github.com/google/adk-python
- https://google.github.io/adk-docs/

## Overview

Google's Agent Development Kit (ADK) is an open-source, code-first framework for building, evaluating, and deploying AI agents and multi-agent systems. Introduced at Google Cloud NEXT 2025, ADK is optimized for Gemini but is model-agnostic (supports Anthropic, Meta, Mistral via LiteLLM), deployment-agnostic, and compatible with other frameworks. It is now production-ready across Python (v1.0), Go (v1.0), Java (v1.0), and TypeScript.

## Key Developments (reverse chronological)

### 2025-12 -- ADK for TypeScript Released
- **What**: Official TypeScript/JavaScript SDK launched, enabling Node.js developers to build agents with ADK. Supports Gemini 3 Pro/Flash, MCP Toolbox for Databases integration, and full multi-agent patterns.
- **Significance**: Expands ADK reach to the largest developer ecosystem (JavaScript/TypeScript). Completes the major language coverage.
- **Source**: https://developers.googleblog.com/introducing-agent-development-kit-for-typescript-build-ai-agents-with-the-power-of-a-code-first-approach/

### 2025-11 -- ADK Go 1.0.0 Released
- **What**: Production-grade Go release with native OpenTelemetry tracing, self-healing plugins, Human-in-the-Loop (RequireConfirmation) for sensitive operations, A2A cross-language agent communication (Go/Java/Python), and YAML agent configuration support.
- **Significance**: OpenTelemetry integration makes ADK Go the first language SDK with native observability. Human-in-the-Loop support aligns with SAIF (Safe AI Framework) guidelines.
- **Source**: https://developers.googleblog.com/adk-go-10-arrives/

### 2025-05-20 -- ADK Python v1.0.0 at Google I/O
- **What**: Python SDK reached v1.0 stable release, signifying production readiness. Java ADK v0.1.0 also launched. New Agent Engine UI in Google Cloud console for managing deployed agents. Early adopters include Renault Group, Box, and Revionics.
- **Significance**: v1.0 milestone signals enterprise-ready stability. Agent Engine UI streamlines the lifecycle from development to production monitoring.
- **Source**: https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/

### 2025-04 -- ADK Introduced at Cloud NEXT
- **What**: ADK launched as an open-source framework for end-to-end agent development, supporting multi-agent systems with hierarchical delegation and workflow orchestration.
- **Significance**: Google's answer to the growing demand for structured agent development frameworks, competing with LangChain/LangGraph, CrewAI, and Anthropic's Agent SDK.
- **Source**: https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/

## Technical Details

### Architecture: Four Pillars

1. **Build**: Define agents with instructions, tools, and sub-agents
2. **Interact**: CLI, Web UI, API Server, or Python API interfaces
3. **Evaluate**: Systematic testing with `AgentEvaluator.evaluate()` against predefined datasets
4. **Deploy**: Container packaging, Vertex AI Agent Engine, or any runtime

### Agent Types

- **LlmAgent**: Primary agent type -- processes instructions, manages tools, handles LLM interactions
- **Workflow Agents**: Orchestration patterns:
  - `Sequential`: Step-by-step pipeline execution
  - `Parallel`: Concurrent task execution
  - `Loop`: Iterative processing until condition met
- **Sub-agents**: Hierarchical delegation via description-driven LLM routing

### Tool Ecosystem

- Pre-built tools (Google Search, Code Execution)
- **MCP tools**: Native Model Context Protocol support
- Third-party library integration (LangChain tools, LlamaIndex)
- Agent-as-tool patterns (interop with LangGraph, CrewAI agents)
- Custom Python function tools (docstring-based intent detection)

### Model Support (via LiteLLM)

- Google Gemini (primary)
- Anthropic Claude
- Meta Llama
- Mistral AI
- AI21 Labs
- Any model via Vertex AI Model Garden

### Multi-Agent Patterns

- **Hierarchical delegation**: Root agent routes to specialized sub-agents based on capability descriptions (LLM-driven routing)
- **Workflow orchestration**: Predictable pipelines (sequential/parallel) or dynamic routing (LLM-driven transfers)
- **A2A interop**: Cross-language agent communication via A2A protocol

### Key Features

| Feature | Details |
|---------|---------|
| Streaming | Bidirectional audio/video for multimodal interactions |
| State Management | Built-in agent state and tool orchestration |
| Observability | Native OpenTelemetry in Go; tracing/debugging in all SDKs |
| Human-in-the-Loop | RequireConfirmation for sensitive operations (Go) |
| YAML Config | Define agents via YAML without boilerplate code (Go) |

### Language SDK Status

| Language | Version | Status |
|----------|---------|--------|
| Python | 1.0.0 | GA, production-ready |
| Go | 1.0.0 | GA, production-ready |
| Java | 1.0.0 | GA |
| TypeScript | 1.0+ | GA |

## Comparison Notes

**vs Anthropic Agent SDK**:
- ADK is more opinionated with built-in workflow patterns (Sequential, Parallel, Loop); Anthropic Agent SDK is more minimal/flexible
- ADK supports 4 languages (Python, Go, Java, TypeScript); Anthropic Agent SDK currently Python-focused
- Both support MCP natively
- ADK has native A2A support; Anthropic Agent SDK does not have an equivalent inter-agent protocol
- ADK is model-agnostic via LiteLLM (can use Claude); Anthropic SDK is Claude-only
- ADK includes built-in evaluation framework; Anthropic relies on external eval tools
- ADK's Vertex AI Agent Engine provides managed deployment; Anthropic lacks equivalent managed hosting
- ADK has visual Web UI for development; Anthropic Agent SDK is CLI/code-only
