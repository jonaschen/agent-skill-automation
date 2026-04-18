# Model Releases

**Last updated**: 2026-04-18 (evening)
**Sources**:
- https://platform.claude.com/docs/en/about-claude/models/overview
- https://platform.claude.com/docs/en/release-notes/overview (April 7 entry)
- https://wavespeed.ai/blog/posts/claude-mythos-api-pricing/
- https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/
- https://edition.cnn.com/2026/04/03/tech/anthropic-mythos-ai-cybersecurity
- https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-6
- https://en.wikipedia.org/wiki/Claude_(language_model)
- https://www.anthropic.com/news/claude-opus-4-5
- https://www.cnbc.com/2026/02/17/anthropic-ai-claude-sonnet-4-6-default-free-pro.html
- https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/
- https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/
- https://capybara.com/
- https://wavespeed.ai/blog/posts/claude-mythos-opus-5-leak-what-we-know/
- https://www.rsa.com/resources/blog/zero-trust/claude-mythos-and-capybara-best-practices-for-the-next-evolution-in-ai-powered-cybersecurity-risks/
- https://techcrunch.com/2026/04/07/anthropic-compute-deal-google-broadcom-tpus/
- https://www.the-ai-corner.com/p/anthropic-30b-arr-passed-openai-revenue-2026
- https://siliconcanals.com/sc-w-why-anthropic-is-locking-in-3-5-gigawatts-of-compute-years-before-it-comes-online/

## Overview

Anthropic's Claude model family has progressed through Claude 3 (March 2024), Claude 3.5 (June 2024), Claude 4 (May 2025), Claude 4.5 (October-November 2025), Claude 4.6 (February 2026), and Claude 4.7 (April 2026). The current flagship models are Opus 4.7 (1M context, 128K output, $5/$25 per MTok) and Sonnet 4.6 (1M context, 64K output, $3/$15 per MTok). Mythos remains a gated research preview for defensive cybersecurity (Project Glasswing).

## Key Developments (reverse chronological)

