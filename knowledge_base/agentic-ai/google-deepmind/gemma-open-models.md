# Gemma / Open Models

**Last updated**: 2026-04-08
**Sources**:
- https://deepmind.google/models/gemma/
- https://deepmind.google/models/gemma/gemma-3/
- https://developers.googleblog.com/en/introducing-gemma-3n/
- https://blog.google/technology/developers/gemma-3/
- https://ai.google.dev/gemma/docs/releases
- https://www.infoq.com/news/2026/01/functiongemma-edge-function-call/
- https://ai.google.dev/gemma/docs/functiongemma
- https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/
- https://developers.googleblog.com/bring-state-of-the-art-agentic-skills-to-the-edge-with-gemma-4/
- https://9to5google.com/2026/04/02/google-gemma-4/
- https://android-developers.googleblog.com/2026/04/gemma-4-new-standard-for-local-agentic-intelligence.html
- https://deepmind.google/models/gemma/gemma-4/
- https://developer.nvidia.com/blog/bringing-ai-closer-to-the-edge-and-on-device-with-gemma-4/
- https://www.interconnects.ai/p/gemma-4-and-what-makes-an-open-model
- https://android-developers.googleblog.com/2026/04/AI-Core-Developer-Preview.html

## Overview

Gemma is Google DeepMind's family of open-weight models built on the same research as Gemini. Gemma 4 (April 2026) is the latest generation — the most capable open models to date, purpose-built for advanced reasoning and agentic workflows with native function calling. Gemma 3 (March 2025) was the first version optimized for agentic workflows. Gemma 3n (2025) adds mobile-first on-device capabilities with audio support. The family ranges from 270M to 31B parameters, with all models designed to run on a single GPU or TPU, making them ideal for edge and on-device agent deployments.

## Key Developments (reverse chronological)

### 2026-04-08 -- Gemma 4 Day 6: Comprehensive Competitive Benchmarks; Qwen 3.6 Plus Disrupts; Fine-Tuning Ecosystem Status
- **What**: Post-launch ecosystem analysis continues (day 6 since Gemma 4 release): (1) **Head-to-head benchmarks vs Qwen 3.5 27B and Llama 4 Scout** now available. RTX 4090 Q4 results: Qwen 3.5 27B: ~35 tok/s, Gemma 4 31B Dense: ~25 tok/s, Gemma 4 26B MoE: ~11 tok/s, Llama 4 Scout: ~15 tok/s. On quality: Qwen 3.5 edges out Gemma 4 on MMLU Pro (86.1% vs 85.2%) and GPQA Diamond (85.5% vs 84.3%), but Gemma 4 dominates math (AIME 2026: 89.2%) and Codeforces ELO (2150 vs ~1900). (2) **Qwen 3.6 Plus** (released ~Mar 30) emerges as a major competitive threat specifically for agentic coding: 1M token context, matches Claude Opus 4.5 on SWE-bench and Terminal-Bench 2.0, visual coding from screenshots/wireframes, free preview on OpenRouter. Described as "the first real agentic LLM" by some analysts. (3) **Fine-tuning status update**: HuggingFace Transformers fix requires installing from source (v5.5.0.dev0). **Unsloth confirmed as the reliable production path** — trains Gemma 4 ~1.5x faster with ~50% less VRAM, bypasses all three QLoRA blockers. TRL supports multimodal fine-tuning including tool response training. Medium article documents step-by-step Gemma 4 E2B fine-tuning via Unsloth with OOM error recovery. (4) **Apache 2.0 license praised** as "massively boosting adoption" vs Qwen 3.5 (also Apache 2.0) and Llama 4 (700M MAU ceiling). (5) **Multilingual advantage**: Gemma 4 outperforms Qwen 3.5 in non-English tasks (German, Arabic, Vietnamese, French tested). (6) **No new Gemma 4 model variants** from Google since Apr 2 launch. (7) **Practical recommendations emerging**: use Gemma 4 E2B/E4B for edge/mobile (unmatched), Qwen 3.5 for speed-critical single-GPU workstations, Gemma 4 31B for math/coding quality, Llama 4 Scout for ultra-long context (10M tokens).
- **Significance**: The competitive benchmark landscape is now well-characterized: Gemma 4 wins on math/coding quality and multilingual tasks but loses on inference speed (3.2x slower than Qwen 3.5 on dense, 5.5x slower on MoE). For our Phase 6 edge AI plans, the recommendation matrix is clear: **Gemma 4 E2B/E4B remain unmatched for on-device** (no competitor has native audio + 128K context at <1.5GB), but **Qwen 3.5/3.6 is superior for latency-sensitive server-side agentic workloads**. The Unsloth path is now the recommended fine-tuning approach until HuggingFace stable releases land. Qwen 3.6 Plus's free-tier disruption and SWE-bench parity with Claude Opus represents a significant threat to both Google and Anthropic's agentic coding positioning.
- **Source**: https://www.lushbinary.com/blog/gemma-4-vs-llama-4-vs-qwen-3-5-open-weight-model-comparison/, https://letsdatascience.com/blog/google-gemma-4-open-source-apache-community-found-catches, https://paddo.dev/blog/ai-roundup-april-2026/, https://medium.com/@gabi.preda/from-oom-errors-to-working-model-fine-tuning-gemma-4-e2b-step-by-step-using-unsloth-ef7873e59efd, https://www.geeky-gadgets.com/google-gemma-4/

