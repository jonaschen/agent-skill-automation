# Vertex AI Agents

**Last updated**: 2026-04-09
**Sources**:
- https://docs.cloud.google.com/agent-builder/overview
- https://docs.cloud.google.com/agent-builder/release-notes
- https://cloud.google.com/products/agent-builder
- https://cloud.google.com/blog/products/ai-machine-learning/more-ways-to-build-and-scale-ai-agents-with-vertex-ai-agent-builder
- https://docs.cloud.google.com/agent-builder/agent-engine/overview
- https://cloud.google.com/blog/products/ai-machine-learning/vertex-ai-memory-bank-in-public-preview
- https://cloud.google.com/blog/products/ai-machine-learning/new-enhanced-tool-governance-in-vertex-ai-agent-builder
- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes
- https://cloudfresh.com/en/blog/google-agentspace-evolves-into-gemini-enterprise/
- https://docs.cloud.google.com/gemini/enterprise/docs/release-notes
- https://docs.cloud.google.com/gemini/enterprise/docs/agent-designer

## Overview

Vertex AI Agent Builder is Google Cloud's enterprise platform for building, deploying, and managing AI agents at scale. It provides a full-stack foundation combining the Agent Development Kit (ADK), Agent Engine (managed runtime), Agent Designer (low-code visual tool), and Agent Garden (prebuilt agent library). Sessions, Memory Bank, and Code Execution are now Generally Available, with billing starting February 2026.

## Key Developments (reverse chronological)

### 2026-04-09 -- Vertex AI Extended Stabilization Day 6; No New Releases; Express Mode and Gemini 3.1 Flash Image Confirmed
- **What**: Vertex AI Agent Builder and Agent Engine remain in extended pre-I/O stabilization: (1) **No new Vertex AI GenAI release notes** after April 3, 2026 (RAG Engine Serverless Preview). Six consecutive days without releases. (2) **No new Agent Builder release notes** after February 18 (Code Execution GA). (3) **Express Mode** for Agent Engine Runtime confirmed — includes a new free tier, lowering the barrier to entry for agent development. (4) **Gemini 3.1 Flash Image** (`gemini-3.1-flash-image`) confirmed in public preview on Vertex AI with upsampling for 1080p and 4K video resolution — extends multimodal generation capabilities. (5) **Gemini 3.1 Pro** confirmed in preview in Model Garden as "most advanced reasoning Gemini model" with 1M context, multi-source problem solving (text, audio, images, video, PDFs, code repos). (6) **Gemini Enterprise** (formerly Agentspace) connector ecosystem continues expanding — Jira, Confluence, Salesforce, Docusign, GitHub, Google Chat, Notion, Linear all available. No new connectors this week. (7) **Partner model evaluation GA** — Anthropic and Llama models evaluable within Vertex AI's Gen AI evaluation service. (8) **Video generation endpoint deprecation** enforcement underway — legacy `imagegeneration`/`imagen` endpoints redirecting to newer models. (9) **Google I/O 2026 (May 19-20)** expected for major Agent Builder announcements.
- **Significance**: Six days of release silence across Vertex AI is the longest gap since the March release burst, strongly confirming the pre-I/O preparation pattern. The Express Mode with free tier is strategically significant — it creates a "try before you buy" path for Agent Engine, which could significantly increase developer adoption. Gemini 3.1 Flash Image on Vertex AI enables enterprise agents to generate and manipulate images natively, extending agent capabilities beyond text/code. The Gemini 3.1 Pro "multi-source problem solving" framing (text + audio + images + video + PDFs + code repos) positions it as the foundation for enterprise RAG agents that can reason across all document types. For our pipeline, Vertex AI remains stable with no blocking changes.
- **Source**: https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes, https://docs.cloud.google.com/agent-builder/release-notes, https://cloud.google.com/products/agent-builder

