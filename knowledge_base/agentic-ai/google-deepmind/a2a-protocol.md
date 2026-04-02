# Agent2Agent (A2A) Protocol

**Last updated**: 2026-04-02
**Sources**:
- https://developers.googleblog.com/en/a2a-a-new-era-of-agent-interoperability/
- https://cloud.google.com/blog/products/ai-machine-learning/agent2agent-protocol-is-getting-an-upgrade
- https://developers.googleblog.com/agents-adk-agent-engine-a2a-enhancements-google-io/
- https://www.linuxfoundation.org/press/linux-foundation-launches-the-agent2agent-protocol-project-to-enable-secure-intelligent-communication-between-ai-agents
- https://github.com/a2aproject/A2A

## Overview

Agent2Agent (A2A) is an open protocol created by Google for enabling secure communication and collaboration between AI agents across different platforms, vendors, and frameworks. Launched in April 2025, it was donated to the Linux Foundation in June 2025 and has grown to over 150 supporting organizations. A2A is designed to complement (not compete with) Anthropic's Model Context Protocol (MCP), with MCP handling tool/context provision and A2A handling inter-agent communication.

## Key Developments (reverse chronological)

### 2026-04-02 -- A2A Ecosystem at 150+ Organizations (surveyed)
- **What**: The A2A ecosystem now includes over 150 organizations spanning hyperscalers, technology providers, and enterprise customers. AWS published a blog on A2A interoperability. A rival protocol (AAIF) has emerged as competition.
- **Significance**: Broad adoption validates A2A as a potential industry standard, though competing protocols signal the space is not yet settled.
- **Source**: https://aws.amazon.com/blogs/opensource/open-protocols-for-agent-interoperability-part-4-inter-agent-communication-on-a2a/

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
