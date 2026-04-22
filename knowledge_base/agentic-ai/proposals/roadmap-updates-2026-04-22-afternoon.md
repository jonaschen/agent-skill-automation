# ROADMAP Update Recommendations — 2026-04-22 Afternoon

**Source**: Analysis 2026-04-22-afternoon + Discussion 2026-04-22-afternoon
**Directive compliance**: Single-cycle, no new research areas

---

## Change 1: Update ROADMAP Status Line

**Location**: ROADMAP.md line 4 (status line)
**Priority**: P1
**Action**: Update status to reflect afternoon state:

```
Status as of 2026-04-22 (afternoon): Phase 4 core complete. CC v2.1.117 context window fix (200K→1M) means shadow eval 0.683 NO-GO was measured under broken conditions — re-run needed post-upgrade. Shadow eval prefix match implemented (commit 6e70617). Triple convergence on self-contained agent definitions (CC mcpServers + ADK App/Plugin + Deep Research MCP). Factory queue: ~16 items (~5-6 sessions). 8/10 DEPLOYED (80%), 0.95 uniform trigger rate. Eval suite at 59 tests (T=39, V=20). Countdowns: Google I/O 27d (May 19-20). Phase 4 core complete.
```

---

## Change 2: Shadow Eval Re-Run Protocol (Discussion A1)

**Location**: `eval/model_migration_runbook.md` — new section after "Shadow Eval Results Checklist"
**Priority**: P1 (S1 critical path)
**Effort**: 10 min
**Action**: Add "CC v2.1.117 Re-Run Protocol" section:

```markdown
### CC v2.1.117 Re-Run Protocol

**Context**: Shadow eval NO-GO (0.683, CI [0.535, 0.814]) was measured on CC version
that computed Opus 4.7 context window against 200K instead of 1M. Premature
autocompacting may have caused some failures. v2.1.117 fixes this.

**Procedure**:
1. Upgrade CC to v2.1.117
2. Run `daily_shadow_eval.sh` (prefix match ensures automatic detection)
3. Per-test logging (commit 79c98c7) captures granular results
4. Compare per-test results to 0.683 baseline

**Attribution**:
- Test flips FAIL→PASS: CC context window bug caused this failure
- Test remains FAIL: Opus 4.7 model behavior (likely #49562 adaptive thinking)
- Test changes character: both factors contributing

**Decision**:
- If aggregate improves significantly (>0.85): CC bug was dominant. Re-assess GO/NO-GO.
- If aggregate remains below 0.80: #49562 is the primary issue. Wait for model fix.

**Note**: No `context_diagnostics` flag needed — before/after per-test comparison
is sufficient for attribution. Existing tooling provides all needed data.
```

**Rationale**: The CC context window bug creates a confound that invalidates the baseline. The re-run protocol provides a mechanistic decision path. Engineer correctly eliminated the proposed `context_diagnostics` flag as unnecessary overhead.

---

## Change 3: Phase 5 Context Management Strategy (Discussion A2)

**Location**: Phase 5 design index if it exists; otherwise standalone `knowledge_base/agentic-ai/evaluations/event-compaction-convergence.md`
**Priority**: P2
**Effort**: 15 min
**Action**: Create convergence analysis document:

```markdown
# Event Compaction Convergence — Context Management for Long Agent Sessions

## Two-Vendor Convergence

| Approach | Mechanism | Trigger | Predictability |
|----------|-----------|---------|---------------|
| ADK Java proactive | Summarize older events, sliding window | Before hitting limit | High |
| CC reactive | Autocompact when context fills | At the limit | Low |
| Hybrid (recommended) | Proactive for orchestrator state, reactive for sub-agent detail | Threshold-based | Medium |

## Phase 5 Recommendation

The sprint-orchestrator should use a hybrid approach:
- **Proactive compaction**: Summarize completed tasks, maintain compact state snapshot
  of sprint progress, blockers, and completed items
- **Reactive compaction**: Let CC handle sub-agent interaction detail (conversation
  history with worker agents)
- **Design constraint**: Orchestrator MUST checkpoint critical state (task list,
  assignment map, progress %) before context pressure triggers compaction

## Pattern References
- ADK Java 1.0: Event compaction via sliding window + summarization
- CC v2.1.117: Context window fix (200K→1M) + existing autocompaction
- Both are responses to: long-running agent sessions exhaust context windows
```

**Rationale**: Phase 5 sprint-orchestrator will run multi-hour sessions. Without a context management strategy, it will hit CC's reactive autocompaction unpredictably, potentially losing task state mid-sprint.

---

## Change 4: Agent Definition Format Comparison Matrix (Discussion A5)

**Location**: `knowledge_base/agentic-ai/evaluations/agent-format-comparison.md`
**Priority**: P2 (first concrete S3 artifact)
**Effort**: 25 min
**Action**: Create 3-row comparison matrix:

| Dimension | CC Agents (.md) | ADK Java (App/Plugin) | Gemini CLI (Skills) |
|-----------|----------------|----------------------|---------------------|
| Format syntax | YAML frontmatter in Markdown | Java annotations/config | YAML (TBD - unvalidated) |
| Tool declaration | `tools:` list + new `mcpServers:` | Tool class constructors | `tools:` list (TBD) |
| Permission model | `permissions.allow`/`.deny` in settings | App-level capability grants | Context-aware approvals (TBD) |
| Context management | Autocompaction (reactive) | Event compaction (proactive) | Unknown (TBD) |
| Subagent dispatch | `Agent(prompt, subagent_type)` | ADK agent delegation | `invoke_subagent(config)` (preview) |
| State persistence | File system + git | ADK SessionService | `/memory inbox` (preview) |
| MCP integration | STDIO/SSE, now frontmatter `mcpServers` | Not native (plugin tools instead) | Deep Research: remote HTTP |

