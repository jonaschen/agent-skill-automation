# Claude Code

**Last updated**: 2026-04-21
**Sources**:
- https://code.claude.com/docs/en/changelog
- https://github.com/anthropics/claude-code/releases
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/hooks-guide
- https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md
- https://claude.com/product/claude-code
- https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/
- https://www.nagarro.com/en/blog/claude-code-feb-2026-update-analysis
- https://claudefa.st/blog/guide/changelog
- https://releasebot.io/updates/anthropic/claude-code
- https://www.theregister.com/2026/04/01/claude_code_rule_cap_raises/
- https://venturebeat.com/technology/claude-codes-source-code-appears-to-have-leaked-heres-what-we-know
- https://fortune.com/2026/03/31/anthropic-source-code-claude-code-data-leak-second-security-lapse-days-after-accidentally-revealing-mythos/
- https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/
- https://releasebot.io/updates/anthropic/claude-code (v2.1.92)
- https://releasebot.io/updates/anthropic/claude-code (v2.1.94, v2.1.96)
- https://code.claude.com/docs/en/changelog (April 1-8 entries)
- https://github.com/anthropics/claude-code/releases (v2.1.97)

## Overview

Claude Code is Anthropic's agentic CLI tool that reads codebases, executes commands, and modifies files through a layered system of permissions, hooks, MCP integrations, and subagents. As of February 2026, 4% of public GitHub commits (~135,000 per day) are authored by Claude Code -- a 42,896x growth in 13 months since the research preview -- and 90% of Anthropic's own code is AI-written. The current version is v2.1.116 (April 20, 2026), with the v2.1.x series seeing 30+ releases in March-April 2026 alone.

## Key Developments (reverse chronological)

### 2026-04-22 — v2.1.116 Still Latest (Day 2); Post-Freeze Burst Did Not Materialize
- **What**: CC v2.1.116 remains latest (npm confirmed). No v2.1.117+. The directive predicted "Anthropic tends to ship daily after a freeze break" but 2 days of silence since Apr 20 release. Post-freeze burst has not materialized.
- **Significance**: Unexpected quiet period. May indicate bundled release staging or focus on Opus 4.7 adaptive reasoning patch. Monitor continues.
- **Source**: https://www.npmjs.com/package/@anthropic-ai/claude-code (verified Apr 22)

### 2026-04-21 (evening) — v2.1.116 Confirmed Latest; No v2.1.117; Release Cadence Normalizing
- **What**: Evening verification confirms v2.1.116 (Apr 20) remains latest on GitHub releases. No v2.1.117. Freeze broke after ~130h with two releases (v2.1.115 bridge + v2.1.116 major). Release cadence expected to resume normal pace.
- **Significance**: Confirmation only. No new action items.
- **Source**: https://github.com/anthropics/claude-code/releases (verified evening Apr 21)

### 2026-04-21 (afternoon) — FREEZE BROKEN: v2.1.115 (Apr 19) + v2.1.116 (Apr 20) Shipped; Major Release With Performance + Security Fixes
- **What**: The ~130h freeze broke late Sunday/Monday. **v2.1.115** shipped April 19 (bridge release). **v2.1.116** shipped April 20 with significant changes:
  - **Performance**: `/resume` up to 67% faster on 40MB+ sessions; faster MCP startup (deferred `resources/templates/list` to first `@`-mention); smoother fullscreen scrolling with terminal scroll sensitivity config
  - **UX**: Thinking spinner progress indicators ("still thinking", "thinking more", "almost done thinking"); `/config` search now matches option values; `/doctor` accessible during active responses; plugin dependency auto-install on `/reload-plugins`; Bash tool surfaces hints on `gh` rate-limit
  - **Security**: Sandbox auto-allow no longer bypasses dangerous-path safety for `rm`/`rmdir` targeting `/`, `$HOME`, or critical system directories
  - **Fixes**: Devanagari/Indic script column alignment; Ctrl+- undo in Kitty terminals; Cmd+Left/Right navigation; Ctrl+Z hang via wrapper processes (npx, bun run); modal dialogs overflowing at short terminal heights; `/branch` rejecting >50MB conversations; intermittent 400 error from cache control TTL ordering during parallel requests
- **Significance**: The freeze break confirms Anthropic was staging a batched release, not experiencing a development pause. The 67% `/resume` speedup is operationally significant for our pipeline's large sessions. The security fix (rm/rmdir safety) is important for any agentic workflow. **No Opus 4.7 adaptive reasoning patch** in either release — #49562 remains unaddressed.
- **Source**: https://github.com/anthropics/claude-code/releases (v2.1.116, Apr 20), https://code.claude.com/docs/en/changelog

### 2026-04-21 — v2.1.114 Freeze Extends Into Monday (~120h); No v2.1.115; Unprecedented Weekday Freeze
- **What**: Claude Code v2.1.114 remains the latest release. No v2.1.115 or higher has shipped. The freeze now extends ~120+ hours (since Apr 17), making this the longest v2.1.x release gap observed. Monday is typically a high-release day — the continued freeze into a weekday is unprecedented in the v2.1.x era.
- **Significance**: The 96h+ freeze predicted on Sunday has now extended further. This is unusual for a Monday. May indicate a larger release being staged, or internal focus on Opus 4.7 stabilization.
- **Source**: https://github.com/anthropics/claude-code/releases (verified Apr 21 — v2.1.114 still latest)

### 2026-04-20 (night) — v2.1.114 Freeze Confirmed End of Day; No v2.1.115; Monday Unfreeze Expected
- **What**: Night verification confirms v2.1.114 remains latest on GitHub releases and npm. No v2.1.115 published Sunday. Freeze now **~100 hours** (since Apr 18 01:34 UTC). This is the longest gap in the entire v2.1.x series. Monday is the most likely unfreeze day — 96h+ weekend freeze is unusual but not unprecedented (Easter 2026 had a similar pattern).
- **Significance**: Pure confirmation. Monday morning sweep should prioritize checking for v2.1.115+. No operational impact from the freeze.
- **Source**: https://github.com/anthropics/claude-code/releases, https://www.npmjs.com/package/@anthropic-ai/claude-code

### 2026-04-20 (evening) — v2.1.114 Holds 96+ Hours Into Monday; Weekend Freeze Extends to Weekday; No New Releases
- **What**: CC v2.1.114 freeze now extends **96+ hours** (April 18 → April 20 evening), unusual for stretching into a Monday. No new GitHub release or changelog entry. The v2.1.113 release (April 17) was the last significant update, introducing native binary spawning, `sandbox.network.deniedDomains`, and `/ultrareview`. v2.1.114 (April 18) was a crash fix only. **Routines** confirmed as a new automation feature: bundles prompt + repo + connectors with scheduled/API/GitHub triggers (Pro 5/day, Max 15/day, min 1h interval, `claude/` branch prefix only). **Desktop app redesign** (April 15): new sidebar for parallel sessions, integrated terminal, in-app file editor, rebuilt diff viewer, drag-and-drop layout.
- **Significance**: The 96h+ freeze is the longest in the v2.1.x series. Monday typically breaks weekend freezes — if v2.1.115 doesn't ship by Tuesday, this may signal a longer development cycle (possibly for I/O-adjacent features). No action needed for pipeline.
- **Source**: https://github.com/anthropics/claude-code/releases, https://www.macrumors.com/2026/04/15/anthropic-rebuilds-claude-code-desktop-app/

### 2026-04-20 — v2.1.114 Holds (72+ Hours); Claude Design Details Confirmed; No New Releases
- **What**: Claude Code **v2.1.114** remains the latest release. No v2.1.115 or newer on GitHub releases, npm, or changelog as of April 20. Weekend quiet continues — 72+ hours since last release. **Claude Design additional details** (from official Anthropic page): (1) Export formats: Canva, PDF, PPTX, standalone HTML. (2) Claude Code handoff confirmed: "Claude packages everything into a handoff bundle that you can pass to Claude Code with a single instruction." (3) Powered by Opus 4.7 with enhanced vision (2,576px long edge, ~3.75MP). (4) Available for Pro, Max, Team, Enterprise. (5) Anthropic positions it as competitive with Figma for AI-native design workflows — VentureBeat headline: "challenges Figma." (6) Brilliant (early user): complex pages needed 20+ prompts in competitors, only 2 in Claude Design.
- **Significance**: Pipeline stable. Claude Design's handoff-to-Claude-Code integration is notable for future Phase 7 — if AaaS includes design-to-code automation, the bridge already exists. Export to standalone HTML means generated designs are portable and testable. Weekend release cadence normal — typical for Anthropic to batch changes for Monday-Friday releases.
- **Source**: https://releasebot.io/updates/anthropic/claude-code, https://www.anthropic.com/news/claude-design-anthropic-labs, https://techcrunch.com/2026/04/17/anthropic-launches-claude-design-a-new-product-for-creating-quick-visuals/, https://venturebeat.com/technology/anthropic-just-launched-claude-design-an-ai-tool-that-turns-prompts-into-prototypes-and-challenges-figma/

