# Summary Statistics — Experiment Data for Paper

**Generated**: 2026-04-18
**Source**: `logs/performance/*.json` (69 records, 9 agent types), `knowledge_base/agentic-ai/discussions/*.md` (13 transcripts)

---

## Experiment 1: Orchestration Topology Comparison

### Data Overview

| Agent | N | Date Range | Status |
|-------|---|-----------|--------|
| Researcher | 12 | Apr 4-18 | Active |
| Research-Lead | 1 | Apr 18 | Active (new) |
| Factory-Steward | 13 | Apr 4-18 | Active |
| Android-SW Steward | 9 | Apr 4-17 | Suspended |
| ARM-MRS Steward | 8 | Apr 4-17 | Suspended |
| BSP-Knowledge Steward | 8 | Apr 7-17 | Suspended |
| LTC Steward | 7 | Apr 11-18 | Active |
| Project Reviewer | 9 | Apr 7-17 | Suspended |
| Issue Triage | 1 | Apr 4 | Inactive |

### Serial Chain Performance (Researcher → Research-Lead → Factory)

| Metric | Researcher | Research-Lead | Factory-Steward |
|--------|-----------|---------------|-----------------|
| N | 12 | 1 | 13 |
| Duration mean (s) | 2117.9 | 184.0 | 839.2 |
| Duration median (s) | 2011.5 | 184.0 | 837.0 |
| Duration std (s) | 431.1 | — | 185.7 |
| Duration 95% CI | [1874.0, 2361.9] | — | [738.3, 940.2] |
| Commits mean | 0.83 | 1.0 | 2.08 |
| Files changed mean | 18.83 | 2.0 | 10.31 |
| KB files updated mean | 18.58 | 0.0 | 0.0 |
| Success rate | 100% | 100% | 100% |

### Pipeline Utilization (N=11 common dates)

| Metric | Value |
|--------|-------|
| Mean serial compute time | 51.0 min |
| Cron wall-clock allocation | 180 min |
| **Utilization** | **28.3%** |
| Parallel ceiling | 34.8 min |
| **Parallel speedup** | **1.47x** |
| Idle time (mean) | 129.0 min |

### Temporal Trends

| Agent | Metric | Spearman rho | p | Significant? |
|-------|--------|-------------|---|-------------|
| Researcher | Duration | 0.441 | 0.121 | No |
| Researcher | Files changed | **0.944** | **<0.001** | **Yes** |
| Factory | Duration | -0.209 | 0.479 | No |
| Factory | Files changed | 0.082 | 0.784 | No |

### Throughput Comparison

| Agent | Commits/hour | Files/hour |
|-------|-------------|------------|
| Researcher | 2.10 | 47.27 |
| Factory-Steward | 8.99 | 43.12 |

---

## Experiment 2: Structured Debate Effectiveness

### Overall Distribution (N=136 proposals across 13 discussions)

| Category | Count | Rate | 95% Wilson CI |
|----------|-------|------|---------------|
| ADOPT | 85 | 62.5% | [54.1%, 70.2%] |
| DEFER | 38 | 27.9% | — |
| REJECT | 13 | 9.6% | — |

### Per-Discussion Adoption Rate

| Metric | Value |
|--------|-------|
| Mean | 0.646 |
| Median | 0.600 |
| Std Dev | 0.200 |
| 95% CI | [0.537, 0.755] |

### Engineer Pushback

| Metric | Value |
|--------|-------|
| Mean pushback rate | 0.354 |
| 95% CI | [0.245, 0.462] |
| DEFER:REJECT ratio | 2.9:1 |

### Implementation Conversion

| Metric | Value |
|--------|-------|
| Discussion dates with implementation commits | 10 / 13 (76.9%) |
| Git commits referencing ADOPT items | 14 |
| Total factory commits | 67 |
| ADOPT-referencing % of factory commits | 20.9% |

### Temporal Trend

| Metric | Spearman rho | p | Significant? |
|--------|-------------|---|-------------|
| ADOPT rate | 0.302 | 0.293 | No |

### Early vs Late Comparison

| Period | N | Aggregate ADOPT Rate |
|--------|---|---------------------|
| Early (Apr 5-9) | 5 | 0.571 |
| Late (Apr 10-18) | 8 | 0.662 |
| Difference | — | +0.091 (not significant) |

---

## Cross-Experiment Notes

- **Total pipeline observation**: 14 days of production data
- **Total agent sessions recorded**: 69 performance records
- **Total git commits in period**: 108
- **Model**: All agents run on claude-opus-4-6 (1M context)
- **All agents achieved 100% reliability** (zero failures, zero skips)
