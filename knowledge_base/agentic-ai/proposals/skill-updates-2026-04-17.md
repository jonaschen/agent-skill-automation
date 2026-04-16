# Skill Update Recommendations — 2026-04-17

**Produced by**: agentic-ai-researcher (Mode 2c, L4 Strategic Planning)
**Scope**: Modifications to existing agent / skill definitions. factory-steward reviews and applies per Action Safety rules.

---

## Update 1 — Fleet Agent `model:` Frontmatter (Staged Cascade)

**Trigger**: Opus 4.7 shipped 2026-04-16 at flat pricing. Shadow-eval gate must pass before any change.

**Affected files (orchestration-class agents only)**:

| File | Current | Proposed | Day |
|------|---------|----------|-----|
| `.claude/agents/factory-steward.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 1 (first cascade) |
| `.claude/agents/meta-agent-factory.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 2 |
| `.claude/agents/autoresearch-optimizer.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 2 |
| `.claude/agents/agentic-ai-researcher.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 |
| `.claude/agents/android-sw-steward.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 |
| `.claude/agents/arm-mrs-steward.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 |
| `.claude/agents/bsp-knowledge-steward.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 |
| `.claude/agents/ltc-steward.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 |
| `.claude/agents/project-reviewer.md` | `claude-opus-4-6` | `claude-opus-4-7` | Day 3 (review-pattern agent, Opus class) |

**Explicitly untouched (no Sonnet 4.7 exists)**:
- `.claude/agents/skill-quality-validator.md` (Sonnet 4.6)
- `.claude/agents/agentic-cicd-gate.md` (Sonnet 4.6)
- `.claude/agents/changeling-router.md` (Sonnet 4.6)
- Any watchdog / Sonnet-class review agents

**Gate per cascade step**:
1. Shadow eval on meta-agent-factory must show CI-overlap with T=0.895 baseline
2. Day 1 factory-steward nightly run must exit 0 with performance JSON within normal distribution
3. Day 2 cascade only if Day 1 is clean; similarly Day 3 contingent on Day 2

**Priority**: P0 (gated by proposal `2026-04-17-opus-4-7-shadow-eval-rollout.md`)

---

## Update 2 — agentic-ai-researcher.md: Add ZDR Policy Tracking to Sweep Workflow

**Trigger**: ZDR policy running log adopted (proposal `2026-04-17-zdr-policy-running-log.md`).

**Affected file**: `.claude/agents/agentic-ai-researcher.md`

**Proposed addition under "Automated Output Artifacts" section** (after `eval/deprecated_models.json` block):

```markdown
#### ZDR Policy Running Log (`knowledge_base/agentic-ai/evaluations/credential-isolation-design.md`)

During sweeps, when you detect a ZDR policy decision change from an official source (Anthropic docs,
Google Cloud compliance docs, vendor changelog), append a paragraph to the running log section of
`credential-isolation-design.md`. This feeds Phase 7 regulatory compliance groundwork.

Rules:
- **Append-only** — never remove or edit existing entries; corrections via a new dated entry
- **Per (tool × model × ZDR decision)** — one paragraph per unique combination
- **Required fields**: Tool, Model(s), Retention window, Regulatory implication (PDPA/APPI/GDPR), Source URL, Date
- **Scope**: public Anthropic + Google policy only; MCP-server-dependent ZDR status is out-of-scope for v1
```

**Priority**: P2

---

## Update 3 — agentic-ai-researcher.md: Event-Driven Sweep Queries Expanded

**Trigger**: Google I/O 32 days away; pre-I/O stability window discipline; ensure sweep coverage stays broad up to May 19-20.

**Affected file**: `.claude/agents/agentic-ai-researcher.md`

**Proposed addition to "Event-Driven Sweep Queries" section**:

```markdown
#### Anthropic Post-Opus-4.7 Tracking (2026-04-17 → 2026-05-31)

Add these queries to every sweep until a Sonnet 4.7 announcement lands or May 31, whichever comes first:
- `"Sonnet 4.7"` — shipping date would unlock review-class agent upgrades
- `"Mythos" public API Anthropic` — unblocks D6 / benchmark re-baselining
- `"Claude Code" "Routines" CLI` — first CLI-native Routines primitive triggers D5 reconsideration
- `"code_execution_20260120"` hook instrumentation — unblocks D1 programmatic tool calling pilot
- `MCP Triggers Events SEP draft` — unblocks D4 adoption evaluation

#### Post-Haiku-3 Retirement Verification (2026-04-19 → 2026-04-21)
Single-sweep targeted queries on Apr 19 morning:
- `"claude-3-haiku-20240307" retirement behavior`
- `Anthropic deprecation post-retirement error codes`
```

**Priority**: P2

---

## Update 4 — meta-agent-factory.md: Emit Factory Manifest v0

**Trigger**: Sprint contract manifest v0 adopted (proposal `2026-04-17-sprint-contract-manifest-v0.md`).

**Affected file**: `.claude/agents/meta-agent-factory.md`

**Proposed addition under agent deliverables**:

```markdown
## Factory Manifest v0 Emission

On every SKILL.md generation, also emit `eval/contracts/runs/<timestamp>/manifest.json` with the
structure documented in `eval/contracts/factory_manifest.v0.md`.

Required sections:
- `skill{}`: name, path, description_version, permission_tier, target_trigger_rate
- `security_constraints[]`: extracted from SKILL.md security section
- `pipeline_metadata{}`: factory_agent_version (git SHA of meta-agent-factory.md committed at
  generation time), timestamp, git_sha (HEAD at generation), correlation_id (new UUID)

Do NOT emit to non-contracts paths. Do NOT overwrite existing manifests (timestamp-dir per run).
Failure to emit the manifest is non-blocking — validator has fallback to SKILL.md frontmatter.
```