### 2026-04-07 -- Gemma 4 Fine-Tuning Bug Fixes Landing; Performance Gaps vs Qwen 3.5 Quantified; Stability Issues on 31B
- **What**: Post-launch ecosystem analysis (day 5 since Gemma 4 release): (1) **Fine-tuning bug fixes progressing**: The three QLoRA blockers identified at launch are being resolved — HuggingFace Transformers fix requires installing from source (`pip install git+transformers.git`, version 5.5.0.dev0 includes `Gemma4ForConditionalGeneration`), PEFT monkey-patch for `Gemma4ClippableLinear` is a confirmed workaround, and a PR for `mm_token_type_ids` handling is in progress on the HuggingFace repos. Both repos responded within hours of bug reports. (2) **Unsloth confirmed as reliable day-one alternative** — bypasses all three compatibility issues with pre-configured support. (3) **Performance gap vs Qwen 3.5 quantified**: Independent testing shows **11 tok/s on Gemma 4 26B-A4B vs 60+ tok/s on Qwen 3.5** on identical hardware — a significant inference speed disadvantage. VRAM consumption also exceeds competing models at comparable parameter counts. (4) **Stability issues on non-quantized 31B**: Community reports of **infinite loops and inability to read text from images** on the non-quantized 31B model. Early jailbreak vulnerabilities found with basic system prompts. **Mac hard crashes** reported when loading models in LM Studio. (5) **Google Cloud deployment blog** (Apr 5) confirms three production paths: Vertex AI Model Garden (managed), Cloud Run (serverless), GKE with vLLM (high-throughput). (6) **No new Gemma 4 model variants or updates** from Google since Apr 2 launch.
- **Significance**: The fine-tuning ecosystem is maturing but NOT yet production-ready for Gemma 4 — the "install from source" requirement for Transformers means stable releases haven't landed. The **5.5x inference speed gap vs Qwen 3.5** is a serious competitive disadvantage for latency-sensitive agentic workflows — if our Phase 6 edge agents need fast inference, Qwen 3.5 may be the better choice despite Gemma 4's superior benchmarks. The 31B stability issues (infinite loops, crashes) suggest the largest variant needs more time to mature. For immediate use, the **26B MoE and E4B variants appear more stable** and are better tested. The Unsloth path should be our recommended fine-tuning approach until HuggingFace stable releases land.
- **Source**: https://dev.to/dentity007/-gemma-4-after-24-hours-what-the-community-found-vs-what-google-promised-3a2f, https://dev.to/dentity007/fine-tuning-gemma-4-on-day-zero-3-bugs-we-solved-in-30-minutes-2ke, https://docs.bswen.com/blog/2026-04-03-how-to-fine-tune-gemma-4-locally/, https://cloud.google.com/blog/products/ai-machine-learning/gemma-4-available-on-google-cloud

