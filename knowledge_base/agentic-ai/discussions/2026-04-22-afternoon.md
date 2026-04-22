# Innovator / Engineer Discussion — 2026-04-22 Afternoon

## Context

Both vendors broke their freezes on Apr 22 — the morning discussion's MODERATE burst forecast proved correct, arriving same-day. CC v2.1.117 is a major release (25+ changes) with the critical **Opus 4.7 context window fix** (CC was computing against 200K instead of 1M, causing premature autocompacting). Gemini CLI preview channel shipped aggressively (v0.39.0-preview.2) while stable remains frozen.

Key findings from the afternoon analysis:
1. **CC v2.1.117 context window fix** — shadow eval 0.683 NO-GO was measured under broken conditions (S1, P0)
2. **Triple convergence on agent definitions carrying tool dependencies** — CC mcpServers + ADK App/Plugin + Deep Research MCP (S3)
3. **Event compaction convergence** — ADK sliding window + CC autocompaction, both solving long-session context management (S2/Phase 5)
4. **Gemini CLI preview unified subagent tool** — `invoke_subagent` consolidation validates our single-dispatch Phase 5 design (S2/S3)

Shadow eval status: per-test logging implemented (commit 79c98c7), prefix match implemented (commit 6e70617). #49562: OPEN. Factory queue at ~10 items remaining (3 cleared this cycle).

Strategic priorities: S1 (self-improvement), S2 (multi-agent orchestration), S3 (platform generalization).

---

## Round 1

### INNOVATOR

**Proposal 1.1: Shadow Eval Re-Run Protocol After CC v2.1.117 Upgrade (S1)**

This is the highest-impact finding today. The shadow eval NO-GO (0.683, CI [0.535, 0.814]) was measured on a CC version that computed Opus 4.7's context window against 200K instead of 1M. Twelve of 39 tests failed — but we now know those failures may have been caused by premature autocompacting (a CC bug), not Opus 4.7 model behavior. This is a confound that invalidates the baseline.