**Priority**: P1 (gated by proposal `2026-04-17-sprint-contract-manifest-v0.md`)

---

## Update 5 — skill-quality-validator.md: Opportunistic Manifest Read

**Trigger**: Same as Update 4.

**Affected file**: `.claude/agents/skill-quality-validator.md`

**Proposed addition**:

```markdown
## Factory Manifest v0 Consumption (Opportunistic)

On validation run, first look for `eval/contracts/runs/<timestamp>/manifest.json` where
`<timestamp>` is passed as context or derivable from the active run. If present, use manifest
fields as authoritative source for:
- Skill metadata (`skill_name`, `target_trigger_rate`, `permission_tier`)
- Security constraints (cross-check SKILL.md security section against `security_constraints[]`)
- Correlation_id (propagate into validator_report.json for end-to-end traceability)

If manifest is absent or malformed, log a warning to performance JSON and FALL BACK to
SKILL.md frontmatter parsing (existing behavior). Do NOT fail on missing manifest — v0 is
opportunistic, not required.
```

**Priority**: P1 (gated by Update 4)

---

## Update 6 — topology-aware-router.md: Expand to Three-Track Dispatch

**Trigger**: Three-track topology design adopted (proposal `2026-04-17-three-track-topology-dispatch-design.md`).

**Affected file**: `.claude/agents/topology-aware-router.md`

**Proposed content replacement for dispatch section**:

```markdown
## Three-Track Dispatch Logic (Design Complete; Runtime Pending §5.1 TCI Benchmark)

```
def select_track(task):
    tci = compute_tci(task)
    if tci <= 2:
        return ("TRACK_A_ORCHESTRATOR_WORKER", {"lead": "opus", "workers": 3})
    if tci >= 7:
        return ("TRACK_B_SEQUENTIAL_HARNESS", {"planner": "opus", "generator": "opus", "evaluator": "sonnet"})
    # TCI 3-6 middle band
    if has_clear_decision_points(task):
        return ("TRACK_C_ADVISOR_AUGMENTED", {"executor": "sonnet", "advisor": "opus"})
    return ("TRACK_B_SEQUENTIAL_HARNESS", {"planner": "opus", "generator": "opus", "evaluator": "sonnet"})
```

### Decision-Point Heuristics

- Skill-generation tasks (requirements → draft → validation) → `has_clear_decision_points = True`
- Steward phase-work sessions (open-ended autonomous time) → `has_clear_decision_points = False`
- Debugging tasks with explicit hypothesis checkpoints → `True`
- Documentation / refactoring → `False`

### Status

- **Design**: complete
- **Runtime**: blocked by Phase 5.1 50-task TCI benchmark
- **Canonical vocabulary source**: `knowledge_base/agentic-ai/analysis/three-track-topology-mapping.md`
```

**Priority**: P1 (gated by proposal `2026-04-17-three-track-topology-dispatch-design.md`)

---

## Update 7 — factory-steward.md: Apr 19 Pre-Flight Retirement Audit

**Trigger**: Post-retirement audit ritual adopted (proposal `2026-04-17-post-haiku3-retirement-audit.md`).

**Affected file**: `.claude/agents/factory-steward.md`

**Proposed addition** to session prompt or pre-flight checklist:

```markdown
## Pre-Flight Deprecation Audit (Retirement Days)

On Apr 19, Apr 30, May 11, Jun 15, Jul 5 (or any date after a model in `eval/deprecated_models.json`
retires), the first factory-steward run of the day must include:

```bash
scripts/model_audit.sh --retired-on $(date +%Y-%m-%d) --log logs/security/deprecation_audit.jsonl
eval/security_suite.sh --retired-models --log logs/security/deprecation_audit.jsonl
```

- Non-zero exit → HALT ROADMAP work; create escalation issue; flag to `scripts/agent_review.sh`
- Clean exit → append `"verified_clean_post_retirement": "<date>"` to the matching `eval/deprecated_models.json` entry
- Do NOT rely on email alerts (no verified mail daemon in cron environment)
- Idempotent: safe to run across all three daily factory-steward slots
```

**Priority**: P0 (Apr 19 is imminent)

---

## Update 8 — Description Field: No Changes Recommended Today

**Assessment**: Today's sweep did not surface new industry terminology that would change trigger
patterns for existing skills. No description-field optimization proposals today.

Future monitoring focus:
- When Google I/O 2026 lands (May 19-20), Mariner / Agent Builder rebrand may force KB filename
  renames + search pattern updates (tracked in threat 3.3 of 2026-04-17 analysis).
- When Mythos public API announces, `autoresearch-optimizer` description may need a `--model`
  flag mention for cross-model benchmarking.

---

## Cross-Reference Table

| Update | Affected File(s) | Gated By Proposal |
|--------|------------------|-------------------|
| 1 | 9 orchestration-class agents (model frontmatter) | 2026-04-17-opus-4-7-shadow-eval-rollout.md |
| 2 | agentic-ai-researcher.md (ZDR tracking) | 2026-04-17-zdr-policy-running-log.md |
| 3 | agentic-ai-researcher.md (sweep queries) | — (internal sweep discipline) |
| 4 | meta-agent-factory.md (manifest emission) | 2026-04-17-sprint-contract-manifest-v0.md |
| 5 | skill-quality-validator.md (manifest read) | 2026-04-17-sprint-contract-manifest-v0.md |
| 6 | topology-aware-router.md (three-track) | 2026-04-17-three-track-topology-dispatch-design.md |
| 7 | factory-steward.md (retirement audit pre-flight) | 2026-04-17-post-haiku3-retirement-audit.md |

---

*Produced by agentic-ai-researcher in Mode 2c. Advisory only — factory-steward or human operator applies after gate clearance.*
