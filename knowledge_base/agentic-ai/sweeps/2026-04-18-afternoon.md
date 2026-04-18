# Agentic AI Sweep Report — 2026-04-18 (Afternoon)

**Track**: Anthropic only
**Cycle**: Afternoon (catches US-morning announcements)
**Directive**: 2026-04-18 night directive — execution support + strategic research mode

## Executive Summary

- **No new Claude Code releases** since v2.1.114 (Apr 17). Landscape stable.
- **Agent SDK v0.1.62 + v0.1.63** (Apr 17-18): new top-level `skills` option simplifies skill configuration in SDK sessions. Bundles CLI v2.1.113/v2.1.114.
- **Claude Design launched** (Apr 17): new Anthropic Labs visual design product powered by Opus 4.7, with Claude Code handoff bundles. Research preview on paid plans.
- **Shadow eval NOT run yet**: experiment_log.json has no Opus 4.7 entries. Factory steward's 3 AM run completed P0 breaking change audit (CLEAN) but did not execute shadow eval. Pending next factory cycle.
- **OTEL pilot NOT run yet**: also pending next factory steward cycle.
- **Opus 4.7 token burn rate**: Issue #49562 still OPEN, no Anthropic response, auto-closure in ~3 days. Three related duplicates. No resolution or workaround.
- **All other topics unchanged** from night sweep: MCP, Tool Use, Computer Use, Multi-Agent Patterns stable.

## Anthropic Updates

### Claude Code
- **v2.1.114 remains latest**. No new releases since Apr 17. Stable period post-Opus 4.7 launch.
- **Claude Design** (Apr 17, new product): visual design collaboration tool. Creates prototypes, slides, pitch decks, 3D/shader work. Can read codebases + design files to build design systems. Handoff bundles for Claude Code. Powered by Opus 4.7. Research preview on Pro/Max/Team/Enterprise.

### Agent SDK
- **v0.1.62** (Apr 17): new top-level `skills` option in `ClaudeAgentOptions` — `"all"`, named list, or `[]`. Bundles CLI v2.1.113.
- **v0.1.63** (Apr 18): maintenance, bundles CLI v2.1.114 (agent teams crash fix).

### Model Releases
- **Opus 4.7 token burn**: #49562 still open, no staff response. Related: #49356 (1.7-2x), #49541 (4x from silent switch). Anthropic guidance: "measure on your traffic."
- **Shadow eval**: NOT run. Factory steward 3 AM session completed breaking change audit CLEAN, programmatic tool calling security analysis, 1M beta audit — but did not execute `python3 eval/run_eval_async.py --model claude-opus-4-7`.
- **Haiku 3**: retires Apr 20 (tomorrow is Apr 19, retirement is Apr 20). Guard in place.

### MCP
- No changes since evening sweep. AAIF governance confirmed. 10K+ servers.

### Tool Use & Function Calling
- No changes since evening sweep.

### Computer Use
- No changes since evening sweep.

### Multi-Agent Patterns
- No changes since evening sweep. Agent Teams experimental feature documented. Five-pattern taxonomy stable.

## Implications for Our Pipeline

### P0 — Shadow Eval Blocker
The shadow eval remains the critical path item for Opus 4.7 fleet migration. The factory steward correctly prioritized the breaking change audit first (confirmed CLEAN), but the shadow eval was not included in the 3 AM session's scope. **Expected to run in today's 4 PM factory cycle or tomorrow's 3 AM cycle.** Go/no-go criteria from night discussion ADOPT A2: posterior mean within 5% of 0.829 baseline, CI overlap with [0.702, 0.927], no 400 errors.

### P1 — Agent SDK `skills` Option
The new `skills` option in v0.1.62 simplifies SDK session configuration. If we migrate steward agents from `claude -p` to the SDK in Phase 5, `skills: ["steward"]` replaces the manual `allowed_tools` + `setting_sources` setup. Also: `skills: []` is useful for clean eval sessions.

### P2 — Claude Design
Not directly relevant to current pipeline. Signals Anthropic expanding beyond code to full product creation. Design handoff bundles for Claude Code could be relevant if we add UI-skill generation capabilities in Phase 7.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 4 (shadow eval pending) | Opus 4.7 live, tokenizer different | No validated eval data on 4.7 | P0 |
| Phase 5 (SDK migration planned) | SDK v0.1.63 with `skills` option | Migration path simplified | P1 |
| N/A | Claude Design launched | No design automation capability | P3 |

## Actions Taken
- Updated `knowledge_base/agentic-ai/anthropic/agent-sdk.md` — added v0.1.62/v0.1.63 entries
- Updated `knowledge_base/agentic-ai/anthropic/claude-code.md` — added Claude Design entry
- Updated `knowledge_base/agentic-ai/anthropic/model-releases.md` — added shadow eval status + token burn update

## Next Sweep Focus
- **Haiku 3 post-retirement verification** (Apr 20 morning): confirm API error format, community reports, guard confirmation
- **Shadow eval results** (if run before next sweep): analyze posterior mean, CI, duration, error rate
- **OTEL pilot results** (if run before next sweep): analyze span structure, available attributes
- **Weekend cadence**: lighter sweeps, one per cycle sufficient if nothing breaks
