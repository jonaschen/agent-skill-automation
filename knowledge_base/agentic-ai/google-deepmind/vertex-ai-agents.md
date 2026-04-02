# Vertex AI Agents

**Last updated**: 2026-04-02
**Sources**:
- https://docs.cloud.google.com/agent-builder/overview
- https://docs.cloud.google.com/agent-builder/release-notes
- https://cloud.google.com/products/agent-builder
- https://cloud.google.com/blog/products/ai-machine-learning/more-ways-to-build-and-scale-ai-agents-with-vertex-ai-agent-builder
- https://docs.cloud.google.com/agent-builder/agent-engine/overview
- https://cloud.google.com/blog/products/ai-machine-learning/vertex-ai-memory-bank-in-public-preview

## Overview

Vertex AI Agent Builder is Google Cloud's enterprise platform for building, deploying, and managing AI agents at scale. It provides a full-stack foundation combining the Agent Development Kit (ADK), Agent Engine (managed runtime), Agent Designer (low-code visual tool), and Agent Garden (prebuilt agent library). Sessions, Memory Bank, and Code Execution are now Generally Available, with billing starting February 2026.

## Key Developments (reverse chronological)

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