**Scope constraints** (per Engineer):
- Three rows only (CC, ADK Java, Gemini CLI). No A2A Agent Cards, Managed Agents, etc. until a specific comparison question requires them.
- Mark unvalidated fields clearly as "TBD - documentation-inferred" vs. "validated".
- Initial creation only — updates tied to specific research questions, not every sweep.

**Rationale**: S3 format study discussed repeatedly but never started. The triple convergence on self-contained agent definitions (72h window) provides concrete data. This breaks the logjam by producing something tangible from what we know.

---

## Change 5: OTEL Effort Integration Plan (Discussion A4)

**Location**: `eval/model_migration_runbook.md` — append to "Shadow Eval Failure Analysis" section
**Priority**: P3
**Effort**: 5 min
**Action**: Add "Next Diagnostic Step" subsection:

```markdown
#### Next Diagnostic Step: OTEL Effort Correlation

After the initial v2.1.117 re-run, if failures persist:
1. Integrate OTEL `effort` attribute (new in CC v2.1.117) as secondary diagnostic
2. Track effort level per test and correlate with pass/fail
3. This narrows failure attribution to adaptive thinking subsystem vs. other
   Opus 4.7 behavioral changes
4. Only pursue if re-run aggregate remains below 0.85 — if CC bug was the
   dominant factor, this step is unnecessary
```

**Rationale**: Well-sequenced conditional work. Depends on re-run results. Engineer correctly placed it in the failure analysis template rather than as a standalone document.

---

## Change 6: Gemini CLI Channel Selection Note (Discussion A3)

**Location**: Append to the S3 blocker human action item (wherever Gemini CLI install is tracked)
**Priority**: P3
**Effort**: 5 min
**Action**: Add recommendation note:

```
When installing Gemini CLI:
- Install stable (v0.38.2) for baseline S3 format comparison work
- Install preview alongside if parallel channel installs are supported, for
  subagent feature comparison (unified invoke_subagent in v0.39.0-preview)
- If parallel install not supported: install stable first, switch to preview
  for specific subagent feature tests
- Run any S3 eval twice (stable + preview) to separate platform features from
  preview-channel bugs
```

**Rationale**: Channel choice affects S3 eval quality. Having the recommendation ready prevents a wasted decision cycle when Jonas acts on the install.

---

## CC v2.1.117 Upgrade Impact Checklist (Discussion A6, inline)

**Location**: Inline in this document (Jonas-facing, not a separate file per Engineer)
**Priority**: P2

After upgrading CC to v2.1.117, verify:

1. **Shadow eval re-run** (P0) — run `daily_shadow_eval.sh`, compare per-test results to 0.683 baseline. Prefix match (commit 6e70617) ensures patched variants auto-trigger.
2. **Effort default check** — v2.1.117 sets default effort `high` for Pro/Max on Opus 4.6/Sonnet 4.6. Note: `claude -p` sessions may be classified differently than interactive Pro/Max sessions — the effort change may not affect our pipeline at all. Monitor first factory-steward session costs post-upgrade.
3. **Native bfs/ugrep** — Glob/Grep tools now use native implementations on Linux. Run researcher sweep, spot-check search result consistency vs. pre-upgrade.
4. **MCP concurrent connections** — new default for concurrent MCP server connections. Verify `.mcp.json` servers start correctly.
5. **Cron pipeline smoke test** — run one manual researcher sweep + factory session post-upgrade, verify no script breakage.

---

## No Phase 7 Changes

Consistent with morning cycle — Phase 7 pricing analysis is in `analysis/2026-04-22.md`. ROADMAP tracks tasks, not research.

---

## Factory-Steward Priority Queue (Combined Morning + Afternoon)

~10 remaining from morning queue + 6 afternoon ADOPTs = ~16 total. At 3 items/session, ~5-6 sessions to clear.

### Morning items (remaining ~10)

1. ADK v2.0 TCI comparison framework (P2, 30 min) — carried from Apr 21
2. Remote MCP feasibility study (P2, 30 min) — morning A1
3. Async dispatch convergence §5 (P2, 20 min) — morning A4
4. SessionStore design note (P2, 10 min) — carried from Apr 21
5. Phase 5 design index (P3, 20 min) — carried from Apr 21
6. Phase 5.1 planning confirmation note (P3, 5 min) — morning A2
7. I/O playbook note + sweep corrections log (P3, 10 min) — carried
8. Programmatic Tool Calling deny rule (P1, human action) — carried
9. G20 MCP false-positive tests (P2) — carried

### Afternoon additions (insert by priority)

| Position | Item | Priority | Effort |
|----------|------|----------|--------|
| Insert at #2 | A1: Shadow eval re-run protocol doc | P1 | 10 min |
| Insert at #5 | A2: Phase 5 context management section | P2 | 15 min |
| Insert at #6 | A5: Agent format comparison matrix | P2 | 25 min |
| Append | A3: Gemini CLI channel selection note | P3 | 5 min |
| Append | A4: OTEL effort integration plan note | P3 | 5 min |

Note: A6 (upgrade checklist) is documented inline above — no separate factory action needed.

---

## Human Action Items (Updated)

1. **Upgrade CC to v2.1.117** — **P0 (elevated from P1)**. Context window fix blocks clean shadow eval data. Also adds native bfs/ugrep, `mcpServers` frontmatter, OTEL effort attribute. Verify with 5-point checklist above.
2. **Install Gemini CLI** — gates all S3 implementation work (S3, unchanged). See channel selection note (Change 6).
3. **No shadow eval manual action** — infrastructure autonomous. Re-run triggers automatically after upgrade + prefix match.