### 2026-04-06 -- Gemma 4 HuggingFace Day-0 Integration, Fine-Tuning Blockers, Arm Partnership, Cloud Deployment Paths
- **What**: Post-launch ecosystem analysis reveals critical details: (1) **HuggingFace day-0 integration** comprehensive — new `AutoModelForMultimodalLM` class, `any-to-any` pipeline, ONNX checkpoints for edge deployment, transformers.js for browser (WebGPU), MLX for Apple Silicon with TurboQuant (4x less memory), Mistral.rs (Rust) with built-in tool-calling. Demos available for E4B, 26B, 31B, and WebGPU browser. (2) **Fine-tuning blockers at launch** (CRITICAL): QLoRA was NOT ready — three specific issues: (a) HuggingFace Transformers didn't recognize `gemma4` architecture initially, (b) PEFT couldn't handle `Gemma4ClippableLinear` layer type in vision encoder, (c) new `mm_token_type_ids` field required during training even for text-only data. Both HuggingFace repos had issues filed. Unsloth Studio offers UI-based alternative. TRL supports multimodal fine-tuning including tool response training during RL. (3) **Arm optimization partnership** announced — Arm Newsroom confirms optimized on-device AI for mobile apps, expanding hardware acceleration beyond Google/MediaTek/Qualcomm to Arm's broader ecosystem. (4) **Google Cloud deployment** (Apr 5 blog post) — three paths: Vertex AI Model Garden (managed, autoscaling, SLA), Cloud Run (serverless containers), GKE with vLLM (high-throughput). Gemma 4 26B MoE available as fully managed/serverless on Model Garden. Fine-tuning via VTC with NeMo Megatron. (5) **Architecture detail**: Per-Layer Embeddings (PLE) provides residual signals to every decoder layer, shared KV cache eliminates redundant projections in last N layers, alternating attention uses local sliding-window (512-1024) + global full-context layers with dual RoPE. (6) **Coding agent compatibility**: Gemma 4 confirmed compatible with Pi, OpenClaw, Hermes, and OpenCode local coding agents via llama.cpp server. (7) **OpenRouter pricing**: 26B A4B at $0.13/M input, $0.40/M output tokens.
- **Significance**: The fine-tuning blockers are the most impactful finding — for our Phase 6 edge AI plans, we cannot yet rely on Gemma 4 QLoRA fine-tuning for custom agent skills. This should be resolved as HuggingFace patches land, but it's a "wait and verify" situation. The HuggingFace ecosystem breadth (transformers, MLX, Rust, browser) makes Gemma 4 the most broadly deployable open model ever released. The Arm partnership extends hardware acceleration beyond mobile SoC vendors to the embedded/IoT ecosystem. The coding agent compatibility confirms Gemma 4 can serve as a local coding assistant, relevant for edge-deployed developer tools.
- **Source**: https://huggingface.co/blog/gemma4, https://dev.to/linnn_charm_2e397112f3b51/gemma-4-complete-guide-architecture-models-and-deployment-in-2026-3m5b, https://newsroom.arm.com/blog/gemma-4-on-arm-optimized-on-device-ai, https://cloud.google.com/blog/products/ai-machine-learning/gemma-4-available-on-google-cloud

### 2026-04-05 -- Gemma 4 AICore Developer Preview, Competitive Analysis, Apache 2.0 Impact
- **What**: Multiple post-launch developments: (1) **AICore Developer Preview** (Apr 2) — Google released a Developer Preview of Gemma 4 on Android via **AICore**, the on-device AI infrastructure. Models execute on specialized AI accelerators from **Google, MediaTek, and Qualcomm** with CPU fallback. Two variants: **E4B** (higher reasoning) and **E2B** (3x faster, lower latency). Uses ML Kit's Prompt API — developers write code targeting Gemma 4 that automatically works on Gemini Nano 4 devices shipping later in 2026. Capabilities: multimodal (text, images, audio), 140+ languages, enhanced chain-of-thought reasoning, improved OCR and visual data extraction, temporal reasoning for calendar/reminder apps. (2) **Independent analysis** (Interconnects.ai by Nathan Lambert): Gemma 4 31B "rivals the recent Qwen 3.5 27B" in the ~30B class. Competitive field includes Qwen 3.5, Kimi K2.5, GLM 5, MiniMax M2.5, GPT-OSS, Arcee Large, Nemotron 3, Olmo 3. Five adoption criteria identified beyond benchmarks: model performance, country of origin (US-built faces fewer barriers), model license, tooling stability at release, and fine-tunability. (3) **Apache 2.0 licensing praised** as "massively boosting adoption" — a significant shift from Google's earlier restrictive Gemma licenses. (4) **Cautionary note**: Previous Gemma models suffered from "tooling issues and poorer performance when being finetuned" — Gemma 4's success depends on "ease of use, to a point where a 5-10% swing on benchmarks wouldn't matter." (5) **Rumored 100B+ MoE variant** unreleased.
- **Significance**: The AICore Developer Preview is the most important development for our Phase 6 — it provides a production-ready API path for on-device Gemma 4 agents on Android with hardware acceleration from all major mobile SoC vendors (Google Tensor, MediaTek, Qualcomm). The forward compatibility with Gemini Nano 4 means code written today will run on mass-market devices. The independent critical analysis raises valid concerns about fine-tunability — we should evaluate Gemma 4 fine-tuning quality before committing to it for Phase 6. The Apache 2.0 license eliminates the legal uncertainty that limited Gemma 3's enterprise adoption.
- **Source**: https://android-developers.googleblog.com/2026/04/AI-Core-Developer-Preview.html, https://www.interconnects.ai/p/gemma-4-and-what-makes-an-open-model

