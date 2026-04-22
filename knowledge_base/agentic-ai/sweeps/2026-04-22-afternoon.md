# Agentic AI Sweep Report — 2026-04-22 Afternoon

## Executive Summary

- **CC v2.1.117 SHIPPED TODAY** — 2-day turnaround from v2.1.116, 25+ changes. Headline: **Opus 4.7 context window fix** (200K→1M computation), forked subagents on external builds, native bfs/ugrep, OTEL effort attribute, concurrent MCP connections, Advisor Tool stability fixes.
- **Opus 4.7 #49562 STILL OPEN** — zero staff responses, last activity Apr 19. But v2.1.117's context window fix (200K→1M) likely resolves premature autocompacting that was amplifying token burn. Core adaptive thinking cost increase (~35%) remains unaddressed.
- **Agent SDK unchanged** — still at Py v0.1.64, TS v0.2.116. No new releases.
- **MCP, Tool Use, Computer Use, Multi-agent Patterns: steady state** — no new standalone announcements, but v2.1.117 carries MCP improvements (declarative mcpServers in agent frontmatter, concurrent connections).
- **No new model releases** — Opus 4.7 remains latest.

## Anthropic Updates

### Claude Code
- **v2.1.117** (Apr 22) — Major release ending 2-day silence since v2.1.116 (Apr 20). Top items:
  - **Opus 4.7 context window fix**: CC computed against 200K instead of 1M, causing premature autocompacting — fixed.
  - **Forked subagents**: `CLAUDE_CODE_FORK_SUBAGENT=1` enables on external builds.
  - **Agent frontmatter `mcpServers`**: Declarative MCP dependency loading for agents.
  - **Native bfs/ugrep**: Replaces Glob/Grep tools on macOS/Linux native builds.
  - **Default effort `high`**: For Pro/Max on Opus 4.6/Sonnet 4.6 (was `medium`).
  - **OTEL enhancements**: `effort` attribute on cost/token events; `command_name`/`command_source` for slash commands.
  - **Advisor Tool**: Stability fixes, experimental labeling.
  - **Managed-settings**: `blockedMarketplaces`/`strictKnownMarketplaces` enforced.
  - **Bug fixes**: OAuth token refresh, WebFetch hang, proxy 204 crash, NO_PROXY under Bun, idle re-render loop on Linux, subagent malware false positive, Bedrock/Opus 4.7 with thinking disabled 400 error, MCP elicitation auto-cancel.
- **Source**: https://code.claude.com/docs/en/changelog, https://github.com/anthropics/claude-code/releases

### Agent SDK
- **No new releases.** Py v0.1.64 (Apr 20), TS v0.2.116 (Apr 20) — unchanged.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases

### Model Releases
- **No new model releases.** Opus 4.7 (Apr 16) remains latest.
- **Opus 4.7 #49562**: OPEN, zero staff responses, last update Apr 19. Labels: bug, area:cost, area:model. Duplicate bot flagged 3 related issues. Community sentiment: user requesting Opus 4.6 revert. Third-party ecosystem pressure: n8n #28635, openclaw #67888, pi-mono #3289 (`supportsAdaptiveThinking()` breakage).
- **Context window fix in v2.1.117** partially addresses issue — premature autocompacting from 200K computation was amplifying token usage.
- **Source**: https://github.com/anthropics/claude-code/issues/49562

### MCP
- **No new standalone announcements.** STDIO vulnerability media coverage continues (no new CVEs).
- **v2.1.117 MCP improvements**: Declarative `mcpServers` in agent frontmatter, concurrent connection default, elicitation fix, serial reload fix.

### Tool Use & Function Calling
- **No new API-level changes.** Web search + programmatic tool calling remain GA.
- **v2.1.117**: Native bfs/ugrep replacing Glob/Grep on native builds. OTEL `effort` attribute for adaptive thinking observability.

### Computer Use
- **No changes.** Still beta, Windows support via Cowork/CC Desktop.

### Multi-agent Patterns
- **No new announcements.** Managed Agents ($0.08/hr) remain in public beta.
- **v2.1.117**: `CLAUDE_CODE_FORK_SUBAGENT=1` democratizes forked subagents to external builds. Subagent malware false positive fixed.

## Implications for Our Pipeline

### S1 — Automatic Agent/Skill Improvement
1. **UPGRADE CC TO v2.1.117 (P0)** — The Opus 4.7 context window fix is critical for our fleet. Our agents run on Opus 4.6/4.7 and may have been silently affected by premature autocompacting.
2. **OTEL `effort` attribute** — enables external monitoring of adaptive thinking effort levels. Once we upgrade, our OTEL pipeline can track effort per request, giving the shadow eval system a new signal dimension.
3. **Shadow eval prefix match**: v2.1.117 may change Opus 4.7 behavior due to correct 1M context window. Re-run shadow eval after upgrade to get clean baseline.

