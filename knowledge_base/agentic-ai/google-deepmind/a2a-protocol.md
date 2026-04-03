# Agent2Agent (A2A) Protocol

**Last updated**: 2026-04-04
**Sources**:
- https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/
- https://cloud.google.com/blog/products/ai-machine-learning/agent2agent-protocol-is-getting-an-upgrade
- https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/
- https://www.linuxfoundation.org/press/linux-foundation-launches-the-agent2agent-protocol-project-to-enable-secure-intelligent-communication-between-ai-agents
- https://github.com/a2aproject/A2A
- https://www.infoworld.com/article/4032776/google-upgrades-agent2agent-protocol-with-grpc-and-enterprise-grade-security.html
- https://a2a-protocol.org/latest/specification/
- https://developers.googleblog.com/developers-guide-to-ai-agent-protocols/
- https://cloudfresh.com/en/blog/google-agentspace-evolves-into-gemini-enterprise/

## Overview

Agent2Agent (A2A) is an open protocol created by Google for enabling secure communication and collaboration between AI agents across different platforms, vendors, and frameworks. Launched in April 2025, it was donated to the Linux Foundation in June 2025 and has grown to over 150 supporting organizations. A2A is designed to complement (not compete with) Anthropic's Model Context Protocol (MCP), with MCP handling tool/context provision and A2A handling inter-agent communication.

## Key Developments (reverse chronological)

### 2026-04-04 -- A2A v1.0.0 Released (March 12, 2026) — Major Milestone
- **What**: The Agent2Agent protocol reached **v1.0.0** on March 12, 2026 — a major milestone signaling production readiness. Key changes from v0.3: (1) **Breaking changes**: Large refactor separating application protocol definition from transport mapping; combined `TaskPushNotificationConfig` and `PushNotificationConfig`; switched to non-complex IDs in requests; aligned enum format with ADR-001 ProtoJSON specification; removed deprecated fields; moved `extendedAgentCard` to `AgentCapabilities`; standardized American spelling of "canceled". (2) **New features**: `tasks/list` method with filtering and pagination; modernized OAuth 2.0 flows (removed implicit/password grants, added device code + PKCE); native gRPC multi-tenancy support via additional scope field on requests; SDK backwards compatibility mechanism. (3) **Ecosystem integration**: Google published a **Developer's Guide to AI Agent Protocols** (Mar 18, 2026) positioning A2A alongside MCP as the two foundational agent protocols. (4) **Agentspace → Gemini Enterprise rebrand**: The platform consuming A2A agents has been rebranded from Google Agentspace to Gemini Enterprise (Agentspace no longer available for new subscriptions as of Dec 31, 2025). A2A agents can now be consumed through the Gemini Enterprise platform.
- **Significance**: v1.0.0 is a watershed moment — it signals the protocol is stable enough for production enterprise deployments. The OAuth 2.0 modernization (removing implicit/password grants, adding PKCE) aligns with current security best practices. The `tasks/list` method with filtering/pagination addresses a real production need for managing large-scale agent task queues. The transport-agnostic refactor makes it cleaner to add future transport bindings. The Agentspace → Gemini Enterprise rebrand creates a clearer product hierarchy.
- **Source**: https://github.com/a2aproject/A2A/releases/tag/v1.0.0, https://developers.googleblog.com/developers-guide-to-ai-agent-protocols/, https://cloudfresh.com/en/blog/google-agentspace-evolves-into-gemini-enterprise/

### 2026-04-03 -- A2A v0.3 Enterprise Security Deep Dive & Marketplace Integration
- **What**: Further details on A2A v0.3 enterprise adoption: (1) **Signed Agent Cards** enable cryptographic identity verification — agents can prove their origin, addressing Fortune 500 requirements that won't deploy agents lacking proof of identity. The signing mechanism ensures "appropriate access control and runtime policies are followed," protecting reputation, trade secrets, and financial performance. (2) **ADK native integration** — A2A is built directly into ADK, so agents built with ADK automatically get A2A communication capabilities without additional configuration. (3) **AI Agents Marketplace** — partners can now sell A2A-supported agents on Google's marketplace; enterprise systems can evaluate A2A-compatible agents through the Vertex GenAI Evaluation Service. (4) **Real-world enterprise pilots**: Tyson Foods and Gordon Food Service are pioneering collaborative A2A systems, creating a real-time channel for their agents to share product data and leads to enhance the food supply chain. (5) **Protocol bindings clarified**: JSON-RPC, gRPC, and HTTP/REST are all equally capable — developers choose based on infrastructure. Service parameters transmitted via HTTP headers for HTTP bindings, gRPC metadata for gRPC bindings.
- **Significance**: The signed Agent Cards are the most important enterprise security feature — they solve the "who is this agent?" identity problem that has been a blocker for enterprise multi-agent deployments. The marketplace integration creates a commercial flywheel: build A2A agents → sell on marketplace → more adoption → more agents. Tyson/Gordon Food Service shows A2A moving beyond demos to production supply chain use.
- **Source**: https://www.infoworld.com/article/4032776/google-upgrades-agent2agent-protocol-with-grpc-and-enterprise-grade-security.html, https://a2a-protocol.org/latest/specification/

