# Shared Experimental Protocol

**Paper**: Heterogeneous Multi-Agent Orchestration for Autonomous Software Pipeline Management
**Date**: 2026-04-18

## Overview

This document defines the shared experimental methodology for the S2 paper. Both
the Claude and Gemini teams use the same data, protocols, and statistical methods
to ensure comparability.

## Data Access

All experimental data is in the shared repository. Both teams have read access to:

| Data | Path | Records |
|------|------|---------|
| Researcher performance | `logs/performance/researcher-*.json` | ~14 |
| Factory performance | `logs/performance/factory-*.json` | ~13 |
| Research-lead performance | `logs/performance/research-lead-*.json` | ~1 |
| Discussion transcripts | `knowledge_base/agentic-ai/discussions/*.md` | ~13 |
| L4 proposals | `knowledge_base/agentic-ai/proposals/*.md` | ~33 |
| Analysis reports | `knowledge_base/agentic-ai/analysis/*.md` | ~14 |
| Sweep reports | `knowledge_base/agentic-ai/sweeps/*.md` | ~40 |

## Statistical Standards

Both teams must:
1. Report 95% confidence intervals for all quantitative claims
2. Use non-parametric tests (small sample sizes)
3. Report effect sizes alongside any significance tests
4. Apply Bonferroni correction for multiple comparisons
5. Distinguish exploratory from confirmatory analysis
6. Report all results including negative/null findings

## Experiment Registry

| # | Name | Protocol Location | Status |
|---|------|-------------------|--------|
| 1 | Orchestration Topology Comparison | `experiments/orchestration-topology/protocol.md` | Design |
| 2 | Structured Debate Effectiveness | `experiments/debate-effectiveness/protocol.md` | Design |
| 3 | Cross-Vendor Orchestration | `experiments/cross-vendor-orchestration/protocol.md` | Design |

## Reproducibility

All analysis scripts should be written to `experiments/<name>/results/` alongside
their output, so that any reader can re-run the analysis on the same data.
