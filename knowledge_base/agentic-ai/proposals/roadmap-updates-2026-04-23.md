# ROADMAP Update Recommendations — 2026-04-23

**Source**: Analysis 2026-04-23 + Discussion 2026-04-23
**Author**: agentic-ai-researcher (Mode 2c)

---

## PROPOSED CHANGE 1: Update ROADMAP Status Line

**Section**: Top-level status paragraph
**Priority**: P2
**Rationale**: Current status reflects Apr 22 afternoon factory session. Should note ADK v2.0.0b1 impact assessment and factory queue state.

**Current**:
> Status as of 2026-04-22 (afternoon factory session): Phase 4 core complete. Shadow eval re-run protocol documented...

**Proposed** (append after current text or update next factory session):
> ADK v2.0.0b1 graph orchestration assessed — complementary to TCI routing (not competing). Factory queue at ~15 items (~5 sessions to clear). Pre-I/O design input inventory in progress.

---

## PROPOSED CHANGE 2: G20 Priority Note

**Section**: Phase 2.4 (G20 item)
**Priority**: P2
**Rationale**: G20 has been waiting 7 days. Discussion 2026-04-23 elevated it as a quiet-day execution target.

**Current**:
> [ ] **G20**: 5 MCP ecosystem false-positive tests (test_60–64)... — P2

**Proposed**: No text change needed. G20 is correctly specified. Factory steward should execute it per team-2026-04-23.md A4 instructions.

---

## PROPOSED CHANGE 3: Phase 5 Design Input Tracking

**Section**: Phase 5 (when created)
**Priority**: P2
**Rationale**: Phase 5 has accumulated 8+ design input documents across `evaluations/`, `papers/data/`, and `proposals/` over 2+ weeks. A design index is needed before I/O (26 days) to prevent integration chaos when I/O findings land.

**Proposed addition** (when Phase 5 section is formalized):
```
#### 5.0 Pre-I/O Design Input Inventory
- [ ] Create Phase 5 design index: list all pre-I/O design inputs with paths, strategic alignment, and post-I/O disposition columns
- [ ] Inventory includes: credential isolation, TCI comparison, permission cache, workflow convergence, hybrid routing, orchestration taxonomy, programmatic tool calling security, shadow eval re-run protocol
- [ ] Post-I/O: fill disposition column (still valid / superseded / needs update) within 1 week of I/O
```

---

## PROPOSED CHANGE 4: Day Count Updates

**Section**: Various countdown references
**Priority**: P3

Updated day counts for reference (no ROADMAP text change needed — these are tracked in sweep reports):
- 1M context beta sunset: 7 days (Apr 30)
- Google I/O: 26 days (May 19-20)
- Opus 4/Sonnet 4 retirement: 53 days (June 15)
- Phase 4 deadline (May 9): 16 days

---

## PROPOSED CHANGE 5: S2 Paper — Orchestration Taxonomy as Data Input

**Section**: Not directly in ROADMAP (paper project tracked separately)
**Priority**: P2
**Rationale**: Analysis 2026-04-23 Finding 3 crystallizes a novel agent-centric vs. workflow-centric orchestration taxonomy. This is citable, original framing for the S2 paper.

**Proposed**: No ROADMAP change. The paper project README should note this data input when factory steward creates `orchestration-taxonomy.md` (team proposal A1).

---

## No Priority Changes Recommended

All existing ROADMAP task priorities remain correctly calibrated. The ADK v2.0.0b1 beta findings are MODERATE impact, not critical — they enrich Phase 5 design without requiring priority changes. The TCI comparison framework (correctly blank for post-I/O filling) handles this.

## No New Risks Identified

Existing ROADMAP risks remain accurate:
- ADK v2.0 beta instability (Threat 2 in analysis) is already mitigated by the existing "No ADK/A2A integration until post-I/O" hold
- #49562 extended silence (Finding 4) is LOW risk for our fleet (runs Opus 4.6)
- Factory queue size (~15) is below alert threshold (>20)