### S2 — Multi-Agent Orchestration
1. **`CLAUDE_CODE_FORK_SUBAGENT=1`** — Test this env var for our agent fleet. Forked subagents may improve isolation and reduce context interference between agents in our cron pipeline.
2. **Advisor Tool** — Now stable enough to experiment with. The executor+advisor pattern (fast model executes, smart model advises) is a novel orchestration topology for the S2 paper.

### S3 — Platform Generalization
1. **Declarative `mcpServers` in agent frontmatter** — Agents can now specify their MCP dependencies declaratively. This converges with the S3 goal of portable agent definitions that carry tool requirements. Compare with Gemini Skills' tool declarations for the format comparison study.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 3 (shadow eval) | CC v2.1.117 fixes context window; OTEL adds effort tracking | Shadow eval needs re-run on v2.1.117; OTEL effort integration | P1 |
| Phase 4 (closed loop) | Forked subagents now externally available | Pipeline doesn't use forked subagents; could improve isolation | P2 |
| Phase 5 (multi-agent) | Advisor Tool stable; forked subagents external | Neither pattern in our Phase 5 design yet | P2 |

## Skill Proposals Generated

None. The v2.1.117 changes are infrastructure improvements that strengthen existing capabilities rather than creating new skill opportunities.

## Actions Taken

- Updated 5 KB files: claude-code.md, model-releases.md, model-context-protocol.md, multi-agent-patterns.md, tool-use-and-function-calling.md
- No proposals generated
- No deprecated_models.json updates needed (no new retirement announcements)

## Google/DeepMind Updates

### Gemini CLI — Preview Channel Breaks Freeze
- **v0.39.0-preview.2** shipped TODAY (Apr 22, 00:45 UTC). v0.39.0-preview.1 shipped Apr 21. Three preview releases in 8 days while stable (v0.38.2, Apr 17) remains frozen at day 5.
- **Major features in preview.0** (45+ PRs): unified `invoke_subagent` tool (consolidation from multiple tools), `/memory inbox` command (review extracted skills), JSONL streaming for chat recording, plan mode skill confirmation, `useAgentStream` hook, dynamic session ID injection (resume bug fixes), startup optimization, sandbox security hardening, subagent memory leak fixes via AbortSignal, OOM prevention for large output streams.
- **Stable channel**: v0.38.2 (Apr 17) day 5 unchanged. Nightly: v0.40.0 (Apr 15) day 7+ paused.
- **Source**: https://github.com/google-gemini/gemini-cli/releases (verified via `gh api`)

### Gemini API — Free Tier Changes + Model Deprecations
- **No new API entries after Apr 21** (Deep Research). Day 1 of silence.
- **Free tier changes (Apr 1)**: Pro models (Gemini 3.1 Pro) moved to paid-only. Flash models remain free with reduced quotas. Mandatory spending caps: Tier 1 $250/mo, Tier 2 $2K/mo, Tier 3 $20K-100K+/mo. Prepaid billing required for new accounts.
- **Model deprecations**: Gemini 2.0 Flash + 2.0 Flash-Lite → June 1, 2026. Robotics ER 1.5 → April 30, 2026.
- **Deep Research Max blog** (Apr 21, Lukas Haas): Positions Deep Research Max as "step change for autonomous research agents." Technical docs confirm: MCP server integration with auth headers + tool restrictions, collaborative planning, Interactions API only, 60-min max, $1-3/task (standard) / $3-7/task (max).
- **Source**: https://ai.google.dev/gemini-api/docs/changelog, https://ai.google.dev/gemini-api/docs/deep-research

### ADK — v1.31.1 Confirmed Latest; Java 1.0 Architecture Details
- **v1.31.1** (Apr 21) confirmed latest via `gh api`. **v1.32.0 does NOT exist** (third confirmation; WebFetch consistently hallucinates this from GitHub HTML). Next release expected ~Apr 27-May 1.
- **ADK Java 1.0** (InfoQ, Apr 20): App/Plugin architecture, ComputerUseTool (Playwright), GoogleMapsTool, UrlContextTool, event compaction (sliding window + summarization for long sessions), human-in-the-loop (pause/approve/resume), native A2A support.
- v2.0.0a3 (Apr 9) still latest pre-release.
- **Source**: https://github.com/google/adk-python/releases, https://www.infoq.com/news/2026/04/google-adk-1-0-new-architecture/

### A2A Protocol — Day 41 Stable
- A2A v1.0.0 (Mar 12) day 41. No v1.1.0 (verified via `gh api`). No change.
- **Source**: https://github.com/a2aproject/A2A/releases

### Vertex AI Agent Builder — Day 63+ Frozen
- Agent Builder last release Feb 18. Day 63+ without releases. Express mode + free tier noted. All new features continue routing through Gemini API/ADK. I/O relaunch expected.
- **Source**: https://docs.cloud.google.com/agent-builder/release-notes

### Project Mariner — Steady State
- No new announcements. Cloud VM architecture, DeepMind absorption, AI Ultra integration all hold. I/O 27d.
- **Source**: https://deepmind.google/models/project-mariner/