### 2026-04-19 (evening) — No Changes: v2.1.114 Holds for 48+ Hours
- **What**: Claude Code **v2.1.114** remains the latest release (Apr 18). No v2.1.115 or newer on GitHub releases or changelog. 48+ hours with no new release — typical weekend quiet period.
- **Significance**: Pipeline stable on v2.1.114. No action needed.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-04-18 (afternoon) -- Claude Design Launched (April 17): Visual Design Collaboration Product Powered by Opus 4.7
- **What**: **Claude Design** launched April 17, 2026 as an Anthropic Labs product in research preview. Key details: (1) **What it creates**: designs, prototypes, slides, pitch decks, one-pagers, marketing collateral, plus "frontier design" including voice, video, shaders, 3D, and built-in AI elements. (2) **Design system integration**: can read codebases and design files to build a team design system, then auto-apply brand consistency (colors, typography, components) across projects. (3) **Mixed-interface editing**: text prompts, inline comments, direct text edits, and adjustment knobs — beyond simple one-shot generation. (4) **Implementation handoff**: packages designs into handoff bundles for Claude Code, connecting design and development workflows. (5) **Powered by Opus 4.7**, not a separate design-specific model. (6) **Availability**: research preview for Pro, Max, Team, and Enterprise subscribers (Enterprise disabled by default, admin must enable). Access included with existing subscription limits; optional extra usage available.
- **Significance**: Claude Design is Anthropic's first non-code visual creation product. For our pipeline: (1) **Design handoff bundles for Claude Code** — if our pipeline generates UI-facing skills, the design→code handoff could be automated via Claude Design → Claude Code. (2) **Not directly relevant to our current pipeline** (we don't produce visual artifacts), but signals Anthropic expanding Claude Code's role from pure development to full product creation. (3) The "read codebases + design files" capability suggests Claude Code's file-system awareness is being reused across products. (4) For future Phase 7 AaaS: if customers need design automation alongside code automation, Claude Design is the complementary surface.
- **Source**: https://www.progressiverobot.com/2026/04/17/anthropic-launches-claude-design/

### 2026-04-18 (evening) -- Claude Code v2.1.113 + v2.1.114: Native Binary Spawn, Major Security Hardening, Opus 4.7 Bedrock Fix, Agent Teams Crash Fix
- **What**: Two releases landed April 17. **(1) v2.1.113** (April 17, 19:09 UTC) — **major release**: (a) **CLI now spawns a native Claude Code binary** (per-platform optional dependency) instead of bundled JavaScript — architectural change that should improve startup performance and reduce memory footprint. (b) **Security hardening** (5 fixes): `sandbox.network.deniedDomains` setting to block specific domains even when broader wildcards permit; macOS `/private/{etc,var,tmp,home}` treated as dangerous for `Bash(rm:*)` rules; Bash deny rules now match `env`/`sudo`/`watch`/`ionice`/`setsid` exec wrappers; `Bash(find:*)` no longer auto-approves `find -exec`/`-delete`; `dangerouslyDisableSandbox` fixed to require permission prompt; multi-line commands with first-line comments now show full command in transcript (UI spoofing fix). (c) **Opus 4.7 Bedrock fix**: `thinking.type.enabled is not supported` 400 error resolved for Bedrock Application Inference Profile ARNs. (d) **Subagent stability**: stalled mid-stream subagents now fail with clear error after 10 minutes instead of hanging silently. (e) **`/loop` improvement**: Esc cancels pending wakeups; wakeups display as "Claude resuming /loop wakeup". (f) **`/ultrareview`**: faster launch with parallelized checks, diffstat in launch dialog. (g) **Fullscreen**: Shift+↑/↓ scrolls viewport when extending selection. (h) **`CLAUDE_CODE_EXTRA_BODY` `output_config.effort` fix**: no longer causes 400 errors on subagent calls to models without effort support or on Vertex AI. (i) **Bug fixes** (15+): MCP concurrent-call timeout handling, session recap auto-firing while composing, markdown table pipe-in-code-span, long-context compaction on resumed sessions ("Extra usage required"), plugin version conflict detection, Remote Control session archiving/streaming, SDK image crash degradation, and more. **(2) v2.1.114** (April 17, 23:26 UTC) — single fix: crash in permission dialog when agent teams teammate requested tool permission.
- **Significance**: **(1) Native binary spawn** is the most architecturally significant change — shifts Claude Code from pure Node.js to a hybrid native/Node architecture. Monitor for stability regressions in our `claude -p` steward invocations. **(2) The Opus 4.7 Bedrock ARN fix** (v2.1.113) directly addresses the #49238 issue — users on Bedrock with Application Inference Profiles can now use Opus 4.7 without `thinking.type.enabled` errors. This resolves a P0 blocker for Bedrock-based deployments. **(3) `dangerouslyDisableSandbox` requiring permission prompt** is a security fix — automated pipelines using this flag may now pause for permission unexpectedly. **(4) Subagent 10-minute timeout** prevents our steward agents from hanging indefinitely on stalled subagent calls. **(5) `/loop` Esc cancellation** is useful for our `/loop`-based monitoring workflows. **(6) `CLAUDE_CODE_EXTRA_BODY` effort fix** — critical for mixed-model pipelines where a parent uses Opus 4.7 with effort but subagents may use models that don't support effort. **(7) Agent teams crash fix** (v2.1.114) — relevant if our future Phase 5 topology uses agent teams.
- **Source**: https://github.com/anthropics/claude-code/releases, https://code.claude.com/docs/en/changelog, https://www.npmjs.com/package/@anthropic-ai/claude-code

### 2026-04-18 -- Claude Code v2.1.112: Opus 4.7 Auto Mode Fix; Routines Research Preview Deepened; v2.1.111 Stabilization Day 2
- **What**: **v2.1.112** (April 16 evening) — single critical fix: resolved "claude-opus-4-7 is temporarily unavailable" error affecting auto mode on the new Opus 4.7 model. **v2.1.111 feature review (day 2)**: (1) **Opus 4.7 xhigh effort** confirmed stable — the interactive `/effort` slider with arrow-key navigation and Enter confirmation works across CLI and agent sessions; `xhigh` sits between `high` and `max`, falls back to `high` on non-4.7 models. (2) **`/ultrareview`** runs cloud-based parallel multi-agent code review — Pro/Max users get 3 free ultrareviews. (3) **`/less-permission-prompts`** scans transcripts for common read-only Bash/MCP calls and proposes additions to `.claude/settings.json` allowlist — significant steward-agent productivity win by reducing interactive permission prompts. (4) **Auto mode** no longer requires `--enable-auto-mode` flag. (5) **Plan files** now named after prompt text (e.g., `fix-auth-race-snug-otter.md`). (6) **`/skills` menu** now sortable by estimated token count (press `t`). (7) **Read-only bash commands** with glob patterns and `cd <project-dir> &&` no longer trigger permission prompts. (8) **Windows PowerShell tool** progressively rolling out (`CLAUDE_CODE_USE_POWERSHELL_TOOL` env var). **Bug fixes in v2.1.111**: terminal display tearing in iTerm2+tmux, `@` file suggestions re-scanning in non-git dirs, LSP diagnostics after edits, `/resume` tab-completion, `/context` grid rendering, `/clear` dropping session names, non-existent `commit` skill call, 429 rate-limit errors on Bedrock/Vertex/Foundry. **Routines** (April 14 research preview): saved cloud automations combining a prompt + repo + connectors, with three trigger types: **Scheduled** (hourly/daily/weekly), **API** (HTTP POST to per-routine endpoint with bearer token), **GitHub** (PR/release events). Run limits by plan: Pro 5/day, Max 15/day, Team/Enterprise 25/day. Minimum interval: 1 hour.
- **Significance**: The v2.1.112 hotfix for auto mode on Opus 4.7 confirms this is a rapid-response cycle around the 4.7 launch — expect a few more patch releases in the next 24h. **For our pipeline**: (1) **`/less-permission-prompts`** is directly applicable to our steward agents — running this on a steward session transcript would generate an allowlist that eliminates most interactive prompts, enabling faster unattended runs. **Action: run `/less-permission-prompts` on the factory-steward and ltc-steward sessions to generate allowlists.** (2) **Routines** are Anthropic's answer to our cron-based scheduling — scheduled + API + GitHub triggers. However, our current cron-based approach offers more flexibility (exact timing, custom scripts, performance JSON logging). Routines may be worth evaluating for simpler workflows, but our cron infrastructure is more mature for the multi-agent pipeline. (3) **`/skills` sortable by token count** helps our meta-agent-factory understand which skills are cheapest to inject — useful for Phase 5 topology-aware routing decisions. (4) **Plan file naming** (`fix-auth-race-snug-otter.md`) is useful context for debugging autonomous sessions — steward logs could reference these.
- **Source**: https://github.com/anthropics/claude-code/releases, https://code.claude.com/docs/en/routines, https://claude.com/blog/introducing-routines-in-claude-code

