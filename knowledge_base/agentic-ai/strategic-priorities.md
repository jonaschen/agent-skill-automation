# Strategic Research Priorities

**Authority**: Project Owner (Jonas)
**Last updated**: 2026-04-18
**Persistence**: These priorities persist across all research cycles until explicitly
updated by the project owner. They are NOT superseded by individual directives —
they SHAPE every directive.

## How to Use This File

- **Research-lead**: Read this file BEFORE writing any directive. Every P0/P1 topic
  in your directive should trace back to one of these strategic priorities or to an
  urgent tactical need (deprecation, breaking change). If a directive has no items
  advancing strategic priorities, explain why in the Strategic Alignment section.
- **Researcher**: Reference these priorities when proposing new research areas or
  evaluating depth vs. breadth trade-offs. Proposals that advance a strategic priority
  get an automatic +1 priority boost.
- **Factory-steward**: When triaging ADOPT items, prefer items that advance strategic
  priorities over pure operational improvements.

---

## Priority S1: Automatic Agent/Skill Improvement

**Goal**: Build systems that automatically improve agents and agent skills to keep pace
with — and eventually anticipate — Anthropic and Google/DeepMind's latest developments.

**Current state**: The autoresearch-optimizer (Phase 3) can improve trigger descriptions.
The researcher tracks releases. But there is no closed loop that detects a new platform
capability and automatically adapts the pipeline's agents to use it.

**Research questions**:
- How can agents detect when a new model capability (e.g., extended reasoning, new tool
  modes) makes their current approach suboptimal?
- Can we build a "capability diff" that compares a new release's features against our
  agents' assumptions and generates upgrade tasks?
- What does the literature say about self-improving agent systems? Are there architectures
  beyond our optimize-eval loop?
- Can we design experiments to measure improvement velocity — how fast our agents adapt
  to a platform change vs. how fast the change ships?

**Scope**: Not just tracking releases (the researcher already does that). This is about
building the meta-optimization layer — the system that self-improves.

## Priority S2: Multi-Agent Orchestration

**Goal**: Develop deep expertise in effectively organizing multiple agents to work on
complex tasks, going beyond both our Phase 5 TCI routing and Anthropic's published
patterns.

**Current state**: Phase 5 (TCI routing, Scrum orchestration) is designed but pending.
The pipeline currently runs agents serially via cron. Research has tracked A2A, ADK,
Agent SDK, and Managed Agents but hasn't deeply explored novel orchestration patterns.

**Research questions**:
- Beyond Anthropic's four patterns (Teams, Subagents, Three-Agent Harness,
  Orchestrator-Worker), what other orchestration topologies exist? What does the
  multi-agent systems literature say?
- How do real-world multi-agent deployments handle state sharing, failure recovery,
  and task decomposition?
- Can we design and run small-scale experiments comparing orchestration strategies
  using our existing pipeline? (Compute budget available for this.)
- What orchestration patterns work specifically for heterogeneous agent fleets —
  mixing capabilities, models, and even vendors?

**Scope**: Not just Anthropic's patterns. Original research, experiments, and potentially
publishable findings.

**Active paper project**: "Heterogeneous Multi-Agent Orchestration for Autonomous
Software Pipeline Management" — empirical systems paper with Claude + Gemini teams
producing independent candidates. See `knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/README.md`.

## Priority S3: Platform Generalization (Cross-Platform Agent Portability)

**Goal**: Make agents shareable across multiple AI platforms — specifically, both Gemini
and Claude should be able to work with the agents to achieve scheduled work.

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

**Scope**: This is the most architecturally ambitious priority. Early work should be
comparative analysis and feasibility studies, not implementation.

---

## Meta-Goal: Original Research & Experimentation

The research team should not just follow the giants' paces. Where strategic priorities
reveal gaps in the industry's knowledge, the team should:

- **Design experiments** — Jonas can provide compute budget (more sessions if needed)
- **Run controlled comparisons** using the existing pipeline as a testbed
- **Document findings** in publishable form
- **Contribute novel patterns** back to the ecosystem

This applies to all three strategic priorities but especially to S2 (Multi-Agent
Orchestration), where the most opportunity for original contribution exists.

Experiment designs and results go to `knowledge_base/agentic-ai/experiments/`.
