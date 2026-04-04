# Gemini Agents

**Last updated**: 2026-04-05
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
- https://geminicli.com/docs/changelogs/preview/
- https://github.com/google-gemini/gemini-cli
- https://blog.google/innovation-and-ai/technology/developers-tools/gemini-api-docsmcp-agent-skills/
- https://geminicli.com/docs/cli/skills/
- https://geminicli.com/docs/core/subagents/
- https://findskill.ai/blog/gemini-api-pricing-guide/

## Overview

Gemini is Google's flagship multimodal model family, with Gemini 3 (released November 2025) representing the latest generation optimized for agentic workflows. The Gemini API supports advanced function calling, tool use, structured output, and multi-step reasoning -- making it a primary foundation for building AI agents in the Google ecosystem. Models range from lightweight Flash variants to the full Pro model, all accessible via the Gemini API and Vertex AI.

## Key Developments (reverse chronological)

### 2026-04-05 -- Gemini CLI v0.36.0 Stable, Gemini 3 Deep Think Science Upgrade, API Docs MCP + Agent Skills
- **What (new findings)**: (1) **Gemini CLI v0.36.0 stable** released April 1, 2026 (100+ PRs) with: multi-registry architecture for subagents, strict sandboxing for macOS (Seatbelt) and Windows (Mandatory Integrity Control), **git worktree support** for isolated parallel sessions, plan mode support in non-interactive environments, experimental **memory manager agent** replacing save_memory tool, AgentSession renamed from stream events to agent events, ACP SDK upgraded from 0.12 to 0.16.1, browser agent security hardened with sensitive action controls, content-utils module added. (2) **Gemini 3 Deep Think major upgrade** (Feb 12, updated Mar 19): Beyond mathematics and competitive coding, now excels across **broad scientific domains** — demonstrated **gold medal-level results** on the written sections of the 2025 International Physics Olympiad (IPhO) and International Chemistry Olympiad (IChO). Positioned for science, research, and engineering use cases.
- **Significance**: Gemini CLI v0.36.0 reaching stable with git worktree support is notable — this directly mirrors Claude Code's worktree-based agent isolation pattern, confirming architectural convergence. The experimental memory manager agent in Gemini CLI suggests Google is building persistent context into the CLI experience (cf. Conway's persistent memory). Gemini 3 Deep Think expanding into scientific reasoning opens new agentic use cases in research automation, lab analysis, and scientific workflow orchestration — capabilities Anthropic has not matched with a specialized reasoning mode.

