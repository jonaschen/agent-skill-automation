# Agentic AI Knowledge Base -- Index

**Last sweep**: 2026-04-06
**Total entries**: 17

## Anthropic Track

| Topic | File | Last Updated |
|-------|------|-------------|
| Claude Code | anthropic/claude-code.md | 2026-04-06 |
| Agent SDK | anthropic/agent-sdk.md | 2026-04-06 |
| Model Context Protocol | anthropic/model-context-protocol.md | 2026-04-06 |
| Tool Use & Function Calling | anthropic/tool-use-and-function-calling.md | 2026-04-06 |
| Computer Use | anthropic/computer-use.md | 2026-04-06 |
| Multi-agent Patterns | anthropic/multi-agent-patterns.md | 2026-04-06 |
| Model Releases | anthropic/model-releases.md | 2026-04-06 |

## Google/DeepMind Track

| Topic | File | Last Updated |
|-------|------|-------------|
| Gemini Agents | google-deepmind/gemini-agents.md | 2026-04-06 |
| A2A Protocol | google-deepmind/a2a-protocol.md | 2026-04-06 |
| Agent Development Kit | google-deepmind/agent-development-kit.md | 2026-04-06 |
| Vertex AI Agents | google-deepmind/vertex-ai-agents.md | 2026-04-06 |
| Project Mariner | google-deepmind/project-mariner.md | 2026-04-06 |
| Project Astra | google-deepmind/project-astra.md | 2026-04-06 |
| Gemma / Open Models | google-deepmind/gemma-open-models.md | 2026-04-06 |

Note: 2026-04-06 sweep: Stabilization phase — no new releases from either vendor (Claude Code v2.1.92, Gemini CLI v0.36.0, ADK v1.28.1 all hold). OWASP MCP security crisis quantified (30+ CVEs/60d, 84.2% tool poisoning success, 34/100 avg security score). Anthropic three-agent harness going viral (Swarms framework adoption, "harness engineering" named as discipline). Gemma 4 QLoRA fine-tuning tooling recovering via community patches. Google I/O 2026 May 19-20 confirmed as P0 monitoring event. ADK agents now registrable in Gemini Enterprise. Conway still internal testing. Prior: All 14 topic files updated with comprehensive April 2-6 developments.

## Cross-Cutting

| Topic | File | Last Updated |
|-------|------|-------------|
| MCP vs A2A Interop | cross-cutting/mcp-vs-a2a-interop.md | 2026-04-03 |
| Agentic Benchmarks | cross-cutting/agentic-benchmarks.md | 2026-04-03 |
| Safety & Alignment | cross-cutting/safety-and-alignment.md | 2026-04-03 |

## Analysis Reports

| Date | File | Summary |
|------|------|---------|
| 2026-04-06 | analysis/2026-04-06.md | L2-L3 deep analysis: OWASP MCP security crisis quantified (30% coverage of 10 attack categories), harness engineering simplification principle, sprint contract pattern for factory→validator, `terminal_reason` for closed-loop retry, Google I/O P0 monitoring event, `mcp-scan` hash pinning for rug pulls, Phase 6 zero-shot-first strategy, 15 priority actions |
| 2026-04-05 | analysis/2026-04-05.md | L2-L3 deep analysis: MCP tool poisoning P0 threat, Conway persistent agents, 4-way payment protocol war, supply chain security (LiteLLM+axios), 5 cross-pollination opportunities (progressive disclosure, Conway extensions, Pinterest MCP, ADK graph workflows), Capybara threat upgraded to P1, 11 priority actions |
| 2026-04-04 | analysis/2026-04-04.md | L2-L3 deep analysis: 8 gap findings (MCP V2 threat P1, Gemma 4 accelerates Phase 6, deny-rule bypass P1), 5 cross-pollination opportunities, 5 threats assessed |

## Sweep Reports

| Date | File | Summary |
|------|------|---------|
| 2026-04-06 | sweeps/2026-04-06.md | Stabilization sweep: No new releases from either vendor. OWASP MCP security crisis quantified (30+ CVEs/60d, 84.2% tool poisoning success, 34/100 avg security score). Three-agent harness going viral. Gemma 4 QLoRA tooling recovering. Google I/O 2026 May 19-20 confirmed. ADK agents in Gemini Enterprise. |
| 2026-04-05 | sweeps/2026-04-05.md | Full sweep (2 passes): Claude Code v2.1.92, OpenClaw cutoff + backlash, Pinterest MCP, Conway leaked, MCP 6,400+ servers + Fingerprint fraud MCP, Agent SDK v0.1.55-56, model codenames. Google: AP2 + Visa TAP + x402 + PayPal Agent Ready payment war ($11.79B market), Gemini CLI v0.36.0 stable (worktrees, memory mgr), Gemini 3 Deep Think science (IPhO/IChO gold), ADK LiteLLM security, Gemma 4 AICore, Android XR May 2026 unveil |
| 2026-04-04 | sweeps/2026-04-04.md | Full sweep: Computer Use→Windows, MCP Dev Summit results (SDK V2 roadmap, XAA/ID-JAG agent SSO, OpenAI Resources alignment, 10K+ servers), tool streaming GA, context editing beta, Gemma 4 τ2-bench 86.4% |
| 2026-04-03 | sweeps/2026-04-03.md | Updated sweep: Claude Code source leak (KAIROS, anti-distillation, Capybara tier), x402 agent payment protocol at MCP Dev Summit, Gemma 4 + Gemini Nano 4 on 140M devices, ADK Java 1.0, A2A signed cards, Agent SDK progress summaries |
| 2026-04-02 | sweeps/2026-04-02.md | First full sweep: 17 topics across Anthropic, Google/DeepMind, cross-cutting |

## Discussion Transcripts

| Date | File | Summary |
|------|------|---------|
| 2026-04-05 | discussions/2026-04-05.md | Innovator/Engineer debate (3 rounds): 6 ADOPT items (MCP content validator P0, dep pinning P1, allowlist in factory P1, model migration runbook P1, closed-loop state machine P2, payment protocol tracking P2), 4 DEFER, 3 REJECT |