### 2026-04-08 -- Vertex AI Stabilization Holds; No New Releases Since Apr 3; Partner Model Eval Expanding
- **What**: Vertex AI Agent Builder and Agent Engine remain in extended stabilization with no new releases since April 3 (RAG Engine Serverless Preview). Key observations: (1) **Vertex AI GenAI release notes** show no entries after April 3, 2026. The April entries were: RAG Engine Serverless (Apr 3), Veo 3.1 Lite (Apr 2), Gemini 2.5 retirement extension to Oct 16 (Apr 2). (2) **Agent Builder release notes** still show no entries after February 18 (Code Execution GA). (3) **Gemini Enterprise** (formerly Agentspace) continues connector expansion — Jira, Confluence, Salesforce, Docusign, GitHub, Google Chat, Notion, Linear all available. (4) **Partner model evaluation** is now GA — enterprises can evaluate Anthropic and Llama models within Google's evaluation service, reducing vendor lock-in perception. (5) **Gemini 3.1 Flash-Lite** confirmed in public preview as "most cost-efficient Gemini model" for high-volume traffic. (6) **Gemini 3.1 Flash Image** (`gemini-3.1-flash-image`) available in public preview on Vertex AI. (7) **Claude 3 Haiku deprecated** on Vertex AI as of Feb 23, shutdown Aug 23. (8) Team appears focused on Google I/O 2026 (May 19-20) preparations.
- **Significance**: The 5-day release silence (Apr 3-8) across Vertex AI confirms the pre-I/O preparation pattern. The partner model evaluation GA is strategically important — it positions Vertex AI as a neutral evaluation platform, not just a Google-model platform. Gemini 3.1 Flash Image on Vertex AI expands multimodal generation capabilities for enterprise agents. The Claude 3 Haiku deprecation on Vertex signals Google pushing customers toward newer Anthropic models or Gemini alternatives. For our pipeline, Vertex AI Agent Engine remains the production deployment target for Google-ecosystem agents, with no blocking changes.
- **Source**: https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes, https://docs.cloud.google.com/agent-builder/release-notes

### 2026-04-07 -- Vertex AI Continues Stabilization; No New Releases; Google I/O Focus
- **What**: Vertex AI Agent Builder and Agent Engine remain in stabilization with no new releases since April 3 (RAG Engine Serverless Preview). Key confirmed state: (1) **Agent Builder release notes** show no entries after February 18, 2026 (Code Execution GA) — the April 3 RAG Engine Serverless entry appears only in the Vertex AI GenAI release notes, not the Agent Builder-specific notes. (2) **Vertex AI SDK Python** remains at v1.112.0 with the refactored agent_engines client-based design. (3) **Gemini Enterprise** (formerly Agentspace) continuing rapid connector expansion — Jira, Confluence, Salesforce, Docusign, GitHub, Google Chat, Notion, Linear connectors all added in Feb–Apr timeframe. (4) **Agent Designer sharing** is GA (Feb 23) with admin review support. (5) The team appears focused on **Google I/O 2026 (May 19-20)** preparations — expect major Agent Builder announcements there. (6) No pricing changes or new feature announcements detected.
- **Significance**: The extended quiet period (no Agent Builder releases since Feb 18, despite active Vertex AI GenAI releases) suggests the Agent Builder team is working on a significant update expected at Google I/O. The connector expansion in Gemini Enterprise shows Google prioritizing enterprise data integration breadth over platform features. For our pipeline, Vertex AI Agent Engine remains the production deployment target for any Google-ecosystem agents we build.
- **Source**: https://docs.cloud.google.com/agent-builder/release-notes, https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes

### 2026-04-06 -- Vertex AI Stabilization Phase; RAG Engine Serverless and Veo 3.1 Lite Confirmed as Latest
- **What**: Sweep of Vertex AI release notes confirms no new Agent Builder or Agent Engine releases since April 3: (1) **RAG Engine Serverless Mode** (Apr 3, Preview) — fully managed database for RAG resources with seamless switching between serverless and Spanner modes — remains the most recent Agent Builder-adjacent feature. (2) **Veo 3.1 Lite** (Apr 2, Preview) — cost-efficient video generation on Vertex AI. (3) **Gemini 2.5 model retirement extended** to October 16, 2026. (4) **Gemma 4 Vertex AI deployment** confirmed — three paths: Vertex AI Model Garden (managed with autoscaling, SLA guarantees), Cloud Run (serverless containers), GKE with vLLM (high-throughput). Gemma 4 26B MoE to be available as fully managed and serverless on Model Garden. Fine-tuning via Vertex AI Training Clusters (VTC) with NVIDIA NeMo Megatron optimized SFT recipes. (5) **Vertex AI SDK Python v1.112.0** — agent_engines module refactored to client-based design with migration guide available. (6) **Private VPC deployment** now supported for Agent Engine — Private Service Connect interface for data privacy and compliance.
- **Significance**: Vertex AI is in a stabilization/consolidation phase after the intense March release cycle. The Gemma 4 managed serving on Model Garden is significant — it provides a turnkey production deployment path for open models without self-hosting infrastructure. The SDK refactor to client-based design suggests Google is preparing for higher-scale agent engine usage. The private VPC support addresses the #1 enterprise blocker for agent adoption (data sovereignty). No new features in April 4-6 suggests the team is focused on Google I/O 2026 (May 19-20) preparations.
- **Source**: https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes, https://docs.cloud.google.com/agent-builder/release-notes, https://cloud.google.com/blog/products/ai-machine-learning/gemma-4-available-on-google-cloud

