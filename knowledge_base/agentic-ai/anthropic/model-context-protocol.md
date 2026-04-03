# Model Context Protocol (MCP)

**Last updated**: 2026-04-04
**Sources**:
- https://modelcontextprotocol.io/specification/2025-11-25
- https://modelcontextprotocol.io/specification/draft/basic/authorization
- https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/
- https://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/
- https://en.wikipedia.org/wiki/Model_Context_Protocol
- https://guptadeepak.com/the-complete-guide-to-model-context-protocol-mcp-enterprise-adoption-market-trends-and-implementation-strategies/
- https://auth0.com/blog/mcp-specs-update-all-about-auth/
- https://medium.com/@dave-patten/securing-remote-mcp-servers-oauth-2-1-cimd-and-dcr-07b72c036d7f
- https://www.prnewswire.com/news-releases/linux-foundation-is-launching-the-x402-foundation-and-welcoming-the-contribution-of-the-x402-protocol-302732803.html
- https://zuplo.com/blog/mcp-api-payments-with-x402

## Overview

The Model Context Protocol (MCP) is an open protocol created by Anthropic that enables seamless integration between LLM applications and external data sources and tools. It uses JSON-RPC 2.0 messages for communication between hosts (LLM applications), clients (connectors), and servers (capability providers). As of early 2026, MCP has 97M+ monthly SDK downloads, 5,800+ servers, 300+ clients, and backing from Anthropic, OpenAI, Google, and Microsoft. In December 2025, Anthropic donated MCP to the Agentic AI Foundation (AAIF) under the Linux Foundation.

## Key Developments (reverse chronological)

### 2026-04-04 -- MCP Dev Summit Results: SDK V2 Roadmap, XAA/ID-JAG, OpenAI Resources Alignment
- **What**: Key outcomes from the MCP Dev Summit North America (April 2-3, NYC), now available on YouTube: (1) **SDK V2 Roadmap** — Anthropic's Max Isbey presented "Path to V2 for MCP SDKs." The Python SDK has been frozen at v1.26.0 since January 24 (63-day freeze) while V2 is developed. V2 may include breaking changes to `mcp.server.auth`. (2) **Cross-App Access (XAA/ID-JAG)** — Anthropic's Paul Carleton presented on "single sign-on for agents" enabling shared identity across multiple AI tools. (3) **OpenAI MCP Resources alignment** — Nick Cooper (OpenAI) presented "MCP x MCP" keynote. OpenAI's agents SDK recently added `list_resources()` and `read_resource()` for MCP Resources, with parallel PRs pending in the Anthropic Python SDK. This signals cross-ecosystem standardization of MCP Resource support. (4) **Aaron Parecki** (OAuth 2.1 spec author) attended, grounding auth work in formal specification. (5) **Ecosystem scale**: MCP now has 10,000+ published servers (up from 5,800+ previously documented), covering everything from developer tools to Fortune 500 deployments. All sessions now available on the MCP Developers Summit YouTube channel.
- **Significance**: SDK V2 is the most impactful announcement — the 63-day Python freeze signals a major rewrite is underway. XAA/ID-JAG ("single sign-on for agents") could solve the fragmented auth problem across the entire agent ecosystem. OpenAI + Anthropic aligning on MCP Resources means the two largest AI platforms will have interoperable context sharing. The 10K server milestone (up from 5.8K) represents 72% growth in a short period.
- **Source**: https://dev.to/peytongreen_dev/mcp-dev-summit-2026-what-python-developers-should-actually-pay-attention-to-5ald, https://events.linuxfoundation.org/mcp-dev-summit-north-america/

### 2026-04-04 -- MCP Roadmap 2026: No New Transports, Evolve Existing
- **What**: Confirmed from the official 2026 MCP roadmap blog: the team explicitly stated "we are not adding more official transports this cycle but evolve the existing transport." Streamable HTTP is the sole remote transport being scaled. Key gaps surfaced in production: stateful sessions conflict with load balancers, horizontal scaling requires workarounds, and there is no standard way for a registry or crawler to discover server capabilities without connecting. Solutions in progress: evolving transport/session model for stateless horizontal scaling, and a standard `.well-known` metadata format for offline server capability discovery. The governance shift to Working Group autonomy allows domain-specific SEPs to be accepted without full Core Maintainer review, removing the bottleneck. Enterprise features (audit trails, SSO, gateway behavior, config portability) will land as extensions, not core protocol changes.
- **Significance**: The explicit "no new transports" commitment provides stability for implementers. The `.well-known` metadata format is critical for MCP server registries, marketplaces, and automated agent discovery. The enterprise-as-extensions approach keeps the core protocol simple while enabling production deployment at scale.
- **Source**: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/

