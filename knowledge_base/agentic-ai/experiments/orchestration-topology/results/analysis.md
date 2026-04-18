# Experiment 1: Orchestration Topology Comparison — Results

**Analysis Date**: 2026-04-18
**Status**: analysis
**Data Range**: 2026-04-04 to 2026-04-18

## Summary

Serial cron-based orchestration achieves 100% reliability but only 28.3% pipeline utilization.
The parallel execution ceiling offers a 1.47x speedup. The researcher agent dominates pipeline
wall-clock time (mean 35.3 min vs factory-steward's 14.0 min), making it the primary bottleneck.
Both agents show 100% success rates (zero failures, zero skips) across the observation period.

## 1. Per-Agent Descriptive Statistics

### Researcher (N=12)

| Metric | Mean | Median | Std Dev | 95% CI | Range | IQR |
|--------|------|--------|---------|--------|-------|-----|
| Duration (s) | 2117.9 | 2011.5 | 431.1 | [1874.0, 2361.9] | [1598, 2936] | 679 |
| Commits | 0.83 | 1.0 | 0.83 | — | [0, 3] | — |
| Files changed | 18.83 | 25.0 | 14.37 | — | [0, 34] | — |
| KB files updated | 18.58 | 25.0 | — | — | [0, 33] | — |

**Note**: First 4 runs (Apr 4-7) produced 0 commits/files (early bootstrapping phase before
KB write infrastructure was operational). From Apr 8 onward, researcher consistently produces
22-34 KB file updates per run.

### Research-Lead (N=1)

| Metric | Value |
|--------|-------|
| Duration (s) | 184 |
| Commits | 1 |
| Files changed | 2 |

**Note**: Agent activated 2026-04-18. Single observation insufficient for statistical analysis.
Preliminary finding: research-lead is the lightest agent in the chain (3.1 min vs researcher's
35.3 min mean), consistent with its role as a strategic director rather than a content producer.

### Factory-Steward (N=13)

| Metric | Mean | Median | Std Dev | 95% CI | Range | IQR |
|--------|------|--------|---------|--------|-------|-----|
| Duration (s) | 839.2 | 837 | 185.7 | [738.3, 940.2] | [607, 1359] | 137 |
| Commits | 2.08 | 2 | 0.64 | — | [1, 3] | — |
| Files changed | 10.31 | 9 | 5.84 | — | [3, 24] | — |
| ADOPT items available | 8.31 | 8 | 5.90 | — | [0, 18] | — |

## 2. Throughput Metrics

| Agent | Commits/hour | Files/hour |
|-------|-------------|------------|
| Researcher | 2.10 (mean) | 47.27 (mean) |
| Factory-Steward | 8.99 (mean) | 43.12 (mean) |

**Finding**: Factory-steward produces 4.3x more commits per hour than researcher, reflecting its
focused implementation role vs. the researcher's broad scanning role. Files-per-hour rates are
comparable (47.3 vs 43.1), suggesting similar raw output volume despite different work profiles.

## 3. Temporal Trends

| Agent | Metric | Spearman rho | p-value | Interpretation |
|-------|--------|-------------|---------|----------------|
| Researcher | Duration | 0.441 | 0.121 | Weak positive trend (not significant) |
| Researcher | Files changed | 0.944 | <0.001 | **Strong positive trend (significant)** |
| Factory | Duration | -0.209 | 0.479 | No significant trend |
| Factory | Files changed | 0.082 | 0.784 | No significant trend |

**Key finding**: Researcher output (files changed) shows a strong, statistically significant
increasing trend over time (rho=0.944, p<0.001). This reflects the KB growth from bootstrapping
(0 files in first 4 runs) to mature operation (22-34 files per run). This is not a learning
effect but rather infrastructure maturation — the researcher gained the ability to write to KB
files starting April 8.

Factory-steward shows no significant trends in either duration or output, consistent with
stable operational behavior throughout the observation period.

## 4. Reliability Analysis

| Agent | Successful Runs | Total Runs | Success Rate | Skips |
|-------|----------------|------------|-------------|-------|
| Researcher | 12 | 12 | 100.0% | 0 |
| Factory-Steward | 13 | 13 | 100.0% | 0 |
| Research-Lead | 1 | 1 | 100.0% | 0 |

All agents achieved 100% reliability (exit_code=0) across the entire observation period.
No skipped runs or recovery events observed.

## 5. Pipeline Utilization Analysis

The serial chain runs on fixed cron intervals:
- Researcher: 1:00 AM → Research-Lead: 2:00 AM → Factory-Steward: 3:00 AM
- Total wall-clock allocation: 3 hours (10,800 seconds)

| Metric | Value |
|--------|-------|
| Common observation dates (researcher + factory) | 11 |
| Mean serial compute time | 3060.9s (51.0 min) |
| Cron wall-clock time | 10,800s (180 min) |
| **Pipeline utilization** | **28.3%** |
| Mean parallel ceiling | 2087.6s (34.8 min) |
| **Parallel speedup** | **1.47x** |
| Parallel utilization would be | 19.3% |

**Interpretation**: Only 28.3% of the 3-hour cron window is spent on active compute. The
remaining 71.7% is inter-agent idle time (waiting for the next cron trigger). If all three
agents ran simultaneously (parallel ceiling), total wall-clock time would reduce from 51.0
to 34.8 minutes — a 1.47x speedup with theoretical utilization of 19.3% of the 3-hour window.

The modest parallel speedup (1.47x vs theoretical 3x) reflects the researcher's dominance:
it accounts for ~69% of total serial compute time. The parallel ceiling is bounded by the
researcher's duration since it's the slowest agent.

## 6. Agent Comparison

### Duration: Researcher vs Factory-Steward (Mann-Whitney U)

| Test | U | p-value | Rank-biserial r | Interpretation |
|------|---|---------|-----------------|----------------|
| Duration | 156.0 | <0.001 | 1.000 | **Large effect**: researcher always longer |
| Files changed | 102.5 | 0.183 | 0.314 | Not significant |
| Files/minute (efficiency) | 69.0 | 0.218 | 0.327 | Not significant |

**Finding**: Researcher duration is significantly and substantially longer than factory-steward
(mean 2118s vs 839s, rank-biserial r=1.0 — every researcher session was longer than every
factory session). However, raw file output and efficiency (files/minute) do not differ
significantly between agents, suggesting comparable productivity per unit of compute time.

## 7. Supplementary Agent Data

Beyond the serial chain, the pipeline includes 5 additional agent types:

| Agent | N | Mean Duration (s) | Mean Commits | Status |
|-------|---|-------------------|-------------|--------|
| android-sw-steward | 9 | 839 | 1.78 | Suspended Apr 17 |
| arm-mrs-steward | 8 | 1042 | 1.38 | Suspended Apr 17 |
| bsp-knowledge-steward | 8 | 2367 | 2.00 | Suspended Apr 17 |
| ltc-steward | 7 | 618 | 2.00 | Active |
| project-reviewer | 9 | 284 | 1.00 | Suspended Apr 17 |

## 8. Conclusions

1. **H1 (Partially Supported)**: Serial cron-based orchestration is indeed suboptimal for
   throughput, with only 28.3% utilization. However, the parallel ceiling improvement is
   modest (1.47x) because the chain is bottlenecked on the researcher agent.

2. **Reliability is excellent**: 100% success rate across all agents over 14 days suggests
   the serial cron model provides robust operational stability.

3. **The real optimization opportunity** is not parallelization (which saves ~16 min per cycle)
   but rather reducing the researcher's duration (mean 35.3 min) or running the research-lead
   + factory as a tighter sequential pair (they could start immediately after the researcher
   completes rather than waiting for cron intervals).

4. **Generalizability caveat**: These findings are preliminary (N=12-13 per agent) and specific
   to one pipeline instance. Power analysis indicates we can detect large effects (d>0.8) but
   may miss medium effects. Continued data collection will improve statistical power.

## Threats to Validity

- **Internal**: No randomization of run order; background load uncontrolled; first 4 researcher
  runs had infrastructure limitations (no KB write capability)
- **External**: Single pipeline, single model (Opus 4.6), specific task distribution
- **Construct**: Duration as proxy for compute cost (not actual token count); file counts don't
  measure output quality
