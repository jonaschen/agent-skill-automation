# MCP vs A2A Interoperability

**Last updated**: 2026-04-02
**Sources**:
- https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li
- https://toolradar.com/blog/mcp-vs-a2a
- https://www.theregister.com/2026/01/30/agnetic_ai_protocols_mcp_utcp_a2a_etc/
- https://lfaidata.foundation/communityblog/2025/08/29/acp-joins-forces-with-a2a-under-the-linux-foundations-lf-ai-data/
- https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation
- https://www.solo.io/blog/aaif-announcement-agentgateway
- https://arxiv.org/html/2505.02279v1

## Overview

MCP (Model Context Protocol) and A2A (Agent-to-Agent Protocol) are complementary, not competing, standards that occupy different layers of the agentic AI stack. MCP, created by Anthropic, standardizes how an agent connects to tools, data sources, and APIs. A2A, created by Google, standardizes how agents discover, communicate, and delegate tasks to each other. Both are now governed by the Linux Foundation's Agentic AI Foundation (AAIF), which was launched in December 2025.

## Key Developments (reverse chronological)

### 2026-04-02 — Three-Layer Protocol Stack Becomes Consensus Architecture
- **What**: The emerging consensus architecture for agentic AI uses three protocol layers: WebMCP (agent-to-web), MCP (agent-to-tool), and A2A (agent-to-agent). Additional protocols have emerged for specific domains, including Google's Universal Commerce Protocol (UCP) for business transactions, Agent Payments Protocol (AP2) for purchases, and A2UI/AG-UI for agent-to-user interfaces.
- **Significance**: The protocol landscape is consolidating around complementary layers rather than competing standards. MCP is the de facto standard for tool access ("the USB-C of agentic systems"), while A2A handles multi-agent orchestration.
- **Source**: https://www.theregister.com/2026/01/30/agnetic_ai_protocols_mcp_utcp_a2a_etc/

### 2026-04-02 — MCP Reaches 97 Million Monthly SDK Downloads
- **What**: By February 2026, MCP crossed 97 million monthly SDK downloads (Python + TypeScript combined) and has been adopted by every major AI provider: Anthropic, OpenAI, Google, Microsoft, and Amazon. The ecosystem includes 5,800+ public MCP servers with official integrations for GitHub, Slack, PostgreSQL, Google Drive, Stripe, AWS, Jira, Linear, and Notion.
- **Significance**: MCP has achieved dominant market adoption as the tool-access standard. No competing tool-access protocol has comparable traction.
- **Source**: https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li

### 2026-04-02 — A2A Reaches v1.0 With gRPC and Signed Agent Cards
- **What**: A2A v1.0 shipped in early 2026 with support for gRPC transport, signed Agent Cards for discovery, and multi-tenancy.
- **Significance**: A2A has matured from a draft spec to a production-ready protocol. Agent Cards (JSON manifests at `/.well-known/agent-card.json`) enable automatic agent discovery.
- **Source**: https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li

### 2026-04-02 — AAIF Membership Reaches 146 Organizations
- **What**: As of March 2026, the Agentic AI Foundation has 146 members across three tiers. Platinum members include AWS, Anthropic, Block, Bloomberg, Cloudflare, Google, Microsoft, and OpenAI. Gold members include IBM, Salesforce, SAP, Shopify, Snowflake, Docker, JetBrains, Oracle, JPMorgan Chase, and American Express. Silver members include Zapier, Hugging Face, Uber, Pydantic, WorkOS, and dozens more.
- **Significance**: Industry-wide buy-in from both tech companies and enterprises signals that these protocols will become the durable standards.
- **Source**: https://www.solo.io/blog/aaif-announcement-agentgateway

### 2025-12-09 — Linux Foundation Launches Agentic AI Foundation (AAIF)
- **What**: The Linux Foundation announced AAIF, co-founded by OpenAI, Anthropic, Google, Microsoft, AWS, and Block. Founding project contributions included Anthropic's MCP, Block's goose, and OpenAI's AGENTS.md.
- **Significance**: Both MCP and A2A now live under vendor-neutral governance, eliminating the risk of single-vendor lock-in and enabling coordinated evolution.
- **Source**: https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation

