# ROADMAP Update Recommendations — 2026-04-20 Evening

**Source**: Evening + night analysis and discussions (3 cycles total for April 20)
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update shadow eval cron task status (DONE)

**Section**: Phase 4 → 4.4 Security hardening
**Priority**: P0 (accuracy)
**Action**: Mark task as complete

The morning proposal (Change 2) requested adding the shadow eval cron task. The factory steward delivered it in commit c0568c4 on April 20. Update:

```markdown
- [x] **Dedicated shadow eval cron script**: Created `scripts/daily_shadow_eval.sh` — standalone cron job (11:30 PM, no Claude session needed) that runs eval against pending migration model as direct Python invocation. Idempotent: checks experiment_log.json before running, fires only when PENDING_MIGRATION_MODEL set with zero matching entries. Writes results + go/no-go assessment. Solves L12 time-budget mismatch (88-min eval exceeds 44-min factory session). Sources cost_ceiling.sh + session_log.sh. Cron line: `30 23 * * * .../scripts/daily_shadow_eval.sh`. Source: proposal 2026-04-20-dedicated-shadow-eval-cron.md — P1 ✅ 2026-04-20
```

---

## PROPOSED CHANGE 2: Update dollar ceiling task status (DONE)

**Section**: Phase 4 → 4.4 Security hardening
**Priority**: P0 (accuracy)
**Action**: Mark task as complete

Delivered in commit c0568c4 on April 20.

```markdown
- [x] **Dollar ceiling on steward sessions**: Added `--max-budget-usd 10.00` to all `claude -p` invocations in 5 daily scripts (factory-steward 2 calls, researcher 7 calls, research-lead 1 call, ltc-steward 2 calls, kings-hand-steward 1 call). Complements existing duration ceiling (`cost_ceiling.sh`). All scripts pass syntax check — P1 ✅ 2026-04-20
```

---

## PROPOSED CHANGE 3: Update Model Migration dashboard status (DONE)

**Section**: Phase 4 → 4.3 Observability (or 4.4 Security)
**Priority**: P0 (accuracy)
**Action**: Mark task as complete

Delivered in commit 6649009 on April 20.

```markdown
- [x] **Model Migration dashboard section**: Added "Model Migration Status" section to `scripts/agent_review.sh` — shows current fleet model, pending migration target, shadow eval results (posterior mean + CI), and go/no-go G1 assessment. Surfaces migration status every time Jonas runs the dashboard. Source: discussion 2026-04-19 A5 — P2 ✅ 2026-04-20
```

---

## PROPOSED CHANGE 4: Amend experiment log validator task (wiring scope)

**Section**: Phase 4 → 4.4 (morning proposal Change 3)
**Priority**: P2
**Action**: Amend the morning's proposed task to include gate-first wiring

Evening discussion A2 amended this: the validator should wire into **both** shadow eval pre-flight AND factory gate-first preamble. Updated task text:

```markdown
- [ ] **Experiment log validator**: `eval/validate_experiment_log.py` — validates experiment_log.json schema (valid JSON, required fields, no duplicates, chronological timestamps). Wired into: (1) `daily_shadow_eval.sh` pre-flight, (2) `daily_factory_steward.sh` gate-first preamble via `&&`-chaining (`python3 eval/validate_experiment_log.py && grep "claude-opus-4-7" experiment_log.json`). Prevents silent S1 loop failure from corrupted state file. Source: discussion 2026-04-20 A3 + evening amendment A2 — P2
```

---

## PROPOSED CHANGE 5: Amend fleet manifest task (A2A-compatible field names)

**Section**: Phase 4 → 4.3 (morning proposal Change 4)
**Priority**: P2
**Action**: Amend the morning's proposed task to specify A2A field names

Evening discussion A1 amended this: use A2A Agent Card field names (`name`, `description`, `version`, `capabilities`, `provider`) with a `_schema` field (`a2a-agent-card-v1.0-subset`). Updated task text:

