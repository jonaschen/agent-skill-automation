# Gemini Agents

**Last updated**: 2026-04-03
**Sources**:
- https://developers.googleblog.com/new-gemini-api-updates-for-gemini-3/
- https://ai.google.dev/gemini-api/docs/function-calling
- https://ai.google.dev/gemini-api/docs/changelog
- https://developers.googleblog.com/building-agents-google-gemini-open-source-frameworks/
- https://blog.google/innovation-and-ai/technology/developers-tools/build-with-gemini-3-1-flash-live/
- https://developers.googleblog.com/building-agents-with-the-adk-and-the-new-interactions-api/
- https://blog.google/innovation-and-ai/technology/developers-tools/agentic-vision-gemini-3-flash/
- https://beam.ai/agentic-insights/geminis-january-2026-update-just-changed-how-people-buy-online
- https://ai.google.dev/gemini-api/docs/tools

## Overview

Gemini is Google's flagship multimodal model family, with Gemini 3 (released November 2025) representing the latest generation optimized for agentic workflows. The Gemini API supports advanced function calling, tool use, structured output, and multi-step reasoning -- making it a primary foundation for building AI agents in the Google ecosystem. Models range from lightweight Flash variants to the full Pro model, all accessible via the Gemini API and Vertex AI.

## Key Developments (reverse chronological)

### 2026-04-03 -- Agentic Vision in Gemini 3 Flash & Universal Commerce Protocol
- **What**: Two major agentic capabilities announced in early 2026: (1) **Agentic Vision** (Jan 27, 2026) — a new capability in Gemini 3 Flash that converts image understanding from a static act into an agentic process. Uses a **Think-Act-Observe loop**: Think (model analyzes query and image, formulates a multi-step plan), Act (generates and executes Python code to manipulate/analyze images), Observe (transformed image appended to context window for iterative refinement). (2) **Universal Commerce Protocol (UCP)** (Jan 11, 2026) — a new open standard for agentic commerce, pushing Gemini toward being an execution layer for shopping (discovery, buying, post-purchase). Includes a **Business Agent** feature (live Jan 12 with select retailers) letting shoppers chat with brands directly on Search as a virtual sales associate.
- **Significance**: Agentic Vision is architecturally novel — it gives vision models the ability to iteratively process images through code execution, similar to how tool-using agents solve multi-step problems. UCP positions Google as defining the standard for AI-mediated commerce, a major commercial moat. The Business Agent feature is the first large-scale deployment of brand-specific conversational agents in search results.
- **Source**: https://blog.google/innovation-and-ai/technology/developers-tools/agentic-vision-gemini-3-flash/, https://beam.ai/agentic-insights/geminis-january-2026-update-just-changed-how-people-buy-online

### 2026-04-02 -- Gemini 3.1 Series & Interactions API (sweep update)
- **What**: Rapid model releases in March-April 2026: Gemini 3.1 Pro Preview (Feb 19) with "powerful agentic and coding capabilities" plus a dedicated `gemini-3.1-pro-preview-customtools` endpoint; Gemini 3.1 Flash-Lite Preview (Mar 3) for efficiency; Built-in Tools & Function Calling integration (Mar 18) enabling combined built-in + custom tools in a single API call; Gemini 3.1 Flash Live Preview (Mar 26) for real-time voice/vision agents via the Live API; Flex and Priority Inference Tiers (Apr 1) for cost vs latency optimization. Additionally, the new **Interactions API** launched as a unified interface for stateful multi-turn AI workflows — a single gateway to both raw models and managed agents (like Gemini Deep Research Agent). Supports `previous_interaction_id` for server-side conversation history, background execution for long-running tasks, and native thought handling.
- **Significance**: The 3.1 series marks a rapid cadence of agentic improvements. The Interactions API is a major architectural shift — it replaces `generateContent` as the recommended inference endpoint for ADK agents and doubles as a transparent A2A bridge via `InteractionsApiTransport`. The customtools endpoint signals Google recognizes developers need optimized function calling without built-in tool interference.
- **Source**: https://ai.google.dev/gemini-api/docs/changelog, https://developers.googleblog.com/building-agents-with-the-adk-and-the-new-interactions-api/

