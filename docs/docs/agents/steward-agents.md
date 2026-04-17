---
sidebar_position: 2
title: Steward Agents
---

# Autonomous Steward Agents

The steward agents run via cron, each maintaining a specific aspect of the pipeline. The research pipeline forms a three-agent cycle that runs twice daily: researcher produces findings, research-lead reviews and directs, factory-steward implements.

## Overview

| Agent | Target | Schedule | Model | Status |
|-------|--------|----------|-------|--------|
| `agentic-ai-researcher` | This repo (knowledge base) | 2am + 10am | Opus 4.6 | Active |
| `agentic-ai-research-lead` | This repo (directives) | 3am + 11am | Opus 4.6 | Active |
| `factory-steward` | This repo (pipeline) | 4am + 12pm | Opus 4.6 | Active |
| `ltc-steward` | long-term-care-expert | 8am | Opus 4.6 | Active |

## agentic-ai-researcher

Runs a five-level pipeline every sweep:

| Level | Activity |
|-------|----------|
| L1 — Collect | Scans Anthropic + Google/DeepMind sources for new developments |
| L2 — Analyze | Deep analysis of significant findings |
| L3 — Discuss | Innovator-vs-Engineer discussion format for strategic decisions |
| L4 — Plan | Strategic proposals with priority ratings (P0-P3) |
| L5 — Act | Implements ADOPT decisions, updates knowledge base |

Reads the latest research-lead directive to adjust priorities per topic (P0 = deep, P2 = watch-only).

**Output**: Sweep reports in `knowledge_base/agentic-ai/sweeps/`, proposals in `knowledge_base/agentic-ai/proposals/`

## agentic-ai-research-lead

Strategic director of the research program. Reviews researcher output and sets priorities.

**Responsibilities**:
- Assesses sweep quality, depth, and relevance to pipeline goals
- Writes priority directives (`knowledge_base/agentic-ai/directives/YYYY-MM-DD.md`)
- Evaluates whether previous directives were followed
- Proposes team composition changes when needed

**Output**: Research directives, team proposals

## factory-steward

The self-improvement agent for this repository. Implements research findings into the pipeline.

**Responsibilities**:
- Implements ADOPT items from the researcher's discussion transcripts
- Reads research-lead directives to prioritize which ADOPT items to tackle
- Tunes underperforming agents based on `agent_review.sh` data
- Improves eval infrastructure (test prompts, splits, scoring)
- Advances ROADMAP deliverables

## ltc-steward

Maintains the long-term-care-expert project (Hana LINE bot + Digital Surrogate).

**Current focus**: Phase 7/8 work (Hana hardening, Digital Surrogate sprints), SaMD compliance, eval suites

## The Research Direction Loop

```
researcher (L1-L5) → knowledge_base/ → research-lead → directives/
      ↑                                                    ↓
      └────────────── reads directive ◄────────────────────┘
                                                           ↓
                                              factory-steward (same cycle)
```

## Suspended Agents

The following agents are suspended (2026-04-17, resource reallocation). Definitions preserved for potential reactivation:

- `android-sw-steward` — Android-Software AOSP skill set
- `arm-mrs-steward` — ARM MRS AArch64 agent skills
- `bsp-knowledge-steward` — BSP Knowledge Skill Sets
- `project-reviewer` — Cross-project steward quality reviews