### 2026-04-05 -- Vertex AI RAG Engine Serverless, Gemini Enterprise Rapid Connector Expansion, Agent Designer GA
- **What**: Multiple updates across the Vertex AI and Gemini Enterprise ecosystem: (1) **Vertex AI RAG Engine Serverless Mode** (Apr 3) — public preview of a fully managed database for storing RAG resources with seamless switching between serverless and Spanner modes. (2) **Gemini Enterprise connector explosion** (Mar–Apr): Jira Cloud + Confluence Cloud federated connectors (GA, Apr 3), Salesforce data federation (Preview, Mar 31), Docusign connector (Preview, Mar 23), GitHub connector (Preview, Mar 4), Google Chat connector (Preview, Mar 11), Notion connector (Preview, Feb 9), Linear connector (Preview, Feb 6). New actions for Gmail, Google Drive, GitHub, HubSpot, Monday, Confluence Data Center, Shopify, Zendesk (Preview, Mar 31). (3) **Agent Designer sharing GA** (Feb 23) — direct sharing of agents with configurable admin review. (4) **Cross-domain documents for Google Drive** (Preview, Mar 30) — search and index documents outside your organization. (5) **Data Insights agent for BigQuery** (GA with allowlist, Mar 24). (6) **NotebookLM Enterprise autocomplete** (GA, Apr 2). (7) **Gemini Enterprise mobile app** (GA with allowlist, Feb 12). (8) **Chat retention configuration** (GA, Mar 11). (9) **Image and video search in assistant** (GA, Mar 13). (10) **Observability settings** — Metrics Explorer and Trace Explorer (Preview, Mar 12). (11) **Veo 3.1 Lite** on Vertex AI (Preview, Apr 2). (12) **Gemini 2.5 model retirement extended** to October 16, 2026.
- **Significance**: The RAG Engine serverless mode is a significant infrastructure addition — it removes the need for teams to manage their own vector databases when building RAG-powered agents. The connector expansion pace (8+ new connectors in 2 months) shows Google aggressively expanding Gemini Enterprise's data source coverage to compete with enterprise SaaS aggregators. Agent Designer reaching GA with sharing confirms Google's bet on low-code agent building. The Gemini Enterprise mobile app means enterprise AI agents are now mobile-first. The Gemini 2.5 retirement extension (to Oct 2026) gives enterprises more migration runway.
- **Source**: https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes, https://docs.cloud.google.com/gemini/enterprise/docs/release-notes

