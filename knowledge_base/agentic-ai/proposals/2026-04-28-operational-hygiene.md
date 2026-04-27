# Operational Hygiene Proposals — 2026-04-28

**Date**: 2026-04-28
**Triggered by**: Discussion 2026-04-28 Rounds 2 + 3. Five small-but-high-leverage items adopted with sub-30-minute effort each.
**Owner**: factory-steward (next session)

This document bundles five operational hygiene items from today's discussion. Each is a refinement to an existing artifact (not a net-new file), low blast radius, and high leverage relative to cost.

---

## Item 1 — Task↔Agent Dual-Name Validator Pass (P1)

**Triggered by**: Finding 5 (analysis 2026-04-28) — CC v2.1.63 renamed dispatch tool from `Task` to `Agent` at user-facing level, but Agent SDK still emits `"Task"` in `system:init` payloads and `result.permission_denials[].tool_name`. Both names appear in production today.

**Why P1**: Latent defect. Any code in our pipeline that pattern-matches the dispatch tool name has been silently degraded if it checks only one of `"Task"` / `"Agent"`. Most of our trigger-detection and post-tool-use hooks were written before v2.1.63 — likely against `"Task"` only. The bug masquerades as flakiness because the SDK emits both names in different contexts.

**Action**:
- Grep `eval/`, `scripts/lib/`, `scripts/`, `.claude/hooks/`, `.claude/agents/` for hardcoded `"Task"` or `"Agent"` string literals matching the dispatch tool name pattern
- For each match: update the comparison to `tool_name in ("Task", "Agent")` semantics
- Add one-line test (or comment) at each fix site documenting the dual-name requirement

**Scope** (per discussion Round 2 Engineer):
- `eval/run_eval_async.py`
- `eval/run_eval.sh`
- `scripts/lib/*.sh` (especially `cmd_chain_monitor.sh` if it pattern-matches the tool name)
- `.claude/hooks/post-tool-use.sh`, `pre-deploy.sh`, `stop.sh`

**Effort**: ~10 minutes
**Risk**: LOW — test changes only; fixes a real defect
**Verdict**: ADOPT P1

---

## Item 2 — CC Version Advisory Section in Migration Runbook (P2)

