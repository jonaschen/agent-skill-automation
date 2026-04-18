# Heterogeneous Multi-Agent Orchestration for Autonomous Software Pipeline Management

**Authors**: Jonas Chen

**Draft Date**: 2026-04-18
**Status**: Phase 1 Draft (Claude Candidate)

---

*Abstract: To be written after all sections are finalized.*

---

## 1. Introduction

Managing complex software pipelines with multiple AI agents presents fundamental challenges in orchestration, quality assurance, and operational reliability. As large language model (LLM) capabilities have expanded from single-turn question answering to autonomous multi-step task execution, the question of how to effectively coordinate multiple specialized agents has become a critical engineering problem [Guo et al., 2025; Raza et al., 2026].

The transition from single-agent to multi-agent systems promises improved throughput through parallelization, better quality through role specialization, and greater robustness through redundancy. However, this transition introduces new failure modes: routing regressions when agents compete for the same prompts, measurement instability from non-deterministic LLM routing, and urgency bias where news-driven tasks perpetually displace gate-blocking work [Zheng et al., 2026; Nguyen et al., 2026].

In this paper, we present the design, implementation, and operational evaluation of a heterogeneous multi-agent orchestration system that autonomously manages a software skill automation pipeline. The system comprises 14 specialized agents spanning five functional categories (core pipeline, research, steward, paper, and strategic) that operate on a serial cron-based schedule with structured inter-agent communication via file-based artifacts.

Our contributions are:

1. **A production system description with real operational data.** We report 14 days of continuous autonomous operation (April 4--18, 2026) with 69 agent session records, 108 git commits, and 100% reliability (zero failures across all agents). Unlike benchmark-only evaluations, our data comes from a system performing real engineering work on its own codebase.

2. **An empirical comparison of orchestration patterns.** We analyze serial cron-based orchestration and find 28.3% pipeline utilization with a theoretical 1.47x parallel speedup ceiling. We identify the researcher agent as the primary bottleneck (69% of serial compute time) and show that tighter sequential coupling --- not parallelization --- is the dominant optimization opportunity.

3. **Structured adversarial debate as a decision-making mechanism.** We evaluate an Innovator/Engineer debate format across 13 discussion sessions (136 proposals) and find a 62.5% adoption rate [95% CI: 54.1%, 70.2%], 35.4% substantive pushback rate, and 76.9% date-level implementation conversion. The debate format translates research findings into actionable engineering decisions with measurable downstream impact.

4. **Lessons from production deployment.** We document 13 operational lessons learned, including that trust in automatic routing scales inversely with fleet size (L13), that agent fleets develop urgency bias toward novelty-driven tasks (L12), and that Bayesian credible intervals are the only reliable decision criterion for non-deterministic LLM evaluation (L4).

The remainder of this paper is organized as follows. Section 2 surveys related work in multi-agent systems, LLM-based agent frameworks, and autonomous software engineering. Section 3 describes our system architecture. Section 4 presents our experimental methodology. Section 5 reports results from two completed experiments. Section 6 discusses findings, implications, and limitations. Section 7 concludes with future directions.

## 2. Related Work

### 2.1 Multi-Agent Systems: Classical and LLM-Based

Multi-agent systems (MAS) have a long history in AI research, with foundational work on coordination, negotiation, and task decomposition dating to the 1980s and 1990s [Wooldridge and Jennings, 1995; Ferber, 1999]. Classical MAS research established core architectural patterns --- centralized coordinator, distributed peer-to-peer, and hierarchical delegation --- that remain relevant in the LLM era.

The emergence of LLM-based multi-agent systems has rekindled interest in MAS, now with agents powered by large language models rather than hand-coded rules. Guo et al. [2025] survey multi-agent collaboration mechanisms for LLMs across 35 pages, categorizing systems by type, strategy, structure, and coordination mechanism. They identify chain (sequential), star (centralized coordinator), and mesh (decentralized) topologies --- our serial cron chain implements their chain topology, while our proposed Phase 5 design targets a star topology with TCI-based routing.

Wang et al. [2024] provide a broad survey of LLM-based MAS covering complex task solving, scenario simulation, and agent evaluation. They identify key challenges in coordination, communication, and emergent behavior that we encounter in production: specifically, the routing regression problem when adding agents to a fleet (our Lesson L7) and the measurement instability of non-deterministic LLM evaluation (our Lessons L4, L10).

Singh et al. [2026] offer a unified treatment linking classical MAS with modern LLM-based frameworks through a POMDP-based agentic control loop. Their evaluation framework informs our Bayesian approach to trigger rate assessment, where we model each skill's routing accuracy as a Beta distribution rather than a point estimate.

### 2.2 Agent Orchestration Frameworks

The agentic AI ecosystem has rapidly developed standardized frameworks and protocols for agent orchestration. Two protocol layers have emerged as de facto standards: the Model Context Protocol (MCP) [Anthropic, 2024] for agent-to-tool communication and the Agent-to-Agent Protocol (A2A) [Google, 2025] for inter-agent coordination [Raza et al., 2026].

MCP, created by Anthropic and now governed by the Linux Foundation's Agentic AI Foundation (AAIF), standardizes how agents connect to tools, data sources, and APIs. As of April 2026, MCP has achieved 97 million monthly SDK downloads and 10,000+ public servers [Anthropic, 2026]. Our system uses MCP indirectly through Claude Code's tool interface but does not implement MCP servers directly.

A2A, created by Google and also governed by AAIF, standardizes agent discovery and inter-agent communication. A2A v1.0 reached production readiness in March 2026 with support from 150+ organizations including all three major cloud providers (Azure AI Foundry, AWS Bedrock AgentCore, Google Cloud) [A2A Project, 2026]. Our system does not currently use A2A but has evaluated it for Phase 5 multi-agent topology design.

