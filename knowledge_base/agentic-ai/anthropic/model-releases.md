# Model Releases

**Last updated**: 2026-04-05
**Sources**:
- https://platform.claude.com/docs/en/about-claude/models/overview
- https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-6
- https://en.wikipedia.org/wiki/Claude_(language_model)
- https://www.anthropic.com/news/claude-opus-4-5
- https://www.cnbc.com/2026/02/17/anthropic-ai-claude-sonnet-4-6-default-free-pro.html
- https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/
- https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/
- https://capybara.com/

## Overview

Anthropic's Claude model family has progressed through Claude 3 (March 2024), Claude 3.5 (June 2024), Claude 4 (May 2025), Claude 4.5 (October-November 2025), and Claude 4.6 (February 2026). The current flagship models are Opus 4.6 (1M context, $5/$25 per MTok) and Sonnet 4.6 (1M context, $3/$15 per MTok). An unreleased "Mythos" model is reportedly in internal testing with capabilities beyond Opus 4.6.

## Key Developments (reverse chronological)

### 2026-04-05 -- Leaked Model Codenames: Fenick (Opus), Capra/Capabra (Sonnet), Tangu (Haiku)
- **What**: Following the March 31 Claude Code source leak (59.8MB source map published to npm), additional internal details emerged about Anthropic's model naming conventions: (1) "Fenick" is the internal codename for the Opus model series. (2) "Capra" or "Capabra" is the internal codename for Sonnet. (3) "Tangu" is the internal codename for Haiku. (4) References to "Opus 4.7" and "Sonnet 4.8" found in internal testing configurations, suggesting the next generation is already in development. (5) "Capybara" tier confirmed as the tier name that sits above Opus/Sonnet/Haiku — Mythos is the first model in this tier. (6) 44 hidden feature flags discovered including voice mode, multi-agent coordination enhancements, background sessions, and a `/buddy` feature. Note: Some of this information originated from April 1 posts and should be treated with appropriate skepticism — codenames are confirmed but version numbers and feature flags may be speculative or satirical.
- **Significance**: The codename system (Fenick/Capra/Tangu) provides a way to track unreleased models in future leaks or documentation. The Opus 4.7/Sonnet 4.8 references suggest Anthropic maintains a rapid release cadence even for flagship models. The Capybara tier above Opus confirms Anthropic's intent to create a premium model category — pricing likely above current Opus 4.6 ($5/$25). Background sessions feature flag aligns with the Conway persistent agent platform.
- **Source**: https://medium.com/@mfierce0/the-claude-code-leak-opus-4-7-sonnet-4-8-and-mythos-a-rare-unfiltered-look-inside-anthropic-70c6f735810a, https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/

