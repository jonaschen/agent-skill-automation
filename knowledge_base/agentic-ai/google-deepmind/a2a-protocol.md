# Agent2Agent (A2A) Protocol

**Last updated**: 2026-04-07
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
- https://cloud.google.com/blog/products/ai-machine-learning/announcing-agents-to-payments-ap2-protocol
- https://github.com/google-agentic-commerce/AP2
- https://ap2-protocol.org/

## Overview

Agent2Agent (A2A) is an open protocol created by Google for enabling secure communication and collaboration between AI agents across different platforms, vendors, and frameworks. Launched in April 2025, it was donated to the Linux Foundation in June 2025 and has grown to over 150 supporting organizations. A2A is designed to complement (not compete with) Anthropic's Model Context Protocol (MCP), with MCP handling tool/context provision and A2A handling inter-agent communication.

## Key Developments (reverse chronological)

### 2026-04-07 -- A2A v1.0 Ecosystem Maturity: TSC Membership, 5-Language SDK Coverage, Progressive Migration Confirmed
- **What**: Consolidation of A2A v1.0 ecosystem details reveals production-ready maturity: (1) **Technical Steering Committee (TSC)** confirmed with representatives from **Google, AWS, Microsoft, IBM, Cisco, Salesforce, SAP, and ServiceNow** — the first multi-vendor governance body for an agent interoperability protocol. (2) **SDK availability in 5 languages**: Python, Go, JavaScript, Java, and .NET — covering all major enterprise language ecosystems. (3) **Progressive migration mechanism confirmed**: AgentCard has been evolved in a backward-compatible way allowing agents to advertise support for both v0.3 and v1.0 simultaneously, enabling **dual-protocol operation** during transition. Clients can migrate progressively rather than requiring a single-cutover migration. (4) **A2A Purchasing Concierge Codelab** published by Google (codelabs.developers.google.com) — hands-on tutorial demonstrating A2A agent interactions on Cloud Run and Agent Engine, covering remote seller agent → purchasing concierge workflow. (5) **IBM published an authoritative explainer** at ibm.com/think/topics/agent2agent-protocol, validating A2A as an industry standard. No new spec releases or breaking changes since v1.0.0 (Mar 12).
- **Significance**: The TSC composition is the strongest signal yet that A2A has achieved genuine multi-vendor commitment — all three hyperscalers (Google, AWS, Microsoft) plus four enterprise SaaS leaders (IBM, Cisco, Salesforce, SAP/ServiceNow). The 5-language SDK coverage means any enterprise team can implement A2A in their preferred stack. The dual-protocol AgentCard support addresses the biggest enterprise adoption blocker: migration risk. The Codelab publication signals Google wants hands-on developer adoption, not just specification readership. For our Phase 5 multi-agent topology, A2A is now production-viable across all dimensions: spec stability (v1.0), governance (TSC), tooling (5 SDKs), migration (progressive), and learning resources (Codelab).
- **Source**: https://onereach.ai/blog/what-is-a2a-agent-to-agent-protocol/, https://www.ibm.com/think/topics/agent2agent-protocol, https://codelabs.developers.google.com/intro-a2a-purchasing-concierge, https://a2a-protocol.org/latest/

### 2026-04-06 -- A2A v1.0.0 Deep Technical Analysis: Breaking Changes, Multi-Tenancy, and Migration Path
- **What**: Detailed analysis of the A2A v1.0.0 specification (released Mar 12, 2026) reveals extensive breaking changes and new enterprise capabilities beyond what was previously documented: (1) **Part Type Unification** (CRITICAL) — TextPart, FilePart, and DataPart merged into unified `Part` structure using `oneof content`. Removes `kind` discriminator field in favor of JSON member-based polymorphism. `mimeType` renamed to `mediaType`. (2) **Stream Event Pattern overhaul** — removes `kind` field from stream events, wraps in named objects (`{"taskStatusUpdate": {...}}`), eliminates `final` boolean in favor of protocol-binding stream closure, adds `index` field to artifact updates. (3) **Agent Card restructuring** — consolidates `preferredTransport` and `additionalInterfaces` into `supportedInterfaces[]` array, moves `protocolVersion` to individual `AgentInterface` objects, relocates `supportsAuthenticatedExtendedCard` to `capabilities.extendedAgentCard`. (4) **Enum value transformation** — all enums move from kebab-case to SCREAMING_SNAKE_CASE with prefixes (e.g., `"completed"` → `"TASK_STATE_COMPLETED"`, `"user"` → `"ROLE_USER"`). (5) **Error handling standardized** — shifts from RFC 9457 Problem Details to `google.rpc.Status` with `ErrorInfo` details using `domain: "a2a-protocol.org"`. (6) **Cursor-based pagination** replaces page-based; introduces `nextCursor` field. (7) **Native multi-tenancy** via `tenant` field in all request messages. (8) **Operation renames**: `message/send` → `SendMessage`, `message/stream` → `SendStreamingMessage`, `tasks/get` → `GetTask`, etc. (9) **OAuth 2.0 modernization**: adds Device Code flow (RFC 8628) for CLI/IoT, adds `pkce_required` for Authorization Code, removes implicit and password flows. (10) **Extension versioning**: messages and artifacts include `extensions[]` array with mandatory requirement flags. (11) **Formal dependencies**: RFC 8785 (JSON canonicalization), RFC 7515 (JWS), google.rpc.Status, ISO 8601 timestamps with millisecond precision. (12) **Recommended 3-phase migration**: compatibility layer → dual support → v1.0-only cutover.
- **Significance**: This is the most comprehensive A2A spec change since launch. The breaking changes are substantial enough that any existing v0.3 integration requires significant refactoring. The multi-tenancy support is critical for enterprise SaaS platforms hosting multiple agent instances. The OAuth modernization (removing implicit/password, adding Device Code + PKCE) brings A2A auth to current security standards. The formal migration path (3 phases) suggests Google expects a 3-6 month transition period. For our pipeline, the Part unification and enum changes would impact any future A2A integration — we should track this for Phase 5 multi-agent topology.
- **Source**: https://a2a-protocol.org/latest/whats-new-v1/, https://a2a-protocol.org/latest/specification/