On the framework side, Google's Agent Development Kit (ADK) [Google, 2025] provides a code-first framework for multi-agent systems with graph-based workflow execution (v2.0 alpha). Anthropic's Agent SDK [Anthropic, 2026] enables programmatic agent orchestration with subagent transcript inspection and distributed tracing. Our system currently uses Claude Code's CLI interface (`claude -p`) rather than the Agent SDK, with migration planned for Phase 5.

Anthropic has formalized four multi-agent patterns: Agent Teams (parallel coordination with independent contexts), Subagents (same-session delegation), Three-Agent Harness (Planner/Generator/Evaluator with structured handoffs), and Orchestrator-Worker (lead decomposes, specialists execute in parallel) [Anthropic, 2026]. Our pipeline implements a variant of the Three-Agent Harness pattern, and our research chain implements a simplified Orchestrator-Worker pattern.

Zhou et al. [2025] propose "evolving orchestration" with a centralized RL-trained orchestrator that dynamically sequences agents. Li et al. [2025] present AgentOrchestra, a hierarchical framework for general-purpose task solving. These dynamic approaches contrast with our static cron-based scheduling, which we show achieves 100% reliability at the cost of 71.7% idle time.

### 2.3 Autonomous Software Engineering Agents

The application of LLM agents to software engineering has accelerated rapidly. SWE-bench Verified scores reached 80.9% by March 2026 (Claude Opus 4.5), with the top five models separated by less than one percentage point [SWE-bench, 2026]. Opus 4.7, released April 16, 2026, extended this to 87.6%.

Zheng et al. [2026] present Agyn, a multi-agent system that models software engineering as an organizational process with coordinator, implementer, reviewer, and researcher roles interacting through shared artifacts. This directly parallels our system's role specialization (research-lead as coordinator, factory-steward as implementer, skill-quality-validator as reviewer, agentic-ai-researcher as researcher), though our system operates continuously in production rather than on benchmark tasks.

Bhatia et al. [2026] introduce Agent Contracts, a formal framework for resource-bounded autonomous AI systems, demonstrating 90% token reduction in iterative workflows through explicit resource constraints and success criteria. Their contract metaphor complements our Bayesian deployment gates, which serve a similar governance function (posterior_mean >= 0.90 AND ci_lower >= 0.80) but are derived empirically rather than specified formally.

Anthropic demonstrated the most ambitious multi-agent software engineering benchmark to date: a 16-agent team producing a 100,000-line Rust-based C compiler capable of compiling the Linux kernel, over approximately 2,000 sessions at $20,000 in API costs [Anthropic, 2026]. This establishes the upper bound of what coordinated agent teams can produce.

Nguyen et al. [2026] articulate a vision for agentic software project management beyond code generation, covering task coordination, dependency management, and team orchestration. Our system realizes several elements of their vision: autonomous task coordination through cron scheduling, dependency management through pipeline stage gating, and quality assurance through Bayesian evaluation gates.

### 2.4 Structured Debate in Multi-Agent Systems

The use of debate and adversarial review as multi-agent decision-making mechanisms has received growing attention. Iyengar et al. [2024] propose D3 (Debate, Deliberate, Decide), a cost-aware adversarial framework with role-specialized agents (advocates, judge, jury) and budgeted stopping. Their multi-round protocol resembles our Innovator/Engineer debate, though they apply it to evaluation rather than prioritization.

Li et al. [2025] present iMAD, finding that multi-agent debate does not consistently improve response quality and may override correct single-agent answers. This contrasting finding is important context for our work: we apply structured debate to *decision-making* (what should the pipeline implement next?) rather than *answer verification*, and our empirical results show strong implementation conversion (76.9% of discussion dates produce committed code).

Papadopoulos et al. [2026] demonstrate courtroom-style multi-agent debate for claim verification, showing the effectiveness of explicit roles and adversarial interaction. Our Innovator/Engineer format follows a similar principle --- explicit role separation between a creative proposer and a conservative engineer --- but applies it to software pipeline management rather than factual verification.

### 2.5 Positioning Our Work

Our system differs from prior work in three key dimensions. First, we report on a *production* system with 14 days of continuous autonomous operation, not a benchmark evaluation or simulation. Second, we combine orchestration pattern analysis with structured debate effectiveness analysis, addressing both the *how* (orchestration topology) and *what* (decision-making mechanism) of multi-agent coordination. Third, our system operates on its own codebase --- the agents manage the pipeline that produces and evaluates agents --- creating a self-referential development loop that is unique in the literature.

## 3. System Design

### 3.1 Architecture Overview

The system implements a seven-phase pipeline for autonomously designing, validating, optimizing, and deploying Claude Code Agent Skills. Phases 0--4 (complete) build the core automation loop; Phases 5--7 (planned) extend to multi-agent topology, edge AI, and commercial deployment. This paper focuses on the operational Phase 4 system.

The pipeline follows a linear architecture:

```
Human (requirements)
    |
    v
meta-agent-factory --> .claude/skills/<name>/SKILL.md
    |
    v
skill-quality-validator --> JSON report {trigger_rate, ci_lower, ci_upper}
    |-- posterior_mean >= 0.90, ci_lower >= 0.80 --> agentic-cicd-gate (deploy)
    '-- below threshold --> autoresearch-optimizer (auto-repair, <= 50 iterations)
```

The core pipeline transforms natural language requirements into deployed, quality-gated Agent Skills through four stages: generation (meta-agent-factory), validation (skill-quality-validator), optimization (autoresearch-optimizer), and deployment (agentic-cicd-gate). Each stage produces structured artifacts that serve as input to the next, implementing Anthropic's recommended "structured handoff artifacts" pattern [Anthropic, 2026].

