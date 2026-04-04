# Agent Development Kit (ADK)

**Last updated**: 2026-04-05
**Sources**:
- https://developers.googleblog.com/en/agent-development-kit-easy-to-build-multi-agent-applications/
- https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/
- https://developers.googleblog.com/adk-go-10-arrives/
- https://developers.googleblog.com/introducing-agent-development-kit-for-typescript-build-ai-agents-with-the-power-of-a-code-first-approach/
- https://github.com/google/adk-python
- https://adk.dev/ (formerly google.github.io/adk-docs, redirected)
- https://developers.googleblog.com/building-agents-with-the-adk-and-the-new-interactions-api/
- https://developers.googleblog.com/announcing-adk-for-java-100-building-the-future-of-ai-agents-in-java/
- https://adk.dev/release-notes/
- https://github.com/google/adk-python/releases
- https://developers.googleblog.com/developers-guide-to-ai-agent-protocols/

## Overview

Google's Agent Development Kit (ADK) is an open-source, code-first framework for building, evaluating, and deploying AI agents and multi-agent systems. Introduced at Google Cloud NEXT 2025, ADK is optimized for Gemini but is model-agnostic (supports Anthropic, Meta, Mistral via LiteLLM), deployment-agnostic, and compatible with other frameworks. It is now production-ready across Python (v1.0), Go (v1.0), Java (v1.0), and TypeScript.

## Key Developments (reverse chronological)

### 2026-04-05 -- ADK Python Release Cadence Deep Dive: v1.27.0–v1.28.1 Security Hardening & A2A Maturity
- **What**: Detailed release cadence analysis from March–April 2026 reveals rapid iteration: (1) **v1.27.0** (Mar 12) — A2A request interceptors and auth provider registry, streaming support for Anthropic models, enhanced skill toolset with GCS filesystem and bash tool support. (2) **v1.27.1** (Mar 13) — rollback of telemetry changes affecting LlmAgent creation. (3) **v1.27.2** (Mar 17) — BigQuery OAuth scope fix for Dataplex, improved Vertex AI usage metadata. (4) **v1.27.3** (Mar 23) — **security: protection against arbitrary module imports**. (5) **v1.27.4** (Mar 24) — **excluded compromised LiteLLM versions**, gated builder endpoints behind web flag. (6) **v1.27.5** (Mar 26) — constrained LiteLLM to v1.82.6. (7) **v1.28.0** (Mar 26) — major feature release: A2A lifespan parameter support, new A2A integration extension, **Spanner Admin Toolset**, **Slack integration**, database role properties for fine-grained access, BigQuery migration with OAuth scope fixes, MultiTurn Task metrics, SSE streaming support. (8) **v2.0.0-alpha.1** (Mar 18) — **workflow runtime with graph-based execution**, **Task API for structured agent-to-agent delegation**. (9) **v2.0.0-alpha.2** (Mar 27) — GKE deployment defaults to ClusterIP, file extension enforcement for builder API GET requests.
- **Significance**: The v1.27.3–v1.27.5 cluster is a **security incident response** — three rapid patches in 4 days addressing the LiteLLM supply chain compromise (compromised versions excluded, dependency pinned). This is the first publicly visible supply chain security incident affecting the ADK ecosystem. v1.28.0's Slack integration and Spanner Admin Toolset signal ADK expanding into enterprise workflow automation beyond pure AI agent scenarios. v2.0.0-alpha.1's "workflow runtime with graph-based execution" previews a potential convergence with Vercel's Workflow DevKit concept — graph-based durable agent execution. The **Task API** in v2.0 alpha suggests ADK is building a native task delegation system complementary to A2A.
- **Source**: https://github.com/google/adk-python/releases