### 2026-04-17 -- Claude Code v2.1.110 + v2.1.111: Opus 4.7 `xhigh` Effort, `/ultrareview` Cloud Parallel Review, `/less-permission-prompts` Allowlist Builder, `/tui` Flicker-Free Mode; Desktop App Redesign + Routines Research Preview
- **What**: Two releases landed April 15–16. **(1) v2.1.111** (April 16): **Claude Opus 4.7 `xhigh` effort level** introduced (between `high` and `max`) — new finer-grained budget tier on top of the Opus 4.7 launch. **`/effort` command** now opens an interactive slider with arrow-key navigation. **`/less-permission-prompts` skill** — scans the session transcript and proposes a permission allowlist to reduce mid-task interruptions (productivity win for steward agents). **`/ultrareview`** — cloud-based comprehensive code review using parallel multi-agent analysis. **Auto mode** no longer requires the `--enable-auto-mode` flag (now default-available). **Windows PowerShell tool** progressive rollout via `CLAUDE_CODE_USE_POWERSHELL_TOOL` env var. **Plan files** renamed after prompts (e.g., `fix-auth-race-snug-otter.md`) — replaces numeric IDs for discoverability. **`/skills` menu** now supports sorting by token count (press `t`). "Auto (match terminal)" theme option for light/dark detection. Improved `/setup-vertex` and `/setup-bedrock` wizards. **(2) v2.1.110** (April 15): **`/tui` command** — toggles flicker-free rendering in fullscreen mode (alt-screen mode with virtualized scrollback). **Push notification tool** — surface-agnostic push to registered Remote Control devices when Claude decides to notify (requires "Push when Claude decides" config). **`autoScrollEnabled`** config option for conversation auto-scroll behavior. **External editor** can now show Claude's last response as commented context for inline reply composition. **`/plugin` Installed tab** — priority sorting, favorites, collapse-disabled-items. **`/doctor`** warns on MCP servers defined in multiple config scopes (conflict detection). **`--resume`/`--continue`** now resurrects unexpired scheduled tasks. **`/context`, `/exit`, `/reload-plugins`** work from Remote Control clients. Bug fixes: MCP tool calls hanging when server connection drops mid-response; non-streaming fallback retries causing multi-minute hangs; session recap enabled when telemetry disabled. **(3) Claude Code Desktop App Redesign (April 14)**: Anthropic released a complete redesign of the Claude Code desktop app for Mac and Windows alongside the launch of **Routines in research preview** — a shift from chat-centric to orchestration-centric development workflows. Routines let users codify repeating multi-step workflows with scheduled/triggered execution, surfacing as first-class primitives in the desktop app.
- **Significance**: The **`/less-permission-prompts` skill** is directly useful for our steward agents — running `/less-permission-prompts` after a steady-state steward run produces a vetted allowlist, cutting mid-session permission prompts to near zero. The **`/ultrareview` parallel multi-agent review** is a cloud-native multi-agent primitive embedded in the CLI — validates our Phase 5 topology-aware-router direction and gives a concrete pattern to study. **Opus 4.7 `xhigh` effort** adds a budget tier for tasks where `high` underperforms but `max` is wasteful — likely useful for our optimizer's harder eval prompts. **`/tui` flicker-free fullscreen mode** may benefit steward agents running over SSH (our current fleet). The **push notification tool** enables agent → human handoff on async judgments — relevant for our Phase 5 watchdog circuit breaker pattern. **Routines** (research preview) is the most strategically significant item: if Routines becomes a stable primitive, it could subsume parts of our cron-scheduled steward architecture — monitor closely. For our fleet: **update to v2.1.111 is recommended** once rolled out, particularly for `/less-permission-prompts` and `xhigh` effort access.
- **Source**: https://code.claude.com/docs/en/changelog, https://venturebeat.com/orchestration/we-tested-anthropics-redesigned-claude-code-desktop-app-and-routines-heres-what-enterprises-should-know

### 2026-04-16 -- Claude Code v2.1.109: Extended-Thinking Progress Hint; v2.1.108: Prompt Caching TTL Controls, Session Recap, Skill Discovery; v2.1.107: Thinking Hints Earlier; v2.1.105: PreCompact Hook, Background Monitors, 1536-char Skill Descriptions
- **What**: Four releases landed April 13–15. **(1) v2.1.109** (April 15): Improved extended-thinking indicator with a rotating progress hint — gives better user visibility during long reasoning passes. **(2) v2.1.108** (April 14, major): **Prompt caching TTL controls** — `ENABLE_PROMPT_CACHING_1H` env var opts into 1-hour cache TTL on API key/Bedrock/Vertex/Foundry; `FORCE_PROMPT_CACHING_5M` forces 5-minute TTL (useful for frequently-changing system prompts); startup warning shown if caching disabled. **Session recap** — `/recap` command provides context summary when returning to a session; auto-triggered after away periods; configurable in `/config`; force-enabled via `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` if telemetry disabled. **Skill tool discovers built-in slash commands** — model can now invoke `/init`, `/review`, `/security-review`, and similar built-in commands via the Skill tool (previously Skill tool only found user/plugin skills). `/undo` now aliases `/rewind`. Enhanced `/model` warns before mid-conversation model switches (full history re-read uncached). Improved `/resume` picker defaults to current directory sessions; `Ctrl+A` shows all projects. Error messages now distinguish server rate limits from plan usage limits; 5xx/529 errors show `status.claude.com` link. Language grammars load on-demand → lower memory footprint for file reads/edits/highlighting. **Bug fixes**: paste regression in `/login` code prompt; `DISABLE_TELEMETRY` fallback to 5-minute cache; Agent tool prompting in auto mode when safety classifier context exceeded; Bash `CLAUDE_ENV_FILE` ending with `#` comment producing no output; `--resume` losing custom session names/colors; session titles showing placeholder on short greetings; terminal escape codes appearing as garbage after `--teleport`; diacritical marks (accents, umlauts) dropped when `language` setting configured; policy-managed plugins not auto-updating across projects. **(3) v2.1.107** (April 14, minor): Show thinking hints sooner during long operations. **(4) v2.1.105** (April 13): **`EnterWorktree` path parameter** — accepts `path` to switch into existing worktree (not just create new ones). **PreCompact hook support** — hooks can block compaction by exiting with code 2 or returning `{"decision":"block"}`. **Background Monitor support** — plugins can declare `monitors` manifest key for auto-arming at session start or skill invoke. `/proactive` now aliases `/loop`. **Stalled API stream handling** — streams abort after 5 minutes of no data, retry non-streaming. **Skill description cap raised 250→1,536 characters** with startup warning on truncation. `WebFetch` strips `<style>` and `<script>` tag contents (prevents CSS/JS bloat in context). MCP output truncation with format-specific recipes (jq for JSON). `/doctor` improved layout with status icons; press `f` to have Claude fix issues. **Bug fixes**: images dropped from queued messages; blank screen on wrap-to-second-line in long conversations; leading whitespace trimmed from assistant messages (breaking ASCII art/indents); garbled bash output with rich/loguru clickable links; alt+enter not inserting newlines in ESC-prefix terminals; one-shot scheduled tasks re-firing repeatedly; inbound notifications dropped after first message (Team/Enterprise); marketplace plugins with `package.json` not auto-installing; 429 rate-limit errors showing raw JSON; crash on resume with malformed text blocks; washed-out 16-color palette over SSH (Ghostty, Kitty, Alacritty, WezTerm, foot, rio, Contour).
- **Significance**: The **Skill tool discovering built-in commands** (v2.1.108) is architecturally significant — it unifies user-defined and built-in skills under one discovery API, enabling agents to programmatically invoke any slash command. The **1-hour prompt cache TTL** (v2.1.108) is impactful for our steward agents: nightly runs that exceed 5 minutes will now benefit from 1-hour caching without additional setup, reducing costs significantly. The **PreCompact hook** (v2.1.105) enables pipeline control over context compaction — our steward agents could block premature compaction and force a clean state instead. The **1,536-char skill description cap** (v2.1.105) allows richer trigger descriptions in our SKILL.md files. The **Background Monitor** manifest key enables plugins to auto-arm monitoring without explicit invocation — useful for our supervisor/watchdog agents in Phase 5. The **session recap** feature could benefit our long-running steward agents by providing context restoration after interruption. For our fleet: **update to v2.1.109 is recommended** — includes memory, caching, and reliability improvements directly relevant to steward operations.
- **Source**: https://code.claude.com/docs/en/changelog, https://releasebot.io/updates/anthropic/claude-code

