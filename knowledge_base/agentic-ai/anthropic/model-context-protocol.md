# Model Context Protocol (MCP)

**Last updated**: 2026-04-02
**Sources**:
- https://modelcontextprotocol.io/specification/2025-11-25
- https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/
- https://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/
- https://en.wikipedia.org/wiki/Model_Context_Protocol
- https://guptadeepak.com/the-complete-guide-to-model-context-protocol-mcp-enterprise-adoption-market-trends-and-implementation-strategies/

## Overview

The Model Context Protocol (MCP) is an open protocol created by Anthropic that enables seamless integration between LLM applications and external data sources and tools. It uses JSON-RPC 2.0 messages for communication between hosts (LLM applications), clients (connectors), and servers (capability providers). As of early 2026, MCP has 97M+ monthly SDK downloads, 5,800+ servers, 300+ clients, and backing from Anthropic, OpenAI, Google, and Microsoft. In December 2025, Anthropic donated MCP to the Agentic AI Foundation (AAIF) under the Linux Foundation.

## Key Developments (reverse chronological)

### 2026-01-01 -- 2026 MCP Roadmap Published
- **What**: Four priority areas defined: (1) Transport evolution and scalability, (2) Agent communication, (3) Governance maturation, (4) Enterprise readiness. Working Groups are now the primary vehicle for protocol development. SEPs aligned with priorities get expedited review.
- **Significance**: Shift from release-milestone organization to priority-area structure acknowledges the complexity of open-standards work. Next spec release tentatively slated for June 2026.
- **Source**: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/

### 2025-12-19 -- Transport Future Blog Post
- **What**: MCP will maintain only two official transports: STDIO (local) and Streamable HTTP (remote). No new transports planned. Focus on evolving existing transports for horizontal scaling, stateless session handling, and server discovery.
- **Significance**: Deliberate simplicity in transport layer. Streamable HTTP's production gaps (load balancer conflicts, no standard capability discovery) are being actively addressed.
- **Source**: https://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/

### 2025-12-01 -- MCP Donated to Agentic AI Foundation (AAIF)
- **What**: Anthropic donated MCP to the AAIF, a directed fund under the Linux Foundation, co-founded by Anthropic, Block, and OpenAI.
- **Significance**: Moves MCP from Anthropic-controlled to industry-governed open standard, increasing vendor neutrality and adoption confidence.
- **Source**: https://en.wikipedia.org/wiki/Model_Context_Protocol

### 2025-11-25 -- Specification Version 2025-11-25 Released
- **What**: Current authoritative specification version. Defines JSON-RPC 2.0 base protocol, stateful connections, capability negotiation. Server features: Resources, Prompts, Tools. Client features: Sampling, Roots, Elicitation. Additional: configuration, progress tracking, cancellation, error reporting, logging.
- **Significance**: First mature specification with full bidirectional capabilities (servers can request LLM sampling from clients).
- **Source**: https://modelcontextprotocol.io/specification/2025-11-25

### 2025-04-01 -- MCP Ecosystem Hits 8M Downloads
- **What**: MCP grew from 100K total downloads in November 2024 to over 8M by April 2025 -- 80x growth in five months.
- **Significance**: Explosive adoption validates the protocol as the de facto standard for AI-tool integration.
- **Source**: https://guptadeepak.com/the-complete-guide-to-model-context-protocol-mcp-enterprise-adoption-market-trends-and-implementation-strategies/

## Technical Details

### Architecture (Three-Tier)
- **Hosts**: LLM applications that initiate connections (e.g., Claude Code, IDEs)
- **Clients**: Connectors within the host application
- **Servers**: Services that provide context and capabilities

### Protocol Primitives

**Server-provided features:**
| Feature | Description |
|---------|-------------|
| Resources | Context and data for the user or AI model |
| Prompts | Templated messages and workflows |
| Tools | Functions for the AI model to execute |

**Client-provided features:**
| Feature | Description |
|---------|-------------|
| Sampling | Server-initiated LLM interactions |
| Roots | Server-initiated filesystem/URI boundary queries |
| Elicitation | Server-initiated requests for user information |

### Transports
- **STDIO**: Local deployments (subprocess communication)
- **Streamable HTTP**: Remote deployments (HTTP-based, replacing earlier SSE transport)

### Upcoming Features (2026 Roadmap)
- **MCP Server Cards**: Structured metadata at `/.well-known/mcp.json` for capability discovery without live connection
- **Agent Communication**: Building on experimental Tasks primitive; adding retry semantics and expiry policies
- **Governance**: Contributor ladder, delegation model, Working Group autonomy
- **Enterprise**: Audit trails, SSO authentication, gateway behavior, configuration portability
- **On the Horizon**: Triggers, event-driven updates, streamed result types, security enhancements

### Security Principles
1. Explicit user consent for all data access and operations
2. Tool descriptions treated as untrusted unless from trusted server
3. Explicit user approval required for LLM sampling requests
4. Implementors should build robust consent/authorization flows

### Spec Version History
- 2024-11-05: Initial specification
- 2025-11-25: Current version (added Elicitation, enhanced security model)
- ~2026-06 (tentative): Next version with transport evolution and agent communication

## Comparison Notes

MCP vs Google's A2A (Agent-to-Agent) Protocol:
- **MCP**: Focuses on connecting AI models to tools and data sources (model-to-tool)
- **A2A**: Focuses on agent-to-agent interoperability (agent-to-agent communication)
- **Complementary**: MCP and A2A serve different layers; A2A was designed to complement MCP
- **Governance**: Both are now under open governance (MCP via AAIF/Linux Foundation; A2A via its own community)
- **Adoption**: MCP has broader ecosystem adoption (97M+ downloads); A2A is earlier stage
- **Google supports both**: Google adopted MCP for Gemini while also developing A2A