### 2026-04-04 -- Claude Code v2.1.91: MCP Result Size Override (500K chars)
- **What**: Claude Code v2.1.91 added `_meta["anthropic/maxResultSizeChars"]` annotation for MCP tool results, allowing servers to specify result persistence up to 500K characters. Previously, large MCP results were truncated. This is an MCP server-side annotation, not a protocol change.
- **Significance**: Removes a significant bottleneck for MCP servers returning large datasets (database queries, log dumps, code analysis reports). Servers can now self-declare their result size needs without client-side configuration.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-04-03 -- x402 Foundation Launched at MCP Dev Summit for Agent Payments
- **What**: The Linux Foundation announced the x402 Foundation at the MCP Dev Summit North America on April 2, 2026. x402 is a universal payment protocol (contributed by Coinbase, originally developed with Cloudflare and Stripe) that embeds payments directly into HTTP interactions, enabling AI agents to autonomously pay for APIs and MCP servers with stablecoins — no accounts, subscriptions, or manual approvals required. Supporting members include AWS, American Express, Google, Mastercard, Shopify, Solana Foundation, and Visa. The protocol is being positioned as the payment layer for the agentic economy.
- **Significance**: x402 addresses the critical "how do agents pay for things?" problem. By embedding payments at the HTTP level, MCP servers can charge per-invocation without requiring client authentication or billing agreements. This is the first major payment protocol specifically designed for AI agent commerce, and its backing by Visa, Mastercard, and Stripe signals financial industry buy-in. Direct relevance to our Phase 7 AaaS billing model.
- **Source**: https://www.prnewswire.com/news-releases/linux-foundation-is-launching-the-x402-foundation-and-welcoming-the-contribution-of-the-x402-protocol-302732803.html, https://zuplo.com/blog/mcp-api-payments-with-x402

### 2026-04-03 -- MCP Dev Summit North America 2026 Underway in NYC
- **What**: The Agentic AI Foundation's MCP Dev Summit North America is taking place April 2-3, 2026 in New York City, with 95+ sessions from MCP co-founders, maintainers, and production users. Notable sessions include conformance testing by Anthropic's Paul Carleton, security mix-up attack research by Microsoft's Emily Lauber, scalability lessons from Datadog, and an 18-month retrospective from Hugging Face. Sponsors include AWS, Docker, Google Cloud, and IBM.
- **Significance**: First major in-person MCP summit under AAIF governance. Session topics (conformance testing, security attacks, production scaling) reflect MCP is firmly in the "production hardening" phase.
- **Source**: https://www.linuxfoundation.org/press/agentic-ai-foundation-unveils-mcp-dev-summit-north-america-2026-schedule

### 2026-04-03 -- Pinterest Deploys Production-Scale MCP Ecosystem
- **What**: Pinterest engineering deployed a production MCP ecosystem with domain-specific MCP servers (Presto, Spark, Airflow), a central server registry with UI/API discovery, and agent integration via chat platforms and IDEs. The system handles 66,000 invocations/month across 844 active users and saves ~7,000 hours/month. Two-layer authorization with end-user JWTs and mesh identities, plus human-in-the-loop approval for sensitive operations.
- **Significance**: One of the most detailed public case studies of enterprise-scale MCP deployment. Demonstrates domain-specific server pattern is the winning architecture. The 7,000 hours/month savings provides concrete ROI evidence.
- **Source**: https://www.infoq.com/news/2026/04/pinterest-mcp-ecosystem/

### 2026-04-03 -- Security SEPs in Progress: DPoP and Workload Identity Federation
- **What**: Two security-focused SEPs under active development: SEP-1932 (DPoP — Demonstration of Proof-of-Possession) and SEP-1933 (Workload Identity Federation). Listed on the roadmap's "On the Horizon" section alongside finer-grained least-privilege scopes and OAuth mix-up attack mitigations.
- **Significance**: DPoP prevents token theft/replay by binding tokens to specific client key pairs. Workload Identity Federation enables machine-to-machine auth without static secrets, aligning MCP with zero-trust security models.
- **Source**: https://modelcontextprotocol.io/development/roadmap

### 2026-04-03 -- Red Hat Releases MCP Server for RHEL (Developer Preview)
- **What**: Red Hat released a developer preview MCP server for RHEL enabling LLMs to perform intelligent log analysis and performance analysis on RHEL systems. Uses SSH key authentication, configurable allowlists, read-only access with pre-vetted commands only. Compatible with Claude Desktop and Goose.
- **Significance**: Red Hat entering the MCP server ecosystem validates MCP as the standard for infrastructure-AI integration. This is Red Hat's third MCP server (after Lightspeed and Satellite).
- **Source**: https://www.dbta.com/Editorial/News-Flashes/Red-Hat-Announces-Developer-Preview-for-New-MCP-Server-for-Red-Hat-Enterprise-Linux-173028.aspx

### 2026-04-03 -- Tasks Primitive (SEP-1686) Enters Production Hardening
- **What**: The Tasks primitive ("call-now / fetch-later" for agent communication) has completed experimental deployment and is now in production hardening. The Agents Working Group is addressing: retry semantics for transient failures, expiry policies (how long results are retained), and collecting operational issues from production deployments.
- **Significance**: Tasks is the key primitive enabling MCP to support agent-to-agent communication, not just agent-to-tool. Will likely land in the June 2026 spec release, positioning MCP to compete with Google's A2A protocol on agent coordination.
- **Source**: https://modelcontextprotocol.io/development/roadmap

