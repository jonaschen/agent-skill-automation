# Tool Use and Function Calling

**Last updated**: 2026-04-17
**Sources**:
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling
- https://www.anthropic.com/engineering/advanced-tool-use
- https://platform.claude.com/docs/en/build-with-claude/structured-outputs
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use
- https://platform.claude.com/docs/en/agent-sdk/structured-outputs
- https://releasebot.io/updates/anthropic

## Overview

Claude's tool use system allows the model to invoke external functions by returning structured tool call requests that the application executes. Recent advances include three beta features (Tool Search Tool, Programmatic Tool Calling, Tool Use Examples) announced November 24, 2025, plus a Tool Runner in the Python/TypeScript/Ruby SDKs. These features dramatically improve scalability (hundreds of tools without context bloat), efficiency (37% token reduction), and accuracy (72% to 90% on complex parameter handling).

## Key Developments (reverse chronological)

### 2026-04-17 -- Programmatic Tool Calling Now GA on Claude Opus 4.7 via `code_execution_20260120`; Docs Confirm 5-Model Compatibility
- **What**: Confirmed via updated docs following the Opus 4.7 launch (April 16): **Programmatic Tool Calling** via the `code_execution_20260120` tool type is now generally available on **five models**: Claude Opus 4.7 (`claude-opus-4-7`), Opus 4.6 (`claude-opus-4-6`), Sonnet 4.6 (`claude-sonnet-4-6`), Opus 4.5 (`claude-opus-4-5-20251101`), and Sonnet 4.5 (`claude-sonnet-4-5-20250929`). Available via Claude API and Microsoft Foundry. Bedrock and Vertex still require a beta header. **Constraints confirmed**: (1) `strict: true` tools are incompatible with programmatic calling; (2) `tool_choice` cannot force programmatic calling of a specific tool; (3) `disable_parallel_tool_use: true` is unsupported with programmatic calling; (4) MCP connector tools still cannot be called programmatically (future work); (5) Message formatting: when responding to pending programmatic tool calls, the user message must contain **only** `tool_result` blocks — no text content. **Container semantics unchanged**: 30-day max lifetime, 4.5-minute idle timeout; container ID returned via `container` field; pass the ID to maintain state across requests. **Token accounting**: tool results from programmatic invocations do NOT count toward input/output token usage — only the final code execution result + Claude's response count. **Data retention**: NOT eligible for Zero Data Retention (ZDR); containers retained up to 30 days. **New benchmark insight**: BrowseComp and DeepSearchQA results show programmatic tool calling was the key factor that fully unlocked agent performance on multi-step web research and complex information retrieval — not just an efficiency win.
- **Significance**: Opus 4.7 adoption for our pipeline now comes with full programmatic tool calling by default. This removes the gate on upgrading our optimizer/validator agents to 4.7. **Key action item**: our `meta-agent-factory` could benefit from programmatic tool calling when generating SKILL.md plus auxiliary artifacts (scripts, references, tests) — currently each artifact takes a round trip; programmatic calling could collapse this to one code execution. Also: for our `agentic-ai-researcher` sweeps, using programmatic tool calling to batch WebSearch → WebFetch chains would dramatically cut token consumption on large research passes (10× reduction claimed). **Constraint to watch**: MCP tools still cannot be called programmatically. Our pipeline's MCP-heavy skills cannot fully benefit from this pattern yet. For Phase 7 enterprise: note the ZDR-ineligibility flag — must be disclosed to any customer with strict data residency requirements.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling, https://www.anthropic.com/engineering/advanced-tool-use