### 2026-04-04 -- Model Capabilities Comparison Update (newly documented)
- **What**: Updated technical comparison from official models overview: (1) Opus 4.6 supports adaptive thinking (dynamic thinking depth), extended thinking, 1M context, 128K max output. Training data cutoff: Aug 2025. (2) Sonnet 4.6 supports adaptive thinking, extended thinking, 1M context, 64K max output. Training data cutoff: Jan 2026 (newer than Opus). (3) Haiku 4.5 supports extended thinking but NOT adaptive thinking, 200K context, 64K max output. Training data cutoff: Jul 2025. (4) Batch API: Opus 4.6 and Sonnet 4.6 support 300K output with `output-300k-2026-03-24` beta header. (5) Models API (`/v1/models`) now returns `capabilities` object for programmatic capability discovery.
- **Significance**: Notable that Sonnet 4.6 has a newer training data cutoff (Jan 2026) than Opus 4.6 (Aug 2025), meaning Sonnet may have more current knowledge for some topics. The programmable capabilities API enables agents to dynamically select models based on required features.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-04 -- Legacy Model Lineup and Pricing Confirmed
- **What**: Full legacy model pricing confirmed: Sonnet 4.5 ($3/$15), Opus 4.5 ($5/$25), Opus 4.1 ($15/$75), Sonnet 4 ($3/$15), Opus 4 ($15/$75), Haiku 3 ($0.25/$1.25, retiring April 19). All legacy models have 200K context windows. Opus 4.1 and Opus 4 are the most expensive at $15/$75 — 3x the price of current Opus 4.6 ($5/$25) for inferior capabilities.
- **Significance**: The pricing trajectory shows aggressive cost reduction with each generation: Opus went from $15/$75 (4.0/4.1) to $5/$25 (4.5/4.6) — a 67% reduction. This incentivizes migration away from legacy models.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-03 -- Claude Haiku 3 Retirement April 19, 2026
- **What**: Claude Haiku 3 (`claude-3-haiku-20240307`) is scheduled for retirement on April 19, 2026. After that date, all API requests to this model will return an error. Anthropic recommends migrating to Claude Haiku 4.5 ($1/$5 per MTok vs Haiku 3's $0.25/$1.25).
- **Significance**: Organizations still using legacy Haiku 3 have ~16 days to migrate. This is both a capability upgrade and a 4x price increase for input tokens.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-03 -- 1M Context Beta Retiring for Sonnet 4.5 and Sonnet 4 (April 30)
- **What**: Anthropic is retiring the 1M token context window beta for Claude Sonnet 4.5 and Sonnet 4 on April 30, 2026. The `context-1m-2025-08-07` beta header will have no effect after that date. Users must migrate to Sonnet 4.6 or Opus 4.6 for 1M context at standard pricing.
- **Significance**: Forces migration to 4.6-generation models for long-context workloads. Clear signal Anthropic is consolidating around the 4.6 generation.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 -- Message Batches API Max Output Raised to 300k Tokens
- **What**: `max_tokens` cap raised to 300k on Message Batches API for Opus 4.6 and Sonnet 4.6 via `output-300k-2026-03-24` beta header. 2.3x increase over previous 128k limit.
- **Significance**: Particularly relevant for large-scale code generation and document processing in batch workflows.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 -- Claude Code Leak Confirms Model Codenames and Capybara Tier
- **What**: The Claude Code source code leak (v2.1.88 npm source map) confirmed internal model codenames: Capybara is a new model tier above Opus ("larger and more intelligent than our Opus models"), Fennec maps to Opus 4.6, and Numbat is an unreleased model still in testing. Capybara is confirmed to be the same model previously leaked as "Mythos." The source also references KAIROS, an autonomous daemon mode feature flag. No official release date for Capybara/Mythos has been announced; it remains available only to a small group of early access customers.
- **Significance**: Confirms the Mythos/Capybara connection and establishes a new tier hierarchy: Haiku < Sonnet < Opus < Capybara. The KAIROS daemon mode suggests Capybara may ship with persistent background agent capabilities as a differentiator.
- **Source**: https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/, https://capybara.com/

### 2026-04-03 -- Claude Mythos (Capybara): Safety Concerns and Government Warnings
- **What**: Anthropic has privately warned senior government officials that Mythos "makes large-scale cyberattacks significantly more likely in 2026." The model is described as "currently far ahead of any other AI model in cyber capabilities." A prior incident is noted: in September 2025, a Chinese state-sponsored group used an earlier Claude model to execute cyberattacks with "80-90% autonomy" across ~30 organizations. Anthropic's planned rollout prioritizes giving cyber defenders early access before broader distribution.
- **Significance**: Represents a new frontier in AI safety concerns for agentic systems. The defender-first rollout strategy may set precedent for how frontier agentic models are released.
- **Source**: https://www.pymnts.com/artificial-intelligence-2/2026/anthropics-unreleased-claude-mythos-might-be-the-most-advanced-ai-model-yet/

### 2026-04-02 -- Deep Dive: Claude 4.6 New Features and Breaking Changes
- **What**: Detailed technical review of all 4.6 launch features, deprecations, and breaking changes from the official "What's New in Claude 4.6" documentation. Key findings below.
- **Adaptive Thinking**: `thinking: {type: "adaptive"}` is the recommended mode. Claude dynamically decides when and how much to think. Old `thinking: {type: "enabled"}` with `budget_tokens` is deprecated. New `max` effort level on Opus 4.6 provides highest capability.
- **Fast Mode (beta)**: `speed: "fast"` delivers up to 2.5x faster output generation for Opus at premium pricing ($30/$150 per MTok). Same model, faster inference. Beta header: `fast-mode-2026-02-01`.
- **Compaction API (beta)**: Server-side context summarization for infinite conversations. Auto-summarizes when context approaches window limit. Available on Opus 4.6.
- **Free Code Execution**: Code execution is free when used with web search or web fetch tools. Dynamic filtering support with `web_search_20260209` / `web_fetch_20260209` tool versions.
- **Tools GA**: Code execution, web fetch, programmatic tool calling, tool search, tool use examples, and memory tool all graduated to general availability.
- **Data Residency**: `inference_geo` parameter supports `"global"` (default) or `"us"`. US-only at 1.1x pricing for models after Feb 1, 2026.
- **Breaking: Prefill Removal**: Prefilling assistant messages not supported on Opus 4.6. Requests return 400 error. Must use structured outputs or system prompts instead.
- **Breaking: Tool Parameter Quoting**: Opus 4.6 may produce different JSON string escaping in tool call arguments. Standard parsers handle it; raw string parsers may break.
- **Deprecation: output_format**: Moved to `output_config.format`. Old parameter still functional but deprecated.
- **Deprecation: interleaved-thinking beta header**: No longer required on Opus 4.6 (adaptive thinking enables it automatically).
- **Significance**: These details are critical for migration planning. The prefill removal is a breaking change that affects many existing agentic workflows.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-6

### 2026-03-26 -- Mythos Model Leaked
- **What**: Data leak revealed existence of "Mythos," a next-generation model in internal testing. Anthropic confirmed it represents a "step change" in capabilities, with internal benchmarks showing superiority to Opus 4.6 on complex coding, long-horizon reasoning, and safety.
- **Significance**: Indicates Anthropic's next major model generation. Speculative timeline: Q3-Q4 2026.
- **Source**: https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/

### 2026-02-17 -- Claude Sonnet 4.6 Released
- **What**: Released as default model for free and Pro users. Improvements in computer use, coding, design, knowledge work, and large data processing. 1M context window, 64K max output. Pricing: $3/$15 per MTok. Training data cutoff: January 2026. Reliable knowledge cutoff: August 2025.
- **Significance**: Brings 4.6-generation capabilities to the cost-efficient Sonnet tier.
- **Source**: https://www.cnbc.com/2026/02/17/anthropic-ai-claude-sonnet-4-6-default-free-pro.html

### 2026-02-05 -- Claude Opus 4.6 Released
- **What**: Flagship model with 1M token context window (up from 200K), 128K max output. Released alongside agent teams feature and Claude in PowerPoint. Pricing: $5/$25 per MTok (massive price reduction from Opus 4.5's $5/$25 and Opus 4.1's $15/$75). Training data cutoff: August 2025. Reliable knowledge cutoff: May 2025. Supports extended thinking, adaptive thinking, and Priority Tier.
- **Significance**: 5x context window expansion plus agent teams make this the primary agentic model. Batch API supports 300K output with beta header.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-11-24 -- Claude Opus 4.5 Released
- **What**: 200K context, 64K max output. Introduced "Infinite Chats" eliminating context window limit errors. Improvements in coding and spreadsheet tasks. Pricing: $5/$25 per MTok. Knowledge cutoff: May 2025.
- **Significance**: Major step in making Opus more affordable (down from $15/$75 for Opus 4.1).
- **Source**: https://www.anthropic.com/news/claude-opus-4-5

### 2025-10-15 -- Claude Haiku 4.5 Released
- **What**: Fast, cost-effective model. 200K context, 64K max output. Pricing: $1/$5 per MTok. Supports extended thinking and Priority Tier.
- **Significance**: Budget-friendly option for high-volume agent workloads.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-09-29 -- Claude Sonnet 4.5 Released
- **What**: 200K context, 64K max output. Pricing: $3/$15 per MTok. Training data cutoff: July 2025. First model to support advanced tool use features.
- **Significance**: Introduced advanced tool use (Tool Search, Programmatic Tool Calling, Examples).
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-08-05 -- Claude Opus 4.1 Released
- **What**: 200K context, 32K max output. Pricing: $15/$75 per MTok. Knowledge cutoff: March 2025.
- **Significance**: Incremental Opus improvement; now categorized as legacy given Opus 4.5/4.6 pricing.
- **Source**: https://en.wikipedia.org/wiki/Claude_(language_model)

### 2025-05-22 -- Claude 4 Released (Opus 4 + Sonnet 4)
- **What**: Fourth generation. Opus 4 classified as "Level 3" safety rating. 200K context. Opus 4: $15/$75 per MTok. Sonnet 4: $3/$15 per MTok.
- **Significance**: Major generation jump with top-tier reasoning, coding, and multilingual capabilities.
- **Source**: https://en.wikipedia.org/wiki/Claude_(language_model)

## Technical Details

### Current Model Lineup (as of April 2026)

| Model | API ID | Context | Max Output | Input $/MTok | Output $/MTok | Knowledge Cutoff |
|-------|--------|---------|------------|-------------|--------------|-----------------|
| Opus 4.6 | claude-opus-4-6 | 1M | 128K | $5 | $25 | May 2025 (reliable) |
| Sonnet 4.6 | claude-sonnet-4-6 | 1M | 64K | $3 | $15 | Aug 2025 (reliable) |
| Haiku 4.5 | claude-haiku-4-5 | 200K | 64K | $1 | $5 | Feb 2025 (reliable) |

### Training Data Cutoffs (vs Reliable Knowledge Cutoffs)

| Model | Reliable Knowledge Cutoff | Training Data Cutoff |
|-------|--------------------------|---------------------|
| Opus 4.6 | May 2025 | August 2025 |
| Sonnet 4.6 | August 2025 | January 2026 |
| Haiku 4.5 | February 2025 | July 2025 |

### Legacy Models (still available)
| Model | API ID | Context | Max Output | Input $/MTok | Output $/MTok |
|-------|--------|---------|------------|-------------|--------------|
| Sonnet 4.5 | claude-sonnet-4-5 | 200K | 64K | $3 | $15 |
| Opus 4.5 | claude-opus-4-5 | 200K | 64K | $5 | $25 |
| Opus 4.1 | claude-opus-4-1 | 200K | 32K | $15 | $75 |
| Sonnet 4 | claude-sonnet-4-0 | 200K | 64K | $3 | $15 |
| Opus 4 | claude-opus-4-0 | 200K | 32K | $15 | $75 |

### Deprecation Notice
- Claude Haiku 3 (claude-3-haiku-20240307) deprecated, retiring April 19, 2026

### Extended Output (Batch API)
- Opus 4.6 and Sonnet 4.6 support up to 300K output tokens via `output-300k-2026-03-24` beta header on Message Batches API

### Fast Mode (Opus 4.6 only, beta)
- Premium pricing: $30/$150 per MTok (6x standard)
- Up to 2.5x faster output token generation
- Same model intelligence, faster inference
- Beta header: `fast-mode-2026-02-01`

### Compaction API (Opus 4.6, beta)
- Server-side context summarization
- Enables effectively infinite conversations
- Auto-triggers when context approaches window limit

### Platform Availability
- Claude API (direct)
- AWS Bedrock (IDs: `anthropic.claude-opus-4-6-v1`, `anthropic.claude-sonnet-4-6`)
- Google Vertex AI (IDs: `claude-opus-4-6`, `claude-sonnet-4-6`)
- Microsoft Azure AI Foundry (Opus 4.6/Sonnet 4.6)

### Key Capability Features (4.6 generation)
- Extended thinking
- Adaptive thinking (recommended; replaces manual budget_tokens)
- Effort parameter GA (low/medium/high/max levels)
- Priority Tier service
- 1M token context window
- Computer use (beta)
- Agent teams / swarm mode
- Data residency controls (inference_geo)
- Free code execution with web tools

### Breaking Changes in 4.6
- **Prefill removal**: Prefilling assistant messages returns 400 on Opus 4.6
- **Tool parameter quoting**: Different JSON escaping in tool call arguments
- **output_format deprecated**: Use `output_config.format` instead

## Comparison Notes

Claude 4.6 vs Gemini 2.5:
- **Context**: Opus 4.6 has 1M tokens; Gemini 2.5 Pro has 1M tokens (parity)
- **Max output**: Opus 4.6 at 128K (300K batch); Gemini 2.5 Pro at 65K
- **Pricing**: Opus 4.6 at $5/$25; Gemini 2.5 Pro at $1.25/$10 (Gemini significantly cheaper)
- **Coding**: Both claim top-tier coding performance; Claude leads on SWE-bench
- **Agentic**: Opus 4.6 has native agent teams; Gemini uses ADK for agent orchestration
- **Safety**: Claude Opus 4 was first to receive Level 3 safety classification
- **Multimodal**: Both support text + image input; Gemini also supports audio/video input natively
