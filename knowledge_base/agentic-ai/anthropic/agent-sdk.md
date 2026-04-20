# Claude Agent SDK

**Last updated**: 2026-04-21
**Sources**:
- https://platform.claude.com/docs/en/agent-sdk/overview
- https://cvefeed.io/vuln/detail/CVE-2026-35020
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
- https://claude.com/blog/building-agents-with-the-claude-agent-sdk
- https://github.com/anthropics/claude-agent-sdk-python
- https://github.com/anthropics/claude-agent-sdk-python/releases
- https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md
- https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk
- https://www.contextstudios.ai/glossary/anthropic-agent-sdk
- https://releasebot.io/updates/anthropic
- https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md (TS v0.2.89-v0.2.92)
- https://platform.claude.com/docs/en/managed-agents/overview
- https://the-decoder.com/anthropic-launches-managed-infrastructure-for-autonomous-ai-agents/

## Overview

The Claude Agent SDK (formerly Claude Code SDK, renamed late 2025) is Anthropic's general-purpose agent runtime that gives developers the same tools, agent loop, and context management that power Claude Code as a programmable library. As of April 18, 2026, Python is at v0.1.63 and TypeScript is at v0.2.114. It supports built-in tools, hooks, subagents, MCP integration, permissions, session management, plugins, and skills.

## Key Developments (reverse chronological)

### 2026-04-21 — SDK Freeze Extends Into Monday; Python v0.1.63, TypeScript v0.2.114 Still Latest
- **What**: No new Agent SDK releases. Python remains at v0.1.63 (Apr 18, bundles CLI v2.1.114), TypeScript at v0.2.114 (Apr 18, CLI v2.1.114 parity). Both SDKs last released simultaneously on Apr 18 — now 3 days without updates.
- **Significance**: SDK tracks CLI closely (SDK Py v0.1.63 bundles CLI v2.1.114). Until a new CLI version ships, no SDK update is expected. The freeze is consistent with the broader Claude Code freeze.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/releases (verified Apr 21)

### 2026-04-20 (night) — SDK Freeze Confirmed End of Day; Py v0.1.63, TS v0.2.114 Unchanged
- **What**: Night verification confirms no new SDK releases Sunday. Python v0.1.63 (Apr 18), TypeScript v0.2.114 (Apr 18) remain latest. Freeze now ~100 hours. Monday unfreeze expected.
- **Significance**: Pure confirmation. No change from evening.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/releases

### 2026-04-20 (evening) — SDK Freeze Extends 96h+ Into Monday; Key v0.1.62/v0.2.113 Features Confirmed
- **What**: Agent SDK versions unchanged: Python v0.1.63, TypeScript v0.2.114. Freeze now **96+ hours** into Monday. **Key features confirmed from April 17 releases**: (1) **Python v0.1.62**: top-level `skills` option on `ClaudeAgentOptions` — accepts `"all"`, named list, or `[]` to suppress. (2) **Python v0.1.60**: subagent transcript helpers (`list_subagents()`, `get_subagent_messages()`), distributed tracing, cascading session deletion. (3) **TypeScript v0.2.113**: native Claude Code binary spawning via platform-specific optional deps, `sessionStore` option (alpha) for mirroring transcripts to external storage, `deleteSession()` function, OpenTelemetry trace context propagation, `title` option for sessions. (4) **Python v0.1.57**: cross-user prompt caching, auto permission mode, thinking configuration fixes. No new Managed Agents announcements.
- **Significance**: The `skills` option (v0.1.62) is operationally significant — it enables SDK-based agents to selectively load Skills, which would be relevant if we migrate steward sessions from `claude -p` to Agent SDK. The `sessionStore` alpha in TS is an early signal of persistent session infrastructure. No immediate action for our pipeline.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/releases

### 2026-04-20 — No Changes: Python v0.1.63, TypeScript v0.2.114; Weekend Freeze Continues
- **What**: Agent SDK versions unchanged. Python v0.1.63, TypeScript v0.2.114. No new releases on GitHub or npm. Weekend quiet period — 72+ hours since last release. No new Managed Agents announcements.
- **Significance**: No action needed. Stable.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### 2026-04-19 (evening) — No Changes: Python v0.1.63, TypeScript v0.2.114 Hold for 48+ Hours
- **What**: Both SDKs unchanged since April 18. Python v0.1.63, TypeScript v0.2.114. No new releases on either GitHub releases page. Typical weekend quiet period.
- **Significance**: Pipeline stable. No action needed.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/releases

