# Model Releases

**Last updated**: 2026-04-02
**Sources**:
- https://platform.claude.com/docs/en/about-claude/models/overview
- https://en.wikipedia.org/wiki/Claude_(language_model)
- https://www.anthropic.com/news/claude-opus-4-5
- https://www.cnbc.com/2026/02/17/anthropic-ai-claude-sonnet-4-6-default-free-pro.html
- https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/

## Overview

Anthropic's Claude model family has progressed through Claude 3 (March 2024), Claude 3.5 (June 2024), Claude 4 (May 2025), Claude 4.5 (October-November 2025), and Claude 4.6 (February 2026). The current flagship models are Opus 4.6 (1M context, $5/$25 per MTok) and Sonnet 4.6 (1M context, $3/$15 per MTok). An unreleased "Mythos" model is reportedly in internal testing with capabilities beyond Opus 4.6.

## Key Developments (reverse chronological)

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

### Platform Availability
- Claude API (direct)
- AWS Bedrock
- Google Vertex AI
- Microsoft Azure AI Foundry (Opus 4.6/Sonnet 4.6)

### Key Capability Features (4.6 generation)
- Extended thinking
- Adaptive thinking
- Priority Tier service
- 1M token context window
- Computer use (beta)
- Agent teams / swarm mode

## Comparison Notes

Claude 4.6 vs Gemini 2.5:
- **Context**: Opus 4.6 has 1M tokens; Gemini 2.5 Pro has 1M tokens (parity)
- **Max output**: Opus 4.6 at 128K (300K batch); Gemini 2.5 Pro at 65K
- **Pricing**: Opus 4.6 at $5/$25; Gemini 2.5 Pro at $1.25/$10 (Gemini significantly cheaper)
- **Coding**: Both claim top-tier coding performance; Claude leads on SWE-bench
- **Agentic**: Opus 4.6 has native agent teams; Gemini uses ADK for agent orchestration
- **Safety**: Claude Opus 4 was first to receive Level 3 safety classification
- **Multimodal**: Both support text + image input; Gemini also supports audio/video input natively