### 2026-04-02 -- A2A Ecosystem Expansion, Interactions API Bridge, Agentspace (sweep update)
- **What**: The A2A ecosystem now includes over 150 organizations spanning hyperscalers, technology providers, and enterprise customers. AWS published a blog on A2A interoperability. A rival protocol (AAIF) has emerged as competition. New developments: (1) **InteractionsApiTransport** provides a transparent A2A bridge — treats Google's managed agents as standard remote A2A agents without client refactoring; (2) Google announced A2A support coming to **Agent Engine**, enabling any-framework agents deployed on Agent Engine to become production-ready A2A agents; (3) **Agentspace** integration coming, allowing partners to make A2A agents available as consumable services in the Agentspace platform.
- **Significance**: The Interactions API bridge is architecturally significant — it means any ADK agent can instantly interop with Google's managed agents (Deep Research, etc.) via A2A. Agent Engine + A2A means the deployment story is now: write in any framework → deploy to Agent Engine → automatically A2A-accessible. Agentspace turns A2A agents into a marketplace.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/agent2agent-protocol-is-getting-an-upgrade, https://developers.googleblog.com/building-agents-with-the-adk-and-the-new-interactions-api/

### 2025-07 -- A2A v0.3 Released
- **What**: Version 0.3.0 introduced gRPC support (in addition to JSON-RPC 2.0 and REST), signed Agent Cards for security verification, updated well-known path to `/.well-known/agent-card.json`, and extended Python SDK client-side support.
- **Significance**: gRPC support enables high-performance enterprise streaming use cases. Signed Agent Cards address enterprise security requirements for verifying agent identity.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/agent2agent-protocol-is-getting-an-upgrade

### 2025-06 -- Linux Foundation Adoption
- **What**: Google donated A2A to the Linux Foundation as an open-source project, ensuring vendor-neutral governance.
- **Significance**: Linux Foundation hosting provides credibility and governance structure needed for enterprise adoption, similar to how CNCF hosts Kubernetes.
- **Source**: https://developers.googleblog.com/en/google-cloud-donates-a2a-to-linux-foundation/

### 2025-05-20 -- A2A v0.2 at Google I/O
- **What**: Specification v0.2 released with support for stateless interactions and standardized authentication based on OpenAPI-like schema. Official Python SDK released. Partners adding support: Auth0, Box, Microsoft (Azure AI Foundry), SAP (Joule), Zoom.
- **Significance**: Stateless interactions reduce complexity for lightweight agent communication. Microsoft's adoption signals cross-cloud acceptance.
- **Source**: https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/

### 2025-04 -- A2A Protocol Launch
- **What**: Google launched A2A with 50+ technology partners including Atlassian, Box, Cohere, Intuit, LangChain, MongoDB, PayPal, Salesforce, SAP, ServiceNow, UKG, Workday, plus service providers (Accenture, BCG, Deloitte, McKinsey, etc.).
- **Significance**: Largest initial partner coalition for an agent interoperability protocol, establishing immediate ecosystem credibility.
- **Source**: https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/

## Technical Details

### Architecture

A2A uses a client-remote model:
- **Client agent**: Formulates tasks and sends them to remote agents
- **Remote agent**: Executes tasks and returns results

### Core Components

1. **Agent Cards**: JSON documents where agents advertise capabilities. Published at `/.well-known/agent-card.json`. Can be signed (v0.3+) for identity verification. Enable capability discovery -- client agents find the best remote agent for a task.

2. **Task Management**: Communication centers on task lifecycle. Tasks can complete immediately or span hours/days as long-running operations with real-time status updates.

3. **Message Exchange**: Agents exchange messages containing context, replies, artifacts, and user instructions while maintaining synchronized state.

4. **UX Negotiation**: Messages include "parts" (content units with MIME types). Agents negotiate display formats including iframes, video, web forms.

### Transport Protocols (v0.3)
- JSON-RPC 2.0
- gRPC
- REST

All three are equally capable -- developers choose based on infrastructure.

### Design Principles
1. **Agentic capabilities**: Agents are peers, not limited to "tool" roles
2. **Existing standards**: Built on HTTP, SSE, JSON-RPC
3. **Enterprise security**: OpenAPI-compatible auth schemes
4. **Long-running tasks**: Quick tasks to extended research spanning days
5. **Modality agnostic**: Text, audio, video streaming

### Example: Candidate Sourcing Workflow
A hiring manager's agent tasks specialized agents to source candidates, schedule interviews, and coordinate background checks -- demonstrating multi-agent collaboration across HR systems with no shared memory or tools.

## Comparison Notes

**A2A vs MCP (Anthropic)**:
- **Complementary, not competing**: MCP provides tools and context to agents; A2A enables agents to talk to each other
- **MCP** = "give an agent access to tools/data" (agent-to-tool)
- **A2A** = "let agents collaborate on tasks" (agent-to-agent)
- Both are open-source and built on existing web standards
- MCP is more mature (broader tool ecosystem); A2A is newer but growing fast
- A2A supports long-running tasks natively; MCP is typically request-response
- A2A has Agent Cards for capability discovery; MCP has server manifests
- Google explicitly states A2A complements MCP, and ADK supports both