### 2026-04-19 — Session Storage Alpha: TS-Only, Python SDK Has No Equivalent; Community Feature Request #97 Active
- **What**: Verification sweep confirms Session Storage Alpha remains **TypeScript-only** (v0.2.113+). Python SDK v0.1.63 has no Session Storage functionality — no `sessionStore`, `InMemorySessionStore`, or `importSessionToStore` in its changelog or API surface. Community feature request **#97** ("Customizable Session Storage Backend for Cloud/Kubernetes Deployments," filed Dec 2025, 20 👍, 14 ❤️) requests cloud-native storage backends (PostgreSQL, S3, Redis) with a `SessionStorageProvider` interface. No Anthropic team response documented. Issue marked as duplicate of #167 (Session save/export) on Mar 28, 2026, but remains open. Current workaround: users manually sync `.claude/projects/{cwd}/{sessionId}.jsonl` to databases.
- **Significance**: Session Storage Alpha is **not actionable for our Python-based pipeline** until it lands in the Python SDK. The TS SDK is advancing ~4x faster than Python (v0.2.114 vs v0.1.63 — 22 vs 5 minor versions in the Apr 13-18 window). If Phase 5 requires Session Storage, TypeScript may be the forced migration target. Community demand (issue #97) validates the use case but shows no official roadmap commitment. **Closing this tracking item per directive**: feature is TS-only, not actionable until Python SDK or Phase 5 SDK decision. Will re-open if Python SDK adds `sessionStore`.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/issues/97

### 2026-04-18 (afternoon-2) — Agent SDK TypeScript v0.2.113 + v0.2.114: Session Storage Alpha, OTEL Trace Propagation, Native Binary
- **What**: The TypeScript SDK advanced from v0.2.92 to **v0.2.113** (Apr 17, 19:34 UTC) and **v0.2.114** (Apr 18, 01:33 UTC). Major v0.2.113 features: **(1) Session Storage Alpha** — new `sessionStore` option in `ClaudeAgentOptions` for mirroring session transcripts to external storage. New types: `SessionStore` (interface), `SessionKey`, `SessionStoreEntry`, `InMemorySessionStore` (reference implementation), `importSessionToStore()` (migration helper). Enables queryable externalization of agent session data. **(2) OTEL Trace Context Propagation** — distributed tracing support for TypeScript SDK sessions, connecting SDK callers to CLI child process spans. **(3) Native Binary Integration** — SDK now spawns a per-platform native Claude Code binary via optional dependency instead of bundled JavaScript (mirrors CLI v2.1.113 architecture). **(4) Session Management** — `deleteSession()` for removing sessions from disk or `SessionStore`; `title` option on `query()` to set session titles and skip auto-generation. **(5) Error Handling** — `SDKMirrorErrorMessage` (`subtype: 'mirror_error'`) for batch append failures in Session Storage. v0.2.114: maintenance release at CLI v2.1.114 parity (agent teams crash fix).
- **Significance**: **Session Storage Alpha is the most strategically significant SDK addition for S1.** It provides externalized, queryable session transcripts — a prerequisite for automated behavioral analysis. Combined with OTEL traces, this creates a dual observability channel: OTEL for structured span-level metrics (tool call duration, tokens), Session Storage for full conversation-level replay (agent reasoning, decisions). For our pipeline: (1) In Phase 5, Session Storage replaces our log-file-based steward review with a structured API. (2) `importSessionToStore()` could retrospectively analyze historical sessions. (3) The native binary spawn aligns TS SDK with CLI v2.1.113's architecture. **Note: TS SDK (v0.2.x) is advancing significantly faster than Python SDK (v0.1.x)** — 22 minor versions in ~10 days vs. 5 for Python. TypeScript may be the better Phase 5 migration target.
- **Source**: https://github.com/anthropics/claude-agent-sdk-typescript/releases

### 2026-04-18 (afternoon) — Agent SDK Python v0.1.62 + v0.1.63: Top-Level `skills` Option, CLI v2.1.113/v2.1.114 Bundles
- **What**: Two releases landed April 17-18. **(1) v0.1.62** (April 17, 19:54 UTC) — **new top-level `skills` option** in `ClaudeAgentOptions`: enables skills on the main session without manually configuring `allowed_tools` and `setting_sources`. Accepts `"all"` (every discovered skill), a named list of skills, or `[]` to suppress all skills. PR #804. Bundles CLI v2.1.113. **(2) v0.1.63** (April 18, 01:49 UTC) — maintenance release bundling CLI v2.1.114 (agent teams crash fix).
- **Significance**: The top-level `skills` option (v0.1.62) is a meaningful ergonomic improvement for SDK users building agent pipelines. For our pipeline: (1) If we migrate steward agents from `claude -p` to the SDK, the `skills: ["steward"]` option would simplify configuration vs. the current `allowed_tools` + `setting_sources` dance. (2) The `skills: []` option is useful for creating "clean" agent sessions that don't inherit any skills — relevant for our eval runner where we want to test skill triggering in isolation. (3) CLI v2.1.113 bundle means SDK users now get the native binary spawn, security hardening, and Opus 4.7 Bedrock fix. (4) CLI v2.1.114 bundle means agent teams crash fix is available through the SDK.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases

### 2026-04-18 (evening) — OTEL Tracing Architecture Clarified: CLI-Native Telemetry, Not SDK-Produced; Works with `claude -p` Subagents via Env Vars
- **What**: **Agent SDK OTEL investigation** (directive P1 item): (1) **OTEL telemetry is produced by the CLI, not the SDK**. The SDK runs the Claude Code CLI as a child process; the CLI has built-in OpenTelemetry instrumentation. The SDK passes configuration via environment variables. (2) **Works with CLI-spawned subagents**: Since `claude -p` spawns CLI child processes, and the CLI inherits parent environment, setting `CLAUDE_CODE_ENABLE_TELEMETRY=1` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` + `OTEL_TRACES_EXPORTER=otlp` on the parent process propagates to all child CLI invocations. (3) **W3C TRACEPARENT propagation**: The CLI adds a `TRACEPARENT` env var to Bash tool subprocesses when OTEL tracing is enabled, so child-process spans parent correctly to the trace tree. (4) **Three independent signals**: Metrics (token/cost counters), Log events (prompts, API requests, tool results), Traces (spans per interaction/LLM request/tool call/hook). Each has its own exporter toggle. (5) **Span hierarchy**: `claude_code.interaction` → `claude_code.llm_request` → `claude_code.tool` (with `claude_code.tool.blocked_on_user` and `claude_code.tool.execution` child spans). (6) **Session correlation**: Spans carry `session.id` attribute by default. Multiple `query()` calls against the same session appear as one timeline. (7) **Does NOT require SDK-native session management** — env var configuration alone is sufficient. Our `claude -p` invocations can emit OTEL traces by simply setting env vars in the shell/cron script. (8) **Flush behavior**: CLI batches telemetry; short-lived calls may lose spans. Recommended: set `OTEL_TRACES_EXPORT_INTERVAL=1000` for short tasks. (9) **Sensitive data control**: Content not recorded by default. Opt-in: `OTEL_LOG_USER_PROMPTS=1`, `OTEL_LOG_TOOL_DETAILS=1`, `OTEL_LOG_TOOL_CONTENT=1`.
- **Significance**: **This is the key finding for Phase 5 observability**: OTEL tracing does NOT require migrating from `claude -p` to the Agent SDK's `query()` function. We can add distributed tracing to our existing cron-based steward pipeline by simply adding env vars to the launch scripts. **Implementation complexity: days, not months.** Specific plan: (1) Deploy an OTEL collector (Jaeger or Grafana Tempo). (2) Add 6 env vars to `scripts/daily_*.sh` scripts. (3) Each steward run becomes a trace with spans for every tool call, API request, and subagent invocation. (4) The `session.id` attribute correlates multi-turn steward sessions. **This unblocks Phase 5 OTEL work immediately.** Factory-steward can implement this without waiting for any SDK migration.
- **Source**: https://code.claude.com/docs/en/agent-sdk/observability, https://code.claude.com/docs/en/monitoring-usage

### 2026-04-18 — Agent SDK Python v0.1.60 + v0.1.61: Subagent Transcript Helpers, W3C Distributed Tracing, Cascading Session Deletion; Bundles CLI v2.1.111/v2.1.112
- **What**: Two releases on April 16, 2026: **(1) v0.1.60** (15:34 UTC) — three new features: (a) **Subagent transcript helpers** (`list_subagents()` and `get_subagent_messages()` session helpers) — enables inspection of subagent message chains spawned during a session, critical for debugging multi-agent workflows. PR #825. (b) **W3C distributed tracing** — propagates `TRACEPARENT`/`TRACESTATE` to CLI subprocess, connecting SDK and CLI traces end-to-end. Install optional support: `pip install claude-agent-sdk[otel]`. PR #821. (c) **Cascading session deletion** — `delete_session()` now removes sibling subagent transcript directory, matching TypeScript SDK behavior. PR #805. **Bug fix**: `setting_sources=[]` was silently dropped; empty list now correctly passes `--setting-sources=` to disable all sources. PR #822. **Bundles CLI v2.1.111.** **(2) v0.1.61** (22:03 UTC) — internal-only: updated bundled CLI to v2.1.112 (Opus 4.7 auto mode fix).
- **Significance**: The subagent transcript helpers are the most significant addition for our pipeline. **(1) `list_subagents()` + `get_subagent_messages()`** — we could use these in our steward agents to introspect subagent work, enabling post-hoc review of what subagents did during a session without parsing logs. Directly applicable to our `project-reviewer` agent (currently suspended but could be reactivated). **(2) W3C distributed tracing (OTEL)** — for Phase 5 multi-agent topology, this gives us end-to-end trace correlation across SDK sessions and CLI subprocesses. If we deploy an OTEL collector, we get full distributed traces of our pipeline runs — factory → validator → optimizer → deployer would appear as a single trace. **(3) Cascading session deletion** is good hygiene for our pipeline's temporary sessions. **Action items**: (1) Add `claude-agent-sdk[otel]` to requirements for Phase 5 observability. (2) Evaluate `list_subagents()` for post-run steward review.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://pypi.org/project/claude-agent-sdk/

### 2026-04-17 — Anthropic Three-Agent Harness Design for Long-Running Autonomous Apps (published April 4, 2026)
- **What**: Anthropic's engineering blog "Harness Design for Long-Running Apps" (April 4, 2026) formalizes a **three-agent harness** for multi-hour autonomous development sessions — the architectural sibling to the Agent SDK for long-running app generation. The three roles: **(1) Planning Agent** — decomposes the task, formulates strategy, and defines success criteria. **(2) Generation Agent** — does the actual work (code, design, implementation). **(3) Evaluation Agent** — independently judges Generation Agent outputs against the Planning Agent's criteria; separated to avoid generation-bias in self-evaluation. **Key architectural primitives**: (a) **Structured handoff artifacts** — each agent hands its successor a defined state snapshot (plan doc, code patch, eval report) rather than a shared rolling context. Explicitly contrasted with context compaction, which "can make models overly cautious about approaching token limits." (b) **Independent evaluator using Playwright MCP** — for frontend work, the evaluator navigates live pages via Playwright MCP, scoring **design quality, originality, craft, and functionality** (4 axes). (c) **Iterative cycles of 5–15 refinements** per run, sometimes spanning **~4 hours** of autonomous operation. (d) Works alongside — not inside — the Agent SDK: the SDK remains the execution substrate; the harness is the supervising meta-architecture.
- **Significance**: This is the most detailed public disclosure of Anthropic's own long-running-app harness pattern. For our pipeline: **(1) Direct validation of our meta-agent-factory + skill-quality-validator + autoresearch-optimizer separation** — our factory (Generation), validator (Evaluation), and optimizer (Planning/replanning) already map onto the same three-role decomposition. **(2) Structured handoff artifacts** — we pass JSON reports and SKILL.md diffs between agents; the Anthropic pattern gives us vocabulary and justification for this design. **(3) The explicit "don't compact, hand off" insight** is a new architectural principle — we should prefer explicit artifact passing over shared-context approaches for Phase 5. **(4) Playwright MCP + 4-axis evaluator** is directly applicable to any UI-facing skills we produce; we can evaluate generated frontend skills the same way. **(5) 4-hour run horizon** is consistent with our Phase 4 end-to-end time KPI (≤4 hours). For Phase 5 TCI router: treat long-running tasks as implicitly three-agent — route to full Planning/Generation/Evaluation triad rather than single flagship.
- **Source**: https://www.anthropic.com/engineering/harness-design-long-running-apps, https://www.infoq.com/news/2026/04/anthropic-three-agent-harness-ai/

### 2026-04-16 — Agent SDK Python v0.1.59: CLI v2.1.105 Bundle; TypeScript V2 Interface in Unstable Preview
- **What**: Two developments since April 12: **(1) Python SDK v0.1.59** (April 13): Maintenance release bundling Claude CLI v2.1.105. No new Python APIs. The bundled CLI picks up all v2.1.105 improvements: PreCompact hook, Background Monitor manifest key, EnterWorktree path parameter, 1,536-char skill description cap, WebFetch style/script stripping, stalled-stream 5-minute abort. Still 4 versions behind Claude Code v2.1.109 — expect v0.1.60+ when v2.1.108/v2.1.109 bundle is prepared. **(2) TypeScript SDK V2 interface (unstable preview)**: Anthropic published a preview of a significantly simplified V2 API surface for the TypeScript SDK. Key changes from V1: removes async generators entirely; each turn is a separate `send()`/`stream()` cycle; three-concept API: `unstable_v2_createSession()` / `unstable_v2_resumeSession()` / `unstable_v2_prompt()`. The `SDKSession` interface: `send(message)`, `stream()` → `AsyncGenerator<SDKMessage>`, `close()`. Session lifecycle uses TypeScript 5.2+ `await using` for automatic cleanup. Session IDs are extractable from any `SDKMessage` via `msg.session_id` for cross-session resume. V2 limitations vs V1: session forking (`forkSession`) not available; some advanced streaming input patterns not yet supported. All V2 exports prefixed `unstable_v2_*` to signal preview status. Available in existing `@anthropic-ai/claude-agent-sdk` package — no separate install. TypeScript 5.2+ required for `await using`; manual `session.close()` available for older versions. No GA timeline announced.
- **Significance**: The V2 TypeScript interface is a major ergonomics improvement — eliminating async generator coordination reduces cognitive overhead for multi-turn conversations. The explicit `send()`/`stream()` separation makes it easier to inject logic between turns (like our pipeline's permission checks or eval scoring). The `unstable_v2_*` prefix policy means we can experiment in dev without committing to API stability. For our Phase 5 TypeScript-based orchestrators: V2's session-based model maps naturally to our agent loop pattern; the session resume capability is directly useful for our steward agents that need to persist state across restarts. **Do NOT use in production until V2 is stable** — prefix may change. The Python SDK equivalent is likely planned.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases (v0.1.59), https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview

### 2026-04-12 — Agent SDK: No New Releases; Python v0.1.58 / TypeScript v0.2.92+ Remain Current
- **What**: No new Agent SDK releases since v0.1.58 (April 9). Python SDK remains at v0.1.58 (bundled CLI v2.1.97). TypeScript SDK confirmed at v0.2.92+. The cross-user prompt caching feature (`exclude_dynamic_sections`) from v0.1.57 remains the most recent significant addition. Claude Code v2.1.101 was released but the Agent SDK has not yet been updated to bundle it — expect a v0.1.59 soon to pick up the v2.1.101 security fixes (command injection in `which`, memory leak, `permissions.deny` override). The `get_context_usage()` method and `typing.Annotated` per-parameter descriptions (from v0.1.56) continue as the latest API additions. Agent SDK still requires Python 3.10+. MIT licensed.
- **Significance**: The SDK is in a stable period following the April 9 flurry. The gap between Claude Code v2.1.101 and bundled CLI v2.1.97 means SDK users are 4 versions behind on security fixes. For our pipeline: no action needed until v0.1.59 ships with the v2.1.101 bundle.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://pypi.org/project/claude-agent-sdk/

### 2026-04-11 — Agent SDK Python v0.1.57-58: Cross-User Prompt Caching, Auto Permission Mode, Thinking Fix
- **What**: Two Python SDK releases on April 9: (1) **v0.1.57** — three notable changes: (a) **Cross-user prompt caching** via `exclude_dynamic_sections` option on `SystemPromptPreset` — moves per-user dynamic sections (working directory, memory, git status) out of the system prompt, enabling cross-user prompt cache hits. This is a significant cost reduction for multi-user Agent SDK deployments where the system prompt is identical except for user-specific context. (b) **Auto permission mode** — added `"auto"` to the `PermissionMode` type, bringing Python SDK to parity with TypeScript SDK and CLI v2.1.90+. The `auto` mode lets the agent choose permission level based on context. (c) **Thinking configuration fix** — `thinking={"type": "adaptive"}` was incorrectly mapping to `--max-thinking-tokens 32000` instead of `--thinking adaptive`. Similarly `disabled` now uses `--thinking disabled` instead of `--max-thinking-tokens 0`. This aligns Python SDK with TypeScript SDK behavior. Bundled CLI updated to v2.1.96. (2) **v0.1.58** — bundled CLI updated to v2.1.97 (Focus view, MCP leak fix, permission hardening).
- **Significance**: Cross-user prompt caching is the most cost-impactful SDK feature in weeks — for our daily agent fleet, if we used Agent SDK, this could save 40-60% of input tokens when multiple agents share the same system prompt base. The thinking configuration fix was a silent correctness bug — agents requesting adaptive thinking were actually getting fixed 32K budget, potentially producing different (worse) behavior than expected. For our pipeline: (1) If Phase 5 topology uses Agent SDK, cross-user caching is critical for cost control. (2) The auto permission mode aligns with our Phase 4 closed-loop permission model.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases (v0.1.57, v0.1.58)

### 2026-04-10 — Claude Cowork Enterprise GA; Managed Agents Day 2 Adoption Data
- **What**: Two major enterprise developments: (1) **Claude Cowork now GA for all paid enterprise plans** (announced April 9) — Anthropic's autonomous AI assistant Cowork is now generally available across all paid subscription tiers with a suite of enterprise controls. Key enterprise features: **role-based access controls (RBAC)** via SCIM integration with identity providers, admin group management for defining which Claude capabilities each group can access, enterprise-grade deployment controls. This creates Anthropic's complete enterprise agent stack: Claude Code (developer CLI) + Cowork (consumer/enterprise desktop) + Managed Agents (cloud API) + Agent SDK (custom). Early adopters for Cowork enterprise include Notion, Rakuten, Asana, Vibecode, and Sentry. (2) See below for Managed Agents Day 2 details.
- **Significance**: Cowork GA + Managed Agents creates a two-prong enterprise strategy: Cowork for human-interactive agent workflows with enterprise controls, Managed Agents for programmatic cloud-hosted agent deployments. The SCIM/RBAC integration is critical for enterprise adoption — it lets security teams control agent capabilities at the user/group level. For our pipeline: Cowork's enterprise controls could inform our own permission model in Phase 5.
- **Source**: https://9to5mac.com/2026/04/09/anthropic-scales-up-with-enterprise-features-for-claude-cowork-and-managed-agents/, https://blockchain.news/news/anthropic-claude-cowork-enterprise-rollout-april-2026

### 2026-04-10 — Managed Agents Day 2: Early Adoption Data; Pricing Confirmed at $0.08/session-hour
- **What**: Claude Managed Agents public beta continues to roll out. Key details confirmed since launch: (1) **Pricing**: Standard token rates plus **$0.08 per session hour** — relatively accessible for enterprise agent deployment. (2) **Early customers**: Notion (workspace task delegation), Rakuten (multi-department Slack/Teams agents, deployed within one week), Sentry (debugging with automated patch generation and PRs). (3) **Infrastructure**: Runs exclusively on Anthropic infrastructure — no AWS Bedrock or Google Vertex AI availability announced. (4) **Managed Agents multiagent** (research preview): enables agents to spawn additional agents, coordinate parallel tasks, evaluate outputs, and manage memory. Access via waitlist only. (5) **Branding enforcement**: Partners may use "Claude Agent" but explicitly prohibited from using "Claude Code", "Claude Cowork", or Claude Code ASCII art branding. (6) Claude Code v2.1.97 improvements (MCP memory leak fix, permission hardening) benefit Agent SDK users running local agents. No new Agent SDK version releases (Python stays at v0.1.54+, TypeScript at v0.2.90+).
- **Significance**: The $0.08/session-hour pricing makes Managed Agents cost-competitive with self-hosted agent infrastructure for medium-duration tasks. Rakuten's one-week deployment validates the "10x faster" claim. The Anthropic-only infrastructure is a limitation for multi-cloud enterprises. For our pipeline: the pricing model means our nightly steward agents (typically 30-60 min each) would cost $0.04-$0.08/run in session fees plus tokens — comparable to current API costs. But the exclusive infrastructure and no Bedrock support means it's not viable for our setup yet.
- **Source**: https://the-decoder.com/anthropic-launches-managed-infrastructure-for-autonomous-ai-agents/, https://platform.claude.com/docs/en/managed-agents/overview

### 2026-04-09 — Claude Managed Agents Launched (Public Beta); `ant` CLI Released
- **What**: Two major Anthropic platform launches on April 8, 2026: (1) **Claude Managed Agents** — a fully managed agent harness for running Claude as an autonomous agent with secure sandboxing, built-in tools, and SSE streaming. Core concepts: **Agent** (model + system prompt + tools + MCP servers + skills), **Environment** (configured container template with packages and network access), **Session** (running agent instance), **Events** (SSE messages between app and agent). Built-in tools: Bash, file operations (read/write/edit/glob/grep), web search/fetch, MCP servers. Key capabilities: long-running tasks (minutes to hours), cloud containers with pre-installed packages (Python/Node.js/Go), stateful sessions with persistent file systems, mid-execution steering/interruption. Rate limits: 60 creates/min, 600 reads/min per org. Beta header: `managed-agents-2026-04-01` (set automatically by SDK). Enabled by default for all API accounts. Research preview features (requiring separate access): outcomes, multiagent, memory. Branding: partners may use "Claude Agent" but NOT "Claude Code" or "Claude Cowork" branding. (2) **`ant` CLI** — a command-line client for the Claude API with native Claude Code integration and YAML versioning of API resources. (3) **Messages API on Amazon Bedrock** (April 7) — research preview at `/anthropic/v1/messages` endpoint, same request shape as first-party API, zero operator access, us-east-1 only, invitation required.
- **Significance**: Claude Managed Agents is Anthropic's answer to hosted agent runtimes — it competes directly with Google's Vertex AI Agent Builder and Microsoft's Azure AI Agent Service. This is a major shift: instead of developers building their own agent loops with the Agent SDK, Anthropic now offers a fully managed alternative. The distinction is clear: Agent SDK = custom control, Managed Agents = managed infrastructure. For our pipeline: Managed Agents could eventually host our steward agents without needing local cron jobs, but the 60 creates/min rate limit and container startup time need evaluation. The multiagent research preview is particularly relevant to our Phase 5 topology work. The Bedrock Messages API unification eliminates the Bedrock-specific API translation layer that has been a source of friction.
- **Source**: https://platform.claude.com/docs/en/managed-agents/overview, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-08 — CVE-2026-35020: OS Command Injection via TERMINAL Environment Variable (CVSS 8.4 HIGH)
- **What**: A high-severity OS command injection vulnerability (CVE-2026-35020) was published April 6, 2026 (last modified April 7) affecting both Claude Code CLI and Claude Agent SDK. The vulnerability allows local attackers to execute arbitrary commands by manipulating the `TERMINAL` environment variable, which is improperly parsed during command construction with `shell=true`. Attack vector: local. CWE-78 (Improper Neutralization of Special Elements used in an OS Command). The vulnerability can be triggered both during normal CLI execution and via deep-link handler paths, resulting in command execution with user-level privileges. Affected versions: not specifically documented in the advisory — both Claude Code CLI and Agent SDK should be updated to latest versions. Remediation: (1) Update Claude Code CLI, (2) Update Agent SDK, (3) Sanitize `TERMINAL` variable, (4) Avoid `shell=true` in command construction.
- **Significance**: CVSS 8.4/8.6 is HIGH severity. While the attack vector is local (requires access to set environment variables), this is a serious concern for CI/CD environments, shared servers, and container deployments where environment variables may be influenced by upstream systems. For our pipeline: our daily agent scripts run in controlled environments, but we should verify that our cron scripts don't pass unsanitized TERMINAL values. Any production deployments using Agent SDK should be updated immediately.
- **Source**: https://cvefeed.io/vuln/detail/CVE-2026-35020

### 2026-04-07 — Stabilization: Python v0.1.56, TypeScript v0.2.92 Remain Current
- **What**: No new Agent SDK releases since Python v0.1.56 (April 4) and TypeScript v0.2.92 (April 4). Both SDKs are aligned with Claude Code v2.1.92. Key capabilities confirmed stable: (1) `get_context_usage()` for proactive context management, (2) `terminal_reason` for closed-loop retry logic, (3) `agentProgressSummaries` for orchestrator visibility, (4) MCP large result fix (500K chars), (5) `supportedAgents()` query method in TypeScript. Custom tools as in-process MCP servers (Python SDK) continues to be the recommended pattern for tool integration — eliminates need for separate server processes. The `pathToClaudeCodeExecutable` fix (bare command name support) in TypeScript SDK resolves a common deployment issue where the CLI is on PATH but not at an absolute path.
- **Significance**: Stabilization period following rapid feature additions (v0.1.54→v0.1.56 in 3 days, v0.2.89→v0.2.92 in ~1 week). The in-process MCP server pattern for custom tools is a significant architectural choice — it means Agent SDK agents don't need external MCP server infrastructure for custom tools, reducing deployment complexity.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### 2026-04-06 — TypeScript SDK v0.2.91–v0.2.92: Terminal Reason, Strict Sandbox Default, CLI Parity

- **What**: Two significant TypeScript SDK releases: (1) **v0.2.91** added optional `terminal_reason` field to result messages exposing why the query loop terminated (`completed`, `aborted_tools`, `max_turns`, `blocking_limit`, etc.). Added `'auto'` to public `PermissionMode` type. **Breaking behavior change**: `sandbox` option now defaults `failIfUnavailable: true` when `enabled: true` — `query()` will emit error and exit if sandbox dependencies are missing instead of silently degrading. Set `failIfUnavailable: false` for graceful degradation. Updated to CLI v2.1.91 parity. (2) **v0.2.92** updated to CLI v2.1.92 parity.
- **Significance**: The `terminal_reason` field is valuable for agent orchestrators that need to understand WHY an agent stopped — essential for our pipeline's closed-loop retry logic (Phase 4). The strict sandbox default is a security hardening that aligns with production deployment best practices but may break agents that assumed silent degradation. Our `agentic-cicd-gate` should test for this.
- **Source**: https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### 2026-04-05 — Python SDK v0.1.55–v0.1.56: MCP Large Result Fix, Context Usage, Progress Summaries

#### v0.1.55 (April 3)
- **What**: Fixed silent truncation of large MCP tool results (>50K chars). The fix forwards `maxResultSizeChars` from `ToolAnnotations` via `_meta` to bypass Zod annotation stripping in the CLI. This pairs with Claude Code v2.1.91's `_meta["anthropic/maxResultSizeChars"]` override (up to 500K chars). Bundled CLI updated to v2.1.91.
- **Significance**: Large MCP tool results (database schemas, log dumps, code analysis reports) were being silently truncated, causing data loss in agent workflows. This fix is critical for MCP-heavy agents that depend on complete tool outputs.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases

#### v0.1.56 (April 4)
Previously documented below as combined entry — now split for clarity.

### 2026-04-05 — Python SDK v0.1.56, TypeScript SDK Updates: Context Usage, Progress Summaries, Custom Sessions
- **What**: Python SDK updated to v0.1.56 (April 4) with: (1) `get_context_usage()` method on `ClaudeSDKClient` — allows querying context window usage by category (system prompt, tools, conversation, etc.), enabling agents to make informed decisions about context management. (2) Support for `typing.Annotated` for per-parameter descriptions in JSON Schema — improves tool input documentation without custom schema overrides. (3) Exposed `tool_use_id` and `agent_id` in `ToolPermissionContext` — allows distinguishing between parallel permission requests from different subagents. (4) `session_id` option added to `ClaudeAgentOptions` for specifying custom session IDs. (5) Fixed `connect(prompt="...")` silently dropping string prompts. (6) Fixed type:'sdk' MCP servers passed via `--mcp-config` being dropped during startup. TypeScript SDK added: (1) `agentProgressSummaries` option to enable periodic AI-generated progress summaries for running subagents, emitted via `task_progress` events with a new `summary` field. (2) `getSettings()` applied section with runtime-resolved model and effort values.
- **Significance**: `get_context_usage()` is critical for long-running agents that need to proactively manage context before hitting limits — enables graceful compaction triggers. `agentProgressSummaries` in TypeScript enables orchestrators to surface real-time status without polling subagent internals. The `tool_use_id`/`agent_id` exposure in permission context enables fine-grained permission policies in multi-agent setups.
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://releasebot.io/updates/anthropic

### 2026-04-04 — SDK Architecture Deep Dive: Feedback Loop Design Pattern
- **What**: Anthropic's engineering blog details the core Agent SDK architecture as a feedback loop: (1) Gather context (fetch/update info via agentic search — bash grep/tail on file systems preferred over semantic search), (2) Take action (execute via tools, bash, code generation, or MCP), (3) Verify work (rules-based validation, visual feedback via screenshots, or LLM-as-judge). Tools represent frequent primary actions; bash/scripts handle general-purpose computer access; code generation handles complex reusable operations (Excel/PowerPoint creation). Compaction auto-summarizes when approaching context limits.
- **Significance**: Establishes official best practices: start with agentic search before semantic alternatives; design tools for context efficiency; test against representative datasets; analyze failure cases to identify missing tools/context.
- **Source**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk

### 2026-04-04 — SDK Branding Guidelines Published
- **What**: Anthropic published official branding rules for Agent SDK integrations. Allowed: "Claude Agent" (preferred for dropdowns), "Claude" (within agent-labeled menus), "{YourAgentName} Powered by Claude". Not permitted: "Claude Code", "Claude Code Agent", Claude Code-branded ASCII art. Products must maintain their own branding. License governed by Anthropic's Commercial Terms of Service.
- **Significance**: Clear boundary between Claude Code (Anthropic's product) and third-party agents built on the SDK. Partners cannot present their agents as Claude Code.
- **Source**: https://platform.claude.com/docs/en/agent-sdk/overview

### 2026-04-03 — TypeScript SDK: Progress Summaries and Runtime Settings
- **What**: TypeScript SDK v0.2.90 added two notable features: (1) `agentProgressSummaries` option enables periodic AI-generated progress summaries for running subagents — useful for long-running tasks where the parent agent or user needs status updates without interrupting the subagent. (2) `getSettings()` method returns runtime-resolved model and effort values, enabling agents to introspect their own configuration.
- **Significance**: Progress summaries address a key UX gap in multi-agent systems — knowing what a subagent is doing during long operations. `getSettings()` enables self-aware agents that can adjust behavior based on their resolved configuration.
- **Source**: https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

### 2026-04-03 — 1M Context Window Beta Retiring for Older Sonnet Models (April 30)
- **What**: The 1M token context window beta for Claude Sonnet 4.5 and Claude Sonnet 4 is being retired on April 30, 2026. Users must migrate to Claude Sonnet 4.6 or Claude Opus 4.6 for 1M context at standard pricing.
- **Significance**: Affects any SDK-based agents configured to use older Sonnet models with extended context. Migration to 4.6 models is required before April 30.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 — CLI v2.1.89: "Defer" Permission Hook and PermissionDenied Hook
- **What**: The bundled CLI introduced a "defer" permission option in PreToolUse hooks, allowing hooks to pass permission decisions to the next handler rather than accepting or rejecting. Also added a `PermissionDenied` hook that fires when auto mode denies a tool use. Fixed StructuredOutput schema cache failures (~50% failure rate for multi-schema sessions).
- **Significance**: The "defer" permission pattern enables layered permission policies. The `PermissionDenied` hook enables audit logging of denied operations. The schema cache fix resolves a severe reliability issue.
- **Source**: https://releasebot.io/updates/anthropic

### 2026-04-02 — Deep dive: SDK release cadence and new primitives (Python v0.1.54, TS v0.2.90)
- **What**: Rapid release cadence continues. Since the last KB entry (v0.1.48 Python / v0.2.71 TS), both SDKs have shipped dozens of releases adding major new capabilities. Key new primitives and APIs are documented below.
- **Significance**: The SDK has matured from a basic query wrapper to a full agent runtime with session management, subagent introspection, token budgeting, plugin reload, and context usage analytics. Production readiness is confirmed by the pace of bugfixes targeting edge cases (deadlocks, race conditions, cancellation scopes).
- **Source**: https://github.com/anthropics/claude-agent-sdk-python/releases, https://github.com/anthropics/claude-agent-sdk-typescript/blob/main/CHANGELOG.md

#### New classes, methods, and options (Python SDK, v0.1.49 -- v0.1.54)

| Version | Feature | Details |
|---------|---------|---------|
| v0.1.54 | (latest) | Bugfix release, bundled CLI v2.1.88 |
| v0.1.53 | `--setting-sources` fix, deadlock fix | Fixed deadlock in `query()` with string prompt + hooks/MCP triggering many tool calls; spawns `wait_for_result_and_end_input()` as background task |
| v0.1.52 | `get_context_usage()` | Query context window usage by category |
| v0.1.52 | `typing.Annotated` support | Per-parameter descriptions in JSON Schema for tool definitions |
| v0.1.52 | `ToolPermissionContext` | Exposed `tool_use_id` and `agent_id` fields |
| v0.1.52 | `session_id` option | Added to `ClaudeAgentOptions` for explicit session targeting |
| v0.1.52 | `control_cancel_request` | Proper hook callback cancellation handling |
| v0.1.51 | `fork_session()` | Fork an existing session to explore alternative paths |
| v0.1.51 | `delete_session()` | Clean up session data |
| v0.1.51 | `task_budget` | Token budget management option |
| v0.1.51 | `SystemPromptFile` | Support for `--system-prompt-file` CLI flag |
| v0.1.51 | `AgentDefinition` expanded | Added `disallowedTools`, `maxTurns`, `initialPrompt` fields |
| v0.1.50 | `get_session_info()` | Retrieve session metadata (tag, created_at) |
| v0.1.49 | `AgentDefinition` expanded | Added `skills`, `memory`, `mcpServers` fields |
| v0.1.49 | `tag_session()` | Tag sessions with Unicode sanitization |
| v0.1.49 | `rename_session()` | Rename existing sessions |
| v0.1.49 | `RateLimitEvent` | Typed message class for rate limit events |
| v0.1.49 | Per-turn `usage` | Usage stats preserved on `AssistantMessage` |

#### New classes, methods, and options (TypeScript SDK, v0.2.80 -- v0.2.90)

| Version | Feature | Details |
|---------|---------|---------|
| v0.2.90 | Parity with CLI v2.1.90 | Latest release |
| v0.2.89 | `startup()` | Pre-warm CLI subprocess before `query()` -- first query ~20x faster |
| v0.2.89 | `listSubagents()` | Retrieve subagent list from session history |
| v0.2.89 | `getSubagentMessages()` | Read subagent conversation history |
| v0.2.89 | `includeSystemMessages` option | Include system messages in `getSessionMessages()` |
| v0.2.89 | `includeHookEvents` option | Enable hook lifecycle messages (`hook_started`, `hook_progress`, `hook_response`) |
| v0.2.86 | `getContextUsage()` | Context window usage breakdown by category |
| v0.2.85 | `reloadPlugins()` | Reload plugins, receive refreshed commands/agents/MCP status |
| v0.2.84 | `taskBudget` | API-side token budget awareness |
| v0.2.84 | `enableChannel()` + `capabilities` | MCP server channel control and capability discovery |
| v0.2.84 | `EffortLevel` type | Exported type: `'low' | 'medium' | 'high' | 'max'` |
| v0.2.83 | `seed_read_state` | Seed `readFileState` with `{path, mtime}` for context priming |

#### Notable bugfixes (selection)
- Fixed MCP servers getting permanently stuck in failed state after connection race (TS v0.2.89)
- Fixed Zod v4 `.describe()` metadata being dropped from `createSdkMcpServer` tool schemas (TS v0.2.89)
- Fixed `getSessionMessages()` dropping parallel tool results (TS v0.2.80)
- Fixed deadlock with string prompt + many tool calls (Python v0.1.53)
- Fixed cross-task cancel scope `RuntimeError` on async generator cleanup (Python v0.1.51)
- Added `SIGKILL` fallback when `SIGTERM` handler blocks (Python v0.1.51)
- Fixed `include_partial_messages=True` not delivering `input_json_delta` events (Python v0.1.48)

#### Session management (v0.1.46+)
- `list_sessions()` -- enumerate all sessions
- `get_session_messages()` -- retrieve conversation history with pagination
- `add_mcp_server()` / `remove_mcp_server()` -- dynamic MCP server management
- Typed task messages: `TaskStarted`, `TaskProgress`, `TaskNotification`
- `ResultMessage.stop_reason` field
- Hook input enhancements: `agent_id` and `agent_type` in tool-lifecycle hooks

### 2026-04-02 — Agent Skills GA, SDK v0.2.89 (TypeScript)
- **What**: Agent Skills launched -- modular capability packages (instructions + metadata + resources) that Claude loads dynamically. Anthropic-managed Skills ship for Office docs (pptx, xlsx, docx) and PDF; custom Skills uploadable via Skills API. TypeScript SDK now at v0.2.89 with continuous releases. Claude Opus 4.6 launched as flagship agentic model. Web search and web fetch tools are now GA with dynamic domain filtering.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview, https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk

### 2026-03-01 -- SDK reaches v0.1.48 (Python) / v0.2.71 (TypeScript)
- **What**: Active development continues with regular releases. Python and TypeScript SDKs are feature-parallel.
- **Significance**: Production-ready maturity indicated by version cadence and enterprise adoption.
- **Source**: https://www.contextstudios.ai/glossary/anthropic-agent-sdk

### 2025-09-01 -- Rename from Claude Code SDK to Claude Agent SDK
- **What**: SDK renamed to reflect broader purpose beyond coding. Migration guide published.
- **Significance**: Signals Anthropic's positioning of the SDK as a general-purpose agent framework, not just a coding tool.
- **Source**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk

### 2025-03-01 -- Initial Claude Code SDK release
- **What**: Released with Tool Use, Orchestration Loops, Guardrails, and Tracing capabilities.
- **Significance**: First official SDK for building Claude-powered agents programmatically.
- **Source**: https://www.contextstudios.ai/glossary/anthropic-agent-sdk

## Technical Details

### Core API Surface

The primary entry point is the `query()` function (async generator):

```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

### Built-in Tools
| Tool | Purpose |
|------|---------|
| Read | Read any file in working directory |
| Write | Create new files |
| Edit | Make precise edits to existing files |
| Bash | Run terminal commands, scripts, git operations |
| Glob | Find files by pattern |
| Grep | Search file contents with regex |
| WebSearch | Search the web |
| WebFetch | Fetch and parse web pages |
| AskUserQuestion | Ask user clarifying questions |
| Agent | Spawn subagents |

### Subagent Architecture
Subagents enable parallelization and context isolation:

```python
options=ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Expert code reviewer",
            prompt="Analyze code quality and suggest improvements.",
            tools=["Read", "Glob", "Grep"],
            # New in v0.1.51:
            disallowed_tools=["Bash"],
            max_turns=20,
            initial_prompt="Start by reading the project structure.",
            # New in v0.1.49:
            skills=[],
            memory="Review all code for security vulnerabilities.",
            mcp_servers={},
        )
    },
)
```

Key properties:
- Each subagent gets its own isolated context window
- Only relevant results sent back to orchestrator
- Messages include `parent_tool_use_id` for tracking
- Prevents context bloat when processing large volumes
- Subagent introspection: `listSubagents()` and `getSubagentMessages()` (TS v0.2.89)

### Hooks System
SDK hooks use callback functions (not shell commands like CLI hooks):
- **PreToolUse**: Validate, block, or transform tool calls
- **PostToolUse**: Audit logging, side effects
- **Stop, SessionStart, SessionEnd**: Lifecycle events
- **UserPromptSubmit**: Pre-process user input
- Hook inputs now include `agent_id` and `agent_type` (v0.1.46+)
- Hook lifecycle messages available via `includeHookEvents` option (TS v0.2.89)

### Authentication
- Direct API key: `ANTHROPIC_API_KEY`
- Amazon Bedrock: `CLAUDE_CODE_USE_BEDROCK=1`
- Google Vertex AI: `CLAUDE_CODE_USE_VERTEX=1`
- Microsoft Azure: `CLAUDE_CODE_USE_FOUNDRY=1`

### MCP Integration
```python
options=ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    }
)
```

Dynamic MCP management (v0.1.46+):
- `add_mcp_server()` -- add MCP server at runtime
- `remove_mcp_server()` -- remove MCP server at runtime
- `McpServerStatus` typed response with `capabilities` field (TS v0.2.84)
- `enableChannel()` for MCP server channel control (TS v0.2.84)

### Session Management
Sessions maintain context across multiple exchanges with resume capability:
- Capture `session_id` from init message
- Resume with `options=ClaudeAgentOptions(resume=session_id)`
- `fork_session()` -- fork to explore different approaches (v0.1.51)
- `delete_session()` -- clean up session data (v0.1.51)
- `list_sessions()` -- enumerate all sessions (v0.1.46)
- `get_session_messages()` -- retrieve history with pagination (v0.1.46)
- `get_session_info()` -- metadata including tag and created_at (v0.1.50)
- `tag_session()` -- tag sessions with Unicode sanitization (v0.1.49)
- `rename_session()` -- rename sessions (v0.1.49)

### Token Budget Management
- `task_budget` option in `ClaudeAgentOptions` (Python v0.1.51, TS v0.2.84)
- `get_context_usage()` / `getContextUsage()` -- breakdown of context window usage by category (Python v0.1.52, TS v0.2.86)
- `EffortLevel` type: `'low' | 'medium' | 'high' | 'max'` (TS v0.2.84)

### Performance Optimization
- `startup()` -- pre-warm CLI subprocess before first `query()`, making first query ~20x faster (TS v0.2.89)
- `seed_read_state` -- seed file read state with `{path, mtime}` for context priming (TS v0.2.83)

### Plugin System
- `reloadPlugins()` -- hot-reload plugins and receive refreshed commands, agents, MCP server status (TS v0.2.85)

### Claude Code Feature Integration
When `setting_sources=["project"]` is set, SDK agents can use:
- Skills (`.claude/skills/*/SKILL.md`)
- Slash commands (`.claude/commands/*.md`)
- Memory (`CLAUDE.md`)
- Plugins (programmatic via `plugins` option)

### Design Principles (from Anthropic engineering blog)
1. **Gather context** - Search files, semantic retrieval, deploy subagents
2. **Take action** - Execute via tools, bash, code generation, MCPs
3. **Verify work** - Rules-based checks, visual feedback, LLM judgments
4. Start with agentic search (grep, tail) before semantic search
5. Use the file system as structured context engineering
6. Prioritize rules-based feedback for precise evaluation

### Branding Rules
- Allowed: "Claude Agent", "{YourName} Powered by Claude"
- Not allowed: "Claude Code" or Claude Code-branded elements

## Comparison Notes

Google's equivalent is the Agent Development Kit (ADK). Key differences:
- Claude Agent SDK builds on Claude Code's tool ecosystem; Google ADK is a standalone framework
- Claude Agent SDK has built-in tool execution; Google ADK requires more manual tool implementation
- Claude Agent SDK is tightly coupled to Claude models; Google ADK supports multiple model backends
- Both support multi-agent orchestration with subagent patterns
- Claude Agent SDK offers session management with resume/fork; ADK has its own session primitives
- Claude Agent SDK now has dynamic MCP server management (add/remove at runtime); ADK uses static tool configuration
- Claude Agent SDK introduced token budgeting and context usage analytics; ADK does not yet have equivalents
