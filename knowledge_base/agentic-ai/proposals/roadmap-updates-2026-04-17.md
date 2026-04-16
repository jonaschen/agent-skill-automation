# ROADMAP Update Recommendations — 2026-04-17

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Based on**: Deep Analysis 2026-04-17 + Discussion 2026-04-17 + 2026-04-17 proposal set
**Status**: **ADVISORY** — ROADMAP.md is not modified by the researcher per Action Safety rules.
Human (or factory-steward with explicit user delegation) must apply changes.

---

## PROPOSED CHANGE 1 — Phase 3 Section: Add `--model` Flag + Opus 4.7 Baseline Reference

**Context**: Opus 4.7 shipped 2026-04-16 at flat pricing. Shadow-eval gate adopted (proposal `2026-04-17-opus-4-7-shadow-eval-rollout.md`).

**Current state** (ROADMAP §Phase 3 / §6.6): `--model` flag referenced but status unconfirmed.

**Proposed addition under Phase 3 — Measurement Infrastructure**:
```markdown
### Phase 3 Opus 4.7 Baseline (2026-04-17)
- **Baseline**: T=0.895 / V=0.900 on Opus 4.6 (G8 Iter 2)
- **Upgrade gate**: Opus 4.7 shadow eval must show CI-overlap with baseline; no regression allowed
- **Rollout**: factory-steward Day 1 → meta-agent-factory + optimizer Day 2 → researcher + remaining stewards Day 3
- **Review-class agents untouched**: Sonnet 4.7 does not exist; skill-quality-validator, agentic-cicd-gate, changeling-router, watchdog stay on Sonnet 4.6
- **Eval runner --model flag**: VERIFY exists in `eval/run_eval_async.py`; Step 0 of shadow-eval blocker
```

**Priority**: P0 (active this week)
**Owner**: factory-steward

---

## PROPOSED CHANGE 2 — Phase 4 Section: Add Sprint Contract Manifest v0 Task

**Context**: Three-Agent Harness blog (Apr 4) canonized structured handoff artifacts. Proposal `2026-04-17-sprint-contract-manifest-v0.md` scopes this as documented v0 object (not schema-enforced v1.0).

