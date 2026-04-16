# Skill Proposal: Sprint Contract Manifest v0 (Factory→Validator Handoff)

**Date**: 2026-04-17
**Triggered by**: Anthropic's Apr 4 "Harness Design for Long-Running Apps" engineering blog canonized the Three-Agent Harness (Planning / Generation / Evaluation) with **structured handoff artifacts replacing rolling context**. Our meta-agent-factory → skill-quality-validator → autoresearch-optimizer pipeline maps onto this canon directly. Analysis §1.2; Discussion A3 (ADOPT P1, scoped down).
**Priority**: **P1** (high — architectural alignment during pre-I/O stability window)
**Target Phase**: Phase 4 (closed loop)

## Rationale

The Three-Agent Harness blog formalizes what our pipeline built independently: Planning (autoresearch-optimizer)
/ Generation (meta-agent-factory) / Evaluation (skill-quality-validator). The canonical pattern prescribes
**structured handoff artifacts** between agents, not shared rolling context.

Today, our handoffs are implicit:
- Factory → Validator: SKILL.md file path + frontmatter (validator re-derives metadata)
- Validator → Optimizer: JSON report with `trigger_rate`, `ci_lower`, `ci_upper`, `security_score`, `recommendations`

These work, but they're brittle. Agent replacement (Mythos-class validator in 6+ months, A2A transport
post-I/O) would require re-implementing the implicit contract.

**Discussion consensus (2026-04-17 Round 1)**:
- Adopt the sprint contract manifest, but scope down from the Innovator's original "formal JSON Schema Draft 2020-12" ask
- Scope reduction: **v0 is a documented JSON object**, not a validated schema. Validator reads opportunistically; falls back to SKILL.md frontmatter if manifest is absent.
- Schema validation (`v1.0`) deferred until first real Phase 5 agent swap forces the discipline
- Separate skill-level metadata (durable) from pipeline-state metadata (ephemeral git_sha)

## Proposed Specification

- **Name**: Factory Manifest v0
- **Type**: Pipeline Contract Artifact (documented JSON object; no schema enforcement)
- **Location**: `eval/contracts/factory_manifest.v0.md` (doc) + emitted to `eval/contracts/runs/<timestamp>/manifest.json` (runtime)

**Manifest Structure**:

```json
{
  "$doc_version": "0",
  "skill": {
    "name": "<kebab-case>",
    "path": ".claude/skills/<name>/SKILL.md",
    "description_version": "<monotonic counter, or git SHA of description>",
    "permission_tier": "review|execution|orchestration",
    "target_trigger_rate": 0.90
  },
  "security_constraints": [
    "<security constraint 1>",
    "<security constraint 2>"
  ],
  "pipeline_metadata": {
    "factory_agent_version": "<git SHA of meta-agent-factory.md>",
    "timestamp": "2026-04-17T12:00:00Z",
    "git_sha": "<HEAD SHA at generation time>",
    "correlation_id": "<uuid for tracing through factory → validator → optimizer>"
  }
}
```

**Lifetime of Sections**:
- `skill`: durable; co-versioned with SKILL.md
- `security_constraints`: durable; extracted from SKILL.md or requirements
- `pipeline_metadata`: ephemeral; reset per-run

**Agent Changes**:

| Agent | Change |
|-------|--------|
| meta-agent-factory | On SKILL.md Write, also write `eval/contracts/runs/<timestamp>/manifest.json` |
| skill-quality-validator | Read `manifest.json` if present; else fall back to SKILL.md frontmatter (current behavior) |
| autoresearch-optimizer | Read validator_report.json (already exists; no change for v0) |
| factory-steward | Surface correlation_id in performance JSON for traceability |

**Tools Required**: Write (meta-agent-factory already has); Read (validator already has)

## Implementation Notes

**Dependencies**:
- `eval/contracts/` directory must be created (it does not exist today)
- `.claude/hooks/post-tool-use.sh` Write coverage must include `eval/contracts/runs/` path (security)
- Validator fallback to SKILL.md frontmatter must be explicit (keep current behavior as else-branch)

**Risk**:
- Schema drift: a documented-object-without-enforcement is easy to diverge from spec. Mitigation: validator logs a warning when manifest fields are missing or unrecognized; factory-steward surfaces in dashboard.
- Premature complexity: if v0 goes unused for 3+ months, remove it. Don't let a speculative artifact accumulate dead weight.
- Agent-version identifier: using git SHA ties manifest to repo state; if factory-steward auto-tunes meta-agent-factory.md mid-session, SHA may be ahead of latest commit. Mitigation: use committed SHA at generation time, not HEAD at emission time.

**Do NOT (v0 scope — explicitly deferred to v1.0)**:
- JSON Schema Draft 2020-12 enforcement
- `$id` URIs, versioned schema evolution rules
- Additive-only field contract (enforced by CI)
- Tests that break on schema violation

**v1.0 Trigger (explicit gate)**:
- First Phase 5 agent swap (validator replacement, topology-aware router integration, A2A transport) — this is what forces schema rigor
- OR: a second, third, fourth consumer of the manifest joins the pipeline (at 4+ consumers, schema cost amortizes)

## Estimated Impact

- **Architectural alignment** with Anthropic canonical Three-Agent Harness pattern
- **Traceability**: correlation_id threads a single skill generation through all three agents' logs and performance JSONs
- **Agent replaceability groundwork**: future Mythos-class validator can be dropped in by reading the same manifest
- **Low risk**: opportunistic read + fallback keeps current pipeline behavior intact
- **Phase 4 closure support**: documented handoff contract is a gate-closure deliverable for the "closed loop" definition