### 3.2 Agent Taxonomy

The system comprises 14 agents across five functional categories:

**Table 1: Agent Taxonomy**

| Category | Agent | Role | Model |
|----------|-------|------|-------|
| Core Pipeline | meta-agent-factory | Generate SKILL.md from requirements | Opus 4.6 |
| Core Pipeline | skill-quality-validator | 5-step validation, JSON report | Sonnet 4.6 |
| Core Pipeline | autoresearch-optimizer | Binary eval loop, parallel branch search | Opus 4.6 |
| Core Pipeline | agentic-cicd-gate | Deployment gating, rollback | Sonnet 4.6 |
| Core Pipeline | changeling-router | Dynamic identity switching | Sonnet 4.6 |
| Research | agentic-ai-researcher | L1--L5 research sweep | Opus 4.6 |
| Research | agentic-ai-research-lead | Strategic direction, debate facilitation | Opus 4.6 |
| Steward | factory-steward | Pipeline implementation work | Opus 4.6 |
| Steward | ltc-steward | Long-term-care-expert project maintenance | Opus 4.6 |
| Paper | paper-synthesizer | Academic paper writing | Opus 4.6 |
| Paper | experiment-designer | Experiment design and statistical analysis | Opus 4.6 |
| Paper | peer-reviewer | Cross-team paper review | Sonnet 4.6 |
| Strategic | topology-aware-router | TCI-based task routing | Sonnet 4.6 |
| Strategic | sprint-orchestrator | Agile ceremony facilitation | Sonnet 4.6 |

The taxonomy reflects a design principle of **mutually exclusive permissions**: review/validation agents (skill-quality-validator, agentic-cicd-gate, peer-reviewer) are denied Write and Edit tools, while execution agents are denied the Task delegation tool. This separation is enforced by a static permission checker (`check-permissions.sh`) and was inspired by Anthropic's observation that "separating evaluation from generation is a strong lever" against self-evaluation bias [Anthropic, 2026].

### 3.3 Orchestration Patterns

The system employs three orchestration patterns:

**Pattern 1: Serial Cron Chain.** The primary orchestration mechanism is a three-agent serial chain triggered by cron jobs at fixed intervals:

- 1:00 AM: `agentic-ai-researcher` performs L1--L5 research sweep
- 2:00 AM: `agentic-ai-research-lead` reviews output, writes priority directive
- 3:00 AM: `factory-steward` implements ADOPT items from directive

This chain runs twice daily (night cycle 1--3 AM, morning cycle 12--2 PM, Asia/Taipei timezone). Inter-agent communication is mediated by file-based artifacts: the researcher writes sweep reports and knowledge base updates; the research-lead writes priority directives; the factory-steward reads directives and implements prioritized items.

**Pattern 2: Structured Adversarial Debate.** The research-lead agent uses an Innovator/Engineer debate format to evaluate proposals from the researcher. The Innovator role proposes new capabilities or changes; the Engineer role applies scope reduction, timing adjustment, architectural correction, and risk gating. Each proposal receives an ADOPT, DEFER, or REJECT verdict. This pattern is used within a single agent session through prompt-engineered role separation, not through separate agent instances.

**Pattern 3: Delegation via Task Tool.** Several agents (meta-agent-factory, topology-aware-router, sprint-orchestrator) can delegate subtasks to specialized subagents via the Task tool. This creates dynamic fan-out patterns within an agent session. The subagent operates with its own context window, reports results to the parent, and terminates.

### 3.4 Measurement Infrastructure

Skill routing in Claude Code is probabilistic: the model reads a skill's `description` field and decides --- non-deterministically --- whether the skill applies to a given prompt. This creates a measurement problem where a single evaluation run gives one sample from a distribution, not a definitive answer. A skill achieving 0.77 on one run may achieve 0.50 on the next, not because the skill changed but because the routing decision is noisy.

We address this through four mechanisms:

1. **Bayesian Evaluation** (`bayesian_eval.py`): Models trigger rate as a Beta(K+1, N-K+1) posterior with 95% credible intervals. Optimization commits are accepted only when `new_ci_lower > old_ci_upper` (non-overlapping credible intervals).

2. **Async Evaluation with Backoff** (`run_eval_async.py`): Sequential test execution with exponential backoff and configurable inter-test delay (15--30s), preventing API quota burst that would corrupt measurements.

3. **Semantic Cache** (`prompt_cache.py`): Caches routing decisions keyed on `(prompt_hash, description_hash)`. Negative tests are cached description-invariantly, reducing API calls by approximately 40% per optimizer iteration.

4. **Train/Validation Split** (`splits.json`): 39 training prompts (optimizer iterates on these) and 20 validation prompts (held-out honesty check). Both sets include >= 30% negative controls (hallucination traps, near-miss prompts, cross-domain conflicts) to prevent overfitting.

The evaluation suite comprises 59 test prompts: 22 positive cases, 17 hallucination traps, 5 cross-domain conflicts, 10 near-miss negatives, and 5 real-world negatives promoted from production skill usage logs.

### 3.5 Design Decisions and Rationale

Several design decisions merit discussion:

**Why serial cron, not event-driven?** The serial cron chain was chosen for simplicity and reliability. Event-driven activation (e.g., MCP Triggers & Events, expected mid-2026) would reduce idle time but introduces failure modes around event delivery guarantees and concurrent agent execution. The 28.3% utilization rate is acceptable given 100% reliability.

