# Multi-Agent Frameworks

**Last updated**: 2026-04-22
**Sources**:
- [AAAI-26 — FD-MAGRPO: Functionality-Driven Multi-Agent Group Relative Policy Optimization](https://aaai.org/Conferences/AAAI-26/)
- [Cloud Resource Allocation via Multi-Agent Reinforcement Learning and Amortized Winner Determination (March 2026)](https://www.researchgate.net/publication/378873428_Cloud_Resource_Allocation_via_Multi-Agent_Reinforcement_Learning_and_Amortized_Winner_Determination)
- [ICLR 2026 Workshop on Multi-Agent Learning and Generative AI](https://multi-agent-learning.github.io/iclr2026/)

## Overview
Multi-agent research has transitioned from simple LLM-chaining to **integrated Multi-Agent Reinforcement Learning (MARL)** frameworks. The focus is on coordination efficiency, functionality-driven roles, and decentralized orchestration for real-time resource management.

## Key Developments (reverse chronological)

### 2026-04-10 — Hybrid LLM + MARL Cloud Orchestration
- **What**: A tiered architecture where LLMs act as "Strategic Managers" (planning, anomaly analysis) while MARL agents handle "Local Execution" (atomic actions, real-time optimization).
- **Significance**: Combines the high-level reasoning of generative AI with the sub-millisecond efficiency and statistical rigor of RL. Achieved a Jain’s Fairness Index of 0.929 in cloud resource allocation tasks.
- **Source**: [ResearchGate / Industry Tech Blogs](https://www.researchgate.net/publication/378873428_Cloud_Resource_Allocation_via_Multi-Agent_Reinforcement_Learning_and_Amortized_Winner_Determination)

### 2026-01-25 — FD-MAGRPO (Functionality-Driven Multi-Agent Group Relative Policy Optimization)
- **What**: A critic-free MARL framework that extends DeepSeek's GRPO to multi-agent settings. It groups agents by **functional roles** rather than physical or structural blocks.
- **Significance**: Eliminates the instability of critic networks in high-dimensional engineering tasks. Achieved 4.8× to 13.0× speedup in convergence for complex system sizing (e.g., analog circuits).
- **Source**: [AAAI-26](https://aaai.org/Conferences/AAAI-26/)

### 2025-12-15 — M-GRPO: Hierarchical Group Relative Policy Optimization
- **What**: A variant of GRPO designed for "Vertical Multi-Agent Systems," focusing on hierarchical credit assignment between a "planner" agent and multiple "executor" sub-agents.
- **Significance**: Solves the credit assignment problem in complex delegation chains by evaluating sub-agent actions relative to the group's contribution to the planner's goal.
- **Source**: [arXiv:2512.xxxxx (Pre-print / ICLR Workshop)](https://multi-agent-learning.github.io/iclr2026/)

## Technical Details

### Critic-Free Advantage Estimation (FD-MAGRPO)
The advantage $A_i$ for agent $i$'s action is calculated relative to the mean reward of a group of $G$ sampled trajectories:
$$A_i = \frac{R_i - \text{mean}(R_1, ..., R_G)}{\text{std}(R_1, ..., R_G)}$$
This removes the need for a separate value network (Critic), reducing memory overhead and training instability.

### Functionality-Driven Grouping
Instead of grouping agents by proximity (e.g., "all agents in the same server"), agents are grouped by the **type of action** they perform (e.g., "all agents managing memory"). This enables clearer "social" learning and strategy transfer between functionally similar agents.

## Comparison Notes
| Pattern | Orchestration Style | Best For |
|---------|---------------------|----------|
| **Sequential** | Deterministic Chaining | Fixed business workflows |
| **Hierarchical** | Adaptive Delegation | Complex tasks with sub-goals (e.g., software engineering) |
| **Peer-to-Peer** | Autonomous Coordination | Real-time resource marketplaces, swarm robotics |
| **LLM + MARL Hybrid** | Strategic + Reactive | Dynamic cloud/edge environments with high uncertainty |
