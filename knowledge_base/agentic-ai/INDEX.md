# Agentic AI Knowledge Base -- Index

**Last sweep**: 2026-04-11 (Google/DeepMind track updated)
**Total entries**: 17

## Anthropic Track

| Topic | File | Last Updated |
|-------|------|-------------|
| Claude Code | anthropic/claude-code.md | 2026-04-11 |
| Agent SDK | anthropic/agent-sdk.md | 2026-04-11 |
| Model Context Protocol | anthropic/model-context-protocol.md | 2026-04-11 |
| Tool Use & Function Calling | anthropic/tool-use-and-function-calling.md | 2026-04-11 |
| Computer Use | anthropic/computer-use.md | 2026-04-11 |
| Multi-agent Patterns | anthropic/multi-agent-patterns.md | 2026-04-11 |
| Model Releases | anthropic/model-releases.md | 2026-04-11 |

## Google/DeepMind Track

| Topic | File | Last Updated |
|-------|------|-------------|
| Gemini Agents | google-deepmind/gemini-agents.md | 2026-04-11 |
| A2A Protocol | google-deepmind/a2a-protocol.md | 2026-04-11 |
| Agent Development Kit | google-deepmind/agent-development-kit.md | 2026-04-11 |
| Vertex AI Agents | google-deepmind/vertex-ai-agents.md | 2026-04-11 |
| Project Mariner | google-deepmind/project-mariner.md | 2026-04-11 |
| Project Astra | google-deepmind/project-astra.md | 2026-04-11 |
| Gemma / Open Models | google-deepmind/gemma-open-models.md | 2026-04-11 |

Note: 2026-04-11 Full sweep: **Advisor Tool launched** (Apr 9, public beta `advisor-tool-2026-03-01`) — MAJOR: executor model (Haiku/Sonnet/Opus) consults Opus 4.6 advisor mid-generation via server-side sub-inference. Sonnet+Opus advisor: +2.7pp SWE-bench, -11.9% cost. Haiku+Opus advisor: 41.2% BrowseComp (2x solo), 85% cheaper than Sonnet. Creates "virtual model tier." **Claude Code v2.1.98** — PID namespace subprocess sandboxing (major security), Vertex AI wizard, Perforce mode, Monitor tool, OTEL tracing. **v2.1.100** — config-only. **Agent SDK Python v0.1.57-58** — cross-user prompt caching (40-60% savings), auto permission mode, thinking config fix. **ADK Python v1.29.0 + v2.0.0-alpha.3** — 8-day freeze broken. EnvironmentToolset, BashTool hardening, auth overhaul. Alpha.3: workflow graph visualization with active node rendering, lazy scan dedup on resume. **Gemini CLI v0.37.1 stable + v0.39.0-nightly.20260410** — unified subagent invocation, Linux sandbox refactor, OAuth leak fix. **Gemma 4 MTP heads confirmed stripped** from public weights — two-tier speed gap. TRL v1.0 released. **Anthropic explores custom AI chips** — $30B ARR, 3.5 GW TPU deal. **Haiku 3 retires Apr 19** (8d). **1M beta ends Apr 30** (19d). **Google I/O May 19-20** (38d).

Note: 2026-04-10 Full sweep: **A2A one-year anniversary milestone** — 150+ orgs (3x growth from 50+), 22K GitHub stars, 5 SDKs, **triple hyperscaler integration** (Azure AI Foundry + AWS Bedrock AgentCore + Google Cloud), enterprise production in supply chain/finance/insurance/IT ops. **Claude Code v2.1.97** — Focus view (`Ctrl+O`), MCP HTTP/SSE memory leak fix (50 MB/hr), permission hardening (prototype collision, bash env/redirect validation), 429 retry fix, git worktree status line, subagent count indicator. **Claude Cowork enterprise GA** (Apr 9) — RBAC via SCIM, admin group management, all paid tiers. **Managed Agents Day 2** — $0.08/session-hour + tokens, Notion/Rakuten/Sentry/Asana. Anthropic-only infra. **Gemini CLI v0.39.0 nightlies** — `/memory inbox` skill review, plan mode skill activation confirmation, ACP `/help`, browser agent isolation. Stable v0.37.0. **ADK Python** v1.28.1 day 8 freeze (longest gap). **Vertex AI Agent Builder renamed "AI Applications"**. **EAGLE3 speculative decoding** Gemma 4 31B — 1.72x speedup, 277MB draft head. **Gemini Nano 4 Fast** 3x speed. **On-device Agent Skills** on Android. **Samsung Galaxy Glasses August 2026** $600-$900. **Anthropic $30B ARR**, expanded Google Cloud TPU deal (3.5 GW). **Haiku 3 retires Apr 19** (9d). **1M beta ends Apr 30** (20d). **Google I/O May 19-20** (39d).

