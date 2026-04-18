# Literature Notes: Multi-Agent LLM Systems Surveys and Frameworks

**Date**: 2026-04-18
**Reviewer**: Claude paper-synthesizer

---

## [Guo et al., 2025] Multi-Agent Collaboration Mechanisms: A Survey of LLMs
**URL**: https://arxiv.org/abs/2501.06322
**Key contribution**: Comprehensive 35-page survey categorizing LLM-based multi-agent collaborative systems by type, strategy, structure, coordination, and orchestration mechanisms. Identifies key architectural patterns including chain, star, and mesh topologies.
**Relevance to our paper**: Provides the taxonomic framework for classifying our orchestration patterns. Our serial cron chain maps to their "chain" topology; our proposed Phase 5 parallel topology maps to "star" with central coordinator.
**Positioning**: Our work provides empirical production data for patterns they describe taxonomically. We contribute operational metrics (utilization, throughput, reliability) that surveys typically lack.

## [Wang et al., 2024] A Survey on LLM-based Multi-Agent System: Recent Advances and New Frontiers
**URL**: https://arxiv.org/abs/2412.17481
**Key contribution**: Broad survey of LLM-based Multi-Agent Systems covering complex task solving, scenario simulation, and generative agent evaluation. Identifies key challenges in coordination, communication, and emergent behavior.
**Relevance to our paper**: Establishes the broader MAS landscape within which our system operates. Their taxonomy of agent roles (executor, evaluator, planner) maps to our factory-steward, validator, and research-lead.
**Positioning**: Our system is a concrete production instance of the patterns they survey. We provide longitudinal operational data rather than benchmark-only evaluation.

## [Raza et al., 2026] The Orchestration of Multi-Agent Systems: Architectures, Protocols, and Enterprise Adoption
**URL**: https://arxiv.org/abs/2601.13671
**Key contribution**: Focuses specifically on orchestration architectures and protocols (A2A, MCP) for enterprise adoption. Discusses the three-layer protocol stack (MCP for tools, A2A for inter-agent communication, AP2 for payments).
**Relevance to our paper**: Directly relevant to our system's use of MCP for tool access and discussion of A2A for Phase 5. Their enterprise adoption patterns mirror our progression from single-agent to multi-agent orchestration.
**Positioning**: We provide a concrete case study of enterprise-style orchestration patterns in a production pipeline, with empirical data on adoption challenges (L7, L10, L12, L13).

## [Zhou et al., 2025] Multi-Agent Collaboration via Evolving Orchestration
**URL**: https://arxiv.org/abs/2505.19591
**Key contribution**: Proposes a "puppeteer-style" paradigm with a centralized orchestrator that dynamically directs agents via reinforcement learning. Demonstrates coordination of both heterogeneous and single-model agents.
**Relevance to our paper**: Their dynamic orchestration contrasts with our static cron-based scheduling. Their RL-based routing is analogous to our proposed TCI-based routing in Phase 5.
**Positioning**: Our work demonstrates that even static scheduling achieves 100% reliability over 14 days, suggesting the complexity of dynamic orchestration may not always be justified.

## [Li et al., 2025] AgentOrchestra: A Hierarchical Multi-Agent Framework for General-Purpose Task Solving
**URL**: https://arxiv.org/abs/2506.12508
**Key contribution**: Hierarchical framework with a central planning agent that decomposes objectives and delegates to specialized agents. General-purpose design applicable across domains.
**Relevance to our paper**: Their hierarchical decomposition pattern resembles our research-lead -> factory-steward delegation chain. Their planning agent role parallels our research-lead's directive-writing function.
**Positioning**: We demonstrate a production deployment of hierarchical orchestration with real operational data, while AgentOrchestra focuses on benchmark evaluation.

