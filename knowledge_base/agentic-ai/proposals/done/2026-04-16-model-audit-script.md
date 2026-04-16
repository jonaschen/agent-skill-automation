# Skill Proposal: model-audit-script
**Date**: 2026-04-16
**Triggered by**: Haiku 3 retirement April 19 (3 days) — `claude-3-haiku-20240307` retires. Pre-deploy guard only fires at deploy time; cron scripts calling the model directly bypass it.
**Priority**: P0 (critical)
**Target Phase**: Phase 4 (operational gate — active before Phase 4 close)

## Rationale

`claude-3-haiku-20240307` retires April 19, 2026 — three days from today. Our `deprecated_models.json`
entry and pre-deploy guard are in place, but the guard fires only at deploy time. Any cron script
(e.g., `daily_research_sweep.sh`, `eval/run_eval_async.py`) that calls the model directly without
going through the Claude Code hook chain bypasses the guard entirely.

Additionally, the April 30 sunset of the 1M context beta headers (`anthropic-beta: interleaved-thinking`
and `max-tokens-3-5-sonnet`) for Sonnet 4.5/4 requires verification that no eval runner or agent script
uses these headers.

Discussion consensus (2026-04-16 Round 1, Innovator + Engineer): "This is hygiene, not innovation — but
skipping it means a live breakage in 72 hours."

## Proposed Specification

- **Name**: `model_audit.sh`
- **Type**: CI/CD Shell Script (not a Skill — operational tooling)
- **Location**: `scripts/model_audit.sh`
- **Integration**: Integrated into `.claude/hooks/pre-deploy.sh` (alongside existing `eval/model_deprecation_check.sh`)

**Key Capabilities**:
- Grep full repo (not just `scripts/`, `eval/`, `.claude/` — include `~/.claude/agents/` per Engineer's note) for `claude-3-haiku-20240307`
- Grep for `anthropic-beta` headers referencing `interleaved-thinking` or `max-tokens-3-5-sonnet`
- Report hits with file path and line number
- Exit non-zero if any hits found (blocks deploy when integrated into pre-deploy.sh)
- Outputs a clean "no deprecated models detected" confirmation on clean pass

**Tools Required**: Bash (grep, find)

## Implementation Notes

**Scope of grep** (per Engineer's Round 1 response):
- `scripts/**/*.sh`
- `eval/**/*.py`, `eval/**/*.sh`, `eval/**/*.json`
- `.claude/agents/*.md`, `.claude/skills/**/*.md`, `.claude/hooks/*.sh`
- `~/.claude/agents/*.md` (global role library — agent .md files embed example model IDs)
- Top-level `*.json`, `*.md`

**Integration sequence**:
1. Write `scripts/model_audit.sh`
2. Call it from `.claude/hooks/pre-deploy.sh` after `eval/model_deprecation_check.sh`
3. Verify it catches `claude-3-haiku-20240307` references before migrating them
4. Migrate any hits to `claude-haiku-4-5-20251001`
5. Commit with migration in same commit as script addition

**Key constraint**: The migration of any detected model IDs must happen BEFORE April 19. The script
itself is a secondary deliverable — the immediate migration is the P0 action.

## Estimated Impact

- Eliminates time-boxed breaking change risk (April 19 Haiku 3 retirement)
- Provides permanent CI protection against future deprecated model references in cron scripts
- Closes the gap between deploy-time guard (`model_deprecation_check.sh`) and runtime usage in scheduled scripts
- Estimated implementation: 30-60 minutes for script + migration

## Immediate Actions Required

1. **Run now** (before factory-steward next session): grep for `claude-3-haiku-20240307` across full repo
2. Migrate any hits to `claude-haiku-4-5-20251001`
3. Grep for `anthropic-beta` headers on Sonnet 4 variants — verify none used
4. Write `scripts/model_audit.sh` as permanent guard
5. Integrate into `pre-deploy.sh`