### 2026-04-16 -- Tool Use: No New API Changes; Cowork Adds Computer Use Access for Pro/Max; Claude for Office Add-ins Updated
- **What**: No new tool use API changes since the Advisor Tool launch (April 9). Platform-level additions relevant to tool use: **(1) Computer Use in Cowork (Pro/Max)** — users on Pro and Max plans can now give Claude access to computer use directly from Cowork without any setup — Claude can open files, run dev tools, point, click, and navigate the screen. This is the consumer/Cowork surface; the `computer_20251124` API tool remains research preview. **(2) Persistent agent thread (Pro/Max)** — Cowork persistent thread for managing long-running tasks from mobile and desktop (Claude Desktop, iOS, Android). **(3) Claude for Excel/PowerPoint add-ins** — full context sharing between Excel and PowerPoint add-ins; Skills support added; LLM gateway support added (AWS Bedrock, Google Cloud Vertex AI, Microsoft Foundry). **(4) Strict tool use confirmed GA** — `strict: true` ensures tool calls always match schema exactly; incompatible with programmatic calling. **(5) Fine-grained tool streaming** confirmed GA for Sonnet 4.5, Haiku 4.5, Sonnet 4, Opus 4 — stream tool parameters without buffering or JSON validation. **(6) Programmatic Tool Calling** remains GA with unchanged semantics: `allowed_callers: ["code_execution_20260120"]`, 30-day container max, 4.5-minute idle timeout. MCP tools still cannot be called programmatically.
- **Significance**: The Cowork + Computer Use integration (Pro/Max) confirms that computer use is being bundled into the premium tier consumer experience, not the API. This is Anthropic's strategy: consumer computer use → Cowork; developer automation → Managed Agents (without computer use yet). The Office add-in LLM gateway support (Bedrock/Vertex/Foundry) enables enterprise Anthropic deployments without direct API key use — relevant for Phase 7 enterprise customer segments. The tool use surface itself is fully mature; no action items for our pipeline.
- **Source**: https://releasebot.io/updates/anthropic/claude, https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2026-04-12 -- Tool Use: No New API Changes; Programmatic Tool Calling Docs Confirmed GA; Context Management Beta Active
- **What**: No new tool use API changes since the Advisor Tool launch on April 9. The complete GA tool stack remains: (1) **Programmatic Tool Calling** (GA) — `allowed_callers: ["code_execution_20260120"]` enables tools to be invoked from within code execution containers, reducing latency and token consumption for multi-tool workflows. Claude writes Python code that calls tools as async functions; intermediate results don't enter the context window. Token savings: tool results from programmatic calls are NOT counted toward input/output token usage — only the final code execution result counts. Key patterns: batch processing with loops, early termination, conditional tool selection, data filtering. (2) **Strict tool use** (`strict: true`) — schema-exact tool calls, incompatible with programmatic calling. (3) **Tool Search Tool** (GA) — dynamic tool discovery for large tool sets. (4) **Fine-grained tool streaming** (GA) — stream tool parameters without JSON validation buffering. (5) **Automatic tool call clearing** (beta) — `context-management-2025-06-27` header, auto-clears old tool results approaching token limits. (6) **Advisor Tool** (beta) — `advisor-tool-2026-03-01` header for inline model pairing. (7) Server tools: web_search, code_execution, web_fetch, tool_search. (8) Message Batches API: 300K output tokens via `output-300k-2026-03-24` header. No changes to `caller` field semantics or `allowed_callers` options. MCP tools still cannot be called programmatically (noted as future work). Container lifecycle: 30-day max, 4.5-minute idle timeout.
- **Significance**: Tool use is fully stabilized. The programmatic tool calling documentation confirms significant token efficiency gains — for multi-tool workflows, this can reduce token consumption by 10x compared to direct tool calls. The incompatibility between `strict: true` and programmatic calling is a design constraint to be aware of. No action items for our pipeline — tool use surface is mature.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling, https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2026-04-11 -- Advisor Tool Launched in Public Beta: Executor+Advisor Model Pairing for Agentic Workloads
- **What**: **MAJOR NEW FEATURE** — On April 9, Anthropic launched the **Advisor Tool** (`advisor_20260301`) in public beta. This is a fundamentally new tool use pattern: a faster, cheaper **executor model** (Haiku 4.5, Sonnet 4.6, or Opus 4.6) can consult a higher-intelligence **advisor model** (Opus 4.6) mid-generation for strategic guidance. The advisor reads the executor's full transcript and returns advice (typically 400-700 text tokens, 1,400-1,800 total with thinking), then the executor continues. Key technical details: (1) **API shape**: add `{"type": "advisor_20260301", "name": "advisor", "model": "claude-opus-4-6"}` to the `tools` array. Beta header: `advisor-tool-2026-03-01`. (2) **Runs as server-side sub-inference** within a single `/v1/messages` request — no extra round trips. The executor decides when to call the advisor, just like any other tool. (3) **Billing**: separate `usage.iterations[]` array with `type: "advisor_message"` entries billed at the advisor model's rates. Top-level usage reflects executor tokens only. (4) **Caching**: optional advisor-side prompt caching (`caching: {"type": "ephemeral", "ttl": "5m" | "1h"}`) — breaks even at ~3 advisor calls per conversation. (5) **Error handling**: graceful degradation with error codes (`max_uses_exceeded`, `too_many_requests`, `overloaded`, `prompt_too_long`, `execution_time_exceeded`, `unavailable`). (6) **Streaming**: executor stream pauses while advisor runs; result arrives in single `content_block_start` event. (7) **Composable**: works alongside web search, code execution, custom tools in same `tools` array. (8) **Model pairs**: Haiku→Opus, Sonnet→Opus, Opus→Opus are valid; advisor must be ≥ executor capability. (9) **max_uses** parameter caps advisor calls per request; no built-in conversation-level cap (track client-side). (10) **Recommended prompting pattern**: call advisor before substantive work (not orientation), when stuck, and before declaring done. On internal coding evaluations, advisor + Sonnet achieved near-Opus quality at Sonnet cost.
- **Significance**: The Advisor Tool is the most significant tool use innovation since Agent Skills (October 2025). It creates a new cost-quality tradeoff dimension: instead of choosing one model, you get advisor-quality planning with executor-speed generation. For our pipeline: (1) Phase 3 autoresearch-optimizer could use Sonnet+Opus advisor for cheaper iterations with near-Opus quality. (2) Phase 5 multi-agent topology could use advisor pattern instead of separate planner agent. (3) The `usage.iterations[]` billing breakdown is a model for our Phase 7 outcome-based billing. This is architecturally distinct from the three-agent harness — it's a tool-level primitive, not an orchestration pattern.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-10 -- Tool Input Validation Fix for Streaming; Message Batches 300K Output; No New Tool APIs
- **What**: (1) **Streaming tool input validation fix**: Anthropic fixed tool input validation failures when streaming emits array/object fields as JSON-encoded strings — this affected tools with complex nested schemas during streaming. (2) **Message Batches API 300K max_tokens** (announced March 30, confirmed active): `output-300k-2026-03-24` beta header enables 300K output tokens for Opus 4.6 and Sonnet 4.6 in batch processing — useful for large code generation and structured data extraction via tool use. (3) No new tool use API surfaces or features. The complete GA tool stack remains: Tool Search, Programmatic Tool Calling, Tool Use Examples, web search/fetch, code execution v2, memory tool, fine-grained tool streaming. Context editing remains the only beta. (4) Managed Agents tool execution (server-side) continues as the alternative to client-side tool orchestration.
- **Significance**: The streaming tool input validation fix is important for production tool use with complex schemas — streaming tool calls with nested arrays/objects were silently producing invalid inputs. No new features to track. Tool use is fully stabilized.
- **Source**: https://releasebot.io/updates/anthropic, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-09 -- Managed Agents Introduces Hosted Tool Execution; No New API Tool Use Changes
- **What**: No new tool use API changes since the February 17 GA graduation. However, Claude Managed Agents (launched April 8) introduces a new execution context for tool use: built-in tools (Bash, file ops, web search/fetch, MCP) run inside managed containers rather than locally. This is the first Anthropic product where tool execution is fully server-side rather than client-orchestrated. The tool result persistence override (`_meta["anthropic/maxResultSizeChars"]` up to 500K, from Claude Code v2.1.91) also applies in Managed Agents sessions. The `strict: true` option on tool definitions (ensuring schema-exact tool calls) remains available. All advanced tool features (Tool Search, Programmatic Calling, Examples, Dynamic Filtering) remain GA with no beta headers required.
- **Significance**: Managed Agents creates a bifurcation in tool use patterns: client-side (Messages API + Agent SDK) vs server-side (Managed Agents). For developers, the choice is now: custom tool execution with full control (SDK) vs managed tool execution with zero infrastructure (Managed Agents). No changes to the tool use API surface itself.
- **Source**: https://platform.claude.com/docs/en/managed-agents/tools, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-08 -- No New Tool Use Developments; Stabilization Continues
- **What**: No new tool use features or API changes since the February 17 GA graduation. Day 4 of broader platform stabilization. The complete tool use stack remains: Tool Search (dynamic discovery), Programmatic Tool Calling (code-orchestrated), Tool Use Examples (input_examples), web search/fetch (with dynamic filtering), code execution v2 (free with web tools), memory tool, fine-grained tool streaming — all GA, no beta headers required. Context editing remains the only beta feature in the tool use surface area.
- **Significance**: Tool use is fully stabilized. No action items.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-07 -- All Advanced Tool Use Features Now GA; Complete Feature Catalog Confirmed
- **What**: Comprehensive audit confirms all three advanced tool use features have graduated from beta to GA as of February 17, 2026 (Sonnet 4.6 launch): (1) **Tool Search Tool** — dynamic discovery, `defer_loading: true`, regex/BM25 search. 85% token reduction, Opus accuracy 49%→74%. No beta header required. (2) **Programmatic Tool Calling** — Claude orchestrates tools via Python code in sandboxed execution. `allowed_callers` on tools, `caller` field in requests. 37% token reduction. No beta header required. (3) **Tool Use Examples** — `input_examples` field in tool definitions. Accuracy 72%→90%. No beta header required. Additionally confirmed GA: web search tool, web fetch tool, memory tool, code execution tool (all Feb 17). Fine-grained tool streaming also GA (Feb 5). Context editing remains beta. Code execution is now **free when used with web search or web fetch**. Dynamic filtering (code execution pre-filters web results) shipped alongside. The API code execution sandbox is now v2 — Bash command execution and multi-language support, replacing Python-only v1.
- **Significance**: The full tool use stack is now production-ready without beta headers. The free code execution when paired with web tools creates a powerful zero-cost enhancement for research agents. The combination of tool search (context efficiency), programmatic calling (execution efficiency), and examples (accuracy) addresses the three fundamental bottlenecks of tool-using agents. No new tool use developments since February — Anthropic appears to be consolidating rather than adding new features.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview, https://www.anthropic.com/engineering/advanced-tool-use

