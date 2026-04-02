# Tool Use and Function Calling

**Last updated**: 2026-04-02
**Sources**:
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview
- https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling
- https://www.anthropic.com/engineering/advanced-tool-use
- https://platform.claude.com/docs/en/build-with-claude/structured-outputs

## Overview

Claude's tool use system allows the model to invoke external functions by returning structured tool call requests that the application executes. Recent advances include three beta features (Tool Search Tool, Programmatic Tool Calling, Tool Use Examples) announced November 24, 2025, plus a Tool Runner in the Python/TypeScript/Ruby SDKs. These features dramatically improve scalability (hundreds of tools without context bloat), efficiency (37% token reduction), and accuracy (72% to 90% on complex parameter handling).

## Key Developments (reverse chronological)

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
- **Client tools**: Application executes them locally
- **Server tools**: Anthropic executes them (e.g., web search, code execution)
- **Anthropic-schema tools**: Built-in tools like computer use, bash, text editor

### Tool Search Tool Details
```json
{
  "name": "search_api",
  "description": "Search for API endpoints",
  "defer_loading": true,
  "input_schema": { ... }
}
```
When `defer_loading: true`, the tool definition is not loaded into context until Claude actively searches for it. Enables working with hundreds or thousands of tools.

### Programmatic Tool Calling
Claude writes and executes code in a sandboxed environment to orchestrate multiple tool calls. Intermediate results are processed in the sandbox; only final output enters the context window. Real-world example: Claude for Excel uses this to manage spreadsheets with thousands of rows.

### Tool Use Examples Format
Include examples directly in tool definitions to demonstrate:
- Format conventions (date formats, ID patterns)
- Parameter correlations (which params go together)
- Expected usage patterns

### Requirements
- Minimum model: Claude Sonnet 4.5 or later for advanced features
- Beta header: `advanced-tool-use-2025-11-20`
- Standard tool use available on all Claude 3+ models

## Comparison Notes

Claude tool use vs Google Gemini function calling:
- **Schema format**: Both use JSON Schema for tool definitions
- **Parallel calls**: Both support parallel function calling
- **Structured output**: Both offer JSON mode / structured output
- **Tool search**: Claude's Tool Search Tool is unique -- Gemini does not have an equivalent deferred loading mechanism
- **Programmatic calling**: Claude's sandboxed code execution for tool orchestration is unique
- **Pricing**: Both charge standard input/output token rates for tool definitions and results
- **Ecosystem**: Claude's MCP provides a standardized server protocol; Gemini relies on Vertex AI extensions and function declarations