**Why file-based inter-agent communication, not message passing?** Structured files (sweep reports, priority directives, JSON performance records) provide durability, inspectability, and version control via git. This follows the "structured handoff artifacts" pattern recommended by Anthropic's three-agent harness architecture [Anthropic, 2026] and avoids the "shared rolling context" anti-pattern that can cause models to become overly cautious near context limits.

**Why Bayesian gates, not fixed thresholds?** Non-deterministic LLM routing means a fixed pass/fail threshold is unreliable. Two runs of the same skill may produce different trigger rates due to model sampling, rate-limit degradation, or background API load. The Bayesian approach models the true trigger rate as a distribution and requires non-overlapping credible intervals to commit changes, eliminating measurement noise from decision-making (Lesson L4).

**Why mutually exclusive permissions?** The separation of validation agents (no Write/Edit) from execution agents (no Task delegation) prevents self-evaluation bias --- the tendency for agents to approve their own work. This mirrors Anthropic's finding that "agents tend to confidently praise their own work even when quality is obviously mediocre" [Anthropic, 2026]. The constraint is enforced statically by `check-permissions.sh`, not by model behavior, making it robust to prompt injection.

## 4. Methodology

### 4.1 Research Questions

Our evaluation addresses three research questions:

- **RQ1**: What is the throughput efficiency and reliability profile of serial cron-based orchestration in a production multi-agent pipeline?
- **RQ2**: Does structured adversarial debate (Innovator/Engineer format) produce actionable engineering decisions with measurable implementation conversion?
- **RQ3**: (Phase 2, ongoing) Do heterogeneous agent teams (Claude + Gemini) working independently on the same task produce research outputs with broader coverage than either team alone?

### 4.2 Experiment 1: Orchestration Topology Comparison

**Hypothesis.** Serial cron-based orchestration results in lower throughput efficiency than the theoretical parallel execution ceiling, with idle time between stages representing recoverable waste.

**Data Sources.** Performance JSON records from `logs/performance/` for researcher (N=12), research-lead (N=1), and factory-steward (N=13) agents, covering April 4--18, 2026. Each record contains: agent type, date, duration (seconds), exit code, commits made, files changed, KB files updated, and effort level.

**Metrics.**
- *Throughput*: commits/hour and files/hour per agent
- *Pipeline utilization*: active compute time / cron wall-clock allocation
- *Parallel ceiling*: max(individual durations) vs. sum(individual durations)
- *Reliability*: proportion of runs with exit_code=0
- *Temporal trends*: Spearman rank correlation between date and output metrics