### 2025-08-29 — IBM's ACP Merges Into A2A
- **What**: IBM's Agent Communication Protocol (ACP), originally built for its BeeAI Platform, formally merged into A2A under the Linux Foundation.
- **Significance**: Protocol consolidation reduced fragmentation. ACP's streaming and human-in-the-loop features were folded into the A2A spec.
- **Source**: https://lfaidata.foundation/communityblog/2025/08/29/acp-joins-forces-with-a2a-under-the-linux-foundations-lf-ai-data/

### 2025-06 — Google Donates A2A to Linux Foundation
- **What**: Google contributed A2A to the Linux Foundation, moving it from a Google-controlled project to open governance.
- **Significance**: Opened the door for broader industry participation and eventual merger with ACP.
- **Source**: https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li

### 2025-04 — Google Creates A2A Protocol
- **What**: Google launched the Agent-to-Agent protocol to standardize discovery and communication between autonomous AI agents.
- **Significance**: Filled the gap that MCP did not address -- agent-to-agent coordination and task delegation.
- **Source**: https://dev.to/pockit_tools/mcp-vs-a2a-the-complete-guide-to-ai-agent-protocols-in-2026-30li

## Technical Details

### MCP Architecture
- **Transport**: Client-server using JSON-RPC 2.0 over three transports: stdio (local/desktop), SSE (HTTP streaming), and Streamable HTTP (bidirectional production APIs)
- **Capability types**: Resources (read-only data), Tools (executable actions), Prompts (reusable templates), Sampling (reverse LLM requests)
- **Security concerns**: Known vulnerabilities including remote code execution risks from code interpreter wrappers; prompt injection via tool responses

### A2A Architecture
- **Transport**: Client-remote HTTP/JSON with Server-Sent Events for real-time task updates; v1.0 adds gRPC
- **Discovery**: Agent Cards -- JSON manifests at `/.well-known/agent-card.json` describing agent capabilities
- **Task lifecycle states**: submitted, working, input-required, completed, failed, canceled
- **Features absorbed from ACP**: Streaming support, human-in-the-loop patterns

### Other Protocols in the Landscape
| Protocol | Layer | Creator | Status |
|----------|-------|---------|--------|
| **UTCP** (Universal Tool Calling Protocol) | Agent-to-tool | Independent | Niche; simpler than MCP but low adoption |
| **ANP** (Agent Network Protocol) | Agent-to-agent (P2P) | Independent | Focuses on "internet of agents" concept |
| **NLIP** (Natural Language Interaction Protocol) | Agent-to-agent | Ecma International | Immature; uses natural language for exchange |
| **A2UI** | Agent-to-user | Google | Preview; generates dynamic UIs via Flutter/React |
| **AG-UI** | Agent-to-frontend | CopilotKit | Lower-level agent-to-frontend communication |
| **UCP** (Universal Commerce Protocol) | Agent-to-business | Google | New; standardizes commerce interactions |
| **AP2** (Agent Payments Protocol) | Payments | Independent | Works with A2A/MCP for agent purchases |

## Comparison Notes

### Anthropic (MCP) vs Google (A2A)
- **Not competing**: MCP and A2A address different layers. MCP gives agents "hands" (tool access); A2A gives agents the ability to "work as a team" (coordination).
- **Adoption asymmetry**: MCP has far greater adoption (97M monthly downloads) because tool access is a prerequisite -- every agent needs it. A2A adoption is growing but multi-agent orchestration is a more advanced use case.
- **Governance convergence**: Both protocols are now under AAIF with identical governance. Neither Anthropic nor Google solely controls the specs.
- **Practical rule**: You need MCP first. An agent that can coordinate via A2A but has no tool access via MCP is useless. The reverse (MCP without A2A) still produces a functional single-agent system.
- **Strategic positioning**: Anthropic established the foundational layer (tool access) while Google captured the coordination layer (agent-to-agent). Both companies benefit from each other's protocol succeeding.
