# Strategic Research Priorities

**Authority**: Project Owner (Jonas)
**Last updated**: 2026-04-18 (Reaffirmed & Expanded)
**Persistence**: These priorities persist across all research cycles until explicitly
updated by the project owner. They are NOT superseded by individual directives —
they SHAPE every directive.

## Owner's Core Concerns (April 2026)

The project owner has explicitly prioritized the following three research tracks as
the most critical for the long-term success of the repository. The research team
is expected to move beyond simply "following" industry leaders and begin
contributing original strategies and experiments.

---

## Priority S1: Automatic Agent/Skill Improvement

**Goal**: Build systems that automatically improve agents and agent skills to keep on
Anthropic and Google/DeepMind's latest paces.

**Current state**: The autoresearch-optimizer (Phase 3) can improve trigger descriptions.
The researcher tracks releases. But there is no closed loop that detects a new platform
capability (e.g., Gemini 1.5 Pro's long context or Opus 4.7's reasoning) and automatically
adapts the pipeline's agents to use it.

**Research questions**:
- How can agents detect when a new model capability makes their current approach suboptimal?
- Can we build a "capability diff" that compares a new release's features against our
  agents' assumptions and generates upgrade tasks?
- What does the literature say about self-improving agent systems? Are there architectures
  beyond our optimize-eval loop?
- Can we design experiments to measure improvement velocity — how fast our agents adapt
  to a platform change vs. how fast the change ships?

**Scope**: High. This is about building the meta-optimization layer that keeps us
at the frontier of agentic capabilities.

## Priority S2: Multi-Agent Orchestration

**Goal**: Develop deep expertise in effectively organizing multiple agents to work on
complex tasks.

**Current state**: Phase 5 (TCI routing, Scrum orchestration) is designed but pending.
The pipeline currently runs agents serially via cron. Research has tracked A2A, ADK,
Agent SDK, and Managed Agents but hasn't deeply explored novel orchestration patterns.

**Research questions**:
- Beyond published vendor patterns (Teams, Subagents, Orchestrator-Worker), what
  other orchestration topologies exist in the multi-agent systems (MAS) literature?
- How do real-world multi-agent deployments handle state sharing, failure recovery,
  and task decomposition?
- Can we design and run small-scale experiments comparing orchestration strategies
  using our existing pipeline?
- What orchestration patterns work specifically for heterogeneous agent fleets —
  mixing capabilities, models, and even vendors?

**Scope**: Deep. This is the heart of complex work automation.

## Priority S3: Platform Generalization & Portability

**Goal**: Generalize agents and skills so they are not dependent on a single ecosystem.
The repository must be shared by multiple systems; specifically, both **Gemini** and
**Claude** must be able to work with the agents to achieve scheduled work.

**Current state**: The entire pipeline depends on Claude Code utilities and ecosystem.
SKILL.md is a Claude Code format. Cron scripts invoke `claude -p`. Agent definitions
live in `.claude/agents/`. There is zero Gemini integration.

**Research questions**:
- What is the minimal portable agent definition format that both Claude Code and
  Gemini CLI can consume? Is it SKILL.md with adaptations, or something new?
- What are the concrete differences in how Claude Code and Gemini CLI handle agent
  definitions, tool permissions, and context management?
- Can a "transpiler" approach work (one canonical format, compiled to vendor-specific
  formats), or does portability require a shared runtime?
- What does A2A's Agent Card offer as a cross-platform identity layer?
- Are there existing open-source frameworks that achieve agent portability across
  LLM vendors?

**Scope**: Architectural. This is critical for future-proofing and multi-system synergy.

---

## Meta-Goal: Original Research, Experiments & Publication

The research team should NOT only follow the giants' paces. Where strategic priorities
reveal gaps in the industry's knowledge, the team is empowered and expected to:

- **Design new strategies or experiments**: Don't wait for Anthropic or Google to
  publish a pattern. Propose and test our own.
- **Run controlled comparisons**: Use the existing pipeline as a testbed for
  novel agentic workflows.
- **Write and Publish Papers**: Document findings in a form suitable for publication
  to the AI research community.
- **Contribute back**: Novel patterns should be contributed back to the ecosystem.

**Resource Commitment**: If necessary, the owner (Jonas) can provide **more resources for
more rounds of sessions for research**. High-impact experiment designs will be
prioritized for additional compute budget.

Experiment designs and results go to `knowledge_base/agentic-ai/experiments/`.
Manuscripts and publishable findings go to `knowledge_base/agentic-ai/publications/`.