Note: 2026-04-09 Full sweep: **Claude Managed Agents launched** (public beta, Apr 8) — fully managed agent harness with secure containers, built-in tools (Bash, file ops, web search/fetch, MCP), SSE streaming, stateful sessions. Multiagent research preview gated. Competes with Vertex AI Agent Builder. **`ant` CLI launched** — Claude API command-line client with YAML resource versioning. **Claude Code v2.1.94/v2.1.96** — Bedrock Mantle integration, effort default medium→high, CJK/UTF-8 fix, Bedrock auth hotfix. **Gemini CLI v0.37.0 stable + v0.38.0-preview.0** (Apr 8) — sandbox expansion, persistent browser sessions, context compression services (new), context-aware persistent policy approvals (new). **Gemini API tooling** — context circulation, tool combos, Maps grounding adopted. **Gemma 4 Unsloth** — 3 universal bugs fixed (gradient accumulation, KV cache -0==0, cache corruption); fine-tuning now reliable. 400M+ downloads. **CLI agent convergence COMPLETE** — Gemini CLI now matches Claude Code on all architectural dimensions. **Haiku 3 retires Apr 19** (10d). **1M beta ends Apr 30** (21d). **Google I/O May 19-20** (40d) — expected ADK v2.0, A2A v1.1, Android XR glasses, possibly Gemini 4.

## Cross-Cutting

| Topic | File | Last Updated |
|-------|------|-------------|
| MCP vs A2A Interop | cross-cutting/mcp-vs-a2a-interop.md | 2026-04-03 |
| Agentic Benchmarks | cross-cutting/agentic-benchmarks.md | 2026-04-03 |
| Safety & Alignment | cross-cutting/safety-and-alignment.md | 2026-04-03 |

## Analysis Reports