### 2026-04-05 -- Gemini API Docs MCP, Agent Skills, Billing Caps, Gemini 3.1 Pro Preview, Gemini CLI Subagent Architecture
- **What**: Multiple significant developments confirmed in early April 2026: (1) **Gemini API Docs MCP + Agent Skills** (Apr 1) — Google released two complementary tools for coding agents: the **Gemini API Docs MCP** connects coding agents to real-time Gemini API documentation via MCP, and **Agent Skills** adds best-practice instructions and patterns. Combined, they achieve a **96.3% pass rate** on Google's eval set with **63% fewer tokens** per correct answer vs vanilla prompting. Setup at ai.google.dev/gemini-api/docs/coding-agents. (2) **Mandatory billing caps** (Apr 1) — Google enforced mandatory spending caps across all billing tiers, restricted Pro models behind a paywall for free users (free tier now Flash-only), and introduced prepaid billing for new accounts. (3) **Gemini 3.1 Pro Preview** available in Vertex AI Model Garden — most advanced reasoning Gemini model with 1M token context. A dedicated `gemini-3.1-pro-preview-customtools` endpoint prioritizes custom tools over built-in tools. (4) **Gemini 3.1 Flash-Lite Preview** launched as the first Flash-Lite model in the 3.1 series. (5) **Gemini CLI subagent architecture** now fully documented: 4 built-in subagents (`codebase_investigator`, `cli_help`, `generalist_agent`, `browser_agent`), custom subagents via `.gemini/agents/*.md` markdown files with YAML frontmatter, tool isolation via allowlists with wildcard support (`mcp_*`), recursion prevention (subagents cannot call other subagents), policy engine integration via `policy.toml`, and remote A2A subagent delegation. Agent Skills use progressive disclosure — only metadata loaded initially, full instructions injected on activation. Skills discovered from 3 tiers: workspace (`.gemini/skills/`), user (`~/.gemini/skills/`), extension. (6) **Gemini 2.5 model retirement extended** — Gemini 2.5 Pro, Flash-Lite, and Flash retirement dates pushed to October 16, 2026.
- **Significance**: The Docs MCP + Agent Skills combo is architecturally significant — it's Google's answer to the "stale training data" problem for coding agents, and the 96.3% eval pass rate validates the MCP-as-knowledge-source pattern. The billing changes signal Google monetizing the Gemini API more aggressively — free-tier restriction to Flash-only may push hobbyists to alternatives. The Gemini CLI's subagent architecture is now at feature parity with Claude Code's agent system — both support markdown-defined agents, tool isolation, MCP integration, and project config files. The convergence is remarkable: `.gemini/agents/*.md` mirrors `.claude/agents/*.md`, GEMINI.md mirrors CLAUDE.md, Agent Skills mirror Claude Code Skills.
- **Source**: https://blog.google/innovation-and-ai/technology/developers-tools/gemini-api-docsmcp-agent-skills/, https://geminicli.com/docs/core/subagents/, https://geminicli.com/docs/cli/skills/, https://ai.google.dev/gemini-api/docs/changelog, https://findskill.ai/blog/gemini-api-pricing-guide/

### 2026-04-04 -- Gemini API April Updates: Inference Tiers, Veo 3.1, Lyria 3, Gemini CLI v0.37
- **What**: Rapid-fire updates in late March/early April 2026: (1) **Flex and Priority Inference Tiers** (Apr 1) — developers can now choose between cost-optimized (Flex) and latency-optimized (Priority) inference tiers for Gemini API calls, enabling cost/latency tradeoffs per use case. (2) **Gemma 4 models on Gemini API** (Apr 2) — `gemma-4-26b-a4b-it` and `gemma-4-31b-it` now available in AI Studio and via the Gemini API. (3) **Veo 3.1 Lite Preview** (Mar 31) — cost-efficient video generation model for rapid iteration and high-volume applications. (4) **Lyria 3 music generation** (Mar 25) — `lyria-3-clip-preview` (30s clips) and `lyria-3-pro-preview` (full-length songs), accepting text + image inputs for 48kHz stereo audio. (5) **Model deprecation**: `gemini-2.5-flash-lite-preview-09-2025` shut down, users directed to `gemini-3.1-flash-lite-preview`. (6) **Gemini CLI v0.37.0-preview.1** (Apr 2) — open-source terminal agent with subagent architecture (event-driven history, remote subagent support with inline agentCardJson), persistent browser sessions, dynamic tool discovery, MCP integration, GEMINI.md project config, and "Chapters" tool-based topic grouping. Includes security hardening (secret visibility lockdown, Windows Mandatory Integrity Control) and sandbox expansion.
- **Significance**: The inference tier system is a notable pricing innovation — it lets developers optimize for cost (batch/async workloads) vs latency (real-time user-facing) without changing model code. Veo 3.1 Lite and Lyria 3 signal Google's push into multimodal generation beyond text/image. The Gemini CLI's subagent architecture with A2A-compatible agent cards directly mirrors Claude Code's agent architecture — these two tools are converging on similar patterns (MCP, project config files, subagent delegation). The gemini-2.5 deprecation confirms Google's aggressive model lifecycle management.
- **Source**: https://ai.google.dev/gemini-api/docs/changelog, https://geminicli.com/docs/changelogs/preview/, https://github.com/google-gemini/gemini-cli

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