**Current state** (ROADMAP §10 Immediate Next Actions #10): "sprint contract manifest" scaffolded, no concrete spec.

**Proposed addition under Phase 4 — Closed Loop**:
```markdown
### Phase 4.4.m — Factory Manifest v0 (2026-04-17 → 2026-04-24)
- Emit `eval/contracts/runs/<timestamp>/manifest.json` from meta-agent-factory alongside SKILL.md
- Validator reads manifest.json opportunistically; falls back to SKILL.md frontmatter if absent
- Structure: `skill{}` (durable) + `security_constraints[]` + `pipeline_metadata{}` (ephemeral)
- correlation_id threads through factory → validator → optimizer performance JSONs
- **NOT** JSON Schema Draft 2020-12 validated — deferred to v1.0 at first agent swap
- **Trigger for v1.0 promotion**: first Phase 5 agent swap, or 4+ manifest consumers
```

**Priority**: P1 (this week)
**Owner**: factory-steward

---

## PROPOSED CHANGE 3 — Phase 4 Section: Fleet Version Bump + Pilot Allowlist Regeneration

**Context**: Claude Code v2.1.111 shipped `/less-permission-prompts` and `xhigh` effort tier. Fleet minimum is 2.1.101 (10 versions behind). Proposals `2026-04-17-fleet-version-bump-less-permission-prompts.md` and `2026-04-17-xhigh-effort-optimizer-pilot.md`.

**Current state** (ROADMAP §Phase 4): `fleet_min_version.txt` = 2.1.101.

**Proposed additions under Phase 4 — Operational Hygiene**:
```markdown
### Phase 4.4.n — Fleet Version Bump 2.1.101 → 2.1.111 (2026-04-17)
- Update `scripts/lib/fleet_min_version.txt`
- Alert shown until human upgrade confirmed
- Unlocks: `/less-permission-prompts`, `/effort` slider, `xhigh` tier, `/ultrareview`, `/tui`, push notifications

### Phase 4.4.o — Pilot Allowlist Regeneration (after next 10-Skill pilot)
- Run `/less-permission-prompts` inside pilot session
- Diff against `settings.local.json.backup-pre-pilot5`; narrower → replace; broader → investigate
- Commit with calibration-source note (pilot = broader surface than nightly)
- Archive prior backup to `.claude/settings.local.json.history/`

### Phase 4.4.p — xhigh Effort 3-Day Pilot (autoresearch-optimizer only)
- Step 0: Verify `xhigh` invocation path (env var / CLI flag / session-only)
- Step 1: Export `CLAUDE_CODE_EFFORT=xhigh` in optimizer invocation only
- Step 3 (Day 3): KEEP iff iterations_to_converge < 0.80 × baseline AND cost < 1.50 × baseline
- Forcing function: adds `iterations_to_converge` field to experiment_log (precondition for R1 ceiling reconsideration)
```

**Priority**: P1
**Owner**: factory-steward

---

## PROPOSED CHANGE 4 — Phase 5 Section: Three-Track Topology Dispatch (Design)

**Context**: Three canonical Anthropic multi-agent patterns (Three-Agent Harness, Orchestrator-Worker, Advisor) all published within two weeks. Advisor GA as of Apr 9 unblocks TCI routing range design. Proposal `2026-04-17-three-track-topology-dispatch-design.md`.

**Current state** (ROADMAP §Phase 5.2): TCI 3-6 band = "evaluation required" (ambiguous).

**Proposed replacement for §Phase 5.2 dispatch table**:
```markdown
### Phase 5.2 — Topology Dispatch (Three-Track, 2026-04-17 Design)

| TCI Band | Task Profile | Canonical Pattern | Our Track |
|----------|--------------|-------------------|-----------|
| ≤ 2 | Independent subtasks, parallelizable | Orchestrator-Worker | **Track A** (parallel cohort) |
| 3-6 | Moderate coupling, clear decision points | Inline Advisor | **Track C** (Sonnet + Opus advisor) |
| 3-6 | Moderate coupling, no decision points | (conservative fallback) | **Track B** (sequential) |
| ≥ 7 | Sequential, deep handoffs | Three-Agent Harness | **Track B** (sequential flagship) |

- Track C uses `advisor_20260301` (GA since 2026-04-09); Skill-generation tasks (clear decision points) are primary Track C candidates; steward phase-work typically routes to Track B.
- Design status: **complete**. Runtime status: **pending §5.1 TCI benchmark build-out** (50-task benchmark still unbuilt).
- Canonical Track A/B/C vocabulary lives in `knowledge_base/agentic-ai/analysis/three-track-topology-mapping.md` (single source of truth).
```

**Remove from §Phase 5.2**: the HOLD note "do not hardcode TCI routing ranges until advisor reaches GA" — advisor IS GA.

**Priority**: P1 (design, not runtime)
**Owner**: factory-steward for design; Phase 5.1 benchmark still required for runtime claim

---

## PROPOSED CHANGE 5 — Phase 4 Security: Programmatic Tool Calling Security Analysis (Blocker)

**Context**: `code_execution_20260120` GA on Opus 4.7. Hook coverage over container-internal tool calls unverified. Proposal `2026-04-17-programmatic-tool-calling-security-analysis.md`.

**Proposed addition under Phase 4 — Security**:
```markdown
### Phase 4 Security — Programmatic Tool Calling Gate (2026-04-18)
- **Status**: BLOCKING any programmatic-tool-calling pilot (researcher, factory, or other)
- **Deliverable**: `knowledge_base/agentic-ai/evaluations/programmatic-tool-calling-security.md`
- **Three-question analysis**:
  Q1: Does `post-tool-use.sh` fire on container-internal tool calls?
  Q2: If not, what container-level instrumentation exists?
  Q3: If not, what's the minimal `settings.local.json` deny rule?
- **Gate outcomes**: PASS → unblock pilots; BLOCK_WITH_DENY → pilot with deny rule in place; BLOCK_PENDING_INSTRUMENTATION → wait
```

**Priority**: P1
**Owner**: factory-steward

---

## PROPOSED CHANGE 6 — Deprecation Hygiene: Post-Retirement Audit Ritual

**Context**: Haiku 3 retires Apr 19. Proposal `2026-04-17-post-haiku3-retirement-audit.md`.

**Proposed addition under Phase 4 — Deprecation Detection Closed Loop**:
```markdown
### Phase 4 Deprecation Hygiene — Post-Retirement Audit Ritual
- Integrate into factory-steward morning run on retirement day
- Pre-flight: `scripts/model_audit.sh --retired-on <date> --log logs/security/deprecation_audit.jsonl`
- Clean exit: append `"verified_clean_post_retirement": "<date>"` to `eval/deprecated_models.json` entry
- Surface via `scripts/agent_review.sh` dashboard (no email — no verified mail daemon in cron)
- **Scheduled retirements requiring ritual**:
  - 2026-04-19: `claude-3-haiku-20240307`
  - 2026-04-30: `gemini-robotics-er-1.5-preview`
  - 2026-05-11: Sonnet 3.5 (both identifiers)
  - 2026-06-15: Sonnet 4 + Opus 4
  - 2026-07-05: Haiku 3.5 (both identifiers)
```

**Priority**: P0 (Apr 19 ritual is imminent)
**Owner**: factory-steward

---

## PROPOSED CHANGE 7 — Phase 7 Groundwork: ZDR Policy Running Log

**Context**: Opus 4.7 Computer Use is now ZDR-eligible; Programmatic Tool Calling NOT ZDR. Proposal `2026-04-17-zdr-policy-running-log.md`.

**Proposed addition under Phase 7 — Groundwork**:
```markdown
### Phase 7 Groundwork — ZDR Policy Running Log
- Extend `knowledge_base/agentic-ai/evaluations/credential-isolation-design.md` with append-only ZDR log
- Entries: one paragraph per (tool × model × ZDR decision), timestamped, source-linked
- Researcher appends during sweeps; factory-steward appends on pilot decisions
- **NOT** formal matrix (Phase 7 kickoff assembles from raw material)
- Current entries: Opus 4.7 Computer Use = ZDR / 0d; Programmatic Tool Calling = NOT ZDR / 30d; Standard tool use = ZDR / 0d
```

**Priority**: P2
**Owner**: agentic-ai-researcher + factory-steward (joint)

---

## PROPOSED CHANGE 8 — Lessons Learned: Add L12 (Three-Agent Harness Convergence)

**Context**: Our Phase 4 closed-loop architecture converges with Anthropic's canonical Three-Agent Harness. Strong external validation.

**Proposed new Lessons Learned entry**:
```markdown
### L12 — Three-Agent Harness External Validation (2026-04-17)
- Anthropic's Apr 4 "Harness Design for Long-Running Apps" blog canonized Planning/Generation/Evaluation with structured handoff artifacts
- Our pipeline (autoresearch-optimizer / meta-agent-factory / skill-quality-validator) maps directly; closed_loop.sh is the harness orchestrator
- Confirms our Phase 4 design as on the canonical path, not an experimental detour
- Action: formalize handoff artifacts (Factory Manifest v0) to match canonical pattern; defer 4-axis scoring expansion to post-stabilization
- **Principle**: when independent convergence on canonical architecture is observed, invest in tightening the fit (contracts, schemas, docs), not re-debating the approach
```

**Priority**: P2 (documentation; reinforces confidence in Phase 4 investment decisions)
**Owner**: factory-steward

---

## PROPOSED CHANGE 9 — Risk Table Update

**Proposed new risk entries**:

```markdown
| Risk | Likelihood | Impact | Mitigation | Owner |
|------|-----------|--------|------------|-------|
| Opus 4.7 silent routing regression | Medium | High (10 agents × 15 nightly runs) | Shadow-eval gate before rollout (proposal A1); graduated 4-day cascade | factory-steward |
| `code_execution_20260120` security envelope bypass | Medium | Catastrophic (silent) | Pre-pilot security analysis (proposal A7); BLOCK until Q1/Q2/Q3 answered | factory-steward |
| I/O 2026 ADK v2.0 / A2A v1.1 breaking changes | Low | Medium | Already mitigated by §5 HOLD directive; reassess May 21 | factory-steward |
| Mariner / Agent Builder rebrand link rot in KB | Low | Low | Post-I/O rename pass via `google-io-2026.md` dedicated analysis | agentic-ai-researcher |
| Allowlist shrinkage from narrow-session regeneration | Medium | Medium | Commit message discipline + `.claude/` README | factory-steward |
```

**Priority**: P1 (new risks should be tracked before the corresponding work lands)
**Owner**: factory-steward

---

## PROPOSED CHANGE 10 — Status Update Line

**Proposed replacement for top-of-ROADMAP status line**:
```markdown
**Current status (2026-04-17):** Phase 3 G8 Iter 2 stable (T=0.895 / V=0.900). Phase 4 closed loop operational; 4.2a gate closed. Opus 4.7 shipped 2026-04-16 at flat pricing — shadow-eval gate adopted P0, 4-day fleet cascade pending. Fleet minimum bump to Claude Code 2.1.111 pending human upgrade. Haiku 3 retires 2026-04-19 (ritual integrated into factory-steward morning run). Google I/O 2026 in 32 days; ADK/A2A HOLD remains in force. Phase 5 three-track topology dispatch design adopted; runtime pending §5.1 TCI benchmark build-out.
```

**Priority**: P1 (reflects current state accurately)
**Owner**: factory-steward (post-review of adopted proposals)

---

## Summary Table

| ID | Change | Priority | Owner |
|----|--------|----------|-------|
| C1 | Phase 3: Opus 4.7 baseline + `--model` flag discipline | P0 | factory-steward |
| C2 | Phase 4.4.m: Factory Manifest v0 | P1 | factory-steward |
| C3 | Phase 4.4.n-p: Version bump + allowlist + xhigh pilot | P1 | factory-steward |
| C4 | Phase 5.2: Three-track topology dispatch (design) | P1 | factory-steward |
| C5 | Phase 4 Security: Programmatic tool calling gate | P1 | factory-steward |
| C6 | Phase 4: Post-retirement audit ritual | P0 | factory-steward |
| C7 | Phase 7 Groundwork: ZDR running log | P2 | researcher + factory-steward |
| C8 | Lessons Learned L12: Three-Agent Harness convergence | P2 | factory-steward |
| C9 | Risk table: 5 new entries | P1 | factory-steward |
| C10 | Top-of-file status line | P1 | factory-steward |

---

*Produced by agentic-ai-researcher in Mode 2c. Not applied — advisory only. factory-steward or human operator should apply after review.*
