# Credential Isolation Design Document

**Date**: 2026-04-13
**Source**: Discussion 2026-04-12, ADOPT #3; Managed Agents analysis (sweep 2026-04-12)
**Status**: Design reference for Phase 5.3 (Security Requirements) and Phase 7 (Multi-Tenant AaaS)
**Priority**: P2 — design only, no implementation until Phase 5

---

## 1. Current Credential Surface

### Env Vars by Agent Need

| Env Var | Who Needs It | Purpose |
|---------|-------------|---------|
| `ANTHROPIC_API_KEY` | All 7 agents | Claude API access |
| `GITHUB_TOKEN` | factory-steward, project-reviewer (steering notes) | Git push to target repos |
| `HOME` | All | File system access |
| `PATH` | All | Tool execution |
| `TERMINAL` | None (unset via CVE-2026-35020 mitigation) | N/A |
| `CLAUDE_CODE_EFFORT` | All (optional) | Reasoning effort tuning |
| `CLAUDE_INITIATOR_TYPE` | All | Cron vs interactive policy enforcement |

**Key finding**: Most agents need only `ANTHROPIC_API_KEY`. The researcher, android-sw, arm-mrs, and bsp-knowledge stewards have no legitimate need for `GITHUB_TOKEN` — they commit locally but never push. Only factory-steward (steering notes in external repos) and project-reviewer (steering notes) require git push credentials.

### Credential Flow

```
crontab (user jonas)
  │
  ├── env: inherits full user environment
  │
  └── bash script (e.g., daily_factory_steward.sh)
        │
        ├── sources: scripts/lib/cost_ceiling.sh
        ├── sources: scripts/lib/session_log.sh
        ├── sources: scripts/lib/check_fleet_version.sh
        ├── unset TERMINAL (CVE mitigation)
        ├── export CLAUDE_INITIATOR_TYPE=cron-automated
        │
        └── claude -p "<prompt>" --allowedTools '...'
              │
              ├── inherits: all parent env vars
              ├── reads: CLAUDE.md, ROADMAP.md (may reference env vars)
              ├── tool calls: Bash (full env access), Read, Write, Edit
              │
              └── subagent (Task delegation)
                    └── inherits: parent session env + tools
```

**Isolation boundaries (potential enforcement points):**
1. Crontab → script: `env -i` to start clean, explicit var passthrough
2. Script → Claude session: `--env` flag (if supported) or wrapper
3. Claude session → subagent: Agent SDK `exclude_dynamic_sections` controls prompt inheritance
4. Claude session → MCP tools: MCP proxy for credential-mediated access

---

## 2. Threat Model

| Threat | Current Risk | Phase 5 Risk | Phase 7 Risk |
|--------|-------------|-------------|-------------|
| Compromised agent reads `GITHUB_TOKEN` | Low (single user) | Medium (generated skills in sandbox) | High (multi-tenant) |
| Agent exfiltrates API key via Bash | Low (trust boundary) | Medium (untrusted skill code) | High |
| MCP tool leaks credentials | Low (no MCP tools today) | Medium (A2A bus) | High (marketplace) |
| Subagent inherits parent credentials | Low | Medium (skill testing) | High |
| Env var injection via tool output | Low (CVE-2026-35020 mitigated) | Low | Medium |

---

## 3. Reference Patterns (Managed Agents)

### Pattern 1: Resource-Bundled Auth

```
Setup phase:          credentials → initialize resources (repos, DBs, APIs)
Execution phase:      sandbox operates on initialized resources
                      NO direct credential access during execution
```

**Applicability to our pipeline**: Strong fit for steward agents. During setup,
clone/fetch target repos with credentials. During execution, steward works on
local files — no credential needed. Git push happens post-session via script,
not via agent Bash tool.

### Pattern 2: Vault-Based MCP Proxy

```
Agent session:        needs OAuth token for external API
                      ↓
MCP proxy server:     reads token from vault (HashiCorp, AWS SSM, GCP Secret Manager)
                      ↓
External API:         MCP proxy makes authenticated call
                      ↓
Agent receives:       result only (no token exposure)
```

**Applicability**: Future Phase 7 requirement for marketplace integrations and
multi-tenant credential isolation. Not needed at Phase 4/5.

### Pattern 3: Agent SDK `exclude_dynamic_sections`

The Agent SDK's `SystemPromptPreset` supports `exclude_dynamic_sections` to prevent
dynamic content (potentially including credential references or session-specific
secrets) from being included in cross-user cached prompt prefixes. When adopting
Agent SDK in Phase 5:

- Static CLAUDE.md content → cacheable across agents
- Dynamic status, credential references, session context → excluded from cache
- Prevents credential leakage via prompt cache sharing

---

## 4. Minimal Isolation Model (Phase 5)

### Per-Agent Env Var Subsets

```bash
# In each daily script, replace implicit env inheritance with explicit passthrough:

# Before (current):
claude -p "$PROMPT" ...

# After (Phase 5):
env -i \
  HOME="$HOME" \
  PATH="$PATH" \
  ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
  CLAUDE_INITIATOR_TYPE=cron-automated \
  claude -p "$PROMPT" ...
```

**Agent-specific additions:**
- factory-steward, project-reviewer: add `GITHUB_TOKEN` (steering notes push)
- All others: no `GITHUB_TOKEN`

### Generated Skill Sandbox Isolation

When Phase 5 tests generated skills, the sandbox MUST NOT inherit parent credentials:

```bash
# Skill testing sandbox (no API keys, no tokens):
env -i HOME=/tmp/skill-sandbox PATH=/usr/bin:/bin \
  claude -p "test this skill..." --allowedTools 'Read,Glob,Grep'
```

### Implementation Checklist (Phase 5)

- [ ] Audit all 7 daily scripts for env var usage
- [ ] Implement `env -i` + explicit passthrough in each script
- [ ] Test that agents function correctly with reduced env
- [ ] Add env var audit to `security_suite.sh`
- [ ] Document per-agent env var policy in CLAUDE.md

---

## 5. Full Isolation Model (Phase 7 — Multi-Tenant AaaS)

### MCP Proxy Architecture

```
Tenant A agent ──→ MCP Credential Proxy ──→ Vault (Tenant A secrets)
Tenant B agent ──→ MCP Credential Proxy ──→ Vault (Tenant B secrets)
                         │
                    Per-tenant scoping
                    Audit logging
                    Rate limiting
```

### Requirements (to be refined at Phase 7 design time)

- Per-tenant secret namespaces in vault
- MCP proxy enforces tenant isolation (agent A cannot access tenant B secrets)
- All credential access logged for billing and compliance audit
- Credential rotation without agent session interruption
- Emergency credential revocation with <5min propagation

---

## 6. Migration Path

| Phase | Action | Risk |
|-------|--------|------|
| Phase 4 (current) | Document-only (this file) | None |
| Phase 5 | Implement `env -i` isolation in daily scripts | Low — may break scripts if env vars missed |
| Phase 5 | Add env var audit to security suite | None |
| Phase 5 | Sandbox isolation for generated skill testing | Low |
| Phase 7 | Deploy MCP credential proxy | Medium — new infrastructure |
| Phase 7 | Per-tenant vault integration | Medium — operational complexity |
