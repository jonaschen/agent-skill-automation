# Experiment: Structured Debate Effectiveness

**Date**: 2026-04-18
**Strategic Priority**: S2 (Multi-Agent Orchestration)
**Status**: design

## Hypothesis

The Innovator/Engineer structured debate format produces proposals with higher
implementation conversion rates and greater specificity than single-agent strategic
planning (L4 proposals generated without adversarial review).

## Research Questions

1. What is the ADOPT/DEFER/REJECT distribution across all discussion transcripts?
2. What proportion of ADOPT items are subsequently implemented (appear in git commits)?
3. Does the Engineer perspective genuinely modify proposals, or does it rubber-stamp?
4. Are proposals from discussions more specific than proposals from L4-only planning?
5. Do discussion quality metrics improve over time (learning effect)?

## Variables

- **Independent**: Proposal source (discussion ADOPT vs. L4-only proposal)
- **Dependent**: Implementation rate, specificity score, priority distribution
- **Controls**: Same pipeline context, same agent model

## Data Sources

- `knowledge_base/agentic-ai/discussions/*.md` -- all discussion transcripts (13+ files)
- `knowledge_base/agentic-ai/proposals/*.md` -- L4 proposals (for comparison baseline)
- `git log` -- implementation evidence (commits referencing ADOPT items or proposals)

## Sample Size

- Discussion transcripts: ~13 (with ~3 rounds each = ~39 proposal-response pairs)
- L4-only proposals: ~33 files
- Git commits: full history since April 4, 2026

## Measurement Definitions

### Specificity Score (0-3)
- 0: Vague ("improve the pipeline")
- 1: Names a component ("update the researcher agent")
- 2: Names a file or tool ("modify .claude/agents/agentic-ai-researcher.md to add X")
- 3: Names file + specific change ("add WebFetch rate limiting to line 374 of researcher.md")

### Implementation Conversion
An ADOPT item is "implemented" if:
- A git commit message references it (by name or ID), OR
- The specific file/change it proposes appears in git diff within 7 days of the discussion

### Engineer Pushback Rate
Proportion of Innovator proposals where the Engineer either:
- Rejects outright
- Proposes a simpler alternative
- Adds conditions/constraints before accepting

## Statistical Analysis Plan

1. **ADOPT/DEFER/REJECT distribution**: Count per discussion, compute proportions with 95% CI (Wilson score interval)
2. **Implementation conversion**: Count implemented ADOPT items / total ADOPT items, with 95% CI
3. **Specificity comparison**: Mean specificity score for discussion ADOPT items vs. L4-only proposals (Mann-Whitney U test)
4. **Pushback rate**: Proportion of proposals modified by Engineer, with 95% CI
5. **Temporal trend**: Spearman correlation between discussion date and (a) specificity, (b) ADOPT rate, (c) implementation rate

**Significance level**: alpha = 0.05
**Effect size**: rank-biserial correlation for Mann-Whitney U, phi coefficient for proportions

## Threats to Validity

- **Internal**: Same agent writes both discussion proposals and L4 proposals -- differences may reflect prompt design, not debate value. No randomization.
- **External**: Single system with specific Innovator/Engineer prompt. Different prompt formulations may produce different dynamics.
- **Construct**: "Implementation" is measured by git commit presence, which may miss implementations that weren't committed or were committed under different names. Specificity score is subjective -- inter-rater reliability should be assessed.

## Results

<to be filled after analysis>

## Conclusions

<to be filled after analysis>
