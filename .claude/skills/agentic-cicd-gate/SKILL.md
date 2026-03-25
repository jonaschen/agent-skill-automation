---
name: agentic-cicd-gate
description: >
  Manages the deployment pipeline for Claude Agent Skills with automated
  quality gating, impact prediction, and rollback. See
  .claude/agents/agentic-cicd-gate.md for the full agent definition.
tools:
  - Read
  - Bash
  - Glob
  - Grep
model: claude-sonnet-4-6
---

# Agentic CI/CD Gate Skill

This Skill manages the full deployment lifecycle:

1. **Pre-deploy quality gate** — runs eval + permission checks, blocks sub-threshold deploys
2. **Change impact analysis** — identifies affected downstream agents, scopes regression tests
3. **Deployment execution** — copies validated files, commits with structured messages
4. **Post-deployment monitoring** — checks at 1h, 6h, 24h; compares against baselines
5. **Autonomous rollback** — reverts when trigger rate drops > 10%

## Integration Points

- `eval/run_eval.sh` — trigger rate measurement
- `eval/check-permissions.sh` — permission validation
- `eval/flaky_detector.py` — flaky test detection and quarantine
- `.claude/hooks/pre-deploy.sh` — pre-deploy quality gate
- `eval/deploy_history.json` — deployment event log