### 2026-04-02 -- Gemini 3 Agentic Capabilities (surveyed)
- **What**: Gemini 3 Pro Preview and Flash Preview support Computer Use tool, enabling agents to interact with desktop environments. Deep Research Agent launched in preview for autonomous multi-step research. Built-in Tools and Function Calling Combination allows mixing Gemini built-in tools with custom function declarations in a single API call.
- **Significance**: Computer Use puts Gemini in direct competition with Anthropic's Computer Use feature. Deep Research Agent represents Google's push into fully autonomous agentic workflows.
- **Source**: https://ai.google.dev/gemini-api/docs/changelog

### 2025-11-25 -- Gemini 3 API Updates
- **What**: New `thinking_level` parameter controls reasoning depth (high/low). Thought signatures (encrypted reasoning representations) enforce chain-of-thought across conversations -- mandatory for function calling (400 error if missing), optional for text generation. New `media_resolution` parameter for granular token allocation on images/video/documents. Grounding with structured outputs enables combining Google Search grounding with JSON extraction.
- **Significance**: Thought signatures are critical for multi-step agentic workflows, ensuring reasoning continuity across conversation turns. The thinking_level parameter allows latency vs reasoning depth tradeoffs.
- **Source**: https://developers.googleblog.com/new-gemini-api-updates-for-gemini-3/

### 2025-05-20 -- Google I/O 2025 Agent Announcements
- **What**: Gemini positioned as foundation for agent development across open-source frameworks (LangGraph, CrewAI, LlamaIndex). ADK released alongside agent ecosystem tools.
- **Significance**: Google established Gemini as a model-agnostic agent foundation, not just for Google-proprietary tools.
- **Source**: https://developers.googleblog.com/building-agents-google-gemini-open-source-frameworks/

## Technical Details

### Function Calling Mechanism

Four-step process: (1) define function declarations using OpenAPI schema subset, (2) call API with declarations, (3) execute function code, (4) return results to model.

**Supported models**: Gemini 3.1 Pro Preview, Gemini 3.1 Flash Live Preview, Gemini 3.1 Flash-Lite Preview, Gemini 3 Flash Preview, Gemini 2.5 Pro/Flash/Flash-Lite, Gemini 2.0 Flash.

### Interactions API (new, 2026)

The Interactions API is Google's new unified interface for stateful, multi-turn AI workflows:
- **Single endpoint** for both raw models and managed agents (e.g., Deep Research Agent)
- **Server-side state**: Offload conversation history via `previous_interaction_id`
- **Background mode**: Long-running tasks with async polling
- **Native thought handling**: Reasoning chains modeled separately from responses
- **Two integration patterns**:
  1. **ADK Integration**: Use as inference engine for custom ADK agents (replaces `generateContent`)
  2. **Transparent A2A Bridge**: `InteractionsApiTransport` maps A2A protocol onto Interactions API, treating Google agents as standard remote A2A agents

**Calling modes**:
- `AUTO` (default): Model decides text vs function call
- `ANY`: Forces function call; can restrict via `allowed_function_names`
- `NONE`: Disables function calling
- `VALIDATED`: Ensures either function call or schema-adherent natural language

**Advanced features**:
- Parallel function calling with unique `id` tracking per call
- Compositional function calling (chaining outputs as inputs)
- Automatic function calling (Python SDK only -- converts Python functions to declarations)
- Multimodal function responses (Gemini 3): images and documents in function responses via MIME types

**Best practices**:
- Keep active tool sets to 10-20 max for reliability
- Use strong typing with enums for constrained values
- Default temperature 1.0 recommended for Gemini 3
- Always map function IDs in responses
- Validate consequential calls before execution

### Pricing
Grounding with Google Search: US$14 per 1,000 search queries (changed from flat US$35/1k prompts).

## Comparison Notes

**vs Anthropic Claude tool use**: Both use similar request-response patterns for function calling. Key differences:
- Gemini supports `VALIDATED` mode (no Anthropic equivalent)
- Gemini 3 requires thought signatures for function calling continuity; Claude uses standard conversation context
- Gemini has native Google Search grounding built in; Anthropic relies on MCP tools for search
- Gemini's `thinking_level` parameter is analogous to Claude's extended thinking feature
- Both support parallel tool use; Gemini adds compositional (chained) calling natively
- Gemini Computer Use is in preview; Anthropic Computer Use has been available since October 2024
