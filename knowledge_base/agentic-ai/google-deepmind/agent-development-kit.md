# Agent Development Kit (ADK)

**Last updated**: 2026-04-09
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

### 2026-04-09 -- ADK Python Still at v1.28.1; No New Releases Day 7; Bi-Weekly Cadence Suggests Mid-April Release Imminent
- **What**: ADK continues pre-I/O stabilization with no new releases: (1) **ADK Python** latest stable remains v1.28.1 (Apr 2). No new releases on GitHub or PyPI. The bi-weekly release cadence (v1.28.0 Mar 26 → v1.28.1 Apr 2) suggests the next release (~v1.29.0) is imminent, likely within the next 3-5 days. (2) **ADK v2.0.0-alpha.2** (Mar 27) remains the latest alpha — graph-based workflow runtime and Task API for structured agent-to-agent delegation. (3) **New ADK feature highlighted**: **AgentEngineSandboxCodeExecutor** class for executing agent-generated code using Vertex AI Code Execution Sandbox API. Also, **session rewind capability** — rewind a session to before a previous invocation, removing polluted context. Both features visible in GitHub README but not yet documented in a specific release. (4) **ADK docs** at adk.dev (formerly google.github.io/adk-docs) continue updating — Google Skills training course now available at skills.google for ADK onboarding. (5) **Gemini API tooling updates** (context circulation, tool combos, Maps grounding) complement ADK's tool orchestration — ADK agents can now leverage combined built-in + custom tools in single API calls. (6) **Google I/O 2026 (May 19-20)** expected for ADK v2.0 beta or GA announcement. (7) **7M+ PyPI downloads** milestone holds — ADK remains the dominant agent framework by adoption.
- **Significance**: The 7-day gap since last release (longest gap in the recent bi-weekly cadence) confirms the pre-I/O preparation pattern. The session rewind and sandbox code executor features, if confirmed in the next release, add significant production value — session rewind is a novel debugging capability unique to ADK (no equivalent in Anthropic Agent SDK), and sandbox code execution addresses the security concern of running agent-generated code. The Google Skills training course signals Google is investing in ADK developer education infrastructure, not just the framework itself. For our pipeline, the key monitoring items remain: v2.0 graph runtime (Phase 5 impact), next stable release (expected mid-April), and I/O announcements.
- **Source**: https://github.com/google/adk-python/releases, https://pypi.org/project/google-adk/, https://github.com/google/adk-python

### 2026-04-08 -- ADK Pre-I/O Stabilization; 7M+ Downloads Confirmed; v2.0 Graph Runtime Preview Continues
- **What**: ADK ecosystem remains in pre-Google I/O stabilization with no new releases: (1) **ADK Python** latest stable is v1.28.1 (Apr 2). No new releases since. Bi-weekly cadence suggests next release mid-April. (2) **ADK v2.0.0-alpha.2** (Mar 27) remains the latest alpha — graph-based workflow runtime and Task API for structured agent-to-agent delegation. Not recommended for production. (3) **7M+ PyPI downloads** confirmed — ADK is the dominant agent framework in the Google ecosystem by download count. (4) **ADK Skills architecture** fully documented: progressive disclosure, 3-tier discovery (workspace/user/extension), SkillToolset runtime expertise generation. This mirrors Claude Code's skill loading but adds the capability for agents to **generate new expertise at runtime**. (5) **Qwen 3.6 Plus** (released ~Mar 30) presents a competitive challenge for ADK-based coding agents — 1M context, matches Claude Opus 4.5 on SWE-bench, free preview. ADK agents using Gemini may face quality comparisons. (6) **Google I/O 2026 (May 19-20)** expected to announce ADK v2.0 beta or GA with the graph-based workflow runtime.
- **Significance**: The extended stabilization period (no releases since Apr 2) is characteristic of a pre-major-announcement freeze. The ADK team appears to be preparing for a significant Google I/O reveal. The 7M download milestone validates ADK as the market leader among agent frameworks by adoption. For our pipeline, the key tracking items remain: v2.0 graph runtime (potential impact on Phase 5 topology), SkillToolset runtime generation (gap vs our build-time factory), and Qwen 3.6 Plus as an alternative model backend for ADK agents.
- **Source**: https://github.com/google/adk-python/releases, https://pypi.org/project/google-adk/, https://paddo.dev/blog/ai-roundup-april-2026/

