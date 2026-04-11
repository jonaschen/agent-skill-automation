# Deferred Items — 2026-04-11

Items from today's discussion with clear rationale for deferral.

## D1: 1M Context Beta Sunset Contingency

**Priority**: P2 (deferred)
**Rationale**: Agents use 50-200K context, well under the 1M limit. The 1M beta sunset (April 30) likely means pricing changes, not capability removal. Implementing sweep segmentation (7 topics per session instead of 14) pre-emptively wastes effort. Claude Code doesn't expose context window usage metrics, so `max_context_tokens` perf JSON instrumentation is impossible today.
**Revisit**: When Anthropic announces post-beta terms (expected late April 2026). If context_tokens becomes available via Claude Code API, add instrumentation then.

## D2: Pre-Execution Blocking (PreToolUse Hook)

**Priority**: P2 (deferred)
**Rationale**: Requires Phase 5.5 hook infrastructure (`PreToolUse` hook) that doesn't exist yet. The detection baseline being built now (ADOPT #3: metacharacter detection in `cmd_chain_monitor.sh`) provides the 30-day data needed to calibrate the blocking allowlist. Detection before blocking — the allowlist needs real data to avoid false-positive disruption of legitimate piped commands.
**Revisit**: Phase 5.5 implementation, when PreToolUse hook infrastructure is designed

## D3: Advisor Tool for Phase 3.5 Distillation (Detailed Design)

**Priority**: P3 (deferred)
**Rationale**: Phase 3.5 is unscheduled and has no timeline. The advisor API is public beta (`advisor_20260301`) — billing model and quality profile could change before Phase 3.5 starts. A one-line ROADMAP note (ADOPT #6: "Evaluate Sonnet+Opus advisor as intermediate distillation tier") captures the idea without creating documentation debt that goes stale. Additionally, the simpler first experiment (pure Sonnet vs Opus, no advisor) should be tried first — if Sonnet alone matches on our 36-prompt Training set, the advisor adds unnecessary complexity.
**Revisit**: Phase 3.5 scheduling + advisor tool reaching GA status
