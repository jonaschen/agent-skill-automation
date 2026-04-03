# Skill Proposal: Phase 6 Edge Model Update — Gemma 4 Replaces FunctionGemma
**Date**: 2026-04-04
**Triggered by**: Gemma 4 release — E2B achieves 86.4% τ2-bench tool use without fine-tuning, <1.5GB memory, native function calling, 4x faster + 60% less battery than predecessor, available on 140M+ Android devices
**Priority**: P1 (high)
**Target Phase**: Phase 6 (Edge AI)

## Rationale

Our ROADMAP Phase 6 was designed around FunctionGemma (270M params, 85% accuracy *after* fine-tuning) as the edge model target. Gemma 4 E2B fundamentally changes the equation:

| Criterion | FunctionGemma (old plan) | Gemma 4 E2B (new) |
|-----------|------------------------|--------------------|
| Tool use accuracy | 85% (after fine-tuning) | 86.4% (zero-shot) |
| Fine-tuning required | Yes | No |
| Memory footprint | ~300MB | <1.5GB |
| Native function calling | No (custom format) | Yes (built-in) |
| Quantization | Custom | NVIDIA NVFP4 (Blackwell) |
| Runtime support | Custom | llama.cpp, Ollama, vLLM, ONNX |

This is a simplification, not a complication. Gemma 4 eliminates the fine-tuning step entirely, supports standard inference runtimes, and achieves better accuracy out of the box.

## Proposed Specification

- **Name**: Not a new Skill — this is a ROADMAP update proposal
- **Type**: Phase 6 plan revision
- **Key Changes**:
  - Replace FunctionGemma references with Gemma 4 E2B (primary) / E4B (high-accuracy)
  - Remove the fine-tuning step from Phase 6 task 6.4 (model packaging)
  - Update `eval/edge_readiness.py` criteria: model size limit changes from ~300MB to ~1.5GB
  - Add ONNX/GGUF export paths for Gemma 4 (already supported)
  - Update Phase 3.5 distillation: Gemma 4 as alternative target alongside Haiku 4.5
  - Consider Gemma 4 + Gemini CLI as fully open-source edge deployment target

## Implementation Notes

- Gemma 4 E2B memory (<1.5GB) is larger than FunctionGemma (~300MB) but still edge-viable for modern phones and embedded devices
- NVIDIA NVFP4 quantization available for Blackwell GPUs — relevant for edge GPU deployments
- 140M+ Android devices already have Gemini Nano 4 — potential distribution channel
- llama.cpp, Ollama, and vLLM already support Gemma 4 — no custom runtime needed

## Estimated Impact

- Eliminates fine-tuning step from Phase 6 (saves ~2 weeks of development)
- Improves edge accuracy from 85% to 86.4% baseline
- Simplifies model packaging (standard runtimes instead of custom)
- Opens fully open-source deployment path (Gemma 4 + Gemini CLI)