### 2026-04-07 -- ADK Stabilization Continues; SkillToolset Runtime Expertise Generation; No New Releases
- **What**: ADK ecosystem remains in stabilization phase: (1) **No new ADK Python releases** since v1.28.1 (Apr 2) — expected bi-weekly cadence suggests next release mid-April. ADK v2.0.0-alpha.2 (Mar 27) remains the latest alpha. (2) **SkillToolset runtime expertise generation** highlighted in the April 1 developer guide — ADK agents can now **generate entirely new expertise at runtime** through skill configuration, not just load pre-defined skills. This is architecturally significant: agents are not limited to their initial tool set but can dynamically create new capabilities. (3) **Gemini CLI nightly build** (Apr 6) shows background memory service for skill extraction feeding back into the ADK skill ecosystem — suggesting a tight Gemini CLI → ADK skill pipeline. (4) **ADK Skills architecture confirmed**: progressive disclosure (metadata loaded initially, full instructions on activation), 3-tier discovery (workspace `.gemini/skills/`, user `~/.gemini/skills/`, extension), directly mirrors Claude Code's skill loading pattern. (5) **Google I/O 2026 (May 19-20)** expected to announce ADK v2.0 beta or GA with the graph-based workflow runtime.
- **Significance**: The SkillToolset runtime expertise generation is a notable capability gap vs our pipeline — our meta-agent-factory generates skills at build time, but ADK agents can create expertise dynamically at runtime. This aligns with the research direction of self-improving agents. The Gemini CLI → ADK skill pipeline (memory → skill extraction → runtime loading) represents a tighter feedback loop than our current factory → deploy model. No new releases is expected — the team appears focused on Google I/O preparations.
- **Source**: https://developers.googleblog.com/en/developers-guide-to-building-adk-agents-with-skills/, https://github.com/google/adk-python/releases, https://github.com/google-gemini/gemini-cli/releases

### 2026-04-06 -- ADK v2.0 Alpha Workflow Runtime Details, Gemma 4 Fine-Tuning Blockers, ADK 7M+ Downloads
- **What**: Consolidation sweep reveals: (1) **ADK v2.0 Alpha architecture details** — the "workflow runtime with graph-based execution" in v2.0.0-alpha.1 (Mar 18) introduces a structured Task API for agent-to-agent delegation. ADK 2.0 is designed for "more control, predictability, and reliability" — explicit graph-based workflows rather than LLM-driven routing. Should NOT be used in production; backwards compatibility not guaranteed. (2) **ADK Python downloads exceed 7 million** since public inception — confirms ADK as the dominant agent framework in the Google ecosystem. (3) **Gemma 4 fine-tuning tooling blockers at launch**: QLoRA fine-tuning was NOT ready at ADK launch — HuggingFace Transformers didn't recognize the `gemma4` architecture initially, PEFT couldn't handle `Gemma4ClippableLinear` (new vision encoder layer type), and a new `mm_token_type_ids` field is required during training even for text-only data. Both HuggingFace repos had issues filed. (4) **Gemma 4 26B MoE architecture clarification** — uses an "unusual design choice" where MoE blocks are added as separate layers alongside standard MLP blocks (not replacing them), trading efficiency for architectural simplicity vs. competitors like DeepSeek and Qwen. (5) **No new ADK releases since v1.28.1** (Apr 2) — current stable cadence is roughly bi-weekly. Next release expected mid-April.
- **Significance**: The ADK v2.0 graph-based workflow runtime is architecturally significant — it converges with Vercel's Workflow DevKit and temporal.io patterns for durable, observable agent orchestration. The 7M download milestone validates ADK's market position. The Gemma 4 fine-tuning blockers are a cautionary note — developers should verify tooling readiness before committing to Gemma 4 fine-tuning workflows. The MoE architecture detail (parallel not replacement) explains why the 26B has higher total params but only 4B active — it's a design tradeoff favoring simplicity.
- **Source**: https://google.github.io/adk-docs/2.0/, https://pypi.org/project/google-adk/, https://dev.to/linnn_charm_2e397112f3b51/gemma-4-complete-guide-architecture-models-and-deployment-in-2026-3m5b, https://github.com/google/adk-python/releases

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
