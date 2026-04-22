# Context Management: Gemini vs Claude

**Last updated**: 2026-04-23
**Topics**: S3 (Platform Generalization & Portability)

## Overview

As of April 2026, both Google and Anthropic have introduced advanced primitives for managing the "context wall" in long-running agentic sessions. While their goals are similar (reducing token cost and latency while preserving model performance), their architectural approaches differ significantly.

## Comparison: Gemini Context Compression vs. Claude Prompt Caching

| Feature | Gemini Context Compression (v0.38.0+) | Claude Prompt Caching |
| :--- | :--- | :--- |
| **Primary Mechanism** | **Active Compression Service**: Periodically summarizes and prunes the conversation history based on semantic relevance. | **Static Prefix Caching**: Persists the prompt prefix in memory for 5 minutes (sliding window) to avoid re-computation. |
| **Logic** | **"Chapters" Pattern**: Groups related turns into semantic chapters; old chapters are summarized into "Context Seeds". | **Byte-for-byte matching**: Only identical prefixes are cached. Any change in the prefix invalidates the cache. |
| **User Control** | **Automatic/Service-managed**: The CLI handles compression transparently via the Background Memory Service. | **Explicit/Manual**: Developers must tag blocks with `cache_control: {"type": "ephemeral"}`. |
| **Token Efficiency** | **High (Aggressive)**: Can keep 1M+ token conversations within a ~32K active "sliding window". | **Variable**: Excellent for large static contexts (docs/codebases); poor for rapidly growing linear conversations. |
| **Cost Profile** | **Throughput-based**: Significant savings on input tokens by physically removing them from the request. | **Usage-based**: 10% of base input rate for cache hits; 25% premium for cache writes. |
| **Latency (TTFT)** | **Medium**: Compression events can cause transient latency spikes (up to 2-3s). | **Ultra-Low**: Up to 80% reduction in TTFT for cache hits (typically <500ms). |

## Strategic Analysis

### Gemini's "Service-First" Approach
Gemini CLI v0.38.0 treats context as a **managed service**. The agent doesn't just see a rolling window; it sees a semantically distilled history. This is superior for "long-horizon" tasks where the agent needs to remember the *intent* of Turn 1 while at Turn 500, without paying for the intermediate 499 turns' worth of tokens.
- **Strength**: Infinite conversation length with sub-linear cost growth.
- **Weakness**: Potential loss of fine-grained detail in summarized chapters.

### Claude's "Cache-First" Approach
Claude Code v2.1 relies on **Prompt Caching** and **Auto-Compaction**. Prompt Caching is a developer primitive, not a semantic service. It is highly optimized for the "Edit-Test-Repeat" loop where 95% of the prompt (the codebase) is static.
- **Strength**: Incredible speed and predictability. Perfect for coding agents.
- **Weakness**: Still hits a hard context wall eventually (the 1M limit), requiring explicit truncation or "CHAPTER" style manual summarization.

## Recommendations for Phase 5 (Multi-Agent Topology)

1.  **For High-Depth Tasks (App Generation)**: Use **Claude with explicit Chapter summarization**. The byte-for-byte precision of caching is critical for code correctness.
2.  **For High-Width Tasks (Deep Research)**: Use **Gemini with Context Compression**. The ability to scan thousands of web pages and synthesize them into a distilled context seed is more valuable than preserving the raw HTML of Page 1.
3.  **Cross-Platform Parity**: Our pipeline should implement a **"Context Abstractor"** that maps Gemini's "Chapters" concept onto Claude's "Compaction" hooks. This ensures that agents remain portable between providers while maintaining similar memory architectures.