### 2026-04-04 -- Agentspace → Gemini Enterprise Rebrand, HIPAA Support, Multimodal Model Updates
- **What**: Several platform-level changes affecting the Vertex AI agent ecosystem: (1) **Agentspace → Gemini Enterprise rebrand** — Google Agentspace has been absorbed into Gemini Enterprise, with conversational AI and agent orchestration technology from Agentspace now powering Gemini Enterprise core. New Agentspace subscriptions ceased Dec 31, 2025. Agent Designer is now GA within Gemini Enterprise. Semantic search (meaning-based, not just keyword) enabled. Cross-platform file uploads from Google Drive, OneDrive, and SharePoint. Web grounding enabled by default. (2) **HIPAA workloads**: Vertex AI Agent Engine now supports HIPAA workloads, critical for healthcare agent deployments. (3) **Veo 3.1 Lite** (Apr 2) available on Vertex AI for cost-efficient video generation. (4) **Lyria 3 audio** (Mar 25) in public preview with pro (184s) and clip (30s) variants. (5) **Partner model evaluation** (Mar 12) — Gen AI evaluation service now supports evaluating Anthropic and Llama models, not just Google models. (6) **Legacy endpoint deprecation** (Mar 24) — all `imagegeneration`/`imagen` endpoints redirect to `gemini-2.5-flash-image` by June 30, 2026; video generation migrates to `veo-3.1` variants.
- **Significance**: The Agentspace → Gemini Enterprise rebrand consolidates Google's enterprise AI agent story under one brand. HIPAA support is a major enterprise unlock — healthcare is one of the largest potential markets for AI agents. Partner model evaluation is strategically important — enterprises can now objectively compare Claude/Llama/Gemini agents within Google's tooling, reducing vendor lock-in perception. The aggressive deprecation timeline (June 30) forces migration to newer models.
- **Source**: https://cloudfresh.com/en/blog/google-agentspace-evolves-into-gemini-enterprise/, https://docs.cloud.google.com/vertex-ai/generative-ai/docs/release-notes, https://docs.cloud.google.com/agent-builder/release-notes

### 2026-04-03 -- Code Execution GA, Regional Expansion, Session Rewind, Bidirectional Streaming
- **What**: Comprehensive release notes update: (1) **Code Execution GA** (Feb 18, 2026) — Agent Engine Code Execution is now Generally Available with sandboxed execution. (2) **Regional expansion** — Agent Engine services now available in 7 additional regions: Zurich, Milan, Hong Kong, Seoul, Jakarta, Toronto, and São Paulo (Dec 2025). (3) **Session rewind** — developers can now rewind to any point in a conversation and invalidate all interactions after that point, removing polluted context without sending a new message. (4) **Bidirectional streaming** — Agent Engine supports bidirectional streaming for real-time agent interactions. (5) **Enterprise security**: Private Service Connect and customer-managed encryption keys (CMEK) now supported. (6) **Agent identity** credentials secured by default through Google-managed Context-Aware Access (CAA) policy. (7) **Cloud API Registry** (Preview, Dec 18 2025) — private registry for admins to curate and govern approved tools for developers across their organization, integrated with MCP servers. (8) **Agent Designer** (Preview, Dec 19 2025) — low-code visual designer for designing and testing agents in the Cloud console.
- **Significance**: Code Execution GA completes the core Agent Engine service trilogy (Sessions + Memory Bank + Code Execution). Session rewind is a novel debugging/UX feature — no competitor offers mid-conversation state rollback. The 7-region expansion addresses data residency requirements for global enterprises. CMEK + Private Service Connect addresses regulated industry requirements (finance, healthcare).
- **Source**: https://docs.cloud.google.com/agent-builder/release-notes

### 2026-04-02 -- Context Layers, Self-Healing Plugins, Observability, Tool Governance Details (sweep update)
- **What**: New capabilities announced for Vertex AI Agent Builder: (1) **Configurable context layers** (Static, Turn, User, Cache) via the ADK API give developers granular control over agent context and token usage; (2) **Self-healing plugins framework** enables agents to recover from tool failures using adaptable plugins, including a prebuilt tool-use plugin; (3) **Cloud API Registry integration** for tool governance — admins manage available tools for developers across their organization directly in the Agent Builder Console, with pre-built tools for BigQuery and Google Maps; (4) **Observability dashboard** within Agent Engine runtime tracks token usage, latency, and error rates; (5) **Evaluation layer** simulates user interactions to test agent reliability before production; (6) **Agent identity credentials** secured by default via Google-managed Context-Aware Access (CAA) policy; (7) **Lowered pricing** for Agent Engine runtime.
- **Significance**: Context layers address the #1 production pain point (token cost). Self-healing plugins are a novel approach to agent reliability — agents can autonomously recover from tool errors without human intervention. The observability dashboard fills a critical gap for production monitoring. CAA-secured agent identity is an enterprise security differentiator.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/more-ways-to-build-and-scale-ai-agents-with-vertex-ai-agent-builder, https://cloud.google.com/blog/products/ai-machine-learning/new-enhanced-tool-governance-in-vertex-ai-agent-builder

