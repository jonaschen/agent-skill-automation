# Gemma / Open Models

**Last updated**: 2026-04-02
**Sources**:
- https://deepmind.google/models/gemma/
- https://deepmind.google/models/gemma/gemma-3/
- https://developers.googleblog.com/en/introducing-gemma-3n/
- https://blog.google/technology/developers/gemma-3/
- https://ai.google.dev/gemma/docs/releases

## Overview

Gemma is Google DeepMind's family of open-weight models built on the same research as Gemini. Gemma 3 (March 2025) is the first version optimized for agentic workflows with function calling and structured output support. Gemma 3n (2025) adds mobile-first on-device capabilities with audio support. The family ranges from 270M to 27B parameters, with all models designed to run on a single GPU or TPU, making them ideal for edge and on-device agent deployments.

## Key Developments (reverse chronological)

### 2025-H2 -- Gemma 3n Released (Mobile-First)
- **What**: Gemma 3n launched in 5B and 8B parameter variants with Per-Layer Embeddings (PLE) innovation reducing effective memory to 2B and 4B equivalent. Features MatFormer training for nested submodels, "mix'n'match" capability for custom submodel creation. Processes audio, text, images, and video. Developed with Qualcomm, MediaTek, and Samsung. Achieves 1.5x faster mobile responses than Gemma 3 4B with better quality.
- **Significance**: First Gemma model purpose-built for on-device/mobile deployment. The 2-3GB memory footprint enables agent capabilities on smartphones. Audio support opens voice-based agent interactions on-device.
- **Source**: https://developers.googleblog.com/en/introducing-gemma-3n/

### 2025-12 -- FunctionGemma and Edge Function Calling
- **What**: FunctionGemma released at 270M parameter size. Google introduced "bespoke function calling" for edge deployment, bringing tool use capabilities to extremely small models.
- **Significance**: 270M-parameter function calling enables agent-like behavior on the most resource-constrained devices (IoT, embedded systems). This is orders of magnitude smaller than any competing function-calling model.
- **Source**: https://ai.google.dev/gemma/docs/releases

### 2025-03-12 -- Gemma 3 Released
- **What**: Gemma 3 launched in 270M, 1B, 4B, 12B, and 27B sizes. Built on Gemini 2.0 foundation. First Gemma with function calling and structured output support for agentic workflows. 128K token context window. Multimodal (image, text, video) at 4B+. Over 140 language support. Quantization-Aware Training (QAT) enables 27B on consumer GPUs (RTX 3090).
- **Significance**: Gemma 3 bridges the gap between open-weight models and agentic capabilities previously limited to closed API models. Function calling support makes it viable for building agents that can use tools.
- **Source**: https://blog.google/technology/developers/gemma-3/

## Technical Details

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