### 2026-04-18 (night) -- CORRECTION: Haiku 3 Retires April 20 (Not April 19); Opus 4.7 Bug Landscape Unchanged
- **What**: **DATE CORRECTION**: Official [model deprecations table](https://platform.claude.com/docs/en/about-claude/model-deprecations) shows `claude-3-haiku-20240307` retirement date as **April 20, 2026** (not April 19 as previously tracked). The Feb 19 release notes announcement said "April 19" but the table — which is the maintained authoritative source — says April 20. Likely explanation: model disabled at midnight UTC April 20 (= end of day April 19 US time). `deprecated_models.json` updated from `2026-04-19` to `2026-04-20`. No new Opus 4.7 bug reports since evening sweep. No new Claude Code releases (v2.1.114 remains latest). Token burn rate issue (#49562) still without Anthropic response.
- **Significance**: The 1-day correction has minimal practical impact — our guard triggers safely before the actual cutoff. All other Opus 4.7 findings from the evening sweep remain current. The pipeline is safe for programmatic `claude -p` invocations on Opus 4.7 with v2.1.113+.
- **Source**: https://platform.claude.com/docs/en/about-claude/model-deprecations

### 2026-04-18 (evening) -- Opus 4.7 Day 3: Post-Launch Bug Landscape Mapped; Haiku 3 Retires TOMORROW; Token Burn Reports Emerging
- **What**: Opus 4.7 day 3 status (launched April 16). **Community bug reports mapped across GitHub Issues**: (1) **Bedrock `thinking.type.enabled` error** (#49238) — RESOLVED in v2.1.113. The `anthropic_beta` field was sent in request body but Bedrock only accepts it as HTTP header. Fix deployed to all AWS regions. Additional fix in v2.1.113 for Application Inference Profile ARN detection. (2) **Token burn rate regression** (#49562) — users report ~1% of monthly quota per basic prompt on Opus 4.7, vs. hours of usage on v2.1.69/Opus 4.6. Likely caused by Opus 4.7's new tokenizer (1.0-1.35× more tokens) combined with default effort raised to `high`. No Anthropic response yet. 3 related issues tracked (#49356, #49541, #41771). (3) **Quality regression reports** (#49725, #49214, #49244) — multiple users report Opus 4.7 "doesn't think hard, ignores instructions." Auto-tagged as `needs-repro`. Related issue #49555 requests forcing extended thinking. These may be symptoms of adaptive thinking defaulting to omitted display. (4) **`claude-code-action` v1.0.97 compatibility** (#1225) — Claude Code Action failing with Opus 4.7. (5) **LiteLLM integration** (#25877) — `thinking.type.enabled` error in third-party proxy. (6) **Billing concerns** — GitHub Copilot users report models they never selected appearing in billing at 7.5× rate. **Impact on `claude -p` programmatic invocations**: No specific `claude -p` mode bugs reported. The Bedrock fix (v2.1.113) was the closest — it affected API-level `anthropic_beta` handling, not CLI-specific logic. The token burn reports are surface-agnostic (affect both interactive and programmatic). **Haiku 3 retirement status**: Retires tomorrow (April 19). `deprecated_models.json` guard verified. The `claude-code-security-review` project (#69) had a documented silent failure from hardcoded Haiku 3.5 references — fix merged. Pattern: hardcoded model IDs cause silent feature degradation on retirement.
- **Significance**: **(1) No `claude -p`-specific bugs found** — our pipeline's programmatic invocations appear safe on Opus 4.7 with v2.1.113+. The main risk was the Bedrock `thinking.type.enabled` error, now resolved. **(2) Token burn rate reports need monitoring** — if the 1.35× tokenizer overhead is confirmed, our steward agent sessions will consume ~35% more tokens. Combined with default effort `high` (up from `medium`), total token burn could be 2-3× higher. This directly impacts the factory-steward's cost per session. **(3) Quality regression reports are low-quality** (no repro steps, no specific examples) but the pattern of "model doesn't think as hard" aligns with Opus 4.7's documented behavioral change of "fewer subagents by default" and thinking content omitted by default. Fix: set `display: "summarized"` to restore thinking visibility, and use explicit effort levels. **(4) Haiku 3 retirement in <24 hours** — final guard check passed.
- **Source**: https://github.com/anthropics/claude-code/issues/49238, https://github.com/anthropics/claude-code/issues/49725, https://github.com/anthropics/claude-code/issues/49562, https://github.com/anthropics/claude-code-action/issues/1225, https://github.com/anthropics/claude-code-security-review/issues/69

### 2026-04-18 -- Opus 4.7 Day 2 Stabilization: Extended Benchmarks Confirmed; Breaking Changes Documented; Deprecation Timeline Clarified
- **What**: Opus 4.7 (`claude-opus-4-7`) day 2 since launch. **Extended benchmark scorecard confirmed across multiple sources**: SWE-bench Verified **87.6%**, SWE-bench Pro **64.3%** (vs GPT-5.4's 57.7%), Terminal-Bench 2.0 **69.4%**, OSWorld-Verified **78.0%**, CursorBench **70%**, MCP-Atlas **77.3%** (multi-tool orchestration), XBOW visual acuity **98.5%** (vs 54.5% for 4.6). Described as first Claude model passing "implicit-need tests" — tasks requiring inference about which tools/actions are needed without explicit instruction. **14% resolution improvement** over Opus 4.6 on complex multi-step workflows, with fewer tokens used and 1/3 the tool errors. **Full breaking changes vs Opus 4.6 (Messages API only)**: (1) `thinking: {type: "enabled", budget_tokens: N}` → 400 error (use `{type: "adaptive"}` + effort instead). (2) `temperature`/`top_p`/`top_k` at non-default → 400 error (must omit entirely). (3) Thinking content omitted by default (set `display: "summarized"` to restore). (4) New tokenizer: 1.0–1.35× more tokens for same content. **Task Budgets** in public beta (`task-budgets-2026-03-13`). **Behavioral changes**: more literal instruction following, response length calibrates to task complexity, fewer tool calls by default (prefers reasoning), more direct/opinionated tone, fewer subagents spawned by default. **Memory improvement**: better at file-system-based scratchpads across turns. **Availability**: Claude API, Amazon Bedrock, Google Cloud Vertex AI, Microsoft Foundry; Claude Pro/Max/Team/Enterprise. **Deprecation timeline confirmed**: Sonnet 4 + Opus 4 retire **June 15, 2026** (58 days). Haiku 3 retires **April 19** (tomorrow). 1M beta (Sonnet 4.5/4) ends April 30 (12 days).
- **Significance**: Opus 4.7 is a clear generational upgrade. The key impact for our pipeline: **(1) Upgrade urgency → P0**: The breaking changes (sampling parameters, thinking budgets, tokenizer) mean upgrading is not a drop-in replacement — it requires migration work. However, the quality improvements (87.6% SWE-bench, 14% resolution lift, 1/3 tool errors) make this the strongest model for our pipeline. **(2) "Fewer subagents by default"** — our steward agents rely on subagent spawning; we need to test Opus 4.7 on steward sessions and add explicit delegation prompting if needed. **(3) Tokenizer 1.35× worst case** — our eval suite token budgets, compaction triggers, and prompt caching strategies need headroom increases. Run eval suite on 4.7 to baseline. **(4) Task Budgets** — evaluate for steward sessions to prevent runaway consumption. **(5) Memory improvement** — our steward agents use file-based scratchpads; 4.7 should improve their note-taking and cross-turn recall. **(6) Haiku 3 retires TOMORROW** — verify our `deprecated_models.json` guard is live and correct.
- **Source**: https://www.anthropic.com/news/claude-opus-4-7, https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7, https://platform.claude.com/docs/en/release-notes/overview, https://officechai.com/ai/ckaude-opus-4-7-benchmarks/, https://aws.amazon.com/about-aws/whats-new/2026/04/claude-opus-4.7-amazon-bedrock/

### 2026-04-17 -- Claude Opus 4.7 Launched April 16: Full Benchmark Disclosure + Pricing Held Flat at $5/$25 MTok
- **What**: Claude Opus 4.7 (`claude-opus-4-7`) launched April 16, 2026. Full benchmark disclosure from the launch announcement: **SWE-bench Pro 64.3**, **SWE-bench Verified 87.6**, **Terminal-Bench 2.0 69.4**, **OSWorld-Verified 78.0** — described by Anthropic as "a step-change improvement in agentic coding over Claude Opus 4.6." **Pricing unchanged at $5/$25 per million input/output tokens** (same as Opus 4.6), keeping the Opus-to-Sonnet cost multiplier at 1.67× rather than a larger premium — notable pricing strategy: Anthropic chose not to raise Opus pricing despite the quality improvements. **New "xhigh" effort level** introduced alongside 4.7 (between `high` and `max`) — finer-grained effort control on the most capable tier. **Claude Code v2.1.111 ships Opus 4.7 support** with the `/effort` interactive slider for selecting effort level. **Current official lineup** as of April 17: Haiku 4.5 ($1/$5, 200K ctx, 64K output), Sonnet 4.6 ($3/$15, 1M ctx, 64K output), Opus 4.7 ($5/$25, 1M ctx, 128K output). **Tool support on 4.7**: Programmatic Tool Calling (`code_execution_20260120`), Computer Use (`computer_20251124` with zoom + 2576-px long edge + 1:1 coordinates), all standard advanced tool features (Tool Search, Tool Use Examples, fine-grained streaming). **Adaptive thinking** available on 4.7 (as on 4.6). **Models API** `/models` endpoint exposes 4.7 capabilities programmatically.
- **Significance**: **(1) Pricing held flat** is the most strategically notable fact — Anthropic is absorbing the capability improvement rather than monetizing it. Implies they see competitive pressure on price/quality and want to stay ahead of OpenAI/Google frontier pricing. For our budget: upgrading steward agents to 4.7 costs nothing vs. 4.6. **(2) 87.6 on SWE-bench Verified + 69.4 on Terminal-Bench 2.0** makes 4.7 the new recommended default for our `meta-agent-factory`, `autoresearch-optimizer`, and all `*-steward` agents — coding and terminal performance is directly on our critical path. **(3) `xhigh` effort level** gives us a new tuning knob for our harder eval prompts (tests 23–39 and 40–44 in our test set) — try `xhigh` before `max` to see if it closes the gap on hallucination/false-positive cases without full `max` cost. **(4) 128K output window** (vs 64K on Sonnet) matters for our optimizer — SKILL.md + full rewrite proposals comfortably fit. **(5) Updated `eval/deprecated_models.json`** should already have 4.7 recognized; no new deprecation announcements from the launch. **Action for pipeline**: bump default model for all orchestration agents (meta-agent-factory, autoresearch-optimizer, steward agents) from `claude-opus-4-6` → `claude-opus-4-7` in `.claude/agents/*.md` frontmatter. Validate with a shadow eval run before full cutover.
- **Source**: https://benchlm.ai/blog/posts/claude-api-pricing, https://platform.claude.com/docs/en/about-claude/models/overview, https://code.claude.com/docs/en/changelog (v2.1.111)

### 2026-04-16 -- No New Model Releases; Haiku 3 Retires in 3 Days; Mythos Benchmark Details Confirmed; Claude Sonnet 4 + Opus 4 Retiring June 15
- **What**: No new model releases since April 12. Critical updates: **(1) Haiku 3 retirement in 3 days** — `claude-3-haiku-20240307` retires **April 19, 2026**. Migrate to `claude-haiku-4-5-20251001`. Deprecation guard in `eval/deprecated_models.json` verified present. **(2) NEW deprecation confirmed — Claude Sonnet 4 and Opus 4** — official models page now carries a warning: `claude-sonnet-4-20250514` and `claude-opus-4-20250514` are deprecated and will be **retired June 15, 2026**. Migration: Sonnet 4 → Sonnet 4.6; Opus 4 → Opus 4.6. Both are available in Bedrock (same model IDs) and Vertex (same IDs). Added to `eval/deprecated_models.json`. **(3) Mythos Preview benchmark details confirmed**: `claude-mythos-preview-2026-03-01` (via `red.anthropic.com`) shows: **93.9% SWE-bench Verified** (vs 80.8% Opus 4.6), **97.6% USAMO 2026** (vs 42.3% Opus 4.6), **79.6% OSWorld** (vs Opus 4.6 baseline). Described as "a new general-purpose language model that performs strongly across the board, but is strikingly capable at computer security tasks." Anthropic confirms it is NOT a security-specialized model — it's a frontier general model. Access remains invitation-only under Project Glasswing for defensive cybersecurity workflows; 11 organizations onboarded. No public API sign-up. **(4) Current official lineup unchanged**: Opus 4.6 ($5/$25 MTok, 1M ctx, 128K output), Sonnet 4.6 ($3/$15 MTok, 1M ctx, 64K output), Haiku 4.5 ($1/$5 MTok, 200K ctx, 64K output). 1M context beta for Sonnet 4.5/4 ends **April 30** (14 days). **(5) Adaptive thinking**: available on Opus 4.6 and Sonnet 4.6 only (not Haiku 4.5). **(6) Models API**: programmatic capability/token-limit queries available via `/models` endpoint.
- **Significance**: The **Claude Sonnet 4 + Opus 4 June 15 retirement** is a new actionable deprecation — any system still using these must migrate in 60 days. Our `eval/deprecated_models.json` has been updated with these entries. The **Mythos benchmark metrics** confirm a genuine step-change: +13pp SWE-bench (93.9% vs 80.8%), +55pp USAMO (97.6% vs 42.3%) — this is Opus 4.6's successor, not a variant. When Mythos becomes publicly available, it will significantly exceed our current Opus 4.6 benchmark baselines. For our pipeline: (1) Verify no systems use `claude-sonnet-4-20250514` or `claude-opus-4-20250514` — migrate before June 15. (2) Haiku 3 retirement in 3 days — final check. (3) When Mythos becomes available, evaluate as replacement for Opus 4.6 in factory/optimizer agents.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview, https://red.anthropic.com/2026/mythos-preview/, https://wavespeed.ai/blog/posts/what-is-claude-mythos-preview/

### 2026-04-12 -- No New Model Releases; Official Model Table Confirmed; Haiku 3 Retirement in 7 Days; 1M Beta in 18 Days
- **What**: (1) **No new model releases**. Current lineup confirmed from official docs: **Opus 4.6** (claude-opus-4-6, $5/$25 MTok, 1M context, 128K max output, reliable knowledge cutoff May 2025, training data Aug 2025), **Sonnet 4.6** (claude-sonnet-4-6, $3/$15 MTok, 1M context, 64K max output, reliable knowledge cutoff Aug 2025, training data Jan 2026), **Haiku 4.5** (claude-haiku-4-5-20251001, $1/$5 MTok, 200K context, 64K max output, reliable knowledge cutoff Feb 2025, training data Jul 2025). All support extended thinking; only Opus/Sonnet support adaptive thinking. (2) **Legacy models still available**: Sonnet 4.5, Opus 4.5, Opus 4.1, Sonnet 4, Opus 4. (3) **Batch API extended output**: 300K tokens for Opus 4.6/Sonnet 4.6 via `output-300k-2026-03-24` beta header. (4) **Mythos Preview** remains invitation-only under Project Glasswing — "research preview model for defensive cybersecurity workflows." No self-serve sign-up. (5) **Deprecation countdown**: Haiku 3 (`claude-3-haiku-20240307`) retires **April 19** (7 days). 1M context beta for Sonnet 4.5/4 sunsets **April 30** (18 days). (6) **Deprecation guard status**: `eval/deprecated_models.json` verified — Haiku 3 entry present with April 19 date. No update needed. (7) **Sonnet 4.6 training data cutoff Jan 2026** is notably recent — 3 months ago. This means Sonnet has more current knowledge than Opus (Aug 2025).
- **Significance**: The model lineup is stable. No new model releases expected before Haiku 3 retirement on April 19. The Sonnet 4.6 training data cutoff (Jan 2026, 5 months more recent than Opus) makes it preferable for tasks requiring current knowledge — a factor our pipeline should consider when choosing executor models. The 300K batch output is relevant for bulk code generation in our factory pipeline. For our pipeline: (1) Verify all systems ready for Haiku 3 retirement in 7 days. (2) Consider Sonnet 4.6 for knowledge-sensitive tasks due to more recent training data.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview, https://platform.claude.com/docs/en/about-claude/pricing

### 2026-04-11 -- No New Model Releases; Advisor Tool Redefines Model Economics; Haiku 3 Retirement in 8 Days
- **What**: (1) **No new model releases**. Current lineup unchanged: Opus 4.6, Sonnet 4.6, Haiku 4.5. Mythos Preview remains invitation-only under Project Glasswing. (2) **Advisor Tool reshapes model economics** — launched April 9, the advisor pattern (`advisor-tool-2026-03-01` beta) lets Sonnet 4.6 or Haiku 4.5 consult Opus 4.6 as an advisor mid-generation. This creates a new cost tier: "Sonnet with Opus guidance" — near-Opus intelligence with Sonnet-dominated token costs. The advisor produces only 400-700 text tokens per call while the executor handles all bulk generation. Pricing: advisor tokens billed at Opus rates ($15/$75 per MTok), executor tokens at executor rates (Sonnet: $3/$15, Haiku: $1/$5). For typical coding tasks with 2-3 advisor calls, total cost is ~40-60% of Opus-only. (3) **Deprecation countdown**: Haiku 3 (`claude-3-haiku-20240307`) retires **April 19** (8 days). 1M context beta for Sonnet 4.5/4 sunsets **April 30** (19 days). (4) **Deprecation guard status**: `eval/deprecated_models.json` already contains Haiku 3 entry — no update needed.
- **Significance**: The advisor pattern effectively creates a new "virtual model tier" between Sonnet and Opus without requiring a new model release. This is an economic innovation, not a model innovation — but it changes the competitive landscape since it makes Opus-quality reasoning accessible at lower cost. Our Phase 3 optimizer and Phase 5 topology should evaluate advisor mode for cost optimization.
- **Source**: https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool, https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-10 -- No New Model Releases; Haiku 3 Retirement in 9 Days; Anthropic Expands Google Cloud TPU Deal
- **What**: (1) **No new model releases**. Current lineup unchanged: Opus 4.6, Sonnet 4.6, Haiku 4.5. Mythos Preview remains invitation-only under Project Glasswing for defensive cybersecurity. (2) **Deprecation countdown**: Haiku 3 (`claude-3-haiku-20240307`) retires **April 19** (9 days). 1M context beta (`context-1m-2025-08-07`) for Sonnet 4.5 and Sonnet 4 sunsets **April 30** (20 days). (3) **Anthropic expands Google Cloud/TPU deal** (April 6-7): Anthropic secured expanded compute capacity with Google Cloud and Broadcom for TPU infrastructure amid "skyrocketing demand." Anthropic is locking in 3.5 gigawatts of compute years before it comes online. (4) **Anthropic reportedly passed $30B ARR** (April 2026) — surpassing OpenAI. This massive revenue growth funds continued model development and infrastructure expansion. (5) **300K max_tokens** on Message Batches API remains available via `output-300k-2026-03-24` beta header for Opus 4.6 and Sonnet 4.6. (6) **Messages API on Amazon Bedrock** (research preview, April 7) — same request shape as first-party API, us-east-1, invitation required.
- **Significance**: The compute infrastructure expansion (3.5 GW) and $30B ARR signal Anthropic is preparing for much larger model training runs — likely Mythos or a next-generation model family. The Haiku 3 retirement is now 9 days away — our deprecation guard should flag this. No new models to integrate.
- **Source**: https://techcrunch.com/2026/04/07/anthropic-compute-deal-google-broadcom-tpus/, https://www.the-ai-corner.com/p/anthropic-30b-arr-passed-openai-revenue-2026, https://siliconcanals.com/sc-w-why-anthropic-is-locking-in-3-5-gigawatts-of-compute-years-before-it-comes-online/

### 2026-04-09 -- No New Model Releases; Deprecation Timeline Update: Haiku 3 in 10 Days, 1M Beta in 21 Days
- **What**: No new model releases or announcements. Current deprecation countdown: (1) **Claude Haiku 3** (`claude-3-haiku-20240307`) retires **April 19, 2026** (10 days). Migrate to Haiku 4.5. (2) **1M context beta** (`context-1m-2025-08-07`) for Sonnet 4.5 and Sonnet 4 sunsets **April 30, 2026** (21 days). Requests exceeding 200k tokens on these models will error. Migrate to Sonnet 4.6 or Opus 4.6 (native 1M, no beta header). (3) **Claude Sonnet 3.7** retirement previously scheduled; already retired February 19. Current model lineup: Opus 4.6 (Feb 5), Sonnet 4.6 (Feb 17), Haiku 4.5 (Oct 15, 2025). Mythos Preview remains invitation-only under Project Glasswing. The **300k max_tokens** cap on Message Batches API (via `output-300k-2026-03-24` beta header) for Opus 4.6 and Sonnet 4.6 is now available. The **Managed Agents** platform (launched April 8) can run any of the current models — agent, environment, and model are configured independently.
- **Significance**: The Haiku 3 retirement is imminent — any CI/CD pipelines, eval scripts, or cost-optimized workflows still using `claude-3-haiku-20240307` must migrate within 10 days. The 1M beta sunset is less urgent (21 days) but affects anyone not yet on 4.6 models. No new model releases expected until Mythos reaches broader availability.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview, https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-08 -- Claude Mythos Preview Announced as "Project Glasswing" (Gated Defensive Cybersecurity Preview)
- **What**: On April 7, 2026, Anthropic's platform release notes announced that **Claude Mythos Preview** is available as a gated research preview for defensive cybersecurity work under the name **"Project Glasswing"** (https://anthropic.com/glasswing). Access is invitation-only. This is the first official acknowledgment of Mythos since the March 26 CMS data leak that exposed ~3,000 internal documents including a draft blog post describing Mythos as a "step change" in AI capabilities. Key details: (1) **Capabilities**: Mythos reportedly achieves dramatically higher scores than Opus 4.6 on software coding, academic reasoning, and cybersecurity benchmarks. Anthropic describes it as "the most capable model we've ever developed" with "meaningful advances in reasoning, coding, and cybersecurity." (2) **Pricing tier**: The model sits in the "Capybara" tier, positioned above Opus — Anthropic states it is "very expensive to serve" with no public pricing announced. (3) **Rollout strategy**: Initial access limited to "a small group of early access customers selected by Anthropic" with focus on enterprise security teams. No public waitlist. Broader rollout expected later in 2026, contingent on safety evaluations. (4) **Cybersecurity dual-use**: Anthropic is privately warning top government officials that Mythos "makes large-scale cyberattacks much more likely in 2026" due to agents that can "work on their own with wild sophistication and precision to penetrate corporate, government and municipal systems." The defensive framing of Project Glasswing (seeding security teams first) is Anthropic's response to this dual-use risk. (5) **No confirmed model ID, context window, or API endpoint** as of this date.
- **Significance**: This is Anthropic's most significant model announcement since Opus 4.6 (February 5). The "Capybara" pricing tier above Opus signals a new premium segment. The defensive-cybersecurity-first rollout strategy is unprecedented — no major AI lab has gated a model's general release behind security team evaluation before. For our pipeline: Mythos' cybersecurity capabilities could eventually power a security-focused agent skill. The gated access means no immediate action needed, but we should monitor for API availability. The Capybara tier may also indicate Anthropic's pricing strategy for future frontier models.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview (April 7 entry), https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/, https://edition.cnn.com/2026/04/03/tech/anthropic-mythos-ai-cybersecurity, https://wavespeed.ai/blog/posts/claude-mythos-api-pricing/

### 2026-04-08 -- Haiku 3 Retirement Imminent (April 19); 1M Context Retiring for Sonnet 4.5/4 (April 30)
- **What**: Two upcoming deprecation deadlines confirmed: (1) **Claude Haiku 3** (`claude-3-haiku-20240307`) retires April 19, 2026 — all requests will return errors after that date. Migration target: Claude Haiku 4.5. (2) **1M context window beta** for Claude Sonnet 4.5 and Claude Sonnet 4 ends April 30, 2026 — the `context-1m-2025-08-07` beta header will have no effect after that date. Requests exceeding 200k tokens will return errors. Migration target: Claude Sonnet 4.6 or Opus 4.6, which support 1M context at standard pricing with no beta header. These were previously announced but are now within their execution window.
- **Significance**: Imminent action deadlines. Any systems still using Haiku 3 have 11 days to migrate. Any systems using 1M context on Sonnet 4.5/4 have 22 days to migrate to Sonnet 4.6+. For our pipeline: verify none of our agent configurations reference Haiku 3 or depend on 1M context with older Sonnet models.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-07 -- US Government Blacklists Anthropic; UK Courts Expansion; Geopolitical Context for Model Access

- **What**: Major geopolitical developments affecting Anthropic's model availability and business: (1) **US blacklisting** (April 5): The US government designated Anthropic a national-security supply-chain risk after the company declined to allow military use of Claude for surveillance or autonomous weapons. (2) **Federal court ruling**: A First Amendment ruling blocked the Pentagon's blacklisting. The DOJ immediately appealed to the Ninth Circuit. (3) **GSA restoration** (April 3): The General Services Administration restored Anthropic to federal procurement schedules. (4) **UK courting** (April 5): Britain is attempting to attract Anthropic expansion, with proposals ranging from London office expansion to a dual stock listing. PM Keir Starmer's office supports the effort; CEO Dario Amodei expected to visit in late May 2026. (5) **Market status**: Anthropic described as "the hardest stock to source in our marketplace" with "just no sellers" — demand for shares is near-insatiable. (6) **Vertex AI webinar** (April 7): Anthropic hosted "Ship Code Faster with Claude Code on Vertex AI," reinforcing multi-cloud positioning.
- **Significance**: The blacklisting/restoration cycle creates regulatory uncertainty for US government customers using Claude models. If the Ninth Circuit appeal succeeds, it could restrict federal agencies from using Anthropic's models, pushing them to competitor offerings (OpenAI, Google). UK expansion could create a secondary operational hub outside US jurisdiction. For our pipeline: no immediate impact on model access for non-government users, but worth monitoring for API access policy changes. The dual-listing possibility could affect Anthropic's governance and model access policies long-term.
- **Source**: https://letsdatascience.com/news/us-blacklists-anthropic-as-security-risk-5e0f08ff, https://www.usnews.com/news/top-news/articles/2026-04-05/britain-woos-expansion-effort-by-anthropic-after-us-defence-clash-ft-says, https://techcrunch.com/2026/04/03/anthropic-is-having-a-moment-in-the-private-markets-spacex-could-spoil-the-party/

### 2026-04-07 -- Platform Release Notes Audit: Compaction API, Data Residency, Fast Mode, Automatic Caching

- **What**: Comprehensive audit of Claude Platform release notes confirms several significant features from February 2026 not previously documented in this KB: (1) **Compaction API** (Feb 5, beta) — server-side context summarization for effectively infinite conversations, available on Opus 4.6. Enables long-running agents to maintain coherent conversations without client-side context management. (2) **Data residency controls** (Feb 5) — `inference_geo` parameter allows specifying where model inference runs. US-only inference available at 1.1x pricing for post-Feb-2026 models. (3) **Fast mode** (Feb 7, research preview) — up to 2.5x faster output token generation via `speed` parameter for Opus 4.6. Premium pricing. Waitlist-gated. (4) **Automatic caching** (Feb 19) — single `cache_control` field on request body auto-caches the last cacheable block, moving the cache point forward as conversations grow. Eliminates manual breakpoint management. Available on Claude API and Azure AI Foundry. (5) **Adaptive thinking** (Feb 5) — Opus 4.6 recommends `thinking: {type: "adaptive"}` over manual `budget_tokens`. Effort parameter GA, replaces `budget_tokens` for controlling thinking depth. (6) **Media limit raised** (March 13) — 600 images or PDF pages per request (up from 100) when using 1M context. (7) **Thinking display control** (March 16) — `thinking.display: "omitted"` omits thinking content from responses for faster streaming while preserving signature for multi-turn continuity.
- **Significance**: The Compaction API is critical for our steward agents which run long sessions — it enables server-side context management that could replace manual compaction strategies. Data residency controls matter for compliance-sensitive deployments. Fast mode's 2.5x speedup could significantly reduce our eval iteration time if we can access it. Automatic caching simplifies our API integration — no need to manually manage cache breakpoints. The 600 media limit enables PDF-heavy workflows (legal, research).
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-06 -- Mythos/Capybara: Cybersecurity-First Rollout Strategy, RSA Best Practices, Early Access Status Confirmed

- **What**: Additional details on Claude Mythos/Capybara rollout strategy confirmed from multiple sources: (1) **Cybersecurity-first deployment**: Anthropic is deliberately limiting early access to cybersecurity defense organizations, giving defenders a head start to identify and patch vulnerabilities before broader availability. Internal documents describe Mythos as "currently far ahead of any other AI model in cyber capabilities" for discovering and exploiting vulnerabilities. (2) **RSA published best practices** for organizations preparing for Mythos-class models, framing it as "the next evolution in AI-powered cybersecurity risks." (3) **Early access status confirmed**: as of April 2026, Mythos/Capybara is available only to a select group of vetted early access customers — no public API, no announced pricing, no confirmed release date. Training is complete; staged expansion planned. (4) **Leak origin clarified**: a misconfigured CMS data store exposed ~3,000 unpublished assets; fixed within hours of responsible disclosure. (5) **No specific benchmarks published** — claims of "dramatically higher scores" on coding, reasoning, and cybersecurity remain unverified by third parties. (6) **Polymarket prediction market** tracking release timing, indicating significant public interest/speculation.
- **Significance**: The cybersecurity-first rollout is unprecedented — no major AI lab has previously gated model access by defender-first security considerations. This suggests Mythos's capabilities are genuinely concerning even to Anthropic. The RSA publication signals enterprise security teams are already preparing defensive strategies. For our pipeline: (a) Mythos would likely replace Opus 4.6 as the flagship model for complex agent tasks when available. (b) The Capybara tier pricing will likely be significantly above Opus 4.6's $5/$25 — cost modeling for Phase 7 (AaaS) should account for this. (c) No timeline means our pipeline should not block on Mythos availability.
- **Source**: https://wavespeed.ai/blog/posts/claude-mythos-opus-5-leak-what-we-know/, https://www.rsa.com/resources/blog/zero-trust/claude-mythos-and-capybara-best-practices-for-the-next-evolution-in-ai-powered-cybersecurity-risks/, https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/

### 2026-04-05 -- Leaked Model Codenames: Fenick (Opus), Capra/Capabra (Sonnet), Tangu (Haiku)
- **What**: Following the March 31 Claude Code source leak (59.8MB source map published to npm), additional internal details emerged about Anthropic's model naming conventions: (1) "Fenick" is the internal codename for the Opus model series. (2) "Capra" or "Capabra" is the internal codename for Sonnet. (3) "Tangu" is the internal codename for Haiku. (4) References to "Opus 4.7" and "Sonnet 4.8" found in internal testing configurations, suggesting the next generation is already in development. (5) "Capybara" tier confirmed as the tier name that sits above Opus/Sonnet/Haiku — Mythos is the first model in this tier. (6) 44 hidden feature flags discovered including voice mode, multi-agent coordination enhancements, background sessions, and a `/buddy` feature. Note: Some of this information originated from April 1 posts and should be treated with appropriate skepticism — codenames are confirmed but version numbers and feature flags may be speculative or satirical.
- **Significance**: The codename system (Fenick/Capra/Tangu) provides a way to track unreleased models in future leaks or documentation. The Opus 4.7/Sonnet 4.8 references suggest Anthropic maintains a rapid release cadence even for flagship models. The Capybara tier above Opus confirms Anthropic's intent to create a premium model category — pricing likely above current Opus 4.6 ($5/$25). Background sessions feature flag aligns with the Conway persistent agent platform.
- **Source**: https://medium.com/@mfierce0/the-claude-code-leak-opus-4-7-sonnet-4-8-and-mythos-a-rare-unfiltered-look-inside-anthropic-70c6f735810a, https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/

### 2026-04-04 -- Model Capabilities Comparison Update (newly documented)
- **What**: Updated technical comparison from official models overview: (1) Opus 4.6 supports adaptive thinking (dynamic thinking depth), extended thinking, 1M context, 128K max output. Training data cutoff: Aug 2025. (2) Sonnet 4.6 supports adaptive thinking, extended thinking, 1M context, 64K max output. Training data cutoff: Jan 2026 (newer than Opus). (3) Haiku 4.5 supports extended thinking but NOT adaptive thinking, 200K context, 64K max output. Training data cutoff: Jul 2025. (4) Batch API: Opus 4.6 and Sonnet 4.6 support 300K output with `output-300k-2026-03-24` beta header. (5) Models API (`/v1/models`) now returns `capabilities` object for programmatic capability discovery.
- **Significance**: Notable that Sonnet 4.6 has a newer training data cutoff (Jan 2026) than Opus 4.6 (Aug 2025), meaning Sonnet may have more current knowledge for some topics. The programmable capabilities API enables agents to dynamically select models based on required features.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-04 -- Legacy Model Lineup and Pricing Confirmed
- **What**: Full legacy model pricing confirmed: Sonnet 4.5 ($3/$15), Opus 4.5 ($5/$25), Opus 4.1 ($15/$75), Sonnet 4 ($3/$15), Opus 4 ($15/$75), Haiku 3 ($0.25/$1.25, retiring April 19). All legacy models have 200K context windows. Opus 4.1 and Opus 4 are the most expensive at $15/$75 — 3x the price of current Opus 4.6 ($5/$25) for inferior capabilities.
- **Significance**: The pricing trajectory shows aggressive cost reduction with each generation: Opus went from $15/$75 (4.0/4.1) to $5/$25 (4.5/4.6) — a 67% reduction. This incentivizes migration away from legacy models.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-03 -- Claude Haiku 3 Retirement April 19, 2026
- **What**: Claude Haiku 3 (`claude-3-haiku-20240307`) is scheduled for retirement on April 19, 2026. After that date, all API requests to this model will return an error. Anthropic recommends migrating to Claude Haiku 4.5 ($1/$5 per MTok vs Haiku 3's $0.25/$1.25).
- **Significance**: Organizations still using legacy Haiku 3 have ~16 days to migrate. This is both a capability upgrade and a 4x price increase for input tokens.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2026-04-03 -- 1M Context Beta Retiring for Sonnet 4.5 and Sonnet 4 (April 30)
- **What**: Anthropic is retiring the 1M token context window beta for Claude Sonnet 4.5 and Sonnet 4 on April 30, 2026. The `context-1m-2025-08-07` beta header will have no effect after that date. Users must migrate to Sonnet 4.6 or Opus 4.6 for 1M context at standard pricing.
- **Significance**: Forces migration to 4.6-generation models for long-context workloads. Clear signal Anthropic is consolidating around the 4.6 generation.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 -- Message Batches API Max Output Raised to 300k Tokens
- **What**: `max_tokens` cap raised to 300k on Message Batches API for Opus 4.6 and Sonnet 4.6 via `output-300k-2026-03-24` beta header. 2.3x increase over previous 128k limit.
- **Significance**: Particularly relevant for large-scale code generation and document processing in batch workflows.
- **Source**: https://platform.claude.com/docs/en/release-notes/overview

### 2026-04-03 -- Claude Code Leak Confirms Model Codenames and Capybara Tier
- **What**: The Claude Code source code leak (v2.1.88 npm source map) confirmed internal model codenames: Capybara is a new model tier above Opus ("larger and more intelligent than our Opus models"), Fennec maps to Opus 4.6, and Numbat is an unreleased model still in testing. Capybara is confirmed to be the same model previously leaked as "Mythos." The source also references KAIROS, an autonomous daemon mode feature flag. No official release date for Capybara/Mythos has been announced; it remains available only to a small group of early access customers.
- **Significance**: Confirms the Mythos/Capybara connection and establishes a new tier hierarchy: Haiku < Sonnet < Opus < Capybara. The KAIROS daemon mode suggests Capybara may ship with persistent background agent capabilities as a differentiator.
- **Source**: https://alex000kim.com/posts/2026-03-31-claude-code-source-leak/, https://capybara.com/

### 2026-04-03 -- Claude Mythos (Capybara): Safety Concerns and Government Warnings
- **What**: Anthropic has privately warned senior government officials that Mythos "makes large-scale cyberattacks significantly more likely in 2026." The model is described as "currently far ahead of any other AI model in cyber capabilities." A prior incident is noted: in September 2025, a Chinese state-sponsored group used an earlier Claude model to execute cyberattacks with "80-90% autonomy" across ~30 organizations. Anthropic's planned rollout prioritizes giving cyber defenders early access before broader distribution.
- **Significance**: Represents a new frontier in AI safety concerns for agentic systems. The defender-first rollout strategy may set precedent for how frontier agentic models are released.
- **Source**: https://www.pymnts.com/artificial-intelligence-2/2026/anthropics-unreleased-claude-mythos-might-be-the-most-advanced-ai-model-yet/

### 2026-04-02 -- Deep Dive: Claude 4.6 New Features and Breaking Changes
- **What**: Detailed technical review of all 4.6 launch features, deprecations, and breaking changes from the official "What's New in Claude 4.6" documentation. Key findings below.
- **Adaptive Thinking**: `thinking: {type: "adaptive"}` is the recommended mode. Claude dynamically decides when and how much to think. Old `thinking: {type: "enabled"}` with `budget_tokens` is deprecated. New `max` effort level on Opus 4.6 provides highest capability.
- **Fast Mode (beta)**: `speed: "fast"` delivers up to 2.5x faster output generation for Opus at premium pricing ($30/$150 per MTok). Same model, faster inference. Beta header: `fast-mode-2026-02-01`.
- **Compaction API (beta)**: Server-side context summarization for infinite conversations. Auto-summarizes when context approaches window limit. Available on Opus 4.6.
- **Free Code Execution**: Code execution is free when used with web search or web fetch tools. Dynamic filtering support with `web_search_20260209` / `web_fetch_20260209` tool versions.
- **Tools GA**: Code execution, web fetch, programmatic tool calling, tool search, tool use examples, and memory tool all graduated to general availability.
- **Data Residency**: `inference_geo` parameter supports `"global"` (default) or `"us"`. US-only at 1.1x pricing for models after Feb 1, 2026.
- **Breaking: Prefill Removal**: Prefilling assistant messages not supported on Opus 4.6. Requests return 400 error. Must use structured outputs or system prompts instead.
- **Breaking: Tool Parameter Quoting**: Opus 4.6 may produce different JSON string escaping in tool call arguments. Standard parsers handle it; raw string parsers may break.
- **Deprecation: output_format**: Moved to `output_config.format`. Old parameter still functional but deprecated.
- **Deprecation: interleaved-thinking beta header**: No longer required on Opus 4.6 (adaptive thinking enables it automatically).
- **Significance**: These details are critical for migration planning. The prefill removal is a breaking change that affects many existing agentic workflows.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-6

### 2026-03-26 -- Mythos Model Leaked
- **What**: Data leak revealed existence of "Mythos," a next-generation model in internal testing. Anthropic confirmed it represents a "step change" in capabilities, with internal benchmarks showing superiority to Opus 4.6 on complex coding, long-horizon reasoning, and safety.
- **Significance**: Indicates Anthropic's next major model generation. Speculative timeline: Q3-Q4 2026.
- **Source**: https://fortune.com/2026/03/26/anthropic-says-testing-mythos-powerful-new-ai-model-after-data-leak-reveals-its-existence-step-change-in-capabilities/

### 2026-02-17 -- Claude Sonnet 4.6 Released
- **What**: Released as default model for free and Pro users. Improvements in computer use, coding, design, knowledge work, and large data processing. 1M context window, 64K max output. Pricing: $3/$15 per MTok. Training data cutoff: January 2026. Reliable knowledge cutoff: August 2025.
- **Significance**: Brings 4.6-generation capabilities to the cost-efficient Sonnet tier.
- **Source**: https://www.cnbc.com/2026/02/17/anthropic-ai-claude-sonnet-4-6-default-free-pro.html

### 2026-02-05 -- Claude Opus 4.6 Released
- **What**: Flagship model with 1M token context window (up from 200K), 128K max output. Released alongside agent teams feature and Claude in PowerPoint. Pricing: $5/$25 per MTok (massive price reduction from Opus 4.5's $5/$25 and Opus 4.1's $15/$75). Training data cutoff: August 2025. Reliable knowledge cutoff: May 2025. Supports extended thinking, adaptive thinking, and Priority Tier.
- **Significance**: 5x context window expansion plus agent teams make this the primary agentic model. Batch API supports 300K output with beta header.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-11-24 -- Claude Opus 4.5 Released
- **What**: 200K context, 64K max output. Introduced "Infinite Chats" eliminating context window limit errors. Improvements in coding and spreadsheet tasks. Pricing: $5/$25 per MTok. Knowledge cutoff: May 2025.
- **Significance**: Major step in making Opus more affordable (down from $15/$75 for Opus 4.1).
- **Source**: https://www.anthropic.com/news/claude-opus-4-5

### 2025-10-15 -- Claude Haiku 4.5 Released
- **What**: Fast, cost-effective model. 200K context, 64K max output. Pricing: $1/$5 per MTok. Supports extended thinking and Priority Tier.
- **Significance**: Budget-friendly option for high-volume agent workloads.
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-09-29 -- Claude Sonnet 4.5 Released
- **What**: 200K context, 64K max output. Pricing: $3/$15 per MTok. Training data cutoff: July 2025. First model to support advanced tool use features.
- **Significance**: Introduced advanced tool use (Tool Search, Programmatic Tool Calling, Examples).
- **Source**: https://platform.claude.com/docs/en/about-claude/models/overview

### 2025-08-05 -- Claude Opus 4.1 Released
- **What**: 200K context, 32K max output. Pricing: $15/$75 per MTok. Knowledge cutoff: March 2025.
- **Significance**: Incremental Opus improvement; now categorized as legacy given Opus 4.5/4.6 pricing.
- **Source**: https://en.wikipedia.org/wiki/Claude_(language_model)

### 2025-05-22 -- Claude 4 Released (Opus 4 + Sonnet 4)
- **What**: Fourth generation. Opus 4 classified as "Level 3" safety rating. 200K context. Opus 4: $15/$75 per MTok. Sonnet 4: $3/$15 per MTok.
- **Significance**: Major generation jump with top-tier reasoning, coding, and multilingual capabilities.
- **Source**: https://en.wikipedia.org/wiki/Claude_(language_model)

## Technical Details

### Current Model Lineup (as of April 2026)

| Model | API ID | Context | Max Output | Input $/MTok | Output $/MTok | Knowledge Cutoff |
|-------|--------|---------|------------|-------------|--------------|-----------------|
| Opus 4.6 | claude-opus-4-6 | 1M | 128K | $5 | $25 | May 2025 (reliable) |
| Sonnet 4.6 | claude-sonnet-4-6 | 1M | 64K | $3 | $15 | Aug 2025 (reliable) |
| Haiku 4.5 | claude-haiku-4-5 | 200K | 64K | $1 | $5 | Feb 2025 (reliable) |

### Training Data Cutoffs (vs Reliable Knowledge Cutoffs)

| Model | Reliable Knowledge Cutoff | Training Data Cutoff |
|-------|--------------------------|---------------------|
| Opus 4.6 | May 2025 | August 2025 |
| Sonnet 4.6 | August 2025 | January 2026 |
| Haiku 4.5 | February 2025 | July 2025 |

### Legacy Models (still available)
| Model | API ID | Context | Max Output | Input $/MTok | Output $/MTok |
|-------|--------|---------|------------|-------------|--------------|
| Sonnet 4.5 | claude-sonnet-4-5 | 200K | 64K | $3 | $15 |
| Opus 4.5 | claude-opus-4-5 | 200K | 64K | $5 | $25 |
| Opus 4.1 | claude-opus-4-1 | 200K | 32K | $15 | $75 |
| Sonnet 4 | claude-sonnet-4-0 | 200K | 64K | $3 | $15 |
| Opus 4 | claude-opus-4-0 | 200K | 32K | $15 | $75 |

### Deprecation Notice
- Claude Haiku 3 (claude-3-haiku-20240307) deprecated, retiring April 19, 2026

### Extended Output (Batch API)
- Opus 4.6 and Sonnet 4.6 support up to 300K output tokens via `output-300k-2026-03-24` beta header on Message Batches API

### Fast Mode (Opus 4.6 only, beta)
- Premium pricing: $30/$150 per MTok (6x standard)
- Up to 2.5x faster output token generation
- Same model intelligence, faster inference
- Beta header: `fast-mode-2026-02-01`

### Compaction API (Opus 4.6, beta)
- Server-side context summarization
- Enables effectively infinite conversations
- Auto-triggers when context approaches window limit

### Platform Availability
- Claude API (direct)
- AWS Bedrock (IDs: `anthropic.claude-opus-4-6-v1`, `anthropic.claude-sonnet-4-6`)
- Google Vertex AI (IDs: `claude-opus-4-6`, `claude-sonnet-4-6`)
- Microsoft Azure AI Foundry (Opus 4.6/Sonnet 4.6)

### Key Capability Features (4.6 generation)
- Extended thinking
- Adaptive thinking (recommended; replaces manual budget_tokens)
- Effort parameter GA (low/medium/high/max levels)
- Priority Tier service
- 1M token context window
- Computer use (beta)
- Agent teams / swarm mode
- Data residency controls (inference_geo)
- Free code execution with web tools

### Breaking Changes in 4.6
- **Prefill removal**: Prefilling assistant messages returns 400 on Opus 4.6
- **Tool parameter quoting**: Different JSON escaping in tool call arguments
- **output_format deprecated**: Use `output_config.format` instead

## Comparison Notes

Claude 4.6 vs Gemini 2.5:
- **Context**: Opus 4.6 has 1M tokens; Gemini 2.5 Pro has 1M tokens (parity)
- **Max output**: Opus 4.6 at 128K (300K batch); Gemini 2.5 Pro at 65K
- **Pricing**: Opus 4.6 at $5/$25; Gemini 2.5 Pro at $1.25/$10 (Gemini significantly cheaper)
- **Coding**: Both claim top-tier coding performance; Claude leads on SWE-bench
- **Agentic**: Opus 4.6 has native agent teams; Gemini uses ADK for agent orchestration
- **Safety**: Claude Opus 4 was first to receive Level 3 safety classification
- **Multimodal**: Both support text + image input; Gemini also supports audio/video input natively