**Triggered by**: Finding 1 (analysis 2026-04-28) — CC v2.1.119 documented + v2.1.120 silent release. Eight community-documented regressions across both. Three new pipeline-relevant Apr 27 issues (#53972, #53973, #53976). Upgrade target shifted from v2.1.118 → v2.1.119, with explicit advice to **avoid v2.1.120** until v2.1.121 ships.

**Why P2**: Prevents Jonas from upgrading to v2.1.120 inadvertently. Today's advisory currently lives only in today's analysis + the directive's human-action-debt section. Surfacing it in the dashboard makes it persistent across sessions.

**Action** (per discussion Round 2 Engineer counter — modify existing artifact, not new JSON file):
- Add `## CC Version Advisory` section to `eval/model_migration_runbook.md` with structured headers:

  ```markdown
  ## CC Version Advisory

  - **Recommended**: 2.1.119
  - **Avoid**: 2.1.120 (eight community regressions, silent release, broken auto-update could strand fleet)
  - **Reason**: v2.1.119 = `PostToolUse.duration_ms` + parallel MCP-server reconfig + `--resume` 67% speedup. v2.1.120 = silent release, `--resume` TypeError crash, auto-update breakage.
  - **Minimum**: 2.1.116 (post-#49562 fix baseline)
  - **Expires**: When 2.1.121 or later ships (likely 2-4 days from 2026-04-28)
  ```

- Update `scripts/agent_review.sh` Model Migration section to surface this advisory:
  ```bash
  echo "## CC Version Advisory"
  grep -A 5 "## CC Version Advisory" eval/model_migration_runbook.md | tail -n 5
  ```

**Effort**: ~10 minutes
**Risk**: LOW — adds documentation + 1 line to dashboard
**Verdict**: ADOPT P2

---

## Item 3 — A2A Misreport Rebuttal Note in KB (P2)

**Triggered by**: Finding 8 (analysis 2026-04-28) — TheNextWeb-origin "A2A v1.2 with signed agent cards" misreport debunked Apr 24, but has now propagated through three independent channels: TheNextWeb, PRNewswire, Stellagent blog. Each new sweep that touches A2A versions burns a 4-search verification round trip.

**Why P2**: Hygiene with compounding return. One 10-minute write saves every future researcher session a verification round trip on A2A versions.

**Action** (per discussion Round 2):
- Add `## Version Verification Notes` section to `knowledge_base/agentic-ai/google-deepmind/a2a-protocol.md` with three short paragraphs:

  ```markdown
  ## Version Verification Notes

  ### Canonical Source
  Always verify A2A version claims against `gh api repos/a2aproject/A2A/tags`.
  As of 2026-04-28, latest tag is **v1.0.0**. The web spec at
  https://a2a-protocol.org/latest/specification/ also serves v1.0.0.

  ### Confirmation History
  - 2026-04-24: Triple-verified at v1.0.0 (GitHub tag, a2a-protocol.org spec,
    spec-content). Signed agent cards documented as v1.0.0 features.
  - 2026-04-28: Confirmed unchanged (no new tag).

  ### Known Misreport Cluster
  TheNextWeb (origin), PRNewswire 150-org anniversary post, Stellagent blog
  have reported "A2A v1.2 with signed agent cards." This is incorrect — v1.2
  has not been released. Signed agent cards are a v1.0.0 feature.
  Discount any "A2A v1.x" claim from non-tag sources until verified at the
  canonical source.
  ```

**Effort**: ~10 minutes (researcher folds into next sweep that touches A2A; or factory-steward writes directly)
**Risk**: LOW — KB documentation only
**Verdict**: ADOPT P2

---

## Item 4 — I/O Sensitivity Registry Update (P2)

**Triggered by**: Discussion Round 3 Proposal 2 — Today's two new architectural primitives (subagent resumability, dispatch primitives) belong in the Phase 5 design index's I/O Sensitivity table. If I/O changes either API, the dependent design notes need review.

**Why P2**: Makes I/O triage mechanical. When ADK v2.0 GA / A2A v1.1 / Gemini 4 lands, the researcher reads the registry to know which design notes need review.

**Action** (per discussion Round 3 Engineer):
- Add 2 rows to the existing I/O Sensitivity table inside Phase 5 design index (factory P1 item #1):

  ```markdown
  | Subagent resumability | agentId in Agent tool result, resume:sessionId, default 30-day cleanup | Phase 5.4 Inspect-Resume section | If I/O changes resume API, Phase 5.4 design needs revision |
  | Dispatch primitive surface | Claude Agent(subagent_type, prompt) + Gemini invoke_subagent(agent, prompt) | Canonical skill schema (S3) | If ADK v2.0 changes dispatch surface, schema needs review |
  ```

**Effort**: ~5 minutes
**Risk**: LOW — registry update only
**Verdict**: ADOPT P2

---

## Item 5 — S2 Paper Anchor Surfacing in Dashboard (P3)

**Triggered by**: Discussion Round 3 Proposal 3 (modified per Engineer's counter) — S2 paper has accumulated five empirical anchors as of today: SPIFFE identity, Agent Memory Bank Memory Profiles, Cloud Next dispatch convergence, Inspect-Resume composition (today), and dispatch-primitive comparison (today). Paper-pipeline trigger gate is "factory queue < 10 items" — but threshold-based dashboard messages flicker; informational surfacing is more durable.

**Why P3**: Makes paper-pipeline run a Jonas decision based on dashboard surfacing, not a buried directive note. No flicker — informational only.

**Action**:
- Create `knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/anchors.md` listing incorporated vs pending empirical anchors:

  ```markdown
  # S2 Paper Empirical Anchors

  ## Pending Incorporation (5)
  - SPIFFE Agent Identity (Cloud Next 2026)
  - Agent Memory Bank Memory Profiles
  - Dispatch convergence (Cloud Next + Apr 28 verdict)
  - Inspect-Resume composition pattern (Apr 28 — novel proposed)
  - Subagent resumability primitive (Apr 28 — Anthropic)

  ## Incorporated
  *(none yet — paper pipeline not yet triggered)*
  ```

- Add informational message to `scripts/agent_review.sh`:
  ```bash
  PENDING_ANCHORS=$(grep -c "^- " knowledge_base/agentic-ai/papers/s2-multi-agent-orchestration/anchors.md 2>/dev/null || echo 0)
  FACTORY_QUEUE_SIZE=$(...) # existing computation
  echo "## S2 Paper Status"
  echo "Pending anchors: $PENDING_ANCHORS"
  echo "Factory queue: $FACTORY_QUEUE_SIZE"
  echo "Consider running scripts/paper_pipeline.sh when queue < 10."
  ```

- Researcher updates `anchors.md` as new anchors accumulate (one line per new empirical finding)

**Effort**: ~20 minutes (dashboard line + initial anchors file)
**Risk**: LOW — informational only
**Verdict**: ADOPT P3

---

## Net Queue Impact

- **New factory items**: 0 (all 5 are refinements to existing artifacts or single-file additions to documentation)
- **Existing items refined**: 4 (Phase 5 design index P1 #1, model migration runbook, a2a-protocol.md, agent_review.sh)
- **New files created**: 1 (`papers/s2-multi-agent-orchestration/anchors.md` — minimal index file)
- **Total effort**: ~55 minutes factory-steward time

All 5 items can be processed in a single factory session.
