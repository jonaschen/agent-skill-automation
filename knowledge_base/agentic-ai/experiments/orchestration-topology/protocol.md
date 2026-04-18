# Experiment: Orchestration Topology Comparison

**Date**: 2026-04-18
**Strategic Priority**: S2 (Multi-Agent Orchestration)
**Status**: analysis

## Hypothesis

Serial cron-based orchestration (current pipeline: researcher -> research-lead ->
factory-steward at fixed 1-hour intervals) results in lower throughput efficiency
than the theoretical parallel execution ceiling, with idle time between stages
representing recoverable waste.

## Research Questions

1. What is the per-session throughput (commits/hour, KB files updated/hour) of each agent in the serial chain?
2. Is there measurable improvement in agent efficiency over time (learning curve)?
3. What proportion of total pipeline wall-clock time is inter-agent idle time vs. active compute?
4. What is the reliability profile (exit code distribution, recovery events) of each agent?
5. Are there temporal patterns (time-of-day, day-of-week) that affect agent performance?

## Variables

- **Independent**: Agent type (researcher, research-lead, factory-steward), date, time-of-day
- **Dependent**: Duration (seconds), commits_made, files_changed, kb_files_updated, exit_code
- **Controls**: Model (all use claude-opus-4-6), repo state (same repository), effort level

## Data Sources

- `logs/performance/researcher-*.json` (April 4-18, 2026: ~14 records)
- `logs/performance/research-lead-*.json` (April 18, 2026: ~1 record)
- `logs/performance/factory-*.json` (April 4-18, 2026: ~13 records)

Each JSON record contains: agent, date, duration_seconds, status, pre_commit, commit,
commits_made, files_changed, kb_files_updated, effort_level, exit_code.

## Sample Size

- Researcher: ~14 observations
- Factory-steward: ~13 observations
- Research-lead: ~1 observation (just activated)

**Power analysis note**: With N=14, we have power to detect large effects (Cohen's d > 0.8)
at alpha=0.05 using Mann-Whitney U. Medium effects require N>30. We should frame findings
as "preliminary" given the sample size and plan for follow-up with more data.

## Statistical Analysis Plan

1. **Descriptive statistics**: Mean, median, std dev, IQR for each metric per agent
2. **Efficiency metrics**: Compute throughput ratios (commits/minute, KB updates/minute)
3. **Temporal trends**: Spearman rank correlation between date and throughput metrics
4. **Reliability**: Proportion of successful runs (exit_code=0), skip rate
5. **Pipeline utilization**: Total active compute time vs. total wall-clock time (3 hours for the full chain)
6. **Parallel ceiling estimate**: If agents were run simultaneously, what would the theoretical wall-clock time be? (max of individual durations vs. sum)

**Significance level**: alpha = 0.05
**Effect size measures**: Cohen's d for continuous metrics, rank-biserial correlation for Mann-Whitney U
**Multiple comparisons**: Bonferroni correction if >3 comparisons

## Threats to Validity

- **Internal**: Agents run on the same machine; background load may affect duration. No randomization of run order (fixed cron schedule).
- **External**: Single pipeline instance; results may not generalize to other multi-agent systems. Small sample size limits statistical power.
- **Construct**: Duration is a proxy for compute cost, not actual token count. kb_files_updated counts may not reflect quality of updates.

## Results

<to be filled after analysis>

## Conclusions

<to be filled after analysis>