### 2026-04-05 -- Web Search/Fetch Dynamic Filtering GA, Tool Input Streaming Fix
- **What**: Two tool-use related updates confirmed: (1) Web search and web fetch tools now support dynamic filtering — uses code execution to filter results before they reach the context window, reducing token costs and improving relevance. This graduated from beta to GA alongside tool streaming. (2) Claude Code v2.1.92 fixed tool input validation failures that occurred when streaming emitted array/object fields as JSON strings — a bug that could cause tool calls to fail silently during streamed responses with complex parameter types.
- **Significance**: Dynamic filtering for web tools is a significant efficiency improvement — agents performing research can now pre-filter results programmatically rather than consuming context with irrelevant content. The streaming JSON fix removes a reliability issue that affected agents using tools with array/object parameters in streaming mode.
- **Source**: https://releasebot.io/updates/anthropic, https://releasebot.io/updates/anthropic/claude-code

### 2026-04-04 -- Fine-Grained Tool Streaming Now GA
- **What**: Fine-grained tool streaming is now generally available on all models and platforms — no beta header required. This allows clients to receive partial tool call results as they are being generated by the model, enabling real-time UI updates during tool execution.
- **Significance**: Removes the last beta requirement for tool streaming, completing the GA graduation of core tool use features (tool search, programmatic calling, streaming, web search).
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-04 -- Context Editing Beta Launched
- **What**: Context editing launched in beta, providing strategies to automatically manage conversation context. The initial release supports clearing older tool results and calls when approaching token limits. This is distinct from the Compaction API — context editing selectively removes specific tool results rather than summarizing the full conversation.
- **Significance**: Addresses the growing problem of tool-heavy agent sessions where accumulated tool results consume the context window. Allows agents to remain productive in long sessions by shedding stale tool data while preserving conversation flow.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-04 -- Tool Helpers Beta for Python, TypeScript, and Ruby SDKs
- **What**: Tool helpers launched in beta across all three Anthropic SDKs. They simplify tool creation with type-safe input validation and provide a tool runner for automated tool handling in conversation loops. Reduces boilerplate for implementing the tool execution cycle.
- **Significance**: Lowers the barrier to building tool-using agents. Combined with the existing Tool Runner (also beta → GA path), the Anthropic SDKs now provide a complete, low-code tool integration experience.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-03 -- Tool Search Tool: Dynamic Discovery Across Thousands of Tools
- **What**: The Tool Search tool (beta since November 2025, now a GA server tool) allows Claude to discover and load tool definitions on demand. Tools marked with `defer_loading: true` are discoverable via search but not loaded into context until needed. Supports regex-based and BM25-based search plus custom embedding strategies. Benchmarks: Opus 4 accuracy improved from 49% to 74%, Opus 4.5 from 79.5% to 88.1% using tool search vs loading all tools. 85% token reduction.
- **Significance**: Solves the critical scaling problem of tool use -- context window bloat with hundreds/thousands of tools. Key differentiator from other LLM providers for enterprise integration scenarios.
- **Source**: https://www.anthropic.com/engineering/advanced-tool-use