### 2026-04-04 -- Gemma 4 Architecture Details, Benchmarks, NVIDIA Acceleration
- **What**: Additional technical details confirmed for Gemma 4 post-launch: (1) **Architecture specifics**: The 26B MoE variant uses 128 experts with 3.8B active parameters per forward pass. E4B is 7.9B total / 4.5B effective. E2B is 5.1B total / 2.3B effective. Both are Dense Transformers with PLE, not MoE (correcting earlier assumptions). (2) **Benchmark numbers** (Gemma 4 31B IT Thinking): Arena AI text: 1452 (#3), MMLU Multilingual: 85.2%, AIME 2026: 89.2%, LiveCodeBench: 80.0%, **τ2-bench (tool use): 86.4%**. (3) **NVIDIA acceleration**: NVFP4 (4-bit precision) quantized checkpoints available for Blackwell GPUs, maintaining near-identical accuracy to 8-bit while increasing performance per watt. Compatible with vLLM, Ollama, llama.cpp, Unsloth. Deployment targets span data center (Blackwell), edge (Jetson Nano through Thor), desktop (RTX/RTX PRO), and dev (DGX Spark 128GB unified memory). (4) **Available on Gemini API** (Apr 2): `gemma-4-26b-a4b-it` and `gemma-4-31b-it` accessible via AI Studio and Gemini API. (5) **Distribution**: Hugging Face, Ollama, Kaggle, LM Studio, Docker. Training/deployment: JAX, Vertex AI, Keras, Google AI Edge, GKE.
- **Significance**: The τ2-bench score of 86.4% for tool use is the most relevant metric for our pipeline — it confirms Gemma 4 is highly capable at function calling benchmarks, not just reasoning. The NVIDIA NVFP4 quantization path means Gemma 4 can run efficiently on consumer GPUs without significant quality loss. The Jetson Nano → Thor deployment spectrum covers everything from embedded IoT to autonomous vehicle compute. Availability on Gemini API means developers can prototype with Gemma 4 via API before deploying on-device.
- **Source**: https://deepmind.google/models/gemma/gemma-4/, https://developer.nvidia.com/blog/bringing-ai-closer-to-the-edge-and-on-device-with-gemma-4/, https://ai.google.dev/gemini-api/docs/changelog

### 2026-04-03 -- Gemma 4 Released: Most Capable Open Models
- **What**: Google DeepMind released **Gemma 4** on April 2, 2026, the most capable open models to date, purpose-built for advanced reasoning and agentic workflows. Four model sizes: **31B Dense** (#3 on Arena AI text leaderboard), **26B MoE** (#6 on Arena AI), **E4B** (Effective 4B), and **E2B** (Effective 2B, runs in <1.5GB memory). Key capabilities: (1) **Native function calling and structured JSON output** for autonomous agents that interact with third-party tools and execute multi-step plans. (2) **On-device agentic skills**: multi-step planning, autonomous action, offline code generation, audio-visual processing — all without specialized fine-tuning. (3) **Agent Skills** demonstrated in Google AI Edge Gallery support knowledge augmentation, content generation, and multi-step task completion. (4) **LiteRT-LM constrained decoding** ensures structured, predictable outputs for tool-calling scripts. (5) **Performance**: processes 4,000 input tokens across 2 skills in under 3 seconds; Raspberry Pi 5: 133 tok/s prefill, 7.6 tok/s decode. (6) **Context windows**: 128K (edge models), 256K (larger models). (7) **140+ languages**. (8) **Apache 2.0 license**. (9) **Platform support**: Android, iOS, Windows, Linux, macOS, web (WebGPU), Raspberry Pi 5, Qualcomm IQ8 NPU. (10) **NVIDIA acceleration**: RTX AI Garage support announced for local agentic AI.
- **Significance**: Gemma 4 is a generational leap for open agentic models. The 31B Dense ranking #3 on Arena AI puts it in direct competition with proprietary models. Native function calling + structured output without fine-tuning means developers can build tool-using agents out of the box. The E2B at <1.5GB unlocks agent capabilities on extremely constrained devices. For our Phase 6 edge AI plans, Gemma 4 E2B/E4B with native function calling is a significantly better foundation than Gemma 3 + FunctionGemma — it eliminates the need for a separate specialist model.
- **Source**: https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/, https://developers.googleblog.com/bring-state-of-the-art-agentic-skills-to-the-edge-with-gemma-4/, https://9to5google.com/2026/04/02/google-gemma-4/, https://android-developers.googleblog.com/2026/04/gemma-4-new-standard-for-local-agentic-intelligence.html

### 2026-04-03 -- Gemma 4 on Android: Gemini Nano 4 and ML Kit Integration
- **What**: Google announced Gemma 4 as the foundation for on-device Android AI: (1) **Gemini Nano 4** (based on Gemma 4) is up to 4x faster and uses 60% less battery than the previous version, now reaching over 140 million Android devices. (2) **ML Kit GenAI Prompt API** enables developers to integrate Gemma 4 directly into Android apps for on-device intelligence. (3) **Android Studio Agent Mode**: Gemma 4 powers local AI code assistance, keeping model and inference entirely on the developer's machine for privacy. (4) Gemma 4 will launch with new flagship Android devices later in 2026 with a Developer Preview available now. (5) Full Apache 2.0 license maintained for open development.
- **Significance**: The 4x speed / 60% battery improvement is a major practical milestone for on-device agents. 140 million devices gives Gemma 4 unmatched distribution for edge AI. The ML Kit integration provides a production-ready API path for Android developers. For our Phase 6 plans, this confirms Gemma 4 on Android is production-viable, not just research.
- **Source**: https://android-developers.googleblog.com/2026/04/gemma-4-new-standard-for-local-agentic-intelligence.html

### 2025-H2 -- Gemma 3n Released (Mobile-First)
- **What**: Gemma 3n launched in 5B and 8B parameter variants with Per-Layer Embeddings (PLE) innovation reducing effective memory to 2B and 4B equivalent. Features MatFormer training for nested submodels, "mix'n'match" capability for custom submodel creation. Processes audio, text, images, and video. Developed with Qualcomm, MediaTek, and Samsung. Achieves 1.5x faster mobile responses than Gemma 3 4B with better quality.
- **Significance**: First Gemma model purpose-built for on-device/mobile deployment. The 2-3GB memory footprint enables agent capabilities on smartphones. Audio support opens voice-based agent interactions on-device.
- **Source**: https://developers.googleblog.com/en/introducing-gemma-3n/

### 2025-12 -- FunctionGemma: Edge Function Calling Specialist (updated 2026-04-02)
- **What**: FunctionGemma released at 270M parameter size, fine-tuned from Gemma 3 270M specifically for translating natural language into structured function/API calls. Uses Gemma's 256K vocabulary for efficient JSON and multilingual tokenization. In Google's "Mobile Actions" evaluation, fine-tuning boosted accuracy from **58% baseline to 85%**. Can run on NVIDIA Jetson Nano and mobile phones. Supports end-to-end agent workflows: parse natural language → identify correct tool → execute (e.g., "Create a calendar event," "Turn on the flashlight"). Published on Hugging Face at `google/functiongemma-270m-it`.
- **Significance**: 270M-parameter function calling enables agent-like behavior on the most resource-constrained devices (IoT, embedded systems). The 58%→85% accuracy jump from fine-tuning proves that for edge agents, a dedicated trained specialist outperforms general-purpose prompting. This is orders of magnitude smaller than any competing function-calling model and directly relevant to our Phase 6 edge AI plans.
- **Source**: https://www.infoq.com/news/2026/01/functiongemma-edge-function-call/, https://ai.google.dev/gemma/docs/functiongemma

### 2025-03-12 -- Gemma 3 Released
- **What**: Gemma 3 launched in 270M, 1B, 4B, 12B, and 27B sizes. Built on Gemini 2.0 foundation. First Gemma with function calling and structured output support for agentic workflows. 128K token context window. Multimodal (image, text, video) at 4B+. Over 140 language support. Quantization-Aware Training (QAT) enables 27B on consumer GPUs (RTX 3090).
- **Significance**: Gemma 3 bridges the gap between open-weight models and agentic capabilities previously limited to closed API models. Function calling support makes it viable for building agents that can use tools.
- **Source**: https://blog.google/technology/developers/gemma-3/

## Technical Details

### Gemma 4 Model Family (April 2026)

| Variant | Parameters | Architecture | Context Window | Key Use Case |
|---------|-----------|-------------|---------------|-------------|
| 31B Dense | 31B | Dense | 256K | Maximum capability, Arena AI #3 |
| 26B MoE | 26B | Mixture of Experts | 256K | Balanced performance/efficiency, Arena AI #6 |
| E4B | ~8B (effective 4B) | MoE w/ PLE | 128K | On-device agentic workflows |
| E2B | ~5B (effective 2B) | MoE w/ PLE | 128K | Ultra-constrained devices (<1.5GB) |

**Key features**:
- Native function calling and structured JSON output (no fine-tuning needed)
- LiteRT-LM constrained decoding for reliable tool-calling
- 140+ languages
- Apache 2.0 license
- Platform: Android, iOS, Windows, Linux, macOS, WebGPU, Raspberry Pi 5, Qualcomm IQ8 NPU

### Gemma 3 Model Family

| Variant | Parameters | Modality | Key Use Case |
|---------|-----------|----------|-------------|
| 270M | 270M | Text | Task-specific fine-tuning, edge |
| 1B | 1B | Text | Lightweight applications |
| 4B | 4B | Text + Image + Video | Balanced mobile/desktop |
| 12B | 12B | Text + Image + Video | Complex tasks |
| 27B | 27B | Text + Image + Video | Maximum capability, single GPU |

### Gemma 3n (Mobile-First)

| Variant | Params | Effective Memory | Dynamic Memory |
|---------|--------|-----------------|----------------|
| E2B | 5B | ~2B equivalent | 2GB |
| E4B | 8B | ~4B equivalent | 3GB |

**Architecture innovations**:
- Per-Layer Embeddings (PLE): Reduces memory overhead
- MatFormer training: Enables nested submodels (e.g., 2B active within 4B)
- Mix'n'match: Dynamic custom submodel creation for specific tasks
- Audio processing: Native speech recognition and translation
- Interleaved multimodal inputs across modalities

### Agent Capabilities

**Function calling**: Gemma 3 supports function calling following the same pattern as Gemini -- declare tools, model generates structured function call JSON, execute and return results.

**Structured output**: JSON schema-constrained output generation for reliable data extraction and API integration.

**FunctionGemma (270M)**: Purpose-built tiny model specifically for function calling at the edge. Enables tool-using agents on extremely constrained hardware.

### Benchmarks (Gemma 3 27B)

| Benchmark | Score |
|-----------|-------|
| MMLU-Pro | 67.5% |
| MATH | 89% |
| LiveCodeBench | 29.7% |
| MMMU (multimodal) | 64.9% |

### Deployment Options
- Hugging Face (transformers, GGUF)
- Ollama (local inference)
- Kaggle (notebooks)
- Vertex AI Model Garden
- Any ONNX/GGUF compatible runtime

## Comparison Notes

**vs Anthropic Open Models**:
- Anthropic does not release open-weight models -- Claude is API-only. This makes Gemma the only option from a major AI lab for on-device/edge agent deployment
- Gemma 3's function calling brings agent capabilities to open models that would otherwise require Claude API calls
- Gemma 3n's mobile-first design (2-3GB memory) enables phone-based agents impossible with any Anthropic offering
- FunctionGemma at 270M has no equivalent in the Anthropic ecosystem
- For our Phase 6 (Edge AI + Cloud-Edge Hybrid), Gemma models are the primary candidate for on-device agent components -- ONNX/GGUF packaging aligns directly with Gemma's deployment options
- The 128K context window in Gemma 3 matches Claude's context capabilities at the open-weight level
- Quality gap: Gemma 3 27B is competitive but does not match Claude Opus or Sonnet on complex reasoning tasks; it is comparable to smaller Claude models on simpler tasks