### 2026-04-04 -- ADK Python v2.0.0 Alpha & v1.28.1 Stable; Gemini CLI Emerges as Complementary Agent Tool
- **What**: Several significant ADK developments: (1) **ADK Python v2.0.0a2** (Mar 27, 2026) — first alpha of the next major version. Security-focused release with agent name validation to prevent arbitrary module imports, enforcement of allowed file extensions for GET requests in builder API, builder endpoints gated behind web flag, GKE deployment defaults to ClusterIP (no longer publicly exposed), and exclusion of compromised LiteLLM versions (pinned to 1.82.6). (2) **ADK Python v1.28.1** (Apr 2, 2026) — stable release adding support for `gemini-3.1-flash-live-preview` model in Live API, plus bug fixes for tool call buffering (now emitted together on turn completion). (3) **Gemini CLI** (github.com/google-gemini/gemini-cli) — Google's open-source terminal AI agent now at v0.37.0-preview.1 with subagent architecture (event-driven history, isolation, remote subagent support), persistent browser sessions, dynamic tool discovery, MCP server integration, GEMINI.md project config (analogous to CLAUDE.md), and a "Chapters" system for tool-based topic grouping. Free access to Gemini 2.5 Pro with 1M token context. (4) **Developer's Guide to Building ADK Agents with Skills** published April 1, 2026, and **Developer's Guide to AI Agent Protocols** published March 18, positioning A2A + MCP as the two foundational agent protocols.
- **Significance**: The v2.0.0 alpha signals ADK is preparing for a major version bump — the security hardening (preventing arbitrary module imports, compromised dependency exclusion) indicates lessons learned from production deployments. The LiteLLM compromise is noteworthy — a supply chain security incident affecting a key ADK dependency. Gemini CLI's emergence as a direct Claude Code competitor with similar architecture (MCP, project config files, subagents) validates the agentic CLI paradigm. The Live API support for gemini-3.1-flash-live-preview enables real-time voice/video agent development in ADK.
- **Source**: https://github.com/google/adk-python/releases/tag/v1.28.1, https://github.com/google/adk-python/releases/tag/v2.0.0a2, https://github.com/google-gemini/gemini-cli, https://geminicli.com/docs/changelogs/preview/

### 2026-04-03 -- ADK Java 1.0.0 Detailed Features & Plugin Architecture
- **What**: ADK Java 1.0.0 (released March 30, 2026) by Guillaume Laforge includes substantial new capabilities: (1) **New tools**: `GoogleMapsTool` (location-based grounding), `UrlContextTool` (web content fetch/summarize), `ContainerCodeExecutor` (Docker-based code execution), `VertexAiCodeExecutor` (cloud sandbox), `ComputerUseTool` (abstract browser/desktop automation interface). (2) **Plugin architecture**: New `App` class as top-level container with built-in plugins — `LoggingPlugin` (structured logging), `ContextFilterPlugin` (context window management), `GlobalInstructionPlugin` (app-wide instructions), extensible via custom `BasePlugin`. (3) **Context engineering**: Event compaction manages token efficiency with configurable intervals, overlap sizes, token thresholds (e.g., 4000 tokens), `LlmEventSummarizer`, and customizable retention strategies. (4) **Human-in-the-Loop (HITL)**: `ToolConfirmation`-based workflow for pausing tool execution for user approval with automatic context cleanup and resumption. (5) **Session/Memory services**: `InMemorySessionService`, `VertexAiSessionService`, `FirestoreSessionService` (community), plus `InMemoryMemoryService`, `FirestoreMemoryService`, and `GcsArtifactService`. (6) **Native A2A**: `RemoteA2AAgent` for consuming remote agents, `AgentExecutor` for exposing agents via JSON-RPC REST, seamless event streaming.
- **Significance**: The plugin architecture is a major maturity signal — it enables enterprise customization without forking the framework. Context engineering (event compaction, summarization) directly addresses the token cost problem in production agents. The Java SDK reaching feature parity with Python means enterprise Java shops can now adopt ADK without compromise. `ComputerUseTool` in Java signals Google bringing browser automation to enterprise agents.
- **Source**: https://developers.googleblog.com/announcing-adk-for-java-100-building-the-future-of-ai-agents-in-java/

### 2026-04-02 -- Interactions API Integration & ADK Domain Migration (sweep update)
- **What**: The new **Interactions API** can now serve as the inference engine for ADK agents, replacing the older `generateContent` endpoint. This provides server-side state management, background execution for long-running tasks, and native thought handling. ADK docs have migrated to a dedicated domain at **adk.dev** (redirected from google.github.io/adk-docs). ADK Java 1.0.0 officially released with bug fixes and enhancements. ADK Python latest release on March 26, 2026. Release cadence is roughly **bi-weekly** across all four language SDKs. The `InteractionsApiTransport` pattern also enables ADK agents to use Google's managed agents as A2A remote agents transparently.
- **Significance**: Interactions API integration is a significant upgrade — it means ADK agents get server-managed conversation state and can interop with Google's managed agents (Deep Research etc.) seamlessly. The domain migration to adk.dev signals ADK is becoming a standalone product brand, not just a Google Cloud sub-project.
- **Source**: https://developers.googleblog.com/building-agents-with-the-adk-and-the-new-interactions-api/, https://adk.dev/release-notes/

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