**Statistical Analysis.** Mann-Whitney U test for between-agent comparisons (alpha=0.05, with Bonferroni correction for multiple comparisons). Effect sizes reported as rank-biserial correlation. Confidence intervals for proportions computed using the Wilson score interval. Power analysis: with N=12--13, we have power to detect large effects (Cohen's d > 0.8) but may miss medium effects.

### 4.3 Experiment 2: Structured Debate Effectiveness

**Hypothesis.** The Innovator/Engineer structured debate format produces proposals with high implementation conversion rates and demonstrates substantive adversarial review.

**Data Sources.** Discussion transcripts from `knowledge_base/agentic-ai/discussions/` (13 transcripts, April 5--18, 2026), git log for implementation evidence (108 commits), and L4 proposals from `knowledge_base/agentic-ai/proposals/` for baseline comparison.

**Metrics.**
- *ADOPT/DEFER/REJECT distribution*: count per discussion, overall proportions with 95% Wilson confidence intervals
- *Implementation conversion*: proportion of ADOPT items appearing as git commits within 7 days
- *Engineer pushback rate*: proportion of proposals where the Engineer defers, rejects, or adds conditions
- *Temporal trend*: Spearman correlation between discussion date and adoption rate

**Measurement Definitions.** An ADOPT item is "implemented" if a git commit message references it by name or ID, or the specific file/change it proposes appears in git diff within 7 days. The pushback rate measures the proportion of Innovator proposals where the Engineer either rejects outright, proposes a simpler alternative, or adds conditions before accepting.

### 4.4 Experiment 3: Cross-Vendor Orchestration (Phase 2)

This experiment will compare independent paper candidates produced by Claude and Gemini teams working from the same knowledge base. Metrics include topic coverage (Jaccard similarity), unique insight count, cross-cutting reference count, and citation diversity. As a case study (N=2), findings will be framed as qualitative comparative analysis. Results are pending Phase 2 execution.

### 4.5 Threats to Validity

**Internal validity.** Agents run on the same machine; background load may affect duration. No randomization of run order (fixed cron schedule). The structured debate's Innovator and Engineer are implemented as prompt-engineered roles within the same LLM, not as separate agents with different capabilities.

**External validity.** Single pipeline instance with a specific task distribution (skill generation, research, code implementation). Results may not generalize to other multi-agent systems, other task domains, or other model families. The small sample sizes (N=12--13 per agent, N=13 discussions) limit statistical power to large effect sizes.

**Construct validity.** Duration is used as a proxy for compute cost, but actual token count would be more precise. File counts do not measure output quality. Implementation conversion is measured by git commit presence, which may undercount implementations committed under different names or overcount commits that reference but do not fully implement an ADOPT item.

## 5. Results

### 5.1 Experiment 1: Orchestration Topology Comparison

#### 5.1.1 Per-Agent Performance

Table 2 summarizes the descriptive statistics for each agent in the serial chain.

**Table 2: Per-Agent Performance Statistics**

| Metric | Researcher (N=12) | Research-Lead (N=1) | Factory-Steward (N=13) |
|--------|-------------------|--------------------|-----------------------|
| Duration mean (s) | 2117.9 | 264.0 | 839.2 |
| Duration median (s) | 2011.5 | 264.0 | 837.0 |
| Duration std (s) | 431.1 | -- | 185.7 |
| Duration 95% CI (s) | [1874.0, 2361.9] | -- | [738.3, 940.2] |
| Commits mean | 0.83 | 2.0 | 2.08 |
| Files changed mean | 18.83 | 14.0 | 10.31 |
| Success rate | 100% (12/12) | 100% (1/1) | 100% (13/13) |

The researcher agent dominates pipeline duration (mean 35.3 minutes vs. factory-steward's 14.0 minutes). A Mann-Whitney U test confirms this difference is statistically significant (U=156.0, p<0.001, rank-biserial r=1.0), with every researcher session longer than every factory-steward session.

Despite the duration difference, files-per-minute efficiency does not differ significantly between agents (U=69.0, p=0.218, rank-biserial r=0.327), suggesting comparable productivity per unit of compute time.

#### 5.1.2 Throughput Metrics

**Table 3: Agent Throughput Comparison**

| Agent | Commits/hour | Files/hour |
|-------|-------------|------------|
| Researcher | 2.10 | 47.27 |
| Factory-Steward | 8.99 | 43.12 |

The factory-steward produces 4.3x more commits per hour than the researcher, reflecting its focused implementation role versus the researcher's broad scanning role. Files-per-hour rates are comparable (47.3 vs. 43.1).

#### 5.1.3 Pipeline Utilization

**Table 4: Pipeline Utilization Analysis (N=11 common dates)**

| Metric | Value |
|--------|-------|
| Mean serial compute time | 51.0 min |
| Cron wall-clock allocation | 180 min |
| **Pipeline utilization** | **28.3%** |
| Parallel ceiling | 34.8 min |
| **Parallel speedup** | **1.47x** |
| Idle time (mean) | 129.0 min |

Only 28.3% of the 3-hour cron window is spent on active compute. The remaining 71.7% is inter-agent idle time waiting for the next cron trigger. If all three agents ran simultaneously, total wall-clock time would reduce from 51.0 to 34.8 minutes --- a 1.47x speedup.

The modest parallel speedup (1.47x vs. theoretical 3x) reflects the researcher's dominance: it accounts for approximately 69% of total serial compute time. The parallel ceiling is bounded by the researcher's duration since it is the slowest agent.

#### 5.1.4 Temporal Trends

**Table 5: Temporal Trend Analysis (Spearman Rank Correlation)**

| Agent | Metric | rho | p-value | Significant? |
|-------|--------|-----|---------|-------------|
| Researcher | Duration | 0.441 | 0.121 | No |
| Researcher | Files changed | **0.944** | **<0.001** | **Yes** |
| Factory-Steward | Duration | -0.209 | 0.479 | No |
| Factory-Steward | Files changed | 0.082 | 0.784 | No |

The researcher's output (files changed) shows a strong, statistically significant increasing trend (rho=0.944, p<0.001). This reflects infrastructure maturation --- the researcher produced zero files in the first four runs (April 4--7, before KB write infrastructure was operational) and consistently produced 22--34 files per run from April 8 onward. This is not a learning effect but rather a capability bootstrapping artifact.

#### 5.1.5 Reliability

All agents achieved 100% reliability (exit_code=0) across the entire 14-day observation period. No skipped runs, no recovery events, and no manual interventions were required. This finding supports the serial cron model as a robust baseline for multi-agent orchestration, albeit at the cost of low utilization.

#### 5.1.6 Supplementary Agents

Beyond the serial chain, the pipeline operated 5 additional agent types during portions of the observation period. Table 6 reports their performance before suspension on April 17.

**Table 6: Supplementary Agent Performance**

| Agent | N | Mean Duration (s) | Mean Commits | Status |
|-------|---|-------------------|-------------|--------|
| android-sw-steward | 9 | 839 | 1.78 | Suspended |
| arm-mrs-steward | 8 | 1042 | 1.38 | Suspended |
| bsp-knowledge-steward | 8 | 2367 | 2.00 | Suspended |
| ltc-steward | 7 | 618 | 2.00 | Active |
| project-reviewer | 9 | 284 | 1.00 | Suspended |

The bsp-knowledge-steward is an outlier with mean duration of 2367s (39.5 min), exceeding even the researcher. This reflects the complexity of its target project (Kuzu graph database), not an orchestration inefficiency.

### 5.2 Experiment 2: Structured Debate Effectiveness

#### 5.2.1 Overall Distribution

Across 13 discussion sessions spanning 14 calendar days, the Innovator/Engineer debate produced 136 proposals.

**Table 7: ADOPT/DEFER/REJECT Distribution**

| Category | Count | Rate | 95% Wilson CI |
|----------|-------|------|---------------|
| ADOPT | 85 | 62.5% | [54.1%, 70.2%] |
| DEFER | 38 | 27.9% | -- |
| REJECT | 13 | 9.6% | -- |
| **Total** | **136** | 100% | -- |

The mean number of proposals per discussion was 10.5 (range: 6--15). The standard format used 3 rounds per discussion, with later discussions (starting April 16) expanding to 6 sub-rounds while maintaining similar adoption rates.

#### 5.2.2 Per-Discussion Adoption Rate

**Table 8: Per-Discussion Adoption Rate Statistics**

| Metric | Value |
|--------|-------|
| Mean | 0.646 |
| Median | 0.600 |
| Std Dev | 0.200 |
| 95% CI | [0.537, 0.755] |
| Range | [0.333, 1.000] |

Adoption rates vary substantially across discussions (range 0.333 to 1.000). The lowest rate (0.333, April 7) reflected a session dominated by DEFER verdicts on speculative proposals. The highest rates (1.000, April 16 and April 18 day) occurred during sessions focused on concrete, immediately actionable items.

#### 5.2.3 Engineer Pushback Analysis

The Engineer pushes back on 35.4% of proposals [95% CI: 24.5%, 46.2%]. DEFER (27.9% of all verdicts) is 2.9x more common than REJECT (9.6%), indicating the Engineer typically redirects rather than blocks.

We observe five distinct pushback patterns:

1. **Scope reduction**: "ADOPT but simplified version" (most frequent)
2. **Timing adjustment**: "DEFER to Phase 5" or "DEFER until precondition met"
3. **Architectural correction**: "The proposal misunderstands our architecture"
4. **Risk gating**: "ADOPT contingent on verification"
5. **Full rejection**: "REJECT --- building toward leaked internal software is poor engineering" (rare)

This pushback profile is consistent with a constructive adversarial dynamic where the Engineer refines proposals rather than dismissing them. The predominance of DEFER over REJECT (2.9:1 ratio) suggests the debate format surfaces proposals at the right thematic level but sometimes at the wrong time or scope.

#### 5.2.4 Implementation Conversion

ADOPT items were cross-referenced against git log (108 total commits since April 4, 2026).

**Table 9: Implementation Conversion Metrics**

| Metric | Value |
|--------|-------|
| Discussion dates with implementation commits | 10 / 13 (76.9%) |
| Git commits explicitly referencing ADOPT items | 14 |
| Total factory-steward commits | 67 |
| ADOPT-referencing commits as % of factory commits | 20.9% |

The 76.9% date-level conversion rate demonstrates a clear pipeline from structured debate to engineering implementation. Notable implementation commits include session state logging (April 12 ADOPT), researcher lazy provisioning (April 12 ADOPT), and fleet version checks (April 10 ADOPT).

The 20.9% figure (14/67 factory commits reference ADOPT items) represents a lower bound --- factory-steward also implements items from the research-lead's priority directives that originate as ADOPT items but are not explicitly referenced in commit messages.

#### 5.2.5 Temporal Trends

No significant temporal trend was detected in adoption rate (Spearman rho=0.302, p=0.293). Comparing early (April 5--9, N=5) and late (April 10--18, N=8) periods, the aggregate adoption rate increased from 0.571 to 0.662 (+9.1 percentage points), but this difference is not statistically significant given the sample size and variance.

#### 5.2.6 Priority Distribution

Priority labels across all discussions show a concentration at P1--P2:

| Priority | Mentions |
|----------|---------|
| P0 (Critical) | 78 |
| P1 (High) | 109 |
| P2 (Medium) | 98 |
| P3 (Low) | 20 |

The predominance of P1--P2 priorities (67.9%) suggests the debate format naturally surfaces implementable medium-term improvements rather than exclusively urgent fixes or speculative exploration.

## 6. Discussion

### 6.1 Serial Orchestration: Reliability vs. Utilization Tradeoff

Our results reveal a clear tradeoff in serial cron-based orchestration: perfect reliability (100% success rate over 14 days, zero manual interventions) at the cost of low utilization (28.3%). This finding has practical implications for multi-agent system design.

The 1.47x parallel speedup ceiling suggests that naive parallelization offers modest gains because the pipeline is bottlenecked on a single agent (the researcher, which consumes 69% of serial compute time). More impactful optimizations would be: (a) reducing the researcher's duration (currently 35.3 min mean), (b) triggering the research-lead and factory-steward immediately after the researcher completes rather than waiting for fixed cron intervals, or (c) splitting the researcher's workload across multiple parallel researcher instances.

This finding aligns with Amdahl's law: the maximum speedup from parallelization is limited by the serial fraction of the workload. In our case, the "serial fraction" is the researcher agent, which must complete before downstream agents can meaningfully begin.

The 100% reliability finding is noteworthy given that all agents operate autonomously without human monitoring. Each agent session involves multiple LLM inference calls, tool executions, and git operations, yet no session failed over the 14-day observation period. We attribute this to three factors: (a) the cron model eliminates concurrency-related failures, (b) each agent operates on a well-defined task scope within a familiar codebase, and (c) the file-based inter-agent communication avoids the failure modes of real-time message passing (dropped messages, ordering violations, delivery timeouts).

### 6.2 Structured Debate as Pipeline Governance

The Innovator/Engineer debate format emerges as an effective governance mechanism for multi-agent pipelines. The 62.5% adoption rate (not 100%) combined with 35.4% substantive pushback demonstrates that the format provides genuine adversarial review, not rubber-stamping. This is consistent with Iyengar et al.'s [2024] D3 framework, which argues that structured roles improve decision quality over unstructured deliberation.

Importantly, our findings differ from iMAD's [Li et al., 2025] pessimistic assessment of multi-agent debate. The key difference is the *application domain*: iMAD evaluates debate for answer verification (where the single-agent answer may already be correct), while we apply debate to *prioritization and scope control* (where the question is not "what is correct?" but "what should we build next?"). In this latter context, the adversarial dynamic is consistently valuable because it prevents scope creep, premature implementation, and architectural misunderstandings.

The 76.9% implementation conversion rate demonstrates that debate outputs translate to concrete engineering action. The pipeline from debate to implementation follows a clear chain: researcher produces sweep reports -> research-lead conducts Innovator/Engineer debate -> ADOPT items enter priority directive -> factory-steward implements during next cron cycle. This chain averages approximately 3 hours from ADOPT verdict to implementation commit (one cron cycle interval).

### 6.3 Lessons for Multi-Agent System Design

Our 14-day production deployment yielded 13 operational lessons. We highlight three with broader applicability:

**L4: Bayesian credible intervals are the only reliable decision criterion.** Raw pass rate differences between evaluation runs can be measurement noise. We observed a skill's trigger rate fluctuate between 0.50 and 0.77 across consecutive runs with identical descriptions. Only by modeling the trigger rate as a Beta posterior and requiring non-overlapping 95% credible intervals to commit changes could we distinguish genuine improvements from noise. This finding applies to any system that evaluates non-deterministic LLM behavior.

**L12: Agent fleets develop urgency bias.** Researcher-sourced items (CVEs, new API releases, deprecation notices) carry novelty heat that makes them feel urgent. Gate-blocking tasks (stress test execution, cost analysis) have no "news" and are perpetually deferred. Over 20 sessions, we observed 20+ commits of observability and security hardening but zero execution of a critical stress test. This is classic firefighting culture encoded in an agent fleet. Our mitigation (gate-priority triage: if any Phase gate-blocker is untouched, skip ADOPT/proposals entirely) was effective but required explicit countermeasure design.

**L13: Trust in automatic routing scales inversely with fleet size.** With 5 agents, a generic prompt like "Create a Kubernetes skill" correctly routes to meta-agent-factory. With 15 agents, the same prompt was intercepted by steward agents, changeling-router, and other agents that explored the request for 2--6 minutes without producing output. Every script-initiated `claude -p` call that depends on specific agent behavior must explicitly name the target agent. This finding has direct implications for any multi-agent system that relies on implicit intent-based routing.

### 6.4 Comparison with Industry Patterns

Our system implements a variant of Anthropic's Three-Agent Harness pattern (Planner/Generator/Evaluator) in the core pipeline and a simplified Orchestrator-Worker pattern in the research chain. Comparing our production metrics to Anthropic's published figures:

- **Iteration cadence**: Anthropic reports 5--15 iterations over approximately 4 hours for the three-agent harness. Our optimizer runs up to 50 iterations but our end-to-end pipeline target is also 4 hours per skill (Phase 4 KPI).
- **Cost**: Anthropic reports $124--200 per complex harness run. Our per-skill pipeline cost averages approximately 5.7 minutes of compute (estimated from stress test data), with fleet daily compute at 2.3 hours across 6 agents.
- **Reliability**: Anthropic does not report reliability metrics for their harness. Our 100% success rate over 14 days provides a strong baseline.
- **Orchestration overhead**: Anthropic's orchestrator-worker achieves 90% time reduction for complex research queries. Our serial chain has 71.7% idle time, suggesting significant room for improvement through tighter coupling.

### 6.5 Threats to Validity

**Internal threats.** The structured debate's Innovator and Engineer are prompt-engineered roles within the same LLM, not separate agents with different capabilities. Differences in debate dynamics may reflect prompt design rather than inherent debate value. No randomized control (debate vs. no-debate) was conducted.

**External threats.** Our findings are specific to one pipeline (skill automation), one model family (Claude Opus/Sonnet 4.6), one task distribution (research + implementation + validation), and one codebase. The small sample sizes (N=12--13 per agent, N=13 discussions) limit statistical power to large effects. We frame our results as preliminary evidence from a single production deployment, not as generalizable principles.

**Construct threats.** Duration is an imperfect proxy for cost (actual token count would be more precise). Implementation conversion measured by git commit references is a lower bound. The 100% reliability may partly reflect the simplicity of the current pipeline (no concurrent execution, no shared mutable state) rather than inherent robustness of the orchestration pattern.

### 6.6 Limitations

1. **No randomized experimental design.** All comparisons are observational. The topology comparison is between our actual system (serial cron) and a theoretical alternative (parallel execution ceiling), not between two implemented systems.

2. **Same underlying model for debate roles.** Both Innovator and Engineer are implemented as the same LLM (research-lead agent with different prompt-engineered roles). True multi-agent debate would use separate model instances with different training or fine-tuning.

3. **Single pipeline instance.** We cannot assess how our findings generalize across different task domains, team sizes, or model families.

4. **Specificity scoring not completed.** The protocol specified a 0--3 specificity score per proposal, which would require manual annotation of 136 proposals. This was not completed in this analysis pass and is planned for Phase 2.

5. **Research-lead has N=1.** The research-lead agent was activated on April 18 (the final day of the observation period), providing only a single data point for its performance characteristics.

## 7. Conclusion and Future Work

### 7.1 Summary of Contributions

We presented the design, implementation, and operational evaluation of a heterogeneous multi-agent orchestration system managing an autonomous software pipeline. Our key findings are:

1. Serial cron-based orchestration achieves 100% reliability over 14 days of continuous autonomous operation, at the cost of 28.3% pipeline utilization. The parallel speedup ceiling is a modest 1.47x due to bottleneck dominance by the researcher agent.

2. Structured adversarial debate (Innovator/Engineer format) produces actionable engineering decisions with 62.5% adoption rate and 76.9% implementation conversion, demonstrating that debate-as-governance is effective for multi-agent pipeline management.

3. Production deployment of multi-agent systems yields operational lessons that benchmark evaluations cannot surface, including urgency bias in agent fleets, routing regressions from fleet expansion, and the necessity of Bayesian evaluation for non-deterministic systems.

### 7.2 Future Work

Three strategic priorities shape our future research:

**S1: Automatic Agent/Skill Improvement.** Building a meta-optimization layer that detects when new model capabilities make current agent approaches suboptimal and automatically generates upgrade tasks. The current autoresearch-optimizer improves trigger descriptions; the next step is a "capability diff" system that compares new model releases against agent assumptions and generates adaptation tasks.

**S2: Multi-Agent Orchestration (continued).** Phase 5 will implement topology-aware routing using Task Coupling Index (TCI) scores to select between parallel and sequential execution patterns. The TCI router will dispatch low-coupling tasks to parallel agent teams and high-coupling tasks to a single flagship agent, calibrated against empirical task distribution data. The cross-vendor orchestration experiment (Experiment 3) will provide data on heterogeneous agent team effectiveness.

**S3: Platform Generalization.** Extending agent portability across both Claude and Gemini platforms. The cross-vendor paper experiment (this project) is a first step: both Claude and Gemini teams produce independent paper candidates from shared data, testing whether cross-platform collaboration produces richer outputs than single-vendor teams. Longer-term, we aim to develop a portable agent definition format consumable by both Claude Code and Gemini CLI.

---

## References

[A2A Project, 2026] Agent2Agent Protocol. "A2A Protocol Surpasses 150 Organizations." PR Newswire, April 9, 2026. https://www.prnewswire.com/news-releases/a2a-protocol-surpasses-150-organizations-302737641.html

[Anthropic, 2024] Anthropic. "Model Context Protocol." https://modelcontextprotocol.io/

[Anthropic, 2026a] Anthropic. "Building Agents with the Claude Agent SDK." https://claude.com/blog/building-agents-with-the-claude-agent-sdk

[Anthropic, 2026b] Anthropic. "Harness Design for Long-Running Apps." https://www.anthropic.com/engineering/harness-design-long-running-apps

[Anthropic, 2026c] Anthropic. "How We Built Our Multi-Agent Research System." https://www.anthropic.com/engineering/multi-agent-research-system

[Anthropic, 2026d] Anthropic. "2026 Agentic Coding Trends Report." https://resources.anthropic.com/2026-agentic-coding-trends-report

[Anthropic, 2026e] Anthropic. "Building a C Compiler with 16 Agents." https://www.anthropic.com/engineering/building-c-compiler

[Bhatia et al., 2026] Bhatia, A. et al. "Agent Contracts: A Formal Framework for Resource-Bounded Autonomous AI Systems." COINE 2026 (co-located with AAMAS 2026). https://arxiv.org/abs/2601.08815

[Ferber, 1999] Ferber, J. *Multi-Agent Systems: An Introduction to Distributed Artificial Intelligence.* Addison-Wesley, 1999.

[Google, 2025] Google. "Agent Development Kit." https://adk.dev/

[Guo et al., 2025] Guo, T. et al. "Multi-Agent Collaboration Mechanisms: A Survey of LLMs." arXiv:2501.06322, January 2025. https://arxiv.org/abs/2501.06322

[Iyengar et al., 2024] Iyengar, S. et al. "Debate, Deliberate, Decide (D3): A Cost-Aware Adversarial Framework for Reliable and Interpretable LLM Evaluation." arXiv:2410.04663, October 2024. https://arxiv.org/abs/2410.04663

[Li et al., 2025a] Li, Y. et al. "AgentOrchestra: A Hierarchical Multi-Agent Framework for General-Purpose Task Solving." arXiv:2506.12508, June 2025. https://arxiv.org/abs/2506.12508

[Li et al., 2025b] Li, Z. et al. "iMAD: Intelligent Multi-Agent Debate for Efficient and Accurate LLM Inference." arXiv:2511.11306, November 2025. https://arxiv.org/abs/2511.11306

[Nguyen et al., 2026] Nguyen, T. et al. "Toward Agentic Software Project Management: A Vision and Roadmap." arXiv:2601.16392, January 2026. https://arxiv.org/abs/2601.16392

[Papadopoulos et al., 2026] Papadopoulos, G. et al. "Courtroom-Style Multi-Agent Debate with Progressive RAG and Role-Switching for Controversial Claim Verification." arXiv:2603.28488, March 2026. https://arxiv.org/abs/2603.28488

[Patil et al., 2026] Patil, S. et al. "LLMs Working in Harmony: A Survey on the Technological Aspects of Building Effective LLM-Based Multi Agent Systems." arXiv:2504.01963, April 2025. https://arxiv.org/abs/2504.01963

[Rasheed et al., 2025] Rasheed, Z. et al. "A Practical Guide for Designing, Developing, and Deploying Production-Grade Agentic AI Workflows." arXiv:2512.08769, December 2025. https://arxiv.org/abs/2512.08769

[Raza et al., 2026] Raza, S. et al. "The Orchestration of Multi-Agent Systems: Architectures, Protocols, and Enterprise Adoption." arXiv:2601.13671, January 2026. https://arxiv.org/abs/2601.13671

[Singh et al., 2026] Singh, A. et al. "Agentic AI: Architectures, Taxonomies, and Evaluation of Large Language Model Agents." arXiv:2601.12560, January 2026. https://arxiv.org/abs/2601.12560

[SWE-bench, 2026] SWE-bench Verified Leaderboard. https://www.swebench.com/

[Wang et al., 2024] Wang, J. et al. "A Survey on LLM-based Multi-Agent System: Recent Advances and New Frontiers in Application." arXiv:2412.17481, December 2024. https://arxiv.org/abs/2412.17481

[Wooldridge and Jennings, 1995] Wooldridge, M. and Jennings, N. R. "Intelligent Agents: Theory and Practice." *The Knowledge Engineering Review*, 10(2):115--152, 1995.

[Zheng et al., 2026] Zheng, Y. et al. "Agyn: A Multi-Agent System for Team-Based Autonomous Software Engineering." arXiv:2602.01465, February 2026. https://arxiv.org/abs/2602.01465

[Zhou et al., 2025] Zhou, S. et al. "Multi-Agent Collaboration via Evolving Orchestration." arXiv:2505.19591, May 2025. https://arxiv.org/abs/2505.19591
