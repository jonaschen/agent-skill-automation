# Agentic AI Benchmarks

**Last updated**: 2026-04-02
**Sources**:
- https://llm-stats.com/benchmarks/swe-bench-verified
- https://www.swebench.com/
- https://epoch.ai/benchmarks/swe-bench-verified
- https://www.vals.ai/benchmarks/swebench
- https://www.evidentlyai.com/blog/ai-agent-benchmarks
- https://github.com/philschmid/ai-agent-benchmark-compendium
- https://localaimaster.com/models/swe-bench-explained-ai-benchmarks
- https://simmering.dev/blog/agent-benchmarks/

## Overview

Agentic AI benchmarks evaluate autonomous AI systems on real-world tasks including software engineering, web navigation, tool use, and general assistant capabilities. The field has seen rapid score improvements: SWE-bench Verified top scores jumped from roughly 65% in early 2025 to 80.9% in March 2026, while WebArena improved from 14% to approximately 60% in two years. GAIA is approaching saturation at 90%, only 2 percentage points below the human baseline of 92%.

## Key Developments (reverse chronological)

### 2026-04-02 — SWE-bench Verified Leaderboard (March 2026)
- **What**: Current top 10 on SWE-bench Verified: (1) Claude Opus 4.5 at 80.9%, (2) Claude Opus 4.6 at 80.8%, (3) Gemini 3.1 Pro at 80.6%, (4) MiniMax M2.5 at 80.2%, (5) GPT-5.2 at 80.0%, (6) Claude Sonnet 4.6 at 79.6%, (7) Gemini 3 Flash at 78.0%, (8) GLM-5 at 77.8%, (9) Kimi K2.5 at 76.8%, (10) Seed 2.0 Pro at 76.5%. The benchmark now covers 77 models with an average score of 62.2%.
- **Significance**: Anthropic holds 3 of the top 6 positions. Google's Gemini 3.1 Pro is a close third at 80.6%. The gap between top models has compressed to under 2 percentage points, making the leaderboard highly competitive.
- **Source**: https://llm-stats.com/benchmarks/swe-bench-verified

### 2026-04-02 — SWE-bench Scaffold Upgrade to v2.0.0 (February 2026)
- **What**: Epoch AI upgraded the SWE-bench evaluation scaffold (mini-SWE-agent v2.0.0) with improved scaffolding, environments, and token limits, leading to significantly higher reported scores across all models.
- **Significance**: Score improvements partly reflect scaffold improvements, not just model capability. Direct comparisons to pre-v2.0.0 scores require caution. The official SWE-bench site with mini-SWE-agent v2.0.0 shows somewhat lower scores than third-party leaderboards using different agent frameworks (e.g., Claude Opus 4.5 at 76.8% on official site vs 80.9% on aggregator sites).
- **Source**: https://epoch.ai/benchmarks/swe-bench-verified

### 2026-04-02 — Cost Efficiency Emerges as Benchmark Dimension
- **What**: The official SWE-bench leaderboard now tracks cost per instance alongside resolution rate. Claude Opus 4.5 costs $0.754/instance (32.9 API calls avg), Gemini 3 Flash costs $0.356/instance (56.1 API calls avg), and MiniMax M2.5 costs just $0.073/instance (60.5 API calls avg).
- **Significance**: Cost-effectiveness is becoming as important as raw capability. Gemini 3 Flash achieves 75.8% at less than half the cost of Claude Opus 4.5 (76.8%). MiniMax achieves competitive scores at 1/10th the cost.
- **Source**: https://www.swebench.com/

### 2026-04-02 — GAIA Approaching Saturation
- **What**: The GAIA benchmark high score reached 90% by end of 2025, with the human baseline at 92%. GAIA evaluates general AI assistant capabilities across 466 human-annotated tasks requiring reasoning, multimodality, and tool use across three difficulty levels.
- **Significance**: With only a 2-point gap to human performance, GAIA may need more challenging tasks or a successor benchmark to continue differentiating frontier models.
- **Source**: https://www.evidentlyai.com/blog/ai-agent-benchmarks

