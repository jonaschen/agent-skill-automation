# Agentic AI Sweep Report — 2026-04-28 (Afternoon, both tracks)

**Cycle**: Afternoon (US-morning announcement window)
**Prior sweeps today**: `2026-04-28.md` (Anthropic, night→morning) and `2026-04-28-google.md` (Google, morning).
**Posture**: stabilization continues. Afternoon catches up on the v2.1.119/.120 community fallout window and verifies no new releases shipped from either vendor during the US morning.

## Executive Summary

- **Eight regressions filed Apr 24 against CC v2.1.119/v2.1.120** (community gist, yurukusa). Rollback recommendation to **v2.1.117**. New issues continue to land Apr 27 (#53972 OTel parent-span loss, #53973 Opus 4.7 ignores project constraints, #53976 `/login` & `/mcp` modal freeze in `--resume`). **Material revision to morning's upgrade guidance**: morning suggested "upgrade to v2.1.119 (documented) over v2.1.120 (silent)"; this afternoon's evidence elevates v2.1.117 as the safer pin until v2.1.121 ships.
- **No new releases from either vendor in the US-morning window.** Latest: CC v2.1.120 (Apr 24, day 4 silent), SDK Py v0.1.68, SDK TS v0.2.119, ADK v2.0.0b1/v1.31.1 (day 6/7), gemini-cli latest tag is `v0.41.0-nightly.20260427` (Apr 27).
- **#49562 unchanged**: 2 comments, last update Apr 19 — confirmed via `gh api`. Day 12. Per directive's day-10 rule it is now P2 watch-only — verbatim status only.
- **`#53972` is the highest-impact new bug for our pipeline**: subprocess `claude -p` does not inherit the active OTel span; manual `OTEL_TRACEPARENT` injection required. Directly affects the cron-driven pipeline if/when we wire OTEL traces across the researcher → research-lead → factory-steward chain.
- **No new I/O signals.** T-21 days. Pre-I/O signal window opens ~May 2-4.

## Anthropic Updates

### Claude Code

- **No new releases** in the US-morning window. CC tags via `gh api` (top 5): v2.1.120, v2.1.119, v2.1.118, v2.1.117, v2.1.116. v2.1.120 is day 4 silent (no GitHub Release, no CHANGELOG entry). The latest GitHub Release is v2.1.119.
- **Eight community-documented regressions on v2.1.119/v2.1.120** (gist published Apr 24, content reviewed Apr 28):

  | # | Issue | Description | Workaround |
  |---|-------|-------------|------------|
  | 1 | #53044, #53041 | `claude --resume` crashes with `TypeError` at startup on v2.1.120 | Roll back to v2.1.117 |
  | 2 | #53031 | Silent routing of `claude-opus-4-7` (200k) to the 1M-context variant without notice | Verify with `/status` after `/model` |
  | 3 | #53038 | Terminal resize causes UI duplication; regression of prior fix #49086 | `Ctrl+L` after resize, or pin v2.1.117 |
  | 4 | #53028 | Auto-update mechanism stopped functioning silently | Manual `claude update` |
  | 5 | #53035 | `/mcp` menu freezes when using `--resume` in WSL2 | Don't use `--resume` if MCP needed |
  | 6 | #53040 | `CLAUDE.md` loaded but model ignores it despite low context usage | Re-read or paste content |
  | 7 | #53012 | `sandbox.excludedCommands` doesn't bypass network enforcement on macOS | Run outside sandbox or proxy-aware tools |
  | 8 | #53015 | Worktree creation hangs on macOS 26.4; git merge blocks indefinitely | Avoid worktree flows |

  Source: https://gist.github.com/yurukusa/a866b4cd2976486156a00c190c39cef6

- **Three new bugs filed Apr 27** (afternoon directly impactful for our fleet):
  - **#53976** — `/login` and `/mcp` auth modals freeze inside `--resume` sessions on v2.1.119 (macOS, Ghostty, with/without tmux). Same family as gist #5 (#53035). Force-quit is the only escape. Source: https://github.com/anthropics/claude-code/issues/53976
  - **#53972** — `claude` subprocess does not inherit active OTel span as parent. Requires manual `OTEL_TRACEPARENT` injection across `subprocess.Popen` boundaries. **Directly relevant to our cron pipeline**: if we instrument `daily_research_sweep.sh → daily_research_lead.sh → daily_factory_steward.sh` with OTEL, traces will be unparented unless we forward `traceparent`. Source: https://github.com/anthropics/claude-code/issues/53972
  - **#53973** — `Claude 4.7 ignores established project constraints and over-generates code/docs` despite low context usage. Model-behavior bug, possibly a sibling of #49562 family (postmortem-resolved harness issues fixed by Apr 20, but new behavioral complaints continue to land). Source: https://github.com/anthropics/claude-code/issues/53973
- **Material revision to morning's upgrade recommendation**: morning sweep recommended v2.1.119 over v2.1.120 (since v2.1.120 has no release notes). Afternoon evidence shows v2.1.120 is **actively breaking** (`--resume` crash). For our fleet, the safer pin is now: **v2.1.117** if cautious (no v2.1.119/.120 regressions present); **v2.1.119** if Jonas wants the documented `PostToolUse.duration_ms` and parallel MCP-server reconfig wins (most v2.1.119 regressions are present in v2.1.120 too — only the `--resume` crash and broken auto-update are v2.1.120-specific). **The cron pipeline does not use `--resume`**, so v2.1.119 is workable; v2.1.120 risks broken auto-update masking the fact that we're stuck.

### Agent SDK

- **No new releases.** Latest: Py **v0.1.68** (Apr 25, bundles CC v2.1.119), TS **v0.2.119** (Apr 23, paired with CC v2.1.119). Verified via `gh api repos/anthropics/claude-agent-sdk-{python,typescript}/releases`.
- v0.1.67 (Apr 25) trio fix already covered in morning sweep. v0.1.68 (Apr 25) is a CLI-bundle bump.
- **WebSearch surfaced a "skills parameter on `ClaudeAgentOptions`" claim** — verified against the v0.1.64–v0.1.68 release bodies and **not present**. The WebSearch summary appears to have stitched in older Claude Sonnet 4.5 SDK content (skills launched there). Not a new April finding. Don't carry this forward.

### Model Releases

- **#49562**: state=open, comments=2, last update 2026-04-19T14:19:26Z. **Unchanged from morning sweep.** Day 12. P2 watch-only per directive.
- No new model releases. Postmortem-related work all closed by Apr 20 (v2.1.116). `eval/deprecated_models.json` unchanged.

### MCP

- One sentence: spec unchanged at 2025-11-25. No CVEs. **`/mcp` modal freeze in `--resume`** (issues #53035, #53976) is a CC-side UI bug, not a protocol issue.

### Tool Use / Computer Use / Multi-agent

- One sentence each. No GA/announcement changes. Subagent resumability (morning finding) holds.

### Service & Operations (informational)

- No new incidents on `status.claude.com` in the US-morning window beyond the Apr 27 Claude downtime spike already noted in morning sweep.

## Google/DeepMind Updates

### Gemini CLI

- One paragraph: latest tag **`v0.41.0-nightly.20260427.g42587de73`** (Apr 27, present in morning sweep). No new tag in the US-morning window. Stable channel still v0.39.1; preview still v0.40.0-preview.4. v0.40.0 stable still pending. Web changelog (`geminicli.com/docs/changelogs/`) still 4 days behind the tag stream.

### ADK

- One sentence: tags unchanged — top 5 still `v2.0.0b1` (Apr 22), `v2.0.0a3`, `v2.0.0a2`, `v2.0.0a1`, `v1.31.1` (Apr 21). No v1.32.0 / v2.0.0b2 in the Apr 27–May 1 expected window yet (today is day 1 of that window).

### A2A

- One sentence: spec at v1.0.0, day 47. No new tags. Misreport hygiene unchanged from morning.

### Vertex AI / Gemini Enterprise / Mariner / Astra / Gemma

- One sentence each. No platform-level entries since the Apr 22-24 Cloud Next batch (re-verified). Mariner, Astra, Gemma 4 steady. I/O T-21d, no new pre-I/O session signals.

### Google I/O 2026 (T-21d)

- One sentence: published session lists still do not name ADK / A2A / Mariner / Astra / Gemma 4 in titles. "Firebase Agents" and "Adaptive Everywhere" themes hold. No new pre-I/O blog posts.

## Day Counts (afternoon snapshot — 2026-04-28)

| Item | Version/ID | Days Since | Status |
|------|-----------|------------|--------|
| CC documented latest | v2.1.119 | 5 (Apr 23) | Stable + 7 regressions filed |
| CC silent npm | v2.1.120 | 4 (Apr 24) | Undocumented + 2 v2.1.120-only regressions |
| SDK Py latest | v0.1.68 | 3 (Apr 25) | Stable |
| SDK TS latest | v0.2.119 | 5 (Apr 23) | Stable |
| Opus 4.7 | claude-opus-4-7 | 12 (Apr 16) | GA — postmortem closed |
| #49562 | — | 12 (opened Apr 16) | OPEN, 2 comments, last Apr 19 — P2 |
| ADK pre-release | v2.0.0b1 | 6 (Apr 22) | Stable in beta channel |
| ADK stable | v1.31.1 | 7 (Apr 21) | Stable |
| Gemini CLI stable | v0.39.1 | 4 (Apr 24) | Patch on stable line |
| Gemini CLI v0.40.x preview | preview.4 | 3 (Apr 25) | No stable promo yet |
| Gemini CLI v0.41 nightly | nightly.20260427 | 1 (Apr 27) | Active |
| A2A spec | v1.0.0 | 47 (Mar 12) | Steady |
| Google I/O | May 19-20 | T-21 | Monitoring |
| Sonnet 4 + Opus 4 retirement | June 15 | T-48 | Deprecated |

## Implications for Our Pipeline

- **Upgrade-target revision**: based on afternoon evidence, the recommended Jonas upgrade target is **v2.1.119** (not v2.1.120). v2.1.120 carries two pipeline-relevant breakages: the `claude --resume` `TypeError` crash and silently broken auto-update. Our cron scripts do not use `--resume`, but a broken auto-update on a long-running install will silently strand the fleet at v2.1.120.
- **#53972 (OTel parent-span loss) is a pipeline-relevant bug to track**: if we ever wire OTEL across the researcher → research-lead → factory-steward chain, traces will be disconnected unless we forward `traceparent` on subprocess invocation. Worth a one-line note on the factory queue: "If/when we instrument the cron chain with OTEL, ensure `OTEL_TRACEPARENT` propagates across `claude -p` subprocess calls (CC #53972)." Defer until OTEL wiring is actually scheduled.
- **#53973 ("Claude 4.7 ignores project constraints")** is unrelated to #49562's harness-regression family (which is closed) but worth tracking as a potential model-behavior signal. Single-data-point complaint at this stage; do not act on.
- Shadow eval, Gemini CLI install: unchanged, one-sentence status.
- **No factory queue churn from this sweep.** The eight regressions are external observations; they don't add ADOPT items because (a) we're not affected by `--resume` crashes (cron doesn't use it), (b) v2.1.117 is already what the fleet runs, and (c) the OTel item is conditional on OTEL wiring that isn't on the queue.

## Gap Analysis

| Our Phase | Industry State | Gap | Priority |
|-----------|----------------|-----|----------|
| S1 — observability | CC has `PostToolUse.duration_ms` (v2.1.119); OTel parent-span lost on subprocess (#53972) | We don't capture per-tool timing yet; if we add OTEL, must forward `traceparent` | P2 (post-CC-upgrade work; #53972 is a tracking item) |
| Pipeline upgrade safety | v2.1.120 silent + breaking `--resume` + broken auto-update | Recommended pin shifts from v2.1.120 → v2.1.119 (or v2.1.117 if cautious) | P0 (advisory to Jonas) |
| S3 dispatch portability | Comparison delivered this morning | Implementation gated on Gemini CLI install (day 7+) | Closed (analysis), implementation gated |
| Phase 5 watchdog | Subagent resumability documented (this morning's finding) | Phase 5 design predates this primitive | P2 (factory design note) |

## Skill Proposals Generated

None this cycle. Afternoon is a confirmation/refinement pass on the morning sweep, not a generation pass.

## Actions Taken

- Verified Anthropic + Google release state via `gh api` (no new tags or releases since morning sweep).
- Verified #49562 status via `gh api` (unchanged: 2 comments, last update Apr 19).
- Read CC v2.1.119/.120 community regressions gist (yurukusa) and three new Apr 27 issues (#53972, #53973, #53976). Findings recorded above.
- Updated `claude-code.md` with the eight-regression community summary and the three new Apr 27 issues.
- Updated `INDEX.md` with this afternoon sweep entry and bumped the "Last sweep" header.
- Did NOT re-touch `agent-sdk.md`, `model-releases.md`, or any Google KB file (no new content to append beyond morning).
- Did NOT modify ROADMAP.md (per Action Safety rules).
- Did NOT update `eval/deprecated_models.json` (no new deprecation announcements).
- Did NOT generate any factory queue items (per directive's net-new ADOPT discipline; afternoon sweep is confirmation).

## Next Sweep Focus

- Watch for **CC v2.1.121** (would address the eight community regressions; cadence ~daily during active development).
- Watch for **CC v2.1.120 release notes** (still undocumented at day 4).
- Watch for **ADK v1.32.0 / v2.0.0b2** (expected Apr 27-May 1).
- Watch for **gemini-cli v0.40.0 stable** (preview.4 is day 3).
- Continue one-sentence-per-topic discipline on Mariner, Astra, Gemma, Computer Use.
- Pre-I/O signal window opens ~May 2-4.

## Continuity Notes (afternoon, carry-forward)

| Tracking item | Status this sweep | Next check |
|----------------|-------------------|------------|
| CC v2.1.119/.120 community regressions | NEW context — 8 regressions documented Apr 24, 3 new bugs filed Apr 27 | watch for v2.1.121 |
| CC v2.1.120 silent release | day 4, still undocumented | next sweep |
| #53972 OTel parent-span loss | NEW Apr 27 — relevant to S1 if we add OTEL | tracking item only, do not queue |
| #49562 | day 12, unchanged | one-sentence P2 only |
| Subagent resumability | morning finding holds | factory design note for Phase 5 |
| ADK v1.32.0 / v2.0.0b2 | not yet shipped (window day 1) | next sweep |
| gemini-cli v0.40.0 stable | not yet shipped | next sweep |
| Web changelog lag (geminicli.com) | 4 days behind tags | watch for catch-up at v0.40 stable |
| A2A "v1.2" misreport recurrence | ongoing search-result artifact | discount on sight |
| Shadow eval | blocked on CC upgrade | one-sentence only |
| Gemini CLI install | blocked, day 7+ | one-sentence only |
| MCP spec | unchanged at 2025-11-25 | one-sentence only |
| 1M context beta sunset | non-issue (per directive) | do not mention |
| Cloud Next coverage | closed | I/O T-21 monitoring |
