# ROADMAP Update Recommendations — 2026-04-21 (Afternoon)

**Source**: Afternoon analysis + afternoon discussion (freeze break findings)
**Authority**: Researcher recommendation — requires human review before applying
**Supplements**: `roadmap-updates-2026-04-21.md` (morning, freeze-day content — still valid)

---

## PROPOSED CHANGE 1: Add shadow eval per-test logging task to Phase 4.4

**Section**: Phase 4 → 4.4 Security hardening for autonomous execution
**Priority**: P1
**Source**: Afternoon analysis Finding 1, afternoon discussion A1

**Add after the "Shadow eval timeout safety net" entry:**

```markdown
- [ ] **Shadow eval per-test result logging**: Modify `daily_shadow_eval.sh` to capture `run_eval_async.py` per-test pass/fail output and write it to `experiment_log.json` as a `per_test_results` array in the shadow eval entry. Enables S1 failure pattern characterization (routing regression vs. fundamental behavior change). Must be in place before next Opus 4.7 patch triggers re-run. Source: afternoon analysis 2026-04-21 Finding 1 — P1
```

**Rationale**: The shadow eval infrastructure works (produced correct NO-GO verdict) but under-instruments. Without per-test data, the S1 strategy defaults to "wait for patch" when the failures may be concentrated and fixable via description tuning. This is the sharpest S1 gap identified since the shadow eval infrastructure was built.

---

## PROPOSED CHANGE 2: Add shadow eval failure analysis template task to Phase 4.4

**Section**: Phase 4 → 4.4 Security hardening for autonomous execution
**Priority**: P2
**Source**: Afternoon discussion A4

**Add after the per-test logging entry:**

```markdown
- [ ] **Shadow eval failure analysis template**: Add "Shadow Eval Failure Analysis" section to `eval/model_migration_runbook.md` — three-category failure breakdown (positive 1-22, hallucination 23-39, near-miss 40-59), per-category failure rate, decision tree with >66% concentration threshold, S1 action mapping (positive-concentrated → description tuning, negative-concentrated → wait for patch, mixed → both). Makes next shadow eval result immediately actionable. Source: afternoon discussion 2026-04-21 A4 — P2
```

**Rationale**: Complements the per-test logging (Change 1). Together they form a complete S1 diagnostic pipeline: per-test data → failure pattern classification → S1 action decision.

---

## PROPOSED CHANGE 3: Add fleet version bump to Phase 4.4

**Section**: Phase 4 → 4.4 Security hardening for autonomous execution
**Priority**: P1
**Source**: Afternoon analysis Finding 2, afternoon discussion A2

**Add:**

```markdown
- [ ] **Fleet minimum version bump to >=2.1.116**: Update `fleet_min_version.txt`. v2.1.116 adds 67% `/resume` speedup on 40MB+ sessions, sandbox rm/rmdir safety for system dirs, MCP startup optimization, thinking progress indicators. Human upgrade pending — P1
```

**Rationale**: Fleet is two versions behind after freeze break. The `/resume` speedup directly benefits steward sessions. The sandbox security fix closes a sandbox escape vector relevant to autonomous execution. Supersedes morning recommendation to upgrade to v2.1.114+ — now v2.1.116 is the target.

---

## PROPOSED CHANGE 4: Add SessionStore design note to Phase 5.3.2

**Section**: Phase 5 → 5.3.2 Task-level workflow state tracking
**Priority**: P2
**Source**: Afternoon analysis Finding 3, afternoon discussion A3

**Add as a new design note block after existing 5.3.2 design notes:**

```markdown
> **Design note (2026-04-21)**: Agent SDK v0.1.64 ships production-ready SessionStore with three reference adapters (S3, Redis, Postgres) and conformance tests. SessionStore is a leading candidate for Phase 5.3.2 crash recovery implementation — simplifies recovery from "parse JSONL, find checkpoint, rebuild context" to "call `getSession(id)` + `resume()`." Trade-off: couples 5.3.2 to Agent SDK migration (5.3.3). Custom JSONL approach works with current `claude -p` and can be replaced later. **Decision deferred to Design Freeze week (May 22-26).** Reference: fifth convergent pattern in `workflow-state-convergence.md`.
```

