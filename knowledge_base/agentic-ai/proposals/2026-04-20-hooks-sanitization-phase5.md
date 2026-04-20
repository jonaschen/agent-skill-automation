# Skill Proposal: Phase 5 Hooks Sanitization Requirement

**Date**: 2026-04-20
**Triggered by**: CheckPoint CVEs (CVE-2025-59536, CVE-2026-21852) — Claude Code hooks RCE
**Priority**: P3 (requirements capture, not implementation)
**Target Phase**: Phase 5.5 Defensive architecture
**Strategic Priority**: S1 (self-improvement loop security hardening)

## Rationale

CheckPoint published two CVEs demonstrating RCE and API token exfiltration through malicious `.claude/hooks/` files in cloned repositories. This is a **distinct vulnerability class** from the MCP STDIO family:

| CVE | Attack Vector | Mechanism |
|-----|---------------|-----------|
| CVE-2025-59536 | Malicious `.claude/hooks/` in cloned repos | RCE — hooks execute arbitrary shell commands on agent invocation |
| CVE-2026-21852 | Crafted project config | API token exfiltration via environment variable access in hooks |

**Current exposure**: Low — our pipeline operates on a trusted codebase. No untrusted repos are cloned.

**Phase 5 exposure**: High — when agents operate on external codebases (skill generation for third-party projects, multi-agent systems processing external PRs), hooks in cloned repos could execute arbitrary code with the agent's credentials.

## Proposed Specification

- **Name**: Not a new skill — this is a one-line security requirement for Phase 5
- **Type**: ROADMAP addition (Phase 5.5 Defensive architecture)
- **Key capability**: `.claude/` directory scanning before agent execution on any cloned/forked repo

## Requirement Text

```markdown
> **Security requirement (2026-04-20)**: Hooks sanitization for external repositories — scan `.claude/` directory in any cloned/forked repo before agent execution. Remove or quarantine `.claude/hooks/` files. Validate `.claude/settings.json` and `.claude/settings.local.json` for suspicious entries. Attack vectors: RCE via hooks (CVE-2025-59536), API token exfiltration (CVE-2026-21852). Distinct from MCP STDIO family — project-level, not transport-level.
```

## Implementation Notes

- This is requirements capture only — no code change
- Implementation approach (Phase 5): pre-agent-execution scan of `.claude/` directory in target repo
- Simple version: `rm -rf .claude/hooks/` before agent invocation on untrusted repos
- Robust version: allowlist of permitted `.claude/` files, quarantine unexpected entries
- Should be combined with the existing MCP config validation (`mcp_config_validator.sh`) into a "project security scanner" that validates the entire `.claude/` directory

## Estimated Impact

- Prevents a class of attacks where malicious actors embed hooks in repos submitted for agent processing
- Zero operational impact until Phase 5 (we don't clone untrusted repos today)
- Design pattern is reusable: any CI/CD system that processes external repos faces this same risk
