# Agentic Evaluations

**Last updated**: 2026-04-22
**Sources**:
- [arXiv:2604.01212 — YC-Bench: Benchmarking AI Agents for Long-Term Planning and Consistent Execution](https://arxiv.org/abs/2604.01212)
- [Amazon Holistic Agentic AI Evaluation Framework (Feb 2026)](https://aws.amazon.com/blogs/machine-learning/evaluate-agentic-ai-applications-holistically-with-amazon-bedrock/)
- [KDD 2026 Workshop on Evaluation and Trustworthiness of Agentic AI](https://agentic-eval-workshop.github.io/kdd2026/)

## Overview
Academic and industry evaluation of agentic AI has shifted from static, final-output benchmarks to **trajectory-level** and **long-horizon** assessments. The focus is now on strategic coherence, tool orchestration reliability, and the ability to maintain state across hundreds of interaction turns.

## Key Developments (reverse chronological)

### 2026-04-22 — YC-Bench: Long-Term Planning Benchmark
- **What**: A "Startup Simulation" benchmark where agents act as CEOs over a one-year horizon (hundreds of turns). Agents must manage resources, hire employees, and navigate a partially observable environment with adversarial clients (35%).
- **Significance**: Identifies a "Headroom Gap" where models fail to maintain strategic coherence over long horizons. Highlights that **scratchpad usage** is the single best predictor of success, as it allows agents to "remember" adversarial entities beyond the context window.
- **Top Performers**: Claude Opus 4.6 ($1.27M final funds), GLM-5 ($1.21M). GLM-5 achieved this at 11x lower cost.
- **Source**: [arXiv:2604.01212](https://arxiv.org/abs/2604.01212)

### 2026-02-15 — Amazon Holistic Agentic AI Evaluation Framework
- **What**: A three-layer evaluation strategy integrated into Amazon Bedrock AgentCore.
- **Significance**: Standardizes the evaluation of non-deterministic agents.
    - **Bottom Layer**: Model-level quality and latency.
    - **Middle Layer**: Component-level (intent detection, multi-turn reasoning, tool selection, memory retrieval).
    - **Upper Layer**: End-to-end task completion and alignment.
- **Source**: [Amazon Science / AWS Blog](https://aws.amazon.com/blogs/machine-learning/evaluate-agentic-ai-applications-holistically-with-amazon-bedrock/)

### 2026-01-20 — Trajectory-Level vs. Final-Output Gap
- **What**: Research indicating that agents evaluated only on final output pass 20–40% more test cases than they would under full trajectory evaluation.
- **Significance**: Proves that "hidden failures" in tool call arguments and state propagation are common even when the final goal is seemingly met, leading to brittle systems in production.
- **Source**: [KDD 2026 Workshop / Industry Research](https://agentic-eval-workshop.github.io/kdd2026/)

## Technical Details

### YC-Bench Metrics
- **Progress Rate**: Incremental achievement of quarterly goals.
- **Strategic Coherence**: The consistency of decisions over 100+ turns.
- **Adversarial Resilience**: The ability to identify and "blacklist" bad actors in the simulation.

### Amazon's "Agent Decay" Monitoring
The framework introduces "Agent Decay" detection—a metric-driven way to identify when performance degrades due to external API changes or distribution shifts in user queries, using Human-in-the-Loop (HITL) audits.

## Comparison Notes
| Dimension | Traditional LLM Eval | Agentic AI Eval (2026) |
|-----------|----------------------|-----------------------|
| **Horizon** | Single turn / Few-shot | 100+ turns (Long-horizon) |
| **Success Metric** | Perplexity / Exact Match | Goal attainment / ROI / Trajectory integrity |
| **State** | Stateless / Short context | Persistent memory / Scratchpads |
| **Environment** | Static dataset | Partially observable / Adversarial / Dynamic |