| Date | File | Summary |
|------|------|---------|
| 2026-04-11 | analysis/2026-04-11.md | L2-L3 deep analysis: Advisor Tool as fourth topology option (Sonnet+Opus -11.9% cost, near-Opus quality — Phase 3.5/5/7 impact), fleet version P0 (v2.1.87 → v2.1.98, 11 versions behind with PID namespace + MCP leak + permission fixes), ADK convergence (EnvironmentToolset closes execution gap, workflow graph visualization for Phase 5, BashTool metacharacter blocking reference), Gemma 4 MTP omission two-tier speed gap (AICore 1.8x vs self-hosted 1.0x — Phase 6 SLA planning), thinking config silent bug verification needed, cross-user prompt caching for Phase 5 Agent SDK, 12 priority actions |
| 2026-04-10 | analysis/2026-04-10.md | L2-L3 deep analysis: A2A triple hyperscaler integration crosses irreversibility threshold (150+ orgs, Azure+AWS+Google — Phase 5 must be A2A-native), enterprise stack crystallization (Anthropic vs Google vs Open), EAGLE3 1.72x speedup for Phase 6 edge optimization, MCP 50 MB/hr memory leak fleet impact (v2.1.97 update needed), permission hardening audit, Haiku 3 9-day countdown (guard verified), pre-I/O freeze depth analysis (deepest observed — ADK v2.0/AI Applications relaunch probable), A2A AgentCard → agent discovery cross-pollination, 13 priority actions |
| 2026-04-09 | analysis/2026-04-09.md | L2-L3 deep analysis: Claude Managed Agents architecture evaluation (3-layer: Phase 4 not viable, Phase 5 multiagent preview monitor, Phase 7 deployment target), effort level medium→high cost impact assessment, Gemini CLI context compression vs Claude compaction comparison, deprecation guard verified (Haiku 3 in 10 days), `ant` CLI exploratory tracking, context-aware persistent policy approvals → Phase 5 HITL design, 3 deployment targets for Phase 7 (SKILL.md + Managed Agents + Conway), A2A eval deferred to post-I/O, 11 priority actions |
| 2026-04-08 | analysis/2026-04-08.md | L2-L3 deep analysis: CVE-2026-35020 P0 exposure check, security-first model deployment paradigm (Glasswing + CodeMender + AWS IAM context keys), Qwen 3.6 Plus competitive disruption for Phase 6, converging deprecation deadlines migration risk, CLI agent architectural convergence COMPLETE, AWS IAM → pipeline permission model cross-pollination, CodeMender → security orchestrator agent proposal, Gemma 4 Unsloth confirmed, 10 priority actions |
| 2026-04-07 | analysis/2026-04-07.md | L2-L3 deep analysis: MCP 658x cost amplification attack (P0 new threat category), Adversa AI TOP 25 + mcp-sec-audit 100% MCPTox detection (P1), Gemini CLI passive skill extraction vs explicit memory paradigm comparison, A2A v1.0 TSC governance validates Phase 5, agent platform bifurcation (CLI-native vs cloud-native), security-cost tradeoff as new frontier, harness simplification applied to security stack, 16 priority actions |
| 2026-04-06 | analysis/2026-04-06.md | L2-L3 deep analysis: OWASP MCP security crisis quantified (30% coverage of 10 attack categories), harness engineering simplification principle, sprint contract pattern for factory→validator, `terminal_reason` for closed-loop retry, Google I/O P0 monitoring event, `mcp-scan` hash pinning for rug pulls, Phase 6 zero-shot-first strategy, 15 priority actions |
| 2026-04-05 | analysis/2026-04-05.md | L2-L3 deep analysis: MCP tool poisoning P0 threat, Conway persistent agents, 4-way payment protocol war, supply chain security (LiteLLM+axios), 5 cross-pollination opportunities (progressive disclosure, Conway extensions, Pinterest MCP, ADK graph workflows), Capybara threat upgraded to P1, 11 priority actions |
| 2026-04-04 | analysis/2026-04-04.md | L2-L3 deep analysis: 8 gap findings (MCP V2 threat P1, Gemma 4 accelerates Phase 6, deny-rule bypass P1), 5 cross-pollination opportunities, 5 threats assessed |

## Sweep Reports

