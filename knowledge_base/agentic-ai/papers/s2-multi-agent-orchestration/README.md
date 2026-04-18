# Paper Project: Heterogeneous Multi-Agent Orchestration for Autonomous Software Pipeline Management

**Status**: Active (started 2026-04-18)
**Strategic Priority**: S2 (Multi-Agent Orchestration)
**Paper Type**: Empirical Systems Paper

## Thesis

We present the design, implementation, and operational evaluation of a heterogeneous
multi-agent orchestration system that autonomously manages a software pipeline. Using
14+ days of production operational data, we compare orchestration patterns and identify
conditions under which specific topologies outperform others.

## Novel Contributions

1. **Production system description** with real operational data (not simulation)
2. **Empirical comparison** of orchestration patterns (serial cron vs. delegation vs. parallel)
3. **Structured adversarial debate** (Innovator/Engineer) as a decision-making mechanism for agent systems
4. **Cross-vendor orchestration** findings from Claude + Gemini heterogeneous teams

## Paper Outline

1. **Abstract** (150-250 words)
2. **Introduction** -- Problem: orchestrating heterogeneous AI agent fleets for complex software tasks. Contribution summary.
3. **Related Work** -- Multi-agent systems literature, LLM-based agent frameworks (A2A, ADK, Agent SDK, MCP), autonomous software engineering agents.
4. **System Design** -- 7-phase pipeline architecture, agent taxonomy (5 core + 3 research + 1 steward), orchestration patterns in use.
5. **Methodology** -- Research questions, hypotheses, experimental setup, data collection, analysis methods.
6. **Results** -- Operational data analysis, topology comparison, debate effectiveness, cross-vendor findings.
7. **Discussion** -- Key findings, implications for multi-agent system design, threats to validity, limitations.
8. **Conclusion and Future Work** -- Summary, S1 (self-improvement) and S3 (cross-platform portability) as future directions.

## Two-Team Protocol

Both Claude and Gemini teams produce independent paper candidates using the same shared knowledge base.

### Shared Resources (both teams read)

- `knowledge_base/agentic-ai/` -- all sweep reports, analysis, discussions, proposals
- `logs/performance/` -- operational performance data (14+ days)
- `knowledge_base/agentic-ai/experiments/` -- shared experimental data and protocols
- `knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/methodology/` -- shared experimental protocols
- `knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/literature/` -- shared literature notes
- `knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/data/` -- shared extracted data

### Independent Workspaces

| Team | Workspace | Rules |
|------|-----------|-------|
| Claude | `claude-candidate/` | Only Claude team writes here |
| Gemini | `gemini-candidate/` | Only Gemini team writes here |

### Phase Timeline

| Phase | Days | Activity |
|-------|------|----------|
| **Phase 1: Independent Writing** | 1-5 | Each team reads KB, designs experiments, writes paper candidate |
| **Phase 2: Cross Review** | 6-7 | Each team's peer-reviewer evaluates the other's paper |
| **Phase 3: Revision** | 8-9 | Each team revises based on peer review feedback |
| **Phase 4: Merge** | 10 | Human (Jonas) selects stronger candidate as base, merges best sections |

### Conflict Resolution

Per AGENTS.md: if candidates conflict on factual claims, the version with stronger
empirical evidence wins. If both are equally supported, the human makes the final call.

## Experiments

Three experiments provide the empirical backbone of the paper:

| # | Name | Data Source | Status |
|---|------|-------------|--------|
| 1 | Orchestration Topology Comparison | `logs/performance/*.json` (14+ days) | Protocol needed |
| 2 | Structured Debate Effectiveness | `knowledge_base/agentic-ai/discussions/` (13+ transcripts) | Protocol needed |
| 3 | Cross-Vendor Orchestration | Claude vs Gemini paper candidates (this project) | Meta-experiment |

Protocols in `knowledge_base/agentic-ai/experiments/`.

## Key Source Material

| Section | Primary KB Source |
|---------|-------------------|
| Related Work | `anthropic/multi-agent-patterns.md`, `google-deepmind/a2a-protocol.md`, `cross-cutting/` |
| System Design | `CLAUDE.md`, `ROADMAP.md`, `.claude/agents/*.md` |
| Results | `logs/performance/*.json`, `discussions/*.md`, `analysis/*.md` |
| Discussion | `analysis/*.md`, `discussions/*.md`, `strategic-priorities.md` |