Once Jonas upgrades CC to v2.1.117, we need a clean re-run. But a bare re-run isn't enough — we should design the re-run to disambiguate. The per-test logging (commit 79c98c7) captures granular results. If we also capture context usage metrics during the re-run (how full the context window gets per test, whether autocompacting fires), we can attribute each failure to either:
- (a) CC bug (failure disappears on v2.1.117 = was caused by premature compaction)
- (b) Opus 4.7 model behavior (failure persists = adaptive thinking cost issue from #49562)
- (c) Both (failure changes character but doesn't fully resolve)

Concrete proposal: Add a `context_diagnostics` flag to `daily_shadow_eval.sh` that, when set, logs `/context` output before and after each test. This gives us context window utilization data to correlate with pass/fail. The upgrade + re-run + context diagnostics produces a clean dataset that either gives us a GO (if most failures were CC-caused) or a well-characterized NO-GO (with per-failure attribution).

Implementation: ~20 minutes. Modifying `daily_shadow_eval.sh` to optionally capture `/context` snapshots per test.

**Proposal 1.2: Phase 5 Context Management Design Section — ADK Event Compaction Pattern (S2)**

The afternoon analysis identifies a convergence that the morning discussion missed: ADK Java 1.0's event compaction (sliding window + summarization for long sessions) and CC's autocompaction solve the same fundamental problem — long-running agent sessions exhaust context windows. The solutions differ:

| Approach | Mechanism | Trigger | Predictability |
|----------|-----------|---------|---------------|
| ADK proactive | Summarize older events, keep window | Before hitting limit | High — no surprise truncation |
| CC reactive | Autocompact when context fills | At the limit | Low — truncation timing unpredictable |
| Hybrid | Proactive for orchestrator state, reactive for sub-agent interactions | Threshold-based | Medium |

Our Phase 5 sprint-orchestrator will run multi-hour sessions coordinating sub-agents. The Phase 5 design currently has no context management section. If we don't address this, the orchestrator will hit CC's reactive autocompaction unpredictably, potentially losing task state mid-sprint.

Concrete proposal: Add a "Context Management Strategy" section to the Phase 5 design index (or create one if the index doesn't exist yet). Contents: (1) the ADK vs. CC comparison table, (2) recommendation for hybrid approach (proactive for orchestrator task list and progress tracking, reactive for sub-agent interaction detail), (3) design constraint that orchestrator must checkpoint critical state before context pressure triggers compaction. This feeds the May 22-26 Design Freeze.

~15 minutes. Documentation only, zero implementation.

**Proposal 1.3: Declarative mcpServers Adoption for Agent Fleet (S1/S3)**

CC v2.1.117 introduces `mcpServers` in agent frontmatter — agents can now declare their MCP server dependencies directly in the `.md` file. Currently, our MCP configuration lives globally in `.mcp.json`. This means all agents see all MCP servers, whether they need them or not.

Moving MCP declarations into agent frontmatter would:
- Make each agent self-contained (what it does + what tools it needs, in one file)
- Enable per-agent MCP server sets (the researcher doesn't need the eval runner's MCP tools)
- Align with the S3 format convergence finding (ADK Java does this with App/Plugin declarations)
- Reduce the attack surface per agent (an agent can't accidentally invoke tools it shouldn't have)

Concrete proposal: Audit the 16 agents in the fleet manifest to determine which ones actually use MCP servers. For the 2-3 that do (if any — most use built-in tools), add `mcpServers` to their frontmatter. For the rest, document that they don't require MCP. This establishes the pattern and produces a concrete data point for the S3 format comparison study.

~30 minutes for the audit + any frontmatter changes.

### ENGINEER

**Response to 1.1 (Shadow Eval Re-Run Protocol):**

The diagnosis is correct — the 0.683 baseline is contaminated by the CC context window bug, and we need a clean re-run. But I have reservations about the `context_diagnostics` flag.

Problem 1: `/context` is a Claude Code CLI interactive command. In a scripted `claude -p` session (which is how `daily_shadow_eval.sh` runs), you can't interleave `/context` queries between eval test runs without restructuring the eval runner. The eval runner (`run_eval_async.py`) submits prompts via the API — it doesn't have access to the CC session's internal context state.

Problem 2: Even if we could capture context utilization, the attribution logic is simpler than proposed. If a test that failed at 0.683 now passes on v2.1.117, the failure was CC-caused. If it still fails, it's model behavior. We don't need context window telemetry to make that determination — the before/after comparison does it. The per-test logging (commit 79c98c7) already gives us granular pass/fail per test. Compare old per-test results to new per-test results: any test that flips from FAIL to PASS was a CC victim.

Counter-proposal: Skip the `context_diagnostics` flag entirely. After Jonas upgrades to v2.1.117, re-run the shadow eval using the existing infrastructure (prefix match + per-test logging). Compare per-test results to the 0.683 baseline. If the aggregate score improves significantly (e.g., above 0.85), the CC bug was the dominant factor. If it doesn't, #49562 is the problem and we wait for the model fix. The existing tooling is sufficient.

**Verdict on 1.1: ADOPT as simplified re-run protocol (P1, 10 min)**. Document the expected re-run procedure and comparison methodology. No new `context_diagnostics` flag — existing per-test logging already provides the needed data. Actual re-run is blocked on Jonas upgrading CC.

**Response to 1.2 (Phase 5 Context Management):**

Good catch — the morning discussion didn't cover this convergence, and it's a legitimate Phase 5 design gap. The comparison table is clear and the hybrid recommendation makes sense for our use case.

One concern: does the Phase 5 design index exist yet? The morning discussion adopted A3 (Phase 5 design index, P3, 20 min) but it was item #7 in the factory queue — it may not have been created yet. If the index doesn't exist, this proposal is adding a section to a non-existent document.

Counter-proposal: If the Phase 5 design index exists, add the context management section there. If it doesn't, create a standalone `knowledge_base/agentic-ai/evaluations/event-compaction-convergence.md` — a convergence analysis document like the existing `workflow-state-convergence.md`. When the Phase 5 design index is eventually created, it references this document. This avoids blocking on the index creation.

**Verdict on 1.2: ADOPT (P2, 15 min)**. Add to Phase 5 design index if it exists; otherwise create as standalone convergence analysis. Feeds Design Freeze.

**Response to 1.3 (Declarative mcpServers):**

I appreciate the S3 alignment argument, but let's check the premise: how many of our 16 agents actually use MCP servers? Looking at the agent definitions, the vast majority use built-in tools (Read, Write, Bash, Grep, Glob, Agent, WebSearch, WebFetch). MCP servers in our pipeline are configured for external integrations — not core agent operations.

If the audit reveals that 0-2 agents use MCP, then this proposal produces an audit document confirming "our agents don't depend on MCP servers" — which is valid S3 data, but the frontmatter changes would be empty declarations. If 3+ agents use MCP, then the frontmatter migration has real value.

More importantly: v2.1.117 just shipped today. The `mcpServers` frontmatter feature hasn't been validated in production by anyone. Adopting it immediately in our 16-agent fleet risks hitting undocumented edge cases in a brand-new feature. The safe move is to wait 1-2 CC releases for bug fixes, then evaluate.

Counter-proposal: Do the audit (which agents use MCP?) as a one-paragraph note in the S3 format comparison study. Defer the actual frontmatter migration until `mcpServers` has stabilized (1-2 CC releases, ~1 week). This produces the S3 data point without the adoption risk.

**Verdict on 1.3: DEFER**. Audit as part of S3 format study (minimal effort). Defer frontmatter migration until mcpServers feature stabilizes (~1 week post v2.1.117).

---

## Round 2

### INNOVATOR

**Proposal 2.1: Forked Subagent Isolation Test for Factory-Steward (S2)**

CC v2.1.117 enables `CLAUDE_CODE_FORK_SUBAGENT=1` on external builds. This gives sub-agents process isolation within a single session. Our factory-steward currently runs a linear sequence: read research analysis → triage ADOPT items → implement each one → commit. If the implementation of item #3 pollutes the context with code from items #1-2, later items may suffer from context interference.

Forked subagents could help: the steward dispatches each ADOPT item to an isolated subagent, preventing cross-item context pollution. This is directly relevant to S2 — it's a real-world test of a multi-agent isolation pattern within our own pipeline.

Concrete proposal: Run a single factory-steward session with `CLAUDE_CODE_FORK_SUBAGENT=1` set in the environment. Compare throughput (items/session) and output quality against recent sessions without the flag. This is a controlled experiment using our existing pipeline — exactly the kind of original research S2 calls for.

~10 minutes to set up. The session itself runs during the next scheduled factory cycle.

**Proposal 2.2: Gemini CLI Channel Selection Note (S3, Operational)**

The afternoon analysis flags a real decision point: when Jonas installs Gemini CLI, should we use stable (v0.38.2, missing unified subagent) or preview (v0.39.0, has unified subagent but may be unstable)? The analysis notes this but doesn't recommend.

For S3 format comparison work, we need the unified `invoke_subagent` tool — that's where the subagent invocation convergence signal lives. Stable doesn't have it. But running S3 experiments on an unstable preview build means any weird behavior could be a bug, not a platform difference.

Concrete proposal: Add a one-paragraph recommendation to the Gemini CLI install action item: "Install stable (v0.38.2) for baseline S3 work. Install preview alongside if available, for subagent feature comparison. Run any S3 eval twice (stable + preview) to separate platform features from preview bugs." This prevents the channel choice from becoming a blocker when Jonas eventually acts on the install.

~5 minutes. Documentation only.

**Proposal 2.3: OTEL Effort Attribute Integration Plan (S1)**

v2.1.117 adds an `effort` attribute to OTEL cost/token events. This is a new signal dimension — we can track whether adaptive thinking effort correlates with eval failures. If high-effort tests fail more often on Opus 4.7, that narrows the #49562 issue to the adaptive thinking subsystem specifically.

But the analysis correctly flags this as low priority until the basic shadow eval re-run is complete. The re-run determines whether the CC bug was the dominant issue. If most failures recover after the upgrade, OTEL effort tracking is less urgent. If failures persist, effort correlation becomes the next diagnostic step.

Concrete proposal: Create a ~5-line design note in the shadow eval documentation: "After initial v2.1.117 re-run, if failures persist, integrate OTEL effort attribute as a secondary diagnostic. Track effort level per test and correlate with pass/fail. This narrows failure attribution to adaptive thinking vs. other Opus 4.7 behavioral changes." This queues the work without doing it prematurely.

~5 minutes. Documentation only.

### ENGINEER

**Response to 2.1 (Forked Subagent Isolation Test):**

I like the experimental instinct — testing a new CC feature using our own pipeline as the testbed is exactly the kind of original research S2 needs. But the experimental design has gaps.

Problem 1: `CLAUDE_CODE_FORK_SUBAGENT=1` is documented as an env var for "external builds." Our factory-steward runs via `claude -p` with `--allowedTools`. Does the forked subagent flag work in headless mode? The CC changelog doesn't specify. If it only works in interactive sessions, the experiment is DOA.

Problem 2: Measuring "context interference" requires a definition. What's the metric? If item #5 takes longer than item #1, is that context pollution or just a harder item? You'd need matched items (same complexity, same type) across sessions — and we don't have that. Throughput (items/session) is confounded by item difficulty.

Problem 3: Even if it works, n=1 (one session) has no statistical power. You'd need multiple matched sessions to draw conclusions, which means multiple factory cycles dedicated to a feature test. The factory queue has 10 items waiting.

Counter-proposal: Don't run the experiment yet. Instead, add "forked subagent isolation" to the Phase 5 experiment backlog with the methodology gaps noted. When Phase 5 work begins (and we have more structured experiments), run a proper comparison. In the meantime, if Jonas wants to casually test the flag during a manual session, that provides informal signal without burning factory cycles.

**Verdict on 2.1: DEFER**. Promising S2 experiment but methodology needs work. Add to Phase 5 experiment backlog. Don't burn factory cycles on an underpowered n=1 test.

**Response to 2.2 (Gemini CLI Channel Selection):**

This is practical and cheap. The channel choice genuinely affects S3 eval quality, and having the recommendation ready when Jonas acts on the install prevents a wasted decision cycle.

Minor edit: "Install preview alongside if available" assumes Gemini CLI supports parallel channel installs. Verify this is possible (some CLIs overwrite the binary). If parallel install isn't supported, the recommendation changes to "install stable first, switch to preview for specific subagent feature tests."

**Verdict on 2.2: ADOPT (P3, 5 min)**. With a note to verify parallel channel support before recommending dual install.

**Response to 2.3 (OTEL Effort Integration Plan):**

This is well-sequenced — it explicitly depends on the re-run results and doesn't propose premature implementation. A 5-line design note that queues the work conditionally is exactly the right weight.

One concern: where does this note go? "Shadow eval documentation" isn't a specific file. It could go in the shadow eval script header, in a README in the eval directory, or in the ROADMAP. The most natural home is the failure analysis template that was just implemented (commit 79c98c7) — it's already the place where shadow eval diagnostic methodology lives.

**Verdict on 2.3: ADOPT (P3, 5 min)**. Add as a "next diagnostic step" section in the failure analysis template.

---

## Round 3

### INNOVATOR

**Proposal 3.1: Agent Definition Format Comparison Matrix — First S3 Concrete Artifact (S3)**

Today's analysis produced the strongest S3 convergence evidence yet: three independent moves toward self-contained agent definitions in 72 hours (CC mcpServers, ADK App/Plugin, Deep Research MCP config). The analysis provides a comparison table (format, protocol, scope, runtime). But this table lives in an analysis document that will scroll off the radar within days.

The S3 format comparison study has been discussed repeatedly but never started — partly because it's blocked on Gemini CLI install for validation. But the analytical component can proceed on documentation alone. We now have concrete data points from three vendors on how agent definitions carry tool dependencies.

Concrete proposal: Create `knowledge_base/agentic-ai/evaluations/agent-format-comparison.md` — a living comparison matrix of agent definition formats across CC, ADK, and Gemini CLI. Columns: format syntax, tool declaration, permission model, context management, subagent dispatch, state persistence. Rows: CC agents (.md frontmatter), ADK agents (Python/Java config), Gemini CLI skills (YAML). Populate what we know from documentation; mark TBD for what requires Gemini CLI install to validate.

This is the first concrete S3 artifact beyond strategic notes. It gives the research-lead and factory-steward a clear picture of what we know, what we don't, and what's blocked. ~25 minutes.

**Proposal 3.2: CC v2.1.117 Upgrade Impact Checklist (Operational)**

The analysis makes CC upgrade P0 — it blocks clean shadow eval data. But "upgrade CC" has a blast radius that goes beyond shadow eval. Our entire fleet runs on CC. v2.1.117 changes default effort to `high` (was `medium`), adds native bfs/ugrep for Glob/Grep, changes managed-settings enforcement, and fixes multiple MCP behaviors. Any of these could affect our cron agents.

Rather than treating the upgrade as a single action, we should prepare a checklist of what to verify post-upgrade:
1. Shadow eval re-run (the primary goal)
2. Factory-steward session: does default effort `high` change behavior or costs?
3. Researcher sweep: does native bfs/ugrep produce different search results?
4. MCP server startup: does concurrent connection default affect our MCP config?
5. Cron pipeline: do any scripts break with the new CC version?

Concrete proposal: Write a 10-line upgrade verification checklist as a note in `knowledge_base/agentic-ai/evaluations/` or hand it to Jonas directly. This ensures the upgrade doesn't create new problems while fixing the shadow eval issue. ~10 minutes.

### ENGINEER

**Response to 3.1 (Agent Format Comparison Matrix):**

This is the right artifact at the right time. The S3 format study has been "discussed but never started" for three days — the comparison matrix breaks the logjam by producing something concrete from what we already know.

Two scoping concerns:

1. "Living comparison matrix" risks scope creep. Once created, every sweep that mentions agent formats will want to update it. Define the initial scope tightly: CC agent .md frontmatter, ADK Java App/Plugin, Gemini CLI skills. Three rows. Don't add rows for Managed Agents, A2A Agent Cards, or other formats until there's a specific comparison question to answer.

2. Some columns are speculative without hands-on testing. "Permission model" for Gemini CLI skills requires actually using the CLI. Mark these clearly as "documentation-inferred" vs. "validated" — the distinction matters when the research-lead makes decisions based on this matrix.

With those constraints, this is a solid Phase 5.6 Design Freeze input.

**Verdict on 3.1: ADOPT (P2, 25 min)**. Three-row initial scope (CC, ADK Java, Gemini CLI). Mark unvalidated fields. Don't add rows speculatively.

**Response to 3.2 (Upgrade Impact Checklist):**

This is sensible operational hygiene. Major CC version upgrades should be verified, not just applied blindly. The 5-point checklist is well-scoped and addresses real risks (default effort change, native tool replacement, MCP behavior changes).

One edit: item 2 ("does default effort `high` change behavior or costs?") — the changelog says "default effort high for Pro/Max on Opus 4.6/Sonnet 4.6." Our cron agents run via API (`claude -p`), which may use different defaults than interactive Pro/Max sessions. The checklist should note this ambiguity — the effort change may not affect our pipeline at all, depending on how `claude -p` sessions are classified.

Also: this is Jonas-facing output, not a knowledge base document. It should go directly in the discussion summary as a "Human Action Items" note, not as a separate file. One fewer file to track.

**Verdict on 3.2: ADOPT (P2, 10 min)**. As inline content in the discussion summary, not a separate file. Note the effort default ambiguity for `claude -p` sessions.

---

## Summary

### ADOPT

| ID | Proposal | Priority | Effort | Strategic Alignment |
|----|----------|----------|--------|-------------------|
| A1 | Shadow eval re-run protocol — document comparison methodology for v2.1.117 upgrade, per-test before/after analysis. No new `context_diagnostics` flag. | P1 | 10 min | S1 critical path |
| A2 | Phase 5 context management section — ADK event compaction vs. CC autocompaction comparison, hybrid approach recommendation. Standalone doc if index doesn't exist. | P2 | 15 min | S2, Phase 5.6 input |
| A3 | Gemini CLI channel selection note — stable for baseline, preview for subagent features, verify parallel install support | P3 | 5 min | S3, operational |
| A4 | OTEL effort integration plan — conditional next-diagnostic-step in failure analysis template, depends on re-run results | P3 | 5 min | S1, Phase 5 |
| A5 | Agent definition format comparison matrix — 3-row initial scope (CC, ADK Java, Gemini CLI), mark unvalidated fields | P2 | 25 min | S3, Phase 5.6 input |
| A6 | CC v2.1.117 upgrade impact checklist — 5-point verification (shadow eval, effort defaults, native tools, MCP, cron pipeline). Inline in discussion, not separate file. | P2 | 10 min | S1/operational |

### DEFER

| ID | Proposal | Reason |
|----|----------|--------|
| D1 | Forked subagent isolation test for factory-steward | Promising S2 experiment but n=1 with no matched comparison. Methodology gaps (headless mode untested, no complexity control). Add to Phase 5 experiment backlog. |
| D2 | Declarative mcpServers frontmatter migration for agent fleet | v2.1.117 mcpServers is brand new — adopt after 1-2 releases stabilize (~1 week). MCP usage audit proceeds as part of S3 format study (A5). |

### REJECT

None this round. All proposals were either adopted (with scope adjustments) or deferred with clear re-entry conditions.

### CC v2.1.117 Upgrade Impact Checklist (Jonas Action Item)

After upgrading CC to v2.1.117:

1. **Shadow eval re-run** (P0) — run `daily_shadow_eval.sh`, compare per-test results to 0.683 baseline. Prefix match (commit 6e70617) ensures patched variants auto-trigger.
2. **Effort default check** — v2.1.117 sets default effort `high` for Pro/Max on Opus 4.6/Sonnet 4.6. Verify whether `claude -p` sessions inherit this change (they may be classified differently than interactive sessions). Monitor first factory-steward session costs post-upgrade.
3. **Native bfs/ugrep** — Glob/Grep tools now use native implementations on Linux. Run researcher sweep, spot-check that search results are consistent with pre-upgrade.
4. **MCP concurrent connections** — new default for concurrent MCP server connections. Verify our `.mcp.json` servers start correctly.
5. **Cron pipeline smoke test** — run one manual researcher sweep + factory session post-upgrade, verify no script breakage.

### Factory-Steward Priority Queue (updated)

Remaining ~10 items from morning queue + 6 afternoon ADOPTs = ~16 total. At 3 items/session throughput, ~5-6 sessions to clear. Recommended afternoon additions:

| Position | Item | Priority | Effort |
|----------|------|----------|--------|
| Insert at #2 | A1: Shadow eval re-run protocol doc | P1 | 10 min |
| Insert at #5 | A2: Phase 5 context management section | P2 | 15 min |
| Insert at #6 | A5: Agent format comparison matrix | P2 | 25 min |
| Insert at #7 | A6: Upgrade impact checklist (inline in discussion — already done) | P2 | 10 min |
| Append | A3: Gemini CLI channel selection note | P3 | 5 min |
| Append | A4: OTEL effort integration plan note | P3 | 5 min |

### Discussion Quality Notes

- **Volume: 6 ADOPTs, 2 DEFERs, 0 REJECTs.** Both deferred items have clear re-entry conditions (D1: Phase 5 experiment backlog; D2: 1 week post v2.1.117). No outright rejections reflects that afternoon proposals were better calibrated — learning from the morning discussion's 3 rejections.
- **Engineer pushback was substantive on 4 items**: Killed context_diagnostics flag in 1.1 (existing tooling sufficient), deferred mcpServers adoption in 1.3 (too new), killed forked subagent experiment in 2.1 (underpowered methodology), redirected upgrade checklist from file to inline in 3.2.
- **No new research areas.** Consistent with directive guidance.
- **Strategic priorities advanced**: S1 (two ADOPTs — re-run protocol, OTEL plan), S2 (one ADOPT — context management, one DEFER — forked subagents), S3 (two ADOPTs — format matrix, channel selection, one DEFER — mcpServers).

---

*This discussion covers the 2026-04-22 afternoon analysis findings. The factory-steward should prioritize A1 (shadow eval re-run protocol) alongside the morning's A3 (prefix match, already implemented). The format comparison matrix (A5) is the first concrete S3 artifact — it should be created before the next research cycle to establish a living reference. The upgrade checklist (A6) is Jonas-facing and is documented inline above.*