| Date | File | Summary |
|------|------|---------|
| 2026-04-11 | sweeps/2026-04-11.md | Advisor Tool launched (Sonnet+Opus: +2.7pp SWE-bench, -11.9% cost; Haiku+Opus: 2x BrowseComp at 85% less cost). Claude Code v2.1.98/100 — PID namespace sandboxing, Vertex AI wizard, Perforce mode, Monitor tool. Agent SDK v0.1.57-58 — cross-user prompt caching (40-60% savings). ADK v1.29.0+v2.0.0-alpha.3 breaks 8-day freeze — EnvironmentToolset, workflow graph visualization. Gemma 4 MTP heads confirmed missing from public weights. Anthropic explores custom chips at $30B ARR. Haiku 3 in 8 days. I/O in 38 days. |
| 2026-04-10 | sweeps/2026-04-10.md | A2A one-year anniversary: 150+ orgs, triple hyperscaler integration (Azure+AWS+Google), enterprise production. Claude Code v2.1.97 — Focus view, MCP memory leak fix (50 MB/hr), permission hardening. Claude Cowork enterprise GA with RBAC. Managed Agents Day 2 — $0.08/session-hr, Notion/Rakuten/Sentry/Asana. Gemini CLI v0.39.0 nightlies — /memory inbox, skill activation confirmation. ADK day 8 freeze. EAGLE3 1.72x speedup for Gemma 4 31B. Haiku 3 in 9 days. I/O in 39 days. |
| 2026-04-09 | sweeps/2026-04-09.md | Stabilization ended on Anthropic side. Claude Managed Agents launched (public beta) — fully managed agent harness with MCP, multiagent preview. `ant` CLI launched. Claude Code v2.1.94/v2.1.96 — Bedrock Mantle, effort medium→high. Gemini CLI v0.37.0 stable + v0.38.0-preview.0 — context compression, persistent policy approvals. CLI agent convergence COMPLETE. Gemma 4 Unsloth bugs fixed; fine-tuning reliable. Haiku 3 in 10 days. I/O in 40 days. |
| 2026-04-08 | sweeps/2026-04-08.md | Day 4 dual-vendor stabilization. Mythos/Glasswing officially announced (40+ security partners). CVE-2026-35020 CVSS 8.4 HIGH. AWS MCP IAM context keys. Qwen 3.6 Plus confirmed at 78.8% SWE-bench. Google-Agent crawler rolling out. CodeMender 72 fixes. Haiku 3 retirement in 11 days. Gemma 4 Unsloth path confirmed. |
| 2026-04-07 | sweeps/2026-04-07.md | Day 3 stabilization: Adversa AI TOP 25 MCP vulns + 658x cost amplification attack. ADK "vibe building" + SkillToolset runtime expertise. A2A v1.0 TSC (8 orgs). US blacklisting saga (injunction → appeal → GSA restoration → UK courting). Gemini CLI passive skill extraction. Mariner 2026 roadmap crystallized. Gemma 4 day 5 ecosystem maturing. |
| 2026-04-06 | sweeps/2026-04-06.md | Stabilization sweep: No new releases from either vendor. OWASP MCP security crisis quantified (30+ CVEs/60d, 84.2% tool poisoning success, 34/100 avg security score). Three-agent harness going viral. Gemma 4 QLoRA tooling recovering. Google I/O 2026 May 19-20 confirmed. ADK agents in Gemini Enterprise. |
| 2026-04-05 | sweeps/2026-04-05.md | Full sweep (2 passes): Claude Code v2.1.92, OpenClaw cutoff + backlash, Pinterest MCP, Conway leaked, MCP 6,400+ servers + Fingerprint fraud MCP, Agent SDK v0.1.55-56, model codenames. Google: AP2 + Visa TAP + x402 + PayPal Agent Ready payment war ($11.79B market), Gemini CLI v0.36.0 stable (worktrees, memory mgr), Gemini 3 Deep Think science (IPhO/IChO gold), ADK LiteLLM security, Gemma 4 AICore, Android XR May 2026 unveil |
| 2026-04-04 | sweeps/2026-04-04.md | Full sweep: Computer Use→Windows, MCP Dev Summit results (SDK V2 roadmap, XAA/ID-JAG agent SSO, OpenAI Resources alignment, 10K+ servers), tool streaming GA, context editing beta, Gemma 4 τ2-bench 86.4% |
| 2026-04-03 | sweeps/2026-04-03.md | Updated sweep: Claude Code source leak (KAIROS, anti-distillation, Capybara tier), x402 agent payment protocol at MCP Dev Summit, Gemma 4 + Gemini Nano 4 on 140M devices, ADK Java 1.0, A2A signed cards, Agent SDK progress summaries |
| 2026-04-02 | sweeps/2026-04-02.md | First full sweep: 17 topics across Anthropic, Google/DeepMind, cross-cutting |

## Evaluations

| Topic | File | Last Updated |
|-------|------|-------------|
| Permission Cache Design (Phase 5 HITL) | evaluations/permission-cache-design.md | 2026-04-09 |

## Discussion Transcripts

| Date | File | Summary |
|------|------|---------|
| 2026-04-09 | discussions/2026-04-09.md | Innovator/Engineer debate (3 rounds): 7 ADOPT items (per-agent effort config P1, deprecated models verify P0, A2A deferral P1, 3-target deployment P1, permission cache design P2, effort tracking in perf JSONs P1, steward cross-project deprecation check P1), 3 DEFER (Managed Agents adapter, cross-platform format diff, estimated_tokens), 0 REJECT |
| 2026-04-05 | discussions/2026-04-05.md | Innovator/Engineer debate (3 rounds): 6 ADOPT items (MCP content validator P0, dep pinning P1, allowlist in factory P1, model migration runbook P1, closed-loop state machine P2, payment protocol tracking P2), 4 DEFER, 3 REJECT |