### Project Astra — Steady State
- No new announcements. Gemini Live integration continues. Android XR glasses confirmed 2026. I/O 27d.
- **Source**: https://deepmind.google/models/project-astra/

### Gemma — Day 20 Steady State
- Gemma 4 (Apr 2) day 20. No new model variants. 400M+ downloads. Steady state.
- **Source**: https://deepmind.google/models/gemma/gemma-4/

### Google I/O 2026 — Event-Driven Queries
- May 19-20. "Agentic coding and latest Gemini model updates." No concrete product leaks. ADK integrations ecosystem expansion (Feb 27 blog). Gemini 4 unconfirmed but speculated. I/O 27d.
- **Source**: https://developers.googleblog.com/get-ready-for-google-io-2026/

## Cross-Cutting Analysis

- **Both vendors broke their freezes on the same day (Apr 22)**: Anthropic shipped CC v2.1.117 (stable), Google shipped CLI v0.39.0-preview.2 (preview only). The post-freeze silence lasted ~2 days for Anthropic, ~5 days for Google's stable channel (but only ~1 day for preview). Parallel unfreeze suggests the freeze was seasonal (Easter weekend) rather than coordinated staging.
- **Agent definition convergence signal strengthened**: CC v2.1.117's declarative `mcpServers` in agent frontmatter + ADK Java 1.0's App/Plugin architecture both move toward self-contained agent definitions that carry tool dependencies. S3 format comparison study gains new data points.
- **Event compaction convergence**: ADK Java 1.0's event compaction (sliding window + summarization) addresses the same problem as CC's context window fix in v2.1.117. Both vendors independently solving context management for long-running agent sessions.
- **Preview ≠ Stable**: Google's preview channel (v0.39.0) is shipping aggressively while stable (v0.38.2) holds. This mirrors CC's pattern of frequent patch releases followed by feature batches.
- **Deep Research MCP integration remains the strongest S3 signal**: Google consuming Anthropic's protocol in a production product. No new MCP integration docs since Apr 21.

## Implications for Our Pipeline

### S1 — Automatic Agent/Skill Improvement
1. **CC v2.1.117 context window fix (P0)** — upgrade immediately, re-run shadow eval
2. **OTEL effort attribute** — new observable signal for shadow eval
3. #49562: OPEN, zero staff responses

### S2 — Multi-Agent Orchestration
1. **ADK Java event compaction** — design pattern for Phase 5 long-running orchestration sessions. Sliding window + summarization prevents token overflow without losing critical context.
2. **Unified subagent tool in Gemini CLI** — Google consolidating multiple subagent invocation methods to one. Validates our single-tool subagent dispatch approach in Phase 5.
3. **Advisor Tool in CC v2.1.117** — executor+advisor is a novel topology for S2 paper.

### S3 — Platform Generalization
1. **Declarative `mcpServers` in CC agent frontmatter** + **ADK Java App/Plugin** — both moving toward self-contained agent definitions. Direct comparison material for S3 format study.
2. **Deep Research MCP**: no new docs, but blog confirms production-grade integration.
3. **Gemini CLI install**: still gates all S3 implementation work (longest-standing blocker).

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|---------------|-----|----------|
| Phase 3 (shadow eval) | CC v2.1.117 context window fix + OTEL effort | Re-run shadow eval post-upgrade; integrate effort signal | P1 |
| Phase 4 (closed loop) | Forked subagents external; ADK event compaction | Pipeline lacks context management for long sessions | P2 |
| Phase 5 (multi-agent) | Advisor Tool; unified subagent tool; event compaction | Phase 5 design doesn't include event compaction or advisor pattern | P2 |
| Phase 5 (agent format) | CC declarative mcpServers + ADK App/Plugin | No format comparison study started (needs Gemini CLI install) | P2 |

## Skill Proposals Generated

None. Findings are infrastructure/architecture patterns that inform Phase 5 design rather than new skill opportunities.

## Actions Taken

- Updated 7 Google/DeepMind KB files: gemini-agents.md, agent-development-kit.md, a2a-protocol.md, vertex-ai-agents.md, project-mariner.md, project-astra.md, gemma-open-models.md
- Updated 5 Anthropic KB files (morning): claude-code.md, model-releases.md, model-context-protocol.md, multi-agent-patterns.md, tool-use-and-function-calling.md
- No deprecated_models.json updates needed (Gemini 2.0 Flash/Flash-Lite June 1 deprecation already tracked)
- No proposals generated

## Next Sweep Focus

- **Monitor CC v2.1.118+** — v2.1.117 is a large release; patch releases likely within 24-48h
- **Monitor Gemini CLI v0.38.3 or v0.39.0 stable** — preview channel active, stable release may follow within days
- **Monitor ADK v1.32.0** — expected ~Apr 27-May 1
- **Monitor #49562** — will v2.1.117 context window fix reduce complaint volume?
- **Monitor Agent SDK v0.1.65** — expected soon given CC v2.1.117 shipped
- **If nothing ships by Apr 24**: Write minimal sweep per directive guidance (~300 words)