### 2026-04-03 -- MCP Connector Tools Cannot Be Called Programmatically (Current Limitation)
- **What**: Tools provided by an MCP connector currently cannot be called programmatically from within code execution. The documentation notes this as a current restriction with "support may be added in future releases."
- **Significance**: Notable gap for MCP-heavy architectures. To get programmatic tool calling benefits (token savings, batch processing), tools must be defined as standard client tools rather than via MCP.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling

### 2026-04-03 -- Message Batches API max_tokens Raised to 300k (supplemental)
- **What**: The `max_tokens` cap raised to 300,000 tokens on Message Batches API for Opus 4.6 and Sonnet 4.6, via `output-300k-2026-03-24` beta header. 2.3x increase over the previous 128k limit.
- **Significance**: Enables much longer single-turn outputs for code generation, structured data extraction, and document processing in batch workflows. Combined with programmatic tool calling, allows batch jobs to produce substantially more complex outputs.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-02 -- Deep Dive: Programmatic Tool Calling Now GA on First-Party API
- **What**: Programmatic tool calling has graduated from beta to GA on the first-party Claude API (beta headers still required on Bedrock and Vertex AI only). The tool type version has been updated to `code_execution_20260120`, indicating a January 2026 refresh. Key API details confirmed:
  - `allowed_callers` field on tool definitions controls invocation context: `["direct"]` (default), `["code_execution_20260120"]`, or both
  - New `caller` field in `tool_use` response blocks indicates how a tool was invoked (direct vs programmatic, with `tool_id` back-reference)
  - Container lifecycle: 30-day max lifetime, 4.5-minute idle cleanup, reusable via `container` parameter
  - Tool results from programmatic calls do NOT count toward input/output token usage -- only the final code execution result and Claude's response count
  - Strict tool use (`strict: true`) is NOT compatible with programmatic calling
  - `disable_parallel_tool_use: true` is NOT supported with programmatic calling
  - MCP connector tools cannot currently be called programmatically
  - Tools are converted to async Python functions; Claude uses `await` for invocations