```markdown
- [ ] **Fleet manifest JSON**: `fleet_manifest.json` + `scripts/fleet_registry.sh` — machine-readable agent catalog generated from `.claude/agents/*.md` frontmatter. Uses A2A Agent Card field names (`name`, `description`, `version`, `capabilities`, `provider`) with `"_schema": "a2a-agent-card-v1.0-subset"`. Omits A2A-specific fields (`url`, `authentication`, `defaultInputModes`) — added in Phase 5. Replaces manual CLAUDE.md agent table. Source: discussion 2026-04-20 A5 + evening amendment A1 — P2
```

---

## PROPOSED CHANGE 6: Add shadow eval timeout safety net task

**Section**: Phase 4 → 4.4 Security hardening
**Priority**: P2
**Action**: Add new task

Night discussion A2: verify/add `timeout 5400` wrapper to shadow eval invocation. Prevents overlap with 1:00 AM researcher session. Check if the script already has a timeout from `cost_ceiling.sh`.

```markdown
- [ ] **Shadow eval timeout safety net**: Verify `daily_shadow_eval.sh` has timeout protection (90-min max via `timeout 5400` or existing cost_ceiling.sh integration). If eval exceeds 90 minutes, kill cleanly with TIMEOUT flag in performance JSON. Prevents API overlap with 1:00 AM researcher session. Source: discussion 2026-04-20-night A2 — P2
```

---

## PROPOSED CHANGE 7: Add Phase 5 Design Freeze calendar entry

**Section**: Phase 5 header or Phase 5 tasks preamble
**Priority**: P2
**Action**: Add new entry

Night discussion A3: schedule a design consolidation week after Google I/O. All scattered design documents (workflow-state-convergence.md, credential-isolation-design.md, post-io-response-playbook.md, permission-cache-design.md) get consolidated into a single PHASE_5_DESIGN.md.

```markdown
> **Phase 5 Design Freeze (May 22-26)**: Post-I/O consolidation week. Synthesize all I/O announcements + existing design documents (workflow-state-convergence.md, credential-isolation-design.md, post-io-response-playbook.md, permission-cache-design.md, argument allowlist profiles) into a single `PHASE_5_DESIGN.md`. Implementation begins only after this document is reviewed and approved. Source: discussion 2026-04-20-night A3.
```

---

## PROPOSED CHANGE 8: Add Phase 5 security requirement (hooks sanitization)

**Section**: Phase 5 → 5.5 Defensive architecture (or Phase 5.3 security note)
**Priority**: P3
**Action**: Add one line to existing security requirements

Evening discussion A3-evening: CheckPoint CVEs (CVE-2025-59536, CVE-2026-21852) demonstrate RCE via malicious `.claude/hooks/` in cloned repositories. Not an active threat to our pipeline (trusted codebase), but Phase 5 agents operating on external repos need protection.

```markdown
> **Security requirement (2026-04-20)**: Hooks sanitization for external repositories — scan `.claude/` directory in any cloned/forked repo before agent execution. Attack: malicious hooks achieve RCE and API token exfiltration (ref: CVE-2025-59536, CVE-2026-21852). Our exposure: low (trusted codebase). Phase 5 exposure: high (agents may process untrusted repos). Distinct vulnerability class from MCP STDIO — project-level, not transport-level.
```

---

## PROPOSED CHANGE 9: Add G4 cost gate to migration runbook reference

**Section**: Phase 4 → 4.4 (near shadow eval go/no-go task)
**Priority**: P3
**Action**: Add note to existing shadow eval task

Night discussion A5: add observational cost gate to graduated rollout. Not a blocking gate — an observation step during day 1 rollout.

```markdown
> **G4 cost observational gate (2026-04-20-night)**: During graduated rollout day 1 (factory-steward only), compare actual session duration and cost against Opus 4.6 baseline from performance JSONs. If daily cost increase > 50%, pause rollout and adjust dollar ceiling before expanding to more agents. Data source: `logs/performance/factory-*.json` duration fields. Not a pre-migration gate — a rollout monitoring step.
```

---

## PROPOSED CHANGE 10: Add night cycle directive guidance

**Section**: Not ROADMAP — research-lead directive instruction
**Priority**: P2
**Action**: Guidance for next directive (no ROADMAP change needed)

Night discussion A1-night: on weekends and vendor freeze days, cap at 1 discussion cycle per day. Skip night discussion if evening analysis delta is zero (no new releases, no new CVEs, no strategic status changes). This is a directive instruction, not a ROADMAP task.

**Note to research-lead**: Include in next directive: "One discussion cycle per day on weekends/vendor-freeze days. Skip night discussion if evening delta is zero."

---

## No Changes Proposed

- **Test set section**: Still shows 54 prompts in the Measurement Architecture section but actual count is 59. This was noted in morning proposals but not yet fixed. Carrying forward.
- **Phase 6/7 tasks**: No changes.
- **Acceptance criteria**: No changes.

---

*These recommendations do NOT modify ROADMAP.md directly. They are proposals for human review by Jonas or factory-steward implementation. This file covers evening + night discussion items; morning items are in `roadmap-updates-2026-04-20.md`.*