### 2026-04-12 -- Claude Code v2.1.101: Team Onboarding, OS CA Trust, Command Injection Fix, Memory Leak Fix
- **What**: v2.1.101 released April 10, 19:03 UTC — significant feature and security release: (1) **`/team-onboarding` command** — generates teammate ramp-up guides from local Claude Code usage patterns. First built-in team knowledge transfer feature. (2) **OS CA certificate store trust by default** — enterprise TLS proxy certificates now trusted automatically, eliminating a major friction point for corporate environments. Set `CLAUDE_CODE_CERT_STORE=bundled` to revert to bundled certs only. (3) **`/ultraplan` and remote-session auto-create default cloud environments** — lowers barrier for cloud-based agent workflows. (4) **Brief mode retry** when Claude responds with plain text instead of structured messages — improves reliability. (5) **Session naming** via `/rename` and `--name` for `claude -p --resume`. (6) **Settings resilience** — unrecognized hook events no longer silently ignored. **Security fixes**: Fixed command injection vulnerability in POSIX `which` fallback (exec path); fixed memory leak in long sessions with historical message copies (critical for our steward agents); fixed `--resume` losing context on large sessions; fixed hardcoded 5-minute request timeout that aborted slow backends; fixed `permissions.deny` rules being overridden by PreToolUse hooks; fixed Bedrock SigV4 authentication with Authorization headers; fixed subagents not inheriting MCP tools from dynamically-injected servers. **VSCode**: Fixed file attachment clearing when last editor tab closes.
- **Significance**: The **command injection fix in `which` fallback** is a security-critical update — affects exec path resolution. The **memory leak fix for long sessions** is critical for our steward agents running multi-hour sessions. The **`permissions.deny` override by PreToolUse hooks** was a permission escalation vector. The **subagent MCP tool inheritance fix** matters for our multi-agent pipeline where parent agents inject MCP servers that subagents need. The `/team-onboarding` command is a new team collaboration primitive. The OS CA trust default removes a top enterprise adoption blocker. For our fleet: **update to v2.1.101 is P0** — multiple security and stability fixes.
- **Source**: https://github.com/anthropics/claude-code/releases (v2.1.101), https://code.claude.com/docs/en/changelog

### 2026-04-11 -- Claude Code v2.1.98/v2.1.100: Vertex AI Wizard, PID Namespace Sandboxing, Monitor Tool
- **What**: Two releases landed after v2.1.97: (1) **v2.1.98** (April 9 late, 19:18 UTC) — major security and feature release: **Interactive Google Vertex AI setup wizard** with GCP authentication and configuration guidance; **`CLAUDE_CODE_PERFORCE_MODE`** env var for read-only file handling with `p4 edit` hints (first Perforce/Helix integration); **Monitor tool** for streaming background script events (enables observing long-running processes); **Subprocess sandboxing with PID namespace isolation on Linux** (significant security hardening — processes in sandboxed subshells can no longer enumerate or signal other system processes); **`workspace.git_worktree` status line support**; **W3C `TRACEPARENT` env var for OTEL tracing** (enterprise observability); security fixes for Bash tool permission bypass corrections and compound command hardening; MCP OAuth metadata URL handling improvements; terminal/UI fixes (kitty keyboard protocol, macOS text replacements, wrapped URLs); `/resume` picker improvements; managed settings and permission rules enforcement. (2) **v2.1.100** (April 10, 05:16 UTC) — minor release 11 hours later: config key changes (VE, xI added; DE, bI removed), bundle size -2.5 KB. No v2.1.99 published (skipped).
- **Significance**: The PID namespace isolation is the most significant security hardening since the permission system redesign — it prevents sandbox escapes via process enumeration. The Vertex AI wizard and Perforce mode show Claude Code expanding beyond GitHub/AWS-centric workflows into GCP and enterprise SCM. The Monitor tool enables a new pattern: start a background process, then stream its events — useful for dev server monitoring, build watching, and CI observation. The TRACEPARENT OTEL support is critical for enterprise adoption, enabling distributed tracing across agent workflows.
- **Source**: https://github.com/anthropics/claude-code/releases (v2.1.98, v2.1.100), https://releasebot.io/updates/anthropic/claude-code, https://x.com/ClaudeCodeLog/status/2042508030382678075

### 2026-04-10 -- Claude Code v2.1.97: Focus View, MCP Memory Leak Fix, Permission Hardening
- **What**: Claude Code v2.1.97 released April 9, 2026. Major additions: (1) **Focus view toggle** (`Ctrl+O`) in `NO_FLICKER` mode — shows prompt, one-line tool summary with edit diffstats, and final response only. (2) **Status line `refreshInterval`** setting — re-runs the status line command every N seconds. (3) **`workspace.git_worktree`** in status line JSON input — set when inside a linked git worktree. (4) **`● N running` indicator** in `/agents` showing live subagent instances. (5) **Cedar policy file syntax highlighting** (`.cedar`, `.cedarpolicy`). (6) **Auto mode sandbox network access** — now auto-approves sandbox network access prompts. Notable fixes: **MCP HTTP/SSE memory leak** — connections accumulating ~50 MB/hr of unreleased buffers on reconnect (critical for long-running sessions). **MCP OAuth `authServerMetadataUrl`** not honored on token refresh. **429 retry regression** — exponential backoff was burning all attempts in ~13 seconds, now applies as minimum. **Permission rule prototype collision** — rules with names matching JS prototype properties (e.g., `toString`) silently ignored `settings.json`. **`permissions.additionalDirectories`** not applying mid-session. **`--dangerously-skip-permissions`** being silently downgraded after approving protected path writes. **Bash tool permission hardening** around environment variables and network redirects. Multiple `/resume` picker fixes. File-edit diffs disappearing on `--resume` for files >10KB. Korean/Japanese/Unicode text garbling in no-flicker mode on Windows. Bedrock SigV4 auth with empty `AWS_BEARER_TOKEN_BEDROCK`. CJK sentence punctuation now triggers slash command and @-mention completion. Image compression now matches token budgets for pasted/attached images. Transcript persistence for mid-turn messages and attachment data.
- **Significance**: The **MCP memory leak fix is critical** for our steward agents — 50 MB/hr leak means 400 MB in an 8-hour session, potentially causing OOM kills. The focus view is useful for monitoring agent runs. The permission hardening fixes (prototype collision, `additionalDirectories`, skip-permissions downgrade, bash env/redirect validation) address real security gaps in automated agent workflows. The 429 retry fix improves reliability under rate limits. For our pipeline: the `git_worktree` status line input enables worktree-aware agent UIs. The subagent count indicator (`● N running`) improves observability for our multi-agent runs.
- **Source**: https://github.com/anthropics/claude-code/releases, https://releasebot.io/updates/anthropic/claude-code

### 2026-04-09 -- Claude Code v2.1.94 + v2.1.96: Bedrock Mantle Integration, Effort Level Default Raised to High
- **What**: Two new Claude Code releases after the 4-day stabilization period: (1) **v2.1.94** (April 7): Major additions include Amazon Bedrock integration powered by Mantle (`CLAUDE_CODE_USE_MANTLE=1`), default effort level increased from medium to high for API-key/Bedrock/Vertex/Foundry/Team/Enterprise users, Slack MCP send-message tool now displays "Slacked #channel" with clickable links, plugin skills use frontmatter `name` field for stable invocation names, and `hookSpecificOutput.sessionTitle` for UserPromptSubmit hooks. Notable fixes: rate-limit dialog no longer gets stuck after 429 with long Retry-After, scrollback duplication in long sessions, CJK/multibyte text corruption (U+FFFD) in stream-json when chunk boundaries split UTF-8, Shift+Space literal text bug, hyperlink double-opening in tmux. (2) **v2.1.96** (April 8): Hotfix for a v2.1.94 regression — Bedrock requests failing with `403 "Authorization header is missing"` when using `AWS_BEARER_TOKEN_BEDROCK` or `CLAUDE_CODE_SKIP_BEDROCK_AUTH`. (3) The **`ant` CLI** was also launched April 8 — a new command-line client for the Claude API enabling faster API interaction, native Claude Code integration, and YAML versioning of API resources.
- **Significance**: The effort level default change (medium → high) affects all non-free-tier users — agents and automated workflows that relied on medium effort will now consume more tokens but produce higher quality output. The Bedrock Mantle integration signals deeper AWS partnership. The `ant` CLI is a new tool for API developers to manage resources without writing code. The CJK/UTF-8 fix is critical for international codebases. The stabilization has ended — release cadence has resumed.
- **Source**: https://releasebot.io/updates/anthropic/claude-code, https://code.claude.com/docs/en/changelog, https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-08 -- CVE-2026-35020 Affects Claude Code CLI; v2.1.92 Still Current; No New Release
- **What**: (1) **CVE-2026-35020** (published April 6, modified April 7): High-severity OS command injection vulnerability (CVSS 8.4/8.6) affects Claude Code CLI via the `TERMINAL` environment variable. Local attackers can execute arbitrary commands through shell metacharacter injection when `TERMINAL` is parsed with `shell=true`. Triggered during normal CLI execution and deep-link handler paths. Remediation: update to latest Claude Code version and sanitize `TERMINAL` env var. See agent-sdk.md for full details. (2) No new Claude Code release since v2.1.92 (April 4). Day 4 of stabilization. (3) The `/powerup` interactive lessons (v2.1.90) now cover 18 topics from beginner to advanced, making Claude Code more accessible to new users. (4) `Ctrl+B` (v2.1.92) enables pushing tasks to background with unique IDs — supports parallel task execution within a single session.
- **Significance**: The CVE is the primary action item — update Claude Code CLI in all environments. The stabilization period (4 days without release after 30+ releases in March-April) suggests either a larger release is being prepared or the team is focused on Mythos/Glasswing launch support.
- **Source**: https://cvefeed.io/vuln/detail/CVE-2026-35020, https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md

