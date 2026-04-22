# Orchestration Paradigm Taxonomy

**Created**: 2026-04-23
**Source**: Analysis 2026-04-23 (ADK v2.0.0b1 graph orchestration findings), Discussion 2026-04-23 A1
**Purpose**: Structured comparison of orchestration philosophies for the S2 paper's comparative analysis section

---

## Three Orchestration Paradigms

### 1. Agent-Centric Orchestration

**Definition**: The agent is the fundamental unit of computation. Orchestration happens through agent-to-agent delegation — one agent spawns or calls another. The orchestrator is itself an agent that decides which sub-agents to invoke.

**Core principle**: Computation flows through agent identity boundaries. Each agent maintains its own context, tools, and permissions. The agent's definition (description, tools, constraints) determines what it can do.

**Exemplars**:
- Claude Code Agent tool (parent agent dispatches to child agents via `Task`)
- Anthropic Managed Agents (session-based, billing per agent-session)
- Anthropic Agent SDK subagents (programmatic agent delegation)
- Anthropic's published patterns: Teams, Subagents, Orchestrator-Worker, Three-Agent Harness

**Characteristics**:
| Dimension | Agent-Centric |
|-----------|---------------|
| Unit of computation | Agent |
| Orchestration locus | Agent's decision-making (LLM chooses which sub-agent) |
| State management | Per-agent context windows, tool results passed between agents |
| Failure recovery | Agent-level retry/fallback (orchestrator decides) |
| Routing | Implicit (LLM-decided) or semi-structured (description matching) |

### 2. Workflow-Centric Orchestration

**Definition**: The workflow graph is the fundamental unit of computation. Agents are nodes within a graph; the graph structure (edges, conditions, scheduling) determines execution order. The orchestrator is a runtime that executes the graph, not an agent.

**Core principle**: Computation flows through graph edges. Each node is an execution unit (which may contain an agent), but the graph topology — not the agent — determines control flow.

**Sub-distinction**:

#### 2a. LLM-Native Workflow Orchestration

Workflow frameworks designed specifically for LLM agent orchestration.

**Exemplars**:
- Google ADK v2.0 (`BaseNode` → `Workflow`, `NodeRunner`, `DefaultNodeScheduler`)
- LangGraph (LangChain's graph-based agent orchestration)
- CrewAI (role-based agent workflows with sequential/hierarchical process)

**Characteristics**: Graph nodes are LLM agents with prompts, tools, and context. Edges carry conditions. The runtime handles dispatch, context scoping (e.g., `NodeRunner` isolation), and visualization.

#### 2b. Infrastructure Workflow Orchestration

General-purpose durable execution frameworks adapted for agent workloads.

**Exemplars**:
- Temporal (durable workflow execution with replay-based recovery)
- Apache Airflow (DAG-based task scheduling)
- Prefect (Python-native workflow orchestration)

**Characteristics**: Nodes are arbitrary code (not necessarily LLM agents). Edges are data dependencies. The runtime provides durability, retry, and crash recovery. LLM agents are treated as tasks within the workflow, not first-class primitives.

**Key difference from 2a**: Infrastructure frameworks treat LLM calls as opaque function calls. LLM-native frameworks understand agent context, tool permissions, and prompt structure as first-class concepts.

### 3. Hybrid Orchestration (Our Pipeline)

**Definition**: Cron-orchestrated agent-centric execution with imperative workflow logic. Individual agents are agent-centric (each Claude session is autonomous), but the pipeline's control flow is defined by bash scripts that implement a state machine.

**Core principle**: Time-based dispatch (cron) replaces both LLM-decided routing and graph-edge routing. Within each session, the agent is fully autonomous. Between sessions, `closed_loop.sh` and cron scripts implement conditional branching imperatively.

**Exemplars**:
- Our pipeline: `daily_research_sweep.sh` → `daily_research_lead.sh` → `daily_factory_steward.sh`
- `closed_loop.sh`: GENERATE → VALIDATE → conditional OPTIMIZE → DEPLOY

**Characteristics**:
| Dimension | Hybrid |
|-----------|--------|
| Unit of computation | Agent (within session), Script (across sessions) |
| Orchestration locus | Cron + bash conditionals (between sessions), Agent autonomy (within session) |
| State management | File system artifacts (logs/, knowledge_base/), perf JSON records |
| Failure recovery | Script-level (exit codes, retry limits), agent-level (tool retries within session) |
| Routing | Time-based (cron schedule) + file-based (directives guide agent priorities) |

---

## Comparison Table

| Dimension | Agent-Centric | Workflow-Centric (LLM-Native) | Workflow-Centric (Infrastructure) | Hybrid (Our Pipeline) |
|-----------|---------------|-------------------------------|-----------------------------------|----------------------|
| Unit of computation | Agent | Graph node (contains agent) | Task (contains code) | Agent + Script |
| Orchestration locus | LLM decision | Graph runtime | DAG scheduler | Cron + bash |
| State sharing | Tool results, context window | Graph context, node outputs | Workflow variables | File system artifacts |
| Failure recovery | Agent retry/fallback | Node retry + edge rerouting | Replay-based recovery | Exit codes + retry limits |
| Dynamic routing | LLM chooses sub-agent | Conditional edges | Static DAG (mostly) | Directive-guided priorities |
| Observability | Agent output logs | Graph visualization (ADK v2.0) | Workflow UI (Airflow, Temporal) | Perf JSON + `agent_review.sh` |
| Root abstraction | Agent (CC `.md`, SDK `Agent`) | BaseNode / Workflow (ADK v2.0) | Activity / Task (Temporal) | Shell script + agent session |

---

## Paper Implications

1. **Novel axis**: This taxonomy classifies orchestration by *philosophy* (what is the unit of computation?), not by *topology* (how many agents?). Anthropic's published multi-agent blog categorizes by topology (Teams, Subagents, Orchestrator-Worker). Our taxonomy adds an orthogonal dimension.

2. **Natural experiment**: Our pipeline's hybrid approach can be compared against both paradigms. Agent-centric and workflow-centric orchestration may perform differently for different task coupling levels — this connects directly to the TCI framework.

3. **Third paradigm contribution**: Published literature covers agent-centric (Anthropic patterns) and workflow-centric (ADK, LangGraph). Our hybrid paradigm — cron-orchestrated agent-centric execution with imperative workflow logic — is not well-documented in the literature. Characterizing it as a third paradigm is a potential paper contribution.