**Rationale**: SessionStore is exactly the abstraction Phase 5.3.2 was planning to build custom. Recording this now while the analysis is fresh ensures the Design Freeze week has a pre-analyzed option.

---

## PROPOSED CHANGE 5: Add sweep corrections log to Phase 4.3 Observability

**Section**: Phase 4 → 4.3 Observability
**Priority**: P3
**Source**: Afternoon discussion A7

**Add:**

```markdown
- [ ] **Sweep corrections log**: Create `logs/sweep_corrections.jsonl` — evening consolidation sweep appends structured entries when corrections issued (claim, correction, verification method, category). Provides measurement data for sweep hallucination rate tracking. Source: afternoon discussion 2026-04-21 A7 — P3
```

**Rationale**: The two-sweep architecture correctly catches hallucinations. This log measures the correction rate, enabling data-driven decisions about whether to add automated post-sweep verification.

---

## PROPOSED CHANGE 6: Add shadow eval data gap to Risk Table

**Section**: Key Risks to Watch
**Priority**: P1
**Source**: Afternoon analysis Finding 1

**Add new risk entry:**

```markdown
| Shadow eval produces aggregate-only results — blocks S1 failure characterization | 4 | Per-test result logging in `daily_shadow_eval.sh` + failure analysis template in migration runbook. Must be in place before next Opus 4.7 patch | New — P1 mitigation in progress 2026-04-21 |
```

**Rationale**: New risk category: infrastructure works but under-instruments. The pipeline correctly detected a platform change and rejected migration, but cannot diagnose WHY.

---

## PROPOSED CHANGE 7: Add ADK v1.31.1 minimum version note to Phase 5

**Section**: Phase 5 → 5.3.0 A2A protocol evaluation (or nearby)
**Priority**: P3
**Source**: Afternoon analysis Finding 4

**Add as design note:**

```markdown
> **Security note (2026-04-21)**: ADK v1.31.1 patched a critical RCE via nested YAML unsafe deserialization. Any Phase 5 ADK integration MUST use v1.31.1+ as minimum version. Our pipeline avoids this vulnerability class architecturally (SKILL.md YAML frontmatter is parsed by the LLM, not by a Python YAML library with execution capabilities). Reference: afternoon analysis 2026-04-21 Finding 4.
```

**Rationale**: Documents a concrete security floor for ADK integration and the architectural reason our pipeline is not affected.

---

## PROPOSED CHANGE 8: Update Human Action Items

**Supersedes**: Morning recommendation item 3 ("Upgrade Claude Code to v2.1.114+")

Updated human action items for next directive:

1. **Upgrade CC to v2.1.116** (was v2.1.114+) — 67% `/resume` speedup, sandbox security fix. Two versions behind.
2. **Install Gemini CLI** — gates all S3 research beyond format comparison (unchanged)
3. **Review Opus 4.7 NO-GO decision** — pipeline correctly rejected. Per-test logging will enable failure characterization on next re-run (new item — replaces "run shadow eval manually" which is now resolved)

---

## Summary of Proposed Changes

| # | Section | Priority | Type |
|---|---------|----------|------|
| 1 | Phase 4.4 — shadow eval per-test logging | P1 | New task |
| 2 | Phase 4.4 — failure analysis template | P2 | New task |
| 3 | Phase 4.4 — fleet version bump | P1 | New task |
| 4 | Phase 5.3.2 — SessionStore design note | P2 | Design note |
| 5 | Phase 4.3 — sweep corrections log | P3 | New task |
| 6 | Risk table — shadow eval data gap | P1 | New risk |
| 7 | Phase 5.3.0 — ADK minimum version | P3 | Security note |
| 8 | Human action items | P1 | Update |
