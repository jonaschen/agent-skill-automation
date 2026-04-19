# Agentic AI Sweep Report — 2026-04-20 (Anthropic Track)

## Executive Summary

- **Haiku 3 retires today (April 20)**: Pipeline guard PASS — zero references in operational code. `model_audit.sh` and `model_deprecation_check.sh` both clean. Non-event for pipeline.
- **Shadow eval gate-first contract: structurally working, LLM still not executing**: The A1 preamble fires correctly at the shell level (confirmed in Apr 19 factory log), but the agent inside the session did not run the eval. No factory session ran April 20. New failure diagnosis: LLM prioritization issue, not script bug.
- **MCP STDIO vulnerability escalation**: OX Security published comprehensive report — 10+ CVEs across AI ecosystem, 150M+ downloads affected, ~200,000 vulnerable instances. Anthropic maintains "expected behavior" stance, declined protocol patch. Four exploitation families identified, including allowlist bypass via `npx` flags.
- **Opus 4.7 adaptive reasoning**: No patch released. PM "sprinting on tuning" (Apr 19) — no follow-up.
- **Claude Code v2.1.114**: Stable for 72+ hours. Weekend quiet. No new releases.
- **Claude Design**: Additional details confirmed — export to Canva/PDF/PPTX/HTML, explicit Claude Code handoff bundle, Opus 4.7-powered.

## Anthropic Updates

### Model Releases
- **Haiku 3 (`claude-3-haiku-20240307`)**: Official retirement date today, April 20, 2026. Status still shows "Deprecated" on platform.claude.com (may update to "Retired" shortly). Replacement: `claude-haiku-4-5-20251001`. Pipeline guard fully clean.
- **Opus 4.7**: No patch for adaptive reasoning token burn. Issue #49562 open, PM acknowledged. Community backlash continues (AMD 6,852-session analysis, 35% cost increase reports, "Claude-lash" coverage).
- **No new model releases** since Opus 4.7 (Apr 16).

### Claude Code
- **v2.1.114** remains latest (released Apr 17). No new versions. Weekend release cadence normal.
- **Claude Design** (launched Apr 17): Confirmed details — Opus 4.7-powered visual design tool, exports to Canva/PDF/PPTX/standalone HTML, Claude Code handoff bundles, Pro/Max/Team/Enterprise.

### Agent SDK
- Python v0.1.63, TypeScript v0.2.114. No changes. Weekend freeze.

### MCP
- **Major escalation**: OX Security "Mother of All AI Supply Chains" report identifies systemic command injection via STDIO transport. 10+ CVEs (9 critical-rated): CVE-2026-30623 (LiteLLM), CVE-2026-30624 (Agent Zero), CVE-2026-30618 (Fay), CVE-2026-33224 (Bisheng/Jaaz), CVE-2026-30617 (Langchain-Chatchat), CVE-2026-30625 (Usopnic), CVE-2026-30615 (Windsurf), CVE-2026-26015 (DocsGPT), CVE-2025-65720 (GPT Researcher), GHSA-c9gw-hvqq (Flowise).
- **Four exploitation families**: Direct UI injection, hardening bypass (npx flags), prompt injection modifying configs, hidden STDIO config MITM.
- **Anthropic stance**: "This is an explicit part of how MCP stdio servers work" — declined protocol patch. Quietly updated security policy to advise caution.

### Tool Use & Function Calling
- No changes. Task Budgets remain API-only.

### Computer Use
- No changes. Still research preview. No GA announcement.

### Multi-Agent Patterns
- No new announcements or engineering blog posts.

## Implications for Our Pipeline

1. **Haiku 3 retirement**: Non-event. Guard worked as designed across 3 layers (deprecated_models.json, model_audit.sh, model_deprecation_check.sh).
2. **Shadow eval**: A1 gate-first contract fires at shell level but LLM agent ignores the injected instructions. This is a priority inversion at the LLM level, not a script bug. Manual run by Jonas remains fastest path.
3. **MCP STDIO security**: The `npx` allowlist bypass pattern directly applies to our `cmd_chain_monitor.sh`. Phase 5 blocking mode needs argument-pattern validation beyond binary name checking.
4. **Opus 4.7 patch timing**: If Anthropic patches adaptive reasoning before our shadow eval runs, we'll get different results than what community is reporting now. Consider running eval before patch for baseline.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 4 (shadow eval) | Opus 4.7 GA for 4 days | Shadow eval still not executed — 7th cycle | P0 |
| Phase 5 (cmd_chain_monitor) | MCP STDIO 10+ CVEs, argument-blind bypass confirmed | Allowlist checks binary names only, not arguments | P1 |
| Pipeline security | Anthropic won't fix STDIO transport | Need STDIO→Streamable HTTP migration plan for any production MCP | P2 |

## Skill Proposals Generated
None this cycle. Weekend quiet — no new capabilities to respond to.

## Actions Taken
- Updated 7 KB files (model-releases, claude-code, model-context-protocol, agent-sdk, tool-use, multi-agent-patterns, computer-use)
- Verified Haiku 3 guard: `model_audit.sh` PASS, `model_deprecation_check.sh` PASS
- Confirmed shadow eval experiment_log.json: zero claude-opus-4-7 entries
- Confirmed A1 gate-first preamble fired in Apr 19 factory log

## Next Sweep Focus
- **Shadow eval**: Check factory-2026-04-21.log for gate-first execution result
- **Haiku 3**: Confirm status changes from "Deprecated" to "Retired" on official page
- **Opus 4.7 patch**: Monitor for adaptive reasoning tuning updates (PM said "shortly")
- **MCP**: Watch for Anthropic protocol-level response (unlikely given "expected behavior" stance)
