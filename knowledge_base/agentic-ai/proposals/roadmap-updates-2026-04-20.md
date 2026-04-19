# ROADMAP Update Recommendations — 2026-04-20

**Source**: Sunday sweep analysis + Innovator/Engineer discussion
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update ROADMAP status line (shadow eval diagnosis)

**Section**: ROADMAP header status paragraph
**Priority**: P0 (accuracy)
**Action**: Update status to reflect shadow eval diagnosis

The current status says "Shadow eval for claude-opus-4-7 RUNNING" — this is stale. The eval was launched Apr 19 but could not complete within the factory session's time budget. Correct status:

> Shadow eval for claude-opus-4-7: gate-first contract A1 validated (eval launched, cache model-blindness fixed), but session timeout prevented completion. Manual run required by Jonas, or add dedicated cron slot (proposal 2026-04-20-dedicated-shadow-eval-cron.md). experiment_log.json has zero claude-opus-4-7 entries.

---

## PROPOSED CHANGE 2: Add shadow eval cron job task to Phase 4.4

**Section**: Phase 4 → 4.4 Security hardening
**Priority**: P1
**Action**: Add new task

```markdown
- [ ] **Dedicated shadow eval cron job**: `scripts/daily_shadow_eval.sh` at 11:30 PM — runs pending model migration eval as direct Python invocation (no Claude session). Checks experiment_log.json for existing results before running. Eliminates factory session time budget conflict. Source: discussion 2026-04-20 A2 — P1
```

---

## PROPOSED CHANGE 3: Add experiment log validator task to Phase 4.4

**Section**: Phase 4 → 4.4 Security hardening
**Priority**: P2
**Action**: Add new task

```markdown
- [ ] **Experiment log validator**: `eval/validate_experiment_log.py` — validates experiment_log.json schema (valid JSON, required fields, no duplicates, chronological timestamps). Called from pre-deploy.sh and daily_shadow_eval.sh as pre-flight. Prevents silent S1 loop failure from corrupted state file. Source: discussion 2026-04-20 A3 — P2
```

---

## PROPOSED CHANGE 4: Add fleet manifest task to Phase 4.3

**Section**: Phase 4 → 4.3 Observability
**Priority**: P2
**Action**: Add new task

```markdown
- [ ] **Fleet manifest JSON**: `fleet_manifest.json` + `scripts/fleet_registry.sh` — machine-readable agent catalog generated from `.claude/agents/*.md` frontmatter. Fields: name, model, status, permission_class, tools. Replaces manual CLAUDE.md agent table. Stepping stone to A2A Agent Cards (Phase 5). Source: discussion 2026-04-20 A5 — P2
```

---

## PROPOSED CHANGE 5: Add S1 milestone experiment record task

**Section**: Strategic Research Themes (or Phase 4 general)
**Priority**: P2
**Action**: Add new task

```markdown
- [ ] **S1 milestone documentation**: Write `knowledge_base/agentic-ai/experiments/s1-self-improvement-loop-validation.md` — documents the first autonomous model migration attempt (researcher detection → deprecation registry → A1 gate-first → cache fix → eval launch). Records what worked (detection, task generation, execution attempt), what failed (session timeout), and the fix (dedicated eval slot). Under 200 lines. Source: discussion 2026-04-20 A4 — P2
```

---

## PROPOSED CHANGE 6: Add MCP argument profile extraction task to Phase 5.5

**Section**: Phase 5 → 5.5 Defensive architecture
**Priority**: P3
**Action**: Add new task

```markdown
- [ ] **MCP argument profile extraction**: Extract (binary, argument_pattern) pairs from 30-day `logs/security/metachar_alert.jsonl` baseline into `eval/argument_allowlist.json`. Identifies legitimate vs. suspicious `-c`/`-e`/`--eval` flag usage. Data-only — no enforcement until PreToolUse hook implemented. Human review by Jonas required. Source: discussion 2026-04-20 A6 — P3
```

---

## PROPOSED CHANGE 7: Update Haiku 3 countdown

**Section**: ROADMAP header status paragraph
**Priority**: P0 (accuracy)
**Action**: Update countdown

Current: "Haiku 3 retirement 0d (Apr 20)" — this is now past. Update to reflect completion:

> Haiku 3 retirement: COMPLETE (Apr 20). Guard validated 3-layer clean pass on retirement day. Non-event for operations.

---

## PROPOSED CHANGE 8: Add risk — simultaneous vendor unfreeze burst

**Section**: Risks table (if one exists) or Phase 5 planning notes
**Priority**: P2
**Action**: Note for awareness

Both vendors are in the deepest simultaneous freeze this cycle. When they unfreeze (Google ~May 2 pre-I/O, Anthropic timing unknown), we'll see a burst of releases. The post-I/O response playbook covers Google. No equivalent exists for a burst Anthropic cycle, but normal sweeps handle this. Risk is KB staleness during the burst window (1-2 sweep lag).

---

## No Changes Proposed

- **Phase 5 tasks**: No new Phase 5 tasks beyond the MCP argument extraction (Change 6). All other DEFER items (D1-D5 from discussion) are correctly deferred.
- **Phase 4 acceptance criteria**: Unchanged. 4.2a gate already closed.
- **Strategic Research Themes**: No changes needed. S1/S2/S3 text is current.

---

*These recommendations do NOT modify ROADMAP.md directly. They are proposals for human review by Jonas or factory-steward implementation.*
