# Gemini Agents

**Last updated**: 2026-04-02
**Sources**:
- https://developers.googleblog.com/new-gemini-api-updates-for-gemini-3/
- https://ai.google.dev/gemini-api/docs/function-calling
- https://ai.google.dev/gemini-api/docs/changelog
- https://developers.googleblog.com/building-agents-google-gemini-open-source-frameworks/

## Overview

Gemini is Google's flagship multimodal model family, with Gemini 3 (released November 2025) representing the latest generation optimized for agentic workflows. The Gemini API supports advanced function calling, tool use, structured output, and multi-step reasoning -- making it a primary foundation for building AI agents in the Google ecosystem. Models range from lightweight Flash variants to the full Pro model, all accessible via the Gemini API and Vertex AI.

## Key Developments (reverse chronological)

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

**Supported models**: Gemini 3.1 Pro Preview, Gemini 3 Flash Preview, Gemini 2.5 Pro/Flash/Flash-Lite, Gemini 2.0 Flash.

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