### 2026-02-11 -- Billing Begins for Sessions, Memory Bank, Code Execution
- **What**: Usage-based billing started for Agent Engine Sessions, Memory Bank, and Code Execution services (delayed from original January 28 date).
- **Significance**: Marks the transition from free preview to paid production services, signaling enterprise readiness.
- **Source**: https://docs.cloud.google.com/agent-builder/release-notes

### 2025-12 -- Enhanced Tool Governance
- **What**: Vertex AI Agent Builder added enhanced tool governance capabilities, providing guardrails for agent tool usage in enterprise environments.
- **Significance**: Addresses enterprise security requirements for controlling what agents can do, critical for regulated industries.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/new-enhanced-tool-governance-in-vertex-ai-agent-builder

### 2025-H2 -- Sessions and Memory Bank GA
- **What**: Agent Engine Sessions (short-term context) and Memory Bank (long-term persistent memory) reached General Availability. Memory Bank uses a novel topic-based approach (accepted by ACL 2025) for structured, topic-aware memory organization and retrieval.
- **Significance**: Memory Bank provides persistent cross-session context -- a key requirement for production agents that need to remember user preferences and past interactions. The topic-based approach sets a new standard for agent memory.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/vertex-ai-memory-bank-in-public-preview

### 2025-H2 -- Agent Designer Preview
- **What**: Low-code visual designer launched in Google Cloud console Preview, allowing drag-and-drop agent design and testing.
- **Significance**: Lowers the barrier for non-developers to create agents, expanding the builder audience beyond engineers.
- **Source**: https://docs.cloud.google.com/agent-builder/release-notes

### 2025-05-20 -- Agent Engine UI at Google I/O
- **What**: New Agent Engine UI in Google Cloud console providing centralized dashboard for viewing deployed agents, listing sessions, tracing/debugging actions, and monitoring performance.
- **Significance**: Fills a major gap in agent lifecycle management -- previously required CLI/API for all operations.
- **Source**: https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/

## Technical Details

### Platform Components

1. **Agent Development Kit (ADK)**: Open-source framework for building agents (see separate ADK KB file)

2. **Agent Engine**: Managed runtime services:
   - **Runtime**: Fully managed execution environment for deployed agents
   - **Sessions**: Short-term conversation context management (GA)
   - **Memory Bank**: Long-term persistent memory with topic-based retrieval (GA)
   - **Code Execution**: Sandboxed code execution for agents (GA)
   - **Evaluation**: Built-in agent evaluation capabilities

3. **Agent Designer**: Low-code visual builder (Preview)
   - Drag-and-drop agent design
   - Visual testing interface
   - No-code tool configuration

4. **Agent Garden**: Prebuilt agent and tool library
   - Sample agents for common use cases
   - Reusable tool templates
   - End-to-end solution accelerators

### Enterprise Features

- 100+ pre-built connectors for enterprise data sources
- Application Integration workflows
- AlloyDB and BigQuery data access
- Apigee API management integration
- Google Cloud IAM for access control
- Enhanced tool governance (guardrails)

### Pricing (effective Feb 2026)

- Agent Engine Runtime: Usage-based billing
- Sessions: Usage-based billing
- Memory Bank: Usage-based billing
- Code Execution: Usage-based billing
- Specific per-unit pricing available at https://cloud.google.com/vertex-ai/pricing

## Comparison Notes

**vs Anthropic**:
- Anthropic does not have an equivalent managed agent hosting platform. Claude is accessed via API, and agent orchestration is left to developers or third-party platforms
- Vertex AI Agent Builder provides end-to-end lifecycle management (build, deploy, monitor, evaluate); Anthropic provides API + SDK only
- Memory Bank (persistent agent memory) has no direct Anthropic equivalent -- Claude relies on conversation context or external memory systems
- Agent Designer (low-code) has no Anthropic counterpart
- Agent Garden (prebuilt agents) has no Anthropic equivalent
- Vertex AI's tool governance provides enterprise guardrails; Anthropic relies on system prompts and developer-implemented controls
- Vertex AI supports any model via Model Garden (including Claude); Anthropic is Claude-only