### 2026-04-02 -- Authorization Spec Draft: OAuth 2.1, CIMD, and Step-Up Auth
- **What**: The MCP authorization draft specification now defines a comprehensive OAuth 2.1-based authorization framework for HTTP-based transports. Key additions since the Nov 2025 spec include: (1) Client ID Metadata Documents (CIMD) as the preferred client registration approach when client and server have no prior relationship, (2) Dynamic Client Registration (DCR, RFC 7591) as a backwards-compatible fallback, (3) OAuth 2.0 Protected Resource Metadata (RFC 9728) as mandatory for MCP servers to advertise authorization server locations, (4) Resource Indicators (RFC 8707) as mandatory for token audience binding, (5) Step-up authorization flow for incremental scope escalation at runtime, (6) Authorization extensions as a modular, independently-versioned mechanism (hosted at github.com/modelcontextprotocol/ext-auth).
- **Significance**: This is the most detailed auth specification MCP has produced. CIMD solves the bootstrapping problem (how do clients register with servers they have never met) without requiring pre-registration or a centralized registry. The step-up auth flow allows progressive privilege escalation, reducing initial consent friction. The explicit prohibition of token passthrough and mandatory audience validation address the confused deputy problem that plagued early MCP proxy deployments.
- **Source**: https://modelcontextprotocol.io/specification/draft/basic/authorization

### 2026-04-02 -- 2026 Roadmap Deep Dive: Four Priority Areas
- **What**: Updated detail on the 2026 roadmap's four pillars: (1) Transport Evolution -- `.well-known` metadata for capability discovery, stateless horizontal scaling, no new transports planned; (2) Agent Communication -- Tasks primitive (SEP-1686) getting retry semantics and expiry policies; (3) Governance -- contributor ladder, Working Group autonomy for domain-specific SEP acceptance; (4) Enterprise Readiness -- audit trails, SSO, gateway behavior, config portability, implemented as extensions not core spec changes.
- **Significance**: The governance shift is strategically important: delegating SEP acceptance to trusted Working Groups removes the Core Maintainer bottleneck. The enterprise features being extensions (not core) preserves protocol simplicity while enabling production deployment. SEP-1686 (Tasks) is the foundation for agent-to-agent delegation within MCP, positioning it closer to A2A territory.
- **Source**: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/

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

### Authorization Framework (Draft Spec, as of 2026-04-02)

**Standards stack:**
- OAuth 2.1 (draft-ietf-oauth-v2-1-13)
- OAuth 2.0 Authorization Server Metadata (RFC 8414)
- OAuth 2.0 Dynamic Client Registration (RFC 7591)
- OAuth 2.0 Protected Resource Metadata (RFC 9728)
- OAuth Client ID Metadata Documents (draft-ietf-oauth-client-id-metadata-document-00)
- OAuth 2.0 Resource Indicators (RFC 8707)

**Client registration priority order:**
1. Pre-registered credentials (if available)
2. Client ID Metadata Documents (CIMD) -- preferred for unknown client-server pairs
3. Dynamic Client Registration (DCR) -- backwards-compatible fallback
4. User-entered credentials -- last resort

**Key auth flow:**
1. Client sends unauthenticated request to MCP server
2. Server returns 401 with `WWW-Authenticate` header containing `resource_metadata` URL
3. Client fetches Protected Resource Metadata (RFC 9728) to discover authorization server(s)
4. Client discovers authorization server metadata via RFC 8414 or OpenID Connect Discovery
5. Client registers (via CIMD, DCR, or pre-registration)
6. Standard OAuth 2.1 authorization code flow with PKCE (S256 mandatory)
7. Token includes `resource` parameter (RFC 8707) for audience binding
8. Bearer token sent in `Authorization` header on every HTTP request

**Step-up authorization:**
- If server returns 403 with `error="insufficient_scope"`, client computes union of previously requested scopes + new required scopes, then re-authorizes
- Prevents losing previously granted permissions during scope escalation

**Security requirements:**
- PKCE mandatory (S256 method required)
- Resource Indicators mandatory (prevents token audience confusion)
- Token passthrough explicitly forbidden (confused deputy mitigation)
- All auth endpoints must use HTTPS
- Refresh token rotation required for public clients

### Upcoming Features (2026 Roadmap)
- **MCP Server Cards**: Structured metadata at `/.well-known/mcp.json` for capability discovery without live connection
- **Agent Communication**: Building on experimental Tasks primitive; adding retry semantics and expiry policies
- **Governance**: Contributor ladder, delegation model, Working Group autonomy
- **Enterprise**: Audit trails, SSO authentication, gateway behavior, configuration portability
- **On the Horizon**: Triggers, event-driven updates, streamed result types, security enhancements
- **Auth Extensions**: Modular, independently-versioned at github.com/modelcontextprotocol/ext-auth

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
- **Auth convergence**: Both protocols now lean on OAuth 2.1 for authorization; MCP's CIMD approach and A2A's agent cards solve analogous discovery problems from different angles
