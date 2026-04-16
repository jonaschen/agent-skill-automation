# Skill Proposal: Three-Track Topology Dispatch Design (Phase 5)

**Date**: 2026-04-17
**Triggered by**: Three canonical Anthropic multi-agent patterns published within two weeks — Three-Agent Harness (Apr 4), Multi-Agent Research System / Orchestrator-Worker (Apr 15), Advisor Tool (GA Apr 9). ROADMAP §5.2 design note 2026-04-11 explicitly said "do not hardcode TCI routing ranges until advisor reaches GA" — that constraint is now lifted. Analysis §1.4; Discussion A6 (ADOPT P1 as design artifact).
**Priority**: **P1** (high — vendor-neutral design during pre-I/O stability window)
**Target Phase**: Phase 5 (topology-aware multi-agent)

## Rationale

Anthropic has now canonized **three distinct multi-agent topologies**, each optimized for a
different task profile. Our Phase 5 topology-aware-router is currently stubbed for binary dispatch
(Track A parallel / Track B single flagship). The TCI 3-6 middle band is labeled "evaluation
required" with no concrete third topology assigned.

The three canonical patterns map cleanly onto three TCI bands:

| TCI Band | Task Profile | Anthropic Pattern | Proposed Track |
|----------|--------------|-------------------|----------------|
| ≤ 2 | Independent subtasks, parallelizable | Orchestrator-Worker (Apr 15 research system) | **Track A** (parallel cohort, lead + 3-5 workers, synchronous) |
| 3-6 | Moderate coupling, bounded state, 2-3 decision points | Inline Advisor (GA Apr 9) | **Track C** (Sonnet executor + Opus advisor, augmented) |
| ≥ 7 | Sequential with deep handoffs, 5-15 refinement iterations | Three-Agent Harness (Apr 4) | **Track B** (sequential flagship with structured artifacts) |

**Discussion consensus (2026-04-17 Round 2)**:
- Adopt the three-track **design document** — canonical mapping, rationale, TCI band ranges, dispatch logic
- **Do NOT** claim runnable capability: 50-task TCI benchmark (ROADMAP §5.1) is still unbuilt
- Mark the artifact as "design complete, validation pending Phase 5 benchmark build-out"
- Advisor tool applicability is narrower than it appears: skill generation has clear decision points; stewards (phase work) don't. Track C doesn't apply uniformly.
- Avoid Track A/B/C vocabulary collision: Phase 5 already uses Track A/B. Canonical mapping must live in **one** document.

## Proposed Specification

- **Name**: Three-Track Topology Dispatch Design
- **Type**: Design Artifact (agent stub + ROADMAP section + canonical mapping doc)
- **Owner**: factory-steward

**Deliverables**:

**Deliverable 1 — Expand `.claude/agents/topology-aware-router.md`**:
- Replace binary dispatch stub with three-track logic
- Dispatch pseudocode:
  ```
  def select_track(task):
      tci = compute_tci(task)  # from §5.1 benchmark when built
      if tci <= 2:
          return "TRACK_A_ORCHESTRATOR_WORKER"
      elif 3 <= tci <= 6 and has_clear_decision_points(task):
          return "TRACK_C_ADVISOR_AUGMENTED"
      elif 3 <= tci <= 6:
          # No clear decision points → conservative default
          return "TRACK_B_SEQUENTIAL_HARNESS"
      else:  # tci >= 7
          return "TRACK_B_SEQUENTIAL_HARNESS"
  ```
- Document `has_clear_decision_points` heuristic: skill-generation tasks (requirements → draft → validation) YES; phase-work tasks (open-ended steward sessions) NO
- Mark agent status: `design: complete | runtime: pending §5.1 TCI benchmark`

**Deliverable 2 — Update `ROADMAP.md` §Phase 5.2**:
- Proposed replacement for "evaluation required" middle band:
  > "TCI 3-6 band: Track C (Advisor-augmented) for tasks with clear decision points; Track B (Sequential Harness) otherwise. See `topology-aware-router.md` for dispatch logic."
- Note: do NOT modify ROADMAP.md directly — write proposed change to `roadmap-updates-2026-04-17.md` for human review

**Deliverable 3 — Canonical mapping doc `knowledge_base/agentic-ai/analysis/three-track-topology-mapping.md`**:
- Single source of truth for Track A/B/C vocabulary
- Mapping table (above)
- Pattern references with source URLs
- Anti-pattern examples (why Track A for sequential tasks fails, etc.)

**Tools Required**: Read, Write, Edit (for agent stub and docs)

## Implementation Notes

**Dependencies**:
- Phase 5 HOLD on ADK/A2A does NOT block this work (topology choice is vendor-neutral; transport selection is orthogonal)
- Implementation / runnable dispatch remains blocked by §5.1 50-task TCI benchmark
- `advisor_20260301` beta → GA transition confirmed in 2026-04-09 sweep + 2026-04-17 sweep

**Risk**:
- Vocabulary sprawl: Track A/B/C must be defined in exactly one canonical place. Multi-point definition causes drift. Mitigation: Deliverable 3 is THE source; others cross-reference.
- Premature commitment: if Google I/O 2026 ships ADK v2.0 with its own topology primitives that subsume the Anthropic patterns, our Track A/B/C abstraction becomes wrapper-on-wrapper. Mitigation: design is vendor-neutral (Track = abstract role), can re-map to ADK primitives if ADK wins semantically.
- Advisor narrow applicability: Track C may end up used by only skill-generation flows, not steward flows. Mitigation: dispatch pseudocode explicitly accounts for this with `has_clear_decision_points` fallback.

**Do NOT**:
- Claim runnable three-track dispatch until §5.1 benchmark exists
- Modify ROADMAP.md directly (write to roadmap-updates-2026-04-17.md instead)
- Spread Track A/B/C definitions across multiple docs

## Estimated Impact

- **Architectural clarity**: eliminates "evaluation required" ambiguity in TCI 3-6 band
- **Vendor-neutral foundation**: when ADK v2.0 lands post-I/O, mapping layer absorbs the change instead of requiring Phase 5 redesign
- **Pre-I/O timing**: locks abstraction layer before vendor-surface churn
- **Forcing function for §5.1**: concrete dispatch logic now creates urgency for TCI benchmark build-out (currently unbuilt)
- **Supports three-agent harness validation**: Track B is the formalized Phase 4 closed-loop architecture (sprint contract manifest v0 proposal provides the handoff artifacts)