### 2026-04-07 -- Stabilization Continues; Vertex AI Integration Webinar; v2.1.92 Still Current
- **What**: No new Claude Code release since v2.1.92 (April 4). Day 3 of stabilization period. Anthropic hosted a "Ship Code Faster with Claude Code on Vertex AI" webinar on April 7, signaling deepening GCP integration alongside existing AWS Bedrock support (interactive setup wizard added in v2.1.92). Interactive startup improved ~30ms by parallelizing setup() with slash command and agent loading. REPL now renders immediately with MCP servers instead of blocking until all connect. The 30+ releases in the v2.1.x series (March-April) suggest the next version is being prepared.
- **Significance**: The Vertex AI webinar indicates Claude Code is being positioned as a multi-cloud enterprise tool, not just Anthropic-native. Combined with the Bedrock wizard, Claude Code now has guided setup for both major cloud AI platforms. The startup performance improvements reduce friction for MCP-heavy configurations.
- **Source**: https://www.anthropic.com/events, https://code.claude.com/docs/en/changelog

### 2026-04-06 -- No New Release; v2.1.92 Remains Current
- **What**: No new Claude Code release since v2.1.92 (April 4). The `/powerup` interactive tutorial system (v2.1.90, April 1) continues to receive community coverage — 18 built-in lessons covering beginner to advanced features with animated terminal demos. `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` env var confirmed for offline environments (keeps marketplace cache when git pull fails). Cowork Dispatch message delivery fix confirmed in latest builds.
- **Significance**: The v2.1.x release cadence (~30 releases in March-April) suggests a new version is imminent. No breaking changes to track.
- **Source**: https://releasebot.io/updates/anthropic/claude-code, https://help.apiyi.com/en/claude-code-v2-1-92-mcp-persistence-powerup-tutorial-en.html

### 2026-04-05 -- v2.1.92: Bedrock Setup Wizard, Per-Model Cost Breakdown, Write Tool 60% Faster
- **What**: v2.1.92 released (April 4) with significant features and performance improvements: (1) `forceRemoteSettingsRefresh` policy setting — blocks CLI startup until remote managed settings are freshly fetched; exits on failure. Enterprise security control for ensuring agents always run with latest policies. (2) Interactive Bedrock setup wizard from the login screen's "3rd-party platform" selection — guided AWS authentication and credential verification. (3) Per-model and cache-hit cost breakdown in `/cost` command for subscription users. (4) `/release-notes` converted to interactive version picker. (5) Remote Control sessions now default to hostname-based naming (e.g., `myhost-graceful-unicorn`), customizable via `--remote-control-session-name-prefix`. (6) Pro users receive footer hint displaying uncached token count when returning to sessions after prompt cache expiration. (7) Write tool diff computation accelerated **60%** for large files containing tabs/`&`/`$` characters. (8) Linux sandbox now includes `apply-seccomp` helper in npm and native builds for unix-socket blocking.
- **Fixes**: Subagent spawning no longer fails with "Could not determine pane count" after tmux window changes. API 400 errors eliminated when extended thinking produces whitespace-only text blocks. Tool input validation failures resolved when streaming emits array/object fields as JSON strings. Plugin MCP servers no longer stuck "connecting" when duplicating unauthenticated claude.ai connectors. Message duplication fixed when scrolling up in fullscreen mode (iTerm2, Ghostty, DEC 2026 support). Accidental feedback survey submissions from autopilot keypresses prevented.
- **Removed**: `/tag` command removed. `/vim` command removed (toggle via `/config` Editor mode).
- **Significance**: The 60% Write tool speedup is material for large-file editing workloads. `forceRemoteSettingsRefresh` gives enterprises a hard guarantee that agents run with current policies — critical for compliance. Bedrock wizard lowers the barrier for AWS-native Claude Code deployments. The subagent tmux fix resolves a pain point for multi-agent workflows in terminal multiplexers.
- **Source**: https://releasebot.io/updates/anthropic/claude-code

