# Skill Proposal: Dependency Pinning + Audit Gate
**Date**: 2026-04-05
**Triggered by**: LiteLLM supply chain compromise (3 ADK patches in 4 days), npm axios RAT; discussion ADOPT #2
**Priority**: P1 (high)
**Target Phase**: 4 (Security Hardening)

## Rationale

Supply chain attacks are now actively exploited in the agent framework ecosystem. ADK Python shipped 3 emergency patches (v1.27.3-v1.27.5) for a compromised LiteLLM dependency. A RAT was found in axios npm packages. Our pipeline has two exposure surfaces:
1. Python packages: eval tools (`run_eval_async.py`, `bayesian_eval.py`, `prompt_cache.py`)
2. npm/Node.js: Claude Code distribution chain

## Proposed Specification
- **Name**: dependency-pinning (pipeline hardening, not a Skill)
- **Type**: CI/CD gate extension
- **Description**: Lock Python dependencies and audit npm packages
- **Key Capabilities**:
  - `pip freeze > requirements.txt` — locked manifest checked into git (BLOCKING on deploy)
  - `pip install --require-hashes -r requirements.txt` in CI environments
  - `npm audit --audit-level=high` — WARNING only, not blocking (we're downstream of Claude Code's npm chain and can't fix their deps)
  - Added to `.claude/hooks/pre-deploy.sh`
- **Tools Required**: Bash

## Implementation Notes
- `pip freeze` captures current working state — run from the eval/ virtualenv if one exists, otherwise from system Python
- `npm audit` as warning-only per Engineer decision: high-severity npm findings could block the entire pipeline on things we can't fix
- Both are single-line additions to existing scripts

## Estimated Impact
- Prevents silent dependency drift that could introduce compromised packages
- Near-zero implementation cost with meaningful defense-in-depth
- Establishes supply chain hygiene that scales to Phase 7 production deployments