### 2026-04-02 — WebArena Progress: 14% to 60% in Two Years
- **What**: AI agents improved from 14% to approximately 60% success rate on WebArena's 812 templated web tasks. Human performance on WebArena is approximately 78%.
- **Significance**: An 18-point gap to human performance remains. Closing this gap requires advances in deep visual understanding and common-sense reasoning for web navigation.
- **Source**: https://medium.com/@adnanmasood/webarena-benchmark-and-the-state-of-agentic-ai-c22697e8e192

### 2026-04-02 — BFCL Function Calling Benchmark at 77.5%
- **What**: The Berkeley Function Calling Leaderboard (BFCL) tests function-calling accuracy across 2,000 Q&A pairs with multi-language support. The current top score is 77.5%.
- **Significance**: Function calling / tool use is a foundational capability for agentic systems, and a 77.5% ceiling indicates meaningful room for improvement in reliable tool invocation.
- **Source**: https://www.evidentlyai.com/blog/ai-agent-benchmarks

## Technical Details

### Major Benchmark Profiles

| Benchmark | Focus | Dataset Size | Human Baseline | Top AI Score | Gap |
|-----------|-------|-------------|----------------|-------------|-----|
| **SWE-bench Verified** | Software engineering (resolve GitHub issues) | 500 validated tasks from 12 Python repos | ~100% (human-written patches) | 80.9% | ~19% |
| **GAIA** | General AI assistant (reasoning + tools) | 466 tasks, 3 difficulty levels | 92% | 90% | 2% |
| **WebArena** | Web task completion (realistic browsers) | 812 templated tasks | 78% | ~60% | 18% |
| **BFCL** | Function calling accuracy | 2,000 Q&A pairs | N/A | 77.5% | N/A |
| **AgentBench** | Multi-turn reasoning (8 environments) | 5-50 turns per problem | N/A | N/A | N/A |
| **ToolBench** | API/tool usage mastery | 16,464 RESTful APIs, 49 categories | N/A | N/A | N/A |
| **ToolEmu** | Safety and risk in tool use | 36 high-stakes tools, 144 test cases | N/A | N/A | N/A |
| **MINT** | Multi-turn interaction with tools | Reasoning + code + decisions | N/A | N/A | N/A |
| **ColBench** | Collaborative agent workflows | Backend + frontend iteration | N/A | N/A | N/A |
| **MetaTool** | Tool selection and awareness | 21,000+ prompts | N/A | N/A | N/A |

### Emerging Benchmarks (2025-2026)
- **SWE-bench Pro** (Scale Labs): Professional-grade software engineering tasks, harder than Verified
- **Live-SWE-agent**: Real-time continuously updated evaluation
- **SWE-rebench**: Alternative evaluation with different methodology
- **Webshop**: E-commerce task execution (1.18M products, 12,087 instructions)

### Methodological Concerns
- **Agent framework matters**: Agent scaffolding can improve scores by 10-20 points over raw model performance, making it hard to isolate model vs. framework contributions.
- **Scaffold version sensitivity**: The February 2026 v2.0.0 upgrade caused score jumps across all models, demonstrating that infrastructure changes can inflate apparent progress.
- **Saturation risk**: GAIA at 90% (2 points from human) may stop being useful for differentiation soon.
- **Enterprise gap**: Academic benchmarks may not reflect real enterprise deployment challenges (reliability, cost, latency).

## Comparison Notes

### Anthropic vs Google Positioning
- **SWE-bench**: Anthropic leads with Claude Opus 4.5 (80.9%) and Opus 4.6 (80.8%). Google's Gemini 3.1 Pro is a close third at 80.6%. The gap is marginal (0.3 percentage points).
- **Cost efficiency**: Google's Gemini 3 Flash offers strong price-performance (75.8% at $0.356/instance vs Claude Opus 4.5's 76.8% at $0.754/instance on the official SWE-bench scaffold).
- **Model count**: Anthropic has more models in the top 10 (3 entries) than Google (2 entries), suggesting broader lineup strength.
- **Both companies** are now within the 78-81% band on SWE-bench Verified, indicating near-parity on this benchmark. Differentiation may shift to cost, latency, and reliability rather than raw capability.