### 2026-04-05 -- Agent Payment Protocol War: AP2 vs Visa TAP vs x402 vs PayPal Agent Ready
- **What**: Within 90 days of each other in early 2026, **every major payment platform** launched its own AI agent payment protocol, creating a multi-front "protocol war": (1) **Visa TAP** (Trusted Agent Protocol) — 100+ engaged partners, 30+ in sandbox, 20+ agent platforms integrating. Uses HTTP Message Signatures standard for cryptographically signed messages. Core innovation: Agent Identity Certificate. Builds on existing Visa card network. (2) **Google AP2** — 60+ orgs, mandate-based system (detailed in entry below). Payment-agnostic. (3) **Coinbase x402** — HTTP 402 status code embedded in web layer for automatic micropayments. Partners: Cloudflare, Circle, Stripe, AWS. Multi-chain stablecoin settlement. ~100M transactions, $28K daily volume. (4) **PayPal Agent Ready** — Protocol-agnostic approach that works across TAP, AP2, and x402. Leverages 400M existing accounts and built-in fraud detection/dispute resolution. The protocols are converging into a layered architecture: trust (TAP/AP2) → intent (AP2 mandates) → settlement (x402 for crypto, traditional rails for fiat). Gartner projects $11.79 billion dedicated market for autonomous AI agent software in 2026.
- **Significance**: The four-way protocol competition validates agent payments as a real market, not a speculative concept. The convergence pattern (layered rather than winner-take-all) suggests multiple protocols will coexist, with PayPal's protocol-agnostic approach potentially becoming the unification layer. For our Phase 7 AaaS billing, we should track all four protocols — AP2/x402 for the A2A/MCP ecosystem, but Visa TAP and PayPal Agent Ready may become dominant for enterprise commerce. The $11.79B market projection contextualizes the commercial opportunity.
- **Source**: https://blockeden.xyz/blog/2026/03/14/payment-giants-agent-protocol-war-visa-tap-google-ap2-coinbase-x402-paypal-ai-commerce/, https://www.hypertrends.com/2026/04/agentic-payments-x402-acp-ap2-tap-comparison/

### 2026-04-05 -- Agent Payments Protocol (AP2) Launched — Commerce Layer on A2A
- **What**: Google announced the **Agent Payments Protocol (AP2)** — an open protocol for secure, interoperable agent commerce built as a payments layer on top of A2A and MCP. Key details: (1) **Core mechanism: Mandates** — tamper-proof, cryptographically-signed digital contracts providing verifiable proof of user intent. Two mandate types: **Intent Mandate** (user's initial instruction to agent) and **Cart Mandate** (final approval once agent finds specific product/bundle). Mandates are signed by **Verifiable Digital Credentials (VDCs)** creating a non-repudiable audit trail. (2) **Payment-agnostic**: Supports traditional cards, bank transfers, alternative methods, and stablecoins/crypto via its **x402 extension**. (3) **60+ supporting organizations** including American Express, Coinbase, Etsy, Intuit, Mastercard, PayPal, Salesforce, ServiceNow. (4) **Open source**: Apache 2.0 license at github.com/google-agentic-commerce/AP2, version v0.1.0 (Sep 2025). Python and Android sample implementations using ADK + Gemini 2.5 Flash. (5) **Documentation site**: ap2-protocol.org. (6) **Companion**: PayPal and Google Cloud jointly announced an **agentic commerce solution for merchants** built on AP2.
- **Significance**: AP2 addresses a critical gap in the agent economy — how to verify that a user authorized an agent to make a purchase. Today's payment systems assume a human is clicking "buy"; AP2's mandate system creates a new trust layer for autonomous agent transactions. The 60+ organization coalition (including both Mastercard and Visa competitors) signals industry convergence on this approach. The x402 crypto extension shows forward-thinking about future payment rails. Together, A2A + MCP + AP2 form a three-layer protocol stack: A2A for agent communication, MCP for tool access, AP2 for payments.
- **Source**: https://cloud.google.com/blog/products/ai-machine-learning/announcing-agents-to-payments-ap2-protocol, https://github.com/google-agentic-commerce/AP2, https://ap2-protocol.org/

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
