# Agentic AI Sweep Report — 2026-04-21 (Anthropic Track Only)

## Executive Summary

- **Freeze extends into Monday (~120h+)**: CC v2.1.114, SDK Py v0.1.63, TS v0.2.114 — unprecedented weekday freeze. No new releases across any Anthropic product.
- **Haiku 3 past retirement date, still "Deprecated" on official page**: Retirement date was April 20. As of April 21, the deprecation table still shows "Deprecated" (not "Retired"). Third-party sources report the model returns errors. Page update lagging.
- **Opus 4.7 #49562 OPEN, zero staff responses**: Only 2 community comments. PM's "sprinting on tuning" (Apr 19) has had no follow-up. No patch.
- **Shadow eval pending** — manual run or cron.
- **1M context beta sunset in 9 days (April 30)**: Migration path clear — move to Sonnet 4.6/Opus 4.6 (1M GA, no beta header needed).

## Anthropic Updates

### Claude Code
- **v2.1.114 still latest** (Apr 18). No v2.1.115. Freeze ~120h+, longest observed in v2.1.x era. Unprecedented for a Monday.
- **Source**: https://github.com/anthropics/claude-code/releases

### Agent SDK
- **Python v0.1.63** (Apr 18, bundles CLI v2.1.114) still latest. No new releases.
- **TypeScript v0.2.114** (Apr 18, CLI v2.1.114 parity) still latest. No new releases.
- SDK freeze tracks CLI freeze — no SDK update expected until CLI ships v2.1.115+.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/releases

### Model Releases
- **Haiku 3** (`claude-3-haiku-20240307`): Retirement date was April 20. Official deprecation page still shows "Deprecated" not "Retired" — page update is lagging. Model is functionally retired (API returns errors per third-party reports). Our 3-layer guard PASS validated.
- **Opus 4.7 #49562**: OPEN, 2 comments (both community), zero Anthropic staff responses. PM "sprinting on tuning" (Apr 19) — no follow-up.
- **Opus 4/Sonnet 4**: Deprecated Apr 14, retire June 15 (55 days).
- **1M context beta**: Sunsets April 30 (9 days). Affects Sonnet 4.5/Sonnet 4 only. Migration: switch to Sonnet 4.6/Opus 4.6 (1M GA at standard pricing, no beta header).
- **Source**: https://platform.claude.com/docs/en/about-claude/model-deprecations, https://github.com/anthropics/claude-code/issues/49562

### Model Context Protocol
- No new releases, CVEs, or governance changes. Steady state.
- **Source**: https://blog.modelcontextprotocol.io/

### Tool Use & Function Calling
- No new changes. Programmatic tool calling GA. Strict schema adherence available. Advisor Tool in public beta.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling

### Computer Use
- Still research preview. No GA announcement. Windows expansion holds.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### Multi-Agent Patterns
- No new patterns. Five-pattern taxonomy holds. Managed Agents in public beta. Agent Teams stable.
- **Source**: https://code.claude.com/docs/en/agent-teams

## Implications for Our Pipeline

- **Freeze anomaly**: Monday freeze is unprecedented. May signal a larger bundled release staging, or Anthropic internal focus on Opus 4.7 tuning. Monitor afternoon/evening for potential burst.
- **Shadow eval**: Still pending — zero opus-4-7 entries in experiment_log.json. Manual run or cron.
- **1M sunset (9 days)**: Non-issue for our fleet (already on GA 4.6 models). No action needed.
- **Haiku 3 guard validated**: First automated model retirement handled cleanly. Page label lag is cosmetic.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 4 (current) | All Anthropic releases frozen ~120h+ | No gap — freeze means no new capabilities to integrate | P2 |
| Phase 4 (S1) | Shadow eval infrastructure deployed but unexecuted | Human action blocker (manual run) | P0 |

## Skill Proposals Generated

None this sweep. Freeze continues — no new capabilities to propose against.

## Actions Taken

- Updated 7 Anthropic KB files with April 21 findings
- Wrote sweep report

## Next Sweep Focus

- **Monitor afternoon/evening for freeze break** — if v2.1.115+ ships, extend analysis depth
- **Haiku 3 official status flip** — check if deprecation page updates to "Retired"
- **Opus 4.7 #49562** — monitor for Anthropic staff response or patch