## [Patil et al., 2026] LLMs Working in Harmony: A Survey on Technological Aspects of Building Effective LLM-Based Multi Agent Systems
**URL**: https://arxiv.org/abs/2504.01963
**Key contribution**: Investigates foundational technologies for effective LLM-based MAS across four critical areas: Architecture, Memory, Planning, and Communication. Provides practical engineering guidance.
**Relevance to our paper**: Their treatment of memory (our file-based KB), planning (our structured debate), and communication (our cron-chain handoff artifacts) directly maps to our system components.
**Positioning**: Our paper provides empirical validation of the patterns they discuss theoretically, particularly around structured handoff artifacts and external memory persistence.

## [Singh et al., 2026] Agentic AI: Architectures, Taxonomies, and Evaluation of LLM Agents
**URL**: https://arxiv.org/abs/2601.12560
**Key contribution**: Unified treatment linking classical MAS with modern LLM-based frameworks, starting from a POMDP-based agentic control loop. Covers architecture, deployment, and evaluation.
**Relevance to our paper**: Their POMDP formulation provides a theoretical grounding for our agent decision-making. Their evaluation framework informs our Bayesian evaluation approach.
**Positioning**: We contribute a production-scale evaluation methodology (Bayesian CI, train/validation split) that addresses the measurement challenges they identify.

---

## Autonomous Software Engineering Agents

## [Zheng et al., 2026] Agyn: A Multi-Agent System for Team-Based Autonomous Software Engineering
**URL**: https://arxiv.org/abs/2602.01465
**Key contribution**: Fully automated multi-agent system that models software engineering as an organizational process with distinct roles (coordinator, implementer, reviewer, researcher) interacting through shared artifacts.
**Relevance to our paper**: Directly comparable to our system — both model SE as team-based with role specialization. Their coordinator/implementer/reviewer maps to our research-lead/factory-steward/validator.
**Positioning**: Our system has been in continuous production for 14+ days with real operational data. Agyn evaluates on SWE-bench; we evaluate on our own pipeline's production metrics. Our structured debate format (Innovator/Engineer) adds an adversarial decision-making layer that Agyn lacks.

## [Bhatia et al., 2026] Agent Contracts: Formal Framework for Resource-Bounded Autonomous AI Systems
**URL**: https://arxiv.org/abs/2601.08815
**Key contribution**: Extends the contract metaphor to resource governance with input/output specifications, resource constraints, temporal boundaries, and success criteria. Demonstrates 90% token reduction in iterative workflows. Accepted at COINE 2026 (co-located with AAMAS 2026).
**Relevance to our paper**: Their resource contracts parallel our Bayesian deployment gates (posterior_mean >= 0.90, ci_lower >= 0.80) and cost ceiling mechanisms. Their temporal boundaries map to our 4-hour end-to-end pipeline KPI.
**Positioning**: We implement resource governance through empirical Bayesian gates rather than formal contracts, providing a complementary approach. Our cost ceiling (5x rolling average) is a simpler but effective alternative.

## [Rasheed et al., 2025] A Practical Guide for Designing, Developing, and Deploying Production-Grade Agentic AI Workflows
**URL**: https://arxiv.org/abs/2512.08769
**Key contribution**: Practical engineering guide for production agentic AI covering heterogeneous model integration, deterministic tool calls, and environment-aware orchestration.
**Relevance to our paper**: Validates our engineering decisions around heterogeneous model deployment (Opus for reasoning, Sonnet for validation), deterministic cron scheduling, and environment-aware configuration.
**Positioning**: Our paper provides longitudinal production data that their guide lacks — 14 days of continuous operation, 69 agent sessions, 108 git commits.

## [Nguyen et al., 2026] Toward Agentic Software Project Management: A Vision and Roadmap
**URL**: https://arxiv.org/abs/2601.16392
**Key contribution**: Frames a vision for AI-driven software project management beyond code generation, covering task coordination, dependency management, and team orchestration.
**Relevance to our paper**: Our system implements several of their vision elements: autonomous task coordination (cron chain), dependency management (pipeline stages gate each other), and quality assurance (Bayesian eval gates).
**Positioning**: Our system is a concrete realization of their roadmap vision, with operational data demonstrating feasibility.

