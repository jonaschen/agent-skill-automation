# Agentic AI Sweep Report — 2026-04-21 (Afternoon, Anthropic Only)

## Executive Summary

- **FREEZE BROKEN**: Claude Code v2.1.115 (Apr 19) + v2.1.116 (Apr 20) shipped after ~130h freeze. Significant release with 67% `/resume` speedup, MCP startup optimization, security fixes, and thinking progress indicators.
- **SDK updates**: Python Agent SDK v0.1.64 with production SessionStore adapters (S3, Redis, Postgres). TypeScript v0.2.116 at parity.
- **Opus 4.7 #49562 OPEN**: Zero staff responses. No adaptive reasoning patch in v2.1.115 or v2.1.116. Community frustration growing.
- **Opus 4.7 failure analysis (P1)**: Per-test shadow eval data MISSING from experiment_log.json — cannot characterize the 12/39 failure pattern. Data gap blocks S1 "recoverable vs. fundamental" determination.
- **1M context beta sunset**: 9 days (April 30). Non-issue for fleet. Migration: remove beta header → Sonnet 4.6/Opus 4.6.

## Anthropic Updates

### Claude Code
- **v2.1.116** (Apr 20): Major release. `/resume` 67% faster on 40MB+ sessions. MCP startup faster (deferred template listing). Thinking progress indicators. Security fix: sandbox rm/rmdir no longer bypasses dangerous-path safety for `/`, `$HOME`, system dirs. Devanagari rendering fix. Plugin auto-install. Multiple terminal and keyboard fixes.
- **v2.1.115** (Apr 19): Bridge release.
- **Source**: https://github.com/anthropics/claude-code/releases, https://code.claude.com/docs/en/changelog

### Agent SDK
- **Python v0.1.64** (Apr 20): Full SessionStore support with conformance tests. Three production-ready reference adapters: S3, Redis, Postgres. Bundles CLI v2.1.116.
- **TypeScript v0.2.116** (Apr 20): Parity with CC v2.1.116.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### Model Releases
- **Opus 4.7 #49562**: OPEN. 2 community comments, zero staff responses. Bot attempted auto-close as duplicate (linked #49356, #49541, #41771), community pushed back. Last comment Apr 19: "I would love to revert back to Opus 4.6 as 4.7 is worse then 4.6 on idle." No patch in v2.1.115/v2.1.116.
- **Haiku 3**: Past retirement date (Apr 20). Official page status update still pending. Guard PASS validated.
- **1M beta sunset**: April 30 (9 days). Remove `context-1m-2025-08-07` header, switch to 4.6 models. Non-issue for fleet.
- **Source**: https://github.com/anthropics/claude-code/issues/49562

### Model Context Protocol
- New TechTalks article (Apr 20) amplifies STDIO vulnerability coverage: "When expected behavior becomes a supply chain nightmare." Same issues tracked since Apr 16. No new CVEs. Anthropic stance unchanged.
- **Source**: https://bdtechtalks.com/2026/04/20/anthropic-mcp-vulnerability/

### Tool Use
- Stable. No API changes in v2.1.115/v2.1.116. Bash tool rate-limit hints for `gh` (UX only).

### Computer Use
- Still beta. No changes. No GA announcement.

### Multi-Agent Patterns
- Stable. No new patterns. Agent Teams, Managed Agents, Subagents all unchanged.

## Opus 4.7 Failure Analysis (P1 — One-Time)

**Status: DATA GAP — Cannot complete.**

The research-lead requested characterization of the 12/39 shadow eval failures (which test categories failed on Opus 4.7). Investigation found:
- `experiment_log.json`: Zero `opus-4-7` entries
- Shadow eval log files (`logs/shadow-eval-*.log`): Do not exist on disk
- Shadow eval performance JSONs (`logs/performance/shadow-eval-*.json`): Do not exist on disk

The shadow eval that produced the NO-GO verdict (posterior mean 0.683, CI [0.535, 0.814], 27/39 pass) did not persist per-test results to the standard experiment log. Only the aggregate score is known.

**What's needed**: Next shadow eval re-run must log per-test pass/fail results to `experiment_log.json`. The factory-steward should add per-test logging to `daily_shadow_eval.sh` before the next Opus 4.7 patch triggers a re-run.

**S1 impact**: Without per-test data, we cannot determine:
1. Are failures concentrated in positive tests (routing regression — potentially fixable via description tuning)?
2. Are failures concentrated in negative tests (false triggers — may indicate fundamental behavior change)?
3. Is there a mix (suggesting multiple issues)?

This blocks the "recoverable vs. fundamental" determination that shapes S1 strategy.

## Implications for Our Pipeline

1. **Upgrade CC to v2.1.116** — 67% `/resume` speedup benefits all steward sessions with large transcripts. Security fix important for agentic workflows.
2. **SessionStore adapters** — Python SDK v0.1.64's S3/Redis/Postgres SessionStore is Phase 5 infrastructure. If we migrate from `claude -p` to Agent SDK, persistent sessions across infrastructure are now production-ready.
3. **Shadow eval per-test logging** — Factory-steward should add per-test result logging to `daily_shadow_eval.sh` before next Opus 4.7 patch triggers re-run.
4. **No Opus 4.7 migration action** — #49562 unpatched, shadow eval NO-GO stands, `PENDING_MIGRATION_MODEL` remains set for automatic re-evaluation when patch ships.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 4 (current) | SessionStore with S3/Redis/Postgres adapters | No persistent session storage in pipeline | P2 |
| Shadow eval | Per-test failure data available elsewhere | Missing per-test logging in shadow eval script | P1 |
| CC version | v2.1.116 (Apr 20) | Fleet on v2.1.114 | P1 |

## Skill Proposals Generated

None this cycle. Freeze break was the primary event — operational updates, not new capabilities.

## Actions Taken

- Updated 7 KB files (claude-code, agent-sdk, model-releases, model-context-protocol, tool-use, computer-use, multi-agent-patterns)
- No deprecated_models.json changes needed (no new retirement announcements)

## Next Sweep Focus

- **Monitor for Opus 4.7 adaptive reasoning patch** (#49562) — if patch ships, shadow eval auto-triggers
- **Haiku 3 official "Retired" status flip** on deprecation page
- **Google track freeze break** — Google side was also frozen; check evening/tomorrow
- **v2.1.117+ releases** — now that freeze is broken, release cadence may accelerate