- **Significance**: This is a major efficiency unlock for production agents. Eliminates N model round-trips for N-tool workflows. The token savings compound: a 20-tool workflow that previously required 20+ inference passes and loaded all intermediate data into context now runs in a single code execution with only the final summary entering context.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling

### 2026-04-02 -- Structured Outputs GA with Schema Migration
- **What**: Structured outputs are now GA (no longer beta) for Claude Sonnet 4.5, Opus 4.5, and Haiku 4.5+. Key changes:
  - `output_format` parameter has moved to `output_config.format` (breaking change for existing integrations)
  - Beta header `structured-outputs-2025-11-13` still works during transition period but is no longer required
  - StructuredOutput schema cache bug causing ~50% failure rate with multiple schemas has been fixed
  - JSON schemas are cached for up to 24 hours for optimization; prompts/responses use Zero Data Retention
  - GA adds support for more complex schemas
- **Significance**: Structured outputs reaching GA removes a key reliability concern for production tool pipelines. The schema cache bug fix is particularly important for agents using multiple tools with strict schemas.
- **Source**: https://platform.claude.com/docs/en/build-with-claude/structured-outputs

### 2026-04-02 -- Strict Tool Use (`strict: true`)
- **What**: Adding `strict: true` to tool definitions guarantees that Claude's tool call inputs exactly match the provided JSON Schema. This is the tool-use equivalent of structured outputs.
- **Significance**: Eliminates runtime schema validation failures in production. Combined with structured outputs for final responses, agents can now guarantee schema conformance at both the tool-call and output layers.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2026-04-02 -- Server-Side Tools Ecosystem Expansion
- **What**: Anthropic now operates four server-side tools that execute on Anthropic infrastructure (no client-side execution needed):
  1. `web_search_20260209` -- web search
  2. `code_execution_20260120` -- sandboxed Python execution
  3. `web_fetch` -- URL content retrieval
  4. `tool_search` -- dynamic tool discovery
