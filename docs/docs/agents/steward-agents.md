---
sidebar_position: 2
title: Steward Agents
---

# Autonomous Steward Agents

The steward agents run nightly via cron, each maintaining a specific project repository. They form a self-correcting cycle: stewards build and commit, the project reviewer assesses quality and writes steering notes, which guide the next session.

## Overview

| Agent | Target Project | Schedule | Model |
|-------|---------------|----------|-------|
| `agentic-ai-researcher` | This repo (knowledge base) | 2:00 AM | Opus 4.6 |
| `android-sw-steward` | Android-Software (AOSP skill set) | 3:00 AM | Opus 4.6 |
| `arm-mrs-steward` | ARM MRS (AArch64 agent skills) | 4:00 AM | Opus 4.6 |
| `bsp-knowledge-steward` | BSP Knowledge Skill Sets | 5:00 AM | Opus 4.6 |
| `factory-steward` | This repo (pipeline self-improvement) | 12:00 PM + 9:00 PM | Opus 4.6 |

## agentic-ai-researcher

Runs a five-level pipeline every night:

| Level | Activity |
|-------|----------|
| L1 — Collect | Scans Anthropic + Google/DeepMind sources for new developments |
| L2 — Analyze | Deep analysis of significant findings |
| L3 — Discuss | Innovator-vs-Engineer discussion format for strategic decisions |
| L4 — Plan | Strategic proposals with priority ratings (P0-P3) |
| L5 — Act | Implements ADOPT decisions, updates knowledge base |

**Output**: Sweep reports in `knowledge_base/agentic-ai/sweeps/`, proposals in `knowledge_base/agentic-ai/proposals/`

## android-sw-steward

Autonomously maintains the Android-Software AOSP skill set project.

**Current focus** (Phase 4):
- `detect_dirty_pages.py` — detects modified skill files needing re-evaluation
- `migration_impact.py` — analyzes impact of AOSP version changes
- `skill_lint.py` — lints skill definitions for quality issues
- L3 extension framework
- Android 15 validation pass

**Also**: Researches AOSP/Android updates, creates hindsight notes, expands routing test suite

## arm-mrs-steward

Autonomously maintains the ARM MRS AArch64 agent skill project.

**Current focus** (H8):
- Multi-agent orchestration design (Developer/Critic/Judge/Executor loop)
- T32/A32 instruction coverage expansion
- GIC/CoreSight/PMU data expansion
- Growing the 292-test eval suite
- Tracking ARM spec releases (v9Ap7+, new FEAT_* extensions)

## bsp-knowledge-steward

Autonomously maintains the BSP Knowledge Skill Sets project — a three-layer AI mentor system for SoC BSP engineers grounded in a Kuzu knowledge graph (501+ nodes).

**Current focus**:
- Phase 3 exit: Blackboard eval, Socratic template validation, mentor learner-level detection
- Phase 4: Sedimentation CLI, business impact reports, CI/CD integration, base graph maintenance
- Knowledge graph expansion toward 800-1000 nodes
- Eval coverage growth across all 7 skills

## factory-steward

The self-improvement agent for this repository. Runs twice daily.

**Responsibilities**:
- Implements ADOPT items from the researcher's nightly discussion transcripts
- Tunes underperforming agents based on `agent_review.sh` data
- Improves eval infrastructure (test prompts, splits, scoring)
- Refines agent definitions based on performance data
- Advances ROADMAP Phase 4 deliverables

## The Self-Correcting Cycle

```
Stewards build and commit
        |
        v
project-reviewer assesses quality
        |
        v
Steering notes written to each repo
        |
        v
Stewards read steering notes in next session
        |
        v
Corrections applied, cycle repeats
```

Skills that fail validation (`posterior_mean < 0.90` or `ci_lower < 0.80`) are flagged as **P0 correction items**.