---

## Structured Debate and Adversarial Review

## [Iyengar et al., 2024] Debate, Deliberate, Decide (D3): A Cost-Aware Adversarial Framework
**URL**: https://arxiv.org/abs/2410.04663
**Key contribution**: Orchestrates structured debate among role-specialized agents (advocates, judge, jury) with budgeted stopping. Two protocols: Multi-Advocate One-Round (MORE) and Single-Advocate Multi-Round (SAMRE).
**Relevance to our paper**: Most directly relevant to our Innovator/Engineer debate format. Their multi-round protocol resembles our 3-round structured debate with ADOPT/DEFER/REJECT verdicts.
**Positioning**: Our work applies structured debate to pipeline decision-making (what to implement next) rather than evaluation/verification. We provide empirical data on debate effectiveness: 62.5% adoption rate, 35.4% pushback rate, 76.9% implementation conversion.

## [Li et al., 2025] iMAD: Intelligent Multi-Agent Debate for Efficient and Accurate LLM Inference
**URL**: https://arxiv.org/abs/2511.11306
**Key contribution**: Finds that multi-agent debate does not consistently improve response quality — in many cases single-agent output is already correct and debate may override correct answers.
**Relevance to our paper**: Important contrasting finding. Our data shows the Engineer pushback rate (35.4%) with a DEFER:REJECT ratio of 2.9:1, suggesting constructive refinement rather than harmful overriding. The debate format in our system serves a different purpose: prioritization and scope control, not answer verification.
**Positioning**: Our findings partially challenge iMAD's pessimism about debate — when debate is used for decision-making (not answer verification), the adversarial dynamic produces actionable engineering decisions with high implementation conversion rates.

## [Papadopoulos et al., 2026] Courtroom-Style Multi-Agent Debate with Progressive RAG
**URL**: https://arxiv.org/abs/2603.28488
**Key contribution**: Demonstrates effectiveness of explicit roles and adversarial interaction in high-stakes decision-making using courtroom-style simulations.
**Relevance to our paper**: Their role-based adversarial interaction parallels our Innovator/Engineer format. The "courtroom" metaphor maps to our structured ADOPT/DEFER/REJECT verdict system.
**Positioning**: We apply the adversarial review pattern to software pipeline management rather than claim verification, demonstrating broader applicability of structured debate.

---

## Production Multi-Agent Systems

## [Anthropic, 2026] How We Built Our Multi-Agent Research System
**URL**: https://www.anthropic.com/engineering/multi-agent-research-system
**Key contribution**: Detailed architecture of Anthropic's internal orchestrator-worker pattern: lead decomposes, spawns 3-5 parallel subagents, synchronous cohort completion. 90% time reduction. External memory for context window survival. Tool description quality reduced task completion by 40%.
**Relevance to our paper**: Our system is directly inspired by and validated against this architecture. Our serial cron chain is a simplified version of their orchestrator-worker pattern.
**Positioning**: We provide independent empirical validation of Anthropic's patterns in a production pipeline context, with metrics they do not publicly report (utilization rates, temporal trends, implementation conversion).

## [Anthropic, 2026] Harness Design for Long-Running Apps: Three-Agent Harness
**URL**: https://www.anthropic.com/engineering/harness-design-long-running-apps
**Key contribution**: GAN-inspired three-agent harness (Planner/Generator/Evaluator) for autonomous long-running development. Key insight: separating evaluation from generation is "a strong lever" against self-evaluation bias. Structured handoff artifacts replace shared rolling context.
**Relevance to our paper**: Our pipeline directly implements this pattern: meta-agent-factory (Generator), skill-quality-validator (Evaluator), autoresearch-optimizer (Planner). The structured handoff (JSON report) validates our architectural approach.
**Positioning**: We provide 14 days of production operational data for a system that implements this pattern, including reliability metrics (100% success rate) and throughput analysis.