- **Significance**: Server tools eliminate the need for client-side infrastructure for common agent capabilities. The version dates (`20260209`, `20260120`) indicate active development with multiple updates in early 2026.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2026-04-02 -- Tool Use Token Overhead Standardized
- **What**: All Claude 4.x models (Opus 4.6, Opus 4.5, Opus 4.1, Opus 4, Sonnet 4.6, Sonnet 4.5, Sonnet 4, Haiku 4.5) now use a uniform 346 tokens for `auto`/`none` tool choice and 313 tokens for `any`/`tool` tool choice. This is a standardization from the variable overhead in Claude 3.x models.
- **Significance**: Predictable token costs for tool use across all current models simplifies cost estimation for production deployments.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2026-04-02 -- Message Batches API max_tokens Raised to 300k
- **What**: The Message Batches API `max_tokens` cap has been raised to 300,000 for Claude Opus 4.6 and Sonnet 4.6, enabling longer outputs for large code generation, structured data extraction, and bulk tool use workflows.
- **Significance**: Enables batch processing of large-scale tool use workflows without output truncation.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-02 -- Bug Fixes: Image Queuing + MCP SSE Reconnection
- **What**: Two reliability fixes:
  1. API 400 errors when pasted images were queued during failing tool calls -- fixed
  2. MCP tool calls hanging indefinitely when SSE connection drops mid-call and exhausts reconnection attempts -- fixed
- **Significance**: Both fixes improve reliability of tool-using agents in production, especially those using MCP and multimodal inputs.
- **Source**: https://releasebot.io/updates/anthropic

### 2025-11-24 -- Advanced Tool Use (Beta)
- **What**: Three new features released under beta header `advanced-tool-use-2025-11-20`:
  1. **Tool Search Tool**: Claude dynamically discovers tools without loading all definitions upfront. Mark tools with `defer_loading: true`; Claude loads only what it needs. 85% reduction in token usage. Opus 4 accuracy improved from 49% to 74%; Opus 4.5 from 79.5% to 88.1%.
  2. **Programmatic Tool Calling**: Claude orchestrates tools through code in a sandboxed execution environment instead of API round-trips. 37% token reduction on complex research tasks (43,588 to 27,297 tokens). Only final output enters context.
  3. **Tool Use Examples**: Concrete usage patterns in tool definitions demonstrating format conventions and parameter correlations. Improved accuracy from 72% to 90% on complex parameter handling.
- **Significance**: Solves the key scaling problem of tool use -- context window consumption with large tool libraries -- while also improving accuracy and reducing costs.
- **Source**: https://www.anthropic.com/engineering/advanced-tool-use

### 2025-11-24 -- Tool Runner (Beta)
- **What**: Out-of-the-box solution for executing tools with Claude, available in Python, TypeScript, and Ruby SDKs. Handles the tool execution loop automatically.
- **Significance**: Lowers the barrier to building tool-using agents by eliminating boilerplate tool loop code.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview

### 2025-01-01 -- Structured Outputs
- **What**: JSON outputs control that ensures Claude returns valid JSON matching a provided schema. Prevents malformed JSON responses and invalid tool inputs.
- **Significance**: Critical for production reliability -- eliminates parsing failures in tool pipelines.
- **Source**: https://platform.claude.com/docs/en/build-with-claude/structured-outputs

## Technical Details

