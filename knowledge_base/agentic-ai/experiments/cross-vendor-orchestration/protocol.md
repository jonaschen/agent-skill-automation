# Experiment: Cross-Vendor Orchestration

**Date**: 2026-04-18
**Strategic Priority**: S2 (Multi-Agent Orchestration)
**Status**: design (runs during paper project Phase 2)

## Hypothesis

Heterogeneous agent teams (Claude + Gemini working independently on the same task)
produce research outputs with broader coverage and more cross-cutting insights than
either single-vendor team alone.

## Research Questions

1. How much topic overlap exists between the Claude and Gemini paper candidates?
2. Does each team surface unique insights not found in the other's paper?
3. Which team produces more cross-cutting analysis (bridging Anthropic and Google ecosystems)?
4. Do the teams differ in citation diversity and source selection?
5. Does the merged paper (human-selected best sections) outperform either candidate alone?

## Variables

- **Independent**: Team (Claude vs. Gemini vs. merged)
- **Dependent**: Topic coverage, unique insights, cross-cutting references, citation diversity
- **Controls**: Same KB input, same paper outline, same experimental data

## Data Sources

- `papers/s2-multi-agent-orchestration/claude-candidate/paper.md`
- `papers/s2-multi-agent-orchestration/gemini-candidate/paper.md`
- `papers/s2-multi-agent-orchestration/merged/` (after Phase 4)
- `papers/s2-multi-agent-orchestration/reviews/` (peer review scores)

## Measurement Definitions

### Topic Coverage
Extract all technical topics mentioned in each paper. Compute:
- Total unique topics per candidate
- Jaccard similarity: |A intersection B| / |A union B|
- Unique-to-Claude: topics in Claude but not Gemini
- Unique-to-Gemini: topics in Gemini but not Claude

### Unique Insight Count
An "insight" is a non-obvious claim or connection that:
- Combines two or more findings into a novel conclusion
- Identifies a pattern not explicitly stated in the source KB
- Proposes a mechanism or explanation for observed behavior

Two reviewers (peer-reviewer agents) independently identify insights. Count those
appearing in one candidate but not the other.

### Cross-Cutting Reference Count
Count references that explicitly compare or connect an Anthropic technology to a
Google/DeepMind technology (or vice versa).

### Citation Diversity
Count unique URLs cited per candidate. Measure overlap (shared citations / total unique).

## Sample Size

N=2 candidates (this is a case study, not a powered experiment). Frame as qualitative
comparative analysis, not hypothesis testing. Report descriptive metrics, not p-values.

## Analysis Plan

1. **Topic extraction**: Grep each candidate for technical terms, build topic sets
2. **Jaccard similarity**: Compute overlap coefficient
3. **Insight coding**: Two peer-reviewer passes, count unique insights per candidate
4. **Cross-cutting count**: Grep for patterns like "Anthropic...Google", "A2A...MCP", etc.
5. **Citation extraction**: Extract all URLs, compute overlap and diversity
6. **Qualitative comparison**: Narrative analysis of where candidates diverge most

## Threats to Validity

- **Internal**: N=2, no statistical power. Differences may reflect prompt design, not vendor capability.
- **External**: Single paper topic (S2); results may not generalize to other research questions.
- **Construct**: "Insight" is subjectively defined; inter-rater reliability may be low.

## Results

<to be filled after Phase 2 analysis>

## Conclusions

<to be filled after Phase 2 analysis>
