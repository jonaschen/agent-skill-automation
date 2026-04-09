---
sidebar_position: 3
title: Project Reviewer
---

# Project Reviewer

The project reviewer is the autonomous tech lead for the three project steward agents. It runs every morning at 7:00 AM after all stewards have completed their nightly work.

## What It Does

1. **Reads each steward's output**: log files, performance JSON records, and actual git commits
2. **Cross-references against ROADMAP**: checks each project's `ROADMAP.md` and `CLAUDE.md` for alignment
3. **Assesses quality**: correctness of changes, progress toward milestones, architectural risks
4. **Writes structured review reports**: to `knowledge_base/steward-reviews/`
5. **Issues steering notes**: writes `.claude/steering-notes.md` in each target repo when correction is needed
6. **Validates modified skills**: triggers `skill-quality-validator` when stewards modify skill definitions
7. **Escalates issues**: flags stalled, regressing, or off-roadmap stewards for human attention

## Review Dimensions

| Dimension | What it checks |
|-----------|---------------|
| Correctness | Did the commits introduce bugs or regressions? |
| Alignment | Is the work advancing the project's ROADMAP? |
| Progress | How much of the planned work got completed? |
| Risks | Are there architectural decisions that need human review? |

## Boundaries

The project reviewer is strictly read-only on source code:
- Does **not** modify source code, skill files, or scripts in any repo
- Does **not** execute builds, tests, or deployments
- Does **not** perform the stewards' work itself
- Only writes review reports and steering notes

## Output Artifacts

### Review Reports

Written to `knowledge_base/steward-reviews/` with the structure:

```
knowledge_base/steward-reviews/
+-- android-sw-review-YYYY-MM-DD.md
+-- arm-mrs-review-YYYY-MM-DD.md
+-- bsp-knowledge-review-YYYY-MM-DD.md
```

### Steering Notes

Written to each target repo's `.claude/steering-notes.md` when corrections are needed. Steward agents read these at the start of their next session.

### Performance Records

Written to `logs/performance/reviewer-YYYY-MM-DD.json` with metrics on review duration, findings count, and escalation decisions.
