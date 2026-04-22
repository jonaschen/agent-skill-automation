# Multi-Agent Frameworks

**Last updated**: 2026-04-23
**Sources**:
- [AAAI-26 — FD-MAGRPO: Functionality-Driven Multi-Agent Group Relative Policy Optimization](https://aaai.org/Conferences/AAAI-26/)
- [Nature Biomedical Engineering 2026 — BioMedAgent: A Self-Evolving Multi-Agent Framework for Biomedical Data Analysis](https://www.nature.com/articles/s41551-026-03456-x)
- [arXiv:2601.05678 — MetaGen: Generative Meta-Agents for Self-Optimization](https://arxiv.org/abs/2601.05678)
- [ICLR 2026 Workshop on Multi-Agent Learning and Generative AI](https://multi-agent-learning.github.io/iclr2026/)

## Overview
Multi-agent research has transitioned from static role definitions to **dynamic, self-evolving frameworks**. The focus is on coordination efficiency, autonomous role generation during inference, and integrating multi-agent reinforcement learning (MARL) for complex resource management.

## Key Developments (reverse chronological)

### 2026-03-20 — BioMedAgent: Self-Evolving Biomedical Framework
- **What**: A multi-agent framework designed for autonomous biomedical data analysis using a three-phase collaborative process (Planning, Coding, Execution). It achieved a 77% success rate on the BioMed-AQA benchmark.
- **Significance**: Demonstrates that specialized agents can "learn" to use complex tools through interactive exploration and consensus-of-experts verification.
- **Source**: [Nature Biomedical Engineering 2026](https://www.nature.com/articles/s41551-026-03456-x)

### 2026-01-25 — FD-MAGRPO (Functionality-Driven Multi-Agent Group Relative Policy Optimization)
- **What**: A critic-free MARL framework that groups agents by functional roles. Achieved 4.8× to 13.0× speedup in convergence for complex engineering tasks.
- **Source**: [AAAI-26](https://aaai.org/Conferences/AAAI-26/)

### 2026-01-15 — MetaGen: Generative Meta-Agents for Self-Optimization
- **What**: A training-free framework where a "Meta-Agent" dynamic creates, revises, and optimizes "Worker Agent" system prompts and communication topologies during inference.
- **Significance**: Introduction of "query-conditioned role generation" allows systems to adapt to specific tasks without fixed "crew" structures. Achieved 30-40% token reduction.
- **Source**: [arXiv:2601.05678](https://arxiv.org/abs/2601.05678)

### 2025-12-15 — M-GRPO: Hierarchical Group Relative Policy Optimization
- **What**: A variant of GRPO for "Vertical Multi-Agent Systems," focusing on hierarchical credit assignment between planners and executors.
- **Source**: [ICLR 2026 Workshop](https://multi-agent-learning.github.io/iclr2026/)

## Technical Details

### Consensus-of-Experts (BioMedAgent)
BioMedAgent reduces hallucinations by 15% through a cross-verification step where sub-agents audit each other's outputs (e.g., literature citations) before final synthesis.

### Dynamic Role Generation (MetaGen)
Instead of static YAML definitions, MetaGen generates agent personas on-the-fly based on the complexity of the input query, pruning redundant roles to save tokens and reduce latency.

## Comparison Notes
| Pattern | Orchestration Style | Best For |
|---------|---------------------|----------|
| **Sequential** | Deterministic Chaining | Fixed business workflows |
| **Hierarchical** | Adaptive Delegation | Complex tasks with sub-goals |
| **Meta-Agent (Dynamic)** | Self-Optimizing | Variable tasks with unknown tool requirements |
| **LLM + MARL Hybrid** | Strategic + Reactive | Dynamic cloud/edge environments |