### Tool Use Flow
1. Developer defines tools with names, descriptions, and JSON Schema input schemas
2. User prompt sent with tool definitions
3. Claude decides when to call a tool based on the request and tool description
4. Claude returns a `tool_use` content block with structured parameters
5. Application executes the tool and returns `tool_result`
6. Claude uses the result to formulate its response (or calls more tools)

### Tool Types
- **Client tools**: Application executes them locally (user-defined + Anthropic-schema tools like bash, text_editor)
- **Server tools**: Anthropic executes them (web_search, code_execution, web_fetch, tool_search)

### Tool Search Tool Details
```json
{
  "name": "search_api",
  "description": "Search for API endpoints",
  "defer_loading": true,
  "input_schema": { ... }
}
```
When `defer_loading: true`, the tool definition is not loaded into context until Claude actively searches for it. Enables working with hundreds or thousands of tools. Supports regex-based and BM25-based search implementations.

### Programmatic Tool Calling (GA on First-Party API)

**Core pattern**: Claude writes Python code that calls tools as async functions inside a sandboxed container. Only final output enters context.

**API surface**:
```json
{
  "tools": [
    {"type": "code_execution_20260120", "name": "code_execution"},
    {
      "name": "query_database",
      "description": "Execute SQL query",
      "input_schema": {"type": "object", "properties": {"sql": {"type": "string"}}, "required": ["sql"]},
      "allowed_callers": ["code_execution_20260120"]
    }
  ]
}
```

**Response includes `caller` field**:
```json
{
  "type": "tool_use",
  "id": "toolu_xyz789",
  "name": "query_database",
  "input": {"sql": "SELECT ..."},
  "caller": {
    "type": "code_execution_20260120",
    "tool_id": "srvtoolu_abc123"
  }
}
```

**Constraints**:
- `strict: true` incompatible with programmatic calling
- `disable_parallel_tool_use: true` not supported
- MCP connector tools cannot be called programmatically
- When responding to programmatic tool calls, messages must contain ONLY `tool_result` blocks (no text)

**Container lifecycle**: 30-day max, 4.5-min idle expiry, reusable via `container` parameter.

### Strict Tool Use
Add `strict: true` to any tool definition to guarantee schema conformance:
```json
{
  "name": "get_weather",
  "strict": true,
  "input_schema": {
    "type": "object",
    "properties": {"location": {"type": "string"}},
    "required": ["location"]
  }
}
```

### Structured Outputs (GA)
- Parameter: `output_config.format` (migrated from `output_format`)
- Supports `json_schema` format type
- Schema cached up to 24h; ZDR applies to prompts/responses
- Old beta header `structured-outputs-2025-11-13` still accepted during transition

### Tool Use Examples Format
Include examples directly in tool definitions to demonstrate:
- Format conventions (date formats, ID patterns)
- Parameter correlations (which params go together)
- Expected usage patterns

### Token Overhead (Standardized for Claude 4.x)
| Tool Choice | Tokens |
|------------|--------|
| `auto`, `none` | 346 |
| `any`, `tool` | 313 |

### Requirements
- Minimum model: Claude Sonnet 4.5 or later for advanced features
- Beta header: `advanced-tool-use-2025-11-20` (for tool search and examples)
- Programmatic tool calling: GA on first-party API, beta on Bedrock/Vertex
- Standard tool use available on all Claude 3+ models

## Comparison Notes

Claude tool use vs Google Gemini function calling:
- **Schema format**: Both use JSON Schema for tool definitions
- **Parallel calls**: Both support parallel function calling
- **Structured output**: Both offer JSON mode / structured output; Claude's `strict: true` guarantees schema conformance
- **Tool search**: Claude's Tool Search Tool is unique -- Gemini does not have an equivalent deferred loading mechanism
- **Programmatic calling**: Claude's sandboxed code execution for tool orchestration is unique; Google ADK uses a different agent-orchestrated approach
- **Server-side tools**: Claude has 4 built-in server tools; Gemini has Google Search, Code Execution built-in
- **Pricing**: Both charge standard input/output token rates for tool definitions and results; Claude's programmatic tool calls do NOT count toward token usage (only final output does)
- **Ecosystem**: Claude's MCP provides a standardized server protocol; Gemini relies on Vertex AI extensions, ADK, and function declarations