### 2026-04-05 -- OpenClaw/Third-Party Agent Subscription Cutoff
- **What**: Effective April 5, 2026 at 12pm PT, Anthropic cut off the ability for Claude Pro/Max subscribers to use their subscriptions through third-party agentic tools like OpenClaw. Boris Cherny (Head of Claude Code) stated: "We've been working hard to meet the increase in demand for Claude, and our subscriptions weren't built for the usage patterns of these third-party tools." Third-party harnesses were placing "outsized strain" on compute infrastructure. Users can still access Claude through external tools via pay-as-you-go "extra usage" billing or direct API keys. Subscribers received a one-time credit equal to monthly plan cost (redeemable until April 17) and pre-purchased extra usage bundles with up to 30% discount. OpenClaw creator Peter Steinberger negotiated a one-week delay but could not prevent the change.
- **Significance**: Major policy shift — Anthropic is drawing a clear line between subscription (for Anthropic's own products: Claude.ai, Claude Code, Cowork) and API (for third-party integrations). This forces the ecosystem of third-party Claude tools onto API pricing, significantly increasing costs for heavy agentic usage. Signals that flat-rate subscriptions cannot sustain continuous agent-driven usage patterns. May accelerate development of Anthropic's own agent products (Conway, Dispatch) as the preferred consumer endpoints.
- **Source**: https://the-decoder.com/anthropic-cuts-off-third-party-tools-like-openclaw-for-claude-subscribers-citing-unsustainable-demand/, https://venturebeat.com/technology/anthropic-cuts-off-the-ability-to-use-claude-subscriptions-with-openclaw-and

### 2026-04-04 -- v2.1.91: MCP Result Persistence Override, Skill Shell Execution Control
- **What**: v2.1.91 released with: (1) MCP tool result persistence override via `_meta["anthropic/maxResultSizeChars"]` annotation — allows MCP servers to specify tool results up to 500K characters (previously hard-capped). (2) `disableSkillShellExecution` managed setting — disables inline shell execution within skills/commands, an enterprise security control. (3) Multi-line prompt support in `claude-cli://open?q=` deep links. (4) Plugin executables now supported under `bin/` directory in plugins. (5) Fixed async transcript chain breaks on `--resume` losing history. (6) Fixed iTerm2 `cmd+delete` not deleting to start of line. (7) Fixed Windows Terminal Preview 1.25 Shift+Enter submitting instead of inserting newline. (8) Edit tool now uses shorter `old_string` anchors to reduce output tokens.
- **Significance**: The 500K MCP result size override is a major change for MCP servers returning large datasets (e.g., database queries, log analysis). `disableSkillShellExecution` gives enterprises granular control over skill capabilities. The Edit tool anchor optimization reduces token usage across all editing operations.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-04-04 -- Comprehensive Environment Variable Catalog (newly documented)
- **What**: Full audit of new environment variables introduced in v2.1.69-v2.1.91: `CLAUDE_CODE_NO_FLICKER=1` (alt-screen rendering), `CLAUDE_STREAM_IDLE_TIMEOUT_MS` (streaming watchdog, default 90s), `CLAUDE_CODE_MCP_SERVER_NAME/URL` (MCP helper context), `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` (credential stripping), `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS` (capability override for third-party providers), `ANTHROPIC_CUSTOM_MODEL_OPTION` (custom `/model` picker entry), `ENABLE_TOOL_SEARCH` (activate with custom base URLs), `ENABLE_CLAUDEAI_MCP_SERVERS=false` (opt out of cloud MCP), `CLAUDE_CODE_DISABLE_CRON/1M_CONTEXT/TERMINAL_TITLE/EXPERIMENTAL_BETAS/GIT_INSTRUCTIONS` (feature toggles), `OTEL_LOG_TOOL_DETAILS=1` (OpenTelemetry tool parameter logging), `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` (configurable session-end timeout), `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` (offline resilience), `MCP_CONNECTION_NONBLOCKING=true` (skip MCP wait in headless mode).
- **Significance**: The volume of new env vars reflects Claude Code's maturation into an enterprise-grade platform with fine-grained operational controls. Key categories: security (`ENV_SCRUB`), observability (`OTEL_LOG_TOOL_DETAILS`, `SESSION_ID` header), performance (`NO_FLICKER`, `STREAM_IDLE_TIMEOUT`), and compatibility (`MODEL_SUPPORTS`, `CUSTOM_MODEL_OPTION`).
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-04-03 -- Source Code Leak via npm Source Map (v2.1.88)
- **What**: A 59.8 MB JavaScript source map file (.map) was inadvertently included in the @anthropic-ai/claude-code npm package (v2.1.88), exposing the full ~512,000-line TypeScript codebase. Discovered by Chaofan Shou (Solayer Labs intern) and mirrored across GitHub within hours. Key revelations: (1) **KAIROS** — a feature flag mentioned 150+ times, representing an autonomous daemon mode where Claude Code operates as an always-on background agent. (2) **Anti-distillation mechanisms** — `anti_distillation: ['fake_tools']` in API requests silently injects decoy tool definitions to prevent model distillation. (3) **Undercover Mode** — enables stealth contributions to public open-source repositories. (4) **Model codenames confirmed**: Capybara = Claude 4.6 variant (new tier above Opus), Fennec = Opus 4.6, Numbat = unreleased model still in testing. Anthropic cited "process errors" and fast release cycle. Concurrent supply-chain attack on axios npm package (v1.14.1/0.30.4 with RAT) occurred hours before, though unrelated.
- **Significance**: Largest accidental source code exposure from a major AI company. KAIROS reveals Anthropic's roadmap toward persistent background agents. Anti-distillation confirms active defense against model copying. Anthropic's aggressive DMCA response (accidentally taking down thousands of GitHub repos) drew additional criticism. Users who installed Claude Code via npm on March 31 between 00:21-03:29 UTC may have been affected by the axios RAT.
- **Source**: https://venturebeat.com/technology/claude-codes-source-code-appears-to-have-leaked-heres-what-we-know, https://fortune.com/2026/03/31/anthropic-source-code-claude-code-data-leak-second-security-lapse-days-after-accidentally-revealing-mythos/, https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/

### 2026-04-03 -- Security Disclosure: Deny-Rule Bypass via Long Command Chains
- **What**: Security firm Adversa disclosed that Claude Code's deny rules (e.g., blocking `curl`) can be bypassed when command chains exceed 50 subcommands, due to a hard-coded constant `MAX_SUBCOMMANDS_FOR_SECURITY_CHECK = 50`. Beyond this threshold, the system falls back to asking user permission instead of enforcing the deny rule. An attacker could craft malicious project files that instruct Claude to build 50+ command pipelines disguised as legitimate build processes.
- **Significance**: First publicly reported bypass of Claude Code's permission/deny system. Enterprise users running Claude Code in auto-accept modes should audit deny rules and monitor for unusually long command chains.
- **Source**: https://www.theregister.com/2026/04/01/claude_code_rule_cap_raises/

### 2026-04-03 -- v2.1.90 Additional Details (supplemental)
- **What**: Beyond what was documented on 2026-04-02, v2.1.90 also includes: (1) Fixed auto mode not respecting explicit user boundaries ("don't push", "wait for X before Y"), (2) Fixed click-to-expand hover text nearly invisible on light terminal themes, (3) Fixed UI crash when malformed tool input reached the permission dialog, (4) Fixed headers disappearing when scrolling `/model`, `/config`, and selection screens, (5) Removed `Get-DnsClientCache` and `ipconfig /displaydns` from the auto-allow list for DNS cache privacy, (6) Changed `--resume` picker to no longer show sessions created by `claude -p` or SDK invocations.
- **Significance**: The auto-mode boundary fix is notable -- Claude Code was previously ignoring explicit user instructions like "don't push" in auto mode, which could lead to unintended actions in autonomous workflows.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-04-03 -- v2.1.89 Additional Details (supplemental)
- **What**: Beyond what was documented on 2026-04-02, v2.1.89 also includes: (1) Auto mode denied commands now show a notification and appear in `/permissions` -> Recent tab where you can retry with `r`, (2) Changed Edit to work on files viewed via Bash with `sed -n` or `cat` without requiring a separate Read call, (3) Changed hook output over 50K characters to be saved to disk with a file path + preview instead of injecting directly into context, (4) Changed thinking summaries to no longer be generated by default in interactive sessions (set `showThinkingSummaries: true` to restore), (5) `/env` now applies to PowerShell commands, (6) Pasting `!command` into empty prompt enters bash mode, (7) Fixed Devanagari and combining-mark text truncation, (8) Fixed voice mode failing to request microphone permission on macOS Apple Silicon, (9) Fixed potential OOM crash on Edit of files over 1 GiB.
- **Significance**: Thinking summaries disabled by default is a behavioral change affecting all interactive users. The Edit-without-Read change reduces friction. The 50K hook output cap prevents context pollution.
- **Source**: https://github.com/anthropics/claude-code/releases/tag/v2.1.89

### 2026-04-02 -- Comprehensive March-April 2026 Release Analysis (v2.1.63 through v2.1.90)
- **What**: Major research sweep covering all Claude Code releases from late February through April 1, 2026. This period saw 28+ releases with significant new capabilities across hooks, MCP, CLI, agents, model support, and IDE extensions.
- **Significance**: Claude Code has shifted from a developer tool to an autonomous engineering platform with multi-agent orchestration, voice control, cron scheduling, and deep MCP/hook integration.
- **Source**: https://code.claude.com/docs/en/changelog

---

### 2026-04-01 -- v2.1.90: /powerup, performance, security hardening
- **What**: Added `/powerup` interactive lessons with animated demos. Added `CLAUDE_CODE_PLUGIN_KEEP_MARKETPLACE_ON_FAILURE` for offline environments. Added `.husky` to protected directories. Fixed infinite rate-limit dialog loop, `--resume` prompt-cache miss regression (since v2.1.69), format-on-save hook conflicts with Edit/Write, and PreToolUse stdout+exit-code-2 blocking. Eliminated per-turn JSON.stringify of MCP tool schemas. SSE transport now handles large frames in linear time (was quadratic). SDK long-conversation transcript writes no longer quadratic.
- **Significance**: Performance fixes for SSE and SDK long sessions are critical for production agent deployments.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-04-01 -- v2.1.89: Defer hook decision, PermissionDenied hook, named subagents
- **What**: Added `"defer"` permission decision for PreToolUse hooks -- headless sessions can pause at tool calls and resume with `-p --resume` for re-evaluation. Added `PermissionDenied` hook (fires after auto mode classifier denials; return `{retry: true}` to retry). Named subagents appear in `@` mention typeahead. `MCP_CONNECTION_NONBLOCKING=true` for `-p` mode skips MCP wait entirely. `CLAUDE_CODE_NO_FLICKER=1` for flicker-free alt-screen rendering. Fixed StructuredOutput schema cache bug (~50% failure rate with multiple schemas). Fixed autocompact thrash loop (3-attempt circuit breaker). Fixed nested CLAUDE.md re-injection in long sessions.
- **Significance**: The `defer` decision is transformative for CI/CD -- headless agents can now pause at permission boundaries and be resumed by a human or another system. The PermissionDenied hook enables auto-retry patterns in autonomous workflows.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-03-29 -- v2.1.87: Cowork Dispatch fix
- **What**: Fixed messages in Cowork Dispatch not getting delivered.
- **Significance**: Critical fix for multi-agent team communication.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-03-27 -- v2.1.86: Session ID header, VCS exclusions
- **What**: Added `X-Claude-Code-Session-Id` header to API requests for proxy aggregation. Added `.jj` (Jujutsu) and `.sl` (Sapling) to VCS exclusion lists. Fixed `--resume` failure on pre-v2.1.85 sessions, files outside project root with conditional skills, config corruption from disk writes on every skill invocation (Windows). Reduced startup event-loop stalls with claude.ai MCP connectors (keychain cache 5s to 30s). Skill descriptions capped at 250 chars to reduce context usage.
- **Significance**: Session ID header enables enterprise proxy monitoring and billing. VCS exclusions show growing support for non-Git version control.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-03-26 -- v2.1.85: Conditional hooks, MCP OAuth RFC 9728, elicitation enhancements
- **What**: Added conditional `if` field for hooks using permission rule syntax (e.g., `Bash(git *)`). Added `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` environment variables for multi-server MCP helper scripts. MCP OAuth now follows RFC 9728 Protected Resource Metadata discovery. PreToolUse hooks can satisfy `AskUserQuestion` by returning `updatedInput` + `permissionDecision: "allow"`. Added timestamp markers for `/loop` and CronCreate. OpenTelemetry tool_parameters gated behind `OTEL_LOG_TOOL_DETAILS=1`. Deep links support 5,000 chars. Fixed Python Agent SDK dropping `type:'sdk'` MCP servers. Replaced WASM yoga-layout with pure TypeScript for scroll performance.
- **Significance**: Conditional hooks are a major efficiency gain -- hooks only fire when their `if` condition matches, reducing overhead. RFC 9728 compliance signals enterprise-grade OAuth for MCP servers. PreToolUse answering AskUserQuestion enables fully autonomous agent flows.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-26 -- v2.1.84: PowerShell tool, TaskCreated hook, MCP dedup
- **What**: Added PowerShell tool for Windows (opt-in preview) with hardened permission checks. Added `ANTHROPIC_DEFAULT_{OPUS,SONNET,HAIKU}_MODEL_SUPPORTS` env vars for Bedrock/Vertex/Foundry capability override. Added `TaskCreated` hook. Added `WorktreeCreate` hook `type: "http"` support. MCP tool descriptions capped at 2KB. MCP deduplication (local config wins over claude.ai). Added `allowedChannelPlugins` managed setting. Token counts >= 1M display as "1.5m". Global system-prompt caching works with ToolSearch.
- **Significance**: PowerShell tool brings Windows to parity with Unix. MCP deduplication prevents tool conflicts in enterprise deployments with both local and cloud configs.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-25 -- v2.1.83: Managed settings drop-in, reactive hooks, transcript search
- **What**: Added `managed-settings.d/` drop-in directory for independent policy fragments. Added `CwdChanged` and `FileChanged` hook events for reactive environment management (direnv, auto-reload). Added transcript search (press `/` in Ctrl+O mode). Added `sandbox.failIfUnavailable` to exit on missing sandbox. Added `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1` to strip credentials from subprocesses. Agents can declare `initialPrompt` in frontmatter. `chat:killAgents` and `chat:fastMode` now rebindable.
- **Significance**: Reactive hooks (CwdChanged/FileChanged) enable environment-aware agents that adapt when files or directories change. Managed settings drop-in allows enterprise admins to compose policies from multiple sources without conflict.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-20 -- v2.1.81: --bare flag, --channels permission relay
- **What**: Added `--bare` flag for scripted `-p` calls -- skips hooks, LSP, plugin sync, skill walks; requires API key (OAuth/keychain disabled). Added `--channels` permission relay -- channel servers can forward tool approval to phone. Fixed multiple concurrent sessions requiring repeated re-auth. Fixed Node.js 18 crash.
- **Significance**: `--bare` is essential for embedded/scripted use cases where startup overhead must be minimized. Channels permission relay is a step toward mobile-controlled autonomous agents.
- **Source**: https://github.com/anthropics/claude-code/releases

### 2026-03-19 -- v2.1.80: Rate limit statusline, skill effort, channels preview
- **What**: Added `rate_limits` statusline field for Claude.ai usage (5-hour/7-day windows). Added `source: 'settings'` plugin marketplace source (inline in settings.json). Added `effort:` frontmatter for skills/commands. Added `--channels` research preview (MCP servers push messages into session). Reduced ~80MB startup memory for 250k-file repos.
- **Significance**: Rate limit visibility in statusline prevents surprise throttling. Skill effort frontmatter enables per-skill model intensity tuning.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-17 -- v2.1.78: StopFailure hook, line-by-line streaming
- **What**: Added `StopFailure` hook (fires on API error-caused turn end). Added `${CLAUDE_PLUGIN_DATA}` variable for persistent plugin state. Added plugin agent frontmatter (`effort`, `maxTurns`, `disallowedTools`). Response text now streams line-by-line. Renamed `/fork` to `/branch`. SECURITY: Fixed silent sandbox disable when dependencies missing.
- **Significance**: StopFailure hook is critical for error recovery in autonomous pipelines. Plugin data persistence enables stateful plugin workflows.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-17 -- v2.1.77: Opus 4.6 output token increase
- **What**: Increased default output token limit for Opus 4.6 to 64k tokens. Upper bound increased to 128k tokens for both Opus 4.6 and Sonnet 4.6. Added `allowRead` sandbox setting. Fixed auto-updater downloading tens of GB in parallel. Fixed PreToolUse `"allow"` bypassing `deny` rules.
- **Significance**: 128k output token support is a 16x increase over original limits, enabling much larger code generation in single turns.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-14 -- v2.1.76: MCP Elicitation, session naming, sparse checkout
- **What**: MCP servers can now request structured user input mid-task via interactive dialog (`Elicitation` and `ElicitationResult` hooks). Added `-n`/`--name` CLI flag for session naming. Added `worktree.sparsePaths` for large monorepo sparse checkout. Added `PostCompact` hook. Added `/effort` command. Background agents can be killed preserving partial results.
- **Significance**: MCP Elicitation is a paradigm shift -- MCP servers can pause execution and ask the user (or a hook) for structured data, enabling interactive multi-step workflows without pre-planned parameters.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-13 -- v2.1.75: 1M context for Opus 4.6
- **What**: Opus 4.6 now has 1M context window for Max, Team, and Enterprise plans at standard pricing (no beta header). Added `/color` command. Memory files get last-modified timestamps. Claude now reasons about fresh vs stale memories.
- **Significance**: 1M context at standard pricing democratizes large-codebase analysis. Memory freshness reasoning improves long-running session quality.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-11 -- v2.1.73: modelOverrides, Bedrock/Vertex default Opus 4.6
- **What**: Added `modelOverrides` setting to map model picker entries to custom provider model IDs (e.g., Bedrock inference profiles). Bedrock/Vertex/Foundry now default to Opus 4.6 (was 4.1). Deprecated `/output-style` in favor of `/config`.
- **Significance**: modelOverrides unlocks enterprise custom model routing without forking configuration.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-07 -- v2.1.71: /loop command, cron scheduling
- **What**: Added `/loop` command for recurring prompts/slash commands on intervals (e.g., `/loop 5m check deploy`). Added cron scheduling tools for session-scoped recurring tasks. Voice keybinding `voice:pushToTalk` now rebindable.
- **Significance**: /loop and cron bring autonomous monitoring to Claude Code -- agents can self-schedule health checks, deployments, and maintenance tasks.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-05 -- v2.1.69: /claude-api skill, voice expansion, agent improvements
- **What**: Added `/claude-api` skill for building Claude API applications. Voice STT expanded to 20 languages (added Russian, Polish, Turkish, Dutch, Ukrainian, Greek, Czech, Danish, Swedish, Norwegian). Added `initialPrompt` agent frontmatter. Added `${CLAUDE_SKILL_DIR}` variable. Added `InstructionsLoaded` hook. Added `sandbox.enableWeakerNetworkIsolation` for Go TLS on macOS. Added `includeGitInstructions` setting toggle. MCP `git-subdir` plugin source. MCP server deduplication. SECURITY: Fixed nested skill discovery loading from gitignored directories.
- **Significance**: 20-language voice support and /claude-api skill signal expansion beyond English-speaking developer markets. InstructionsLoaded hook enables dynamic context injection.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-03-04 -- v2.1.68: Opus 4.6 default effort, model deprecations
- **What**: Opus 4.6 default effort set to medium for Max/Team. "Ultrathink" keyword re-introduced for high effort on next turn. Opus 4.0 and 4.1 removed from first-party API with auto-migration to 4.6.
- **Significance**: Opus 4.0/4.1 deprecation forces migration. Medium default effort balances speed and quality for most tasks.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-02-28 -- v2.1.63: HTTP hooks, /simplify, /batch, memory fixes
- **What**: Added HTTP hooks (POST JSON to URL instead of shell commands). Added `/simplify` and `/batch` commands. Auto memory shared across Git worktrees. Added `ENABLE_CLAUDEAI_MCP_SERVERS=false` opt-out. Extensive memory leak fixes (11+ separate leak patches).
- **Significance**: HTTP hooks are a major architectural change -- enterprise systems can now receive hook notifications via HTTP instead of local shell execution, enabling cloud-native CI/CD integration.
- **Source**: https://code.claude.com/docs/en/changelog

### 2026-02-06 -- Agent Teams (Swarm Mode) shipped with Opus 4.6
- **What**: Claude Code agent teams officially enabled alongside Opus 4.6 release. Transforms Claude Code from single-agent to multi-agent orchestration: a lead agent plans and delegates to specialist agents (frontend, backend, testing, docs, architecture) working in parallel via independent Git worktrees.
- **Significance**: Multi-agent coding is now a first-class feature, not experimental. Each agent gets a fresh context window, shares a task board with dependencies, and coordinates via inter-agent @mentions.
- **Source**: https://techcrunch.com/2026/02/05/anthropic-releases-opus-4-6-with-new-agent-teams/

### 2026-02-06 -- February 2026 Feature Bundle
- **What**: Remote control (access live Claude Code sessions from browser/mobile), scheduled tasks (automate recurring workflows), plugin ecosystem (standardized skills and MCP integrations), auto memory (persistent project knowledge).
- **Significance**: Moves Claude Code from a dev tool to a full autonomous engineering platform.
- **Source**: https://www.nagarro.com/en/blog/claude-code-feb-2026-update-analysis

### 2025-08-01 -- Claude for Chrome Extension
- **What**: Google Chrome extension allowing Claude Code to directly control the browser.
- **Significance**: Extends Claude Code's reach beyond terminal into browser-based workflows.
- **Source**: https://siliconangle.com/2026/03/23/anthropics-claude-gets-computer-use-capabilities-preview/

## Technical Details

### Hooks System (as of v2.1.90)
Hooks guarantee execution of shell commands (or HTTP endpoints) regardless of model behavior. Available hook events:
- **PreToolUse**: Runs before any tool call; can block (exit 2), allow, or **defer** (pause for later resumption)
- **PostToolUse**: Runs after tool execution; receives absolute file_path for Write/Edit/Read tools
- **Stop**: Fires when the agent completes
- **StopFailure**: Fires when turn ends due to API error (v2.1.78)
- **SessionStart/SessionEnd**: Lifecycle hooks
- **UserPromptSubmit**: Pre-processes user input
- **PermissionDenied**: Fires after auto mode classifier denials; supports `{retry: true}` (v2.1.89)
- **TaskCreated**: Fires when task created via TaskCreate (v2.1.84)
- **CwdChanged**: Fires on working directory change (v2.1.83)
- **FileChanged**: Fires on file system changes (v2.1.83)
- **InstructionsLoaded**: Fires when CLAUDE.md or rules loaded (v2.1.69)
- **Elicitation/ElicitationResult**: Intercept MCP elicitation requests (v2.1.76)
- **PostCompact**: Fires after context compaction (v2.1.76)
- **WorktreeCreate**: Supports `type: "http"` with worktreePath output (v2.1.84)

**Conditional hooks** (v2.1.85): Hooks accept an `if` field using permission rule syntax (e.g., `Bash(git *)`) so they only fire for matching tool calls.

**HTTP hooks** (v2.1.63): POST JSON to URL endpoint instead of running shell commands -- enables cloud-native integrations.

### MCP Integration (as of v2.1.90)
- 300+ MCP integrations available
- **Elicitation** (v2.1.76): MCP servers can pause and request structured user input mid-task
- **RFC 9728** (v2.1.85): Protected Resource Metadata discovery for OAuth
- **CIMD/SEP-991** (v2.1.85): Client ID Metadata Document support
- **Nonblocking connections** (v2.1.89): `MCP_CONNECTION_NONBLOCKING=true` for pipe mode
- **Server deduplication** (v2.1.84): Local config wins when same server configured locally and via claude.ai
- **Tool description cap** (v2.1.84): 2KB max per tool description
- **Environment variables** (v2.1.85): `CLAUDE_CODE_MCP_SERVER_NAME` and `CLAUDE_CODE_MCP_SERVER_URL` for helper scripts
- **git-subdir source** (v2.1.69): Point to subdirectory within git repo for plugin source

### CLI Features (as of v2.1.90)
- `/powerup` -- interactive lessons with animated demos (v2.1.90)
- `/loop` -- recurring prompts on interval (v2.1.71)
- `/effort` -- set model effort level Low/Medium/High (v2.1.76)
- `/branch` (formerly `/fork`) -- branch conversation (v2.1.78)
- `/context` -- actionable context optimization tips (v2.1.74)
- `/color` -- prompt-bar color customization (v2.1.75)
- `/plan` -- optional description argument (v2.1.72)
- `/copy N` -- copy Nth-latest response (v2.1.72)
- `/simplify`, `/batch` -- bundled commands (v2.1.63)
- `/claude-api` -- skill for building Claude API apps (v2.1.69)
- `--bare` -- minimal scripted mode, no hooks/LSP/plugins (v2.1.81)
- `--channels` -- MCP servers push messages into session (v2.1.80)
- `-n`/`--name` -- session naming (v2.1.76)
- `--console` -- Anthropic Console (API billing) auth (v2.1.79)
- Transcript search with `/` in Ctrl+O mode (v2.1.83)
- Cron scheduling tools within sessions (v2.1.71)

### Model Support (as of v2.1.90)
- **Opus 4.6**: Default model, 1M context, 64k default / 128k max output tokens, medium default effort
- **Sonnet 4.6**: 1M context at standard pricing (no beta header)
- **Opus 4.0/4.1**: Removed from first-party API (auto-migrated to 4.6)
- **Sonnet 4.5 1M beta**: Retiring April 30, 2026 -- migrate to Sonnet 4.6
- **modelOverrides** setting: Map picker entries to custom Bedrock/Vertex/Foundry model IDs
- **"Ultrathink"** keyword: Enables high effort for next turn
- Voice STT: 20 languages supported

### IDE Integration (as of v2.1.90)
- **VS Code**: Rate limit warning banner, spark icon for sessions, native MCP management (`/mcp`), plan preview, AI-generated session titles, remote-control bridge, stats screenshot
- **JetBrains**: equivalent integration
- **Browser**: Chrome extension for web automation
- **Deep links**: `claude-cli://` with 5,000 char limit, preferred terminal detection

### Agent Capabilities (as of v2.1.90)
- **Agent Teams**: Multi-agent with independent Git worktrees, task board, @mention coordination
- **Named subagents**: Appear in `@` typeahead (v2.1.89)
- **initialPrompt**: Agents auto-submit first turn (v2.1.83)
- **model: frontmatter**: Per-agent model selection (v2.1.84)
- **effort: frontmatter**: Per-skill effort override (v2.1.80)
- **maxTurns, disallowedTools**: Plugin agent frontmatter (v2.1.78)
- **Background agents**: Killable with partial result preservation (v2.1.76)
- **Auto memory**: Persistent project knowledge with freshness reasoning (v2.1.75)
- **Cowork Dispatch**: Multi-agent message delivery (v2.1.87 fix)

### Security and Sandbox (as of v2.1.90)
- `sandbox.failIfUnavailable`: Exit on missing sandbox (v2.1.83)
- `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB=1`: Strip credentials from subprocesses (v2.1.83)
- `sandbox.enableWeakerNetworkIsolation`: Allow Go TLS on macOS (v2.1.69)
- `allowRead`: Re-allow reads within denyRead regions (v2.1.77)
- DNS cache privacy: Removed auto-allow for DnsClientCache commands (v2.1.90)
- Protected directories: `.husky` added (v2.1.90)
- Fixed: Nested skill discovery from gitignored directories (v2.1.69)
- Fixed: Silent sandbox disable when dependencies missing (v2.1.78)

### Performance Highlights (March-April 2026)
- SSE transport: linear-time frame handling (was quadratic) (v2.1.90)
- SDK transcript writes: no longer quadratic in long sessions (v2.1.90)
- Startup memory: ~80MB reduction for 250k-file repos (v2.1.80), ~18MB general (v2.1.79)
- macOS startup: ~60ms faster via parallel keychain reads (v2.1.77)
- `--resume`: up to 45% faster, 100-150MB less memory on large sessions (v2.1.77)
- Prompt cache: improved hit rates for Bedrock/Vertex/Foundry (v2.1.84, v2.1.86)
- Bundle size: reduced ~510KB (v2.1.72)

### Version History (March-April 2026)
| Version | Date | Headline |
|---------|------|----------|
| 2.1.90 | Apr 1 | /powerup, SSE linear-time, PowerShell hardening |
| 2.1.89 | Apr 1 | Defer hooks, PermissionDenied hook, named subagents |
| 2.1.87 | Mar 29 | Cowork Dispatch fix |
| 2.1.86 | Mar 27 | Session ID header, VCS exclusions, skill description cap |
| 2.1.85 | Mar 26 | Conditional hooks, RFC 9728, MCP env vars |
| 2.1.84 | Mar 26 | PowerShell tool, TaskCreated hook, MCP dedup |
| 2.1.83 | Mar 25 | Managed settings.d/, CwdChanged/FileChanged hooks, transcript search |
| 2.1.81 | Mar 20 | --bare flag, --channels relay |
| 2.1.80 | Mar 19 | Rate limit statusline, skill effort, channels preview |
| 2.1.79 | Mar 18 | --console auth, turn duration toggle |
| 2.1.78 | Mar 17 | StopFailure hook, line-by-line streaming, /branch |
| 2.1.77 | Mar 17 | Opus 64k/128k output tokens, allowRead sandbox |
| 2.1.76 | Mar 14 | MCP Elicitation, session naming, /effort, PostCompact |
| 2.1.75 | Mar 13 | 1M Opus context at standard pricing, /color, memory timestamps |
| 2.1.74 | Mar 12 | /context suggestions, autoMemoryDirectory |
| 2.1.73 | Mar 11 | modelOverrides, Bedrock/Vertex default Opus 4.6 |
| 2.1.72 | Mar 10 | /plan description, ExitWorktree, simplified effort |
| 2.1.71 | Mar 7 | /loop command, cron scheduling |
| 2.1.70 | Mar 6 | VSCode spark icon, /color reset |
| 2.1.69 | Mar 5 | /claude-api skill, 20 voice languages, initialPrompt |
| 2.1.68 | Mar 4 | Opus 4.6 medium effort default, Opus 4.0/4.1 removal |
| 2.1.63 | Feb 28 | HTTP hooks, /simplify, /batch, 11 memory leak fixes |

## Comparison Notes

Google's equivalent is the Agent Development Kit (ADK) combined with Gemini Code Assist. Key differences:
- Claude Code is CLI-first; Gemini Code Assist is IDE-first
- Claude Code's agent teams use Git worktrees for isolation; Google ADK uses a different orchestration model
- MCP integration is deeper in Claude Code's ecosystem vs Google's broader Vertex AI agent framework
- Claude Code's hook system (15+ event types, conditional firing, HTTP hooks, defer/resume) is significantly more mature than Google's agent lifecycle callbacks
- Claude Code's 4% GitHub commit share indicates significantly higher developer adoption than competitors as of early 2026
- MCP Elicitation (structured mid-task user input) has no direct equivalent in Google's A2A or ADK
