---
name: skill-quality-validator
description: >
  Validates the quality of Claude Agent Skill definitions through automated
  testing and static analysis. See .claude/agents/skill-quality-validator.md
  for the full agent definition.
tools:
  - Read
  - Glob
  - Grep
  - Bash
model: claude-sonnet-4-6
---

# Skill Quality Validator Skill

This Skill runs the 5-step validation pipeline to assess Skill quality:

1. **Frontmatter parse** — verifies YAML format, required fields, token budget
2. **Description quality** — evaluates trigger verb coverage, exclusion contexts, scope clarity
3. **Test set management** — checks for existing test sets or generates new ones
4. **Security audit** — runs `eval/check-permissions.sh`, checks permission rules
5. **Trigger rate measurement** — runs `eval/run_eval.sh`, applies 90%/75% thresholds

## Output

JSON validation report with `trigger_rate`, `security_score`, and `recommendations`.

## Thresholds

| Rate | Verdict | Action |
|------|---------|--------|
| ≥ 90% | PASS | Deploy allowed |
| 75–89% | CONDITIONAL | Deploy with warning |
| < 75% | FAIL | Block deploy, trigger autoresearch-optimizer |
